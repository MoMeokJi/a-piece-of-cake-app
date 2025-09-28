import 'package:cake/presentation/main/components/diary_select_bottom_sheet.dart';
import 'package:cake/presentation/main/components/main_banner.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/main/components/bottom_navi.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    return Scaffold(
      backgroundColor: ColorConfig.background,
      body: Column(
        children: [
          // 상단 고정 배너
          MainBanner(),
          // 하단 탭 컨텐츠
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: BottomNavi(
        currentIndex: navigationShell.currentIndex,
        changeTap: (index) => navigationShell.goBranch(index),
      ),
      floatingActionButton: RawMaterialButton(
        constraints: BoxConstraints.tightFor(
          width: getWidth(80),
          height: getHeight(80),
        ),
        shape: const CircleBorder(),
        elevation: 2,
        fillColor: ColorConfig.primary,
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: ColorConfig.background,
            context: context,
            isScrollControlled: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return DiarySelectBottomSheet();
            },
          );
        },
        child: Icon(
          Icons.create_outlined,
          color: ColorConfig.white,
          size: getHeight(40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
