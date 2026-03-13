import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/ui/common_components/diary_image_grid.dart';
import 'package:cake/presentation/free_diary_create/components/diary_text_field.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/common_components/diary_complete_loading_overlay.dart';
import 'package:cake/ui/common_components/diary_complete_fixed_bottom_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/dialog/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class FreeDiaryCreateScreen extends StatelessWidget {
  const FreeDiaryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreeDiaryCreateViewModel>();
    final isLoading = viewModel.state == ResultState.loading;

    Future<void> handleBackPress() async {
      if (isLoading) return;
      if (viewModel.textController.text.isEmpty) {
        context.pop();
        return;
      }
      final shouldExit = await DialogUtils.showExitDiaryDialog(context: context);
      if (shouldExit == true && context.mounted) {
        context.pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleBackPress();
      },
      child: Stack(
        children: [
          KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
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

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Scaffold(
                  backgroundColor: ColorConfig.background,
                  appBar: CommonMainAppBar(
                    onBackPressed: handleBackPress,
                  ),
                  body: Stack(
                    children: [
                      SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getWidth(25),
                                  vertical: getHeight(15),
                                ),
                                child: Column(
                                  children: [
                                    DiaryTextField(
                                      textController: viewModel.textController,
                                      focusNode: viewModel.focusNode,
                                      isKeyboardVisible: isKeyboardVisible,
                                      hintText: '하고 싶은 말을 자유롭게 적어주세요',
                                    ),
                                    SizedBox(height: getHeight(10)),
                                    if (viewModel.pickedImages.isNotEmpty)
                                      DiaryImageGrid(
                                        images: viewModel.pickedImages,
                                        onRemove: (index) =>
                                            viewModel.removeImage(index),
                                      ),
                                    if (isKeyboardVisible)
                                      SizedBox(height: getHeight(60)),
                                  ],
                                ),
                              ),
                            ),
                            if (!isKeyboardVisible)
                              DiaryCompleteFixedBottomBar(
                                onGalleryTap: viewModel.getImageFromGallery,
                                onCameraTap: viewModel.getImageFromCamera,
                                onCompleted: viewModel.completeDiary,
                                currentImageCount: viewModel.pickedImages.length,
                              ),
                          ],
                        ),
                      ),
                      if (isKeyboardVisible)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: DiaryCompleteFixedBottomBar(
                            onGalleryTap: viewModel.getImageFromGallery,
                            onCameraTap: viewModel.getImageFromCamera,
                            onCompleted: viewModel.completeDiary,
                            currentImageCount: viewModel.pickedImages.length,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (isLoading)
          DiaryCompleteLoadingOverlay(),
        ],
      ),
    );
  }
}