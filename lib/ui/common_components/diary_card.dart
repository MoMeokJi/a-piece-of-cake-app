import 'package:cake/core/extensions/color_extensions.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';

/// 일기 요약 카드. 오른쪽 위 막대는 그날의 컬러 두 개를 이은 그라데이션.
class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;

  const DiaryCard({super.key, required this.diary, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConfig.bgSurface,
      borderRadius: AppRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateConverter.toMonthDayWeekday(diary.createdAt),
                    style: TextConfig.label.copyWith(
                      color: ColorConfig.textTertiary,
                    ),
                  ),
                  DiaryColorBar(
                    first: diary.firstColor.hex.toColor(),
                    second: diary.secondColor.hex.toColor(),
                    width: 36,
                    height: 12,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(diary.summary, style: TextConfig.bodyM),
              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: 1,
                color: ColorConfig.borderSubtle,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const AppIcon(
                    AppIcons.headphones,
                    size: 16,
                    color: ColorConfig.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      diary.musicLabel,
                      style: TextConfig.label.copyWith(
                        color: ColorConfig.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 두 컬러를 잇는 알약 막대 (카드·캘린더 날짜).
class DiaryColorBar extends StatelessWidget {
  final Color first;
  final Color second;
  final double width;
  final double height;

  const DiaryColorBar({
    super.key,
    required this.first,
    required this.second,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.circular(AppRadius.full),
        gradient: LinearGradient(colors: [first, second]),
      ),
    );
  }
}
