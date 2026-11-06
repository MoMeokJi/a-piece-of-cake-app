import 'package:cake/config/di.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_detail/components/diary_body_card.dart';
import 'package:cake/presentation/diary_detail/diary_detail_screen.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/presentation/diary_edit/diary_edit_screen.dart';
import 'package:cake/presentation/diary_edit/diary_edit_view_model.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_screen.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/presentation/home/home_screen.dart';
import 'package:cake/presentation/home/home_view_model.dart';
import 'package:cake/presentation/login/login_screen.dart';
import 'package:cake/presentation/login/login_view_model.dart';
import 'package:cake/presentation/main/main_screen.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/my/my_screen.dart';
import 'package:cake/presentation/my/my_view_model.dart';
import 'package:cake/presentation/nickname/nickname_edit_screen.dart';
import 'package:cake/presentation/nickname/nickname_setup_screen.dart';
import 'package:cake/presentation/nickname/nickname_view_model.dart';
import 'package:cake/presentation/photo_viewer/photo_viewer_screen.dart';
import 'package:cake/presentation/qna_diary_confirm/qna_diary_confirm_screen.dart';
import 'package:cake/presentation/qna_diary_confirm/qna_diary_confirm_view_model.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_screen.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/presentation/splash/splash_screen.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<SplashViewModel>(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<LoginViewModel>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/nickname-setup',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<NicknameViewModel>(
            param1: true,
            param2: state.extra as String?,
          ),
          child: const NicknameSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/nickname-edit',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<NicknameViewModel>(
            param1: false,
            param2: state.extra as String?,
          ),
          child: const NicknameEditScreen(),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ChangeNotifierProvider(
            create: (_) => getIt<MainViewModel>(),
            child: MainScreen(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => ChangeNotifierProvider.value(
                  value: getIt<HomeViewModel>(),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => ChangeNotifierProvider.value(
                  value: getIt<MyViewModel>(),
                  child: const MyScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/qna-diary',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<QnaDiaryCreateViewModel>(),
          child: const QnaDiaryCreateScreen(),
        ),
      ),
      GoRoute(
        path: '/qna-confirm',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<QnaDiaryConfirmViewModel>(
            param1: state.extra as String? ?? '',
          ),
          child: const QnaDiaryConfirmScreen(),
        ),
      ),
      GoRoute(
        path: '/free-diary',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<FreeDiaryCreateViewModel>(),
          child: const FreeDiaryCreateScreen(),
        ),
      ),
      GoRoute(
        path: '/diary-detail',
        builder: (context, state) {
          final extra = state.extra;
          final detail = extra is DiaryDetail ? extra : null;
          final id = extra is int ? extra : null;
          return ChangeNotifierProvider(
            create: (_) => getIt<DiaryDetailViewModel>()..initialize(detail, id),
            child: const DiaryDetailScreen(),
          );
        },
      ),
      GoRoute(
        path: '/diary-edit',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => getIt<DiaryEditViewModel>(
            param1: state.extra as DiaryDetail,
          ),
          child: const DiaryEditScreen(),
        ),
      ),
      GoRoute(
        path: '/photo-viewer',
        builder: (context, state) {
          final args = state.extra as PhotoViewerArgs;
          return PhotoViewerScreen(
            urls: args.urls,
            initialIndex: args.initialIndex,
          );
        },
      ),
    ],
  );
}
