import 'package:cake/config/api_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/settings/components/menu_list_tile.dart';
import 'package:cake/presentation/settings/settings_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    // build 시점에 각 상태 체크하여 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.withdrawState == ResultState.success) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          primaryColor: ColorConfig.primary,
          title: Text(
            '모든 일기 데이터가 삭제되었습니다.',
            style: TextStyle(fontSize: getWidth(14)),
          ),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.center,
          showProgressBar: false,
        );
        viewModel.resetWithdrawState();
        context.go('/splash');
        return;
      } else if (viewModel.withdrawState == ResultState.error) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          primaryColor: ColorConfig.error,
          title: Text(
            '데이터 삭제에 실패했습니다',
            style: TextStyle(fontSize: getWidth(14)),
          ),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
          showProgressBar: false,
        );
        viewModel.resetWithdrawState();
      }
    });

    return Stack(
      children: [
        Scaffold(
          appBar: const CommonMainAppBar(titleText: '설정'),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    '버전정보',
                    style: TextStyle(fontSize: getHeight(14)),
                  ),
                  trailing: Text(
                    'v ${viewModel.version}',
                    style: TextStyle(
                      color: ColorConfig.primary,
                      fontSize: getHeight(16),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: getWidth(25),
                  ),
                  onTap: null,
                ),
                MenuListTile(
                  title: '서비스 이용약관',
                  onTap: () => launchUrl(Uri.parse(ApiConfig.serviceTermUrl)),
                ),
                MenuListTile(
                  title: '개인정보 처리방침',
                  onTap: () => launchUrl(Uri.parse(ApiConfig.privacyPolicyUrl)),
                ),

                MenuListTile(
                  title: '전체 데이터 삭제',
                  color: ColorConfig.gray2,
                  onTap: () async {
                    final confirmed = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(
                          '모든 일기를 삭제할까요?',
                          style: TextStyle(
                            fontSize: 18,
                            color: ColorConfig.black,
                          ),
                        ),
                        content: Text(
                          '한 번 삭제하면 되돌릴 수 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorConfig.gray1,
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => context.pop(false),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorConfig.confirm,
                              ),
                            ),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => context.pop(true),
                            child: Text(
                              '삭제',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorConfig.caution,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await viewModel.confirmWithdraw();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (viewModel.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: SpinKitFadingCube(color: ColorConfig.primary, size: 30.0),
            ),
          ),
      ],
    );
  }
}
