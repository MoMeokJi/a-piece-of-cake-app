import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/free_diary_create/components/diary_image_grid.dart';
import 'package:cake/presentation/free_diary_create/components/diary_text_field.dart';
import 'package:cake/presentation/free_diary_create/components/fixed_bottom_section.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FreeDiaryCreateScreen extends StatelessWidget {
  const FreeDiaryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreeDiaryCreateViewModel>();

    return Stack(
      // 이 스택은 로딩스피너용 스택
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
            });

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: ColorConfig.background,
                appBar: CommonMainAppBar(),
                body: Stack(
                  // 이 스택은 하단 버튼용 스택
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
                            FixedBottomSection(
                              onGalleryTap: viewModel.getImageFromGallery,
                              onCameraTap: viewModel.getImageFromCamera,
                              onCompleted: viewModel.writeFreeDiary,
                              currentImageCount: viewModel.pickedImages.length,
                              maxImageCount: viewModel.maxImgLength,
                            ),
                        ],
                      ),
                    ),
                    if (isKeyboardVisible)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: FixedBottomSection(
                          onGalleryTap: viewModel.getImageFromGallery,
                          onCameraTap: viewModel.getImageFromCamera,
                          onCompleted: () {},
                          currentImageCount: viewModel.pickedImages.length,
                          maxImageCount: viewModel.maxImgLength,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        if (viewModel.state == ResultState.loading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
            ),
          ),
      ],
    );
  }
}
