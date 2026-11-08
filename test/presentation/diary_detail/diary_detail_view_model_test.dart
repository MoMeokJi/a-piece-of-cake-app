import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_music.dart';
import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_repository.dart';
import '../../fakes/fake_push_event_service.dart';

DiaryDetail detail({required int id, String? feedback}) => DiaryDetail(
  id: id,
  type: DiaryType.free,
  body: '본문',
  createdAt: DateTime(2026, 11, 7),
  imageUrls: const [],
  colors: const [],
  music: const DiaryMusic(title: 't', artist: 'a', youtubeVideoId: 'v'),
  feedback: feedback,
);

Future<void> settle() async {
  for (var i = 0; i < 3; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeDiaryRepository diaryRepo;
  late FakePushEventService pushEvents;

  setUp(() {
    diaryRepo = FakeDiaryRepository();
    pushEvents = FakePushEventService();
  });

  DiaryDetailViewModel build() => DiaryDetailViewModel(
    diaryRepo: diaryRepo,
    diaryChanges: DiaryChangeNotifier(),
    analytics: const NoopAnalyticsService(),
    pushEvents: pushEvents,
  );

  test('열려 있는 일기의 시식평 푸시가 도착하면 로딩 없이 다시 불러온다', () async {
    diaryRepo.details[3] = detail(id: 3);
    final vm = build();
    await vm.initialize(null, 3);
    expect(vm.diary?.hasFeedback, isFalse);

    diaryRepo.details[3] = detail(id: 3, feedback: '달콤해요');
    final loadingSeen = <bool>[];
    vm.addListener(() => loadingSeen.add(vm.isLoading));
    pushEvents.receivedController.add(
      const PushPayload(type: PushType.feedback, diaryId: 3),
    );
    await settle();

    expect(vm.diary?.feedback, '달콤해요');
    expect(loadingSeen, [false]);
  });

  test('탭도 같은 일기면 다시 불러온다', () async {
    diaryRepo.details[3] = detail(id: 3);
    final vm = build();
    await vm.initialize(null, 3);
    final before = diaryRepo.getDiaryCallCount;

    pushEvents.controller.add(
      const PushPayload(type: PushType.feedback, diaryId: 3),
    );
    await settle();
    expect(diaryRepo.getDiaryCallCount, before + 1);
  });

  test('다른 일기나 다른 종류의 푸시는 무시한다', () async {
    diaryRepo.details[3] = detail(id: 3);
    final vm = build();
    await vm.initialize(null, 3);
    final before = diaryRepo.getDiaryCallCount;

    pushEvents.receivedController.add(
      const PushPayload(type: PushType.feedback, diaryId: 4),
    );
    pushEvents.receivedController.add(const PushPayload(type: PushType.remind));
    await settle();
    expect(diaryRepo.getDiaryCallCount, before);
  });

  test('조용한 갱신이 실패하면 보던 화면을 유지한다', () async {
    diaryRepo.details[3] = detail(id: 3);
    final vm = build();
    await vm.initialize(null, 3);
    diaryRepo.details.remove(3);

    pushEvents.receivedController.add(
      const PushPayload(type: PushType.feedback, diaryId: 3),
    );
    await settle();
    expect(vm.diary?.id, 3);
    expect(vm.loadFailed, isFalse);
  });

  test('dispose 후에는 푸시를 받지 않는다', () async {
    diaryRepo.details[3] = detail(id: 3);
    final vm = build();
    await vm.initialize(null, 3);
    final before = diaryRepo.getDiaryCallCount;
    vm.dispose();

    pushEvents.receivedController.add(
      const PushPayload(type: PushType.feedback, diaryId: 3),
    );
    await settle();
    expect(diaryRepo.getDiaryCallCount, before);
  });
}
