import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/presentation/home/components/month_calendar.dart';
import 'package:cake/presentation/home/components/month_picker_sheet.dart';
import 'package:cake/presentation/home/home_view_model.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/diary_card.dart';
import 'package:cake/ui/common_components/home_header.dart';
import 'package:cake/ui/common_components/segmented_control.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final topInset = MediaQuery.paddingOf(context).top;
    final isCalendar = viewModel.segment == HomeSegment.calendar;

    return Container(
      color: ColorConfig.bgPage,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    HomeHeader(
                      expanded: isCalendar,
                      greeting: viewModel.greeting,
                      topInset: topInset,
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                Positioned.fill(
                  top: topInset +
                      (isCalendar
                          ? HomeHeader.expandedHeight
                          : HomeHeader.collapsedHeight) -
                      20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ColorConfig.bgPage,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xxl),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            16,
                            AppSpacing.page,
                            12,
                          ),
                          child: SegmentedControl(
                            labels: const ['캘린더', '리스트'],
                            selectedIndex: isCalendar ? 0 : 1,
                            onChanged: (i) => viewModel.setSegment(
                              i == 0 ? HomeSegment.calendar : HomeSegment.list,
                            ),
                          ),
                        ),
                        Expanded(
                          child: isCalendar
                              ? _CalendarTab(viewModel: viewModel)
                              : _ListTab(viewModel: viewModel),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final HomeViewModel viewModel;

  const _CalendarTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final diaries = viewModel.selectedDayDiaries;
    return RefreshIndicator(
      color: ColorConfig.brandBlue,
      onRefresh: viewModel.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 24),
        children: [
          MonthCalendar(
            focusedMonth: viewModel.focusedMonth,
            selectedDay: viewModel.selectedDay,
            today: viewModel.today,
            diariesOn: viewModel.diariesOn,
            onDaySelected: viewModel.selectDay,
            onPrevious: viewModel.previousMonth,
            onNext: viewModel.nextMonth,
            onTitleTap: () async {
              final picked = await MonthPickerSheet.show(
                context,
                initial: viewModel.focusedMonth,
                minYear: 2023,
                maxYear: viewModel.today.year + 1,
              );
              if (picked != null) viewModel.moveToMonth(picked);
            },
          ),
          const SizedBox(height: 12),
          if (!viewModel.hasAnyDiary && viewModel.isFocusedMonthEmpty)
            _FirstDiaryEmptyCard()
          else if (viewModel.isFocusedMonthEmpty)
            _EmptyMonth(viewModel: viewModel)
          else if (diaries.isEmpty)
            _EmptyDay()
          else
            for (final diary in diaries) ...[
              DiaryCard(
                key: ValueKey(diary.id),
                diary: diary,
                onTap: () => context.push('/diary-detail', extra: diary.id),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _FirstDiaryEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      gradient: AppGradients.cardTint,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Image.asset(AppImages.cakePlateStrawberry, width: 59, height: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('아직 모은 조각이 없어요', style: TextConfig.bodyLStrong),
                const SizedBox(height: 4),
                Text(
                  '아래 버튼을 눌러 오늘의 첫 조각을 구워보세요',
                  style: TextConfig.label.copyWith(
                    color: ColorConfig.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMonth extends StatelessWidget {
  final HomeViewModel viewModel;

  const _EmptyMonth({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            '${viewModel.focusedMonth.month}월에는 남긴 조각이 없어요',
            style: TextConfig.bodyMStrong.copyWith(
              color: ColorConfig.textSecondary,
            ),
          ),
          if (!viewModel.isFocusedMonthCurrent) ...[
            const SizedBox(height: 12),
            AppChip(
              label: '이번 달로 돌아가기',
              style: AppChipStyle.tonal,
              onTap: viewModel.moveToCurrentMonth,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '이 날에는 남긴 조각이 없어요',
          style: TextConfig.bodyMStrong.copyWith(
            color: ColorConfig.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final HomeViewModel viewModel;

  const _ListTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isListEmpty) return _ListEmpty();

    final items = viewModel.listItems;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          viewModel.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: ColorConfig.brandBlue,
        onRefresh: viewModel.refresh,
        child: ListView.separated(
          controller: viewModel.listScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 24),
          itemCount: items.length + 1 + (viewModel.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateTime.now().month}월 · ${viewModel.totalCount}조각',
                    style: TextConfig.label.copyWith(
                      color: ColorConfig.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      for (final sort in SortType.values) ...[
                        AppChip(
                          label: sort.text,
                          height: 32,
                          style: viewModel.sortType == sort
                              ? AppChipStyle.tonal
                              : AppChipStyle.ghost,
                          onTap: () => viewModel.setSortType(sort),
                        ),
                        if (sort != SortType.values.last)
                          const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ],
              );
            }
            if (index > items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorConfig.brandBlue,
                    ),
                  ),
                ),
              );
            }
            final diary = items[index - 1];
            return DiaryCard(
              key: ValueKey(diary.id),
              diary: diary,
              onTap: () => context.push('/diary-detail', extra: diary.id),
            );
          },
        ),
      ),
    );
  }
}

class _ListEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
        children: [
          Image.asset(AppImages.cakePlateStrawberry, width: 88, height: 96),
          const SizedBox(height: 12),
          Text('아직 모은 조각이 없어요', style: TextConfig.titleS),
          const SizedBox(height: 12),
          Text(
            '첫 일기를 쓰면 여기에 차곡차곡 쌓여요.\n아래 연필 버튼을 눌러 시작해 보세요.',
            textAlign: TextAlign.center,
            style: TextConfig.bodyS.copyWith(color: ColorConfig.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// 리스트 메타 라벨 등에서 쓰는 월 라벨
String monthLabel(DateTime date) => DateConverter.toYearMonth(date);
