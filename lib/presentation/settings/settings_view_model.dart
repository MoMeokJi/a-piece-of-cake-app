import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsViewModel with ChangeNotifier {
  final UserRepository _userRepo;
  final DiaryRepository _diaryRepo;

  ResultState _withdrawState = ResultState.none;
  ResultState get withdrawState => _withdrawState;

  String _version = '';
  String get version => _version;

  bool get isLoading => withdrawState == ResultState.loading;

  SettingsViewModel({
    required UserRepository userRepo,
    required DiaryRepository diaryRepo,
  }) : _userRepo = userRepo,
       _diaryRepo = diaryRepo {
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      notifyListeners();
    } catch (e) {
      _version = '알 수 없음';
      notifyListeners();
    }
  }

  Future<void> confirmWithdraw() async {
    try {
      _withdrawState = ResultState.loading;
      notifyListeners();

      await _userRepo.withdraw();
      await _diaryRepo.removeAllDiaries();

      _withdrawState = ResultState.success;
    } catch (e) {
      AppLogger.error('전체 데이터 삭제 중 오류 발생: ${e.toString()}');
      _withdrawState = ResultState.error;
    }
    notifyListeners();
  }

  void resetWithdrawState() {
    _withdrawState = ResultState.none;
  }
}
