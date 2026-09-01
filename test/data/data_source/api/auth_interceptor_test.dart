import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_token_repository.dart';

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

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
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
}
