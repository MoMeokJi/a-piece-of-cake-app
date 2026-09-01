import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/data_source/api/error_reporting_interceptor.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:dio/dio.dart';

// package:http의 Request.body setter는 Content-Type에 charset이 없으면
// 항상 charset=utf-8을 덧붙였다 (dart:http Request._body). 그 결과 이 앱이
// 보낸 모든 JSON 요청은 `application/json; charset=utf-8`로 나갔다. dio는
// charset을 자동으로 붙이지 않으므로 여기서 명시한다. 바이트 자체는 항상
// UTF-8이었으니 선언만 복원하는 것이다.
// Transformer.isJsonMimeType은 MediaType을 파싱해 mimeType만 보므로
// charset 파라미터가 붙어도 JSON 인코딩은 그대로 동작한다.
BaseOptions _baseOptions() => BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  headers: {
    Headers.contentTypeHeader: '${Headers.jsonContentType}; charset=utf-8',
  },
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
    )
    // AuthInterceptor 다음에 붙여야 한다: 401이 재발급+재시도로 복구되면
    // handler.resolve()로 끝나 이 인터셉터의 onError까지 오지 않는다.
    // 복구되지 않은 실패만 여기서 보고된다.
    ..interceptors.add(ErrorReportingInterceptor());
}
