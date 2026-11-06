import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

enum WriteType { qna, free }

/// A-11 작성 방식 선택
class WriteTypeSheet {
  WriteTypeSheet._();

  static Future<WriteType?> show(BuildContext context) {
    return AppBottomSheet.show<WriteType>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateConverter.toMonthDayWeekday(DateTime.now()),
            style: TextConfig.label.copyWith(color: ColorConfig.textSecondary),
          ),
          const SizedBox(height: 4),
          Text('오늘은 어떻게 기록할까요?', style: TextConfig.titleL),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Option(
                  background: ColorConfig.bgSubtle,
                  icon: AppIcons.chat,
                  iconColor: ColorConfig.textAccent,
                  title: '문답 일기',
                  description: '질문에 답하면\n일기가 완성돼요',
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(name: 'qna_diary_start');
                    Navigator.of(context).pop(WriteType.qna);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Option(
                  background: ColorConfig.bgTintPinkSubtle,
                  icon: AppIcons.pen,
                  iconColor: ColorConfig.textRose,
                  title: '자유 일기',
                  description: '내 방식대로\n자유롭게 써요',
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'free_diary_start',
                    );
                    Navigator.of(context).pop(WriteType.free);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final Color background;
  final AppIcons icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _Option({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: ColorConfig.bgSurface,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.option,
                ),
                alignment: Alignment.center,
                child: AppIcon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(title, style: TextConfig.titleS),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextConfig.label.copyWith(
                  color: ColorConfig.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
