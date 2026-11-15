import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/presentation/common/profile_change_notifier.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';

enum HomeSegment { calendar, list }

/// 홈 한 화면에 캘린더와 리스트가 세그먼트로 들어 있다.
/// 탭 전환에도 상태를 유지해야 하므로 lazySingleton으로 등록한다.
class HomeViewModel extends ChangeNotifier {
  final DiaryRepository _diaryRepo;
  final UserRepository _userRepo;
  final DiaryChangeNotifier _diaryChanges;
  final ProfileChangeNotifier _profileChanges;

  HomeViewModel({
    required DiaryRepository diaryRepo,
    required UserRepository userRepo,
    required DiaryChangeNotifier diaryChanges,
    required ProfileChangeNotifier profileChanges,
    DateTime? now,
  }) : _diaryRepo = diaryRepo,
       _userRepo = userRepo,
       _diaryChanges = diaryChanges,
       _profileChanges = profileChanges {
    final today = now ?? DateTime.now();
    _today = DateTime(today.year, today.month, today.day);
    _focusedMonth = DateTime(today.year, today.month, 1);
    _selectedDay = _today;
    _diaryChanges.addListener(refresh);
    _profileChanges.addListener(_reloadProfile);
    refresh();
  }

  // ----- 공통 -----
  late final DateTime _today;
  DateTime get today => _today;

  HomeSegment _segment = HomeSegment.calendar;
  HomeSegment get segment => _segment;

  String? _nickname;
  String? get nickname => _nickname;

  bool _hasAnyDiary = true;
  bool get hasAnyDiary => _hasAnyDiary;

  String get greeting {
    final name = (_nickname == null || _nickname!.isEmpty)
        ? ''
        : '$_nickname님,\n';
    return _hasAnyDiary ? '$name오늘은 어떤 하루였나요?' : '$name첫 조각을 기다리고 있어요';
  }

  final ScrollController listScrollController = ScrollController();

  void setSegment(HomeSegment segment) {
    if (_segment == segment) return;
    _segment = segment;
    notifyListeners();
    if (segment == HomeSegment.list && _listItems.isEmpty && !_listLoading) {
      loadFirstPage();
    }
  }

  // ----- 캘린더 -----
  late DateTime _focusedMonth;
  DateTime get focusedMonth => _focusedMonth;

  late DateTime _selectedDay;
  DateTime get selectedDay => _selectedDay;

  List<Diary> _monthlyDiaries = [];
  List<Diary> get monthlyDiaries => _monthlyDiaries;

  bool _monthLoading = false;
  bool get monthLoading => _monthLoading;

  bool get isFocusedMonthEmpty => !_monthLoading && _monthlyDiaries.isEmpty;
  bool get isFocusedMonthCurrent =>
      _focusedMonth.year == _today.year && _focusedMonth.month == _today.month;

  List<Diary> get selectedDayDiaries => _monthlyDiaries
      .where((d) => DateConverter.isSameDay(d.createdAt, _selectedDay))
      .toList();

  List<Diary> diariesOn(DateTime day) => _monthlyDiaries
      .where((d) => DateConverter.isSameDay(d.createdAt, day))
      .toList();

  void selectDay(DateTime day) {
    if (DateConverter.isSameDay(day, _selectedDay)) return;
    _selectedDay = DateTime(day.year, day.month, day.day);
    if (day.year != _focusedMonth.year || day.month != _focusedMonth.month) {
      moveToMonth(DateTime(day.year, day.month, 1));
    } else {
      notifyListeners();
    }
  }

  Future<void> moveToMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month, 1);
    if (_selectedDay.year != month.year || _selectedDay.month != month.month) {
      _selectedDay = isFocusedMonthCurrent ? _today : _focusedMonth;
    }
    await _loadMonth();
  }

  Future<void> previousMonth() =>
      moveToMonth(DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1));
  Future<void> nextMonth() =>
      moveToMonth(DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1));
  Future<void> moveToCurrentMonth() {
    _selectedDay = _today;
    return moveToMonth(_today);
  }

  Future<void> _loadMonth() async {
    _monthLoading = true;
    notifyListeners();
    try {
      _monthlyDiaries = await _diaryRepo.getMonthlyDiaryList(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      if (_monthlyDiaries.isNotEmpty) _hasAnyDiary = true;
    } catch (e) {
      AppLogger.error('월 일기 조회 실패: $e');
      _monthlyDiaries = [];
    } finally {
      _monthLoading = false;
      notifyListeners();
    }
  }

  // ----- 리스트 -----
  SortType _sortType = SortType.recent;
  SortType get sortType => _sortType;

  List<Diary> _listItems = [];
  List<Diary> get listItems => _listItems;

  int _page = 0;
  bool _hasNext = false;
  bool get hasNext => _hasNext;
  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _listLoading = false;
  bool get listLoading => _listLoading;
  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool get isListEmpty => !_listLoading && _listItems.isEmpty;

  Future<void> setSortType(SortType sort) async {
    if (_sortType == sort) return;
    _sortType = sort;
    await loadFirstPage();
    if (listScrollController.hasClients) {
      listScrollController.jumpTo(0);
    }
  }

  Future<void> loadFirstPage() async {
    _listLoading = true;
    notifyListeners();
    try {
      final result = await _diaryRepo.getDiaryPage(sort: _sortType, page: 0);
      _listItems = result.items;
      _page = result.page;
      _hasNext = result.hasNext;
      _totalCount = result.totalCount;
      if (_listItems.isNotEmpty) _hasAnyDiary = true;
    } catch (e) {
      AppLogger.error('목록 조회 실패: $e');
    } finally {
      _listLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasNext || _loadingMore || _listLoading) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final result = await _diaryRepo.getDiaryPage(
        sort: _sortType,
        page: _page + 1,
      );
      _listItems = [..._listItems, ...result.items];
      _page = result.page;
      _hasNext = result.hasNext;
      _totalCount = result.totalCount;
    } catch (e) {
      AppLogger.error('다음 페이지 조회 실패: $e');
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  // ----- 갱신 -----
  Future<void> refresh() async {
    await Future.wait([_loadProfile(), _loadMonth(), loadFirstPage()]);
    _updateHasAnyDiary();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _userRepo.getMe();
      _nickname = profile.nickname;
    } catch (e) {
      AppLogger.error('프로필 조회 실패: $e');
    }
  }

  /// 닉네임이 바뀌면 인사말만 다시 그린다.
  Future<void> _reloadProfile() async {
    await _loadProfile();
    notifyListeners();
  }

  void _updateHasAnyDiary() {
    _hasAnyDiary =
        _totalCount > 0 || _listItems.isNotEmpty || _monthlyDiaries.isNotEmpty;
  }

  @override
  void dispose() {
    _diaryChanges.removeListener(refresh);
    _profileChanges.removeListener(_reloadProfile);
    listScrollController.dispose();
    super.dispose();
  }
}
