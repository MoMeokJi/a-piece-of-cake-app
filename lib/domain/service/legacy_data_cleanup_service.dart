/// deviceId 가입 시절의 로컬 데이터를 지운다. 업데이트 후 첫 실행에 한 번만 호출.
abstract interface class LegacyDataCleanupService {
  Future<void> cleanup();
}
