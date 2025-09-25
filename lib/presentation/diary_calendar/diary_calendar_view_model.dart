import 'package:cake/domain/repository/diary_repository.dart';
import 'package:flutter/material.dart';

class DiaryCalendarViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepository;

  DiaryCalendarViewModel({required DiaryRepository diaryRepository})
    : _diaryRepository = diaryRepository;
}
