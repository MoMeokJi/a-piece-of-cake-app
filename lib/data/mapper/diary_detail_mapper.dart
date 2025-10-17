import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/domain/model/diary_detail.dart';

extension DiaryDetailMapper on DiaryDetailDto {
  DiaryDetail toDiaryDetail() => DiaryDetail(
    id: diaryId ?? -1,
    body: content ?? '',
    createdAt: _parseDateOrDefault(createdAt),
    imageUrls: images ?? [],
    firstColorHex: colors?[0] ?? '#8196C3',
    secondColorHex: colors?[1] ?? '#EEB5BE',
    musicTitle: music?.title ?? '',
    musicArtist: music?.artist ?? '',
    youtubeUrl: music?.youtubeUrl ?? '',
    feedback: feedbackMsg,
    summary: summary,
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
