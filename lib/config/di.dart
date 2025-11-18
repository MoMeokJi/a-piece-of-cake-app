import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/data_source/api/diary/diary_api_impl.dart';
import 'package:cake/data/data_source/api/diary/mock_diary_api.dart';
import 'package:cake/data/data_source/api/user/mock_user_api.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/data_source/api/user/user_api_impl.dart';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager_impl.dart';
import 'package:cake/data/data_source/firebase/messaging/mock_firebase_messaging_manager.dart';
import 'package:cake/data/data_source/sqflite/database_helper.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/data/repository/diary_repository_impl.dart';
import 'package:cake/data/repository/token_repository_impl.dart';
import 'package:cake/data/repository/user_repository_impl.dart';
import 'package:cake/data/service/fcm_service_impl.dart';
import 'package:cake/data/service/notification_service_impl.dart';
import 'package:cake/data/service/permission_handler_service_impl.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/presentation/qna_diary_edit/qna_diary_edit_view_model.dart';
import 'package:cake/presentation/sign_up/sign_up_view_model.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

GetIt getIt = GetIt.instance;

Future<void> diSetup() async {
  // Database 초기화 및 등록
  getIt.registerSingletonAsync<Database>(() => DatabaseHelper().database);
  getIt.registerSingletonWithDependencies<DiaryDao>(
    () => DiaryDao(getIt<Database>()),
    dependsOn: [Database],
  );
  await getIt.isReady<DiaryDao>(); // DiaryDao 인스턴스까지 생성 완료

  // 얘는 data source에서 다 쓸 확률이 높기 때문에 앞에서 선언
  getIt.registerLazySingleton<TokenRepository>(() => TokenRepositoryImpl());

  //api -> LazySignleton
  getIt.registerLazySingleton<UserApi>(
    () => MockUserApi(getIt<TokenRepository>()),
  );

  getIt.registerLazySingleton<DiaryApi>(() => MockDiaryApi());
  // getIt.registerLazySingleton<DiaryApi>(() => DiaryApiImpl(getIt<TokenRepository>()));

  getIt.registerLazySingleton<FirebaseMessagingManager>(
    () => MockFirebaseMessagingManager(),
  );

  //service -> LazySingleton
  getIt.registerLazySingleton<PermissionHandlerService>(
    () => PermissionHandlerServiceImpl(),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );

  getIt.registerLazySingleton<FCMService>(
    () => FCMServiceImpl(
      messagingManager: getIt<FirebaseMessagingManager>(),
      tokenRepository: getIt<TokenRepository>(),
      notificationService: getIt<NotificationService>(),
      permissionHandlerService: getIt<PermissionHandlerService>(),
    ),
  );

  // repository => Lazysingleton
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(
      diaryDao: getIt<DiaryDao>(),
      diaryApi: getIt<DiaryApi>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userApi: getIt<UserApi>(),
      tokenRepo: getIt<TokenRepository>(),
    ),
  );

  //하단 네비게이션 탭 viewmodel -> LazySignleton
  getIt.registerLazySingleton(
    () => DiaryCalendarViewModel(diaryRepo: getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton(
    () => DiaryListViewModel(diaryRepo: getIt<DiaryRepository>()),
  );

  //viewmodel -> factory
  getIt.registerFactory(
    () => SplashViewModel(tokenRepo: getIt<TokenRepository>()),
  );
  getIt.registerFactory(
    () => MainViewModel(diaryRepo: getIt<DiaryRepository>()),
  );
  getIt.registerFactory(
    () => SignUpViewModel(userRepo: getIt<UserRepository>()),
  );
  getIt.registerFactory(
    () => QnaDiaryCreateViewModel(diaryRepo: getIt<DiaryRepository>()),
  );
  getIt.registerFactory(
    () => FreeDiaryCreateViewModel(diaryRepo: getIt<DiaryRepository>()),
  );

  getIt.registerFactory(
    () => DiaryDetailViewModel(diaryRepo: getIt<DiaryRepository>()),
  );

    getIt.registerFactory(
    () => QnaDiaryEditViewModel(diaryRepo: getIt<DiaryRepository>()),
  );
}
