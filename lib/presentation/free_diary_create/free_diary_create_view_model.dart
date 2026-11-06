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

class FreeDiaryCreateViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;
  final DiaryChangeNotifier _diaryChanges;
  final AnalyticsService _analytics;

  FreeDiaryCreateViewModel({
    required DiaryRepository diaryRepo,
    required DiaryChangeNotifier diaryChanges,
    required AnalyticsService analytics,
  }) : _diaryRepo = diaryRepo,
       _diaryChanges = diaryChanges,
       _analytics = analytics {
    attachments.addListener(_onAttachmentsChanged);
    textController.addListener(notifyListeners);
  }

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ImageAttachments attachments = ImageAttachments();

  ResultState _state = ResultState.none;
  ResultState get state => _state;
  bool get isSaving => _state == ResultState.loading;

  DiaryDetail? _completedDiary;
  DiaryDetail? get completedDiary => _completedDiary;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  bool _dailyLimitExceeded = false;
  bool get dailyLimitExceeded => _dailyLimitExceeded;

  bool get hasContent =>
      textController.text.trim().isNotEmpty || attachments.count > 0;
  bool get canComplete =>
      textController.text.trim().length >= ServiceConfig.minDiaryLength &&
      !isSaving;

  void _onAttachmentsChanged() {
    final message = attachments.message;
    if (message != null) {
      attachments.clearMessage();
      _toastMessage = message;
    }
    notifyListeners();
  }

  Future<void> completeDiary() async {
    unfocus();
    final text = textController.text.trim();
    if (text.length < ServiceConfig.minDiaryLength) {
      _toastMessage = '일기는 ${ServiceConfig.minDiaryLength}자 이상 적어 주세요';
      notifyListeners();
      return;
    }
    _state = ResultState.loading;
    notifyListeners();
    try {
      _analytics.logEvent('free_diary_complete');
      _completedDiary = await _diaryRepo.saveDiary(
        diaryType: DiaryType.free,
        text: text,
        images: attachments.images,
      );
      _diaryChanges.notifyChanged();
      _state = ResultState.success;
    } on DiaryDailyLimitExceededException {
      _dailyLimitExceeded = true;
      _state = ResultState.error;
    } catch (e) {
      AppLogger.error('자유 일기 저장 실패: $e');
      _toastMessage = AppErrorMessages.of(e, fallback: AppErrorMessages.saveFailed);
      _state = ResultState.error;
    }
    notifyListeners();
  }

  void unfocus() => focusNode.unfocus();
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
