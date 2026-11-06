import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/common/components/attachment_row.dart';
import 'package:cake/presentation/common/components/diary_editor_card.dart';
import 'package:cake/presentation/common/components/diary_toolbar.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/full_loading.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// 일기 저장 중 429를 받았을 때 띄우는 안내.
Future<void> showDailyLimitSheet(BuildContext context) => ConfirmSheet.show(
  context,
  title: '오늘의 조각을 모두 구웠어요',
  description: '일기는 하루에 3개까지 쓸 수 있어요.\n내일 또 만나요!',
  primaryLabel: '확인',
  visual: Image.asset(AppImages.cakePlateStrawberry, width: 64, height: 70),
);

/// 작성 중 나가기 확인. true면 나간다.
Future<bool> confirmLeaveDiary(BuildContext context) async {
  final stay = await ConfirmSheet.show(
    context,
    title: '작성 중인 일기가 있어요',
    description: '지금 나가면 쓰던 내용이 저장되지 않아요.',
    primaryLabel: '계속 쓰기',
    secondaryLabel: '나가기',
    visual: Image.asset(AppImages.cakePlateStrawberry, width: 64, height: 70),
  );
  return !stay;
}

class FreeDiaryCreateScreen extends StatelessWidget {
  const FreeDiaryCreateScreen({super.key});

  Future<void> _handleBack(
    BuildContext context,
    FreeDiaryCreateViewModel viewModel,
  ) async {
    if (viewModel.isSaving) return;
    if (!viewModel.hasContent) {
      context.pop();
      return;
    }
    final leave = await confirmLeaveDiary(context);
    if (leave && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreeDiaryCreateViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      if (viewModel.state == ResultState.success) {
        viewModel.consumeSuccess();
        context.pushReplacement('/diary-detail', extra: viewModel.completedDiary);
        return;
      }
      if (viewModel.dailyLimitExceeded) {
        viewModel.clearDailyLimit();
        await showDailyLimitSheet(context);
        if (context.mounted) context.pop();
        return;
      }
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(context, toast, tone: ToastTone.error, bottomOffset: 88);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context, viewModel);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: ColorConfig.bgPage,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TopBar(
                    title: '자유 일기',
                    subtitle: DateConverter.toMonthDayWeekday(DateTime.now()),
                    onBack: () => _handleBack(context, viewModel),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        12,
                        AppSpacing.page,
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DiaryEditorCard(
                              controller: viewModel.textController,
                              focusNode: viewModel.focusNode,
                              hintText: '오늘 하루를 자유롭게 적어 주세요',
                            ),
                          ),
                          const SizedBox(height: 6),
                          AttachmentRow(
                            images: viewModel.attachments.images,
                            max: viewModel.attachments.max,
                            onRemove: viewModel.attachments.removeAt,
                          ),
                        ],
                      ),
                    ),
                  ),
                  DiaryToolbar(
                    onCamera: () {
                      viewModel.unfocus();
                      viewModel.attachments.pickFromCamera();
                    },
                    onGallery: () {
                      viewModel.unfocus();
                      viewModel.attachments.pickFromGallery();
                    },
                    imageCount: viewModel.attachments.count,
                    imageMax: viewModel.attachments.max,
                    actionLabel: '완성하기',
                    actionEnabled: viewModel.canComplete,
                    onAction: viewModel.completeDiary,
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.isSaving)
            const Positioned.fill(
              child: FullLoading(messages: FullLoading.saveMessages),
            ),
        ],
      ),
    );
  }
}
