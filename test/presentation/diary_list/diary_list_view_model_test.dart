import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_repository.dart';

Diary buildDiary({required int id, required String summary}) => Diary(
  id: id,
  summary: summary,
  createdAt: DateTime(2026, 1, id),
  firstColorHex: '#FFFFFF',
  secondColorHex: '#000000',
  musicTitle: '노래',
  musicArtist: '가수',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDiaryRepository repository;

  setUp(() {
    repository = FakeDiaryRepository()
      ..latestDiaries = [
        buildDiary(id: 2, summary: '나중 일기'),
        buildDiary(id: 1, summary: '먼저 일기'),
      ]
      ..oldestDiaries = [
        buildDiary(id: 1, summary: '먼저 일기'),
        buildDiary(id: 2, summary: '나중 일기'),
      ];
  });

  test('생성 시 최신순으로 목록을 불러온다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    await Future.delayed(Duration.zero);

    expect(viewModel.sortType, SortType.latest);
    expect(viewModel.diaryList.map((d) => d.id), [2, 1]);
    expect(repository.getLatestCallCount, 1);
  });

  test('정렬을 바꾸면 해당 순서로 다시 불러오고 리스너에 알린다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    await Future.delayed(Duration.zero);

    var notifyCount = 0;
    viewModel.addListener(() => notifyCount++);

    await viewModel.setSortType(SortType.oldest);

    expect(viewModel.sortType, SortType.oldest);
    expect(viewModel.diaryList.map((d) => d.id), [1, 2]);
    expect(repository.getOldestCallCount, 1);
    expect(notifyCount, 1);
  });

  test('같은 정렬을 다시 선택하면 재조회하지 않는다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    await Future.delayed(Duration.zero);

    await viewModel.setSortType(SortType.latest);

    expect(repository.getLatestCallCount, 1);
    expect(repository.getOldestCallCount, 0);
  });
}
