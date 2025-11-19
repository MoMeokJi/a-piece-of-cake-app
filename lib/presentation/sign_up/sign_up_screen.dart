import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/sign_up/components/diary_type_option.dart';
import 'package:cake/presentation/sign_up/sign_up_view_model.dart';
import 'package:cake/ui/common_components/basic_button.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    if (viewModel.state == ResultState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/diary-calendar');
      });
    } else if (viewModel.state == ResultState.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //TODO: error 처리
      });
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorConfig.background,
          body: SafeArea(
            child: Column(
              children: [
                // 상단 타이틀 영역
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                  child: Column(
                    children: [
                      SizedBox(height: getHeight(60)),

                      // 타이틀
                      Text(
                        '어떤 일기를\n선호하시나요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: getWidth(28),
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: getHeight(8)),

                      // 서브 타이틀
                      Text(
                        '마음에 드는 일기 레시피를 골라주세요',
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: ColorConfig.gray2,
                        ),
                      ),

                      SizedBox(height: getHeight(50)),
                    ],
                  ),
                ),

                // 옵션 리스트 (스크롤 가능)
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                    children: [
                      DiaryTypeOption(
                        type: DiaryPreference.emotional,
                        isSelected:
                            viewModel.selectedType == DiaryPreference.emotional,
                        onTap: () =>
                            viewModel.selectType(DiaryPreference.emotional),
                      ),
                      SizedBox(height: getHeight(16)),
                      DiaryTypeOption(
                        type: DiaryPreference.record,
                        isSelected:
                            viewModel.selectedType == DiaryPreference.record,
                        onTap: () =>
                            viewModel.selectType(DiaryPreference.record),
                      ),
                      SizedBox(height: getHeight(16)),
                      DiaryTypeOption(
                        type: DiaryPreference.goal,
                        isSelected:
                            viewModel.selectedType == DiaryPreference.goal,
                        onTap: () => viewModel.selectType(DiaryPreference.goal),
                      ),
                      SizedBox(height: getHeight(16)),
                      DiaryTypeOption(
                        type: DiaryPreference.confession,
                        isSelected:
                            viewModel.selectedType ==
                            DiaryPreference.confession,
                        onTap: () =>
                            viewModel.selectType(DiaryPreference.confession),
                      ),
                      SizedBox(height: getHeight(16)),
                      DiaryTypeOption(
                        type: DiaryPreference.freewriting,
                        isSelected:
                            viewModel.selectedType ==
                            DiaryPreference.freewriting,
                        onTap: () =>
                            viewModel.selectType(DiaryPreference.freewriting),
                      ),
                    ],
                  ),
                ),

                // 하단 버튼 (고정)
                Padding(
                  padding: EdgeInsets.all(getWidth(24)),
                  child: BasicButton(
                    text: '시작하기',
                    isEnabled:
                        viewModel.selectedType != null &&
                        viewModel.state != ResultState.loading,
                    onPressed: () => viewModel.signUp(),
                  ),
                ),
              ],
            ),
          ),
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
