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
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
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
      presentBadge: false,
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
    if (payload != null) {
      AppLogger.log('노티피케이션 탭 처리: $payload');
    }
  }
}
