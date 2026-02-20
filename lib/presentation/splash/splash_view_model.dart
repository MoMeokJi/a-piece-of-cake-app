import 'package:cake/data/data_source/shared_preferences/storage.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/app_store_check_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final TokenRepository _tokenRepo;
  final AppStoreCheckService _appStoreCheckService;
  final Storage _storage;
  final DiaryDao _diaryDao;

  SplashViewModel({
    required TokenRepository tokenRepo,
    required AppStoreCheckService appStoreCheckService,
    required Storage storage,
    required DiaryDao diaryDao,
  }) : _tokenRepo = tokenRepo,
       _appStoreCheckService = appStoreCheckService,
       _storage = storage,
       _diaryDao = diaryDao {
    _init();
  }

  AppInitState _state = AppInitState.initializing;
  AppInitState get state => _state;

  Future<void> _init() async {
    try {
      final startTime = DateTime.now();

      // 1. 업데이트 체크
      final needUpdate = await _appStoreCheckService.checkForUpdate();
      AppLogger.log('Update check - needUpdate: $needUpdate');
      if (needUpdate) {
        await _ensureMinimumDelay(startTime, 1);
        _state = AppInitState.showUpdateDialog;
        notifyListeners();
        return;
      }

      // 2. 비활성 유저 체크
      final isInactive = await _storage.checkInactivity();
      AppLogger.log('Inactivity check - isInactive: $isInactive');
      if (isInactive) {
        await _ensureMinimumDelay(startTime, 1);
        _state = AppInitState.showInactivityDialog;
        notifyListeners();
        return;
      }

      // 3. 토큰 체크 후 네비게이션
      await _checkTokenAndNavigate();
      await _ensureMinimumDelay(startTime, 1);
    } catch (e, stackTrace) {
      AppLogger.error('SplashViewModel init error: $e\n$stackTrace');
      _state = AppInitState.navigateToSignUp;
      notifyListeners();
    }
  }

  Future<void> _ensureMinimumDelay(DateTime startTime, int seconds) async {
    final elapsed = DateTime.now().difference(startTime);
    final minimumDuration = Duration(seconds: seconds);
    if (elapsed < minimumDuration) {
      await Future.delayed(minimumDuration - elapsed);
    }
  }

  Future<void> _checkTokenAndNavigate() async {
    final hasToken = await _tokenRepo.hasJwtTokens();
    AppLogger.log('Token check - hasJwtToken: $hasToken');
    _state = hasToken
        ? AppInitState.navigateToMain
        : AppInitState.navigateToSignUp;
    notifyListeners();
  }

  Future<void> clearDataAndProceed() async {
    await Future.wait([
      _diaryDao.deleteAllDiaries(),
      _tokenRepo.clearAllSecureData(),
      _storage.clearLocalPrefs(),
    ]);
    AppLogger.log('비활성 유저 데이터 초기화 완료');
    await _checkTokenAndNavigate();
  }

  Future<void> openStore() async {
    await _appStoreCheckService.openStore();
  }

  Future<void> skipUpdate() async {
    await _checkTokenAndNavigate();
  }
}