/// 스플래시가 끝난 뒤 어디로 갈지.
enum AppInitState {
  initializing,

  /// 최소 버전 미만. 업데이트 시트를 띄우고 진행을 막는다
  forceUpdate,

  /// deviceId 시절 데이터를 지웠다. 계정 방식 변경 안내 시트를 띄운 뒤 로그인으로
  showAccountMigrationNotice,

  navigateToHome,
  navigateToLogin,
}
