import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/main/components/write_type_sheet.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/bottom_nav.dart';
import 'package:cake/ui/common_components/brand_mark.dart';
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
        visual: const BrandMark(),
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

  static bool _isDiaryDetailOnTop(BuildContext context, int diaryId) {
    final top =
        GoRouter.of(context).routerDelegate.currentConfiguration.lastOrNull;
    if (top is! ImperativeRouteMatch ||
        top.matches.uri.path != '/diary-detail') {
      return false;
    }
    final extra = top.matches.extra;
    return extra == diaryId || (extra is DiaryDetail && extra.id == diaryId);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    // 푸시 알림 탭으로 열어야 할 일기 상세. 빌드가 끝난 뒤 한 번만 민다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final diaryId = viewModel.diaryIdToOpen;
      if (diaryId == null) return;
      viewModel.clearDiaryToOpen();
      // 같은 일기 상세가 맨 위에 있으면 그 화면이 알아서 갱신한다. 한 장 더 쌓지 않는다.
      if (_isDiaryDetailOnTop(context, diaryId)) return;
      context.push('/diary-detail', extra: diaryId);
    });

    return Scaffold(
      backgroundColor: ColorConfig.bgPage,
      body: navigationShell,
      extendBody: false,
      // FAB는 바텀바 안이 아니라 Scaffold 슬롯에 둔다. 바 위로 튀어나온 부분까지 눌리게 하기 위해서다.
      floatingActionButton: WriteFab(onTap: () => _onFabTap(context)),
      floatingActionButtonLocation: const WriteFabLocation(),
      bottomNavigationBar: BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
