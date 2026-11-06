import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary_color.dart';

/// 목록·캘린더용 요약 일기.
class Diary {
  final int id;
  final DiaryType type;
  final String summary;
  final DateTime createdAt;
  final List<DiaryColor> colors;
  final String musicTitle;
  final String musicArtist;

  const Diary({
    required this.id,
    required this.type,
    required this.summary,
    required this.createdAt,
    required this.colors,
    required this.musicTitle,
    required this.musicArtist,
  });

  DiaryColor get firstColor =>
      colors.isNotEmpty ? colors[0] : DiaryColor.fallbackFirst;
  DiaryColor get secondColor =>
      colors.length > 1 ? colors[1] : DiaryColor.fallbackSecond;

  String get musicLabel =>
      musicArtist.isEmpty ? musicTitle : '$musicTitle · $musicArtist';
}
