import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> diSetup() async {
  //viewmodel -> factory
  getIt.registerFactory(() => SplashViewModel());

  getIt.registerFactory(() => MainViewModel());

  //하단 네비게이션 탭 viewmodel -> singleton
  getIt.registerLazySingleton(() => DiaryCalendarViewModel());
  getIt.registerLazySingleton(() => DiaryListViewModel());
}
