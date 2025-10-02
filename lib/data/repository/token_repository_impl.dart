import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepositoryImpl implements TokenRepository {
  late final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _fcmTokenKey = 'FCM_TOKEN';

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    // 앱 삭제 시 데이터도 삭제되도록 설정
    resetOnError: true,
    // SharedPreferences 초기화 실패 시 재설정
    preferencesKeyPrefix: 'secure_storage',
  );

  IOSOptions _getIOSOptions() => const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: false,
  );

  TokenRepositoryImpl() {
    _storage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    AppLogger.log('저장된 엑세스토큰 $accessToken');
    AppLogger.log('저장된 리프레시토큰 $refreshToken');
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<String?> getFCMToken() async {
    return _storage.read(key: _fcmTokenKey);
  }

  @override
  Future<void> saveFCMToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
    AppLogger.log('저장된 FCM 토큰: $token');
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<void> clearFCMToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  @override
  Future<bool> hasFCMToken() async {
    final fcmToken = await getFCMToken();
    return fcmToken != null;
  }
}
