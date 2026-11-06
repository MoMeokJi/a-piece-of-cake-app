import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 상세 화면 섹션 제목. 아이콘은 Image/Icon * (20px png).
class SectionTitle extends StatelessWidget {
  final String iconAsset;
  final String title;

  const SectionTitle({super.key, required this.iconAsset, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconAsset, width: 20, height: 20),
        const SizedBox(width: 8),
        Text(title, style: TextConfig.titleS),
      ],
    );
  }
}
