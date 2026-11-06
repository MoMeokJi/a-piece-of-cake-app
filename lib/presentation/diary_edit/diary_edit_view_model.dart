import 'package:cake/config/service_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// A-5-2 본문 수정. 서버 PATCH는 본문만 받는다 — 사진은 보여주기만 한다.
class DiaryEditViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;
  final DiaryChangeNotifier _diaryChanges;
  final AnalyticsService _analytics;
  final DiaryDetail diary;

  DiaryEditViewModel({
    required DiaryRepository diaryRepo,
    required DiaryChangeNotifier diaryChanges,
    required AnalyticsService analytics,
    required this.diary,
  }) : _diaryRepo = diaryRepo,
       _diaryChanges = diaryChanges,
       _analytics = analytics {
    textController = TextEditingController(text: diary.body);
    textController.addListener(notifyListeners);
  }

  late final TextEditingController textController;
  final FocusNode focusNode = FocusNode();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _savedBody;
  String? get savedBody => _savedBody;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  bool get isModified => textController.text.trim() != diary.body.trim();
  bool get canSave =>
      isModified &&
      textController.text.trim().length >= ServiceConfig.minDiaryLength &&
      !_isSaving;

  Future<void> save() async {
    if (!canSave) return;
    focusNode.unfocus();
    _isSaving = true;
    notifyListeners();
    final text = textController.text.trim();
    try {
      _analytics.logEvent('diary_detail_edit');
      await _diaryRepo.editDiaryText(id: diary.id, editText: text);
      _diaryChanges.notifyChanged();
      _savedBody = text;
    } catch (e) {
      AppLogger.error('일기 수정 실패: $e');
      _toastMessage = AppErrorMessages.of(e, fallback: AppErrorMessages.editFailed);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearToast() => _toastMessage = null;

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
