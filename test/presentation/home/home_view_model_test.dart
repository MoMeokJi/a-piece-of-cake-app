import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/presentation/home/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_repository.dart';
import '../../fakes/fake_user_repository.dart';

Diary buildDiary({required int id, DateTime? createdAt}) => Diary(
  id: id,
  type: DiaryType.free,
  summary: '요약 $id',
  createdAt: createdAt ?? DateTime(2026, 1, id),
  colors: const [],
  musicTitle: '노래',
  musicArtist: '가수',
);

DiaryPage page(List<Diary> items, {int page = 0, bool hasNext = false}) =>
    DiaryPage(items: items, page: page, hasNext: hasNext, totalCount: items.length);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeDiaryRepository diaryRepo;
  late FakeUserRepository userRepo;
  late DiaryChangeNotifier changes;
  final now = DateTime(2026, 1, 15);

  setUp(() {
    diaryRepo = FakeDiaryRepository();
    userRepo = FakeUserRepository();
    changes = DiaryChangeNotifier();
  });

  HomeViewModel build() => HomeViewModel(
    diaryRepo: diaryRepo,
    userRepo: userRepo,
    diaryChanges: changes,
    now: now,
  );

  test('생성 시 프로필·이번 달·최신순 첫 페이지를 불러온다', () async {
    diaryRepo.pages = {
      SortType.recent: [page([buildDiary(id: 1)])],
    };
    diaryRepo.monthlyDiaries = [buildDiary(id: 1, createdAt: now)];

    final vm = build();
    await settle();

    expect(vm.nickname, '서윤');
    expect(vm.greeting, '서윤님,\n오늘은 어떤 하루였나요?');
    expect(vm.requestedSortsOf(diaryRepo), [SortType.recent]);
    expect(vm.selectedDayDiaries.map((d) => d.id), [1]);
    expect(vm.hasAnyDiary, isTrue);
  });

  test('일기가 하나도 없으면 첫 조각 인사말을 쓴다', () async {
    final vm = build();
    await settle();

    expect(vm.hasAnyDiary, isFalse);
    expect(vm.greeting, '서윤님,\n첫 조각을 기다리고 있어요');
  });

  test('정렬을 바꾸면 그 정렬로 다시 불러오고, 같은 정렬이면 재조회하지 않는다', () async {
    diaryRepo.pages = {
      SortType.recent: [page([buildDiary(id: 2), buildDiary(id: 1)])],
      SortType.oldest: [page([buildDiary(id: 1), buildDiary(id: 2)])],
    };
    final vm = build();
    await settle();
    final before = diaryRepo.getPageCallCount;

    await vm.setSortType(SortType.oldest);
    expect(vm.listItems.map((d) => d.id), [1, 2]);
    expect(diaryRepo.getPageCallCount, before + 1);

    await vm.setSortType(SortType.oldest);
    expect(diaryRepo.getPageCallCount, before + 1);
  });

  test('hasNext면 loadMore가 다음 페이지를 이어 붙인다', () async {
    diaryRepo.pages = {
      SortType.recent: [
        page([buildDiary(id: 3)], hasNext: true),
        page([buildDiary(id: 2)], page: 1, hasNext: false),
      ],
    };
    final vm = build();
    await settle();

    await vm.loadMore();
    expect(vm.listItems.map((d) => d.id), [3, 2]);
    expect(vm.hasNext, isFalse);

    final calls = diaryRepo.getPageCallCount;
    await vm.loadMore();
    expect(diaryRepo.getPageCallCount, calls, reason: '더 없으면 요청하지 않는다');
  });

  test('날짜를 고르면 그 날의 일기만 보여준다', () async {
    diaryRepo.monthlyDiaries = [
      buildDiary(id: 1, createdAt: DateTime(2026, 1, 15)),
      buildDiary(id: 2, createdAt: DateTime(2026, 1, 3)),
    ];
    final vm = build();
    await settle();

    vm.selectDay(DateTime(2026, 1, 3));
    expect(vm.selectedDayDiaries.map((d) => d.id), [2]);
  });

  test('다른 달로 이동하면 그 달을 조회하고 기록 없는 달을 판단한다', () async {
    final vm = build();
    await settle();
    final calls = diaryRepo.getMonthlyCallCount;

    await vm.previousMonth();

    expect(vm.focusedMonth, DateTime(2025, 12, 1));
    expect(diaryRepo.getMonthlyCallCount, calls + 1);
    expect(vm.isFocusedMonthEmpty, isTrue);
    expect(vm.isFocusedMonthCurrent, isFalse);

    await vm.moveToCurrentMonth();
    expect(vm.isFocusedMonthCurrent, isTrue);
    expect(vm.selectedDay, now);
  });

  test('일기 변경 알림이 오면 전체를 다시 불러온다', () async {
    build();
    await settle();
    final pageCalls = diaryRepo.getPageCallCount;
    final monthCalls = diaryRepo.getMonthlyCallCount;

    changes.notifyChanged();
    await settle();

    expect(diaryRepo.getPageCallCount, pageCalls + 1);
    expect(diaryRepo.getMonthlyCallCount, monthCalls + 1);
  });
}

extension on HomeViewModel {
  List<SortType> requestedSortsOf(FakeDiaryRepository repo) => repo.requestedSorts;
}
