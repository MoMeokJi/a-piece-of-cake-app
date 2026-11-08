import 'dart:convert';

import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/push_event_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceImpl implements NotificationService {
  /// 서버 AndroidConfig·AndroidManifest와 같은 ID. FCM이 띄우는 알림도 이 채널을 쓴다.
  static const channelId = 'high_importance_channel';
  static const _channelName = '기록·공감 알림';

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final PushEventService _pushEvents;

  NotificationServiceImpl({required PushEventService pushEvents})
    : _pushEvents = pushEvents;

  @override
  Future<void> initialize() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            _channelName,
            importance: Importance.high,
          ),
        );

    // 권한은 FCMService가 한 곳에서 요청한다.
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _publishTap(response.payload),
    );

    // 포그라운드에서 띄운 로컬 알림이 트레이에 남았다가 앱 종료 후 탭된 경우
    final launch = await _localNotifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _publishTap(launch?.notificationResponse?.payload);
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  void _publishTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _pushEvents.publish(PushPayload.fromData(data));
    } catch (e) {
      AppLogger.error('로컬 알림 payload 해석 실패: $payload', tag: 'FCM', error: e);
    }
  }
}
