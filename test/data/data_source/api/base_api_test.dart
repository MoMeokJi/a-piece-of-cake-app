import 'package:cake/data/data_source/api/base_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_token_repository.dart';

// BaseApi는 abstract이므로 테스트용 최소 구현으로 감싼다.
class _TestApi extends BaseApi {
  _TestApi(super._tokenRepository);
}

void main() {
  late FakeTokenRepository tokenRepository;
  late _TestApi api;

  setUp(() {
    tokenRepository = FakeTokenRepository();
    api = _TestApi(tokenRepository);
  });

  group('getHeaders', () {
    test('토큰이 모두 있으면 Authorization과 Refresh-Token을 붙인다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';

      final headers = await api.getHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer access-1');
      expect(headers['Refresh-Token'], 'refresh-1');
    });

    test('needsAuth가 false면 인증 헤더를 붙이지 않는다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';

      final headers = await api.getHeaders(needsAuth: false);

      expect(headers.containsKey('Authorization'), isFalse);
      expect(headers.containsKey('Refresh-Token'), isFalse);
    });

    test('토큰이 하나라도 없으면 인증 헤더를 붙이지 않는다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = null;

      final headers = await api.getHeaders();

      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('saveAllTokensFromHeader', () {
    test('Bearer 접두사를 떼고 두 토큰을 저장한다', () async {
      await api.saveAllTokensFromHeader({
        'authorization': 'Bearer new-access',
        'refresh-token': 'new-refresh',
      });

      expect(tokenRepository.accessToken, 'new-access');
      expect(tokenRepository.refreshToken, 'new-refresh');
      expect(tokenRepository.saveJwtTokensCallCount, 1);
    });

    test('refresh-token이 없으면 아무것도 저장하지 않는다', () async {
      await api.saveAllTokensFromHeader({
        'authorization': 'Bearer new-access',
      });

      expect(tokenRepository.saveJwtTokensCallCount, 0);
      expect(tokenRepository.accessToken, isNull);
    });
  });
}
