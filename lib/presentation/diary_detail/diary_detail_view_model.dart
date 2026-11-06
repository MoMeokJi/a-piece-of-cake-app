import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class DiaryDetailViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;
  final DiaryChangeNotifier _diaryChanges;
  final AnalyticsService _analytics;

  DiaryDetailViewModel({
    required DiaryRepository diaryRepo,
    required DiaryChangeNotifier diaryChanges,
    required AnalyticsService analytics,
  }) : _diaryRepo = diaryRepo,
       _diaryChanges = diaryChanges,
       _analytics = analytics;

  DiaryDetail? _diary;
  DiaryDetail? get diary => _diary;

  ResultState _loadState = ResultState.loading;
  ResultState get loadState => _loadState;
  bool get isLoading => _loadState == ResultState.loading;
  bool get loadFailed => _loadState == ResultState.error;
  bool get notFound => _notFound;
  bool _notFound = false;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  bool _deleted = false;
  bool get deleted => _deleted;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  /// 유튜브를 못 불러왔을 때 "다시 시도"로 플레이어를 다시 만든다.
  int _playerAttempt = 0;
  int get playerAttempt => _playerAttempt;

  int? _id;

  Future<void> initialize(DiaryDetail? detail, int? id) async {
    if (detail != null) {
      _diary = detail;
      _id = detail.id;
      _loadState = ResultState.success;
      notifyListeners();
      return;
    }
    if (id == null) {
      _loadState = ResultState.error;
      notifyListeners();
      return;
    }
    _id = id;
    await reload();
  }

  Future<void> reload() async {
    final id = _id;
    if (id == null) return;
    _loadState = ResultState.loading;
    notifyListeners();
    try {
      _diary = await _diaryRepo.getDiary(id: id);
      _loadState = ResultState.success;
    } on DiaryNotFoundException {
      _notFound = true;
      _loadState = ResultState.error;
    } catch (e) {
      AppLogger.error('일기 상세 조회 실패: $e');
      _loadState = ResultState.error;
    }
    notifyListeners();
  }

  void applyEditedBody(String body) {
    _diary = _diary?.copyWith(body: body);
    notifyListeners();
  }

  Future<void> removeDiary() async {
    final diary = _diary;
    if (diary == null || _isDeleting) return;
    _isDeleting = true;
    notifyListeners();
    try {
      _analytics.logEvent('diary_detail_delete');
      await _diaryRepo.removeDiary(diary.id);
      _diaryChanges.notifyChanged();
      _deleted = true;
    } catch (e) {
      AppLogger.error('일기 삭제 실패: $e');
      _toastMessage = AppErrorMessages.of(e, fallback: AppErrorMessages.deleteFailed);
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void retryPlayer() {
    _playerAttempt++;
    notifyListeners();
  }

  void clearToast() => _toastMessage = null;
}
