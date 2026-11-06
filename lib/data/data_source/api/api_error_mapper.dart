import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:dio/dio.dart';

/// dio 예외를 화면이 구분해야 하는 도메인 예외로 바꾼다. 해당 없으면 null.
AppException? mapDioException(DioException e) {
  final response = e.response;
  if (response == null) {
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const NetworkUnavailableException(),
      _ => null,
    };
  }

  final code = ApiErrorCode.fromResponse(response);
  return switch ((response.statusCode, code)) {
    (429, _) ||
    (_, ApiErrorCode.diaryDailyLimitExceeded) =>
      const DiaryDailyLimitExceededException(),
    (_, ApiErrorCode.validationFailed) => const ValidationFailedException(),
    (_, ApiErrorCode.diaryNotFound) => const DiaryNotFoundException(),
    (_, ApiErrorCode.socialTokenInvalid) => const SocialSignInFailedException(
      '서버가 소셜 토큰을 거부함',
    ),
    (401, ApiErrorCode.tokenInvalid) ||
    (401, ApiErrorCode.refreshInvalid) => const SessionExpiredException(),
    _ => null,
  };
}

/// 리포지토리에서 `on DioException catch (e) { throw mapOrRethrow(e); }` 로 쓴다.
Object mapOrRethrow(DioException e) => mapDioException(e) ?? e;
