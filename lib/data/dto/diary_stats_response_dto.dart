import 'package:json_annotation/json_annotation.dart';

part 'diary_stats_response_dto.g.dart';

@JsonSerializable()
class DiaryStatsResponseDto {
  final int? totalCount;
  final int? monthCount;
  final int? streakDays;
  final int? todayCount;
  final int? dailyLimit;

  DiaryStatsResponseDto({
    this.totalCount,
    this.monthCount,
    this.streakDays,
    this.todayCount,
    this.dailyLimit,
  });

  factory DiaryStatsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryStatsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryStatsResponseDtoToJson(this);
}
