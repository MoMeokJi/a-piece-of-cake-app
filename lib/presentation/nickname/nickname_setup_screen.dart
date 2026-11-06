import 'package:cake/config/service_config.dart';
import 'package:cake/presentation/nickname/nickname_view_model.dart';
import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/app_text_field.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// A-8-1 닉네임 설정 (가입 직후)
class NicknameSetupScreen extends StatelessWidget {
  const NicknameSetupScreen({super.key});

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
      if (viewModel.saved) context.go('/home');
    });

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            28,
            AppSpacing.page,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('뭐라고 불러드릴까요?', style: TextConfig.display),
              const SizedBox(height: 8),
              Text(
                '문답과 시식평에서 이 이름으로 불러드려요.\n마이에서 언제든 바꿀 수 있어요.',
                style: TextConfig.bodyM.copyWith(
                  color: ColorConfig.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              NicknameField(viewModel: viewModel),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: ColorConfig.bgSurface.withValues(alpha: 0.7),
                  borderRadius: AppRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppIcon(
                      AppIcons.info,
                      size: 18,
                      color: ColorConfig.textAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        viewModel.prefilledFromProvider
                            ? '계정 이름을 가져왔어요. 한글, 영문, 숫자로 2~10자까지 쓸 수 있어요.'
                            : '한글, 영문, 숫자로 2~10자까지 쓸 수 있어요.',
                        style: TextConfig.label.copyWith(
                          color: ColorConfig.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: '시작하기',
                enabled: viewModel.canSave,
                isLoading: viewModel.isSaving,
                onPressed: viewModel.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 라벨 + 입력창 + 메시지. 설정·변경 화면 공용.
class NicknameField extends StatelessWidget {
  final NicknameViewModel viewModel;

  const NicknameField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final validation = viewModel.validation;
    final FieldMessageType messageType;
    final String message;
    if (validation.isValid) {
      messageType = FieldMessageType.valid;
      message = validation.message!;
    } else if (viewModel.showError) {
      messageType = FieldMessageType.error;
      message = validation.message!;
    } else {
      messageType = FieldMessageType.hint;
      message = '한글, 영문, 숫자로 2~10자까지 쓸 수 있어요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: TextConfig.label.copyWith(color: ColorConfig.textSecondary),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: viewModel.controller,
          focusNode: viewModel.focusNode,
          maxLength: ServiceConfig.nicknameMaxLength,
          hasError: viewModel.showError,
          hintText: '닉네임',
          autofocus: true,
          onSubmitted: (_) => viewModel.save(),
        ),
        const SizedBox(height: 8),
        FieldMessage(message: message, type: messageType),
      ],
    );
  }
}
