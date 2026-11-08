/// 로컬 알림. Android 포그라운드에서 FCM 대신 알림을 그릴 때만 쓴다.
abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });
}
