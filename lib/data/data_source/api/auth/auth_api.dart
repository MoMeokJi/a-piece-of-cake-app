import 'package:cake/data/dto/auth_token_response_dto.dart';

abstract interface class AuthApi {
  Future<AuthTokenResponseDto> loginWithGoogle({
    required String idToken,
    required String deviceId,
    required String os,
    String? fcmToken,
  });

  Future<AuthTokenResponseDto> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    required String nonce,
    required String deviceId,
    required String os,
    String? fcmToken,
  });

  Future<void> logout({required String deviceId});

  Future<void> updateFcmToken({
    required String deviceId,
    required String fcmToken,
  });
}
