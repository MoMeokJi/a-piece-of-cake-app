import 'package:cake/config/service_config.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _isAppInstalledKey = 'is_app_installed';
  static const String _lastAccessedKey = 'last_accessed_at';

  // 재설치 감지
  Future<bool> checkAndHandleReinstall() async {
    final prefs = await SharedPreferences.getInstance();
    final isAppInstalled = prefs.getBool(_isAppInstalledKey) ?? false;

    if (!isAppInstalled) {
      AppLogger.log('앱 재설치 감지 - Secure Storage 초기화 필요');
      await prefs.setBool(_isAppInstalledKey, true);
      return true;
    }

    return false;
  }

  // API 호출 시마다 마지막 접속 시간 업데이트
Future<void> updateLastAccessed() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  await prefs.setString(_lastAccessedKey, now.toIso8601String());
  AppLogger.log('최근 활성 시간 업데이트: $now');
}

  // 비활성회원 체크 (마지막 api 호출시간으로 부터 180일 지남) 
  Future<bool> checkInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccessedStr = prefs.getString(_lastAccessedKey);

    if (lastAccessedStr == null) return false; // 기록 없으면 패스

    final lastAccessed = DateTime.parse(lastAccessedStr);
    return DateTime.now().difference(lastAccessed).inDays > ServiceConfig.inactivityThresholdDays;
  }

  // SharedPreferences 초기화 (is_app_installed는 유지)
  Future<void> clearLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool(_isAppInstalledKey, true);
    AppLogger.log('SharedPreferences 초기화 완료 (is_app_installed 유지)');
  }
}