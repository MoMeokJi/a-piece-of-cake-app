import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 하단 탭: 홈 / 일기 쓰기(브랜드 그라데이션 FAB) / 마이. 높이 80 + 하단 안전영역.
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  static const double barHeight = 80;
  static const double fabOverlap = 28;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: barHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: ColorConfig.bgSurface,
                border: Border(top: BorderSide(color: ColorConfig.borderSubtle)),
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Row(
                children: [
                  Expanded(
                    child: _Tab(
                      icon: AppIcons.home,
                      label: '홈',
                      active: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: _Tab(
                      icon: AppIcons.user,
                      label: '마이',
                      active: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -fabOverlap,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                button: true,
                label: '일기 쓰기',
                child: GestureDetector(
                  onTap: onFabTap,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.brand,
                      border: Border.all(color: ColorConfig.bgPage, width: 4),
                      boxShadow: AppShadows.fab,
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      AppIcons.pen,
                      color: ColorConfig.textOnDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final AppIcons icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? ColorConfig.textAccent : ColorConfig.textDisabled;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextConfig.tab.copyWith(color: color)),
        ],
      ),
    );
  }
}
