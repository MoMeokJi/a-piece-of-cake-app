import 'package:cake/config/service_config.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/mapper/diary_detail_mapper.dart';
import 'package:cake/data/mapper/qna_mapper.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:image_picker/image_picker.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryDao _diaryDao;
  final DiaryApi _diaryApi;

  DiaryRepositoryImpl({required DiaryDao diaryDao, required DiaryApi diaryApi})
    : _diaryDao = diaryDao,
      _diaryApi = diaryApi;

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
  Future<bool> isAbleToWriteDiaryToday() async {
    final count = await _diaryDao.getTodayDiaryCount();
    return count < ServiceConfig.maxDiaryCount;
  }

  @override
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<XFile> images,
  }) async {
    final DiaryDetailDto dto = switch (diaryType) {
      DiaryType.free => await _diaryApi.createFreeDiary(
        text: text,
        images: images,
      ),
      DiaryType.qna => await _diaryApi.createQnaDiary(
        text: text,
        images: images,
      ),
    };

    final DiaryDetail diary = dto.toDiaryDetail();
    await _diaryDao.insertDiary(
      Diary(
        id: diary.id,
        summary: diary.summary!,
        createdAt: diary.createdAt,
        firstColorHex: diary.firstColorHex,
        secondColorHex: diary.secondColorHex,
        musicTitle: diary.musicTitle,
        musicArtist: diary.musicArtist,
      ),
    );
    return diary;
  }

  @override
  Future<List<Qna>> getQuestionList() async {
    final questions = await _diaryApi.fetchQuestions();

    // 2. List<String> → List<Qna> 변환 (id 부여)
    final qnaList = questions.asMap().entries.map((entry) {
      return Qna(id: (entry.key + 1), question: entry.value, answer: '');
    }).toList();

    // 3. 필요하면 여기서 섞기
    // qnaList.shuffle();

    return qnaList;
  }

  @override
  Future<String> generateQnaDiary({required List<Qna> qnaList}) async {
    final dtoList = qnaList.map((qna) => qna.toDto()).toList();
    final String generatedDiary = await _diaryApi.requestQnaDiary(
      qnaListDto: dtoList,
    );

    return generatedDiary;
  }

  @override
  Future<DiaryDetail> getDiary({required int id}) async {
    final DiaryDetailDto dto = await _diaryApi.fetchDiary(id: id);
    return dto.toDiaryDetail();
  }

  @override
  Future<void> removeDiary(int id) async {
    // sqflite 삭제
    await _diaryDao.deleteDiary(id);

    // 서버에 삭제 요청
    await _diaryApi.deleteDiary(id: id);
  }

  @override
  Future<void> editDiaryText({
    required int id,
    required String editText,
  }) async {
    // 본문은 매번 서버에서 가져오기 때문에 로컬디비에 수정할거 없음. 서버에만 요청
    await _diaryApi.updateDiaryText(id: id, text: editText);
  }

  @override
  Future<void> removeAllDiaries() async {
    await _diaryDao.deleteAll();
  }
}
