import 'package:firebase_messaging/firebase_messaging.dart';

/// `FirebaseMessaging`을 감싼다. 서비스는 이 인터페이스만 보고, 테스트는 Fake로 바꾼다.
abstract interface class FirebaseMessagingManager {
  /// 알림 권한을 요청한다. iOS에서는 APNs 등록도 여기서 시작된다.
  Future<void> requestPermission();

  /// iOS 포그라운드에서 OS 배너를 띄우게 한다.
  Future<void> setForegroundPresentationOptions();

  /// FCM 토큰. iOS에서 APNs 토큰이 아직 없거나 실패하면 null.
  Future<String?> getToken();

  Future<void> deleteToken();

  /// 앱이 켜져 있을 때 도착한 메시지
  Stream<RemoteMessage> get onMessage;

  /// 백그라운드에 있던 앱의 알림을 탭했을 때
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// 종료된 앱이 알림 탭으로 켜졌을 때의 메시지. 한 번만 돌려준다.
  Future<RemoteMessage?> getInitialMessage();

  Stream<String> get onTokenRefresh;
}
