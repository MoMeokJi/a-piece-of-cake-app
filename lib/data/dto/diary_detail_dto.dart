import 'package:cake/data/dto/music_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diary_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DiaryDetailDto {
  final int? diaryId;
  final String? content;
  final String? createdAt;
  final String? summary;
  final List<String>? images;
  final List<String>? colors;
  final MusicDto? music;
  final String? feedbackMsg;

  DiaryDetailDto({
    this.diaryId,
    this.content,
    this.createdAt,
    this.summary,
    this.images,
    this.colors,
    this.music,
    this.feedbackMsg,
  });
  factory DiaryDetailDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryDetailDtoToJson(this);
}
