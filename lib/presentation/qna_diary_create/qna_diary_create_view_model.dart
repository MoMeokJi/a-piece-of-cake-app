import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:flutter/material.dart';

class QnaDiaryCreateViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  QnaDiaryCreateViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo;

  ResultState _resultState = ResultState.none;
  ResultState get state => _resultState;
}
