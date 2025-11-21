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
      // 초기화가 완료된 경우에만 화면 전환 로직 실행
      if (viewModel.isInitialized) {
        // 업데이트가 필요한 경우 다이얼로그 표시
        if (viewModel.needUpdate) {
          DialogUtils.showUpdateDialog(
            context: context,
            onUpdatePressed: () => viewModel.openStore(),
            onLaterPressed: () => viewModel.cancleUpdate(),
          );
        } else {
          final location = (viewModel.hasToken)
              ? '/diary-calendar'
              : '/sign-up';
          context.go(location);
        }
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
