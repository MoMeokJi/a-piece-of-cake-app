import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/dto/diary_stats_response_dto.dart';
import 'package:cake/data/dto/user_me_response_dto.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class UserApiImpl implements UserApi {
  final Dio _dio;

  UserApiImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UserMeResponseDto> fetchMe() async {
    final response = await _dio.get('/users/me');
    return UserMeResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> updateNickname(String nickname) async {
    final response = await _dio.put(
      '/users/me/nickname',
      data: {'nickname': nickname},
    );
    final body = response.data;
    return (body is Map ? body['nickname'] as String? : null) ?? nickname;
  }

  @override
  Future<bool> updateNotification(bool enabled) async {
    final response = await _dio.put(
      '/users/me/notification',
      data: {'enabled': enabled},
    );
    final body = response.data;
    return (body is Map ? body['notificationEnabled'] as bool? : null) ??
        enabled;
  }

  @override
  Future<DiaryStatsResponseDto> fetchStats() async {
    final response = await _dio.get('/users/me/stats');
    return DiaryStatsResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteUser() async {
    final response = await _dio.delete(
      '/users',
      options: Options(
        // 404는 이미 삭제된 유저. 401은 통과시키지 않아야 인터셉터가 재발급한다.
        validateStatus: (status) =>
            status != null && (status < 300 || status == 404),
      ),
    );
    if (response.statusCode == 404) {
      AppLogger.log('deleteUser 404 이미 삭제된 유저.');
    }
  }
}
