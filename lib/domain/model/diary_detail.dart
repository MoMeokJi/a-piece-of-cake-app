import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_color.dart';
import 'package:cake/domain/model/diary_music.dart';

class DiaryDetail {
  final int id;
  final DiaryType type;
  final String body;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<DiaryColor> colors;
  final DiaryMusic music;

  /// 시식평. 작성 후 2~4분 안에 서버 배치가 채운다. 그 전엔 null.
  final String? feedback;

  /// 확정 응답에만 실린다. 상세 조회는 null.
  final String? summary;

  const DiaryDetail({
    required this.id,
    required this.type,
    required this.body,
    required this.createdAt,
    required this.imageUrls,
    required this.colors,
    required this.music,
    this.feedback,
    this.summary,
  });

  DiaryColor get firstColor =>
      colors.isNotEmpty ? colors[0] : DiaryColor.fallbackFirst;
  DiaryColor get secondColor =>
      colors.length > 1 ? colors[1] : DiaryColor.fallbackSecond;

  bool get hasFeedback => feedback != null && feedback!.trim().isNotEmpty;

  DiaryDetail copyWith({String? body, String? feedback}) => DiaryDetail(
    id: id,
    type: type,
    body: body ?? this.body,
    createdAt: createdAt,
    imageUrls: imageUrls,
    colors: colors,
    music: music,
    feedback: feedback ?? this.feedback,
    summary: summary,
  );

  /// 목록 갱신용 요약 모델로 바꾼다 (확정 직후 로컬 목록에 끼워 넣을 때).
  Diary toDiary() => Diary(
    id: id,
    type: type,
    summary: summary ?? '',
    createdAt: createdAt,
    colors: colors,
    musicTitle: music.title,
    musicArtist: music.artist,
  );
}
