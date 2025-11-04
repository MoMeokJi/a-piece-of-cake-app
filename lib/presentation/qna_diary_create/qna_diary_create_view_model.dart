import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:flutter/material.dart';

class QnaDiaryCreateViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  QnaDiaryCreateViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo {
    _initialize();
  }

  ResultState _resultState = ResultState.none;

  List<Qna> _qnaList = [];

  final List<ChatListItem> _chatList = [ChatListItem.bot('...')];

  int _currentChatIndex = 0;
  int _currentQnaIndex = 0;

  final TextEditingController _textController = TextEditingController();

  ResultState get state => _resultState;
  List<ChatListItem> get chatList => _chatList;

  TextEditingController get textController => _textController;

  // 모든 질문 완료 여부
  bool get isAllQuestionsAnswered => _currentQnaIndex >= _qnaList.length;

  Future<void> _initialize() async {
    try {
      _qnaList = await _diaryRepo.getQuestionList();
      _chatList[_currentChatIndex] = _chatList[_currentChatIndex].copyWith(
        content: _qnaList[_currentQnaIndex].question,
      );
    } catch (e) {
      _resultState = ResultState.error;
    }
    notifyListeners();
  }

  // 답변 전송
  Future<void> saveAnswer() async {
    // chatList추가
    _chatList.add(ChatListItem.user(_textController.text));
    _currentChatIndex++;

    // 현재 질문에 답변 저장
    _qnaList[_currentQnaIndex] = _qnaList[_currentQnaIndex].copyWith(
      answer: _textController.text.trim(),
    );
    _currentQnaIndex++;

    // 텍스트필드 초기화
    _textController.clear();
    notifyListeners();

    await _addNextQuestion();
  }

  Future<void> _addNextQuestion() async {
    // 마지막 질문이면
    if (isAllQuestionsAnswered) {
      _chatList.add(ChatListItem.bot('모든 질문에 답변을 완료했어요! 잠시만 기다려주세요 😀'));
      _currentChatIndex++;
      notifyListeners();

      await _submitToServer();
      return;
    }
    _chatList.add(ChatListItem.bot('...'));
    _currentChatIndex++;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 500));
    _chatList[_currentChatIndex] = _chatList[_currentChatIndex].copyWith(
      content: _qnaList[_currentQnaIndex].question,
    );
    notifyListeners();
  }

  // 서버로 전송
  Future<void> _submitToServer() async {
    try {
      _resultState = ResultState.loading;
      notifyListeners();

      String content = await _diaryRepo.generateQnaDiary(qnaList: _qnaList);

      _resultState = ResultState.success;
      notifyListeners();

      // 성공 후 처리 (예: 화면 이동)
    } catch (e) {
      _resultState = ResultState.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
