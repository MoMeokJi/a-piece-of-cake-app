import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/ui/common_components/diary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryCalendarScreen extends StatelessWidget {
  const DiaryCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryCalendarViewModel>();

    return Column(
      children: [
        // 캘린더  영역
        TableCalendar<dynamic>(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: viewModel.focusedMonth,
          calendarFormat: CalendarFormat.month, // 월간 보기
          eventLoader: viewModel.getDiaryListForMarker,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          onDaySelected: viewModel.onDaySelected,
          onPageChanged: (focusedDay) =>
              viewModel.loadMonthlyDiaries(focusedDay),
          selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
          calendarStyle: CalendarStyle(
            outsideTextStyle: TextStyle(color: ColorConfig.outsideDayColor),
            defaultTextStyle: TextStyle(color: ColorConfig.weekdayColor),
            weekendTextStyle: TextStyle(color: ColorConfig.weekendColor),
            holidayTextStyle: TextStyle(color: ColorConfig.weekendColor),
            // 선택된 날짜 스타일
            selectedDecoration: BoxDecoration(
              color: ColorConfig.selectDayColor,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            // 오늘 날짜 스타일
            todayDecoration: BoxDecoration(
              color: ColorConfig.todayColor,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: ColorConfig.weekdayColor),
            // 마커 스타일
            markersMaxCount: 3,
            markerSize: getWidth(6),
            markerMargin: EdgeInsets.symmetric(horizontal: getWidth(1)),
            markersAlignment: Alignment.topCenter,
            markersAnchor: 1.8,
            markerDecoration: BoxDecoration(
              color: ColorConfig.markerDotColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, // 포맷 변경 버튼 숨김
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),

        // 일기 리스트 영역
        (viewModel.selectedDayDiaryList.isEmpty)
            ? _buildEmptyText()
            : Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(16),
                    vertical: getHeight(16),
                  ),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: getHeight(8)),
                  itemCount: viewModel.selectedDayDiaryList.length,
                  itemBuilder: (context, index) {
                    final diary = viewModel.selectedDayDiaryList[index];
                    return DiaryCard(key: ValueKey(diary.id), diary: diary);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyText() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '작성한 일기가 없습니다.',
              style: TextStyle(
                fontSize: getWidth(16),
                color: ColorConfig.gray1,
              ),
            ),
            SizedBox(height: getHeight(8)),
            Text(
              '오늘의 이야기를 기록해보세요',
              style: TextStyle(
                fontSize: getWidth(14),
                color: ColorConfig.gray3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
