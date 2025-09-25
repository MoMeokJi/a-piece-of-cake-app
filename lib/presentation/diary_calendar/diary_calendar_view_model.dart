import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryCalendarViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepository;

  DiaryCalendarViewModel({required DiaryRepository diaryRepository})
    : _diaryRepository = diaryRepository {
    // ViewModel 생성 시 초기 데이터 로드
    loadAllDiaries();
  }

  // 캘린더 상태 관리
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 일기 데이터
  List<Diary> _allDiaries = [];
  List<Diary> _selectedDayDiaries = [];
  bool _isLoading = false;

  // Getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<Diary> get allDiaries => _allDiaries;
  List<Diary> get selectedDayDiaries => _selectedDayDiaries;
  bool get isLoading => _isLoading;

  // 포커스된 날짜 변경
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  // 날짜 선택
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _loadSelectedDayDiaries();
      notifyListeners();
    }
  }

  // 선택된 날짜의 일기들 로드
  Future<void> _loadSelectedDayDiaries() async {
    if (_selectedDay == null) return;

    _selectedDayDiaries = _allDiaries.where((diary) {
      return isSameDay(diary.createdAt, _selectedDay!);
    }).toList();
  }

  // 특정 날짜의 일기들 가져오기 (이벤트 로더용)
  List<Diary> getEventsForDay(DateTime day) {
    return _allDiaries.where((diary) {
      return isSameDay(diary.createdAt, day);
    }).toList();
  }

  // 모든 일기 로드
  Future<void> loadAllDiaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allDiaries = await _diaryRepository.getLatestDiaryList();
      if (_selectedDay != null) {
        _loadSelectedDayDiaries();
      }
    } catch (e) {
      // 에러 처리
      print('일기 로드 중 에러 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 월별 일기 로드 (캘린더 월 변경 시)
  Future<void> loadMonthlyDiaries(DateTime focusedDay) async {
    try {
      final monthlyDiaries = await _diaryRepository.getMonthlyDiaryList(
        year: focusedDay.year,
        month: focusedDay.month,
      );

      // 기존 일기에서 해당 월의 일기들만 업데이트
      _allDiaries.removeWhere((diary) {
        return diary.createdAt.year == focusedDay.year &&
            diary.createdAt.month == focusedDay.month;
      });
      _allDiaries.addAll(monthlyDiaries);

      if (_selectedDay != null) {
        _loadSelectedDayDiaries();
      }
      notifyListeners();
    } catch (e) {
      print('월별 일기 로드 중 에러 발생: $e');
    }
  }
}
