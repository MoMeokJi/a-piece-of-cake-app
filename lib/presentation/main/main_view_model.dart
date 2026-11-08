import 'dart:async';

import 'package:cake/config/service_config.dart';
import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/domain/service/push_event_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

/// 하단 탭 셸. FAB를 눌렀을 때 하루 한도를 확인하고, 푸시 알림 탭을 받아 화면 이동을 요청한다.
///
/// 로그인된 상태에서만 만들어지므로, 로그인 전이나 앱이 켜지는 동안 들어온 탭은
/// [PushEventService]가 보류해 두었다가 여기서 꺼내 간다.
class MainViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final AnalyticsService _analytics;
  late final StreamSubscription<PushPayload> _tapSubscription;

  MainViewModel({
    required UserRepository userRepo,
    required PushEventService pushEvents,
    required AnalyticsService analytics,
  }) : _userRepo = userRepo,
       _analytics = analytics {
    _tapSubscription = pushEvents.taps.listen(_onPushTap);
    final pending = pushEvents.takePending();
    if (pending != null) _onPushTap(pending);
  }

  int _dailyLimit = ServiceConfig.maxDiaryCount;
  int get dailyLimit => _dailyLimit;

  int? _diaryIdToOpen;

  /// 열어야 할 일기 상세. 화면이 이동한 뒤 [clearDiaryToOpen]을 부른다.
  int? get diaryIdToOpen => _diaryIdToOpen;

  void clearDiaryToOpen() => _diaryIdToOpen = null;

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

  void _onPushTap(PushPayload tap) {
    switch (tap.type) {
      case PushType.feedback:
        _analytics.logEvent('fcm_feedback_tapped');
        if (tap.diaryId != null) {
          _diaryIdToOpen = tap.diaryId;
          notifyListeners();
        }
      case PushType.remind:
        _analytics.logEvent('fcm_reminder_tapped');
      case PushType.adminMessage:
        _analytics.logEvent('fcm_admin_message_tapped');
      case PushType.unknown:
        AppLogger.log('알 수 없는 푸시 탭: $tap', tag: 'FCM');
    }
  }

  @override
  void dispose() {
    _tapSubscription.cancel();
    super.dispose();
  }
}
