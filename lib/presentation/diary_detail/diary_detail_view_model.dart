import 'package:cake/config/di.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class DiaryDetailViewModel with ChangeNotifier {
  final DiaryRepository _diaryRepo;

  DiaryDetailViewModel({required DiaryRepository diaryRepo})
    : _diaryRepo = diaryRepo;

  DiaryDetail _diary = DiaryDetail.empty();
  DiaryDetail get diary => _diary;

  ResultState _initializeState = ResultState.loading;
  ResultState get initializeState => _initializeState;

  ResultState _removeState = ResultState.none;
  ResultState get removeState => _removeState;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  Future<void> initialize(DiaryDetail? detail, int? id) async {
    try {
      if (detail != null) {
        _diary = detail;
        _initializeState = ResultState.success;
        notifyListeners();
        return;
      }

      if (id != null) {
        _diary = await _diaryRepo.getDiary(id: id);
        _initializeState = ResultState.success;
        notifyListeners();
        return;
      }

      // detail도 id도 없는 경우 처리
      _initializeState = ResultState.error;
      notifyListeners();
    } catch (e) {
      AppLogger.error('일기디테일 초기화 에러: ${e.toString()}');
      _initializeState = ResultState.error;
      notifyListeners();
    }
  }

  Future<void> removeDiary() async {
    try {
      _removeState = ResultState.loading;
      notifyListeners();

      await _diaryRepo.removeDiary(_diary.id);

      final diaryCalendarVM = getIt<DiaryCalendarViewModel>();
      await diaryCalendarVM.initialize();
      final diaryListVM = getIt<DiaryListViewModel>();
      await diaryListVM.loadDiaryList();

      _toastMessage = '일기가 삭제되었습니다';
      _removeState = ResultState.success;
      notifyListeners();
    } catch (e) {
      AppLogger.error('일기삭제 에러: ${e.toString()}');
      _toastMessage = '일기 삭제에 실패했습니다. 잠시 후 다시 시도해 주세요.';
      _removeState = ResultState.error;
      notifyListeners();
    }
  }

  void clearToastMessage() {
    _toastMessage = null;
  }

  void resetRemoveState() {
    _removeState = ResultState.none;
  }
}
