import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:cake/data/dto/diary_page_response_dto.dart';
import 'package:cake/data/repository/diary_repository_impl.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_api.dart';

void main() {
  late FakeDiaryApi api;
  late DiaryRepositoryImpl repository;

  setUp(() {
    api = FakeDiaryApi();
    repository = DiaryRepositoryImpl(diaryApi: api);
  });

  group('getQuestionList', () {
    test('질문 문자열에 1부터 시작하는 id를 붙이고 answer를 비운다', () async {
      api.questions = ['오늘 무엇을 했나요', '기분은 어땠나요'];

      final result = await repository.getQuestionList();

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].question, '오늘 무엇을 했나요');
      expect(result[0].answer, '');
      expect(result[1].id, 2);
    });
  });

  group('generateQnaDiary', () {
    test('건너뛴 문항과 빈 답은 빼고 보낸다', () async {
      await repository.generateQnaDiary(
        qnaList: const [
          Qna(id: 1, question: 'q1', answer: 'a1'),
          Qna(id: 2, question: 'q2', answer: '', skipped: true),
          Qna(id: 3, question: 'q3', answer: '   '),
          Qna(id: 4, question: 'q4', answer: 'a4'),
        ],
      );

      final sent = api.lastQnaRequest!;
      expect(sent.map((e) => e.question), ['q1', 'q4']);
    });
  });

  group('getDiaryPage', () {
    test('sort 서버 값을 항상 명시하고 목록·메타를 매핑한다', () async {
      api.pageResponse = DiaryPageResponseDto(
        items: [
          DiaryListResponseDto(
            diaryId: 3,
            type: 'QNA',
            summary: '요약',
            createdAt: '2025-09-05T21:12:00+09:00',
          ),
        ],
        page: 2,
        hasNext: false,
        totalCount: 21,
      );

      final page = await repository.getDiaryPage(sort: SortType.oldest, page: 2);

      expect(api.lastPageQuery['sort'], 'oldest');
      expect(page.items.single.type, DiaryType.qna);
      expect(page.page, 2);
      expect(page.totalCount, 21);
    });

    test('타입을 모르면 free로, 색이 없으면 브랜드 색으로 채운다', () async {
      api.pageResponse = DiaryPageResponseDto(
        items: [DiaryListResponseDto(diaryId: 1, createdAt: '2025-09-05T21:12:00')],
      );

      final page = await repository.getDiaryPage(sort: SortType.recent, page: 0);

      final diary = page.items.single;
      expect(diary.type, DiaryType.free);
      expect(diary.firstColor.hex, '#8196C3');
      expect(diary.secondColor.hex, '#EEB5BE');
    });
  });

  group('removeDiary', () {
    test('서버에 삭제를 요청한다', () async {
      await repository.removeDiary(42);

      expect(api.deletedDiaryIds, [42]);
    });
  });
}
