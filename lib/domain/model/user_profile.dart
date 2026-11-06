import 'package:cake/domain/enum/social_provider.dart';

class UserProfile {
  final String memberId;
  final String nickname;
  final SocialProvider? provider;
  final bool notificationEnabled;

  const UserProfile({
    required this.memberId,
    required this.nickname,
    required this.provider,
    required this.notificationEnabled,
  });

  UserProfile copyWith({String? nickname, bool? notificationEnabled}) =>
      UserProfile(
        memberId: memberId,
        nickname: nickname ?? this.nickname,
        provider: provider,
        notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      );
}
