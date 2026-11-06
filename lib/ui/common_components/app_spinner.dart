import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// icon/spinner를 돌리는 로딩 표시.
class AppSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const AppSpinner({
    super.key,
    this.size = 24,
    this.color = ColorConfig.textPrimary,
  });

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AppIcon(AppIcons.spinner, size: widget.size, color: widget.color),
    );
  }
}
