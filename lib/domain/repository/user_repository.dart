import 'package:cake/domain/enum/diary_type.dart';

abstract interface class UserRepository {
  Future<void> signUp({required DiaryType diaryPreference});
  Future<void> withdraw();
}
