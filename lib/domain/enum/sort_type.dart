enum SortType {
  recent,
  oldest;

  String get text => switch (this) {
    SortType.recent => '최신순',
    SortType.oldest => '오래된순',
  };

  /// `GET /diaries?sort=` 값. 서버 기본값에 기대지 않고 항상 명시한다.
  String get serverValue => switch (this) {
    SortType.recent => 'recent',
    SortType.oldest => 'oldest',
  };
}
