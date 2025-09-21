import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryListViewModel>();
    return Center(child: Text('list view'));
  }
}
