import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class DiaryTypeOption extends StatelessWidget {
  final DiaryType type;
  final bool isSelected;
  final VoidCallback onTap;

  const DiaryTypeOption({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String _getEmoji(DiaryType type) {
    return switch (type) {
      DiaryType.emotional => '💕',
      DiaryType.record => '📘',
      DiaryType.goal => '🏆',
      DiaryType.confession => '💭',
      DiaryType.freewriting => '✍🏻',
    };
  }

  Color _getBackgroundColor(DiaryType type) {
    return switch (type) {
      DiaryType.emotional => Color(0xFFFCD2D8), // 핑크
      DiaryType.record => Color(0xFFD8E1F0), // 블루
      DiaryType.goal => Color(0xFFD4E6C7), // 그린
      DiaryType.confession => Color(0xFFE6D7F0), // 퍼플
      DiaryType.freewriting => Color(0xFFF5E6B8), // 옐로우
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(12),
          vertical: getHeight(12),
        ),
        decoration: BoxDecoration(
          color: ColorConfig.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ColorConfig.primary.withValues(alpha: 0.5) : ColorConfig.border.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
          BoxShadow(
            color: ColorConfig.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        ),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: getWidth(48),
              height: getWidth(48),
              decoration: BoxDecoration(
                color: _getBackgroundColor(type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getEmoji(type),
                  style: TextStyle(fontSize: getWidth(18)),
                ),
              ),
            ),

            SizedBox(width: getWidth(16)),

            // 텍스트
            Expanded(
              child: Text(
                type.text,
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),

            // 라디오 버튼
            Container(
              width: getWidth(20),
              height: getWidth(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ColorConfig.primary : ColorConfig.gray4,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: getWidth(12),
                        height: getWidth(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConfig.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
