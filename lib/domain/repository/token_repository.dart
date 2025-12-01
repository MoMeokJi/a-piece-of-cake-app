abstract interface class TokenRepository {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getFcmToken();

  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> saveFcmToken(String token);

  Future<void> clearJwtTokens();
  Future<void> clearFcmToken();

  Future<bool> hasJwtTokens();
  Future<bool> hasFcmToken();
}
