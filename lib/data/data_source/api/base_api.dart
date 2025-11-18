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
    return await _tokenRepository.getFCMToken();
  }

  // 토큰 재발급
  Future<void> reissueTokens() async {
        AppLogger.log('토큰 모두 만료됨. 재발행 api 실행');
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reissue'),
    );

    if (response.statusCode == 200) {
      await saveAllTokensFromHeader(response.headers);
    } else {
      throw ApiException(response.statusCode, 'reissueTokens 에러');
    }
  }

  // 헤더에서 두개의 토큰을 빼내서 저장. (회원가입 및 토큰 재발급 시 사용)
  Future<void> saveAllTokensFromHeader(Map<String, String> headers) async {
    final rawAccessToken = headers['authorization'];
    final refreshToken = headers['refresh-token'];

    AppLogger.log(headers['refresh-token'].toString());
    AppLogger.log(headers['authorization'].toString());


    if (rawAccessToken != null && refreshToken != null) {
      // Bearer prefix 제거
      final accessToken = rawAccessToken.replaceFirst('Bearer ', '');
      await _tokenRepository.saveJWTTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  //헤더에서 access토큰만 빼와서 저장 (서버에서 accessToken이 만료됐을때 저장. 근데 그게 언제인지 모르니까 모든 api에서 사용되어야함)
  Future<void> saveAccessTokenFromHeader(Map<String, String> headers) async {
    final rawAccessToken = headers['authorization'];

    AppLogger.log('accessToken 만료됨. 서버에서 헤더에 새로운 accessToken 발급힘');
    AppLogger.log(headers['authorization'].toString());

    if (rawAccessToken != null) {
      // Bearer prefix 제거
      final accessToken = rawAccessToken.replaceFirst('Bearer ', '');
      await _tokenRepository.saveAccessToken(accessToken);
    }
  }
}
