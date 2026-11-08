import 'dart:ui';
import 'package:cake/config/di.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/my_app.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cake/config/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_logger.dart';

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 날짜포맷팅 초기화
  await initializeDateFormatting('ko');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 시스템 UI(상태바/내비게이션바) 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: ColorConfig.bgSurface,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      // systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Firebase 초기화
  await _initializeFirebase();
  await diSetup();

  // 재설치 감지: iOS 키체인은 앱을 지워도 남으므로 첫 실행이면 secure storage를 비운다
  final isFreshInstall = await getIt<AppPrefsRepository>().consumeFreshInstallFlag();
  if (isFreshInstall) {
    await getIt<TokenRepository>().clearAllSecureData();
  }

  // 알림은 실패해도 앱은 떠야 한다.
  try {
    await getIt<NotificationService>().initialize();
    await getIt<FCMService>().initialize();
  } catch (e, stack) {
    AppLogger.error('알림 초기화 실패: $e\n$stack', tag: 'FCM');
  }

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics 설정
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  AppLogger.log(
    '파이어베이스 초기화 appId : ${DefaultFirebaseOptions.currentPlatform.appId}',
  );
}
