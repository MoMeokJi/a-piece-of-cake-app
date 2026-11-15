import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/model/question_set.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// 문답 일기 (A-4). 질문을 하나씩 던지고, 답하거나 건너뛴다.
/// 마지막 문항이 끝나면 답한 문항만 모아 서버에 일기 생성을 요청한다.
///
/// 건너뛰기 규칙: 필수 문항은 건너뛸 수 없다. 선택 문항을 건너뛰면 여분 질문
/// ([QuestionSet.optionalSpares])을 앞에서부터 꺼내 **같은 자리**에 넣는다 (말풍선을
/// 더 쌓지 않고 지금 떠 있는 질문 말풍선을 바꾼다). 여분이 다 떨어지면 더는 건너뛸 수
/// 없다고 안내하고 그 질문에 답하게 한다. 그래서 생성 요청엔 항상 전 문항의 답이 간다.
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
  final List<String> _spares = [];
  final List<ChatListItem> _chatList = [];
  int _currentIndex = 0;
  int? _editingIndex;
  String _generatedDiary = '';
  String? _errorMessage;
  String? _infoMessage;

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  List<ChatListItem> get chatList => List.unmodifiable(_chatList);
  String get generatedDiary => _generatedDiary;
  bool get isEditMode => _editingIndex != null;
  String? get errorMessage => _errorMessage;

  /// 에러는 아닌 안내 (예: 더는 건너뛸 수 없음). 화면이 토스트로 띄우고 [clearInfo]한다.
  String? get infoMessage => _infoMessage;

  int get totalQuestions => _qnaList.length;

  /// 진행 표시 "3/5": 현재 답하는 문항 번호
  int get currentQuestionNumber =>
      _qnaList.isEmpty ? 0 : (_currentIndex + 1).clamp(1, _qnaList.length);
  double get progress =>
      _qnaList.isEmpty ? 0 : _currentIndex / _qnaList.length;

  bool get isAllQuestionsDone => _currentIndex >= _qnaList.length;

  /// 현재 문항을 건너뛸 수 있는가 (선택 문항이 떠 있고 편집 중이 아닐 때)
  bool get canSkip =>
      !isAllQuestionsDone &&
      !isEditMode &&
      !isGenerating &&
      !_qnaList[_currentIndex].required;

  /// 남은 여분 질문 수
  int get spareCount => _spares.length;

  int get answeredCount => _qnaList.where((q) => q.isAnswered).length;

  Future<void> _initialize() async {
    try {
      final set = await _diaryRepo.getQuestionSet();
      _qnaList = List.of(set.questions);
      _spares
        ..clear()
        ..addAll(set.optionalSpares);
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

  static const String noMoreSkipMessage = '더 이상 건너뛸 수 없어요. 이 질문엔 답해 주세요.';

  /// "이 질문 건너뛰기". 여분이 있으면 같은 자리를 새 질문으로 바꾸고, 없으면 안내만 한다.
  void skipCurrentQuestion() {
    if (!canSkip) return;
    if (_spares.isEmpty) {
      _infoMessage = noMoreSkipMessage;
      notifyListeners();
      return;
    }
    final spare = _spares.removeAt(0);
    _qnaList[_currentIndex] = _qnaList[_currentIndex].copyWith(
      question: spare,
      answer: '',
    );
    // 건너뛸 수 있는 상태면 마지막 말풍선은 항상 현재 문항의 봇 말풍선이다
    // (답을 달면 더 이상 건너뛸 수 없으므로). 그걸 새 질문으로 바꾼다.
    if (_chatList.isNotEmpty && !_chatList.last.isUser) _chatList.removeLast();
    _chatList.add(ChatListItem.bot(spare));
    notifyListeners();
    _scrollToBottom();
  }

  void _applyEditedAnswer(String text) {
    final idx = _editingIndex!;
    _qnaList[idx] = _qnaList[idx].copyWith(answer: text);
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

  Future<void> _generate() async {
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

  void clearError() => _errorMessage = null;

  void clearInfo() => _infoMessage = null;

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
