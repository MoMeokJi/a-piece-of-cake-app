import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_diary_repository.dart';

Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeDiaryRepository repo;

  setUp(() {
    repo = FakeDiaryRepository()
      ..questions = const [
        Qna(id: 1, question: 'q1', answer: ''),
        Qna(id: 2, question: 'q2', answer: ''),
        Qna(id: 3, question: 'q3', answer: ''),
      ];
  });

  test('첫 질문을 봇 말풍선으로 띄운다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();

    expect(vm.chatList.single.content, 'q1');
    expect(vm.currentQuestionNumber, 1);
    expect(vm.totalQuestions, 3);
  });

  test('답하고 건너뛰며 끝까지 가면 답한 것만 모아 생성한다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();

    vm.textController.text = 'a1';
    await vm.submitAnswer();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(vm.currentQuestionNumber, 2);

    await vm.skipCurrentQuestion();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(vm.chatList.last.content, 'q3');

    vm.textController.text = 'a3';
    await vm.submitAnswer();
    await settle();

    expect(vm.state, ResultState.success);
    expect(vm.generatedDiary, '생성된 일기');
    final sent = repo.lastGenerateInput!;
    expect(sent.where((q) => q.isAnswered).map((q) => q.answer), ['a1', 'a3']);
    expect(sent[1].skipped, isTrue);
  });

  test('전부 건너뛰면 생성 요청을 보내지 않고 안내한다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();

    for (var i = 0; i < 3; i++) {
      await vm.skipCurrentQuestion();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    expect(repo.lastGenerateInput, isNull);
    expect(vm.allSkipped, isTrue);
    expect(vm.errorMessage, isNotNull);

    vm.reopenLastQuestion();
    expect(vm.isAllQuestionsDone, isFalse);
    expect(vm.chatList.last.content, 'q3');
  });

  test('생성이 실패하면 error 상태와 메시지, retry로 다시 시도한다', () async {
    repo.generateError = Exception('boom');
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();

    for (var i = 0; i < 3; i++) {
      vm.textController.text = 'a';
      await vm.submitAnswer();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    await settle();
    expect(vm.state, ResultState.error);
    expect(vm.errorMessage, isNotNull);

    repo.generateError = null;
    await vm.retryGenerate();
    expect(vm.state, ResultState.success);
  });

  test('이전 답변을 편집하면 말풍선과 답이 바뀐다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();
    vm.textController.text = 'a1';
    await vm.submitAnswer();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    vm.startEditAnswer(0);
    expect(vm.isEditMode, isTrue);
    expect(vm.textController.text, 'a1');
    vm.textController.text = 'a1-수정';
    await vm.submitAnswer();

    expect(vm.isEditMode, isFalse);
    expect(vm.chatList[1].content, 'a1-수정');
    expect(vm.currentQuestionNumber, 2, reason: '편집은 진행을 바꾸지 않는다');
  });
}
