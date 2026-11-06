import 'package:cake/domain/model/diary_stats.dart';
import 'package:cake/domain/model/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getMe();
  Future<String> updateNickname(String nickname);
  Future<bool> updateNotification(bool enabled);
  Future<DiaryStats> getStats();

  /// 서버 탈퇴 후 로컬 세션을 지운다.
  Future<void> withdraw();
}
