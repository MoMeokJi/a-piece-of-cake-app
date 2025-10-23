import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class ColorsSection extends StatelessWidget {
  final DiaryDetail diary;
  const ColorsSection({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'assets/icons/color_icon.png',
                  width: getWidth(24),
                  height: getHeight(24),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  '오늘의 Color',
                  style: TextStyle(
                    fontSize: getHeight(16),
                    fontWeight: FontWeight.w800,
                    color: ColorConfig.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(12)),

            _buildColorItem(diary.firstColorHex),
            SizedBox(height: getHeight(6)),

            _buildColorItem(diary.secondColorHex),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(String colorHex) {
    // # 제거하고 Color 객체 생성
    final hexColor = colorHex.replaceAll('#', '');
    final color = Color(int.parse('FF$hexColor', radix: 16));

    return Container(
      height: getHeight(35),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: getWidth(100),
              decoration: BoxDecoration(
                color: ColorConfig.black.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  colorHex,
                  style: TextStyle(
                    fontSize: getHeight(14),
                    fontWeight: FontWeight.w800,
                    color: ColorConfig.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
