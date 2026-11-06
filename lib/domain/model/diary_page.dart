import 'package:cake/domain/model/diary.dart';

class DiaryPage {
  final List<Diary> items;
  final int page;
  final bool hasNext;
  final int totalCount;

  const DiaryPage({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.totalCount,
  });

  static const DiaryPage empty = DiaryPage(
    items: [],
    page: 0,
    hasNext: false,
    totalCount: 0,
  );
}
