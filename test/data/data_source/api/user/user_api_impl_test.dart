import 'dart:convert';
import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/dio_client.dart';
import 'package:cake/data/data_source/api/user/user_api_impl.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_token_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  late ResponseBody Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  late FakeTokenRepository tokenRepository;
  late _FakeAdapter adapter;
  late UserApiImpl userApi;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();
    tokenRepository = FakeTokenRepository()
      ..accessToken = 'access-1'
      ..refreshToken = 'refresh-1';
    adapter = _FakeAdapter();
    userApi = UserApiImpl(dio: buildDio(tokenRepository, adapter: adapter));
  });

  test('fetchMe는 provider와 notificationEnabled를 읽는다', () async {
    adapter.responder = (_) => _json(200, {
      'memberId': 'm-1',
      'nickname': '서윤',
      'provider': 'GOOGLE',
      'notificationEnabled': true,
    });

    final dto = await userApi.fetchMe();

    expect(dto.memberId, 'm-1');
    expect(dto.provider, 'GOOGLE');
    expect(dto.notificationEnabled, isTrue);
    expect(adapter.requests.single.headers['Authorization'], 'Bearer access-1');
  });

  test('updateNickname은 PUT /users/me/nickname에 {nickname}을 보낸다', () async {
    adapter.responder = (options) {
      expect(options.method, 'PUT');
      expect(options.path, '/users/me/nickname');
      expect(options.data, {'nickname': '케이크러버'});
      return _json(200, {'nickname': '케이크러버'});
    };

    expect(await userApi.updateNickname('케이크러버'), '케이크러버');
  });

  test('updateNotification은 {enabled}를 보내고 서버 값을 돌려준다', () async {
    adapter.responder = (options) {
      expect(options.data, {'enabled': true});
      return _json(200, {'notificationEnabled': true});
    };

    expect(await userApi.updateNotification(true), isTrue);
  });

  test('deleteUser는 200이면 정상 반환하고 토큰은 건드리지 않는다', () async {
    adapter.responder = (_) => ResponseBody.fromString('', 200);

    await expectLater(userApi.deleteUser(), completes);

    // 세션 정리는 리포지토리 몫이다.
    expect(tokenRepository.accessToken, 'access-1');
  });

  test('deleteUser는 404(이미 삭제됨)를 성공으로 본다', () async {
    adapter.responder = (_) => ResponseBody.fromString('', 404);

    await expectLater(userApi.deleteUser(), completes);
  });

  test('deleteUser가 401 TOKEN_EXPIRED를 받으면 재발급 후 재시도한다', () async {
    var deleteCalls = 0;
    adapter.responder = (options) {
      if (options.path.contains('/auth/refresh')) {
        return _json(200, {'accessToken': 'reissued', 'refreshToken': 'r2'});
      }
      deleteCalls++;
      return deleteCalls == 1
          ? _json(401, {'code': 'TOKEN_EXPIRED'})
          : ResponseBody.fromString('', 200);
    };

    await userApi.deleteUser();

    expect(deleteCalls, 2);
    expect(tokenRepository.accessToken, 'reissued');
  });
}
