import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/diary_type.dart';
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
      DiaryType.emotional => '💝',
      DiaryType.record => '📝',
      DiaryType.goal => '🎯',
      DiaryType.confession => '💭',
      DiaryType.freewriting => '✏️',
    };
  }

  Color _getBackgroundColor(DiaryType type) {
    return switch (type) {
      DiaryType.emotional => Color(0xFFFFD4E5), // 핑크
      DiaryType.record => Color(0xFFD4E5FF), // 블루
      DiaryType.goal => Color(0xFFD4FFD4), // 그린
      DiaryType.confession => Color(0xFFE5D4FF), // 퍼플
      DiaryType.freewriting => Color(0xFFFFF4D4), // 옐로우
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(20),
          vertical: getHeight(20),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF7B9BD4) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getEmoji(type),
                  style: TextStyle(fontSize: getWidth(24)),
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
              width: getWidth(24),
              height: getWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF7B9BD4) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: getWidth(12),
                        height: getWidth(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF7B9BD4),
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
