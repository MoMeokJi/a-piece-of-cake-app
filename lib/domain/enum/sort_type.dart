enum SortType {
  latest,
  oldest;

  String get text => switch (this) {
    SortType.latest => '최신순',
    SortType.oldest => '작성순',
  };
}
