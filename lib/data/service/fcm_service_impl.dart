import 'dart:convert';

import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/push_event_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 서버는 두 플랫폼 모두 `notification{title, body}` + `data{type, diaryId?}`를 보낸다.
///
/// - 백그라운드·종료: OS가 알림을 띄우고, 탭하면 [FirebaseMessagingManager.onMessageOpenedApp]
///   또는 [FirebaseMessagingManager.getInitialMessage]로 들어온다.
/// - 포그라운드: iOS는 OS 배너, Android는 FCM이 띄우지 않으므로 로컬 알림으로 대신 그린다.
///   어느 쪽도 화면을 바로 옮기지 않는다. 수신 사실과 탭을 [PushEventService]로 넘길 뿐이다.
class FCMServiceImpl implements FCMService {
  final FirebaseMessagingManager _messagingManager;
  final TokenRepository _tokenRepository;
  final NotificationService _notificationService;
  final PushEventService _pushEvents;
  final bool _isAndroid;

  FCMServiceImpl({
    required FirebaseMessagingManager messagingManager,
    required TokenRepository tokenRepository,
    required NotificationService notificationService,
    required PushEventService pushEvents,
    required bool isAndroid,
  }) : _messagingManager = messagingManager,
       _tokenRepository = tokenRepository,
       _notificationService = notificationService,
       _pushEvents = pushEvents,
       _isAndroid = isAndroid;

  @override
  Future<void> initialize() async {
    await _messagingManager.requestPermission();
    await _messagingManager.setForegroundPresentationOptions();

    // 권한이 거부돼도 핸들러는 건다. 설정에서 나중에 켜면 그대로 동작해야 한다.
    _messagingManager.onMessage.listen(_onForegroundMessage);
    _messagingManager.onMessageOpenedApp.listen(_publishTap);

    final initial = await _messagingManager.getInitialMessage();
    if (initial != null) {
      AppLogger.log('종료 상태에서 알림 탭으로 실행됨', tag: 'FCM');
      _publishTap(initial);
    }
  }

  @override
  Future<void> getFCMTokenAndSave() async {
    final token = await _messagingManager.getToken();
    if (token == null || token.isEmpty) {
      await _tokenRepository.clearFcmToken();
      return;
    }
    await _tokenRepository.saveFcmToken(token);
  }

  @override
  Future<void> deleteFCMToken() async {
    await _messagingManager.deleteToken();
    await _tokenRepository.clearFcmToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messagingManager.onTokenRefresh;

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    AppLogger.log('포그라운드 수신: ${message.data}', tag: 'FCM');
    _pushEvents.publishReceived(PushPayload.fromData(message.data));

    final notification = message.notification;
    if (!_isAndroid || notification == null) return;

    await _notificationService.showNotification(
      title: notification.title ?? message.data['title']?.toString() ?? '',
      body: notification.body ?? message.data['body']?.toString() ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _publishTap(RemoteMessage message) {
    _pushEvents.publish(PushPayload.fromData(message.data));
  }
}
