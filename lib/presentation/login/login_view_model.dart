import 'dart:io';

import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

/// 로그인 뒤 어디로 갈지.
sealed class LoginOutcome {
  const LoginOutcome();
}

class LoginToHome extends LoginOutcome {
  const LoginToHome();
}

class LoginToNicknameSetup extends LoginOutcome {
  final String? initialNickname;
  const LoginToNicknameSetup(this.initialNickname);
}

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final AppPrefsRepository _prefsRepo;
  final AnalyticsService _analytics;
  final bool _isAndroid;

  LoginViewModel({
    required AuthRepository authRepo,
    required AppPrefsRepository prefsRepo,
    required AnalyticsService analytics,
    bool? isAndroid,
  }) : _authRepo = authRepo,
       _prefsRepo = prefsRepo,
       _analytics = analytics,
       _isAndroid = isAndroid ?? Platform.isAndroid;

  /// Android는 Google 버튼만 (확정).
  List<SocialProvider> get providers => _isAndroid
      ? const [SocialProvider.google]
      : const [SocialProvider.apple, SocialProvider.google];

  SocialProvider? _loadingProvider;
  SocialProvider? get loadingProvider => _loadingProvider;
  bool get isLoading => _loadingProvider != null;

  bool _termsAgreed = false;
  bool get termsAgreed => _termsAgreed;

  LoginOutcome? _outcome;
  LoginOutcome? get outcome => _outcome;

  String? _toastMessage;
  bool _toastIsError = false;
  bool _toastRetryable = false;
  String? get toastMessage => _toastMessage;
  bool get toastIsError => _toastIsError;
  bool get toastRetryable => _toastRetryable;

  SocialProvider? _lastProvider;

  /// 약관 시트에서 동의했을 때. 알림 선택값은 가입 직후 서버에 보낼 때까지 보관.
  Future<void> agreeTerms({required bool notificationOptIn}) async {
    _termsAgreed = true;
    await _prefsRepo.savePendingNotificationOptIn(notificationOptIn);
    notifyListeners();
  }

  Future<void> signIn(SocialProvider provider) async {
    if (isLoading) return;
    _lastProvider = provider;
    _loadingProvider = provider;
    _outcome = null;
    notifyListeners();

    try {
      final session = await _authRepo.signIn(provider);
      _analytics.logLogin(provider.name);
      if (session.isNewMember) {
        _analytics.logSignUp(provider.name);
        _outcome = LoginToNicknameSetup(session.nickname);
      } else {
        await _authRepo.registerFcmToken();
        _outcome = const LoginToHome();
      }
    } on SocialSignInCancelledException {
      _showToast(AppErrorMessages.loginCancelled, isError: false);
    } on AppException catch (e) {
      AppLogger.error('로그인 실패: $e');
      _showToast(
        AppErrorMessages.of(e, fallback: AppErrorMessages.loginFailed),
        isError: true,
        retryable: true,
      );
    } catch (e) {
      AppLogger.error('로그인 실패: $e');
      _showToast(AppErrorMessages.loginFailed, isError: true, retryable: true);
    } finally {
      _loadingProvider = null;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    final provider = _lastProvider;
    if (provider != null) await signIn(provider);
  }

  void _showToast(String message, {required bool isError, bool retryable = false}) {
    _toastMessage = message;
    _toastIsError = isError;
    _toastRetryable = retryable;
  }

  void clearToast() => _toastMessage = null;

  void clearOutcome() => _outcome = null;
}
