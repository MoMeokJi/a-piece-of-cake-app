import 'package:cake/config/api_config.dart';
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
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
    
    // 최초 1회만 약관 동의 바텀시트 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignUpViewModel>();
      if (!viewModel.hasShownTermsSheet) {
        viewModel.markTermsSheetAsShown();
        _showTermsBottomSheet();
      }
    });
  }

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                  child: Column(
                    children: [
                      SizedBox(height: getHeight(60)),
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

  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(getWidth(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getHeight(8)),
            
            // 타이틀
            Text(
              '서비스 이용을 위해\n아래 항목에 동의해 주세요',
              style: TextStyle(
                fontSize: getWidth(22),
                fontWeight: FontWeight.bold,
                height: 1.4,
                fontFamily: 'Pretendard'
              ),
            ),

            SizedBox(height: getHeight(24)),

            // 약관 링크 - 조각케이크 스타일로
            InkWell(
              onTap: () => launchUrl(Uri.parse(ApiConfig.serviceTermUrl)),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: getHeight(4)),
                child: Text(
                  '[조각케이크] 서비스 이용약관 (필수)',
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: ColorConfig.gray2,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Pretendard'
                  ),
                ),
              ),
            ),

            SizedBox(height: getHeight(12)),

            InkWell(
              onTap: () => launchUrl(Uri.parse(ApiConfig.privacyPolicyUrl)),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: getHeight(4)),
                child: Text(
                  '[조각케이크] 개인정보 처리방침 (필수)',
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: ColorConfig.gray2,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Pretendard'
                  ),
                ),
              ),
            ),

            SizedBox(height: getHeight(32)),

            // 동의 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConfig.primary,
                  padding: EdgeInsets.symmetric(vertical: getHeight(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '동의하고 계속하기',
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: Colors.white,
                    fontFamily: 'Pretendard'
                  ),
                ),
              ),
            ),

            SizedBox(height: getHeight(16)),
          ],
        ),
      ),
    );
  }
}