import 'package:cake/config/di.dart';
import 'package:cake/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await diSetup();

  runApp(const MyApp());
}
