import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class DiaryListViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  List<Diary> _diaryList = [];
  SortType _sortType = SortType.latest;
  final ScrollController scrollController = ScrollController();

  List<Diary> get diaryList => _diaryList;
  SortType get sortType => _sortType;

  DiaryListViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadDiaryList();
  }

  Future<void> setSortType(SortType sortType) async {
    if (_sortType == sortType) return;

    _sortType = sortType;

    await loadDiaryList();

    if (scrollController.hasClients) {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> loadDiaryList() async {
    try {
      if (_sortType == SortType.latest) {
        _diaryList = await _diaryRepo.getLatestDiaryList();
      } else {
        _diaryList = await _diaryRepo.getOldestDiaryList();
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('DiaryListViewModel loadDiaryList Error: $e');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
