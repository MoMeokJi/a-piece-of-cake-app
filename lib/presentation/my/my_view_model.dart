import 'package:cake/domain/model/diary_stats.dart';
import 'package:cake/domain/model/user_profile.dart';
import 'package:cake/domain/repository/app_version_repository.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

/// 마이 탭. 탭 전환에도 상태를 유지하므로 lazySingleton.
class MyViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final AuthRepository _authRepo;
  final AppVersionRepository _versionRepo;
  final DiaryChangeNotifier _diaryChanges;
  final AnalyticsService _analytics;

  MyViewModel({
    required UserRepository userRepo,
    required AuthRepository authRepo,
    required AppVersionRepository versionRepo,
    required DiaryChangeNotifier diaryChanges,
    required AnalyticsService analytics,
  }) : _userRepo = userRepo,
       _authRepo = authRepo,
       _versionRepo = versionRepo,
       _diaryChanges = diaryChanges,
       _analytics = analytics {
    _diaryChanges.addListener(_loadStats);
    refresh();
  }

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  DiaryStats? _stats;
  DiaryStats? get stats => _stats;

  String _version = '';
  String get version => _version;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _notificationUpdating = false;
  bool get notificationUpdating => _notificationUpdating;

  /// 로그아웃·탈퇴가 끝나면 true. 화면이 로그인으로 보낸다.
  bool _signedOut = false;
  bool get signedOut => _signedOut;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  Future<void> refresh() async {
    await Future.wait([_loadProfile(), _loadStats(), _loadVersion()]);
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _userRepo.getMe();
    } catch (e) {
      AppLogger.error('프로필 조회 실패: $e');
    }
    notifyListeners();
  }

  Future<void> _loadStats() async {
    try {
      _stats = await _userRepo.getStats();
    } catch (e) {
      AppLogger.error('통계 조회 실패: $e');
    }
    notifyListeners();
  }

  Future<void> _loadVersion() async {
    try {
      _version = await _versionRepo.getCurrentVersion();
    } catch (_) {
      _version = '';
    }
    notifyListeners();
  }

  void applyNickname(String nickname) {
    _profile = _profile?.copyWith(nickname: nickname);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final before = _profile;
    if (before == null || _notificationUpdating) return;
    _notificationUpdating = true;
    _profile = before.copyWith(notificationEnabled: enabled);
    notifyListeners();
    try {
      final applied = await _userRepo.updateNotification(enabled);
      _profile = before.copyWith(notificationEnabled: applied);
    } catch (e) {
      AppLogger.error('알림 설정 실패: $e');
      _profile = before;
      _toastMessage = AppErrorMessages.of(e);
    } finally {
      _notificationUpdating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _analytics.logEvent('logout');
      await _authRepo.logout();
      _signedOut = true;
    } catch (e) {
      AppLogger.error('로그아웃 실패: $e');
      _toastMessage = AppErrorMessages.of(e);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> withdraw() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _analytics.logEvent('account_delete');
      await _userRepo.withdraw();
      _signedOut = true;
    } catch (e) {
      AppLogger.error('탈퇴 실패: $e');
      _toastMessage = AppErrorMessages.of(
        e,
        fallback: '탈퇴하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void clearToast() => _toastMessage = null;

  @override
  void dispose() {
    _diaryChanges.removeListener(_loadStats);
    super.dispose();
  }
}
