import 'package:json_annotation/json_annotation.dart';

part 'music_dto.g.dart';

@JsonSerializable()
class MusicDto {
  final String? title;
  final String? artist;
  final int? durationSeconds;
  final String? videoId;

  MusicDto({this.title, this.artist, this.durationSeconds, this.videoId});

  factory MusicDto.fromJson(Map<String, dynamic> json) =>
      _$MusicDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MusicDtoToJson(this);
}
