import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/service/app_store_check_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final TokenRepository _tokenRepo;
  final AppStoreCheckService _appStoreCheckService;
  SplashViewModel({
    required TokenRepository tokenRepo,
    required AppStoreCheckService appStoreCheckService,
  }) : _tokenRepo = tokenRepo,
       _appStoreCheckService = appStoreCheckService {
    _init();
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _hasToken = false;
  bool get hasToken => _hasToken;

  bool _needUpdate = false;
  bool get needUpdate => _needUpdate;

  Future<void> _init() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // 토큰 체크
      _hasToken = await _tokenRepo.hasTokens();
      // 업데이트 체크
      _needUpdate = await _appStoreCheckService.checkForUpdate();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // 에러 발생 시 비로그인 상태로 처리하고 업데이트 체크도 건너뜀
      AppLogger.error('SplashViewModel Error: $e');
      _hasToken = false;
      _needUpdate = false;
      _isInitialized = true;
    }
  }

  /// 스토어로 이동
  Future<void> openStore() async {
    await _appStoreCheckService.openStore();
  }

  void cancleUpdate() {
    _needUpdate = false;
    notifyListeners();
  }
}
