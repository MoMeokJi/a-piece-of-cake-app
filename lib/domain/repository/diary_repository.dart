import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class DiaryRepository {
  Future<List<Diary>> getLatestDiaryList();
  Future<List<Diary>> getOldestDiaryList();
  Future<List<Diary>> getCurrentMonthlyDiaryList();
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  });
  Future<bool> isAbleToWriteDiaryToday();
  Future<void> removeDiary(int id);

  Future<DiaryDetail> completeDiary({
    required String text,
    required List<XFile> images,
  });

  Future<String> generateQnaDiary({required List<Qna> qnaList});
  Future<DiaryDetail> getDiary({required int id});
}
