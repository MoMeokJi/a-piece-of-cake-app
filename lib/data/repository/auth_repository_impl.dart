import 'dart:io';

import 'package:cake/data/data_source/api/api_error_mapper.dart';
import 'package:cake/data/data_source/api/auth/auth_api.dart';
import 'package:cake/data/mapper/user_mapper.dart';
import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/model/auth_session.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/social_sign_in_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final TokenRepository _tokenRepository;
  final SocialSignInService _socialSignIn;
  final FCMService _fcmService;

  AuthRepositoryImpl({
    required AuthApi authApi,
    required TokenRepository tokenRepository,
    required SocialSignInService socialSignIn,
    required FCMService fcmService,
  }) : _authApi = authApi,
       _tokenRepository = tokenRepository,
       _socialSignIn = socialSignIn,
       _fcmService = fcmService {
    // FCM이 토큰을 바꾸면 세션이 있는 한 서버에 다시 등록한다.
    _fcmService.onTokenRefresh.listen((_) => registerFcmToken());
  }

  static String get _os => Platform.isAndroid ? 'AND' : 'IOS';

  @override
  Future<AuthSession> signIn(SocialProvider provider) async {
    final credential = await _socialSignIn.signIn(provider);
    final deviceId = await _tokenRepository.getOrCreateDeviceId();
    final fcmToken = await _currentFcmToken();

    try {
      final dto = switch (provider) {
        SocialProvider.google => await _authApi.loginWithGoogle(
          idToken: credential.idToken,
          deviceId: deviceId,
          os: _os,
          fcmToken: fcmToken,
        ),
        SocialProvider.apple => await _authApi.loginWithApple(
          identityToken: credential.idToken,
          authorizationCode: credential.authorizationCode ?? '',
          nonce: credential.nonce ?? '',
          deviceId: deviceId,
          os: _os,
          fcmToken: fcmToken,
        ),
      };

      final session = dto.toAuthSession();
      if (session == null) {
        throw const SocialSignInFailedException('로그인 응답에 토큰이 없음');
      }
      await _tokenRepository.saveJwtTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      // 서버는 nickname을 null로 준다. SDK 표시 이름을 초깃값으로 올린다.
      return AuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        accessTokenExpiresIn: session.accessTokenExpiresIn,
        refreshTokenExpiresIn: session.refreshTokenExpiresIn,
        isNewMember: session.isNewMember,
        nickname: session.nickname ?? credential.displayName,
      );
    } on DioException catch (e) {
      final mapped = mapDioException(e);
      if (mapped is NetworkUnavailableException) throw mapped;
      throw SocialSignInFailedException(
        '서버 로그인 실패 ${e.response?.statusCode ?? ''}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final deviceId = await _tokenRepository.getOrCreateDeviceId();
      await _authApi.logout(deviceId: deviceId);
    } catch (e) {
      AppLogger.error('서버 로그아웃 실패(무시): $e');
    }
    await clearSession();
  }

  @override
  Future<void> clearSession() async {
    await _tokenRepository.clearJwtTokens();
    for (final provider in SocialProvider.values) {
      await _socialSignIn.signOut(provider);
    }
  }

  @override
  Future<bool> hasSession() => _tokenRepository.hasJwtTokens();

  @override
  Future<void> registerFcmToken() async {
    try {
      if (!await _tokenRepository.hasJwtTokens()) return;
      await _fcmService.getFCMTokenAndSave();
      final fcmToken = await _tokenRepository.getFcmToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      final deviceId = await _tokenRepository.getOrCreateDeviceId();
      await _authApi.updateFcmToken(deviceId: deviceId, fcmToken: fcmToken);
    } catch (e) {
      AppLogger.error('FCM 토큰 등록 실패(무시): $e');
    }
  }

  Future<String?> _currentFcmToken() async {
    try {
      await _fcmService.getFCMTokenAndSave();
    } catch (e) {
      AppLogger.error('FCM 토큰 발급 실패(로그인은 계속): $e');
    }
    final token = await _tokenRepository.getFcmToken();
    return token == null || token.isEmpty ? null : token;
  }
}
