import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryCalendarViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepository;

  // 현재 포커스한 날짜(=월)
  DateTime _focusedMonth = DateTime.now();
  // 사용자가 선택한 날짜
  DateTime _selectedDay = DateTime.now();

  // 현재 월의 일기들
  List<Diary> _monthlyDiaryList = [];
  // 사용자가 선택한 날의 일기 리스트 (for ui)
  List<Diary> _selectedDayDiaryList = [];

  // Getters
  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDay => _selectedDay;
  List<Diary> get selectedDayDiaryList => _selectedDayDiaryList;

  DiaryCalendarViewModel({required DiaryRepository diaryRepository})
    : _diaryRepository = diaryRepository {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 현재 월의 일기 로드
      _monthlyDiaryList = await _diaryRepository.getCurrentMonthlyDiaryList();
      // 오늘 날짜 일기 필터링
      _filterSelectedDayDiaries();
    } catch (e) {
      AppLogger.error('DiaryCalendarViewModel _initialize Error: $e');
    }
    notifyListeners();
  }

  // 날짜 선택
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedMonth = focusedDay;
      _filterSelectedDayDiaries();
      notifyListeners();
    }
  }

  /// 캘린더 마커 표시용 - TableCalendar의 eventLoader에서 사용
  /// 캘린더 렌더링 시 화면의 모든 날짜에 대해 자동으로 호출됨
  /// 반환된 리스트는 markerBuilder의 events 파라미터로 전달되어 마커 개수 결정
  List<Diary> getDiaryListForMarker(DateTime day) {
    return _monthlyDiaryList.where((diary) {
      return isSameDay(diary.createdAt, day);
    }).toList();
  }

  // 월별 일기 로드 (캘린더 월 변경 시)
  Future<void> loadMonthlyDiaries(DateTime focusedDay) async {
    try {
      // 포커스된 월 업데이트
      _focusedMonth = focusedDay;
      notifyListeners();
      // 해당 월의 일기들 로드
      _monthlyDiaryList = await _diaryRepository.getMonthlyDiaryList(
        year: focusedDay.year,
        month: focusedDay.month,
      );

      // 선택된 날짜의 일기들 다시 로드
      _filterSelectedDayDiaries();
      notifyListeners();
    } catch (e) {
      AppLogger.error('DiaryCalendarViewModel loadMonthlyDiaries Error: $e');
    }
  }

  // _monthlyDiaryList 에서 선택된 날짜의 일기 필터링
  void _filterSelectedDayDiaries() {
    _selectedDayDiaryList = _monthlyDiaryList.where((diary) {
      return isSameDay(diary.createdAt, _selectedDay);
    }).toList();
  }
}
