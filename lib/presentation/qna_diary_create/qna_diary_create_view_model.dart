import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// 문답 일기 (A-4). 질문을 하나씩 던지고, 답하거나 건너뛴다.
/// 마지막 문항이 끝나면 답한 문항만 모아 서버에 일기 생성을 요청한다.
class QnaDiaryCreateViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;

  QnaDiaryCreateViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo {
    _initialize();
  }

  ResultState _state = ResultState.none;
  ResultState get state => _state;
  bool get isGenerating => _state == ResultState.loading;

  List<Qna> _qnaList = [];
  final List<ChatListItem> _chatList = [];
  int _currentIndex = 0;
  int? _editingIndex;
  String _generatedDiary = '';
  String? _errorMessage;

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  List<ChatListItem> get chatList => List.unmodifiable(_chatList);
  String get generatedDiary => _generatedDiary;
  bool get isEditMode => _editingIndex != null;
  String? get errorMessage => _errorMessage;

  int get totalQuestions => _qnaList.length;

  /// 진행 표시 "3/5": 현재 답하는 문항 번호
  int get currentQuestionNumber =>
      _qnaList.isEmpty ? 0 : (_currentIndex + 1).clamp(1, _qnaList.length);
  double get progress =>
      _qnaList.isEmpty ? 0 : _currentIndex / _qnaList.length;

  bool get isAllQuestionsDone => _currentIndex >= _qnaList.length;

  /// 현재 문항을 건너뛸 수 있는가 (질문이 떠 있고 편집 중이 아닐 때)
  bool get canSkip => !isAllQuestionsDone && !isEditMode && !isGenerating;

  int get answeredCount => _qnaList.where((q) => q.isAnswered).length;

  Future<void> _initialize() async {
    try {
      _qnaList = List.of(await _diaryRepo.getQuestionList());
      if (_qnaList.isEmpty) {
        _errorMessage = '질문을 불러오지 못했어요.';
      } else {
        _chatList.add(ChatListItem.bot(_qnaList[0].question));
      }
      focusNode.addListener(_onFocusChange);
    } catch (e) {
      AppLogger.error('질문 조회 실패: $e');
      _errorMessage = AppErrorMessages.of(e, fallback: '질문을 불러오지 못했어요.');
    }
    notifyListeners();
  }

  void startEditAnswer(int qnaIndex) {
    if (isGenerating) return;
    _editingIndex = qnaIndex;
    textController.text = _qnaList[qnaIndex].answer;
    focusNode.requestFocus();
    notifyListeners();
  }

  void cancelEditAnswer() {
    _editingIndex = null;
    textController.clear();
    unfocusKeyboard();
    notifyListeners();
  }

  Future<void> submitAnswer() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    if (isEditMode) {
      _applyEditedAnswer(text);
      return;
    }
    if (isAllQuestionsDone) {
      await _generate();
      return;
    }

    _chatList.add(ChatListItem.user(text, qnaIndex: _currentIndex));
    _qnaList[_currentIndex] = _qnaList[_currentIndex].copyWith(answer: text);
    _currentIndex++;
    textController.clear();
    notifyListeners();
    _scrollToBottom();
    await _advance();
  }

  /// "이 질문 건너뛰기". 답하지 않은 문항은 서버에 보내지 않는다.
  Future<void> skipCurrentQuestion() async {
    if (!canSkip) return;
    _qnaList[_currentIndex] = _qnaList[_currentIndex].copyWith(skipped: true);
    _currentIndex++;
    notifyListeners();
    await _advance();
  }

  void _applyEditedAnswer(String text) {
    final idx = _editingIndex!;
    _qnaList[idx] = _qnaList[idx].copyWith(answer: text, skipped: false);
    final chatIdx = _chatList.indexWhere((item) => item.qnaIndex == idx);
    if (chatIdx != -1) {
      _chatList[chatIdx] = ChatListItem.user(text, qnaIndex: idx);
    }
    _editingIndex = null;
    textController.clear();
    unfocusKeyboard();
    notifyListeners();
  }

  Future<void> _advance() async {
    if (isAllQuestionsDone) {
      unfocusKeyboard();
      await _generate();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _chatList.add(ChatListItem.bot(_qnaList[_currentIndex].question));
    notifyListeners();
    _scrollToBottom();
  }

  /// 전부 건너뛰었으면 생성 요청을 보내지 않고 안내한다.
  bool get allSkipped => isAllQuestionsDone && answeredCount == 0;

  Future<void> _generate() async {
    if (allSkipped) {
      _state = ResultState.error;
      _errorMessage = '답한 질문이 하나도 없어요. 하나 이상 답해 주세요.';
      notifyListeners();
      return;
    }
    _state = ResultState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _generatedDiary = await _diaryRepo.generateQnaDiary(qnaList: _qnaList);
      _state = ResultState.success;
    } catch (e) {
      AppLogger.error('일기 생성 실패: $e');
      _errorMessage = AppErrorMessages.of(
        e,
        fallback: AppErrorMessages.generateFailed,
      );
      _state = ResultState.error;
    }
    notifyListeners();
  }

  Future<void> retryGenerate() async {
    if (!isAllQuestionsDone || isGenerating) return;
    await _generate();
  }

  /// 전부 건너뛴 상태에서 다시 답하고 싶을 때: 마지막 문항으로 되돌린다.
  void reopenLastQuestion() {
    if (_qnaList.isEmpty) return;
    _currentIndex = _qnaList.length - 1;
    _qnaList[_currentIndex] = _qnaList[_currentIndex].copyWith(skipped: false);
    _state = ResultState.none;
    _errorMessage = null;
    _chatList.add(ChatListItem.bot(_qnaList[_currentIndex].question));
    notifyListeners();
    _scrollToBottom();
  }

  void clearError() => _errorMessage = null;

  void consumeSuccess() => _state = ResultState.none;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void unfocusKeyboard() => focusNode.unfocus();

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 400), _scrollToBottom);
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
