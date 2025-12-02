abstract interface class TokenRepository {
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveFcmToken(String token);

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getFcmToken();

  Future<bool> hasJwtTokens();
  Future<bool> hasFcmToken();

  Future<void> clearJwtTokens();
  Future<void> clearFcmToken();

  Future<void> clearAllSecureData();
}
