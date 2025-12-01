import 'dart:io';
import 'package:cake/config/di.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/my_app.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cake/config/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_logger.dart';

// Background 메시지 처리를 위한 top-level function
// 반드시 main 파일의 최상단에 위치해야 함
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler에서는 DI를 사용할 수 없어서 직접 인스턴스 생성
  await Firebase.initializeApp();

  AppLogger.log('FCM 수신 (top level) : Background 메시지');
  AppLogger.log('제목: ${message.data['title']}', tag: 'FCM');
  AppLogger.log('내용: ${message.data['body']}', tag: 'FCM');
  AppLogger.log('타입: ${message.data['type']}', tag: 'FCM');
  AppLogger.log('diaryId: ${message.data['diaryId']}', tag: 'FCM');

  // Android인 경우에만 로컬 노티피케이션 표시 (iOS는 FCM이 자체적으로 처리)
  if (Platform.isAndroid) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // 로컬 노티피케이션 초기화
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Background에서 로컬 노티피케이션 표시
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'test',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.data['title'] ?? 'message.data[title]이 null. background임니다용',
      message.data['body'] ?? '',
      notificationDetails,
    );
  }
}

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 날짜포맷팅 초기화
  await initializeDateFormatting('ko');

  // 3. FCM Background Handler 등록 (반드시 다른 Firebase 작업 전에 호출)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 시스템 UI(상태바/내비게이션바) 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: ColorConfig.bottomNavi,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      // systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Firebase 초기화
  await _initializeFirebase();
  await diSetup();

  await getIt<PermissionHandlerService>().requestEssentialPermissions();
  await getIt<NotificationService>().initialize();
  await getIt<FCMService>().initialize();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.log(
    '파이어베이스 초기화 appId : ${DefaultFirebaseOptions.currentPlatform.appId}',
  );
}
