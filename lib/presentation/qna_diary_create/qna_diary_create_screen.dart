import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/qna_diary_create/components/chat_list.dart';
import 'package:cake/presentation/qna_diary_create/components/fixed_input_section.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QnaDiaryCreateScreen extends StatelessWidget {
  const QnaDiaryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryCreateViewModel>();

    return Stack(
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
                //TODO: error 처리
              }
            });
            
            return GestureDetector(
              // 화면 빈 부분 터치 시 키보드 닫기
              onTap: () => viewModel.unfocusKeyboard(),
              child: Scaffold(
                backgroundColor: ColorConfig.background,
                appBar: const CommonMainAppBar(),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ChatList(
                          chatList: viewModel.chatList,
                          scrollController: viewModel.scrollController,
                        ),
                      ),

                      FixedInputSection(
                        textController: viewModel.textController,
                        focusNode: viewModel.focusNode,
                        onCompleted: viewModel.saveAnswer,
                        isKeyboardVisible: isKeyboardVisible,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // 서버 전송 등으로 인한 전체 로딩 오버레이
        if (viewModel.state == ResultState.loading)
          const Center(
            child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
          ),
      ],
    );
  }
}
