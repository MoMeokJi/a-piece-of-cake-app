import 'package:cake/data/data_source/shared_preferences/app_prefs_store.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';

class AppPrefsRepositoryImpl implements AppPrefsRepository {
  final AppPrefsStore _store;

  AppPrefsRepositoryImpl(this._store);

  /// 옛 버전부터 쓰던 키. 재설치 감지에 그대로 쓴다.
  static const String installedKey = 'is_app_installed';
  static const String legacyCleanupKey = 'legacy_cleanup_done_v2';
  static const String migrationNoticeKey = 'account_migration_notice_shown';
  static const String pendingNotificationKey = 'pending_notification_opt_in';

  @override
  Future<bool> consumeFreshInstallFlag() async {
    final installed = await _store.getBool(installedKey) ?? false;
    if (installed) return false;
    await _store.setBool(installedKey, true);
    return true;
  }

  @override
  Future<bool> isLegacyCleanupDone() async =>
      await _store.getBool(legacyCleanupKey) ?? false;

  @override
  Future<void> markLegacyCleanupDone() => _store.setBool(legacyCleanupKey, true);

  @override
  Future<bool> hasShownAccountMigrationNotice() async =>
      await _store.getBool(migrationNoticeKey) ?? false;

  @override
  Future<void> markAccountMigrationNoticeShown() =>
      _store.setBool(migrationNoticeKey, true);

  @override
  Future<void> savePendingNotificationOptIn(bool enabled) =>
      _store.setBool(pendingNotificationKey, enabled);

  @override
  Future<bool?> takePendingNotificationOptIn() async {
    final value = await _store.getBool(pendingNotificationKey);
    if (value != null) await _store.remove(pendingNotificationKey);
    return value;
  }
}
