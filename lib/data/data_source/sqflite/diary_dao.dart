import 'package:cake/data/data_source/sqflite/database_helper.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:sqflite/sqflite.dart';

class DiaryDao {
  final Database _db;
  DiaryDao(this._db);

  // 최신순으로 일기 가져옴
  Future<List<Diary>> getAllDiariesLatest() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      orderBy: 'createdAt DESC',
    );

    return _mapToDiaries(maps);
  }

  // 등록순으로 일기 가져옴
  Future<List<Diary>> getAllDiariesOldest() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      orderBy: 'createdAt ASC',
    );

    return _mapToDiaries(maps);
  }

  // 일기 삽입/업데이트 메서드
  Future<void> insertDiary(Diary diary) async {
    await _db.insert(
      DatabaseHelper.diaryTableName,
      {
        'id': diary.id,
        'summary': diary.summary,
        'createdAt': diary.createdAt.toIso8601String(),
        'firstColorHex': diary.firstColorHex,
        'secondColorHex': diary.secondColorHex,
        'musicTitle': diary.musicTitle,
        'musicArtist': diary.musicArtist,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // 같은 ID면 덮어쓰기
    );
  }

  // 일기 삭제하는 메서드
  Future<void> deleteDiary(int id) async {
    await _db.delete(
      DatabaseHelper.diaryTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 특정 년/월의 일기 가져오기
  Future<List<Diary>> getDiariesByMonth(int year, int month) async {
    // 해당 월의 시작일과 끝일 계산
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await _db.query(
      DatabaseHelper.diaryTableName,
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'createdAt DESC',
    );

    return _mapToDiaries(maps);
  }

  // 현재 월의 일기 가져오기
  Future<List<Diary>> getCurrentMonthDiaries() async {
    final now = DateTime.now();
    return getDiariesByMonth(now.year, now.month);
  }

  // 전체 데이터 다 지우는 메서드
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
          ),
        )
        .toList();
  }
}
