import 'package:cake/data/data_source/shared_preferences/storage.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepositoryImpl implements TokenRepository {
  late final FlutterSecureStorage _secureStorage;
  final Storage _storage;

  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _fcmTokenKey = 'FCM_TOKEN';

  TokenRepositoryImpl(this._storage) {
    _secureStorage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
    preferencesKeyPrefix: 'secure_storage',
  );

  IOSOptions _getIOSOptions() => const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: false,
  );

  // ========== JWT Tokens ==========

  @override
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    AppLogger.log('저장된 access 토큰: $accessToken');
    AppLogger.log('저장된 refresh 토큰: $refreshToken');
        await _storage.updateLastAccessed();
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearJwtTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<bool> hasJwtTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // ========== FCM Token ==========

  @override
  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: _fcmTokenKey, value: token);
    AppLogger.log('저장된 FCM 토큰: $token');
  }

  @override
  Future<String?> getFcmToken() async {
    return _secureStorage.read(key: _fcmTokenKey);
  }

  @override
  Future<void> clearFcmToken() async {
    await _secureStorage.delete(key: _fcmTokenKey);
  }

  @override
  Future<bool> hasFcmToken() async {
    final fcmToken = await getFcmToken();
    return fcmToken != null;
  }

  // ========== Clear All ==========

  @override
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
    AppLogger.log('모든 Secure Storage 데이터 삭제됨 (재설치 감지)');
  }
}
