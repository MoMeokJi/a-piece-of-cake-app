import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/common_components/section_title.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 오늘의 시식평. 아직 없으면(작성 후 약 10분) 대기 문구.
class FlavorSection extends StatelessWidget {
  final DiaryDetail diary;

  const FlavorSection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      gradient: AppGradients.cardTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(iconAsset: AppImages.iconFlavor, title: '오늘의 시식평'),
          const SizedBox(height: 12),
          if (diary.hasFeedback)
            Text(diary.feedback!, style: TextConfig.bodyMLong)
          else
            Row(
              children: [
                Image.asset(
                  AppImages.cakeSlice,
                  width: 44,
                  height: 46,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('곧 달콤한 한마디가 도착해요', style: TextConfig.bodyMStrong),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
