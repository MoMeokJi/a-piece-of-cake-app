import 'package:cake/domain/service/legacy_data_cleanup_service.dart';

class FakeLegacyDataCleanupService implements LegacyDataCleanupService {
  int cleanupCallCount = 0;

  @override
  Future<void> cleanup() async => cleanupCallCount++;
}
