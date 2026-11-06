import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/model/diary_stats.dart';
import 'package:cake/domain/model/user_profile.dart';
import 'package:cake/domain/repository/user_repository.dart';

class FakeUserRepository implements UserRepository {
  UserProfile profile = const UserProfile(
    memberId: 'm1',
    nickname: '서윤',
    provider: SocialProvider.google,
    notificationEnabled: false,
  );
  DiaryStats stats = const DiaryStats(
    totalCount: 0,
    monthCount: 0,
    streakDays: 0,
    todayCount: 0,
    dailyLimit: 3,
  );
  Object? nicknameError;
  final List<String> savedNicknames = [];
  final List<bool> notificationUpdates = [];
  int withdrawCallCount = 0;

  @override
  Future<UserProfile> getMe() async => profile;

  @override
  Future<String> updateNickname(String nickname) async {
    final error = nicknameError;
    if (error != null) throw error;
    savedNicknames.add(nickname);
    profile = profile.copyWith(nickname: nickname);
    return nickname;
  }

  @override
  Future<bool> updateNotification(bool enabled) async {
    notificationUpdates.add(enabled);
    return enabled;
  }

  @override
  Future<DiaryStats> getStats() async => stats;

  @override
  Future<void> withdraw() async => withdrawCallCount++;
}
