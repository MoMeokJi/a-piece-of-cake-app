import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';

abstract interface class DiaryRepository {
  Future<DiaryPage> getDiaryPage({
    required SortType sort,
    required int page,
    int size,
  });

  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  });

  Future<DiaryDetail> getDiary({required int id});

  Future<List<Qna>> getQuestionList();

  /// 답한 문항만 보낸다. 전부 건너뛰었으면 호출하지 말 것.
  Future<String> generateQnaDiary({required List<Qna> qnaList});

  /// 429면 [DiaryDailyLimitExceededException]
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<LocalImage> images,
  });

  Future<void> editDiaryText({required int id, required String editText});
  Future<void> removeDiary(int id);
}
