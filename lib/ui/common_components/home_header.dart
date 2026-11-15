import 'dart:math' as math;

import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 홈 헤더. [expanded]면 172(인사말 포함), 아니면 108. 배경 케이크는 반투명으로 잘려 배치.
/// [topInset](상태바 높이)만큼 위로 늘려 그라데이션이 상태바 뒤까지 이어지게 한다.
class HomeHeader extends StatelessWidget {
  final bool expanded;
  final String? greeting;
  final double topInset;

  const HomeHeader({
    super.key,
    required this.expanded,
    this.greeting,
    this.topInset = 0,
  });

  static const double expandedHeight = 172;
  static const double collapsedHeight = 108;

  @override
  Widget build(BuildContext context) {
    final height = (expanded ? expandedHeight : collapsedHeight) + topInset;
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
            top: (expanded ? -23 : -22) + topInset,
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
            top: (expanded ? 10 : -2) + topInset,
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
            top: (expanded ? 48 : 52) + topInset,
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
