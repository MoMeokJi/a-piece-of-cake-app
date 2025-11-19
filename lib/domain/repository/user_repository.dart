import 'package:cake/domain/enum/diary_preference.dart';

abstract interface class UserRepository {
  Future<void> signUp({required DiaryPreference diaryPreference});
  Future<void> withdraw();
}
