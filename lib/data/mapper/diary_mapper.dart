import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/domain/model/diary.dart';

extension DiaryMapper on DiaryDetailDto {
  Diary toDiary() => Diary(
    id: diaryId ?? -1,
    summary: summary ?? '',
    createdAt: _parseDateOrDefault(createdAt),
    firstColorHex: colors?[0] ?? '#8196C3',
    secondColorHex: colors?[1] ?? '#EEB5BE',
    musicTitle: music?.title ?? '',
    musicArtist: music?.artist ?? '',
  );

  DateTime _parseDateOrDefault(String? dateStr) {
    if (dateStr == null) {
      return DateTime(1900, 1, 1);
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime(1900, 1, 1);
    }
  }
}
