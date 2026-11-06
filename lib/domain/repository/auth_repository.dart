import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/model/auth_session.dart';

abstract interface class AuthRepository {
  /// 소셜 SDK 인증 → 서버 로그인 → 토큰 저장까지.
  /// 취소는 [SocialSignInCancelledException], 실패는 [SocialSignInFailedException].
  Future<AuthSession> signIn(SocialProvider provider);

  /// 서버 로그아웃 요청 후 로컬 토큰·소셜 세션을 지운다. 서버 실패는 삼킨다.
  Future<void> logout();

  /// 로컬 토큰·소셜 세션만 지운다 (세션 만료, 탈퇴 뒤).
  Future<void> clearSession();

  Future<bool> hasSession();

  /// 현재 FCM 토큰을 서버 기기 정보에 등록한다. 실패해도 예외를 던지지 않는다.
  Future<void> registerFcmToken();
}
