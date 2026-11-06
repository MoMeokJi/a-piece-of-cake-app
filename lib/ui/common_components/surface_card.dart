import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 흰 카드(모서리 20, 카드 그림자). [gradient]를 주면 틴트 카드.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final bool shadow;
  final BoxBorder? border;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.shadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? ColorConfig.bgSurface : null,
        gradient: gradient,
        borderRadius: AppRadius.circular(AppRadius.xl),
        boxShadow: shadow && gradient == null ? AppShadows.card : null,
        border: border,
      ),
      child: child,
    );
  }
}
