import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryCalendarScreen extends StatelessWidget {
  const DiaryCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryCalendarViewModel>();
    return SingleChildScrollView();
  }
}
