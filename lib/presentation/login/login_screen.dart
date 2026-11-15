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
import 'package:flutter_svg/flutter_svg.dart';
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

/// A-1 Hero: 옅은 3D 케이크 둘 + 세로형 흰 로고(너비 150) 가운데.
/// 케이크 위치는 피그마의 회전 바운딩 박스 값(390×512 기준). 블루베리는 위, 딸기는 아래에 붙인다.
class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // Deco Blueberry: 박스 168.75 @ (1.6, 52), 이미지 142.28, 12°, 불투명도 0.4
          Positioned(
            left: 1.6,
            top: 52,
            child: _RotatedDeco(
              boxWidth: 168.75,
              boxHeight: 168.75,
              angleDeg: 12,
              opacity: 0.4,
              child: Image.asset(
                AppImages.cake3dBlueberry,
                width: 142.28,
                height: 142.28,
              ),
            ),
          ),
          // Deco Strawberry: 박스 171.18×183.31 @ (236.46, 295), 이미지 154.46×168.09, -6°, 0.5
          Positioned(
            right: 390 - 236.46 - 171.18,
            bottom: 512 - 295 - 183.31,
            child: _RotatedDeco(
              boxWidth: 171.18,
              boxHeight: 183.31,
              angleDeg: -6,
              opacity: 0.5,
              child: Image.asset(
                AppImages.cake3dStrawberry,
                width: 154.46,
                height: 168.09,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SvgPicture.asset(AppImages.logoStacked, width: 150),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatedDeco extends StatelessWidget {
  final double boxWidth;
  final double boxHeight;
  final double angleDeg;
  final double opacity;
  final Widget child;

  const _RotatedDeco({
    required this.boxWidth,
    required this.boxHeight,
    required this.angleDeg,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Center(
        child: Transform.rotate(
          angle: angleDeg * math.pi / 180,
          child: Opacity(opacity: opacity, child: child),
        ),
      ),
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
