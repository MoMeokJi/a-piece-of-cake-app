import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_push_event_service.dart';
import '../../fakes/fake_user_repository.dart';
import '../../fakes/recording_analytics_service.dart';

const feedbackTap = PushPayload(type: PushType.feedback, diaryId: 9);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeUserRepository userRepo;
  late FakePushEventService pushEvents;
  late RecordingAnalyticsService analytics;

  setUp(() {
    userRepo = FakeUserRepository();
    pushEvents = FakePushEventService();
    analytics = RecordingAnalyticsService();
  });

  MainViewModel build() => MainViewModel(
    userRepo: userRepo,
    pushEvents: pushEvents,
    analytics: analytics,
  );

  test('보류된 시식평 탭이 있으면 만들어질 때 바로 열 일기를 정한다', () {
    pushEvents.pending = feedbackTap;
    final vm = build();
    expect(vm.diaryIdToOpen, 9);
    expect(analytics.events, ['fcm_feedback_tapped']);
    expect(pushEvents.pending, isNull);
  });

  test('실행 중 들어온 시식평 탭은 알리고 열 일기를 정한다', () async {
    final vm = build();
    var notified = 0;
    vm.addListener(() => notified++);
    pushEvents.controller.add(feedbackTap);
    await settle();
    expect(vm.diaryIdToOpen, 9);
    expect(notified, 1);
  });

  test('화면이 이동하면 비운다', () {
    pushEvents.pending = feedbackTap;
    final vm = build();
    vm.clearDiaryToOpen();
    expect(vm.diaryIdToOpen, isNull);
  });

  test('리마인드·공지 탭은 이벤트만 남기고 이동하지 않는다', () async {
    final vm = build();
    pushEvents.controller.add(const PushPayload(type: PushType.remind));
    pushEvents.controller.add(
      const PushPayload(type: PushType.adminMessage),
    );
    await settle();
    expect(vm.diaryIdToOpen, isNull);
    expect(analytics.events, [
      'fcm_reminder_tapped',
      'fcm_admin_message_tapped',
    ]);
  });

  test('diaryId 없는 시식평 탭은 이동하지 않는다', () {
    pushEvents.pending = const PushPayload(type: PushType.feedback);
    expect(build().diaryIdToOpen, isNull);
  });

  test('dispose 후에는 탭을 받지 않는다', () async {
    final vm = build();
    vm.dispose();
    pushEvents.controller.add(feedbackTap);
    await settle();
    expect(vm.diaryIdToOpen, isNull);
  });
}
