import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_detail/components/body_section.dart';
import 'package:cake/presentation/diary_detail/components/colors_section.dart';
import 'package:cake/presentation/diary_detail/components/empty_feedback_section.dart';
import 'package:cake/presentation/diary_detail/components/feedback_section.dart';
import 'package:cake/presentation/diary_detail/components/image_grid_thumbnail.dart';
import 'package:cake/presentation/diary_detail/components/music_section.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryDetail? diaryDetail;
  final int? id;

  const DiaryDetailScreen({super.key, this.diaryDetail, this.id});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      context.read<DiaryDetailViewModel>().initialize(
        widget.diaryDetail,
        widget.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryDetailViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 토스트 메시지 표시
      if (viewModel.toastMessage != null) {
        final isSuccess = viewModel.removeState == ResultState.success;
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

      // 삭제 성공
      if (viewModel.removeState == ResultState.success) {
        context.go('/diary-calendar');
        viewModel.resetRemoveState();
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
                            context.pop();
                            await viewModel.removeDiary();
                          },
                          child: Text('삭제하기', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => context.pop(),
                        child: Text('취소', style: TextStyle(fontSize: 16)),
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
                    // 본문 영역
                    BodySection(diary: viewModel.diary),
                    SizedBox(height: getHeight(8)),
                    // 이미지 영역
                    ImageGridThumbnail(diary: viewModel.diary),
                    SizedBox(height: getHeight(16)),
                    // 피드백 있을 때만 표시
                    if (viewModel.diary.feedback != null &&
                        viewModel.diary.feedback!.isNotEmpty) ...[
                      FeedbackSection(diary: viewModel.diary),
                      SizedBox(height: getHeight(16)),
                    ],
                    // 컬러
                    ColorsSection(diary: viewModel.diary),
                    SizedBox(height: getHeight(16)),
                    // 뮤직
                    MusicSection(diary: viewModel.diary),
                    SizedBox(height: getHeight(16)),
                    // 피드백 없을 때만 표시
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
        // 삭제 로딩 중일 때만 반투명 오버레이
        if (viewModel.removeState == ResultState.loading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
            ),
          ),
        // 처음 로딩 중일 때는 빈 화면에 로딩 스피너만
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
