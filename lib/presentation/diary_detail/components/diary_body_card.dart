import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/common_components/photo_thumb.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 상세의 본문 카드: 시간 · 타입 태그 · 본문 문단 · 사진.
class DiaryBodyCard extends StatelessWidget {
  final DiaryDetail diary;

  const DiaryBodyCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final paragraphs = diary.body
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateConverter.toTimeOfDay(diary.createdAt),
                style: TextConfig.label.copyWith(
                  color: ColorConfig.textTertiary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '·',
                  style: TextConfig.label.copyWith(
                    color: ColorConfig.textTertiary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorConfig.bgChip,
                  borderRadius: AppRadius.circular(AppRadius.full),
                ),
                child: Text(
                  diary.type.label,
                  style: TextConfig.caption.copyWith(
                    color: ColorConfig.textAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            Text(paragraphs[i], style: TextConfig.bodyMLong),
          ],
          if (diary.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < diary.imageUrls.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    PhotoThumb.network(
                      diary.imageUrls[i],
                      size: 98,
                      radius: AppRadius.sm,
                      onTap: () => context.push(
                        '/photo-viewer',
                        extra: PhotoViewerArgs(diary.imageUrls, i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PhotoViewerArgs {
  final List<String> urls;
  final int initialIndex;

  const PhotoViewerArgs(this.urls, this.initialIndex);
}
