import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager_impl.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MockFirebaseMessagingManager implements FirebaseMessagingManagerImpl {
  final FirebaseMessaging _messaging;

  MockFirebaseMessagingManager() : _messaging = FirebaseMessaging.instance;

  @override
  Future<String> getToken() async {
    AppLogger.log('가짜 파이어베이스 토큰 발급');
    return 'fake-firebase-token';
  }

  @override
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  void setForegroundMessageListener(
    void Function(RemoteMessage p1) onMessage,
  ) async {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  @override
  void setMessageTapListener(void Function(RemoteMessage p1) onTap) async {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }
  
  @override
  Future<void> deleteToken() {
    // TODO: implement deleteToken
    throw UnimplementedError();
  }
}
