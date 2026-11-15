import 'package:cake/config/service_config.dart';
import 'package:cake/data/data_source/api/api_error_mapper.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/mapper/diary_mapper.dart';
import 'package:cake/data/mapper/qna_mapper.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/model/question_set.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:dio/dio.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryApi _diaryApi;

  DiaryRepositoryImpl({required DiaryApi diaryApi}) : _diaryApi = diaryApi;

  @override
  Future<DiaryPage> getDiaryPage({
    required SortType sort,
    required int page,
    int size = ServiceConfig.diaryPageSize,
  }) async {
    try {
      final dto = await _diaryApi.fetchDiaryPage(
        sort: sort.serverValue,
        page: page,
        size: size,
      );
      return dto.toDiaryPage(requestedPage: page);
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async {
    try {
      final list = await _diaryApi.fetchMonthlyDiaries(
        year: year,
        month: month,
        sort: SortType.recent.serverValue,
      );
      return list.map((e) => e.toDiary()).toList();
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<DiaryDetail> getDiary({required int id}) async {
    try {
      final dto = await _diaryApi.fetchDiary(id: id);
      return dto.toDiaryDetail();
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<QuestionSet> getQuestionSet() async {
    try {
      final dto = await _diaryApi.fetchQuestions();
      final questions = dto.questions ?? const <String>[];
      return QuestionSet(
        questions: [
          for (final (index, question) in questions.indexed)
            Qna(
              id: index + 1,
              question: question,
              answer: '',
              required: index < ServiceConfig.qnaRequiredCount,
            ),
        ],
        optionalSpares: List.unmodifiable(dto.optionalSpares ?? const []),
      );
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<String> generateQnaDiary({required List<Qna> qnaList}) async {
    final answered = qnaList.where((qna) => qna.isAnswered).toList();
    try {
      return await _diaryApi.requestQnaDiary(
        qnaListDto: answered.map((qna) => qna.toDto()).toList(),
      );
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<LocalImage> images,
  }) async {
    try {
      final dto = switch (diaryType) {
        DiaryType.free => await _diaryApi.createFreeDiary(
          text: text,
          images: images,
        ),
        DiaryType.qna => await _diaryApi.createQnaDiary(
          text: text,
          images: images,
        ),
      };
      return dto.toDiaryDetail(fallbackType: diaryType);
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<void> editDiaryText({
    required int id,
    required String editText,
  }) async {
    try {
      await _diaryApi.updateDiaryText(id: id, text: editText);
    } on DioException catch (e) {
      throw mapOrRethrow(e);
    }
  }

  @override
  Future<void> removeDiary(int id) async {
    try {
      await _diaryApi.deleteDiary(id: id);
    } on DioException catch (e) {
      // 이미 지워진 일기는 성공으로 본다.
      final mapped = mapDioException(e);
      if (e.response?.statusCode == 404) return;
      throw mapped ?? e;
    }
  }
}
