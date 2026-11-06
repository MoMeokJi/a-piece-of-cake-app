import 'package:cake/config/service_config.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

/// 하단 탭 셸. FAB를 눌렀을 때 하루 한도를 확인한다.
class MainViewModel extends ChangeNotifier {
  final UserRepository _userRepo;

  MainViewModel({required UserRepository userRepo}) : _userRepo = userRepo;

  int _dailyLimit = ServiceConfig.maxDiaryCount;
  int get dailyLimit => _dailyLimit;

  /// 서버 통계로 판단한다. 조회 실패면 일단 쓰게 두고 저장 시점의 429에 맡긴다.
  Future<bool> canWriteToday() async {
    try {
      final stats = await _userRepo.getStats();
      _dailyLimit = stats.dailyLimit;
      return stats.canWriteToday;
    } catch (e) {
      AppLogger.error('통계 조회 실패(작성 허용): $e');
      return true;
    }
  }
}
