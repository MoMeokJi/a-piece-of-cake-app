import 'dart:convert';
import 'dart:io';
import 'package:cake/config/app_router.dart';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class FCMServiceImpl implements FCMService {
  final FirebaseMessagingManager _messagingManager;
  final TokenRepository _tokenRepository;
  final NotificationService _notificationService;
  final PermissionHandlerService _permissionHandlerService;

  FCMServiceImpl({
    required FirebaseMessagingManager messagingManager,
    required TokenRepository tokenRepository,
    required NotificationService notificationService,
    required PermissionHandlerService permissionHandlerService,
  }) : _messagingManager = messagingManager,
       _tokenRepository = tokenRepository,
       _notificationService = notificationService,
       _permissionHandlerService = permissionHandlerService;

  @override
  Future<void> initialize() async {
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //       alert: true,
    //       badge: false,
    //       sound: true,
    //     );

    // 1. 알림 권한 확인 및 요청
    if (!await _permissionHandlerService.checkPermission(
      Permission.notification,
    )) {
      final settings = await _messagingManager.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        AppLogger.log('FCM: 알림 권한 거부됨');
        return;
      }
    }

    // 2. FCM 토큰 저장
    await getFCMTokenAndSave();

    // 3. 각 상태별 메시지 핸들러 설정
    _setupForegroundHandler();
    _setupBackgroundOpenHandler();
    _setupTerminatedHandler();
  }

  @override
  Future<void> getFCMTokenAndSave() async {
    final token = await _messagingManager.getToken();
    await _tokenRepository.saveFcmToken(token);
  }

  void _setupForegroundHandler() {
    // Foreground 상태에서 메시지 수신
    FirebaseMessaging.onMessage.listen((message) async {
      AppLogger.log('FCM 수신 : Foreground 메시지');
      if (message.data.isNotEmpty) {
        AppLogger.log('제목: ${message.data['title']}');
        AppLogger.log('내용: ${message.data['body']}');
        AppLogger.log('타입: ${message.data['type']}');
        AppLogger.log('diaryId: ${message.data['diaryId']}');
        AppLogger.log('click_action: ${message.data["click_action"]}');

        // Foreground에서는 시스템 푸시가 안 보이므로 로컬 노티로 표시
        await _notificationService.showNotification(
          title:
              message.data['title'] ??
              'message.data[title]이 null. foreground임니다용',
          body: message.data['body'] ?? '',
          payload: jsonEncode({
            'type': message.data['type'],
            'diaryId': message.data['diaryId'],
          }),
        );
      }
    });
  }

  void _setupBackgroundOpenHandler() {
    // Background 상태에서 푸시 터치
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        AppLogger.log('FCM 수신 : Background 알림 탭');
        AppLogger.log('제목: ${message.data['title']}');
        AppLogger.log('내용: ${message.data['body']}');
        AppLogger.log('타입: ${message.data['type']}');
        AppLogger.log('diaryId: ${message.data['diaryId']}');
        AppLogger.log('click_action: ${message.data["click_action"]}');

        _handleMessageTap(message);
      }
    });
  }

  Future<void> _setupTerminatedHandler() async {
    if (Platform.isIOS) {
      // iOS: Terminated 상태에서 FCM 노티로 실행된 경우
      // 위젯트리가 생성되고 라우터 생성이 될 때까지 충분한 딜레이 추가
      await Future.delayed(const Duration(milliseconds: 2000));
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage?.notification != null) {
        AppLogger.log('FCM 수신 : Terminated 상태에서 알림으로 앱이 실행됨 (iOS)');
        AppLogger.log('title: ${initialMessage?.notification?.title}');
        AppLogger.log('body: ${initialMessage?.notification?.body}');

        _handleMessageTap(initialMessage!);
      }
    }
    // Android: Terminated 상태는 LocalNotificationService에서 처리됨
  }

  void _handleMessageTap(RemoteMessage message) {
    AppLogger.log(
      'fcm service 알림 탭 처리 시작. message: ${message.data.toString()}',
    );
    try {
      final type = message.data['type'];
      final diaryId = message.data['diaryId'];

      if (type == 'FEEDBACK') {
        AppRouter.router.go('/diary-calendar');
        Future.delayed(const Duration(milliseconds: 100), () {
          AppLogger.log('diary detail 페이지로 이동합니다');
          AppRouter.router.push(
            '/diary-detail',
            extra: int.parse(diaryId.toString()),
          );
        });
      }
    } catch (e) {
      AppLogger.error('fcm service 알림 탭 처리 실패: $e');
    }
  }
}
