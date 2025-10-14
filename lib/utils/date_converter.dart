import 'package:intl/intl.dart';

class DateConverter {
  /// 날짜를 맵의 키 값으로 변환. 근데 맵 방식을 안써서 지금은 안쓸듯
  /// "2025-09-12"
  static String dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 시간까지 표시 (디테일 페이지에서 사용)
  /// ex. "2025년 9월 12일 일요일 오후 9시"
  static String dateToFullString(DateTime date) {
    return DateFormat('yyyy년 M월 d일 EEEE a h시', 'ko').format(date);
  }

  /// 요일까지 표시(메인 화면에서 사용)
  /// ex. "2025년 9월 12일 일요일"
  static String dateToDateString(DateTime date) {
    return DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(date);
  }
}
