import 'dart:math' as math;

import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 홈 헤더. [expanded]면 172(인사말 포함), 아니면 108. 배경 케이크는 반투명으로 잘려 배치.
/// 상태바 높이는 포함하지 않는다 — 호출부가 위 여백을 더한다.
class HomeHeader extends StatelessWidget {
  final bool expanded;
  final String? greeting;

  const HomeHeader({super.key, required this.expanded, this.greeting});

  static const double expandedHeight = 172;
  static const double collapsedHeight = 108;

  @override
  Widget build(BuildContext context) {
    final height = expanded ? expandedHeight : collapsedHeight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.header),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            left: expanded ? 153 : 188,
            top: expanded ? -23 : -22,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  AppImages.cake3dBlueberry,
                  width: expanded ? 110 : 92,
                  height: expanded ? 110 : 92,
                ),
              ),
            ),
          ),
          Positioned(
            right: expanded ? -30 : -34,
            top: expanded ? 10 : -2,
            child: Transform.rotate(
              angle: -6 * math.pi / 180,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  AppImages.cake3dStrawberry,
                  width: expanded ? 138 : 106,
                  height: expanded ? 150 : 116,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: expanded ? 48 : 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(boxShadow: AppShadows.logo),
                  child: Image.asset(AppImages.logo, width: 156, height: 19),
                ),
                if (expanded && greeting != null) ...[
                  const SizedBox(height: 8),
                  Text(greeting!, style: TextConfig.titleM),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
