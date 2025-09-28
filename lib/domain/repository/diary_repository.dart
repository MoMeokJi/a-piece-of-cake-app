import 'package:cake/domain/model/diary.dart';

abstract interface class DiaryRepository {
  Future<List<Diary>> getLatestDiaryList();
  Future<List<Diary>> getOldestDiaryList();
  Future<List<Diary>> getCurrentMonthlyDiaryList();
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  });
  Future<bool> isAbleToWriteDiaryToday();
  Future<void> removeDiary(int id);
}
