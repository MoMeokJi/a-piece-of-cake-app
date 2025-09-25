import 'package:json_annotation/json_annotation.dart';

part 'music_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MusicDto {
  final String? title;
  final String? artist;
  final String? youtubeUrl;

  MusicDto({this.title, this.artist, this.youtubeUrl});

  factory MusicDto.fromJson(Map<String, dynamic> json) =>
      _$MusicDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MusicDtoToJson(this);
}
