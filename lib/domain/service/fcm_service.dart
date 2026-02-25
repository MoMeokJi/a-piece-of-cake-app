abstract interface class FCMService {
  Future<void> initialize();
  
  ///FCM 토큰 발급 및 저장
  Future<void> getFCMTokenAndSave();

  /// FCM 토큰 삭제
  Future<void> deleteFCMToken();
}
