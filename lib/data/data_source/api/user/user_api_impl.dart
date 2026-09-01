import 'dart:io';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class UserApiImpl implements UserApi {
  final Dio _dio;
  final TokenRepository _tokenRepository;

  UserApiImpl({required Dio dio, required TokenRepository tokenRepository})
    : _dio = dio,
      _tokenRepository = tokenRepository;

  @override
  Future<void> createUser({required String preference}) async {
    final fcmToken = await _tokenRepository.getFcmToken();

    // 회원가입은 아직 토큰이 없으므로 인증 헤더를 붙이지 않는다.
    final response = await _dio.post(
      '/users',
      data: {
        'deviceId': fcmToken,
        'preference': preference,
        'mobileOS': Platform.isAndroid ? 'AND' : 'IOS',
      },
      options: Options(
        extra: {AuthInterceptor.needsAuthKey: false},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 204) {
      AppLogger.log('가입된 deviceId : $fcmToken');
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'createUser',
      responseBody: response.data?.toString() ?? '',
    );
  }

  @override
  Future<void> deleteUser() async {
    final response = await _dio.delete(
      '/users',
      options: Options(
        // 401은 통과시키지 않는다. DioException으로 떨어져야
        // 인터셉터가 재발급 후 재시도할 수 있다.
        validateStatus: (status) => status == 204 || status == 404,
      ),
    );

    if (response.statusCode == 204) {
      await _tokenRepository.clearJwtTokens();
      return;
    }

    if (response.statusCode == 404) {
      AppLogger.log('deleteUser 404 이미 삭제된 유저.');
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'deleteUser',
      responseBody: response.data?.toString() ?? '',
    );
  }
}
