/// 기기에만 남는 설정값. shared_preferences를 presentation에서 감춘다.
abstract interface class AppPrefsRepository {
  /// 첫 실행이면 true를 돌려주고 설치 표시를 남긴다 (secure storage 잔재 삭제 트리거).
  Future<bool> consumeFreshInstallFlag();

  /// deviceId 시절 데이터(옛 토큰·sqflite·prefs) 정리가 끝났는가
  Future<bool> isLegacyCleanupDone();
  Future<void> markLegacyCleanupDone();

  /// "계정 방식으로 바뀌었다" 안내를 보여줬는가
  Future<bool> hasShownAccountMigrationNotice();
  Future<void> markAccountMigrationNoticeShown();

  /// 약관 시트의 "[선택] 기록 알림 받기" 체크값. 가입 직후 서버에 보낼 때까지 보관.
  Future<void> savePendingNotificationOptIn(bool enabled);
  Future<bool?> takePendingNotificationOptIn();
}
