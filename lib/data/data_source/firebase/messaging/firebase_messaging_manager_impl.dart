import 'dart:io';

import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingManagerImpl implements FirebaseMessagingManager {
  final FirebaseMessaging _messaging;

  FirebaseMessagingManagerImpl() : _messaging = FirebaseMessaging.instance;

  static const _apnsRetries = 3;
  static const _apnsRetryDelay = Duration(seconds: 1);

  @override
  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.log('알림 권한: ${settings.authorizationStatus}', tag: 'FCM');
  }

  @override
  Future<void> setForegroundPresentationOptions() =>
      _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false,
        sound: true,
      );

  @override
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS && !await _waitForApnsToken()) {
        AppLogger.log('APNs 토큰이 없어 FCM 토큰을 건너뜀', tag: 'FCM');
        return null;
      }
      return await _messaging.getToken();
    } on FirebaseException catch (e) {
      AppLogger.error('FCM 토큰 발급 실패: ${e.code}', tag: 'FCM', error: e);
      return null;
    }
  }

  /// iOS는 APNs 토큰이 먼저 있어야 `getToken`이 성공한다.
  Future<bool> _waitForApnsToken() async {
    for (var i = 0; i < _apnsRetries; i++) {
      if (await _messaging.getAPNSToken() != null) return true;
      await Future<void>.delayed(_apnsRetryDelay);
    }
    return await _messaging.getAPNSToken() != null;
  }

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
