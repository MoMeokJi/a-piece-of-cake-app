import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {
  final DiaryDetail diary;
  const FeedbackSection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorConfig.primary.withValues(alpha: 0.2),
              ColorConfig.secondary.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          // boxShadow: [
          //   BoxShadow(
          //     color: ColorConfig.black.withValues(alpha: 0.1),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //     spreadRadius: 0,
          //   ),
          // ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(20),
            vertical: getHeight(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 섹션
              Row(
                children: [
                  Image.asset(
                    'assets/icons/flavor_icon.png',
                    width: getWidth(24),
                    height: getHeight(24),
                  ),
                  SizedBox(width: getWidth(8)),
                  Text(
                    '오늘의 Flavor',
                    style: TextStyle(
                      fontSize: getHeight(16),
                      fontWeight: FontWeight.w800,
                      color: ColorConfig.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(12)),
              Text(
                diary.feedback!,
                style: TextStyle(
                  fontSize: getHeight(14),
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: ColorConfig.gray1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
