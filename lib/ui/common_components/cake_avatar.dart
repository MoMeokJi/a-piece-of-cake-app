import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 브랜드 그라데이션 원 위에 납작 케이크. 문답 봇 아바타.
class CakeAvatar extends StatelessWidget {
  final double size;

  const CakeAvatar({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.brand,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppImages.cakeFlatStrawberry,
        width: size * 24 / 36,
        height: size * 24 / 36,
      ),
    );
  }
}
