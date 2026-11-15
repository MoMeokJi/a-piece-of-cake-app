import 'dart:math' as math;

import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 홈 헤더. 워드마크 없이 인사말 + 배경 케이크.
///
/// 피그마 Home Header(Expanded 172 / Collapsed 104)는 상태바 44를 포함한 높이다.
/// 앱에서는 상태바를 [topInset](`MediaQuery.paddingOf(context).top`)으로 받고,
/// 그 아래를 피그마에서 44를 뺀 값으로 맞춘다: Expanded 128(문구 inset+12), Collapsed 60(문구 inset+6).
/// 배경 케이크 둘은 하나의 Stack으로 묶어 통째로 Opacity 0.45를 준다.
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

  /// 상태바 아래 높이. 전체 높이는 여기에 [topInset]을 더한 값.
  static const double expandedHeight = 128;
  static const double collapsedHeight = 60;

  /// 피그마 프레임에 포함된 상태바 높이. 피그마 y값에서 이만큼 뺀다.
  static const double _figmaStatusBar = 44;
  static const String collapsedGreeting = '오늘은 어떤 하루였나요?';

  @override
  Widget build(BuildContext context) {
    final height = (expanded ? expandedHeight : collapsedHeight) + topInset;
    final text = expanded ? (greeting ?? collapsedGreeting) : collapsedGreeting;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.header),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.45,
              child: _Deco(expanded: expanded),
            ),
          ),
          Positioned(
            left: 20,
            top: (expanded ? 12 : 6) + topInset,
            child: Text(
              text,
              style: TextConfig.titleM.copyWith(color: ColorConfig.textOnDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// 배경 케이크 두 개. 피그마 Deco 그룹(390 기준)의 회전 박스 위치를 오른쪽 기준으로 옮기고,
/// y는 피그마 값에서 상태바 44를 뺀다 (상태바 영역으로 올라가 잘린다).
class _Deco extends StatelessWidget {
  final bool expanded;

  const _Deco({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          // Expanded: 박스 118.6 @ (207.21, 10) · Collapsed: 박스 78.28 @ (240.28, 6)
          right: expanded ? 390 - 207.21 - 118.6 : 390 - 240.28 - 78.28,
          top: (expanded ? 10 : 6) - HomeHeader._figmaStatusBar,
          child: _Rotated(
            boxWidth: expanded ? 118.6 : 78.28,
            boxHeight: expanded ? 118.6 : 78.28,
            angleDeg: 12,
            child: Image.asset(
              AppImages.cake3dBlueberry,
              width: expanded ? 100 : 66,
              height: expanded ? 100 : 66,
            ),
          ),
        ),
        Positioned(
          // Expanded: 박스 152.92×163.6 @ (294, 7.58) · Collapsed: 106.35×113.47 @ (320, 6)
          right: expanded ? 390 - 294 - 152.92 : 390 - 320 - 106.35,
          top: (expanded ? 7.58 : 6) - HomeHeader._figmaStatusBar,
          child: _Rotated(
            boxWidth: expanded ? 152.92 : 106.35,
            boxHeight: expanded ? 163.6 : 113.47,
            angleDeg: -6,
            child: Image.asset(
              AppImages.cake3dStrawberry,
              width: expanded ? 138 : 96,
              height: expanded ? 150 : 104,
            ),
          ),
        ),
      ],
    );
  }
}

/// 피그마가 내보내는 "회전된 요소의 바운딩 박스" 안에 자식을 가운데 두고 돌린다.
class _Rotated extends StatelessWidget {
  final double boxWidth;
  final double boxHeight;
  final double angleDeg;
  final Widget child;

  const _Rotated({
    required this.boxWidth,
    required this.boxHeight,
    required this.angleDeg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Center(
        child: Transform.rotate(angle: angleDeg * math.pi / 180, child: child),
      ),
    );
  }
}
