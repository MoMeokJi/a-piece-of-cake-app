import 'package:cake/domain/service/notification_service.dart';

class FakeNotificationService implements NotificationService {
  final List<({String title, String body, String? payload})> shown = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    shown.add((title: title, body: body, payload: payload));
  }
}
