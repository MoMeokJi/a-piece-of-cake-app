import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:dio/dio.dart';

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  headers: {Headers.contentTypeHeader: Headers.jsonContentType},
);

/// 앱이 쓰는 Dio 인스턴스를 만든다.
///
/// 401 처리를 갖지 않는 retryDio / reissueDio를 따로 두어
/// 재시도와 재발급이 다시 401 처리를 타지 않도록 한다.
///
/// [adapter]는 테스트 전용이다. 세 인스턴스 모두에 적용되므로
/// 이 배선 자체를 실제 네트워크 없이 검증할 수 있다.
Dio buildDio(TokenRepository tokenRepository, {HttpClientAdapter? adapter}) {
  Dio create() {
    final dio = Dio(_baseOptions());
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }

  final reissueDio = create();

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
        reissueDio: reissueDio,
      ),
    );
}
