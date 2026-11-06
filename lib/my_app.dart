import 'package:cake/config/app_router.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '조각케이크',
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ColorConfig.bgPage,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConfig.brandBlue,
          brightness: Brightness.light,
          surface: ColorConfig.bgPage,
        ),
        splashColor: ColorConfig.brandBlue.withValues(alpha: 0.08),
        highlightColor: ColorConfig.brandBlue.withValues(alpha: 0.06),
        // 본문 기본은 Pretendard. 제목은 TextConfig의 Round 스타일을 명시해서 쓴다.
        fontFamily: TextConfig.bodyFamily,
        textTheme: TextTheme(
          bodyLarge: TextConfig.bodyL,
          bodyMedium: TextConfig.bodyM,
          bodySmall: TextConfig.bodyS,
          titleLarge: TextConfig.titleL,
          titleMedium: TextConfig.titleM,
          titleSmall: TextConfig.titleS,
          labelLarge: TextConfig.buttonL,
          labelMedium: TextConfig.label,
          labelSmall: TextConfig.caption,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: ColorConfig.brandBlue,
          selectionHandleColor: ColorConfig.brandBlue,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: ColorConfig.bgSurface,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
