/// 화면이 구분해서 처리해야 하는 실패만 도메인 예외로 올린다.
/// 그 밖의 실패는 data 레이어의 예외가 그대로 올라오고, 화면은 일반 오류로 다룬다.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// 사용자가 소셜 로그인 창을 닫았다. 오류 토스트가 아니라 안내 토스트.
class SocialSignInCancelledException extends AppException {
  const SocialSignInCancelledException() : super('소셜 로그인이 취소됨');
}

/// 소셜 로그인 자체(SDK·서버 검증)가 실패했다.
class SocialSignInFailedException extends AppException {
  const SocialSignInFailedException([super.message = '소셜 로그인 실패']);
}

/// 서버 429 DIARY_DAILY_LIMIT_EXCEEDED
class DiaryDailyLimitExceededException extends AppException {
  const DiaryDailyLimitExceededException() : super('오늘 작성 한도 초과');
}

/// 서버 400 VALIDATION_FAILED (닉네임 형식 등)
class ValidationFailedException extends AppException {
  const ValidationFailedException([super.message = '입력값 검증 실패']);
}

/// 네트워크 단절·타임아웃. 응답을 받지 못했다.
class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException() : super('네트워크 연결 없음');
}

/// 세션이 끝났다(TOKEN_INVALID, REFRESH_INVALID). 로그인 화면으로 보낸다.
class SessionExpiredException extends AppException {
  const SessionExpiredException() : super('세션 만료');
}

/// 서버 404 DIARY_NOT_FOUND
class DiaryNotFoundException extends AppException {
  const DiaryNotFoundException() : super('일기를 찾을 수 없음');
}
