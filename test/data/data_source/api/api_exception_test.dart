import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCrashReporter implements CrashReporter {
  final List<String> reasons = [];

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {
    reasons.add(reason);
  }
}

void main() {
  late _RecordingCrashReporter reporter;

  setUp(() {
    reporter = _RecordingCrashReporter();
    ApiException.reporter = reporter;
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('생성 시 상태코드와 엔드포인트를 담아 크래시 보고를 남긴다', () {
    ApiException(
      statusCode: 500,
      endpoint: 'createUser',
      responseBody: 'server error',
    );

    expect(reporter.reasons, ['[500] createUser']);
  });

  test('Firebase 초기화 없이 생성해도 예외가 나지 않는다', () {
    ApiException.reporter = const NoopCrashReporter();

    expect(
      () => ApiException(
        statusCode: 401,
        endpoint: 'deleteUser',
        responseBody: '',
      ),
      returnsNormally,
    );
  });
}
