class DiaryMusic {
  final String title;
  final String artist;
  final String youtubeVideoId;

  /// YouTube에서 못 받아오면 null. 그러면 재생시간 배지를 숨긴다.
  final int? durationSeconds;

  const DiaryMusic({
    required this.title,
    required this.artist,
    required this.youtubeVideoId,
    this.durationSeconds,
  });

  bool get hasVideo => youtubeVideoId.isNotEmpty;

  /// "3:02" 형식. 없으면 null.
  String? get durationLabel {
    final seconds = durationSeconds;
    if (seconds == null || seconds <= 0) return null;
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
