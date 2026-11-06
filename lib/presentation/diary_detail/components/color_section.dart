import 'package:cake/core/extensions/color_extensions.dart';
import 'package:cake/domain/model/diary_color.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/common_components/section_title.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 오늘의 컬러: 두 색을 이은 띠 + 각 색의 칩·이름·hex. 이름이 없으면 hex를 이름 자리에.
class ColorSection extends StatelessWidget {
  final DiaryDetail diary;

  const ColorSection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final first = diary.firstColor;
    final second = diary.secondColor;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(iconAsset: AppImages.iconColor, title: '오늘의 컬러'),
          const SizedBox(height: 16),
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: AppRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                colors: [first.hex.toColor(), second.hex.toColor()],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Swatch(color: first)),
              const SizedBox(width: 12),
              Expanded(child: _Swatch(color: second)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final DiaryColor color;

  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    final hex = color.hex.toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 88,
          decoration: BoxDecoration(
            color: color.hex.toColor(),
            borderRadius: AppRadius.circular(AppRadius.md),
          ),
        ),
        const SizedBox(height: 8),
        if (color.name != null) ...[
          Text(color.name!, style: TextConfig.bodyMStrong),
          const SizedBox(height: 2),
          Text(
            hex,
            style: TextConfig.caption.copyWith(color: ColorConfig.textTertiary),
          ),
        ] else
          Text(hex, style: TextConfig.numberMStrong),
      ],
    );
  }
}
