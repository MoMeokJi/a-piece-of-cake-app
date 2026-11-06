import 'package:json_annotation/json_annotation.dart';

part 'auth_token_response_dto.g.dart';

@JsonSerializable()
class AuthTokenResponseDto {
  final String? accessToken;
  final int? accessTokenExpiresIn;
  final String? refreshToken;
  final int? refreshTokenExpiresIn;
  final bool? isNewMember;
  final String? nickname;

  AuthTokenResponseDto({
    this.accessToken,
    this.accessTokenExpiresIn,
    this.refreshToken,
    this.refreshTokenExpiresIn,
    this.isNewMember,
    this.nickname,
  });

  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokenResponseDtoToJson(this);
}
