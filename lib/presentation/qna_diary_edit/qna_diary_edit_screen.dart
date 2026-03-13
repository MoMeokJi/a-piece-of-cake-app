import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/qna_diary_edit/components/diary_edit_mode_body.dart';
import 'package:cake/presentation/qna_diary_edit/components/read_mode_text_box.dart';
import 'package:cake/presentation/qna_diary_edit/qna_diary_edit_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/common_components/diary_complete_loading_overlay.dart';
import 'package:cake/ui/common_components/diary_complete_fixed_bottom_bar.dart';
import 'package:cake/ui/common_components/diary_image_grid.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/dialog/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class QnaDiaryEditScreen extends StatelessWidget {
  const QnaDiaryEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryEditViewModel>();
    final isLoading = viewModel.state == ResultState.loading;

    Future<void> handleBackPress() async {
      if (isLoading) return;
      final shouldExit = await DialogUtils.showExitDiaryDialog(context: context);
      if (shouldExit == true && context.mounted) {
        context.pop();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.state == ResultState.success) {
        context.pushReplacement(
          '/diary-detail',
          extra: viewModel.completedDiary,
        );
      } else if (viewModel.state == ResultState.error) {
        //TODO: error 처리
      }
      if (viewModel.toastMessage != null) {
        toastification.show(
          context: context,
          type: ToastificationType.warning,
          style: ToastificationStyle.fillColored,
          primaryColor: ColorConfig.primary,
          title: Text(
            viewModel.toastMessage!,
            style: TextStyle(fontSize: getWidth(14)),
          ),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
          showProgressBar: false,
        );
        viewModel.clearToastMessage();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleBackPress();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: ColorConfig.background,
            appBar: CommonMainAppBar(
              onBackPressed: handleBackPress,
            ),
            body: SafeArea(
              child: viewModel.editMode
                  ? DiaryEditModeBody(
                      textEditingController: viewModel.textController,
                      focusNode: viewModel.focusNode,
                      onCompleted: viewModel.changeToReadMode,
                      unfocus: viewModel.unfocus,
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(25),
                              vertical: getHeight(15),
                            ),
                            child: Column(
                              children: [
                                ReadModeTextBox(
                                  content: viewModel.textController.text,
                                  onEdit: viewModel.changeToEditMode,
                                ),
                                SizedBox(height: getHeight(10)),
                                if (viewModel.pickedImages.isNotEmpty)
                                  DiaryImageGrid(
                                    images: viewModel.pickedImages,
                                    onRemove: (index) =>
                                        viewModel.removeImage(index),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        DiaryCompleteFixedBottomBar(
                          onGalleryTap: viewModel.getImageFromGallery,
                          onCameraTap: viewModel.getImageFromCamera,
                          onCompleted: viewModel.completeDiary,
                          currentImageCount: viewModel.pickedImages.length,
                        ),
                      ],
                    ),
            ),
          ),

          if (isLoading)
            DiaryCompleteLoadingOverlay(),
        ],
      ),
    );
  }
}
