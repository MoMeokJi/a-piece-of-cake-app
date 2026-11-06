import 'package:cake/presentation/nickname/nickname_setup_screen.dart';
import 'package:cake/presentation/nickname/nickname_view_model.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/chat_bubble.dart';
import 'package:cake/ui/common_components/top_bar.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// A-6-1 닉네임 변경 (마이)
class NicknameEditScreen extends StatelessWidget {
  const NicknameEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NicknameViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(context, toast, tone: ToastTone.error);
      }
      if (viewModel.saved) context.pop(viewModel.nickname);
    });

    final preview = viewModel.nickname.isEmpty ? '서윤' : viewModel.nickname;

    return Scaffold(
      backgroundColor: ColorConfig.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: '닉네임 변경'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  24,
                  AppSpacing.page,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NicknameField(viewModel: viewModel),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '이렇게 불러드려요',
                        style: TextConfig.label.copyWith(
                          color: ColorConfig.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ChatBubble(message: '$preview님, 오늘 기분이 어때?', isUser: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                12,
                AppSpacing.page,
                32,
              ),
              child: AppButton(
                label: '저장하기',
                enabled: viewModel.canSave,
                isLoading: viewModel.isSaving,
                onPressed: viewModel.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
