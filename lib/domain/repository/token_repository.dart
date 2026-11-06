abstract interface class TokenRepository {
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> hasJwtTokens();
  Future<void> clearJwtTokens();

  /// 설치 단위로 한 번 만들어 secure storage에 두는 UUID. 서버 기기 식별자.
  Future<String> getOrCreateDeviceId();

  Future<void> saveFcmToken(String token);
  Future<String?> getFcmToken();
  Future<void> clearFcmToken();

  /// 재설치 감지 시 secure storage 전체를 비운다.
  Future<void> clearAllSecureData();
}
