import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/domain/model/app_version_info.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_app_prefs_repository.dart';
import '../../fakes/fake_app_version_repository.dart';
import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_legacy_data_cleanup_service.dart';

Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeAppVersionRepository versionRepo;
  late FakeAuthRepository authRepo;
  late FakeAppPrefsRepository prefsRepo;
  late FakeLegacyDataCleanupService cleanup;

  setUp(() {
    versionRepo = FakeAppVersionRepository();
    authRepo = FakeAuthRepository();
    prefsRepo = FakeAppPrefsRepository();
    cleanup = FakeLegacyDataCleanupService();
  });

  SplashViewModel build() => SplashViewModel(
    versionRepo: versionRepo,
    authRepo: authRepo,
    prefsRepo: prefsRepo,
    legacyCleanup: cleanup,
    minimumDuration: Duration.zero,
  );

  test('최소 버전보다 낮으면 강제 업데이트', () async {
    versionRepo.currentVersion = '1.1.0';
    versionRepo.info = const AppVersionInfo(
      minVersion: '2.0.0',
      storeUrl: 'https://store',
    );

    final vm = build();
    await settle();

    expect(vm.state, AppInitState.forceUpdate);
    await vm.openStore();
    expect(versionRepo.openedStoreUrls, ['https://store']);
  });

  test('버전 정보가 없으면(null) 막지 않는다', () async {
    versionRepo.info = null;
    final vm = build();
    await settle();

    expect(vm.state, AppInitState.navigateToLogin);
  });

  test('업데이트 후 첫 실행: 옛 세션이 있었으면 정리하고 계정 변경 안내를 띄운다', () async {
    prefsRepo.legacyCleanupDone = false;
    authRepo.hasSessionValue = true;

    final vm = build();
    await settle();

    expect(cleanup.cleanupCallCount, 1);
    expect(prefsRepo.legacyCleanupDone, isTrue);
    expect(vm.state, AppInitState.showAccountMigrationNotice);

    await vm.acknowledgeMigrationNotice();
    expect(prefsRepo.migrationNoticeShown, isTrue);
    expect(vm.state, AppInitState.navigateToLogin);
  });

  test('업데이트 후 첫 실행이지만 옛 세션이 없었으면 안내 없이 로그인으로', () async {
    prefsRepo.legacyCleanupDone = false;
    authRepo.hasSessionValue = false;

    final vm = build();
    await settle();

    expect(cleanup.cleanupCallCount, 1);
    expect(vm.state, AppInitState.navigateToLogin);
  });

  test('세션이 있으면 FCM 토큰을 등록하고 홈으로', () async {
    authRepo.hasSessionValue = true;

    final vm = build();
    await settle();

    expect(vm.state, AppInitState.navigateToHome);
    expect(authRepo.registerFcmCallCount, 1);
    expect(cleanup.cleanupCallCount, 0);
  });
}
