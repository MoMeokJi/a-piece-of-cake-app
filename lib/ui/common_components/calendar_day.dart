import 'package:cake/ui/common_components/diary_card.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

enum CalendarDayState { normal, saturday, sunday, muted, selected, today }

/// 캘린더 날짜 칸 46×44. 숫자는 위쪽 고정, 컬러 막대는 아래 (없어도 줄 맞음).
class CalendarDay extends StatelessWidget {
  final int day;
  final CalendarDayState state;
  final Color? firstColor;
  final Color? secondColor;
  final VoidCallback? onTap;

  const CalendarDay({
    super.key,
    required this.day,
    required this.state,
    this.firstColor,
    this.secondColor,
    this.onTap,
  });

  bool get _hasColor => firstColor != null && secondColor != null;

  @override
  Widget build(BuildContext context) {
    final textColor = switch (state) {
      CalendarDayState.saturday || CalendarDayState.today =>
        ColorConfig.textAccent,
      CalendarDayState.sunday => ColorConfig.textDanger,
      CalendarDayState.muted => ColorConfig.textDisabled,
      _ => ColorConfig.textPrimary,
    };
    final strong =
        state == CalendarDayState.selected || state == CalendarDayState.today;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 44,
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == CalendarDayState.selected
                    ? ColorConfig.actionPrimary
                    : null,
                border: state == CalendarDayState.today
                    ? Border.all(color: ColorConfig.borderFocus, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString().padLeft(2, '0'),
                style: (strong ? TextConfig.numberMStrong : TextConfig.numberM)
                    .copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: 3),
            if (_hasColor)
              DiaryColorBar(
                first: firstColor!,
                second: secondColor!,
                width: 16,
                height: 5,
              ),
          ],
        ),
      ),
    );
  }
}
