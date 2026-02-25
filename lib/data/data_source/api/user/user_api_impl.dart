import 'dart:convert';
import 'dart:io';

import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/base_api.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class UserApiImpl extends BaseApi implements UserApi {
  UserApiImpl(super._tokenRepository);

  @override
  Future<void> createUser({required String preference}) async {
    final fcmToken = await getFCMToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deviceId': fcmToken,
        'preference': preference,
        'mobileOS': Platform.isAndroid ? 'AND' : 'IOS',
      }),
    );

    // 회원가입은 401이 있을수없음.
    if (response.statusCode == 204) {
      await saveAllTokensFromHeader(response.headers);
      AppLogger.log('가입된 deviceId : $fcmToken');
      return;
    } else {
      throw ApiException.fromResponse(response, 'createUser');
    }
  }

  @override
  Future<void> deleteUser() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 204) {
      await deleteJwtTokens();
    } else if (response.statusCode == 404) {
      AppLogger.log('deleteUser 404 이미 삭제된 유저.');
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return deleteUser();
    } else {
      throw ApiException.fromResponse(response, 'deleteUser');
    }
  }
}
