import 'package:cake/data/data_source/shared_preferences/app_prefs_store.dart';
import 'package:cake/data/repository/app_prefs_repository_impl.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/legacy_data_cleanup_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:sqflite/sqflite.dart';

/// deviceId 가입 시절 남은 것: secure storage의 옛 토큰, sqflite `cake.db`,
/// shared_preferences의 마지막 접속 시각 등. 계정 체계가 바뀌었으니 전부 지운다.
class LegacyDataCleanupServiceImpl implements LegacyDataCleanupService {
  final TokenRepository _tokenRepository;
  final AppPrefsStore _prefsStore;

  LegacyDataCleanupServiceImpl({
    required TokenRepository tokenRepository,
    required AppPrefsStore prefsStore,
  }) : _tokenRepository = tokenRepository,
       _prefsStore = prefsStore;

  static const String _legacyDatabaseName = 'cake.db';

  @override
  Future<void> cleanup() async {
    await _tokenRepository.clearAllSecureData();
    try {
      final path = '${await getDatabasesPath()}/$_legacyDatabaseName';
      await deleteDatabase(path);
    } catch (e) {
      AppLogger.error('옛 sqflite 삭제 실패(무시): $e');
    }
    await _prefsStore.clearExcept({AppPrefsRepositoryImpl.installedKey});
    AppLogger.log('deviceId 시절 로컬 데이터 정리 완료');
  }
}
