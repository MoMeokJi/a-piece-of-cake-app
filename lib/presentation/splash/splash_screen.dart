import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SplashViewModel>();

    // 로딩이 끝나면 홈으로 이동
    if (!viewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/diary-calendar');
      });
    }

    return Scaffold(
      backgroundColor: ColorConfig.primary,
      body: Center(
        child: Image.asset('assets/logo/logo.png', width: getWidth(300)),
      ),
    );
  }
}
