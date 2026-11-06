import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/data_source/api/dio_client.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_token_repository.dart';

class _RecordingCrashReporter implements CrashReporter {
  final List<String> reasons = [];

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {
    reasons.add(reason);
  }
}

class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  late Future<ResponseBody> Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      // 멀티파트 본문 스트림을 끝까지 읽어야 FormData가 "소비"된다.
      await for (final _ in requestStream) {}
    }
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, [Object body = const {}]) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ResponseBody _refreshed() => _json(200, {
  'accessToken': 'reissued',
  'refreshToken': 'reissued-refresh',
});

void main() {
  late FakeTokenRepository tokenRepository;
  late _FakeAdapter adapter;
  late Dio dio;
  late int sessionExpiredCount;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();
    tokenRepository = FakeTokenRepository()
      ..accessToken = 'access-1'
      ..refreshToken = 'refresh-1';
    adapter = _FakeAdapter();
    sessionExpiredCount = 0;
    dio = buildDio(
      tokenRepository,
      adapter: adapter,
      onSessionExpired: () => sessionExpiredCount++,
    );
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('토큰이 있으면 Bearer 헤더만 붙인다 (Refresh-Token 헤더는 없다)', () async {
    adapter.responder = (_) async => _json(200);

    await dio.get('/diaries');

    final sent = adapter.requests.single;
    expect(sent.headers['Authorization'], 'Bearer access-1');
    expect(sent.headers.containsKey('Refresh-Token'), isFalse);
  });

  test('needsAuth가 false면 인증 헤더를 붙이지 않고 401도 재발급하지 않는다', () async {
    adapter.responder = (_) async => _json(401, {'code': 'TOKEN_EXPIRED'});

    await expectLater(
      dio.post(
        '/auth/social/google',
        options: Options(extra: {AuthInterceptor.needsAuthKey: false}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    expect(adapter.requests.length, 1);
    expect(sessionExpiredCount, 0);
  });

  test('TOKEN_EXPIRED 401이면 /auth/refresh 바디로 재발급하고 한 번 재시도한다', () async {
    var diariesCalls = 0;
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) {
        expect(options.data, {
          'refreshToken': 'refresh-1',
          'deviceId': 'device-uuid',
        });
        return _refreshed();
      }
      diariesCalls++;
      return diariesCalls == 1
          ? _json(401, {'code': 'TOKEN_EXPIRED'})
          : _json(200);
    };

    final response = await dio.get('/diaries');

    expect(response.statusCode, 200);
    expect(diariesCalls, 2);
    expect(tokenRepository.accessToken, 'reissued');
    expect(tokenRepository.refreshToken, 'reissued-refresh');
    expect(adapter.requests.last.headers['Authorization'], 'Bearer reissued');
    expect(sessionExpiredCount, 0);
  });

  test('코드를 못 읽는 401도 refresh를 한 번 시도한다', () async {
    var diariesCalls = 0;
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) return _refreshed();
      diariesCalls++;
      return diariesCalls == 1
          ? ResponseBody.fromString('', 401)
          : _json(200);
    };

    final response = await dio.get('/diaries');

    expect(response.statusCode, 200);
    expect(diariesCalls, 2);
  });

  test('TOKEN_INVALID 401이면 refresh 없이 토큰을 지우고 세션 만료를 알린다', () async {
    adapter.responder = (_) async => _json(401, {'code': 'TOKEN_INVALID'});

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(adapter.requests.length, 1);
    expect(tokenRepository.accessToken, isNull);
    expect(tokenRepository.refreshToken, isNull);
    expect(sessionExpiredCount, 1);
  });

  test('refresh가 REFRESH_INVALID로 거부되면 토큰을 지우고 세션 만료를 알린다', () async {
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) {
        return _json(401, {'code': 'REFRESH_INVALID'});
      }
      return _json(401, {'code': 'TOKEN_EXPIRED'});
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(tokenRepository.accessToken, isNull);
    expect(sessionExpiredCount, 1);
    // 원요청 1 + refresh 1. 재시도는 없다.
    expect(adapter.requests.length, 2);
  });

  test('refresh가 500으로 실패하면 토큰을 유지하고 재시도하지 않는다', () async {
    final reporter = _RecordingCrashReporter();
    ApiException.reporter = reporter;
    var diariesCalls = 0;
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) {
        return ResponseBody.fromString('', 500);
      }
      diariesCalls++;
      return _json(401, {'code': 'TOKEN_EXPIRED'});
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(diariesCalls, 1);
    expect(tokenRepository.accessToken, 'access-1');
    expect(sessionExpiredCount, 0);
    expect(reporter.reasons, contains('refreshTokens 실패'));
  });

  test('재시도한 요청도 401이면 더 재시도하지 않는다', () async {
    var diariesCalls = 0;
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) return _refreshed();
      diariesCalls++;
      return _json(401, {'code': 'TOKEN_EXPIRED'});
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(diariesCalls, 2);
  });

  test('동시에 여러 요청이 401을 받아도 refresh는 한 번만 나간다 (single-flight)', () async {
    var refreshCalls = 0;
    final firstAttempts = <String>{};
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return _refreshed();
      }
      if (firstAttempts.add(options.path)) {
        return _json(401, {'code': 'TOKEN_EXPIRED'});
      }
      return _json(200);
    };

    final results = await Future.wait([
      dio.get('/diaries'),
      dio.get('/users/me'),
      dio.get('/users/me/stats'),
    ]);

    expect(results.map((r) => r.statusCode), everyElement(200));
    expect(refreshCalls, 1);
    expect(tokenRepository.saveJwtTokensCallCount, 1);
  });

  test('401 후 FormData 요청도 clone된 본문으로 한 번만 재시도한다', () async {
    var uploadCalls = 0;
    adapter.responder = (options) async {
      if (options.path.contains('/auth/refresh')) return _refreshed();
      uploadCalls++;
      return uploadCalls == 1
          ? _json(401, {'code': 'TOKEN_EXPIRED'})
          : _json(200, {'diaryId': 1});
    };

    final tempFile = await File(
      '${Directory.systemTemp.path}/auth_interceptor_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
    ).create();
    await tempFile.writeAsBytes([1, 2, 3, 4]);
    addTearDown(() async {
      if (await tempFile.exists()) await tempFile.delete();
    });

    final formData = FormData.fromMap({
      'text': 'hello',
      'images': [await MultipartFile.fromFile(tempFile.path)],
    });

    final response = await dio.post('/diaries', data: formData);

    expect(response.statusCode, 200);
    expect(uploadCalls, 2);
    expect(tokenRepository.accessToken, 'reissued');
  });

  test('응답을 받은 실패(500)는 한 번 보고된다', () async {
    final reporter = _RecordingCrashReporter();
    ApiException.reporter = reporter;
    adapter.responder = (_) async => ResponseBody.fromString('server error', 500);

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(reporter.reasons, ['[500] /diaries']);
  });

  test('기본 Content-Type에 charset=utf-8이 붙는다', () async {
    adapter.responder = (_) async => _json(200);

    await dio.get('/diaries');

    expect(
      adapter.requests.first.headers[Headers.contentTypeHeader],
      '${Headers.jsonContentType}; charset=utf-8',
    );
  });
}
