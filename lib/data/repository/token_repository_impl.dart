import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class TokenRepositoryImpl implements TokenRepository {
  late final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _fcmTokenKey = 'FCM_TOKEN';
  static const String _deviceIdKey = 'DEVICE_ID';

  TokenRepositoryImpl() {
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
    // 재발급이 겹쳐도 access/refresh 쌍이 뒤섞이지 않게 순서대로 쓴다.
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    AppLogger.log('JWT 토큰 저장됨');
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  @override
  Future<void> clearJwtTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<bool> hasJwtTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // ========== Device ID ==========

  @override
  Future<String> getOrCreateDeviceId() async {
    final existing = await _secureStorage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = const Uuid().v4();
    await _secureStorage.write(key: _deviceIdKey, value: created);
    AppLogger.log('deviceId 생성: $created');
    return created;
  }

  // ========== FCM Token ==========

  @override
  Future<void> saveFcmToken(String token) async {
    await _secureStorage.write(key: _fcmTokenKey, value: token);
  }

  @override
  Future<String?> getFcmToken() => _secureStorage.read(key: _fcmTokenKey);

  @override
  Future<void> clearFcmToken() => _secureStorage.delete(key: _fcmTokenKey);

  // ========== Clear All ==========

  @override
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
    AppLogger.log('모든 Secure Storage 데이터 삭제됨');
  }
}
