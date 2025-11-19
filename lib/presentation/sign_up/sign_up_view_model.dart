import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/enum/result_state.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:flutter/material.dart';

class SignUpViewModel with ChangeNotifier {
  final UserRepository _userRepo;

  SignUpViewModel({required UserRepository userRepo}) : _userRepo = userRepo;

  DiaryPreference? _selectedType;
  DiaryPreference? get selectedType => _selectedType;

  ResultState _resultState = ResultState.none;
  ResultState get state => _resultState;

  void selectType(DiaryPreference type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> signUp() async {
    if (_selectedType == null) return;

    _resultState = ResultState.loading;
    notifyListeners();

    try {
      await _userRepo.signUp(diaryPreference: _selectedType!);
      _resultState = ResultState.success;
    } catch (e) {
      _resultState = ResultState.error;
    } finally {
      notifyListeners();
    }
  }
}
