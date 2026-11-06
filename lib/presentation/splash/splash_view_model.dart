import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/domain/model/app_version_info.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';
import 'package:cake/domain/repository/app_version_repository.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/service/legacy_data_cleanup_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:cake/utils/version_compare.dart';
import 'package:flutter/foundation.dart';

class SplashViewModel extends ChangeNotifier {
  final AppVersionRepository _versionRepo;
  final AuthRepository _authRepo;
  final AppPrefsRepository _prefsRepo;
  final LegacyDataCleanupService _legacyCleanup;

  /// 테스트에서 0으로 줄인다.
  final Duration minimumDuration;

  SplashViewModel({
    required AppVersionRepository versionRepo,
    required AuthRepository authRepo,
    required AppPrefsRepository prefsRepo,
    required LegacyDataCleanupService legacyCleanup,
    this.minimumDuration = const Duration(milliseconds: 1200),
  }) : _versionRepo = versionRepo,
       _authRepo = authRepo,
       _prefsRepo = prefsRepo,
       _legacyCleanup = legacyCleanup {
    _init();
  }

  AppInitState _state = AppInitState.initializing;
  AppInitState get state => _state;

  AppVersionInfo? _versionInfo;
  AppVersionInfo? get versionInfo => _versionInfo;

  Future<void> _init() async {
    final startTime = DateTime.now();
    try {
      // 1. 최소 버전
      final info = await _versionRepo.getVersionInfo();
      if (info != null) {
        final current = await _versionRepo.getCurrentVersion();
        if (compareVersions(current, info.minVersion) < 0) {
          _versionInfo = info;
          await _ensureMinimumDelay(startTime);
          _set(AppInitState.forceUpdate);
          return;
        }
      }

      // 2. deviceId 시절 데이터 정리 (업데이트 후 첫 실행 한 번)
      if (!await _prefsRepo.isLegacyCleanupDone()) {
        final hadLegacySession = await _authRepo.hasSession();
        await _legacyCleanup.cleanup();
        await _prefsRepo.markLegacyCleanupDone();
        if (hadLegacySession &&
            !await _prefsRepo.hasShownAccountMigrationNotice()) {
          await _ensureMinimumDelay(startTime);
          _set(AppInitState.showAccountMigrationNotice);
          return;
        }
      }

      // 3. 세션 유무로 분기
      await _ensureMinimumDelay(startTime);
      await _navigateBySession();
    } catch (e, stackTrace) {
      AppLogger.error('SplashViewModel init error: $e\n$stackTrace');
      _set(AppInitState.navigateToLogin);
    }
  }

  Future<void> _navigateBySession() async {
    final hasSession = await _authRepo.hasSession();
    AppLogger.log('Session check - hasSession: $hasSession');
    if (hasSession) {
      // 실패해도 진행을 막지 않는다.
      await _authRepo.registerFcmToken();
    }
    _set(hasSession ? AppInitState.navigateToHome : AppInitState.navigateToLogin);
  }

  /// 계정 방식 변경 안내를 닫았을 때
  Future<void> acknowledgeMigrationNotice() async {
    await _prefsRepo.markAccountMigrationNoticeShown();
    _set(AppInitState.navigateToLogin);
  }

  Future<void> openStore() => _versionRepo.openStore(_versionInfo?.storeUrl);

  Future<void> _ensureMinimumDelay(DateTime startTime) async {
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minimumDuration) {
      await Future.delayed(minimumDuration - elapsed);
    }
  }

  void _set(AppInitState state) {
    _state = state;
    notifyListeners();
  }
}
