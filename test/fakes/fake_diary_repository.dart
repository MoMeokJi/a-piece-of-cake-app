import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/model/question_set.dart';
import 'package:cake/domain/repository/diary_repository.dart';

class FakeDiaryRepository implements DiaryRepository {
  /// 페이지별 응답. 없는 페이지는 빈 페이지.
  Map<SortType, List<DiaryPage>> pages = {};
  List<Diary> monthlyDiaries = [];
  List<Qna> questions = [];
  List<String> optionalSpares = [];
  String generated = '생성된 일기';
  Object? generateError;

  int getPageCallCount = 0;
  int getMonthlyCallCount = 0;
  final List<SortType> requestedSorts = [];
  final List<int> requestedPages = [];
  List<Qna>? lastGenerateInput;

  @override
  Future<DiaryPage> getDiaryPage({
    required SortType sort,
    required int page,
    int size = 10,
  }) async {
    getPageCallCount++;
    requestedSorts.add(sort);
    requestedPages.add(page);
    final list = pages[sort] ?? const [];
    if (page < list.length) return list[page];
    return DiaryPage(items: const [], page: page, hasNext: false, totalCount: 0);
  }

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async {
    getMonthlyCallCount++;
    return monthlyDiaries;
  }

  /// id별 상세. 없으면 UnimplementedError (예전과 같음).
  Map<int, DiaryDetail> details = {};
  int getDiaryCallCount = 0;

  @override
  Future<DiaryDetail> getDiary({required int id}) async {
    getDiaryCallCount++;
    final detail = details[id];
    if (detail == null) throw UnimplementedError();
    return detail;
  }

  @override
  Future<QuestionSet> getQuestionSet() async =>
      QuestionSet(questions: questions, optionalSpares: optionalSpares);

  @override
  Future<String> generateQnaDiary({required List<Qna> qnaList}) async {
    lastGenerateInput = qnaList;
    final error = generateError;
    if (error != null) throw error;
    return generated;
  }

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
