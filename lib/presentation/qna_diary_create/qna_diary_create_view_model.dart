import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class QnaDiaryCreateViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  QnaDiaryCreateViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo {
    _initialize();
  }

  ResultState _resultState = ResultState.none;
  List<Qna> _qnaList = [];
  final List<ChatListItem> _chatList = [];
  int _currentQnaIndex = 0;
  String _generatedDiary = '';

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  ResultState get state => _resultState;
  List<ChatListItem> get chatList => _chatList;
  TextEditingController get textController => _textController;
  FocusNode get focusNode => _focusNode;
  ScrollController get scrollController => _scrollController;
  String get generatedDiary => _generatedDiary;

  bool get isAllQuestionsAnswered => _currentQnaIndex >= _qnaList.length;

  Future<void> _initialize() async {
    try {
      _qnaList = await _diaryRepo.getQuestionList();
      _chatList.add(ChatListItem.bot(_qnaList[_currentQnaIndex].question));

      _focusNode.addListener(_onFocusChange);
    } catch (e) {
      _resultState = ResultState.error;
    }
    notifyListeners();
  }

  // 답변 전송
  Future<void> saveAnswer() async {
    _chatList.add(ChatListItem.user(_textController.text));

    _qnaList[_currentQnaIndex] = _qnaList[_currentQnaIndex].copyWith(
      answer: _textController.text.trim(),
    );
    _currentQnaIndex++;

    _textController.clear();
    notifyListeners();

    // 유저 메시지 추가 후 스크롤
    _scrollToBottom();

    await _addNextQuestion();
  }

  Future<void> _addNextQuestion() async {
    if (isAllQuestionsAnswered) {
      unfocusKeyboard();
      await _submitToServer();
      return;
    }

    // 다음 질문 추가하기 전 살짝 딜레이
    await Future.delayed(Duration(milliseconds: 200));
    _chatList.add(ChatListItem.bot(_qnaList[_currentQnaIndex].question));
    notifyListeners();

    // 봇 메시지 추가 후 스크롤
    _scrollToBottom();
  }

  // 스크롤 맨 아래로
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 키보드 닫기
  void unfocusKeyboard() {
    _focusNode.unfocus();
  }

  Future<void> _submitToServer() async {
    try {
      _resultState = ResultState.loading;
      notifyListeners();

      _generatedDiary = await _diaryRepo.generateQnaDiary(qnaList: _qnaList);
      AppLogger.log(_generatedDiary);

      _resultState = ResultState.success;
      notifyListeners();
    } catch (e) {
      _resultState = ResultState.error;
      notifyListeners();
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // 키보드가 완전히 올라온 후 스크롤
      Future.delayed(Duration(milliseconds: 500), () {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
