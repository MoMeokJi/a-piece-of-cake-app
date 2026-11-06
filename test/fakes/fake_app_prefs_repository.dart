import 'package:cake/domain/repository/app_prefs_repository.dart';

class FakeAppPrefsRepository implements AppPrefsRepository {
  bool freshInstall = false;
  bool legacyCleanupDone = true;
  bool migrationNoticeShown = false;
  bool? pendingNotificationOptIn;

  @override
  Future<bool> consumeFreshInstallFlag() async {
    final value = freshInstall;
    freshInstall = false;
    return value;
  }

  @override
  Future<bool> isLegacyCleanupDone() async => legacyCleanupDone;

  @override
  Future<void> markLegacyCleanupDone() async => legacyCleanupDone = true;

  @override
  Future<bool> hasShownAccountMigrationNotice() async => migrationNoticeShown;

  @override
  Future<void> markAccountMigrationNoticeShown() async =>
      migrationNoticeShown = true;

  @override
  Future<void> savePendingNotificationOptIn(bool enabled) async =>
      pendingNotificationOptIn = enabled;

  @override
  Future<bool?> takePendingNotificationOptIn() async {
    final value = pendingNotificationOptIn;
    pendingNotificationOptIn = null;
    return value;
  }
}
