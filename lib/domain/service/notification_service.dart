abstract interface class NotificationService {
  Future<void> initialize();
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });
}
