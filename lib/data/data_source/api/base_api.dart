import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/repository/token_repository.dart';
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

  // 응답 헤더에서 토큰 저장
  Future<void> saveTokensFromHeader(Map<String, String> headers) async {
    final rawAccessToken = headers['authorization'];
    final refreshToken = headers['refresh-token'];

    if (rawAccessToken != null && refreshToken != null) {
      // Bearer prefix 제거
      final accessToken = rawAccessToken.replaceFirst('Bearer ', '');
      await _tokenRepository.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  // fcmToken 꺼내기
  Future<String?> getFCMToken() async {
    return await _tokenRepository.getFCMToken();
  }

  // 토큰 재발급
  Future<void> reissueTokens() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reissue'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      await saveTokensFromHeader(response.headers);
    } else {
      throw ApiException(response.statusCode, 'reissueTokens 에러');
    }
  }
}
