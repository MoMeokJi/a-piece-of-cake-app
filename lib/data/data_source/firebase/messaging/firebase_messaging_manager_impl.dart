import 'dart:io';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingManagerImpl implements FirebaseMessagingManager {
  final FirebaseMessaging _messaging;

  FirebaseMessagingManagerImpl() : _messaging = FirebaseMessaging.instance;

  @override
  Future<String> getToken() async {
    // iOS에서만 APNS 토큰 체크
    if (Platform.isIOS) {
      AppLogger.log('iOS에서 APNS 토큰 확인 중...');
      final apnsToken = await _messaging.getAPNSToken();

      if (apnsToken == null) {
        AppLogger.log('APNS 토큰 없음, 2초 대기 후 재시도');
        await Future.delayed(Duration(seconds: 2));
      } else {
        AppLogger.log('APNS 토큰 확보됨');
      }
    }

    AppLogger.log('FCM 토큰 요청 중...');
    final token = await _messaging.getToken();
    if (token == null) throw Exception('FCM token is null');
    AppLogger.log('FCM token : $token');
    return token;
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
  void setForegroundMessageListener(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  @override
  void setMessageTapListener(void Function(RemoteMessage) onTap) {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }
  
  @override
  Future<void> deleteToken() async{
   await _messaging.deleteToken();
  }
}
