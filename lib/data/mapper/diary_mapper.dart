import 'package:cake/data/dto/color_dto.dart';
import 'package:cake/data/dto/diary_detail_response_dto.dart';
import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:cake/data/dto/diary_page_response_dto.dart';
import 'package:cake/data/dto/music_dto.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_color.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/diary_music.dart';
import 'package:cake/domain/model/diary_page.dart';
import 'package:cake/utils/date_converter.dart';

/// 색상 필드는 두 형식을 받아준다: 객체 배열 `[{name, hex}]`(새 서버)과
/// 문자열 배열 `['#8196C3', ...]`(옛 배포본). DTO 생성 전에 정규화한다.
List<DiaryColor> colorsFromJsonList(List<dynamic>? raw) {
  if (raw == null) return const [];
  final result = <DiaryColor>[];
  for (final item in raw) {
    if (item is String && item.isNotEmpty) {
      result.add(DiaryColor(hex: item));
    } else if (item is Map) {
      final hex = item['hex'];
      if (hex is String && hex.isNotEmpty) {
        final name = item['name'];
        result.add(
          DiaryColor(
            hex: hex,
            name: name is String && name.trim().isNotEmpty ? name : null,
          ),
        );
      }
    } else if (item is ColorDto && item.hex != null && item.hex!.isNotEmpty) {
      result.add(DiaryColor(hex: item.hex!, name: item.name));
    }
  }
  return result;
}

extension ColorDtoMapper on ColorDto {
  DiaryColor? toDiaryColor() {
    final value = hex;
    if (value == null || value.isEmpty) return null;
    final label = name;
    return DiaryColor(
      hex: value,
      name: label != null && label.trim().isNotEmpty ? label : null,
    );
  }
}

List<DiaryColor> _colors(List<ColorDto>? dtos) =>
    dtos?.map((e) => e.toDiaryColor()).whereType<DiaryColor>().toList() ??
    const [];

extension MusicDtoMapper on MusicDto? {
  DiaryMusic toDiaryMusic() => DiaryMusic(
    title: this?.title ?? '',
    artist: this?.artist ?? '',
    youtubeVideoId: this?.videoId ?? '',
    durationSeconds: this?.durationSeconds,
  );
}

extension DiaryListResponseMapper on DiaryListResponseDto {
  Diary toDiary() => Diary(
    id: diaryId ?? -1,
    type: DiaryType.fromServer(type) ?? DiaryType.free,
    summary: summary ?? '',
    createdAt: DateConverter.parseServerDate(createdAt),
    colors: _colors(colors),
    musicTitle: music?.title ?? '',
    musicArtist: music?.artist ?? '',
  );
}

extension DiaryPageResponseMapper on DiaryPageResponseDto {
  DiaryPage toDiaryPage({required int requestedPage}) {
    final list = items?.map((e) => e.toDiary()).toList() ?? const <Diary>[];
    return DiaryPage(
      items: list,
      page: page ?? requestedPage,
      hasNext: hasNext ?? false,
      totalCount: totalCount ?? list.length,
    );
  }
}

extension DiaryDetailResponseMapper on DiaryDetailResponseDto {
  DiaryDetail toDiaryDetail({DiaryType? fallbackType}) => DiaryDetail(
    id: diaryId ?? -1,
    type: DiaryType.fromServer(type) ?? fallbackType ?? DiaryType.free,
    body: content ?? '',
    createdAt: DateConverter.parseServerDate(createdAt),
    imageUrls: images ?? const [],
    colors: _colors(colors),
    music: music.toDiaryMusic(),
    feedback: feedbackMsg,
    summary: summary,
  );
}
