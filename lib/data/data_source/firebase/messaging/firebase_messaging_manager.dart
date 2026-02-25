import 'package:firebase_messaging/firebase_messaging.dart';

abstract interface class FirebaseMessagingManager {
  /// FCM 토큰 가져오기
  Future<String> getToken();

  /// FCM 토큰 삭제하기
  Future<void> deleteToken();

  /// 푸시 알림 권한 요청
  Future<NotificationSettings> requestPermission();

  /// 포그라운드 메시지 리스너 설정
  void setForegroundMessageListener(void Function(RemoteMessage) onMessage);

  /// 알림 탭 이벤트 리스너 설정
  void setMessageTapListener(void Function(RemoteMessage) onTap);
}
