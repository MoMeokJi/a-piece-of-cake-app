import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/ui/common_components/diary_card.dart';
import 'package:cake/ui/style/text_config.dart';
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
        // 캘린더 카드 영역
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(20),
            vertical: getHeight(12),
          ),
          child: TableCalendar<dynamic>(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: viewModel.focusedMonth,
            calendarFormat: CalendarFormat.month, // 월간 보기
            eventLoader: viewModel.getDiaryListForMarker,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: viewModel.onDaySelected,
            onPageChanged: (focusedDay) =>
                viewModel.loadMonthlyDiaries(focusedDay),
            selectedDayPredicate: (day) =>
                isSameDay(viewModel.selectedDay, day),
            daysOfWeekHeight: getHeight(20), // 요일 헤더 높이
            rowHeight: getHeight(42), // 각 행의 높이
            locale: 'ko_KR',
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: TextConfig.calendarFontSize,
                color: ColorConfig.weekdayColor,
              ),
              weekendStyle: TextStyle(
                fontSize: TextConfig.calendarFontSize,
                color: ColorConfig.weekendColor,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideTextStyle: TextStyle(
                color: ColorConfig.outsideDayColor,
                fontSize: TextConfig.calendarFontSize,
              ),
              defaultTextStyle: TextStyle(
                color: ColorConfig.weekdayColor,
                fontSize: TextConfig.calendarFontSize,
              ),
              todayTextStyle: TextStyle(
                color: ColorConfig.weekdayColor,
                fontSize: TextConfig.calendarFontSize,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: TextConfig.calendarFontSize,
              ),
              weekendTextStyle: TextStyle(
                color: ColorConfig.weekendColor,
                fontSize: TextConfig.calendarFontSize,
              ),
              holidayTextStyle: TextStyle(
                color: ColorConfig.weekendColor,
                fontSize: TextConfig.calendarFontSize,
              ),
              selectedDecoration: BoxDecoration(
                color: ColorConfig.selectDayColor,
                shape: BoxShape.circle,
              ),

              todayDecoration: BoxDecoration(
                color: ColorConfig.todayColor,
                shape: BoxShape.circle,
              ),

              // 마커 스타일
              markersMaxCount: 3,
              markerSize: getWidth(6),
              markerMargin: EdgeInsets.symmetric(horizontal: getWidth(1)),
              markersAlignment: Alignment.topCenter,
              markersAnchor: 0.7,
              markerDecoration: BoxDecoration(
                color: ColorConfig.markerDotColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              formatButtonShowsNext: false,
              headerPadding: EdgeInsets.symmetric(vertical: getHeight(8)),
              titleTextStyle: TextStyle(
                fontSize: getWidth(16), // 제목 폰트 크기 줄임
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                size: getWidth(24), // 좌측 화살표 크기 줄임
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                size: getWidth(24), // 우측 화살표 크기 줄임
              ),
            ),
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
