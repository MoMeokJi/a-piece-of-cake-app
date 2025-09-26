class DateConverter {
  /// 날짜를 맵의 키 값으로 변환. 근데 맵 방식을 안써서 지금은 안쓸듯
  /// "2025-09-12"
  static String dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 시간까지 표시 (디테일 페이지에서 사용)
  /// ex. "2025년 9월 12일 일요일 오후 9시"
  static String dateToFullString(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[date.weekday - 1];
    final period = date.hour < 12 ? '오전' : '오후';
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);

    return '${date.year}년 ${date.month}월 ${date.day}일 $weekday $period $hour시';
  }

  /// 요일까지 표시(메인 화면에서 사용)
  /// ex. "2025년 9월 12일 일요일"
  static String dateToDateString(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[date.weekday - 1];

    return '${date.year}년 ${date.month}월 ${date.day}일 $weekday';
  }
}
