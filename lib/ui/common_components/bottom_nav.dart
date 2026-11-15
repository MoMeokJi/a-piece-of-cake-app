import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 하단 탭: 홈 / (가운데는 [WriteFab] 자리) / 마이. 높이 80 + 하단 안전영역.
///
/// FAB는 이 위젯 안에 두지 않는다. 바 위로 튀어나온 부분은 부모 박스 밖이라 터치 판정에서
/// 빠지기 때문이다. `Scaffold.floatingActionButton`에 [WriteFab]을, `floatingActionButtonLocation`에
/// [WriteFabLocation]을 넣어 같은 자리에 올린다.
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double barHeight = 80;
  static const double fabOverlap = 28;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: barHeight + bottomInset,
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
          // 가운데 칸은 Scaffold가 올리는 WriteFab 자리
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

/// 일기 쓰기 FAB. 64px 원, 브랜드 그라데이션, 페이지색 4px 테두리.
class WriteFab extends StatelessWidget {
  final VoidCallback onTap;

  const WriteFab({super.key, required this.onTap});

  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '일기 쓰기',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.brand,
            border: Border.all(color: ColorConfig.bgPage, width: 4),
            boxShadow: AppShadows.fab,
          ),
          alignment: Alignment.center,
          child: const AppIcon(
            AppIcons.pen,
            size: 30,
            color: ColorConfig.textOnDark,
          ),
        ),
      ),
    );
  }
}

/// [WriteFab]을 바텀바 가운데, 바 위쪽 모서리에서 [BottomNav.fabOverlap]만큼 올려 놓는다.
class WriteFabLocation extends FloatingActionButtonLocation {
  const WriteFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final x = (scaffoldGeometry.scaffoldSize.width - fabSize.width) / 2;
    // contentBottom = 바텀바의 위쪽 모서리
    final y = scaffoldGeometry.contentBottom - BottomNav.fabOverlap;
    return Offset(x, y);
  }
}
