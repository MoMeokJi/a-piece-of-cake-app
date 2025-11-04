import 'package:cake/data/data_source/sqflite/database_helper.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:sqflite/sqflite.dart';

class DiaryDao {
  final Database _db;
  DiaryDao(this._db);

  // 삭제되지 않은 일기만 최신순으로 가져옴
  Future<List<Diary>> getAllDiariesLatest() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );

    return _mapToDiaries(maps);
  }

  // 삭제되지 않은 일기만 등록순으로 가져옴
  Future<List<Diary>> getAllDiariesOldest() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt ASC',
    );

    return _mapToDiaries(maps);
  }

  // 일기 삽입/업데이트 메서드
  Future<void> insertDiary(Diary diary) async {
    await _db.insert(DatabaseHelper.diaryTableName, {
      'id': diary.id,
      'summary': diary.summary,
      'createdAt': diary.createdAt.toIso8601String(),
      'firstColorHex': diary.firstColorHex,
      'secondColorHex': diary.secondColorHex,
      'musicTitle': diary.musicTitle,
      'musicArtist': diary.musicArtist,
      'isDeleted': diary.isDeleted ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // 특정 년/월의 일기 가져오기
  Future<List<Diary>> getDiariesByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      where: 'createdAt >= ? AND createdAt <= ? AND isDeleted = ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String(), 0],
      orderBy: 'createdAt DESC',
    );

    return _mapToDiaries(maps);
  }

  // 현재 월의 일기 가져오기
  Future<List<Diary>> getCurrentMonthDiaries() async {
    final now = DateTime.now();
    return getDiariesByMonth(now.year, now.month);
  }

  // 오늘 작성한 일기 개수 반환
  Future<int> getTodayDiaryCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return maps.length;
  }

  // 일기 소프트 삭제
  Future<void> deleteDiary(int id) async {
    await _db.update(
      DatabaseHelper.diaryTableName,
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 소프트 삭제된 일기들만 영구 삭제 -> 주기적으로 실행?
  Future<int> deleteAllSoftDeletedDiaries() async {
    return await _db.delete(
      DatabaseHelper.diaryTableName,
      where: 'isDeleted = ?',
      whereArgs: [1],
    );
  }

  // 전체 db 삭제
  Future<int> deleteAll() => _db.delete(DatabaseHelper.diaryTableName);

  // Map을 Diary 객체로 변환하는 헬퍼 메서드
  List<Diary> _mapToDiaries(List<Map<String, dynamic>> maps) {
    return maps
        .map(
          (map) => Diary(
            id: map['id'] as int,
            summary: map['summary'] as String,
            createdAt: DateTime.parse(map['createdAt'] as String),
            firstColorHex: map['firstColorHex'] as String,
            secondColorHex: map['secondColorHex'] as String,
            musicTitle: map['musicTitle'] as String,
            musicArtist: map['musicArtist'] as String,
            isDeleted: (map['isDeleted'] as int) == 1,
          ),
        )
        .toList();
  }
}
