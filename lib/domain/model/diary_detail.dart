// ignore_for_file: annotate_overrides

import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'diary_detail.freezed.dart';

@freezed
class DiaryDetail with _$DiaryDetail {
  final int id;
  final String body;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String firstColorHex;
  final String secondColorHex;
  final String musicTitle;
  final String musicArtist;
  final String youtubeUrl;
  final String feedback;
  const DiaryDetail({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.imageUrls,
    required this.firstColorHex,
    required this.secondColorHex,
    required this.musicTitle,
    required this.musicArtist,
    required this.youtubeUrl,
    required this.feedback,
  });
}
