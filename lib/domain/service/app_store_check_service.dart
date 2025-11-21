abstract interface class AppStoreCheckService {
  /// 현재 앱 버전과 스토어 버전을 비교하여 업데이트 필요 여부를 확인
  Future<bool> checkForUpdate();

  /// 현재 앱 버전 정보를 가져옴
  Future<String> getCurrentVersion();

  /// 스토어의 최신 버전 정보를 가져옴
  Future<String?> getStoreVersion();

  /// 스토어로 이동
  Future<void> openStore();
}
