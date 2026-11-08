abstract interface class FCMService {
  /// 권한 요청, 수신·탭 핸들러 등록, 종료 상태에서 알림 탭으로 켜졌는지 확인.
  /// 토큰은 여기서 받지 않는다 (세션이 있을 때 `AuthRepository.registerFcmToken`이 한다).
  Future<void> initialize();

  /// FCM 토큰을 발급해 저장한다. 못 받으면 저장된 값을 지운다.
  Future<void> getFCMTokenAndSave();

  Future<void> deleteFCMToken();

  /// FCM이 토큰을 바꿨을 때. 서버에 다시 등록해야 한다.
  Stream<String> get onTokenRefresh;
}
