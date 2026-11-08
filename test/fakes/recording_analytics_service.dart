import 'package:cake/domain/service/analytics_service.dart';

class RecordingAnalyticsService implements AnalyticsService {
  final List<String> events = [];

  @override
  void logEvent(String name) => events.add(name);

  @override
  void logLogin(String method) => events.add('login:$method');

  @override
  void logSignUp(String method) => events.add('sign_up:$method');
}
