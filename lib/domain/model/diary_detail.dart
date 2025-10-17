// ignore_for_file: annotate_overrides

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
  String? feedback;
  String? summary;

  DiaryDetail({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.imageUrls,
    required this.firstColorHex,
    required this.secondColorHex,
    required this.musicTitle,
    required this.musicArtist,
    required this.youtubeUrl,
    this.feedback,
    this.summary,
  });

  factory DiaryDetail.empty() => DiaryDetail(
    id: -1,
    body: '',
    createdAt: DateTime(1900, 1, 1),
    imageUrls: [],
    firstColorHex: '',
    secondColorHex: '',
    musicTitle: '',
    musicArtist: '',
    youtubeUrl: '',
  );
}
