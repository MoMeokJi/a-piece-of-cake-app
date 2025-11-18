import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';

class BodySection extends StatelessWidget {
  final DiaryDetail diary;
  const BodySection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorConfig.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ColorConfig.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(15),
          vertical: getHeight(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              DateConverter.dateToFullString(diary.createdAt),
              style: TextStyle(
                fontSize: getWidth(16),
                color: ColorConfig.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: getHeight(16)),
            // 일기 내용
            Text(
              diary.body,
              style: const TextStyle(
                fontSize: TextConfig.diaryFontSize,
                color: ColorConfig.diaryTextColor,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
