import 'package:cake/config/di.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_screen.dart';
import 'package:cake/presentation/diary_calendar/diary_calendar_view_model.dart';
import 'package:cake/presentation/diary_detail/diary_detail_screen.dart';
import 'package:cake/presentation/diary_detail/diary_detail_view_model.dart';
import 'package:cake/presentation/diary_list/diary_list_screen.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_screen.dart';
import 'package:cake/presentation/free_diary_create/free_diary_create_view_model.dart';
import 'package:cake/presentation/main/main_screen.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_screen.dart';
import 'package:cake/presentation/qna_diary_create/qna_diary_create_view_model.dart';
import 'package:cake/presentation/qna_diary_edit/qna_diary_edit_screen.dart';
import 'package:cake/presentation/qna_diary_edit/qna_diary_edit_view_model.dart';
import 'package:cake/presentation/sign_up/sign_up_screen.dart';
import 'package:cake/presentation/sign_up/sign_up_view_model.dart';
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
      GoRoute(
        path: '/sign-up',
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (context) => getIt<SignUpViewModel>(),
            child: const SignUpScreen(),
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

      GoRoute(
        path: '/qna-diary',
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (context) => getIt<QnaDiaryCreateViewModel>(),
            child: const QnaDiaryCreateScreen(),
          );
        },
      ),
      GoRoute(
        path: '/free-diary',
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (context) => getIt<FreeDiaryCreateViewModel>(),
            child: const FreeDiaryCreateScreen(),
          );
        },
      ),
      GoRoute(
        path: '/diary-detail',
        builder: (context, state) {
          final extra = state.extra;
          DiaryDetail? diaryDetail;
          int? id;

          if (extra is DiaryDetail) {
            diaryDetail = extra;
          } else if (extra is int) {
            id = extra;
          }

          return ChangeNotifierProvider(
            create: (context) => getIt<DiaryDetailViewModel>(),
            child: DiaryDetailScreen(diaryDetail: diaryDetail, id: id),
          );
        },
      ),
        GoRoute(
        path: '/qna-edit',
        builder: (context, state) {
          final extra = state.extra;
          String content ='';
          
          if (extra is String) {
            content = extra;
          } 

          return ChangeNotifierProvider(
            create: (context) => getIt<QnaDiaryEditViewModel>(),
            child: QnaDiaryEditScreen(content: content),
          );
        },
      ),
    ],
  );
}
