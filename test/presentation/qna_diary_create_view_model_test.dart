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

  test('끝까지 답하면 전 문항을 모아 생성한다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();

    for (final answer in ['a1', 'a2', 'a3']) {
      vm.textController.text = answer;
      await vm.submitAnswer();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    await settle();

    expect(vm.state, ResultState.success);
    expect(vm.generatedDiary, '생성된 일기');
    expect(repo.lastGenerateInput!.map((q) => q.answer), ['a1', 'a2', 'a3']);
  });

  test('여분이 없으면 건너뛰기는 안내만 하고 진행하지 않는다', () async {
    final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
    await settle();
    expect(vm.canSkip, isTrue, reason: '선택 문항이라 버튼은 보인다');

    vm.skipCurrentQuestion();

    expect(vm.infoMessage, QnaDiaryCreateViewModel.noMoreSkipMessage);
    expect(vm.currentQuestionNumber, 1);
    expect(vm.chatList.single.content, 'q1');
    expect(repo.lastGenerateInput, isNull);
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

  group('건너뛰기 교체', () {
    setUp(() {
      repo
        ..questions = const [
          Qna(id: 1, question: '필수1', answer: '', required: true),
          Qna(id: 2, question: '필수2', answer: '', required: true),
          Qna(id: 3, question: '선택1', answer: ''),
          Qna(id: 4, question: '선택2', answer: ''),
        ]
        ..optionalSpares = ['여분1'];
    });

    Future<QnaDiaryCreateViewModel> answerRequired() async {
      final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
      await settle();
      for (var i = 0; i < 2; i++) {
        vm.textController.text = '답$i';
        await vm.submitAnswer();
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      return vm;
    }

    test('필수 질문은 건너뛸 수 없다', () async {
      final vm = QnaDiaryCreateViewModel(diaryRepo: repo);
      await settle();

      expect(vm.canSkip, isFalse);
      vm.skipCurrentQuestion();

      expect(vm.currentQuestionNumber, 1);
      expect(vm.chatList.single.content, '필수1');
    });

    test('선택 질문을 건너뛰면 여분이 같은 자리·같은 말풍선에 들어간다', () async {
      final vm = await answerRequired();
      expect(vm.chatList.last.content, '선택1');
      final bubbleCount = vm.chatList.length;
      expect(vm.canSkip, isTrue);

      vm.skipCurrentQuestion();

      expect(vm.chatList.length, bubbleCount, reason: '말풍선을 더 쌓지 않는다');
      expect(vm.chatList.last.content, '여분1');
      expect(vm.currentQuestionNumber, 3, reason: '진행 번호는 그대로');
      expect(vm.spareCount, 0);
    });

    test('여분이 떨어진 뒤 건너뛰면 토스트 안내만 하고 질문은 그대로다', () async {
      final vm = await answerRequired();
      vm.skipCurrentQuestion(); // 선택1 → 여분1
      final bubbleCount = vm.chatList.length;

      vm.skipCurrentQuestion(); // 여분 없음

      expect(vm.infoMessage, QnaDiaryCreateViewModel.noMoreSkipMessage);
      expect(vm.chatList.length, bubbleCount);
      expect(vm.chatList.last.content, '여분1');
      expect(vm.currentQuestionNumber, 3);
    });

    test('교체된 질문 문구로 답을 보낸다', () async {
      final vm = await answerRequired();
      vm.skipCurrentQuestion(); // 선택1 → 여분1

      vm.textController.text = '여분답';
      await vm.submitAnswer();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      vm.textController.text = '마지막답';
      await vm.submitAnswer();
      await settle();

      expect(vm.state, ResultState.success);
      final sent = repo.lastGenerateInput!;
      expect(sent.map((q) => q.question), ['필수1', '필수2', '여분1', '선택2']);
      expect(sent[2].answer, '여분답');
    });
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
