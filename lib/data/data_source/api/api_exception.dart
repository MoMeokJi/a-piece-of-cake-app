import 'package:cake/utils/app_logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
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
    FirebaseCrashlytics.instance.recordError(
      this,
      StackTrace.current,
      fatal: false,
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