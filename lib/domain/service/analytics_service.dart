/// 사용 이벤트 기록. 테스트에서는 [NoopAnalyticsService]를 쓴다.
abstract interface class AnalyticsService {
  void logEvent(String name);
  void logLogin(String method);
  void logSignUp(String method);
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  void logEvent(String name) {}

  @override
  void logLogin(String method) {}

  @override
  void logSignUp(String method) {}
}
