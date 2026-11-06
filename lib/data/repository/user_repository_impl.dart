import 'package:cake/data/data_source/api/api_error_mapper.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/mapper/user_mapper.dart';
import 'package:cake/domain/model/diary_stats.dart';
import 'package:cake/domain/model/user_profile.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;
  final AuthRepository _authRepository;
  final FCMService _fcmService;

  UserRepositoryImpl({
    required UserApi userApi,
    required AuthRepository authRepository,
    required FCMService fcmService,
  }) : _userApi = userApi,
       _authRepository = authRepository,
       _fcmService = fcmService;

  @override
  Future<UserProfile> getMe() async {
    try {
      return (await _userApi.fetchMe()).toUserProfile();
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<String> updateNickname(String nickname) async {
    try {
      return await _userApi.updateNickname(nickname);
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<bool> updateNotification(bool enabled) async {
    try {
      return await _userApi.updateNotification(enabled);
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<DiaryStats> getStats() async {
    try {
      return (await _userApi.fetchStats()).toDiaryStats();
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<void> withdraw() async {
    try {
      await _userApi.deleteUser();
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
    try {
      await _fcmService.deleteFCMToken();
    } catch (e) {
      AppLogger.error('FCM 토큰 삭제 실패(무시): $e');
    }
    await _authRepository.clearSession();
  }
}
