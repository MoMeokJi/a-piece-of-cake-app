import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';

class FakeDiaryRepository implements DiaryRepository {
  List<Diary> latestDiaries = [];
  List<Diary> oldestDiaries = [];

  int getLatestCallCount = 0;
  int getOldestCallCount = 0;

  @override
  Future<List<Diary>> getLatestDiaryList() async {
    getLatestCallCount++;
    return latestDiaries;
  }

  @override
  Future<List<Diary>> getOldestDiaryList() async {
    getOldestCallCount++;
    return oldestDiaries;
  }

  @override
  Future<List<Diary>> getCurrentMonthlyDiaryList() async => latestDiaries;

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async => latestDiaries;

  @override
  Future<bool> isAbleToWriteDiaryToday() async => true;

  @override
  Future<DiaryDetail> getDiary({required int id}) =>
      throw UnimplementedError();

  @override
  Future<List<Qna>> getQuestionList() => throw UnimplementedError();

  @override
  Future<String> generateQnaDiary({required List<Qna> qnaList}) =>
      throw UnimplementedError();

  @override
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<LocalImage> images,
  }) => throw UnimplementedError();

  @override
  Future<void> editDiaryText({required int id, required String editText}) =>
      throw UnimplementedError();

  @override
  Future<void> removeDiary(int id) => throw UnimplementedError();
}
