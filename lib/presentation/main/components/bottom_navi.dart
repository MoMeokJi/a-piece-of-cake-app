import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class BottomNavi extends StatelessWidget {
  final int currentIndex;
  final void Function(int) changeTap;

  const BottomNavi({
    super.key,
    required this.currentIndex,
    required this.changeTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      Icons.calendar_month_outlined,
      Icons.list_alt_rounded,
    ];

    return AnimatedBottomNavigationBar.builder(
      itemCount: icons.length,
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      backgroundColor: ColorConfig.bottomNavi,
      splashColor: ColorConfig.primary.withAlpha(20),

      height: getHeight(80),
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.10),
        blurRadius: 12,
        spreadRadius: 2,
        offset: const Offset(0, -3),
      ),
      tabBuilder: (index, isActive) {
        final color = isActive ? ColorConfig.primary : ColorConfig.disabled;
        final label = index == 0 ? '캘린더 보기' : '목록 보기';
        return Padding(
          padding: EdgeInsets.symmetric(vertical: getHeight(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[index], color: color, size: getWidth(30)),
              SizedBox(height: getHeight(3)),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      onTap: changeTap,
    );
  }

  // legacy builder removed – migrated to AnimatedBottomNavigationBar.builder
}
