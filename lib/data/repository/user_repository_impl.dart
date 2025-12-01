import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;
  final TokenRepository _tokenRepo;

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
  }
}
