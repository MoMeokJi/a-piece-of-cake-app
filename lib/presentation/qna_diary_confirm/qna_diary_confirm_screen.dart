import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/common/components/attachment_row.dart';
import 'package:cake/presentation/common/components/diary_editor_card.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_screen.dart';
import 'package:cake/presentation/qna_diary_confirm/qna_diary_confirm_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/full_loading.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/common_components/surface_card.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QnaDiaryConfirmScreen extends StatelessWidget {
  const QnaDiaryConfirmScreen({super.key});

  Future<void> _handleBack(
    BuildContext context,
    QnaDiaryConfirmViewModel viewModel,
  ) async {
    if (viewModel.isSaving) return;
    final leave = await confirmLeaveDiary(context);
    if (leave && context.mounted) context.pop();
  }

  Future<void> _pickImage(
    BuildContext context,
    QnaDiaryConfirmViewModel viewModel,
  ) async {
    final index = await ActionSheet.show(
      context,
      items: const [ActionSheetItem('앨범에서 고르기'), ActionSheetItem('사진 찍기')],
    );
    if (index == 0) await viewModel.attachments.pickFromGallery();
    if (index == 1) await viewModel.attachments.pickFromCamera();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryConfirmViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      if (viewModel.state == ResultState.success) {
        viewModel.consumeSuccess();
        context.pushReplacement(
          '/diary-detail',
          extra: viewModel.completedDiary,
        );
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
        AppToast.show(context, toast, tone: ToastTone.error, bottomOffset: 96);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context, viewModel);
      },
      child: Stack(
        children: [
          GradientScaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TopBar(
                    title: '오늘의 일기가 구워졌어요',
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
                            child: viewModel.isEditing
                                ? DiaryEditorCard(
                                    controller: viewModel.textController,
                                    focusNode: viewModel.focusNode,
                                    showFocusBorder: true,
                                  )
                                : _ReadCard(viewModel: viewModel),
                          ),
                          const SizedBox(height: 6),
                          AttachmentRow(
                            images: viewModel.attachments.images,
                            max: viewModel.attachments.max,
                            onRemove: viewModel.attachments.removeAt,
                            onAdd: () => _pickImage(context, viewModel),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _Footer(viewModel: viewModel),
                ],
              ),
            ),
          ),
          if (viewModel.showsLoading)
            const Positioned.fill(
              child: FullLoading(messages: FullLoading.saveMessages),
            ),
        ],
      ),
    );
  }
}

class _ReadCard extends StatelessWidget {
  final QnaDiaryConfirmViewModel viewModel;

  const _ReadCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(viewModel.content, style: TextConfig.bodyMLong),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: AppChip(
              label: '직접 다듬기',
              icon: const AppIcon(AppIcons.pen, size: 16),
              onTap: viewModel.startEditing,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final QnaDiaryConfirmViewModel viewModel;

  const _Footer({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: ColorConfig.bgSurface,
        border: Border(top: BorderSide(color: ColorConfig.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        12,
        AppSpacing.page,
        bottomInset > 0 ? bottomInset : 12,
      ),
      child: viewModel.isEditing
          ? AppButton(label: '다듬기 완료', onPressed: viewModel.finishEditing)
          : AppButton(
              label: '이대로 완성하기',
              enabled: viewModel.canComplete,
              onPressed: viewModel.completeDiary,
            ),
    );
  }
}
