import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/daily_questions_response_dto.dart';
import 'package:cake/data/dto/diary_detail_response_dto.dart';
import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:cake/data/dto/diary_page_response_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/model/local_image.dart';

class FakeDiaryApi implements DiaryApi {
  List<String> questions = [];
  List<String>? optionalSpares;
  List<int> deletedDiaryIds = [];
  List<QnaRequestDto>? lastQnaRequest;
  DiaryPageResponseDto pageResponse = DiaryPageResponseDto(items: []);
  List<DiaryListResponseDto> monthlyResponse = [];
  Map<String, Object?> lastPageQuery = {};

  @override
  Future<DailyQuestionsResponseDto> fetchQuestions() async =>
      DailyQuestionsResponseDto(
        questions: questions,
        optionalSpares: optionalSpares,
      );

  @override
  Future<void> deleteDiary({required int id}) async {
    deletedDiaryIds.add(id);
  }

  @override
  Future<DiaryPageResponseDto> fetchDiaryPage({
    required String sort,
    required int page,
    required int size,
  }) async {
    lastPageQuery = {'sort': sort, 'page': page, 'size': size};
    return pageResponse;
  }

  @override
  Future<List<DiaryListResponseDto>> fetchMonthlyDiaries({
    required int year,
    required int month,
    required String sort,
  }) async => monthlyResponse;

  @override
  Future<DiaryDetailResponseDto> createQnaDiary({
    required String text,
    required List<LocalImage> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailResponseDto> createFreeDiary({
    required String text,
    required List<LocalImage> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailResponseDto> fetchDiary({required int id}) =>
      throw UnimplementedError();

  @override
  Future<String> requestQnaDiary({required List<QnaRequestDto> qnaListDto}) async {
    lastQnaRequest = qnaListDto;
    return '생성된 일기';
  }

  @override
  Future<void> updateDiaryText({required int id, required String text}) =>
      throw UnimplementedError();
}
