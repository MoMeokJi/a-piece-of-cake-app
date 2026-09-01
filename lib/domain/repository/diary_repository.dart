import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';

abstract interface class DiaryRepository {
  Future<List<Diary>> getLatestDiaryList();
  Future<List<Diary>> getOldestDiaryList();
  Future<List<Diary>> getCurrentMonthlyDiaryList();
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  });
  Future<bool> isAbleToWriteDiaryToday();

  Future<DiaryDetail> getDiary({required int id});

  Future<List<Qna>> getQuestionList();
  Future<String> generateQnaDiary({required List<Qna> qnaList});

  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<LocalImage> images,
  });

  Future<void> editDiaryText({required int id, required String editText});
  Future<void> removeDiary(int id);
}
