import 'package:cake/data/data_source/api/auth/auth_api.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/dto/auth_token_response_dto.dart';
import 'package:dio/dio.dart';

class AuthApiImpl implements AuthApi {
  final Dio _dio;

  AuthApiImpl({required Dio dio}) : _dio = dio;

  // 로그인은 아직 토큰이 없으므로 인증 헤더를 붙이지 않고, 401도 재발급 대상이 아니다.
  static final Options _noAuth = Options(
    extra: {AuthInterceptor.needsAuthKey: false},
  );

  @override
  Future<AuthTokenResponseDto> loginWithGoogle({
    required String idToken,
    required String deviceId,
    required String os,
    String? fcmToken,
  }) async {
    final response = await _dio.post(
      '/auth/social/google',
      data: {
        'idToken': idToken,
        'deviceId': deviceId,
        'os': os,
        if (fcmToken != null) 'fcmToken': fcmToken,
      },
      options: _noAuth,
    );
    return AuthTokenResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenResponseDto> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    required String nonce,
    required String deviceId,
    required String os,
    String? fcmToken,
  }) async {
    final response = await _dio.post(
      '/auth/social/apple',
      data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'nonce': nonce,
        'deviceId': deviceId,
        'os': os,
        if (fcmToken != null) 'fcmToken': fcmToken,
      },
      options: _noAuth,
    );
    return AuthTokenResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String deviceId}) async {
    await _dio.post('/auth/logout', data: {'deviceId': deviceId});
  }

  @override
  Future<void> updateFcmToken({
    required String deviceId,
    required String fcmToken,
  }) async {
    await _dio.put(
      '/auth/devices/fcm-token',
      data: {'deviceId': deviceId, 'fcmToken': fcmToken},
    );
  }
}
