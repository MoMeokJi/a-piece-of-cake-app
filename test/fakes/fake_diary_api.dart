import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/model/local_image.dart';

class FakeDiaryApi implements DiaryApi {
  List<String> questions = [];
  List<int> deletedDiaryIds = [];

  @override
  Future<List<String>> fetchQuestions() async => questions;

  @override
  Future<void> deleteDiary({required int id}) async {
    deletedDiaryIds.add(id);
  }

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<LocalImage> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<LocalImage> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) =>
      throw UnimplementedError();

  @override
  Future<String> requestQnaDiary({required List<QnaRequestDto> qnaListDto}) =>
      throw UnimplementedError();

  @override
  Future<void> updateDiaryText({required int id, required String text}) =>
      throw UnimplementedError();
}
