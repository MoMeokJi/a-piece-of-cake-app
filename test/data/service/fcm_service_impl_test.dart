import 'dart:convert';

import 'package:cake/data/service/fcm_service_impl.dart';
import 'package:cake/domain/model/push_payload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_firebase_messaging_manager.dart';
import '../../fakes/fake_notification_service.dart';
import '../../fakes/fake_push_event_service.dart';
import '../../fakes/fake_token_repository.dart';

const feedbackMessage = RemoteMessage(
  notification: RemoteNotification(title: '시식평 도착', body: '확인해보세요'),
  data: {'type': 'FEEDBACK', 'diaryId': '5', 'title': '시식평 도착', 'body': '확인해보세요'},
);
const feedbackTap = PushPayload(type: PushType.feedback, diaryId: 5);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeFirebaseMessagingManager manager;
  late FakeTokenRepository tokenRepo;
  late FakeNotificationService notifications;
  late FakePushEventService pushEvents;

  setUp(() {
    manager = FakeFirebaseMessagingManager();
    tokenRepo = FakeTokenRepository();
    notifications = FakeNotificationService();
    pushEvents = FakePushEventService();
  });

  FCMServiceImpl build({bool isAndroid = false}) => FCMServiceImpl(
    messagingManager: manager,
    tokenRepository: tokenRepo,
    notificationService: notifications,
    pushEvents: pushEvents,
    isAndroid: isAndroid,
  );

  test('initialize는 권한을 요청하고 종료 상태의 알림 탭을 넘긴다', () async {
    manager.initialMessage = feedbackMessage;
    await build().initialize();
    expect(manager.requestPermissionCalls, 1);
    expect(pushEvents.published, [feedbackTap]);
  });

  test('백그라운드 알림 탭은 PushEventService로 간다', () async {
    await build().initialize();
    manager.onOpenedController.add(feedbackMessage);
    await settle();
    expect(pushEvents.published, [feedbackTap]);
  });

  test('포그라운드 수신은 화면을 옮기지 않고 수신 사실만 알린다 (iOS)', () async {
    await build().initialize();
    manager.onMessageController.add(feedbackMessage);
    await settle();
    expect(pushEvents.published, isEmpty);
    expect(pushEvents.publishedReceived, [feedbackTap]);
    expect(notifications.shown, isEmpty);
  });

  test('포그라운드 수신은 Android에서만 로컬 알림으로 그린다', () async {
    await build(isAndroid: true).initialize();
    manager.onMessageController.add(feedbackMessage);
    await settle();
    expect(pushEvents.published, isEmpty);
    expect(notifications.shown, hasLength(1));
    expect(notifications.shown.single.title, '시식평 도착');
    expect(
      jsonDecode(notifications.shown.single.payload!),
      feedbackMessage.data,
    );
  });

  test('토큰을 못 받으면 저장된 토큰을 지우고 가짜 값을 만들지 않는다', () async {
    tokenRepo.fcmToken = 'old';
    manager.token = null;
    await build().getFCMTokenAndSave();
    expect(tokenRepo.fcmToken, isNull);
  });

  test('토큰을 받으면 저장한다', () async {
    await build().getFCMTokenAndSave();
    expect(tokenRepo.fcmToken, 'fcm-token');
  });
}
