abstract interface class TokenRepository {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getFCMToken();

  Future<void> saveJWTTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveAccessToken(String token);

  Future<void> saveRefreshToken(String token);

  Future<void> saveFCMToken(String token);

  Future<void> clearTokens();
  Future<void> clearFCMToken();

  Future<bool> hasTokens();
  Future<bool> hasFCMToken();
}
