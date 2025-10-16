import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class DiaryDetailViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  DiaryDetailViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo;

  DiaryDetail _diary = DiaryDetail.empty();
  DiaryDetail get diary => _diary;

  ResultState _state = ResultState.none;
  ResultState get state => _state;

  Future<void> initialize(DiaryDetail? detail, int? id) async {
    _state = ResultState.loading;
    notifyListeners();

    if (detail != null) {
      _diary = detail;
      _state = ResultState.success;
      notifyListeners();
      return;
    }

    if (id != null) {
      try {
        _diary = await _diaryRepo.getDiary(id: id);
        _state = ResultState.success;
      } catch (e) {
        AppLogger.error('일기디테일 가져오기 에러: ${e.toString()}');
        _state = ResultState.error;
      }
      notifyListeners();
      return;
    }
  }
}
