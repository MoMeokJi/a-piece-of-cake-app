import 'package:cake/domain/enum/diary_preference.dart';

abstract interface class UserRepository {
  Future<void> signUp({required DiaryPreference diaryPreference});
  Future<void> withdraw();

  /// 비활성 사용자 판정 시 로컬 일기를 모두 지운다.
  Future<void> clearLocalDiaries();
}
