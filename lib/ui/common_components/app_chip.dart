import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

enum AppChipStyle { outline, tonal, ghost }

/// 작은 보조 버튼/필터 칩. Outline=보조 액션, Tonal=선택됨, Ghost=비선택.
class AppChip extends StatelessWidget {
  final String label;
  final AppChipStyle style;
  final VoidCallback? onTap;
  final Widget? icon;
  final double height;

  const AppChip({
    super.key,
    required this.label,
    required this.onTap,
    this.style = AppChipStyle.outline,
    this.icon,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = style == AppChipStyle.ghost
        ? ColorConfig.textSecondary
        : ColorConfig.textAccent;
    return Material(
      color: switch (style) {
        AppChipStyle.outline => ColorConfig.bgSurface,
        AppChipStyle.tonal => ColorConfig.bgChip,
        AppChipStyle.ghost => Colors.transparent,
      },
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.circular(AppRadius.full),
        side: style == AppChipStyle.outline
            ? const BorderSide(color: ColorConfig.borderDefault)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circular(AppRadius.full),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: textColor, size: 16),
                  child: icon!,
                ),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextConfig.buttonS.copyWith(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
