import 'package:cake/domain/enum/result_state.dart';
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
  ResultState get state => _resultState;

  List<Qna> _qnaList = [];
  List<Qna> get qnaList => _qnaList;

  final TextEditingController _textController = TextEditingController();
  TextEditingController get textController => _textController;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  bool _isTyping = false; // "..." 애니메이션 표시 여부
  bool get isTyping => _isTyping;

  bool _showCompletionMessage = false; // 완료 메시지 표시 여부
  bool get showCompletionMessage => _showCompletionMessage;

  // 현재 보여줄 질문들 (이미 답변한 것들 + 현재 질문)
  List<Qna> get displayedQnaList {
    if (_currentQuestionIndex < _qnaList.length) {
      return _qnaList.sublist(0, _currentQuestionIndex + 1);
    }
    return _qnaList;
  }

  // 전송 버튼 활성화 여부
  bool get canSend =>
      _textController.text.trim().isNotEmpty &&
      !_isTyping &&
      _currentQuestionIndex < _qnaList.length;

  // 모든 질문 완료 여부
  bool get isAllQuestionsAnswered => _currentQuestionIndex >= _qnaList.length;

  Future<void> _initialize() async {
    try {
      _qnaList = await _diaryRepo.getQuestionList();
      _resultState = ResultState.success;
    } catch (e) {
      _resultState = ResultState.error;
    }
    notifyListeners();
  }

  // 답변 전송
  Future<void> saveAnswer() async {
    if (!canSend) return;

    // 현재 질문에 답변 저장
    _qnaList[_currentQuestionIndex] = _qnaList[_currentQuestionIndex].copyWith(
      answer: _textController.text.trim(),
    );

    // 텍스트필드 초기화
    _textController.clear();
    notifyListeners();

    // "..." 타이핑 표시
    _isTyping = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    _isTyping = false;

    // 다음 질문으로 이동
    _currentQuestionIndex++;

    // 마지막 질문이면
    if (isAllQuestionsAnswered) {
      _showCompletionMessage = true;
      notifyListeners();

      // 완료 메시지 보여주고 서버 전송
      await _submitToServer();
    }

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
