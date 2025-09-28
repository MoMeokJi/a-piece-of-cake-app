import 'package:cake/domain/repository/diary_repository.dart';
import 'package:flutter/material.dart';

class MainViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  MainViewModel({required DiaryRepository diaryRepo}) : _diaryRepo = diaryRepo;

  Future<bool> checkDiaryLimit() async {
    return await _diaryRepo.isAbleToWriteDiaryToday();
  }
}
