import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/qna_diary_create/components/answer_input_bar.dart';
import 'package:cake/presentation/qna_diary_create/components/qna_progress_bar.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/app_chip.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/chat_bubble.dart';
import 'package:cake/ui/common_components/full_loading.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QnaDiaryCreateScreen extends StatelessWidget {
  const QnaDiaryCreateScreen({super.key});

  Future<void> _handleBack(
    BuildContext context,
    QnaDiaryCreateViewModel viewModel,
  ) async {
    if (viewModel.isGenerating) return;
    if (viewModel.answeredCount == 0) {
      context.pop();
      return;
    }
    final leave = await ConfirmSheet.show(
      context,
      title: '작성 중인 일기가 있어요',
      description: '지금 나가면 쓰던 내용이 저장되지 않아요.',
      primaryLabel: '계속 쓰기',
      secondaryLabel: '나가기',
      visual: Image.asset(AppImages.cakePlateStrawberry, width: 64, height: 70),
    );
    if (!leave && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryCreateViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (viewModel.state == ResultState.success) {
        viewModel.consumeSuccess();
        context.pushReplacement('/qna-confirm', extra: viewModel.generatedDiary);
        return;
      }
      final error = viewModel.errorMessage;
      if (error != null) {
        viewModel.clearError();
        final retryable = viewModel.isAllQuestionsDone;
        AppToast.show(
          context,
          error,
          tone: ToastTone.error,
          actionLabel: retryable ? '다시 시도' : null,
          onAction: retryable ? viewModel.retryGenerate : null,
          bottomOffset: 129,
        );
        return;
      }
      final info = viewModel.infoMessage;
      if (info != null) {
        viewModel.clearInfo();
        AppToast.show(context, info, bottomOffset: 129);
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
            body: Column(
              children: [
                Container(
                  color: ColorConfig.bgSurface,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        TopBar(
                          title: '오늘의 문답',
                          onBack: () => _handleBack(context, viewModel),
                        ),
                        Padding(
                          padding: AppSpacing.pageHorizontal,
                          child: QnaProgressBar(
                            progress: viewModel.progress,
                            label:
                                '${viewModel.currentQuestionNumber}/${viewModel.totalQuestions}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (viewModel.isEditMode) {
                        viewModel.cancelEditAnswer();
                      } else {
                        viewModel.unfocusKeyboard();
                      }
                    },
                    child: ListView(
                      controller: viewModel.scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        20,
                        AppSpacing.page,
                        16,
                      ),
                      children: [
                        for (final item in viewModel.chatList) ...[
                          ChatBubble(
                            message: item.content,
                            isUser: item.isUser,
                            animated: !item.isUser,
                            onTap: item.isUser && item.qnaIndex != null
                                ? () => viewModel.startEditAnswer(item.qnaIndex!)
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (viewModel.canSkip)
                          Padding(
                            padding: const EdgeInsets.only(left: 44),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AppChip(
                                label: '이 질문 건너뛰기',
                                height: 32,
                                onTap: viewModel.skipCurrentQuestion,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                AnswerInputBar(
                  controller: viewModel.textController,
                  focusNode: viewModel.focusNode,
                  onSend: viewModel.submitAnswer,
                  enabled: !viewModel.isGenerating && !viewModel.isAllQuestionsDone,
                ),
              ],
            ),
          ),
          if (viewModel.isGenerating)
            const Positioned.fill(
              child: FullLoading(messages: FullLoading.qnaMessages),
            ),
        ],
      ),
    );
  }
}
