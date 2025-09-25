import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
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
        // 캘린더 (고정)
        _buildCalendar(viewModel),

        // 선택된 날짜의 일기들 (스크롤 가능)
        if (viewModel.selectedDay != null) _buildSelectedDayDiaries(viewModel),
      ],
    );
  }

  Widget _buildCalendar(DiaryCalendarViewModel viewModel) {
    return TableCalendar<dynamic>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: viewModel.focusedDay,
      calendarFormat: CalendarFormat.month, // 월간 보기로 고정
      eventLoader: viewModel.getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Colors.red),
        holidayTextStyle: TextStyle(color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, // 포맷 변경 버튼 숨김
        titleCentered: true,
        formatButtonShowsNext: false,
      ),
      calendarBuilders: CalendarBuilders(
        // 일기가 있는 날짜에 점 표시 (최대 3개)
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            final eventCount = events.length;
            final displayCount = eventCount > 3 ? 3 : eventCount;

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(displayCount, (index) {
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            );
          }
          return null;
        },
        // 선택된 날짜 스타일
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        // 오늘 날짜 스타일
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: viewModel.onDaySelected,
      onPageChanged: (focusedDay) {
        viewModel.onPageChanged(focusedDay);
        // 월이 변경될 때 해당 월의 일기들 로드
        viewModel.loadMonthlyDiaries(focusedDay);
      },
      selectedDayPredicate: (day) {
        return isSameDay(viewModel.selectedDay, day);
      },
    );
  }

  Widget _buildSelectedDayDiaries(DiaryCalendarViewModel viewModel) {
    if (viewModel.selectedDayDiaries.isEmpty) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              '이 날에는 일기가 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: viewModel.selectedDayDiaries.length,
        itemBuilder: (context, index) {
          final diary = viewModel.selectedDayDiaries[index];
          return _buildDiaryCard(diary);
        },
      ),
    );
  }

  Widget _buildDiaryCard(dynamic diary) {
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
                    color: Color(int.parse(diary.firstColorHex)),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(int.parse(diary.secondColorHex)),
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
