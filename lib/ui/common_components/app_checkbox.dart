import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 체크박스. 켜짐은 브랜드 블루 원색.
class AppCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final double size;

  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? ColorConfig.brandBlue : ColorConfig.bgSurface,
          borderRadius: BorderRadius.circular(6),
          border: checked
              ? null
              : Border.all(color: ColorConfig.borderDefault, width: 1.5),
        ),
        child: checked
            ? Center(
                child: AppIcon(
                  AppIcons.check,
                  size: size * 16 / 22,
                  color: ColorConfig.textOnDark,
                ),
              )
            : null,
      ),
    );
  }
}
