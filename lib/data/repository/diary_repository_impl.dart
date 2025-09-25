import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/repository/diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryDao _diaryDao;

  DiaryRepositoryImpl({required DiaryDao diaryDao}) : _diaryDao = diaryDao;

  @override
  Future<List<Diary>> getLatestDiaryList() async {
    return await _diaryDao.getAllDiariesLatest();
  }

  @override
  Future<List<Diary>> getOldestDiaryList() async {
    return await _diaryDao.getAllDiariesOldest();
  }

  @override
  Future<List<Diary>> getCurrentMonthlyDiaryList() async {
    return await _diaryDao.getCurrentMonthDiaries();
  }

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async {
    return await _diaryDao.getDiariesByMonth(year, month);
  }

  @override
  Future<void> removeDiary(int id) async {
    // sqflite 삭제
    await _diaryDao.deleteDiary(id);

    // 서버에 삭제 요청 => 추후 구현 예정
  }
}
