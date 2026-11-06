import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';

class FakeDiaryRepository implements DiaryRepository {
  /// 페이지별 응답. 없는 페이지는 빈 페이지.
  Map<SortType, List<DiaryPage>> pages = {};
  List<Diary> monthlyDiaries = [];
  List<Qna> questions = [];
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

  @override
  Future<DiaryDetail> getDiary({required int id}) => throw UnimplementedError();

  @override
  Future<List<Qna>> getQuestionList() async => questions;

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
