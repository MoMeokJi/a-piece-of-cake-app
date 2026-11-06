import 'package:cake/ui/common_components/app_spinner.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

enum AppButtonStyle { primary, danger, neutral }

/// 메인 액션 버튼. 높이 52, 모서리 14. [enabled]가 false면 Disabled 스타일,
/// [isLoading]이면 라벨 대신 스피너.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool enabled;
  final bool isLoading;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.enabled = true,
    this.isLoading = false,
    this.height = 52,
    this.width,
  });

  bool get _disabled => !enabled && !isLoading;

  Color get _background {
    if (_disabled) return ColorConfig.actionDisabled;
    return switch (style) {
      AppButtonStyle.primary => ColorConfig.actionPrimary,
      AppButtonStyle.danger => ColorConfig.actionDanger,
      AppButtonStyle.neutral => ColorConfig.actionNeutral,
    };
  }

  Color get _foreground {
    if (_disabled) return ColorConfig.textDisabled;
    return switch (style) {
      AppButtonStyle.danger => ColorConfig.textOnDark,
      _ => ColorConfig.textPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && !isLoading && onPressed != null;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: _background,
        borderRadius: AppRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: interactive ? onPressed : null,
          borderRadius: AppRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Center(
              child: isLoading
                  ? AppSpinner(color: _foreground)
                  : Text(
                      label,
                      style: TextConfig.buttonL.copyWith(color: _foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
