import 'dart:io';

import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryListViewModel>();

    return CustomScrollView(
      slivers: [
        // 상단 버튼 두 개 (스크롤 시 사라졌다 나타남)
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
              vertical: getHeight(10),
              horizontal: getWidth(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorConfig.white,
                    backgroundColor: ColorConfig.primary,
                    side: BorderSide(color: ColorConfig.primary),
                  ),
                  child: Text(
                    '최신순',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: getWidth(15)),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorConfig.gray3,
                    backgroundColor: ColorConfig.white,
                    side: BorderSide(color: ColorConfig.gray4),
                  ),
                  child: Text(
                    '등록순',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 리스트
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('다이어리 항목 ${index + 1}'),
                    subtitle: Text(
                      '${DateTime.now().add(Duration(days: index)).toString().substring(0, 10)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ),
              );
            },
            childCount: 10, // 10개 아이템
          ),
        ),
      ],
    );
  }
}
