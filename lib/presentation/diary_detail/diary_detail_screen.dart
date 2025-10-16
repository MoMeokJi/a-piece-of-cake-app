import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/ui/common_components/common_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryDetail? diaryDetail;
  final int? id;

  const DiaryDetailScreen({super.key, this.diaryDetail, this.id});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryDetailViewModel>().initialize(
        widget.diaryDetail,
        widget.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryDetailViewModel>();
    return Scaffold(
      appBar: CommonMainAppBar(),
      body: Text(viewModel.diary.toString()),
    );
  }
}
