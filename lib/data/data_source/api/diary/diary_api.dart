import 'package:cake/data/dto/daily_questions_response_dto.dart';
import 'package:cake/data/dto/diary_detail_response_dto.dart';
import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:cake/data/dto/diary_page_response_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/model/local_image.dart';

abstract interface class DiaryApi {
  Future<DiaryPageResponseDto> fetchDiaryPage({
    required String sort,
    required int page,
    required int size,
  });

  Future<List<DiaryListResponseDto>> fetchMonthlyDiaries({
    required int year,
    required int month,
    required String sort,
  });

  Future<DiaryDetailResponseDto> createQnaDiary({
    required String text,
    required List<LocalImage> images,
  });

  Future<DiaryDetailResponseDto> createFreeDiary({
    required String text,
    required List<LocalImage> images,
  });

  Future<DiaryDetailResponseDto> fetchDiary({required int id});

  Future<DailyQuestionsResponseDto> fetchQuestions();

  Future<String> requestQnaDiary({required List<QnaRequestDto> qnaListDto});

  Future<void> updateDiaryText({required int id, required String text});

  Future<void> deleteDiary({required int id});
}
