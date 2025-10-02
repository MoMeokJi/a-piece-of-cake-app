abstract interface class TokenRepository {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getFCMToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveFCMToken(String token);

  Future<void> clearTokens();
  Future<void> clearFCMToken();

  Future<bool> hasTokens();
  Future<bool> hasFCMToken();
}
