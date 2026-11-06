import 'package:cake/data/dto/diary_stats_response_dto.dart';
import 'package:cake/data/dto/user_me_response_dto.dart';

abstract interface class UserApi {
  Future<UserMeResponseDto> fetchMe();
  Future<String> updateNickname(String nickname);
  Future<bool> updateNotification(bool enabled);
  Future<DiaryStatsResponseDto> fetchStats();
  Future<void> deleteUser();
}
