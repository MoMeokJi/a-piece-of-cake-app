import 'package:cake/core/extensions/color_extensions.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/calendar_day.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';

/// 월 캘린더 카드. 월요일 시작, 토=파랑, 일=빨강, 이번 달 밖 날짜는 흐리게.
class MonthCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final DateTime today;
  final List<Diary> Function(DateTime day) diariesOn;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTitleTap;

  const MonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.today,
    required this.diariesOn,
    required this.onDaySelected,
    required this.onPrevious,
    required this.onNext,
    required this.onTitleTap,
  });

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    // 월요일 시작: weekday 1(월)~7(일)
    final leading = firstOfMonth.weekday - 1;
    final gridStart = firstOfMonth.subtract(Duration(days: leading));
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIconButton(
                icon: AppIcons.back,
                iconSize: 20,
                semanticLabel: '이전 달',
                onPressed: onPrevious,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onTitleTap,
                child: Text(
                  DateConverter.toYearMonth(focusedMonth),
                  style: TextConfig.titleS,
                ),
              ),
              const SizedBox(width: 16),
              AppIconButton(
                icon: AppIcons.chevronRight,
                iconSize: 20,
                semanticLabel: '다음 달',
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              return Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        SizedBox(
                          width: cellWidth,
                          height: 18,
                          child: Center(
                            child: Text(
                              _weekdays[i],
                              style: TextConfig.caption.copyWith(
                                color: switch (i) {
                                  5 => ColorConfig.textAccent,
                                  6 => ColorConfig.textDanger,
                                  _ => ColorConfig.textTertiary,
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    runSpacing: 2,
                    children: [
                      for (var i = 0; i < totalCells; i++)
                        SizedBox(
                          width: cellWidth,
                          child: Center(child: _cell(gridStart.add(Duration(days: i)))),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cell(DateTime day) {
    final inMonth = day.month == focusedMonth.month;
    final diaries = diariesOn(day);
    final state = !inMonth
        ? CalendarDayState.muted
        : DateConverter.isSameDay(day, selectedDay)
        ? CalendarDayState.selected
        : DateConverter.isSameDay(day, today)
        ? CalendarDayState.today
        : day.weekday == DateTime.saturday
        ? CalendarDayState.saturday
        : day.weekday == DateTime.sunday
        ? CalendarDayState.sunday
        : CalendarDayState.normal;
    final first = diaries.isEmpty ? null : diaries.first;
    return CalendarDay(
      day: day.day,
      state: state,
      firstColor: first?.firstColor.hex.toColor(),
      secondColor: first?.secondColor.hex.toColor(),
      onTap: () => onDaySelected(day),
    );
  }
}
