import 'package:cake/presentation/common/components/diary_editor_card.dart';
import 'package:cake/presentation/diary_edit/diary_edit_view_model.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_screen.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/common_components/photo_thumb.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DiaryEditScreen extends StatelessWidget {
  const DiaryEditScreen({super.key});

  Future<void> _handleBack(BuildContext context, DiaryEditViewModel viewModel) async {
    if (viewModel.isSaving) return;
    if (!viewModel.isModified) {
      context.pop();
      return;
    }
    final leave = await confirmLeaveDiary(context);
    if (leave && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryEditViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(context, toast, tone: ToastTone.error, bottomOffset: 96);
      }
      final saved = viewModel.savedBody;
      if (saved != null) context.pop(saved);
    });

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context, viewModel);
      },
      child: GradientScaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TopBar(
                title: '일기 수정',
                subtitle: DateConverter.toMonthDayWeekday(viewModel.diary.createdAt),
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
                          showFocusBorder: true,
                        ),
                      ),
                      if (viewModel.diary.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final url in viewModel.diary.imageUrls) ...[
                                PhotoThumb.network(url),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
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
                child: AppButton(
                  label: '수정 완료',
                  enabled: viewModel.canSave,
                  isLoading: viewModel.isSaving,
                  onPressed: viewModel.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
