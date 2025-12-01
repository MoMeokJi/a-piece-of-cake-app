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
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    AppLogger.log('저장된 access 토큰: $accessToken');
    AppLogger.log('저장된 refresh 토큰: $refreshToken');
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    AppLogger.log('저장된 access 토큰: $token');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    AppLogger.log('저장된 refresh 토큰: $token');
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
  Future<String?> getFcmToken() async {
    return _storage.read(key: _fcmTokenKey);
  }

  @override
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
    AppLogger.log('저장된 FCM 토큰: $token');
  }

  @override
  Future<void> clearJwtTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<void> clearFcmToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }

  @override
  Future<bool> hasJwtTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  @override
  Future<bool> hasFcmToken() async {
    final fcmToken = await getFcmToken();
    return fcmToken != null;
  }
}
