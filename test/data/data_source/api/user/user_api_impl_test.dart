import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/dio_client.dart';
import 'package:cake/data/data_source/api/user/user_api_impl.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_token_repository.dart';

/// auth_interceptor_test.dart의 _FakeAdapter와 동일한 패턴.
/// UserApiImpl은 buildDio가 실제로 배선한 AuthInterceptor(401 재발급 +
/// 재시도, 응답 헤더의 토큰 저장)를 함께 거치므로, deleteUser의 401 케이스는
/// dio_client.dart의 buildDio를 그대로 통과시켜야 검증할 수 있다.
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

ResponseBody _empty(int statusCode, {Map<String, List<String>>? headers}) {
  return ResponseBody.fromString('', statusCode, headers: headers ?? {});
}

void main() {
  late FakeTokenRepository tokenRepository;
  late _FakeAdapter adapter;
  late UserApiImpl userApi;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();

    tokenRepository = FakeTokenRepository();
    adapter = _FakeAdapter();

    final dio = buildDio(tokenRepository, adapter: adapter);
    userApi = UserApiImpl(dio: dio, tokenRepository: tokenRepository);
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('deleteUser가 204를 받으면 토큰을 지운다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = 'refresh-1';
    adapter.responder = (_) => _empty(204);

    await userApi.deleteUser();

    expect(tokenRepository.accessToken, isNull);
    expect(tokenRepository.refreshToken, isNull);
  });

  test(
    'deleteUser가 404를 받으면 예외 없이 반환하고 토큰을 지우지 않는다',
    () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';
      adapter.responder = (_) => _empty(404);

      await expectLater(userApi.deleteUser(), completes);

      expect(tokenRepository.accessToken, 'access-1');
      expect(tokenRepository.refreshToken, 'refresh-1');
    },
  );

  test(
    'deleteUser가 401을 받으면 재발급 후 재시도해 204로 토큰을 지운다',
    () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';
      tokenRepository.fcmToken = 'device-1';
      var deleteCalls = 0;

      adapter.responder = (options) {
        if (options.path.contains('/auth/login')) {
          return _empty(
            204,
            headers: {
              'authorization': ['Bearer reissued'],
              'refresh-token': ['reissued-refresh'],
            },
          );
        }
        deleteCalls++;
        // deleteUser의 validateStatus는 204/404만 통과시키므로, 그 외
        // 상태 코드는 여기서 DioException으로 던져져 AuthInterceptor.onError가
        // 401을 재발급+재시도로 처리한다.
        return _empty(deleteCalls == 1 ? 401 : 204);
      };

      await userApi.deleteUser();

      expect(deleteCalls, 2);
      // 재발급으로 잠깐 'reissued'가 저장됐다가, 최종 204 응답을 받은
      // deleteUser가 clearJwtTokens()를 호출해 다시 비운다.
      expect(tokenRepository.accessToken, isNull);
      expect(tokenRepository.refreshToken, isNull);
    },
  );

  test('createUser가 204를 받으면 응답 헤더에 실린 토큰을 저장한다', () async {
    tokenRepository.fcmToken = 'device-1';
    adapter.responder = (_) => _empty(
      204,
      headers: {
        'authorization': ['Bearer new-access'],
        'refresh-token': ['new-refresh'],
      },
    );

    await expectLater(userApi.createUser(preference: 'quiet'), completes);

    expect(tokenRepository.accessToken, 'new-access');
    expect(tokenRepository.refreshToken, 'new-refresh');
  });
}
