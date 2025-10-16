import 'package:json_annotation/json_annotation.dart';

part 'qna_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class QnaRequestDto {
  final String question;
  final String answer;

  QnaRequestDto({required this.question, required this.answer});

  factory QnaRequestDto.fromJson(Map<String, dynamic> json) =>
      _$QnaRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QnaRequestDtoToJson(this);
}
