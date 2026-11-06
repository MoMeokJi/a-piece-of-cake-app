import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diary_page_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DiaryPageResponseDto {
  final List<DiaryListResponseDto>? items;
  final int? page;
  final int? size;
  final bool? hasNext;
  final int? totalCount;

  DiaryPageResponseDto({
    this.items,
    this.page,
    this.size,
    this.hasNext,
    this.totalCount,
  });

  factory DiaryPageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryPageResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryPageResponseDtoToJson(this);
}
