import 'package:cake/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _isAppInstalledKey = 'is_app_installed';

  Future<bool> checkAndHandleReinstall() async {
    final prefs = await SharedPreferences.getInstance();
    final isAppInstalled = prefs.getBool(_isAppInstalledKey) ?? false;

    if (!isAppInstalled) {
      // 재설치 감지됨
      AppLogger.log('앱 재설치 감지 - Secure Storage 초기화 필요');
      await prefs.setBool(_isAppInstalledKey, true);
      return true;
    }

    return false;
  }
}
