import 'package:cake/data/dto/color_dto.dart';
import 'package:cake/data/dto/music_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diary_list_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DiaryListResponseDto {
  final int? diaryId;
  final String? type;
  final String? summary;
  final String? createdAt;
  final List<ColorDto>? colors;
  final MusicDto? music;

  DiaryListResponseDto({
    this.diaryId,
    this.type,
    this.summary,
    this.createdAt,
    this.colors,
    this.music,
  });

  factory DiaryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryListResponseDtoToJson(this);
}
