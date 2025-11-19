import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class DiaryTypeOption extends StatelessWidget {
  final DiaryPreference type;
  final bool isSelected;
  final VoidCallback onTap;

  const DiaryTypeOption({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

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
            color: isSelected
                ? ColorConfig.primary.withValues(alpha: 0.5)
                : ColorConfig.border.withValues(alpha: 0.5),
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
                color: type.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  type.emoji,
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
