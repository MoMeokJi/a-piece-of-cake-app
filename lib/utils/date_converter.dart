import 'package:intl/intl.dart';

class DateConverter {
  DateConverter._();

  /// 서버 createdAt(`2025-09-05T21:12:00+09:00`)을 기기 로컬 시간으로 바꾼다.
  /// 오프셋이 없는 옛 응답은 KST(+09:00)로 간주한다. 못 읽으면 1900-01-01.
  static DateTime parseServerDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(1900, 1, 1);
    try {
      final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
      final parsed = DateTime.parse(hasOffset ? raw : '$raw+09:00');
      return parsed.toLocal();
    } catch (_) {
      return DateTime(1900, 1, 1);
    }
  }

  /// "2025-09-12"
  static String dateToKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// "9월 16일 화요일" (카드·상단 바 부제)
  static String toMonthDayWeekday(DateTime date) =>
      DateFormat('M월 d일 EEEE', 'ko').format(date);

  /// "2025년 9월" (캘린더 헤더)
  static String toYearMonth(DateTime date) =>
      DateFormat('yyyy년 M월', 'ko').format(date);

  /// "오후 9:12" (상세 메타)
  static String toTimeOfDay(DateTime date) =>
      DateFormat('a h:mm', 'ko').format(date);

  /// "9월 5일" (삭제 시트 문구)
  static String toMonthDay(DateTime date) =>
      DateFormat('M월 d일', 'ko').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
