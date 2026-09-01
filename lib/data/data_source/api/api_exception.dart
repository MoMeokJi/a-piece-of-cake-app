import 'package:cake/utils/app_logger.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  /// 테스트에서 NoopCrashReporter로 교체한다.
  static CrashReporter reporter = const FirebaseCrashReporter();

  final int statusCode;
  final String endpoint;
  final String responseBody;

  ApiException({
    required this.statusCode,
    required this.endpoint,
    required this.responseBody,
  }) {
    AppLogger.error('API 에러 [$endpoint]: $statusCode');
    AppLogger.log('Response Body: $responseBody');
    reporter.recordError(
      this,
      StackTrace.current,
      reason: '[$statusCode] $endpoint',
    );
  }

  factory ApiException.fromResponse(http.Response response, String endpoint) {
    return ApiException(
      statusCode: response.statusCode,
      endpoint: endpoint,
      responseBody: response.body,
    );
  }

  static Future<ApiException> fromStreamedResponse(
    http.StreamedResponse streamedResponse,
    String endpoint,
  ) async {
    final response = await http.Response.fromStream(streamedResponse);
    return ApiException.fromResponse(response, endpoint);
  }
}