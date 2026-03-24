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
  int? _editingQnaIndex;
  String _generatedDiary = '';

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  ResultState get state => _resultState;
  List<ChatListItem> get chatList => List.unmodifiable(_chatList);
  TextEditingController get textController => _textController;
  FocusNode get focusNode => _focusNode;
  ScrollController get scrollController => _scrollController;
  String get generatedDiary => _generatedDiary;
  bool get isEditMode => _editingQnaIndex != null;

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

  // 이전 답변 편집 시작
  void startEditAnswer(int qnaIndex) {
    if (_resultState == ResultState.loading) return;
    _editingQnaIndex = qnaIndex;
    _textController.text = _qnaList[qnaIndex].answer;
    _focusNode.requestFocus();
    notifyListeners();
  }

  // 편집 취소
  void cancelEditAnswer() {
    _editingQnaIndex = null;
    _textController.clear();
    unfocusKeyboard();
    notifyListeners();
  }

  // 답변 전송 (편집 모드 / 일반 모드 분기)
  Future<void> saveAnswer() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (isEditMode) {
      _applyEditedAnswer(text);
      return;
    }

    // 모든 질문에 답변 완료 상태에서 호출되면 재시도로 처리
    if (isAllQuestionsAnswered) {
      if (_resultState != ResultState.loading) {
        await _submitToServer();
      }
      return;
    }

    _chatList.add(ChatListItem.user(text, qnaIndex: _currentQnaIndex));
    _qnaList[_currentQnaIndex] = _qnaList[_currentQnaIndex].copyWith(
      answer: text,
    );
    _currentQnaIndex++;

    _textController.clear();
    notifyListeners();
    _scrollToBottom();

    await _addNextQuestion();
  }

  void _applyEditedAnswer(String text) {
    final idx = _editingQnaIndex!;
    _qnaList[idx] = _qnaList[idx].copyWith(answer: text);

    final chatIdx = _chatList.indexWhere((item) => item.qnaIndex == idx);
    if (chatIdx != -1) {
      _chatList[chatIdx] = ChatListItem.user(text, qnaIndex: idx);
    }

    _editingQnaIndex = null;
    _textController.clear();
    unfocusKeyboard();
    notifyListeners();
  }

  Future<void> _addNextQuestion() async {
    if (isAllQuestionsAnswered) {
      unfocusKeyboard();
      await _submitToServer();
      return;
    }

    await Future.delayed(Duration(milliseconds: 200));
    _chatList.add(ChatListItem.bot(_qnaList[_currentQnaIndex].question));
    notifyListeners();
    _scrollToBottom();
  }

  // API 재시도 (에러 상태에서 호출)
  Future<void> retrySubmit() async {
    if (!isAllQuestionsAnswered || _resultState == ResultState.loading) return;
    await _submitToServer();
  }

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
