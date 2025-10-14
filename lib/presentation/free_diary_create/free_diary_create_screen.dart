import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class FreeDiaryCreateScreen extends StatelessWidget {
  const FreeDiaryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreeDiaryCreateViewModel>();
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorConfig.background,
          appBar: CommonMainAppBar(),
          body: Text('free'),
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
