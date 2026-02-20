import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:cake/utils/dialog/dialog_utils.dart';
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
        case AppInitState.initializing:
          break;
        case AppInitState.showUpdateDialog:
          DialogUtils.showUpdateDialog(
            context: context,
            onUpdatePressed: () => viewModel.openStore(),
            onLaterPressed: () => viewModel.skipUpdate(),
          );
        case AppInitState.showInactivityDialog:
          DialogUtils.showInactivityDialog(
            context: context,
            onConfirmed: () => viewModel.clearDataAndProceed(),
          );
        case AppInitState.navigateToMain:
          context.go('/diary-calendar');
        case AppInitState.navigateToSignUp:
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