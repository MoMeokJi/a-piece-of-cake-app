import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:get_it/get_it.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;
  final DiaryDao _diaryDao;
  final FCMService _fcmService;
  final GetIt _getIt = GetIt.instance;

  UserRepositoryImpl({
    required UserApi userApi,
    required DiaryDao diaryDao,
    required FCMService fcmService,
  }) : _userApi = userApi,
       _diaryDao = diaryDao,
       _fcmService = fcmService;

  @override
  Future<void> signUp({required DiaryPreference diaryPreference}) async {
    // 앱을 삭제하지 않고 재가입하는 경우에도 FCM 토큰을 갱신하기 위해 먼저 발급
    await _fcmService.getFCMTokenAndSave();
    await _userApi.createUser(preference: diaryPreference.toServer);
  }

  @override
  Future<void> withdraw() async {
    await _userApi.deleteUser();
    await _fcmService.deleteFCMToken();
    await _diaryDao.deleteAllDiaries();
    await _resetAppState();
  }

  Future<void> _resetAppState() async {
    if (_getIt.isRegistered<DiaryCalendarViewModel>()) {
      _getIt.unregister<DiaryCalendarViewModel>();
      _getIt.registerLazySingleton(
        () => DiaryCalendarViewModel(diaryRepo: _getIt()),
      );
    }

    if (_getIt.isRegistered<DiaryListViewModel>()) {
      _getIt.unregister<DiaryListViewModel>();
      _getIt.registerLazySingleton(
        () => DiaryListViewModel(diaryRepo: _getIt()),
      );
    }
  }
}
