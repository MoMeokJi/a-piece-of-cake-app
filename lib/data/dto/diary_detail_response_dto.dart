import 'package:cake/data/dto/color_dto.dart';
import 'package:cake/data/dto/music_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diary_detail_response_dto.g.dart';

/// `GET /diaries/{id}` 와 확정 응답(`POST /diaries`, `/diaries/free`)을 함께 받는다.
/// 상세에는 summary가, 확정에는 feedbackMsg가 없다.
@JsonSerializable(explicitToJson: true)
class DiaryDetailResponseDto {
  final int? diaryId;
  final String? type;
  final String? content;
  final String? createdAt;
  final String? summary;
  final List<String>? images;
  final List<ColorDto>? colors;
  final MusicDto? music;
  final String? feedbackMsg;

  DiaryDetailResponseDto({
    this.diaryId,
    this.type,
    this.content,
    this.createdAt,
    this.summary,
    this.images,
    this.colors,
    this.music,
    this.feedbackMsg,
  });

  factory DiaryDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryDetailResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryDetailResponseDtoToJson(this);
}
