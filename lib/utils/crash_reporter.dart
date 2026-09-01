import 'package:firebase_crashlytics/firebase_crashlytics.dart';

abstract interface class CrashReporter {
  void recordError(Object error, StackTrace stack, {required String reason});
}

class FirebaseCrashReporter implements CrashReporter {
  const FirebaseCrashReporter();

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: false,
      reason: reason,
    );
  }
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {}
}
