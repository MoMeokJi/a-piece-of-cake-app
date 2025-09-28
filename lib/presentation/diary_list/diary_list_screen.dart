import 'dart:io';
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/ui/common_components/diary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryListViewModel>();

    return CustomScrollView(
      controller: viewModel.scrollController,
      slivers: [
        // 데이터가 있을 때만 SliverAppBar 표시
        if (viewModel.diaryList.isNotEmpty)
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            snap: true,
            toolbarHeight: (Platform.isIOS) ? getHeight(15) : getHeight(40),
            flexibleSpace: Padding(
              padding: EdgeInsets.symmetric(
                vertical: getHeight(8),
                horizontal: getWidth(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSortButton(
                    sortType: SortType.latest,
                    isSelected: viewModel.sortType == SortType.latest,
                    onPressed: () => viewModel.setSortType(SortType.latest),
                  ),
                  SizedBox(width: getWidth(15)),
                  _buildSortButton(
                    sortType: SortType.oldest,
                    isSelected: viewModel.sortType == SortType.oldest,
                    onPressed: () => viewModel.setSortType(SortType.oldest),
                  ),
                ],
              ),
            ),
          ),

        // 내용 부분
        SliverPadding(
          padding: EdgeInsets.only(
            left: getWidth(20),
            right: getWidth(20),
            bottom: getHeight(25), // 리스트 마지막 여백 추가
          ),
          sliver: viewModel.diaryList.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: getHeight(200)),
                    child: Column(
                      children: [
                        Text(
                          '당신의 첫 이야기를 기다리고 있어요',
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w600,
                            color: ColorConfig.gray1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: getHeight(8)),
                        Text(
                          '오늘의 작은 감정이나 일상의 사소한 순간도\n글로 남기면 의미 있는 추억이 될 거에요',
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: ColorConfig.gray2,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: viewModel.diaryList.length,
                  itemBuilder: (context, index) {
                    final diary = viewModel.diaryList[index];
                    return DiaryCard(key: ValueKey(diary.id), diary: diary);
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: getHeight(16)),
                ),
        ),
      ],
    );
  }

  Widget _buildSortButton({
    required SortType sortType,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? ColorConfig.white : ColorConfig.gray3,
        backgroundColor: isSelected ? ColorConfig.primary : ColorConfig.white,
        side: BorderSide(
          color: isSelected ? ColorConfig.primary : ColorConfig.gray4,
        ),
        textStyle: TextStyle(
          fontSize: getWidth(16),
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(15),
          vertical: getHeight(8),
        ),
      ),
      child: Text(sortType.text),
    );
  }
}
