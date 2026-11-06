import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/data_source/api/error_reporting_interceptor.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:dio/dio.dart';

// dio는 charset을 자동으로 붙이지 않으므로 명시한다. 서버는 utf-8 선언을 기대해 왔다.
BaseOptions _baseOptions() => BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 60),
  headers: {
    Headers.contentTypeHeader: '${Headers.jsonContentType}; charset=utf-8',
  },
);

/// 앱이 쓰는 Dio 인스턴스를 만든다.
///
/// 401 처리를 갖지 않는 retryDio / refreshDio를 따로 두어
/// 재시도와 재발급이 다시 401 처리를 타지 않도록 한다.
///
/// [adapter]는 테스트 전용이다. 세 인스턴스 모두에 적용된다.
/// [onSessionExpired]는 토큰이 지워진 뒤 호출된다 (로그인 화면 이동은 호출부 몫).
Dio buildDio(
  TokenRepository tokenRepository, {
  HttpClientAdapter? adapter,
  void Function()? onSessionExpired,
}) {
  Dio create() {
    final dio = Dio(_baseOptions());
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }

  final refreshDio = create();

  final retryDio = create()
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: false,
      ),
    );

  return create()
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: true,
        retryDio: retryDio,
        refreshDio: refreshDio,
        onSessionExpired: onSessionExpired,
      ),
    )
    // AuthInterceptor 다음에 붙여야 한다: 401이 재발급+재시도로 복구되면
    // handler.resolve()로 끝나 이 인터셉터의 onError까지 오지 않는다.
    ..interceptors.add(ErrorReportingInterceptor());
}
