import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel() {
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('SplashViewModel Error: $e');
    }
  }
}
