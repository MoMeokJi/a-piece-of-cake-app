import 'package:cake/domain/enum/social_provider.dart';

/// 소셜 SDK가 돌려준 자격 증명. 서버 로그인 요청의 재료다.
class SocialCredential {
  final SocialProvider provider;

  /// Google: idToken, Apple: identityToken
  final String idToken;

  /// Apple 전용. 서버가 탈퇴(revoke)에 쓴다.
  final String? authorizationCode;

  /// Apple 전용. 요청에 실어 보낸 raw nonce.
  final String? nonce;

  /// SDK가 준 표시 이름. Apple은 첫 인증 때만 준다. 닉네임 초깃값으로 쓴다.
  final String? displayName;

  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.authorizationCode,
    this.nonce,
    this.displayName,
  });
}
