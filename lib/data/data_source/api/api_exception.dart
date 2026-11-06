import 'package:cake/utils/app_logger.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';

/// 서버 에러 코드 (RFC 9457 Problem Details의 `code`).
class ApiErrorCode {
  ApiErrorCode._();

  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String tokenInvalid = 'TOKEN_INVALID';
  static const String refreshInvalid = 'REFRESH_INVALID';
  static const String socialTokenInvalid = 'SOCIAL_TOKEN_INVALID';
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String diaryDailyLimitExceeded = 'DIARY_DAILY_LIMIT_EXCEEDED';
  static const String diaryNotFound = 'DIARY_NOT_FOUND';

  /// 응답 본문에서 `code`를 읽는다. 본문이 JSON 객체가 아니면 null.
  static String? fromResponse(Response? response) {
    final data = response?.data;
    if (data is Map && data['code'] is String) return data['code'] as String;
    return null;
  }

  static String? fromDioException(DioException e) => fromResponse(e.response);
}

/// 2xx이지만 기대한 형태가 아닌 응답 등, dio 예외로 잡히지 않는 API 실패.
class ApiException implements Exception {
  /// 테스트에서 NoopCrashReporter로 교체한다.
  static CrashReporter reporter = const FirebaseCrashReporter();

  final int statusCode;
  final String endpoint;
  final String responseBody;
  final String? code;

  ApiException({
    required this.statusCode,
    required this.endpoint,
    required this.responseBody,
    this.code,
  }) {
    AppLogger.error('API 에러 [$endpoint]: $statusCode ${code ?? ''}');
    AppLogger.log('Response Body: $responseBody');
    reporter.recordError(
      this,
      StackTrace.current,
      reason: '[$statusCode] $endpoint',
    );
  }

  @override
  String toString() => 'ApiException($statusCode $endpoint ${code ?? ''})';
}
