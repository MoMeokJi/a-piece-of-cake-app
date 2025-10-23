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

  ResultState _state = ResultState.loading;
  ResultState get state => _state;

  Future<void> initialize(DiaryDetail? detail, int? id) async {
    try {
      if (detail != null) {
        _diary = detail;
        _state = ResultState.success;
        notifyListeners();
        return;
      }

      if (id != null) {
        _diary = await _diaryRepo.getDiary(id: id);
        _state = ResultState.success;
        notifyListeners();
        return;
      }

      // detail도 id도 없는 경우 처리
      _state = ResultState.error;
      notifyListeners();
    } catch (e) {
      AppLogger.error('일기디테일 초기화 에러: ${e.toString()}');
      _state = ResultState.error;
      notifyListeners();
    }
  }
}
