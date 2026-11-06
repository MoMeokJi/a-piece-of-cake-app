/// 소셜 로그인·토큰 재발급 응답.
class AuthSession {
  final String accessToken;
  final String refreshToken;

  /// 서버가 준 만료값(초 단위로 가정). 만료 판단은 서버 401에 맡기고 참고용으로만 둔다.
  final int? accessTokenExpiresIn;
  final int? refreshTokenExpiresIn;
  final bool isNewMember;

  /// 서버는 null을 준다. 앱이 SDK 이름으로 미리 채운다.
  final String? nickname;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresIn,
    this.refreshTokenExpiresIn,
    this.isNewMember = false,
    this.nickname,
  });
}
