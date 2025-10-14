import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class QnaDiaryCreateScreen extends StatelessWidget {
  const QnaDiaryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QnaDiaryCreateViewModel>();
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorConfig.background,
          appBar: CommonMainAppBar(),
          body: Text('qna'),
        ),
        if (viewModel.state == ResultState.loading)
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
