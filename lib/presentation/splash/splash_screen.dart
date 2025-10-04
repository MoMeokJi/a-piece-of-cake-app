import 'package:cake/ui/style/color_config.dart';
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

    // 로딩이 끝나면 분기 처리
    if (!viewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.isLoggedIn) {
          context.go('/diary-calendar');
        } else {
          context.go('/sign-up');
        }
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorConfig.primary, ColorConfig.secondary],
          ),
        ),
        child: Center(
          child: Text(
            'piece of cake',
            style: TextStyle(
              fontFamily: 'DCC',
              fontSize: getWidth(48),
              color: ColorConfig.white,
            ),
          ),
        ),
      ),
    );
  }
}
