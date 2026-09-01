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
Dio buildDio(TokenRepository tokenRepository) {
  final reissueDio = Dio(_baseOptions());

  final retryDio = Dio(_baseOptions())
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: false,
      ),
    );

  return Dio(_baseOptions())
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: true,
        retryDio: retryDio,
        reissueDio: reissueDio,
      ),
    );
}
