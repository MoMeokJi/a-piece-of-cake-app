import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_detail/components/color_section.dart';
import 'package:cake/presentation/diary_detail/components/diary_body_card.dart';
import 'package:cake/presentation/diary_detail/components/flavor_section.dart';
import 'package:cake/presentation/diary_detail/components/music_section.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DiaryDetailScreen extends StatelessWidget {
  const DiaryDetailScreen({super.key});

  Future<void> _openMore(
    BuildContext context,
    DiaryDetailViewModel viewModel,
    DiaryDetail diary,
  ) async {
    final index = await ActionSheet.show(
      context,
      items: const [
        ActionSheetItem('수정하기'),
        ActionSheetItem('삭제하기', isDanger: true),
      ],
    );
    if (!context.mounted) return;
    if (index == 0) {
      final edited = await context.push<String>('/diary-edit', extra: diary);
      if (edited != null) viewModel.applyEditedBody(edited);
    } else if (index == 1) {
      final ok = await ConfirmSheet.show(
        context,
        title: '이 조각을 삭제할까요?',
        description:
            '${DateConverter.toMonthDay(diary.createdAt)}의 일기와 시식평, 컬러, 음악이\n함께 사라지고 되돌릴 수 없어요.',
        primaryLabel: '삭제하기',
        secondaryLabel: '취소',
        tone: ConfirmTone.danger,
      );
      if (ok) await viewModel.removeDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryDetailViewModel>();
    final diary = viewModel.diary;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(context, toast, tone: ToastTone.error);
      }
      if (viewModel.deleted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    });

    return Stack(
      children: [
        GradientScaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                TopBar(
                  title: diary == null
                      ? ''
                      : DateConverter.toMonthDayWeekday(diary.createdAt),
                  onBack: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  trailing: diary == null
                      ? null
                      : AppIconButton(
                          icon: AppIcons.more,
                          iconSize: 22,
                          semanticLabel: '더보기',
                          onPressed: () => _openMore(context, viewModel, diary),
                        ),
                ),
                Expanded(
                  child: diary == null
                      ? _LoadingOrError(viewModel: viewModel)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            12,
                            AppSpacing.page,
                            40,
                          ),
                          children: [
                            DiaryBodyCard(diary: diary),
                            const SizedBox(height: 16),
                            FlavorSection(diary: diary),
                            const SizedBox(height: 16),
                            ColorSection(diary: diary),
                            const SizedBox(height: 16),
                            MusicSection(
                              music: diary.music,
                              attempt: viewModel.playerAttempt,
                              onRetry: viewModel.retryPlayer,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        if (viewModel.isDeleting)
          const ColoredBox(
            color: ColorConfig.bgDim,
            child: Center(
              child: CircularProgressIndicator(color: ColorConfig.brandBlue),
            ),
          ),
      ],
    );
  }
}

class _LoadingOrError extends StatelessWidget {
  final DiaryDetailViewModel viewModel;

  const _LoadingOrError({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConfig.brandBlue),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.cakeSlice,
            width: 66,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.notFound ? '이미 사라진 조각이에요' : '일기를 불러오지 못했어요',
            style: TextConfig.titleS,
          ),
          const SizedBox(height: 12),
          if (!viewModel.notFound)
            AppChip(label: '다시 시도', onTap: viewModel.reload),
        ],
      ),
    );
  }
}
