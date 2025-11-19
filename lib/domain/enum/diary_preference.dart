import 'dart:ui';

import 'package:cake/ui/style/color_config.dart';

enum DiaryPreference {
  emotional,
  record,
  goal,
  confession,
  freewriting;

  // UI용
  String get text => switch (this) {
    DiaryPreference.emotional => '예쁜 말만 담은 감성일기',
    DiaryPreference.record => '하루를 정리하는 기록일기',
    DiaryPreference.goal => '목표와 계획을 세우는 다짐일기',
    DiaryPreference.confession => '나만 아는 내면을 담은 속마음일기',
    DiaryPreference.freewriting => '뭐라도 쓰는게 목표인 끄적일기',
  };

  String get emoji => switch (this) {
    DiaryPreference.emotional => '💕',
    DiaryPreference.record => '📘',
    DiaryPreference.goal => '🏆',
    DiaryPreference.confession => '💭',
    DiaryPreference.freewriting => '✍🏻',
  };

  Color get color => switch (this) {
    DiaryPreference.emotional => ColorConfig.emotionalDiary,
    DiaryPreference.record => ColorConfig.recordDiary,
    DiaryPreference.goal => ColorConfig.goalDiary,
    DiaryPreference.confession => ColorConfig.confessionDiary,
    DiaryPreference.freewriting => ColorConfig.freewritingDiary,
  };

  // server에 보낼 데이터로 변환
  String get toServer => switch (this) {
    DiaryPreference.emotional => 'EMOTIONAL',
    DiaryPreference.record => 'RECORD',
    DiaryPreference.goal => 'GOAL',
    DiaryPreference.confession => 'CONFESSION',
    DiaryPreference.freewriting => 'FREEWRITING',
  };

  // 모델 변환용 (server에서 온 데이터를 모델로 변환)
  static DiaryPreference fromServer(String? value) {
    return switch (value?.toUpperCase()) {
      'EMOTIONAL' => DiaryPreference.emotional,
      'RECORD' => DiaryPreference.record,
      'GOAL' => DiaryPreference.goal,
      'CONFESSION' => DiaryPreference.confession,
      'FREEWRITING' => DiaryPreference.freewriting,
      _ => DiaryPreference.freewriting, // 기본값
    };
  }
}
