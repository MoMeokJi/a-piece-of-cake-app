import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';

class MockUserApi implements UserApi {
  final TokenRepository _tokenRepository;

  MockUserApi(this._tokenRepository);

  @override
  Future<void> createUser({required String preference}) async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    // Mock 토큰 생성
    final mockAccessToken =
        'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final mockRefreshToken =
        'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

    // 토큰 저장
    await _tokenRepository.saveJWTTokens(
      accessToken: mockAccessToken,
      refreshToken: mockRefreshToken,
    );

    AppLogger.log('Mock createUser 성공: preference=$preference');
  }

  @override
  Future<bool> deleteUser() async {
    await Future.delayed(const Duration(seconds: 1));
    AppLogger.log('Mock deleteUser 성공');

    // 토큰 삭제
    return true;
  }
}
