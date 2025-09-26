import 'package:cake/config/app_router.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp.router(
      title: 'PieceOfCake',
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어 (fallback)
      ],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: ColorConfig.primary,
        scaffoldBackgroundColor: ColorConfig.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConfig.primary,
          brightness: Brightness.light,
        ),
        // 탭했을 때 퍼지는 물결 효과의 색상 -> expansionTile같은데서 적용됨
        splashColor: ColorConfig.primary.withValues(alpha: 0.1),
        // 탭하고 있을 때의 배경색 -> expansionTile같은데서 적용됨
        highlightColor: Colors.grey.withValues(alpha: 0.1),
        fontFamily: 'NanumSquareRound',
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
