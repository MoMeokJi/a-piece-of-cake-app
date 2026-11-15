import 'package:json_annotation/json_annotation.dart';

part 'daily_questions_response_dto.g.dart';

/// `GET /diaries/question`. `questions`는 항상 5개(앞 2개 필수), `optionalSpares`는 0~5개.
/// 구버전 서버는 `optionalSpares`를 주지 않으므로 null을 허용한다.
@JsonSerializable()
class DailyQuestionsResponseDto {
  final List<String>? questions;
  final List<String>? optionalSpares;

  DailyQuestionsResponseDto({this.questions, this.optionalSpares});

  factory DailyQuestionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyQuestionsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DailyQuestionsResponseDtoToJson(this);
}
