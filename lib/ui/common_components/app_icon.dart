import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 피그마 Icons(24px 라인 아이콘). 색은 [color]로 덮어쓴다.
class AppIcon extends StatelessWidget {
  final AppIcons icon;
  final double size;
  final Color color;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color = ColorConfig.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// 44×44 터치 영역을 가진 아이콘 버튼 (상단 바·툴바).
class AppIconButton extends StatelessWidget {
  final AppIcons icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color color;
  final String? semanticLabel;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
    this.color = ColorConfig.textPrimary,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: AppIcon(icon, size: iconSize, color: color)),
        ),
      ),
    );
  }
}
