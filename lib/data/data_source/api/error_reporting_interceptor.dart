import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:dio/dio.dart';

/// 응답을 받은 실패만 크래시 리포터에 남기고 그대로 통과시킨다.
/// dio 전환 이전 ApiException 생성자가 하던 역할을 대신한다.
class ErrorReportingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      ApiException.reporter.recordError(
        err,
        err.stackTrace,
        reason: '[${response.statusCode}] ${err.requestOptions.path}',
      );
    }
    handler.next(err);
  }
}
