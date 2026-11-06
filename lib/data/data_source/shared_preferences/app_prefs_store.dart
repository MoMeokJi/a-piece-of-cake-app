import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences 접근을 한곳에 모은 얇은 저장소.
/// 의미는 AppPrefsRepositoryImpl이 붙인다.
class AppPrefsStore {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool?> getBool(String key) async => (await _prefs).getBool(key);
  Future<void> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);
  Future<void> remove(String key) async => (await _prefs).remove(key);

  /// 지정한 키만 남기고 전부 지운다.
  Future<void> clearExcept(Set<String> keep) async {
    final prefs = await _prefs;
    final kept = {for (final k in keep) k: prefs.get(k)};
    await prefs.clear();
    for (final entry in kept.entries) {
      final value = entry.value;
      if (value is bool) await prefs.setBool(entry.key, value);
      if (value is String) await prefs.setString(entry.key, value);
      if (value is int) await prefs.setInt(entry.key, value);
    }
  }
}
