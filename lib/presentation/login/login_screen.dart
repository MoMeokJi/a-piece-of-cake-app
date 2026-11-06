import 'dart:math' as math;

import 'package:cake/config/api_config.dart';
import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/presentation/login/components/terms_sheet.dart';
import 'package:cake/presentation/login/login_view_model.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:cake/ui/common_components/social_login_button.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:cake/utils/external_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _onProviderTap(
    BuildContext context,
    LoginViewModel viewModel,
    SocialProvider provider,
  ) async {
    if (!viewModel.termsAgreed) {
      final result = await TermsSheet.show(context);
      if (result == null) return; // 시트를 닫았다
      await viewModel.agreeTerms(notificationOptIn: result.notificationOptIn);
    }
    await viewModel.signIn(provider);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final toast = viewModel.toastMessage;
      if (toast != null) {
        viewModel.clearToast();
        AppToast.show(
          context,
          toast,
          tone: viewModel.toastIsError ? ToastTone.error : ToastTone.info,
          actionLabel: viewModel.toastRetryable ? '다시 시도' : null,
          onAction: viewModel.toastRetryable ? viewModel.retry : null,
          bottomOffset: 348,
        );
      }
      final outcome = viewModel.outcome;
      if (outcome != null) {
        viewModel.clearOutcome();
        switch (outcome) {
          case LoginToHome():
            context.go('/home');
          case LoginToNicknameSetup(:final initialNickname):
            context.go('/nickname-setup', extra: initialNickname);
        }
      }
    });

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.onboarding),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(child: _Hero()),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ColorConfig.bgSurface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.page,
                right: AppSpacing.page,
                top: 32,
                bottom: 28 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('하루 한 조각, 달콤하게 기록해요', style: TextConfig.titleL),
                  const SizedBox(height: 8),
                  Text(
                    '질문에 답하면 일기가 완성되고, 오늘의 컬러와 음악이 도착해요',
                    style: TextConfig.bodyM.copyWith(
                      color: ColorConfig.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final provider in viewModel.providers) ...[
                    SocialLoginButton(
                      provider: provider,
                      isLoading: viewModel.loadingProvider == provider,
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _onProviderTap(context, viewModel, provider),
                    ),
                    if (provider != viewModel.providers.last)
                      const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                  const _LegalLinks(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -32,
          top: 28 + MediaQuery.paddingOf(context).top,
          child: Transform.rotate(
            angle: -10 * math.pi / 180,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                AppImages.cake3dBlueberry,
                width: 160,
                height: 160,
              ),
            ),
          ),
        ),
        Positioned(
          right: -20,
          bottom: 0,
          child: Transform.rotate(
            angle: 8 * math.pi / 180,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                AppImages.cake3dStrawberry,
                width: 165,
                height: 180,
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                decoration: const BoxDecoration(boxShadow: AppShadows.logo),
                child: Image.asset(AppImages.logo, width: 280, height: 34),
              ),
              const SizedBox(height: 12),
              Text('오늘은 어떤 하루였나요?', style: TextConfig.titleM),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final style = TextConfig.label.copyWith(color: ColorConfig.textTertiary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => ExternalLinks.open(ApiConfig.serviceTermUrl),
          child: Text('서비스 이용약관', style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('·', style: style),
        ),
        GestureDetector(
          onTap: () => ExternalLinks.open(ApiConfig.privacyPolicyUrl),
          child: Text('개인정보 처리방침', style: style),
        ),
      ],
    );
  }
}
