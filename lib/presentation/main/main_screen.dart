import 'package:cake/presentation/main/components/write_type_sheet.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/bottom_nav.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({required this.navigationShell, super.key});

  Future<void> _onFabTap(BuildContext context) async {
    final viewModel = context.read<MainViewModel>();
    final canWrite = await viewModel.canWriteToday();
    if (!context.mounted) return;

    if (!canWrite) {
      await ConfirmSheet.show(
        context,
        title: '오늘의 조각을 모두 구웠어요',
        description: '일기는 하루에 ${viewModel.dailyLimit}개까지 쓸 수 있어요.\n내일 또 만나요!',
        primaryLabel: '확인',
        visual: Image.asset(AppImages.cakePlateStrawberry, width: 64, height: 70),
      );
      return;
    }

    final type = await WriteTypeSheet.show(context);
    if (type == null || !context.mounted) return;
    switch (type) {
      case WriteType.qna:
        context.push('/qna-diary');
      case WriteType.free:
        context.push('/free-diary');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPage,
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onFabTap: () => _onFabTap(context),
      ),
    );
  }
}
