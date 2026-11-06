import 'package:cake/config/service_config.dart';
import 'package:cake/data/dto/auth_token_response_dto.dart';
import 'package:cake/data/dto/diary_stats_response_dto.dart';
import 'package:cake/data/dto/user_me_response_dto.dart';
import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/model/auth_session.dart';
import 'package:cake/domain/model/diary_stats.dart';
import 'package:cake/domain/model/user_profile.dart';

extension UserMeResponseMapper on UserMeResponseDto {
  UserProfile toUserProfile() => UserProfile(
    memberId: memberId ?? '',
    nickname: nickname ?? '',
    provider: SocialProvider.fromServer(provider),
    notificationEnabled: notificationEnabled ?? false,
  );
}

extension DiaryStatsResponseMapper on DiaryStatsResponseDto {
  DiaryStats toDiaryStats() => DiaryStats(
    totalCount: totalCount ?? 0,
    monthCount: monthCount ?? 0,
    streakDays: streakDays ?? 0,
    todayCount: todayCount ?? 0,
    dailyLimit: dailyLimit ?? ServiceConfig.maxDiaryCount,
  );
}

extension AuthTokenResponseMapper on AuthTokenResponseDto {
  /// 토큰이 비어 있으면 null. 호출부가 실패로 처리한다.
  AuthSession? toAuthSession() {
    final access = accessToken;
    final refresh = refreshToken;
    if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
      return null;
    }
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      accessTokenExpiresIn: accessTokenExpiresIn,
      refreshTokenExpiresIn: refreshTokenExpiresIn,
      isNewMember: isNewMember ?? false,
      nickname: nickname,
    );
  }
}
