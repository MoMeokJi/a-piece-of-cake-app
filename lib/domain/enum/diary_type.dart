enum DiaryType {
  qna,
  free;

  String get serverValue => switch (this) {
    DiaryType.qna => 'QNA',
    DiaryType.free => 'FREE',
  };

  /// 상세 화면 태그 라벨
  String get label => switch (this) {
    DiaryType.qna => '문답 일기',
    DiaryType.free => '자유 일기',
  };

  /// 서버 값이 비어 있거나 모르는 값이면 null. 호출부가 기본값을 정한다.
  static DiaryType? fromServer(String? value) => switch (value?.toUpperCase()) {
    'QNA' => DiaryType.qna,
    'FREE' => DiaryType.free,
    _ => null,
  };
}
