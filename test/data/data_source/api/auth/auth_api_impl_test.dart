import 'dart:convert';
import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth/auth_api_impl.dart';
import 'package:cake/data/data_source/api/dio_client.dart';
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
  late _FakeAdapter adapter;
  late AuthApiImpl api;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();
    adapter = _FakeAdapter();
    api = AuthApiImpl(dio: buildDio(FakeTokenRepository(), adapter: adapter));
  });

  test('Google 로그인은 인증 헤더 없이 idToken·deviceId·os·fcmToken을 보낸다', () async {
    adapter.responder = (options) {
      expect(options.path, '/auth/social/google');
      expect(options.data, {
        'idToken': 'id',
        'deviceId': 'uuid',
        'os': 'IOS',
        'fcmToken': 'fcm',
      });
      expect(options.headers.containsKey('Authorization'), isFalse);
      return _json(200, {
        'accessToken': 'a',
        'refreshToken': 'r',
        'accessTokenExpiresIn': 3600,
        'isNewMember': true,
        'nickname': null,
      });
    };

    final dto = await api.loginWithGoogle(
      idToken: 'id',
      deviceId: 'uuid',
      os: 'IOS',
      fcmToken: 'fcm',
    );

    expect(dto.accessToken, 'a');
    expect(dto.isNewMember, isTrue);
    expect(dto.nickname, isNull);
  });

  test('Apple 로그인은 identityToken·authorizationCode·nonce를 보낸다', () async {
    adapter.responder = (options) {
      expect(options.path, '/auth/social/apple');
      final data = options.data as Map;
      expect(data['identityToken'], 'idt');
      expect(data['authorizationCode'], 'code');
      expect(data['nonce'], 'nonce');
      expect(data.containsKey('fcmToken'), isFalse);
      return _json(200, {'accessToken': 'a', 'refreshToken': 'r'});
    };

    await api.loginWithApple(
      identityToken: 'idt',
      authorizationCode: 'code',
      nonce: 'nonce',
      deviceId: 'uuid',
      os: 'IOS',
    );
  });

  test('updateFcmToken은 PUT /auth/devices/fcm-token', () async {
    adapter.responder = (options) {
      expect(options.method, 'PUT');
      expect(options.path, '/auth/devices/fcm-token');
      expect(options.data, {'deviceId': 'uuid', 'fcmToken': 'fcm'});
      return ResponseBody.fromString('', 200);
    };

    await api.updateFcmToken(deviceId: 'uuid', fcmToken: 'fcm');
  });
}
