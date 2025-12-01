import 'package:cake/domain/enum/splash_state.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:cake/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SplashViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (viewModel.state) {
        case SplashState.initializing:
          break;
        case SplashState.showUpdateDialog:
          DialogUtils.showUpdateDialog(
            context: context,
            onUpdatePressed: () => viewModel.openStore(),
            onLaterPressed: () {
              Navigator.of(context).pop();
              viewModel.skipUpdate();
            },
          );

        case SplashState.navigateToMain:
          context.go('/diary-calendar');

        case SplashState.navigateToSignUp:
          context.go('/sign-up');
      }
    });

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
