import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(0, -1), // 위쪽으로 그림자 효과
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: ColorConfig.bottomNavi,
        notchMargin: 0.0,
        elevation: 0.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem('캘린더 보기', Icons.calendar_month_outlined, 0),
            _buildNavItem('목록 보기', Icons.list_alt_rounded, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String tag, IconData icon, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? ColorConfig.primary : ColorConfig.disabled;

    return Expanded(
      child: MaterialButton(
        onPressed: () => changeTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: getWidth(25)),
            SizedBox(height: getHeight(6)),
            Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: getWidth(10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
