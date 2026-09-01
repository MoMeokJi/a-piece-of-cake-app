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
  late ResponseBody Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, {Map<String, List<String>>? headers}) {
  return ResponseBody.fromString(
    '{}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    },
  );
}

void main() {
  late FakeTokenRepository tokenRepository;
  late _FakeAdapter adapter;
  late Dio dio;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();

    tokenRepository = FakeTokenRepository();
    adapter = _FakeAdapter();

    BaseOptions options() => BaseOptions(baseUrl: 'https://example.test');

    final reissueDio = Dio(options())..httpClientAdapter = adapter;
    final retryDio = Dio(options())
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenRepository: tokenRepository,
          handleUnauthorized: false,
        ),
      );

    dio = Dio(options())
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenRepository: tokenRepository,
          handleUnauthorized: true,
          retryDio: retryDio,
          reissueDio: reissueDio,
        ),
      );
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('토큰이 있으면 인증 헤더를 붙인다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = 'refresh-1';
    adapter.responder = (_) => _json(200);

    await dio.get('/diaries');

    final sent = adapter.requests.single;
    expect(sent.headers['Authorization'], 'Bearer access-1');
    expect(sent.headers['Refresh-Token'], 'refresh-1');
  });

  test('needsAuth가 false면 인증 헤더를 붙이지 않는다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = 'refresh-1';
    adapter.responder = (_) => _json(200);

    await dio.post(
      '/users',
      options: Options(extra: {AuthInterceptor.needsAuthKey: false}),
    );

    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test('응답 헤더에 토큰이 오면 Bearer를 떼고 저장한다', () async {
    adapter.responder = (_) => _json(
      200,
      headers: {
        'authorization': ['Bearer new-access'],
        'refresh-token': ['new-refresh'],
      },
    );

    await dio.get('/diaries');

    expect(tokenRepository.accessToken, 'new-access');
    expect(tokenRepository.refreshToken, 'new-refresh');
  });

  test('401이면 재발급 후 한 번 재시도하고 성공 응답을 반환한다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString(
          '',
          204,
          headers: {
            'authorization': ['Bearer reissued'],
            'refresh-token': ['reissued-refresh'],
          },
        );
      }
      diariesCalls++;
      return _json(diariesCalls == 1 ? 401 : 200);
    };

    final response = await dio.get('/diaries');

    expect(response.statusCode, 200);
    expect(diariesCalls, 2);
    expect(tokenRepository.accessToken, 'reissued');
    // 재시도는 같은 RequestOptions 인스턴스를 재사용하므로 adapter.requests의
    // 첫 항목과 마지막 항목은 동일 객체이고, 헤더는 최종 값을 반영한다.
    // 이 단언은 retryDio에 AuthInterceptor가 없어 재발급된 토큰을 싣지
    // 못하는 회귀를 잡아내며, 시도별 헤더를 구분하지는 못한다.
    expect(adapter.requests.last.headers['Authorization'], 'Bearer reissued');
  });

  test('재시도한 요청도 401이면 더 재시도하지 않고 예외를 던진다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString(
          '',
          204,
          headers: {
            'authorization': ['Bearer reissued'],
            'refresh-token': ['reissued-refresh'],
          },
        );
      }
      diariesCalls++;
      return _json(401);
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    // 원요청 1 + 재시도 1. 무한 재귀가 없다는 것이 이 테스트의 요점이다.
    expect(diariesCalls, 2);
  });

  test('재발급 자체가 실패하면 재시도하지 않는다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString('', 500);
      }
      diariesCalls++;
      return _json(401);
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(diariesCalls, 1);
  });

  test('토큰이 하나라도 없으면 인증 헤더를 붙이지 않는다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = null;
    adapter.responder = (_) => _json(200);

    await dio.get('/diaries');

    final sent = adapter.requests.single;
    expect(sent.headers.containsKey('Authorization'), isFalse);
    expect(sent.headers.containsKey('Refresh-Token'), isFalse);
  });

  test('refresh-token이 없으면 응답 헤더의 토큰을 저장하지 않는다', () async {
    adapter.responder = (_) => _json(
      200,
      headers: {
        'authorization': ['Bearer new-access'],
      },
    );

    await dio.get('/diaries');

    expect(tokenRepository.saveJwtTokensCallCount, 0);
  });

  group('buildDio', () {
    test('401 후 재발급하고 한 번만 재시도한다 (3-Dio 배선 검증)', () async {
      tokenRepository.fcmToken = 'device-1';
      var diariesCalls = 0;

      adapter.responder = (options) {
        if (options.path.contains('/auth/login')) {
          return ResponseBody.fromString(
            '',
            204,
            headers: {
              'authorization': ['Bearer reissued'],
              'refresh-token': ['reissued-refresh'],
            },
          );
        }
        diariesCalls++;
        return _json(401);
      };

      final builtDio = buildDio(tokenRepository, adapter: adapter);

      await expectLater(builtDio.get('/diaries'), throwsA(isA<DioException>()));

      // retryDio가 handleUnauthorized: true로 잘못 배선되면 재시도의 401이
      // 다시 재발급+재시도를 트리거해 diariesCalls가 2를 넘어선다.
      // 이 테스트는 buildDio가 실제로 만드는 배선 자체를 검증한다.
      expect(diariesCalls, 2);
    });

    test('응답을 받은 실패(500)는 한 번 보고된다', () async {
      final reporter = _RecordingCrashReporter();
      ApiException.reporter = reporter;

      adapter.responder = (_) => ResponseBody.fromString('server error', 500);

      final builtDio = buildDio(tokenRepository, adapter: adapter);

      await expectLater(builtDio.get('/diaries'), throwsA(isA<DioException>()));

      expect(reporter.reasons, ['[500] /diaries']);
    });

    test('401이 재발급+재시도로 복구되면 보고되지 않는다', () async {
      final reporter = _RecordingCrashReporter();
      ApiException.reporter = reporter;

      tokenRepository.fcmToken = 'device-1';
      var diariesCalls = 0;

      adapter.responder = (options) {
        if (options.path.contains('/auth/login')) {
          return ResponseBody.fromString(
            '',
            204,
            headers: {
              'authorization': ['Bearer reissued'],
              'refresh-token': ['reissued-refresh'],
            },
          );
        }
        diariesCalls++;
        return _json(diariesCalls == 1 ? 401 : 200);
      };

      final builtDio = buildDio(tokenRepository, adapter: adapter);

      final response = await builtDio.get('/diaries');

      expect(response.statusCode, 200);
      expect(reporter.reasons, isEmpty);
    });

    test('401 후 FormData 요청도 재발급하고 clone된 본문으로 한 번만 재시도한다', () async {
      tokenRepository.fcmToken = 'device-1';
      var uploadCalls = 0;

      adapter.responder = (options) {
        if (options.path.contains('/auth/login')) {
          return ResponseBody.fromString(
            '',
            204,
            headers: {
              'authorization': ['Bearer reissued'],
              'refresh-token': ['reissued-refresh'],
            },
          );
        }
        uploadCalls++;
        return _json(uploadCalls == 1 ? 401 : 201);
      };

      final builtDio = buildDio(tokenRepository, adapter: adapter);

      final formData = FormData.fromMap({
        'text': 'hello',
        'images': [MultipartFile.fromString('fake-bytes', filename: 'a.jpg')],
      });

      final response = await builtDio.post('/diaries', data: formData);

      expect(response.statusCode, 201);
      // 원요청 1 + 재시도 1. clone() 없이는 두 번째 전송에서
      // FormData가 이미 소비된 스트림이라 실패한다.
      expect(uploadCalls, 2);
      expect(tokenRepository.accessToken, 'reissued');
    });
  });
}
