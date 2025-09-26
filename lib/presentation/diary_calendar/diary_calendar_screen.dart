import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/core/extensions/color_extensions.dart';
import 'package:cake/domain/model/diary.dart';
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

        // 선택된 날짜의 일기들 (스크롤 가능)
        _buildSelectedDayDiaries(viewModel),
      ],
    );
  }

  Widget _buildSelectedDayDiaries(DiaryCalendarViewModel viewModel) {
    // 선택된 날짜에 일기가 없을 때
    if (viewModel.selectedDayDiaryList.isEmpty) {
      final dateText =
          '${viewModel.selectedDay.month}월 ${viewModel.selectedDay.day}일';
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '$dateText에는 일기가 없습니다.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: viewModel.selectedDayDiaryList.length,
        itemBuilder: (context, index) {
          final diary = viewModel.selectedDayDiaryList[index];
          return _buildDiaryCard(diary);
        },
      ),
    );
  }

  Widget _buildDiaryCard(Diary diary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 일기 요약
            Text(
              diary.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 색상 표시
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: diary.firstColorHex.toColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: diary.secondColorHex.toColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                const Spacer(),

                // 음악 정보
                if (diary.musicTitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${diary.musicTitle} - ${diary.musicArtist}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 작성일
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${diary.createdAt.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),

                // 더보기 버튼
                TextButton(
                  onPressed: () {
                    // TODO: 일기 상세보기 페이지로 이동
                    print('일기 상세보기: ${diary.id}');
                  },
                  child: const Text(
                    '자세히 보기',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
