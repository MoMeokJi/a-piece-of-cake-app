import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/model/question_set.dart';

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

  /// 질문은 진입 때 한 번만 받는다. 건너뛸 때 다시 부르지 않는다 (호출마다 새로 뽑혀 중복됨).
  Future<QuestionSet> getQuestionSet();

  /// 답한 문항만 보낸다 (정상 흐름에선 전부 답한 상태다).
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
