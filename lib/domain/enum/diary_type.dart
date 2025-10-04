enum DiaryType {
  emotional,
  record,
  goal,
  confession,
  freewriting;

  // UI용
  String get text => switch (this) {
    DiaryType.emotional => '예쁜 말만 담은 감성일기',
    DiaryType.record => '하루를 정리하는 기록일기',
    DiaryType.goal => '목표와 계획을 세우는 다짐일기',
    DiaryType.confession => '나만 아는 내면을 담은 속마음일기',
    DiaryType.freewriting => '뭐라도 쓰는게 목표인 끄적일기',
  };

  // server에 보낼 데이터로 변환
  String get toServer => switch (this) {
    DiaryType.emotional => 'EMOTIONAL',
    DiaryType.record => 'RECORD',
    DiaryType.goal => 'GOAL',
    DiaryType.confession => 'CONFESSION',
    DiaryType.freewriting => 'FREEWRITING',
  };

  // 모델 변환용 (server에서 온 데이터를 모델로 변환)
  static DiaryType fromServer(String? value) {
    return switch (value?.toUpperCase()) {
      'EMOTIONAL' => DiaryType.emotional,
      'RECORD' => DiaryType.record,
      'GOAL' => DiaryType.goal,
      'CONFESSION' => DiaryType.confession,
      'FREEWRITING' => DiaryType.freewriting,
      _ => DiaryType.freewriting, // 기본값
    };
  }
}
