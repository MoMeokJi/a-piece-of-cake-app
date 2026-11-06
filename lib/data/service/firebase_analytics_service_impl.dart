import 'package:cake/domain/service/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsServiceImpl implements AnalyticsService {
  @override
  void logEvent(String name) {
    FirebaseAnalytics.instance.logEvent(name: name);
  }

  @override
  void logLogin(String method) {
    FirebaseAnalytics.instance.logLogin(loginMethod: method);
  }

  @override
  void logSignUp(String method) {
    FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
  }
}
