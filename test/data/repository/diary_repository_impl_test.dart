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

  group('getQuestionSet', () {
    test('질문에 1부터 시작하는 id를 붙이고 앞 2개만 필수로 표시한다', () async {
      api.questions = ['필수1', '필수2', '선택1', '선택2', '선택3'];
      api.optionalSpares = ['여분1', '여분2'];

      final result = await repository.getQuestionSet();

      expect(result.questions.length, 5);
      expect(result.questions[0].id, 1);
      expect(result.questions[0].question, '필수1');
      expect(result.questions[0].answer, '');
      expect(result.questions.map((q) => q.required), [
        true,
        true,
        false,
        false,
        false,
      ]);
      expect(result.optionalSpares, ['여분1', '여분2']);
    });

    test('optionalSpares가 없는 구버전 응답은 빈 여분으로 받는다', () async {
      api.questions = ['q1'];
      api.optionalSpares = null;

      final result = await repository.getQuestionSet();

      expect(result.optionalSpares, isEmpty);
    });
  });

  group('generateQnaDiary', () {
    test('빈 답은 빼고 보낸다', () async {
      await repository.generateQnaDiary(
        qnaList: const [
          Qna(id: 1, question: 'q1', answer: 'a1'),
          Qna(id: 2, question: 'q2', answer: ''),
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
