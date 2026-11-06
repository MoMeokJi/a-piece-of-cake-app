import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 배경 그라데이션이 깔린 Scaffold. 상세·문답·입력 화면(pageTop)과
/// 로그인·스플래시(onboarding)가 쓴다.
class GradientScaffold extends StatelessWidget {
  final Gradient gradient;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  const GradientScaffold({
    super.key,
    required this.body,
    this.gradient = AppGradients.pageTop,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
