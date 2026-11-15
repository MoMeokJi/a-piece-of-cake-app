import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 세레니티 블루 단색 원 위에 케이크 조각. 문답 봇 아바타 (피그마 Bot Avatar 36, 케이크 18).
/// Brand Mark·앱 아이콘과 같은 배경색.
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
        color: ColorConfig.brandBlue,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppImages.cakeSlice,
        width: size * 18 / 36,
        height: size * 18 / 36,
        fit: BoxFit.contain,
      ),
    );
  }
}
