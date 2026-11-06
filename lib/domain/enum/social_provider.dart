enum SocialProvider {
  google,
  apple;

  /// 서버가 쓰는 대문자 값 (GOOGLE · APPLE)
  String get serverValue => switch (this) {
    SocialProvider.google => 'GOOGLE',
    SocialProvider.apple => 'APPLE',
  };

  /// 마이페이지 "Google 계정으로 로그인 중"에 쓰는 표시 이름
  String get displayName => switch (this) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
  };

  static SocialProvider? fromServer(String? value) => switch (value?.toUpperCase()) {
    'GOOGLE' => SocialProvider.google,
    'APPLE' => SocialProvider.apple,
    _ => null,
  };
}
