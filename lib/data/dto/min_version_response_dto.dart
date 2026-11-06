import 'package:json_annotation/json_annotation.dart';

part 'min_version_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MinVersionResponseDto {
  final AppVersionResponseDto? ios;
  final AppVersionResponseDto? android;

  MinVersionResponseDto({this.ios, this.android});

  factory MinVersionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MinVersionResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MinVersionResponseDtoToJson(this);
}

@JsonSerializable()
class AppVersionResponseDto {
  final String? minVersion;
  final String? latestVersion;
  final String? storeUrl;

  AppVersionResponseDto({this.minVersion, this.latestVersion, this.storeUrl});

  factory AppVersionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AppVersionResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppVersionResponseDtoToJson(this);
}
