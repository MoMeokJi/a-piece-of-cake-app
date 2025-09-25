// ignore_for_file: annotate_overrides

import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'diary.freezed.dart';

@freezed
class Diary with _$Diary {
  final int id;
  final String summary;
  final DateTime createdAt;
  final String firstColorHex;
  final String secondColorHex;
  final String musicTitle;
  final String musicArtist;

  const Diary({
    required this.id,
    required this.summary,
    required this.createdAt,
    required this.firstColorHex,
    required this.secondColorHex,
    required this.musicTitle,
    required this.musicArtist,
  });
}
