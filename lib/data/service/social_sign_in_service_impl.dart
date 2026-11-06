import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cake/config/auth_config.dart';
import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/model/social_credential.dart';
import 'package:cake/domain/service/social_sign_in_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialSignInServiceImpl implements SocialSignInService {
  Future<void>? _googleInit;

  /// google_sign_in 7.x는 initialize를 정확히 한 번 호출해야 한다.
  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= GoogleSignIn.instance.initialize(
      clientId: Platform.isIOS && AuthConfig.googleIosClientId.isNotEmpty
          ? AuthConfig.googleIosClientId
          : null,
      // 서버가 idToken의 audience로 검증하는 웹 클라이언트 ID.
      serverClientId: AuthConfig.hasGoogleServerClientId
          ? AuthConfig.googleServerClientId
          : null,
    );
  }

  @override
  Future<SocialCredential> signIn(SocialProvider provider) => switch (provider) {
    SocialProvider.google => _signInWithGoogle(),
    SocialProvider.apple => _signInWithApple(),
  };

  Future<SocialCredential> _signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialSignInFailedException('Google idToken 없음');
      }
      return SocialCredential(
        provider: SocialProvider.google,
        idToken: idToken,
        displayName: account.displayName,
      );
    } on GoogleSignInException catch (e) {
      AppLogger.error('Google 로그인 실패: ${e.code} ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const SocialSignInCancelledException();
      }
      throw SocialSignInFailedException('Google: ${e.code.name}');
    }
  }

  Future<SocialCredential> _signInWithApple() async {
    final rawNonce = _generateNonce();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Apple은 해시된 nonce를 identityToken에 싣는다. 서버는 raw nonce를 받아
        // sha256으로 비교한다.
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const SocialSignInFailedException('Apple identityToken 없음');
      }
      final name = [
        credential.familyName,
        credential.givenName,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join();
      return SocialCredential(
        provider: SocialProvider.apple,
        idToken: identityToken,
        authorizationCode: credential.authorizationCode,
        nonce: rawNonce,
        displayName: name.isEmpty ? null : name,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.error('Apple 로그인 실패: ${e.code} ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      throw SocialSignInFailedException('Apple: ${e.code.name}');
    }
  }

  @override
  Future<void> signOut(SocialProvider provider) async {
    if (provider != SocialProvider.google) return; // Apple은 SDK 세션이 없다
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      AppLogger.error('Google 로그아웃 실패(무시): $e');
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
