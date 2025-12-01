import 'package:cake/domain/enum/splash_state.dart';
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

  SplashState _state = SplashState.initializing;
  SplashState get state => _state;

  Future<void> _init() async {
    try {
      // 스플래시 시작 시간 기록
      final startTime = DateTime.now();

      // 1. 업데이트 체크
      final needUpdate = await _appStoreCheckService.checkForUpdate();
      AppLogger.log('Update check - needUpdate: $needUpdate');

      // 업데이트가 필요하면 다이얼로그 표시 상태로 변경
      if (needUpdate) {
        // 최소 1초는 보여주기
        await _ensureMinimumDelay(startTime, 1);
        _state = SplashState.showUpdateDialog;
        notifyListeners();
        return;
      }

      // 2. 업데이트가 필요 없으면 토큰 체크 후 네비게이션
      await _checkTokenAndNavigate();

      // 스플래시화면 최소 1초 유지
      await _ensureMinimumDelay(startTime, 1);
    } catch (e, stackTrace) {
      AppLogger.error('SplashViewModel init error: $e\n$stackTrace');
      // 에러 발생 시 회원가입 화면으로 이동
      _state = SplashState.navigateToSignUp;
      notifyListeners();
    }
  }

  /// 시작 시간으로부터 최소 시간이 지나도록 보장
  Future<void> _ensureMinimumDelay(DateTime startTime, int seconds) async {
    final elapsed = DateTime.now().difference(startTime);
    final minimumDuration = Duration(seconds: seconds);

    if (elapsed < minimumDuration) {
      await Future.delayed(minimumDuration - elapsed);
    }
  }

  /// 토큰 체크 후 적절한 화면으로 네비게이션 상태 설정
  Future<void> _checkTokenAndNavigate() async {
    final hasToken = await _tokenRepo.hasJwtTokens();
    AppLogger.log('Token check - hasJwtToken: $hasToken');

    _state = hasToken
        ? SplashState.navigateToMain
        : SplashState.navigateToSignUp;
    notifyListeners();
  }

  /// 스토어로 이동 (업데이트 버튼 클릭 시)
  Future<void> openStore() async {
    await _appStoreCheckService.openStore();
  }

  /// 업데이트 스킵 (나중에 버튼 클릭 시)
  Future<void> skipUpdate() async {
    await _checkTokenAndNavigate();
  }
}
