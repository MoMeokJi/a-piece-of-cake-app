class AppLogger {
  static const bool _isStoreBuild = bool.fromEnvironment(
    'STORE_BUILD',
    defaultValue: false,
  );

  static bool _shouldLog() {
    return !_isStoreBuild;
  }

  static void log(String message, {String? tag}) {
    if (_shouldLog()) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final tagStr = tag != null ? '[$tag] ' : '';
      print('$timestamp $tagStr$message'); // ← print 사용!
    }
  }

  static void error(String message, {String? tag, Object? error}) {
    if (_shouldLog()) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final tagStr = tag != null ? '[$tag] ' : '';
      print('🔴 $timestamp $tagStr$message'); // ← print 사용!
      if (error != null) print('   └─ Error: $error'); // ← print 사용!
    }
  }
}
