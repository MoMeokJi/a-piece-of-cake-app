import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/qna_diary_create/components/chat_list.dart';
import 'package:cake/presentation/qna_diary_create/components/bottom_fixed_input_section.dart';
import 'package:cake/presentation/qna_diary_create/components/loading_overlay.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/dialog/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QnaDiaryCreateScreen extends StatelessWidget {
  const QnaDiaryCreateScreen({super.key});

  Future<void> _handleBackPress(BuildContext context, bool isLoading) async {
    if (isLoading) return;
    final shouldExit = await DialogUtils.showExitDiaryDialog(context: context);
    if (shouldExit == true && context.mounted) {
      context.pop();
    }
  }

  void _showRetrySnackbar(BuildContext context, VoidCallback onRetry) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('일기 생성에 실패했어요.'),
          action: SnackBarAction(label: '다시 시도', onPressed: onRetry),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryCreateViewModel>();
    final isLoading = viewModel.state == ResultState.loading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress(context, isLoading);
      },
      child: Stack(
        children: [
          KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.state == ResultState.success) {
                  context.pushReplacement(
                    '/qna-edit',
                    extra: viewModel.generatedDiary,
                  );
                } else if (viewModel.state == ResultState.error) {
                  _showRetrySnackbar(context, viewModel.retrySubmit);
                }
              });

              return Scaffold(
                backgroundColor: ColorConfig.background,
                appBar: CommonMainAppBar(
                  onBackPressed: () => _handleBackPress(context, isLoading),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (viewModel.isEditMode) {
                              viewModel.cancelEditAnswer();
                            } else {
                              viewModel.unfocusKeyboard();
                            }
                          },
                          child: ChatList(
                            chatList: viewModel.chatList,
                            scrollController: viewModel.scrollController,
                            onEditAnswer: isLoading
                                ? null
                                : viewModel.startEditAnswer,
                          ),
                        ),
                      ),
                      BottomFixedInputSection(
                        textController: viewModel.textController,
                        focusNode: viewModel.focusNode,
                        onCompleted: viewModel.saveAnswer,
                        isKeyboardVisible: isKeyboardVisible,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
