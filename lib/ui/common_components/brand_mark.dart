import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 피그마 Brand Mark: 세레니티 블루 원 + 케이크 조각 (앱 아이콘 미니 버전).
/// 안내 시트(하루 한도·업데이트·계정 변경)의 비주얼. 케이크는 원의 53%, 살짝 위로.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ColorConfig.brandBlue,
        shape: BoxShape.circle,
      ),
      // 피그마 inset: top 20.31% / right 23.44% / bottom 26.56% / left 23.44%
      padding: EdgeInsets.fromLTRB(
        size * 0.2344,
        size * 0.2031,
        size * 0.2344,
        size * 0.2656,
      ),
      child: Image.asset(AppImages.cakeSlice, fit: BoxFit.contain),
    );
  }
}
