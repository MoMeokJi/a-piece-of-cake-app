import 'package:cake/domain/repository/token_repository.dart';

class FakeTokenRepository implements TokenRepository {
  String? accessToken;
  String? refreshToken;
  String? fcmToken;
  String deviceId = 'device-uuid';

  int saveJwtTokensCallCount = 0;
  int clearJwtTokensCallCount = 0;

  @override
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    saveJwtTokensCallCount++;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<bool> hasJwtTokens() async =>
      accessToken != null && refreshToken != null;

  @override
  Future<void> clearJwtTokens() async {
    accessToken = null;
    refreshToken = null;
    clearJwtTokensCallCount++;
  }

  @override
  Future<String> getOrCreateDeviceId() async => deviceId;

  @override
  Future<void> saveFcmToken(String token) async => fcmToken = token;

  @override
  Future<String?> getFcmToken() async => fcmToken;

  @override
  Future<void> clearFcmToken() async => fcmToken = null;

  @override
  Future<void> clearAllSecureData() async {
    accessToken = null;
    refreshToken = null;
    fcmToken = null;
  }
}
