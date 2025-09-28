import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class DiarySelectBottomSheet extends StatelessWidget {
  final Function(String)? onDiarySelected;

  const DiarySelectBottomSheet({super.key, this.onDiarySelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: getHeight(300),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(10),
            horizontal: getWidth(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 제목
              Padding(
                padding: EdgeInsets.only(
                  top: getHeight(24),
                  bottom: getHeight(30),
                ),
                child: Text(
                  '어떤 일기를 작성하시나요?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorConfig.black,
                  ),
                ),
              ),

              // 일기 선택 옵션들
              Expanded(
                child: Row(
                  children: [
                    // 문답 일기
                    Expanded(
                      child: _buildDiaryOption(
                        context,
                        imagePath: 'assets/images/blueberry_flat.png',
                        title: '문답 일기',
                        description: '질문에 답하고\n자동으로 일기 작성',
                        backgroundColor: ColorConfig.primary.withAlpha(20),
                        borderColor: ColorConfig.primary.withAlpha(40),
                        onTap: () {
                          onDiarySelected?.call('question');
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    SizedBox(width: getWidth(12)),

                    // 자유 일기
                    Expanded(
                      child: _buildDiaryOption(
                        context,
                        imagePath: 'assets/images/strawberry_flat.png',
                        title: '자유 일기',
                        description: '내 방식대로\n자유롭게 일기 작성',
                        backgroundColor: ColorConfig.secondary.withAlpha(20),
                        borderColor: ColorConfig.secondary.withAlpha(40),
                        onTap: () {
                          onDiarySelected?.call('free');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryOption(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String description,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(getWidth(8)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지
            Flexible(
              child: Image.asset(
                imagePath,
                width: getWidth(80),
                height: getWidth(80),
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: getHeight(20)),

            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConfig.black,
              ),
            ),

            SizedBox(height: getHeight(5)),

            // 설명
            Flexible(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConfig.gray2,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
