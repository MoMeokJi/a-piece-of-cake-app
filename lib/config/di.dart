import 'package:cake/data/data_source/sqflite/database_helper.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

GetIt getIt = GetIt.instance;

Future<void> diSetup() async {
  // Database 초기화 및 등록
  getIt.registerSingletonAsync<Database>(() => DatabaseHelper().database);
  await getIt.isReady<Database>();
  getIt.registerSingletonWithDependencies<DiaryDao>(
    () => DiaryDao(getIt<Database>()),
    dependsOn: [Database],
  );

  //viewmodel -> factory
  getIt.registerFactory(() => SplashViewModel());

  getIt.registerFactory(() => MainViewModel());

  //하단 네비게이션 탭 viewmodel -> singleton
  getIt.registerLazySingleton(() => DiaryCalendarViewModel());
  getIt.registerLazySingleton(() => DiaryListViewModel());
}
