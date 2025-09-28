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
        SliverAppBar(
          automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          floating: true, // 스크롤 올릴 때 바로 나타남
          snap: true, // 빠르게 나타나고 사라짐
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
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
          sliver: SliverList.separated(
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
