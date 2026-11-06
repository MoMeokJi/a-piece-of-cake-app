import 'package:flutter/widgets.dart';

/// 간격 4 / 8 / 12 / 16 / 20 / 24 / 32. 화면 좌우 여백 20, 카드 안 여백 20.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double page = 20;
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
}

/// 모서리 12 / 14(버튼) / 16(입력·리스트) / 20(카드) / 24(시트 상단) / 28(바텀시트) / full
class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double sheet = 28;
  static const double full = 999;

  static BorderRadius circular(double r) => BorderRadius.circular(r);
}
