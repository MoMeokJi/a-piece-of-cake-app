import 'package:cake/config/service_config.dart';
import 'package:cake/data/repository/diary_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_api.dart';
import '../../fakes/fake_diary_dao.dart';

void main() {
  late FakeDiaryApi api;
  late FakeDiaryDao dao;
  late DiaryRepositoryImpl repository;

  setUp(() {
    api = FakeDiaryApi();
    dao = FakeDiaryDao();
    repository = DiaryRepositoryImpl(diaryDao: dao, diaryApi: api);
  });

  group('isAbleToWriteDiaryToday', () {
    test('오늘 작성 수가 상한 미만이면 true', () async {
      dao.todayDiaryCount = ServiceConfig.maxDiaryCount - 1;

      expect(await repository.isAbleToWriteDiaryToday(), isTrue);
    });

    test('오늘 작성 수가 상한에 도달하면 false', () async {
      dao.todayDiaryCount = ServiceConfig.maxDiaryCount;

      expect(await repository.isAbleToWriteDiaryToday(), isFalse);
    });
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

    test('질문이 없으면 빈 목록을 반환한다', () async {
      api.questions = [];

      expect(await repository.getQuestionList(), isEmpty);
    });
  });

  group('removeDiary', () {
    test('로컬 DB와 서버 양쪽에서 삭제한다', () async {
      await repository.removeDiary(42);

      expect(dao.deletedDiaryIds, [42]);
      expect(api.deletedDiaryIds, [42]);
    });
  });
}
