import 'package:cake/domain/exception/app_exception.dart';

/// 도메인 예외를 토스트 문구로 바꾼다. 피그마 "토스트 예시" 문구를 따른다.
class AppErrorMessages {
  AppErrorMessages._();

  static const String network = '인터넷 연결을 확인해 주세요.';
  static const String generic = '문제가 생겼어요. 잠시 후 다시 시도해 주세요.';
  static const String loginCancelled = '로그인이 취소됐어요. 다시 시도해 주세요.';
  static const String loginFailed = '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
  static const String generateFailed = '일기를 만들지 못했어요.';
  static const String saveFailed = '일기를 저장하지 못했어요.';
  static const String editFailed = '수정하지 못했어요. 잠시 후 다시 시도해 주세요.';
  static const String deleteFailed = '삭제하지 못했어요. 잠시 후 다시 시도해 주세요.';
  static const String sessionExpired = '로그인이 만료됐어요. 다시 로그인해 주세요.';

  static String of(Object error, {String fallback = generic}) =>
      switch (error) {
        NetworkUnavailableException() => network,
        SessionExpiredException() => sessionExpired,
        SocialSignInCancelledException() => loginCancelled,
        SocialSignInFailedException() => loginFailed,
        _ => fallback,
      };
}
