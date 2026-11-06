import 'package:cake/config/service_config.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/presentation/common/image_attachments.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// A-13 문답 일기 확인. 생성된 본문을 읽고, 필요하면 직접 다듬은 뒤 확정한다.
class QnaDiaryConfirmViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;
  final DiaryChangeNotifier _diaryChanges;
  final AnalyticsService _analytics;

  QnaDiaryConfirmViewModel({
    required DiaryRepository diaryRepo,
    required DiaryChangeNotifier diaryChanges,
    required AnalyticsService analytics,
    required String initialContent,
  }) : _diaryRepo = diaryRepo,
       _diaryChanges = diaryChanges,
       _analytics = analytics {
    textController = TextEditingController(text: initialContent);
    textController.addListener(notifyListeners);
    attachments.addListener(_onAttachmentsChanged);
    _analytics.logEvent('qna_diary_initial_generation');
  }

  late final TextEditingController textController;
  final FocusNode focusNode = FocusNode();
  final ImageAttachments attachments = ImageAttachments();

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  ResultState _state = ResultState.none;
  ResultState get state => _state;
  bool get isSaving => _state == ResultState.loading;

  DiaryDetail? _completedDiary;
  DiaryDetail? get completedDiary => _completedDiary;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  bool _dailyLimitExceeded = false;
  bool get dailyLimitExceeded => _dailyLimitExceeded;

  String get content => textController.text;
  bool get canComplete =>
      content.trim().length >= ServiceConfig.minDiaryLength && !isSaving;

  void startEditing() {
    _isEditing = true;
    _analytics.logEvent('qna_diary_user_edit_mode');
    notifyListeners();
    focusNode.requestFocus();
  }

  void finishEditing() {
    focusNode.unfocus();
    _isEditing = false;
    notifyListeners();
  }

  void _onAttachmentsChanged() {
    final message = attachments.message;
    if (message != null) {
      attachments.clearMessage();
      _toastMessage = message;
    }
    notifyListeners();
  }

  Future<void> completeDiary() async {
    focusNode.unfocus();
    final text = content.trim();
    if (text.length < ServiceConfig.minDiaryLength) {
      _toastMessage = '일기는 ${ServiceConfig.minDiaryLength}자 이상 적어 주세요';
      notifyListeners();
      return;
    }
    _state = ResultState.loading;
    notifyListeners();
    try {
      _analytics.logEvent('qna_diary_complete');
      _completedDiary = await _diaryRepo.saveDiary(
        diaryType: DiaryType.qna,
        text: text,
        images: attachments.images,
      );
      _diaryChanges.notifyChanged();
      _state = ResultState.success;
    } on DiaryDailyLimitExceededException {
      _dailyLimitExceeded = true;
      _state = ResultState.error;
    } catch (e) {
      AppLogger.error('문답 일기 확정 실패: $e');
      _toastMessage = AppErrorMessages.of(e, fallback: AppErrorMessages.saveFailed);
      _state = ResultState.error;
    }
    notifyListeners();
  }

  void clearToast() => _toastMessage = null;
  void clearDailyLimit() => _dailyLimitExceeded = false;
  void consumeSuccess() => _state = ResultState.none;

  @override
  void dispose() {
    attachments.removeListener(_onAttachmentsChanged);
    attachments.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
