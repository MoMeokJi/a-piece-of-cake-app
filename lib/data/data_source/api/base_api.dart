import 'dart:convert';

import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:http/http.dart' as http;

abstract class BaseApi {
  final TokenRepository _tokenRepository;
  BaseApi(this._tokenRepository);

  // 헤더 설정.
  Future<Map<String, String>> getHeaders({bool needsAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (needsAuth) {
      final accessToken = await _tokenRepository.getAccessToken();
      final refreshToken = await _tokenRepository.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
        headers['Refresh-Token'] = refreshToken;
      }
    }
    return headers;
  }

  // fcmToken 꺼내기
  Future<String?> getFCMToken() async {
    return await _tokenRepository.getFcmToken();
  }

  // 토큰 재발급
  Future<void> reissueTokens() async {
    AppLogger.log('토큰 모두 만료됨. 재발행 api 실행');
    final deviceId = await _tokenRepository.getFcmToken();
    AppLogger.log('deviceId 확인 : $deviceId');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId}),
    );

    if (response.statusCode == 204) {
      await saveAllTokensFromHeader(response.headers);
  } else {
  throw ApiException.fromResponse(response, 'reissueTokens');
}
  }

  // 헤더에서 토큰을 빼내서 저장.
  Future<void> saveAllTokensFromHeader(Map<String, String> headers) async {
    final rawAccessToken = headers['authorization'];
    final refreshToken = headers['refresh-token'];

    AppLogger.log(headers['refresh-token'].toString());
    AppLogger.log(headers['authorization'].toString());

    if (rawAccessToken != null && refreshToken != null) {
      // Bearer prefix 제거
      final accessToken = rawAccessToken.replaceFirst('Bearer ', '');
      await _tokenRepository.saveJwtTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  // 탈퇴 시 jwt 토큰 정리
  Future<void> deleteJwtTokens() async {
  await _tokenRepository.clearJwtTokens();
}
}
