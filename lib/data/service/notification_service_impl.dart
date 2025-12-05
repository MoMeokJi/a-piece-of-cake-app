import 'dart:convert';

import 'package:cake/config/app_router.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceImpl implements NotificationService {
  final _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    // 1. Terminated 상태에서 노티로 실행되었는지 체크
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      AppLogger.log(
        '앱이 로컬 노티로 실행됨: ${launchDetails?.notificationResponse?.payload}',
      );
      _handleNotificationTap(launchDetails?.notificationResponse?.payload);
    }

    // 2. 노티피케이션 초기화
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log('로컬 노티 탭됨: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );
  }

  //개별 알림 메서드
  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'test',
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      ), // 매번 다른 ID : 현재 시간의 밀리초값을 100000으로 나눈 나머지(0~99999)
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      AppLogger.log('payload가 비어있음');
      return;
    }

    AppLogger.log('notification service 알림 탭 처리 시작. payload : $payload');
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'];
      final diaryId = data['diaryId'];

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
      AppLogger.error('notification service 알림 탭 처리 실패: $e');
    }
  }
}
