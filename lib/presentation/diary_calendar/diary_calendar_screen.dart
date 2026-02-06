import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_calendar/components/month_picker_dialog.dart';
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
        // 캘린더 영역
        Padding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
          child: TableCalendar<dynamic>(
            firstDay: viewModel.minDate,
            lastDay: viewModel.maxDate,
            focusedDay: viewModel.focusedDate,
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
              markersAnchor: getHeight(0.8),
              markerDecoration: BoxDecoration(
                color: ColorConfig.markerDotColor,
                shape: BoxShape.circle,
              ),
            ),
            onHeaderTapped: (focusedDay) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => MonthPickerDialog(
                  initialDate: viewModel.focusedDate,
                  minYear: viewModel.minDate.year,
                  maxYear: viewModel.maxDate.year,
                  onDateSelected: (selectedDate) {
                    viewModel.updateFocusedMonth(selectedDate);
                  },
                ),
              );
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              formatButtonShowsNext: false,
              headerPadding: EdgeInsets.symmetric(vertical: getHeight(8)),
              titleTextStyle: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
              ),
              leftChevronMargin: EdgeInsets.only(left: getWidth(75)),
              rightChevronMargin: EdgeInsets.only(right: getWidth(75)),
              leftChevronIcon: Icon(
                Icons.arrow_left,
                size: getWidth(35),
                color: ColorConfig.gray1,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_right,
                size: getWidth(35),
                color: ColorConfig.gray1,
              ),
            ),
          ),
        ),

        // 캘린더 리스트 사이 간격
        SizedBox(height: getHeight(20)),

        // 일기 리스트 영역
        (viewModel.selectedDayDiaryList.isEmpty)
            ? Expanded(child: _buildEmptyText())
            : Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    left: getWidth(20),
                    right: getWidth(20),
                    bottom: getHeight(25), // 리스트 마지막 여백 추가
                  ),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: getHeight(12)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '작성한 일기가 없습니다.',
            style: TextStyle(fontSize: getWidth(16), color: ColorConfig.gray1),
          ),
          SizedBox(height: getHeight(5)),
          Text(
            '오늘의 이야기를 기록해보세요',
            style: TextStyle(fontSize: getWidth(14), color: ColorConfig.gray3),
          ),
        ],
      ),
    );
  }
}
