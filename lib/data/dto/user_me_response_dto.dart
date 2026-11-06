import 'package:json_annotation/json_annotation.dart';

part 'user_me_response_dto.g.dart';

@JsonSerializable()
class UserMeResponseDto {
  final String? memberId;
  final String? nickname;
  final String? provider;
  final bool? notificationEnabled;

  UserMeResponseDto({
    this.memberId,
    this.nickname,
    this.provider,
    this.notificationEnabled,
  });

  factory UserMeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserMeResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserMeResponseDtoToJson(this);
}
