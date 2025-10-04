import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final TokenRepository _tokenRepo;
  SplashViewModel({required TokenRepository tokenRepo})
    : _tokenRepo = tokenRepo {
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _init() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // 토큰 체크
      _isLoggedIn = await _tokenRepo.hasTokens();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('SplashViewModel Error: $e');
    }
  }
}
