import 'dart:convert';
import 'dart:io';

import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/base_api.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:http/http.dart' as http;

class UserApiImpl extends BaseApi implements UserApi {
  UserApiImpl(super._tokenRepository);

  @override
  Future<void> createUser({required String preference}) async {
    final fcmToken = await getFCMToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      body: jsonEncode({
        'deviceId': fcmToken,
        'preference': preference,
        'mobileOS': Platform.isAndroid ? 'AND' : 'IOS',
      }),
    );

    // 회원가입은 401이 있을수없음.
    if (response.statusCode == 204) {
      await saveAllTokensFromHeader(response.headers);
      return;
    } else {
      throw ApiException(response.statusCode, 'createUser 실패');
    }
  }

  @override
  Future<void> deleteUser() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      await saveAccessTokenFromHeader(response.headers);
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return deleteUser();
    } else {
      throw ApiException(response.statusCode, 'deleteUser 실패');
    }
  }
}
