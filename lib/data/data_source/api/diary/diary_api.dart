import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class DiaryApi {
  // 문답일기 확정하기
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  });

  // 자유일기 확정하기
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  });

  // 일기 조회하기
  Future<DiaryDetailDto> fetchDiary({required int id});

  // 문답일기 질문 조회
  Future<List<String>> fetchQuestions();

  // 문답일기 생성
  Future<String> requestQnaDiary({required List<QnaRequestDto> qnaListDto});

  // 일기 삭제하기
  Future<void> deleteDiary({required int id});
}
