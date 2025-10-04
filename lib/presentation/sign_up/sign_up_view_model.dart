import 'package:cake/domain/repository/user_repository.dart';
import 'package:flutter/material.dart';

class SignUpViewModel with ChangeNotifier {
  final UserRepository _userRepo;

  SignUpViewModel({required UserRepository userRepo}) : _userRepo = userRepo;
}
