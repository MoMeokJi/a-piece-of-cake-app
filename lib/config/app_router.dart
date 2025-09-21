import 'package:cake/config/di.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_screen.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_screen.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/presentation/main/main_screen.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/splash/splash_screen.dart';
import 'package:cake/presentation/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (context) => getIt<SplashViewModel>(),
            child: const SplashScreen(),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ChangeNotifierProvider(
            create: (_) => getIt<MainViewModel>(),
            child: MainScreen(navigationShell: navigationShell),
          );
        },
        branches: [
          // 캘린더 탭
          StatefulShellBranch(
            initialLocation: '/diary-calendar',
            routes: [
              GoRoute(
                path: '/diary-calendar',
                builder: (context, state) => ChangeNotifierProvider.value(
                  value: getIt<DiaryCalendarViewModel>(),
                  child: const DiaryCalendarScreen(),
                ),
              ),
            ],
          ),

          // 리스트 탭
          StatefulShellBranch(
            initialLocation: '/diary-list',
            routes: [
              GoRoute(
                path: '/diary-list',
                builder: (context, state) => ChangeNotifierProvider.value(
                  value: getIt<DiaryListViewModel>(),
                  child: const DiaryListScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
