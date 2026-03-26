import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/diary_detail/components/body_section.dart';
import 'package:cake/presentation/diary_detail/components/colors_section.dart';
import 'package:cake/presentation/diary_detail/components/diary_edit_dialog.dart';
import 'package:cake/presentation/diary_detail/components/empty_feedback_section.dart';
import 'package:cake/presentation/diary_detail/components/feedback_section.dart';
import 'package:cake/presentation/diary_detail/components/image_grid_thumbnail.dart';
import 'package:cake/presentation/diary_detail/components/music_section.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/dialog/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class DiaryDetailScreen extends StatelessWidget {
  const DiaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryDetailViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.toastMessage != null) {
        final isSuccess =
            viewModel.removeState == ResultState.success ||
            viewModel.updateState == ResultState.success;
        toastification.show(
          context: context,
          type: isSuccess
              ? ToastificationType.success
              : ToastificationType.error,
          style: ToastificationStyle.flat,
          primaryColor: isSuccess ? ColorConfig.primary : ColorConfig.error,
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

      if (viewModel.removeState == ResultState.success) {
        context.go('/diary-calendar');
        viewModel.resetRemoveState();
      }

      if (viewModel.updateState == ResultState.success) {
        viewModel.resetUpdateState();
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorConfig.background,
          appBar: CommonMainAppBar(
            actions: [
              IconButton(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () async {
                            context.pop(); // 액션시트 먼저 닫기

                            final shouldDelete =
                                await DialogUtils.showDeleteConfirmDialog(
                              context: context,
                              title: '이 일기를 삭제하시겠어요?',
                              content: '삭제 후에는 다시 되돌릴 수 없어요'
                            );

                            if (shouldDelete == true) {
                              await viewModel.removeDiary();
                            }
                          },
                          child: Text(
                            '삭제하기',
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorConfig.caution,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            context.pop();
                            viewModel.prepareEditMode();
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (context) => DiaryEditDialog(
                                textController: viewModel.editTextController,
                                focusNode: viewModel.focusNode,
                                isModified: () => viewModel.isEditModified,
                                onComplete: viewModel.updateDiaryContent,
                              ),
                            ).then((_) {
                              viewModel.closeEditMode();
                            });
                          },
                          child: Text(
                            '수정하기',
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorConfig.black,
                            ),
                          ),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => context.pop(),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorConfig.confirm,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert_rounded),
                color: ColorConfig.black,
                iconSize: getWidth(28),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(25)),
                child: Column(
                  children: [
                    BodySection(diary: viewModel.diary),
                    SizedBox(height: getHeight(8)),
                    ImageGridThumbnail(diary: viewModel.diary),
                    SizedBox(height: getHeight(8)),
                    if (viewModel.diary.feedback != null &&
                        viewModel.diary.feedback!.isNotEmpty) ...[
                      FeedbackSection(diary: viewModel.diary),
                      SizedBox(height: getHeight(16)),
                    ],
                    ColorsSection(diary: viewModel.diary),
                    SizedBox(height: getHeight(16)),
                    MusicSection(diary: viewModel.diary),
                    SizedBox(height: getHeight(16)),
                    if (viewModel.diary.feedback == null ||
                        viewModel.diary.feedback!.isEmpty) ...[
                      EmptyFeedbackSection(),
                      SizedBox(height: getHeight(20)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (viewModel.removeState == ResultState.loading ||
            viewModel.updateState == ResultState.loading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
            ),
          ),
        if (viewModel.initializeState == ResultState.loading)
          Container(
            color: ColorConfig.background,
            child: const Center(
              child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
            ),
          ),
      ],
    );
  }
}