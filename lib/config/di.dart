import 'package:cake/config/app_router.dart';
import 'package:cake/data/data_source/api/app_version/app_version_api.dart';
import 'package:cake/data/data_source/api/app_version/app_version_api_impl.dart';
import 'package:cake/data/data_source/api/auth/auth_api.dart';
import 'package:cake/data/data_source/api/auth/auth_api_impl.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/data_source/api/diary/diary_api_impl.dart';
import 'package:cake/data/data_source/api/dio_client.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/data_source/api/user/user_api_impl.dart';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager_impl.dart';
import 'package:cake/data/data_source/shared_preferences/app_prefs_store.dart';
import 'package:cake/data/repository/app_prefs_repository_impl.dart';
import 'package:cake/data/repository/app_version_repository_impl.dart';
import 'package:cake/data/repository/auth_repository_impl.dart';
import 'package:cake/data/repository/diary_repository_impl.dart';
import 'package:cake/data/repository/token_repository_impl.dart';
import 'package:cake/data/repository/user_repository_impl.dart';
import 'package:cake/data/service/fcm_service_impl.dart';
import 'package:cake/data/service/firebase_analytics_service_impl.dart';
import 'package:cake/data/service/legacy_data_cleanup_service_impl.dart';
import 'package:cake/data/service/notification_service_impl.dart';
import 'package:cake/data/service/permission_handler_service_impl.dart';
import 'package:cake/data/service/social_sign_in_service_impl.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/repository/app_prefs_repository.dart';
import 'package:cake/domain/repository/app_version_repository.dart';
import 'package:cake/domain/repository/auth_repository.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/legacy_data_cleanup_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/domain/service/social_sign_in_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/common/diary_change_notifier.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/presentation/diary_edit/diary_edit_view_model.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/presentation/home/home_view_model.dart';
import 'package:cake/presentation/login/login_view_model.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/my/my_view_model.dart';
import 'package:cake/presentation/nickname/nickname_view_model.dart';
import 'package:cake/presentation/qna_diary_confirm/qna_diary_confirm_view_model.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:cake/ui/common_components/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> diSetup() async {
  // shared_preferences
  getIt.registerLazySingleton<AppPrefsStore>(() => AppPrefsStore());
  getIt.registerLazySingleton<AppPrefsRepository>(
    () => AppPrefsRepositoryImpl(getIt<AppPrefsStore>()),
  );

  // secure storage. data source들이 다 쓰므로 먼저 선언
  getIt.registerLazySingleton<TokenRepository>(() => TokenRepositoryImpl());

  getIt.registerLazySingleton<Dio>(
    () => buildDio(
      getIt<TokenRepository>(),
      onSessionExpired: _handleSessionExpired,
    ),
  );

  // api
  getIt.registerLazySingleton<AuthApi>(() => AuthApiImpl(dio: getIt<Dio>()));
  getIt.registerLazySingleton<UserApi>(() => UserApiImpl(dio: getIt<Dio>()));
  getIt.registerLazySingleton<DiaryApi>(() => DiaryApiImpl(dio: getIt<Dio>()));
  getIt.registerLazySingleton<AppVersionApi>(
    () => AppVersionApiImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<FirebaseMessagingManager>(
    () => FirebaseMessagingManagerImpl(),
  );

  // service
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
  getIt.registerLazySingleton<SocialSignInService>(
    () => SocialSignInServiceImpl(),
  );
  getIt.registerLazySingleton<AnalyticsService>(
    () => FirebaseAnalyticsServiceImpl(),
  );
  getIt.registerLazySingleton<LegacyDataCleanupService>(
    () => LegacyDataCleanupServiceImpl(
      tokenRepository: getIt<TokenRepository>(),
      prefsStore: getIt<AppPrefsStore>(),
    ),
  );

  // repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApi: getIt<AuthApi>(),
      tokenRepository: getIt<TokenRepository>(),
      socialSignIn: getIt<SocialSignInService>(),
      fcmService: getIt<FCMService>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userApi: getIt<UserApi>(),
      authRepository: getIt<AuthRepository>(),
      fcmService: getIt<FCMService>(),
    ),
  );
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(diaryApi: getIt<DiaryApi>()),
  );
  getIt.registerLazySingleton<AppVersionRepository>(
    () => AppVersionRepositoryImpl(api: getIt<AppVersionApi>()),
  );

  // 화면 간 갱신 통로
  getIt.registerLazySingleton<DiaryChangeNotifier>(() => DiaryChangeNotifier());

  // 하단 탭 viewmodel → lazySingleton (탭 전환에도 상태 유지)
  getIt.registerLazySingleton(
    () => HomeViewModel(
      diaryRepo: getIt<DiaryRepository>(),
      userRepo: getIt<UserRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
    ),
  );
  getIt.registerLazySingleton(
    () => MyViewModel(
      userRepo: getIt<UserRepository>(),
      authRepo: getIt<AuthRepository>(),
      versionRepo: getIt<AppVersionRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
      analytics: getIt<AnalyticsService>(),
    ),
  );

  // viewmodel → factory
  getIt.registerFactory(
    () => SplashViewModel(
      versionRepo: getIt<AppVersionRepository>(),
      authRepo: getIt<AuthRepository>(),
      prefsRepo: getIt<AppPrefsRepository>(),
      legacyCleanup: getIt<LegacyDataCleanupService>(),
    ),
  );
  getIt.registerFactory(
    () => LoginViewModel(
      authRepo: getIt<AuthRepository>(),
      prefsRepo: getIt<AppPrefsRepository>(),
      analytics: getIt<AnalyticsService>(),
    ),
  );
  getIt.registerFactoryParam<NicknameViewModel, bool, String?>(
    (isOnboarding, initialNickname) => NicknameViewModel(
      userRepo: getIt<UserRepository>(),
      authRepo: getIt<AuthRepository>(),
      prefsRepo: getIt<AppPrefsRepository>(),
      isOnboarding: isOnboarding,
      initialNickname: initialNickname,
    ),
  );
  getIt.registerFactory(() => MainViewModel(userRepo: getIt<UserRepository>()));
  getIt.registerFactory(
    () => QnaDiaryCreateViewModel(diaryRepo: getIt<DiaryRepository>()),
  );
  getIt.registerFactoryParam<QnaDiaryConfirmViewModel, String, void>(
    (initialContent, _) => QnaDiaryConfirmViewModel(
      diaryRepo: getIt<DiaryRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
      analytics: getIt<AnalyticsService>(),
      initialContent: initialContent,
    ),
  );
  getIt.registerFactory(
    () => FreeDiaryCreateViewModel(
      diaryRepo: getIt<DiaryRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
      analytics: getIt<AnalyticsService>(),
    ),
  );
  getIt.registerFactory(
    () => DiaryDetailViewModel(
      diaryRepo: getIt<DiaryRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
      analytics: getIt<AnalyticsService>(),
    ),
  );
  getIt.registerFactoryParam<DiaryEditViewModel, DiaryDetail, void>(
    (diary, _) => DiaryEditViewModel(
      diaryRepo: getIt<DiaryRepository>(),
      diaryChanges: getIt<DiaryChangeNotifier>(),
      analytics: getIt<AnalyticsService>(),
      diary: diary,
    ),
  );
}

/// 로그아웃·탈퇴·세션 만료 뒤 탭 ViewModel의 잔여 상태를 비운다.
/// 다음 로그인에서 새 계정의 데이터로 다시 만들어지게 한다.
void resetTabViewModels() {
  if (getIt.isRegistered<HomeViewModel>()) {
    getIt.unregister<HomeViewModel>(disposingFunction: (vm) => vm.dispose());
    getIt.registerLazySingleton(
      () => HomeViewModel(
        diaryRepo: getIt<DiaryRepository>(),
        userRepo: getIt<UserRepository>(),
        diaryChanges: getIt<DiaryChangeNotifier>(),
      ),
    );
  }
  if (getIt.isRegistered<MyViewModel>()) {
    getIt.unregister<MyViewModel>(disposingFunction: (vm) => vm.dispose());
    getIt.registerLazySingleton(
      () => MyViewModel(
        userRepo: getIt<UserRepository>(),
        authRepo: getIt<AuthRepository>(),
        versionRepo: getIt<AppVersionRepository>(),
        diaryChanges: getIt<DiaryChangeNotifier>(),
        analytics: getIt<AnalyticsService>(),
      ),
    );
  }
}

bool _sessionExpiryInFlight = false;

/// 인터셉터가 토큰을 지운 뒤 호출. 로그인 화면으로 보내고 안내 토스트를 띄운다.
void _handleSessionExpired() {
  if (_sessionExpiryInFlight) return;
  _sessionExpiryInFlight = true;
  Future<void>.microtask(() async {
    try {
      await getIt<AuthRepository>().clearSession();
      resetTabViewModels();
      AppRouter.router.go('/login');
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        AppToast.show(
          context,
          AppErrorMessages.sessionExpired,
          tone: ToastTone.error,
          bottomOffset: 348,
        );
      }
    } finally {
      _sessionExpiryInFlight = false;
    }
  });
}
