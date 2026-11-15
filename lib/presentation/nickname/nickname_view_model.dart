import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/nickname_validator.dart';
import 'package:cake/presentation/common/profile_change_notifier.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// 닉네임 설정(가입 직후)과 닉네임 변경(마이) 공용.
/// [isOnboarding]이면 저장 뒤 약관에서 고른 알림 설정과 FCM 토큰도 서버에 올린다.
class NicknameViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final AuthRepository _authRepo;
  final AppPrefsRepository _prefsRepo;
  final ProfileChangeNotifier _profileChanges;
  final bool isOnboarding;

  NicknameViewModel({
    required UserRepository userRepo,
    required AuthRepository authRepo,
    required AppPrefsRepository prefsRepo,
    required ProfileChangeNotifier profileChanges,
    required this.isOnboarding,
    String? initialNickname,
  }) : _userRepo = userRepo,
       _authRepo = authRepo,
       _prefsRepo = prefsRepo,
       _profileChanges = profileChanges,
       _prefilledFromProvider =
           initialNickname != null && initialNickname.trim().isNotEmpty {
    final initial = (initialNickname ?? '').trim();
    controller = TextEditingController(text: initial);
    _validation = validateNickname(initial);
    controller.addListener(_onTextChanged);
  }

  late final TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  final bool _prefilledFromProvider;

  /// SDK 계정 이름을 가져와 채웠는지 (안내 문구용)
  bool get prefilledFromProvider => _prefilledFromProvider;

  NicknameValidation _validation = NicknameValidation.empty;
  NicknameValidation get validation => _validation;

  /// 비어 있을 때는 메시지 없이 힌트만. 그 밖엔 유효/오류 메시지.
  bool get showError =>
      !_validation.isValid && _validation != NicknameValidation.empty;
  bool get canSave => _validation.isValid && !_isSaving;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _saved = false;
  bool get saved => _saved;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  String get nickname => controller.text.trim();

  void _onTextChanged() {
    _validation = validateNickname(controller.text);
    notifyListeners();
  }

  Future<void> save() async {
    if (!canSave) return;
    _isSaving = true;
    notifyListeners();

    try {
      await _userRepo.updateNickname(nickname);
      _profileChanges.notifyChanged(); // 홈 인사말 갱신
      if (isOnboarding) await _finishOnboarding();
      _saved = true;
    } on ValidationFailedException {
      _toastMessage = '닉네임 형식을 확인해 주세요';
    } catch (e) {
      AppLogger.error('닉네임 저장 실패: $e');
      _toastMessage = AppErrorMessages.of(e);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _finishOnboarding() async {
    final optIn = await _prefsRepo.takePendingNotificationOptIn();
    if (optIn == true) {
      try {
        await _userRepo.updateNotification(true);
      } catch (e) {
        AppLogger.error('알림 설정 저장 실패(무시): $e');
      }
    }
    await _authRepo.registerFcmToken();
  }

  void clearToast() => _toastMessage = null;

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
