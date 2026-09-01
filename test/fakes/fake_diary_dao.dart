import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/model/diary.dart';

class FakeDiaryDao implements DiaryDao {
  int todayDiaryCount = 0;
  List<Diary> diaries = [];
  List<Diary> insertedDiaries = [];
  List<int> deletedDiaryIds = [];
  int deleteAllDiariesCallCount = 0;

  @override
  Future<int> getTodayDiaryCount() async => todayDiaryCount;

  @override
  Future<List<Diary>> getAllDiariesLatest() async => diaries;

  @override
  Future<List<Diary>> getAllDiariesOldest() async => diaries.reversed.toList();

  @override
  Future<List<Diary>> getCurrentMonthDiaries() async => diaries;

  @override
  Future<List<Diary>> getDiariesByMonth(int year, int month) async => diaries;

  @override
  Future<void> insertDiary(Diary diary) async => insertedDiaries.add(diary);

  @override
  Future<void> deleteDiary(int id) async => deletedDiaryIds.add(id);

  @override
  Future<int> deleteAllDiaries() async {
    deleteAllDiariesCallCount++;
    return 0;
  }

  @override
  Future<int> deleteAllSoftDeletedDiaries() async => 0;
}
