import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:get_it/get_it.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;
  final TokenRepository _tokenRepo;
  final GetIt _getIt = GetIt.instance;

  UserRepositoryImpl({
    required UserApi userApi,
    required TokenRepository tokenRepo,
  }) : _userApi = userApi,
       _tokenRepo = tokenRepo;

  @override
  Future<void> signUp({required DiaryPreference diaryPreference}) async {
    await _userApi.createUser(preference: diaryPreference.toServer);
  }

  @override
  Future<void> withdraw() async {
    await _userApi.deleteUser();
    await _tokenRepo.clearJwtTokens();
    await _tokenRepo.clearFcmToken();
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
