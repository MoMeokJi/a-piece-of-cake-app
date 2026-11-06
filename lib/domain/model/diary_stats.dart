class DiaryStats {
  final int totalCount;
  final int monthCount;
  final int streakDays;
  final int todayCount;

  /// 서버가 주는 하루 한도. 앱 상수는 fallback으로만 쓴다.
  final int dailyLimit;

  const DiaryStats({
    required this.totalCount,
    required this.monthCount,
    required this.streakDays,
    required this.todayCount,
    required this.dailyLimit,
  });

  bool get canWriteToday => todayCount < dailyLimit;
}
