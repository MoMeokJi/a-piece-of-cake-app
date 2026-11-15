import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:cake/ui/common_components/app_bottom_sheet.dart';
import 'package:cake/ui/common_components/brand_mark.dart';
import 'package:cake/ui/common_components/gradient_scaffold.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppInitState? _handled;

  void _handle(SplashViewModel viewModel) {
    final state = viewModel.state;
    if (state == _handled) return;
    _handled = state;

    switch (state) {
      case AppInitState.initializing:
        break;
      case AppInitState.forceUpdate:
        _showUpdateSheet(viewModel);
      case AppInitState.showAccountMigrationNotice:
        _showMigrationSheet(viewModel);
      case AppInitState.navigateToHome:
        context.go('/home');
      case AppInitState.navigateToLogin:
        context.go('/login');
    }
  }

  Future<void> _showUpdateSheet(SplashViewModel viewModel) async {
    // 강제 업데이트: 닫을 수 없고, 업데이트를 누르면 스토어로 간 뒤 시트를 다시 띄운다.
    final go = await ConfirmSheet.show(
      context,
      title: '새 버전이 나왔어요',
      description: '더 편해진 조각케이크를 만나보세요.\n지금 업데이트할까요?',
      primaryLabel: '업데이트',
      isDismissible: false,
      visual: const BrandMark(),
    );
    if (!mounted) return;
    if (go) await viewModel.openStore();
    if (!mounted) return;
    await _showUpdateSheet(viewModel);
  }

  Future<void> _showMigrationSheet(SplashViewModel viewModel) async {
    await ConfirmSheet.show(
      context,
      title: '조각케이크가 새로워졌어요',
      description:
          '이번 버전부터 Apple·Google 계정으로 로그인해요.\n이전 버전에서 쓴 일기는 새 계정으로 이어지지 않아요.',
      primaryLabel: '확인했어요',
      isDismissible: false,
      visual: const BrandMark(),
    );
    if (!mounted) return;
    await viewModel.acknowledgeMigrationNotice();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SplashViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handle(viewModel);
    });

    return GradientScaffold(
      gradient: AppGradients.onboarding,
      // A-7: 세로형 흰 로고만 화면 가운데 (너비 150)
      body: Center(
        child: SvgPicture.asset(AppImages.logoStacked, width: 150),
      ),
    );
  }
}
