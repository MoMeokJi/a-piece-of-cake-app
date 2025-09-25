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
    // TODO: 현재 날짜 확인 후 그 달에 써진 일기 가져오기
    throw UnimplementedError();
  }

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async {
    // TODO: 요청하는 달에 쓴 일기 가져오기
    throw UnimplementedError();
  }

  @override
  Future<void> removeDiary(int id) async {
    // sqflite 삭제
    await _diaryDao.deleteDiary(id);

    // 서버에 삭제 요청 => 추후 구현 예정
  }
}
