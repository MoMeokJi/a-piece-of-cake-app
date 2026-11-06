import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

/// 피그마 글자 스타일. 제목 계열은 NanumSquareRound Bold, 본문 계열은 Pretendard.
/// 모든 스타일에 자간 -1%가 들어간다.
class TextConfig {
  TextConfig._();

  static const String roundFamily = 'NanumSquareRound';
  static const String bodyFamily = 'Pretendard';

  static TextStyle _round(double size, double lineHeight, {Color? color}) =>
      TextStyle(
        fontFamily: roundFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: lineHeight / size,
        letterSpacing: -size * 0.01,
        color: color ?? ColorConfig.textPrimary,
      );

  static TextStyle _body(
    double size,
    double lineHeight, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontWeight: weight,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: -size * 0.01,
    color: color ?? ColorConfig.textPrimary,
  );

  // ----- 제목 (Round) -----
  static final TextStyle display = _round(24, 34);
  static final TextStyle titleL = _round(22, 32);
  static final TextStyle titleM = _round(20, 28);
  static final TextStyle titleS = _round(17, 24);

  /// Round/Button L 16/24
  static final TextStyle buttonL = _round(16, 24);

  /// Round/Button S 14/20 (칩·세그먼트)
  static final TextStyle buttonS = _round(14, 20);

  /// Round/Tab 12/16 (하단 탭)
  static final TextStyle tab = _round(12, 16);

  // ----- 본문 (Pretendard) -----
  static final TextStyle bodyLStrong = _body(16, 24, weight: FontWeight.w600);
  static final TextStyle bodyL = _body(16, 24, weight: FontWeight.w500);
  static final TextStyle bodyMStrong = _body(15, 22, weight: FontWeight.w600);
  static final TextStyle bodyM = _body(15, 24);
  static final TextStyle bodyMLong = _body(15, 26);
  static final TextStyle bodyMChat = _body(15, 22);
  static final TextStyle bodyS = _body(14, 20);
  static final TextStyle bodySMedium = _body(14, 20, weight: FontWeight.w500);
  static final TextStyle label = _body(13, 20);
  static final TextStyle labelStrong = _body(13, 20, weight: FontWeight.w600);
  static final TextStyle caption = _body(12, 16);
  static final TextStyle captionStrong = _body(12, 16, weight: FontWeight.w600);

  // ----- 숫자 (Pretendard) -----
  static final TextStyle numberL = _body(18, 24, weight: FontWeight.w600);
  static final TextStyle numberM = _body(14, 20);
  static final TextStyle numberMStrong = _body(14, 20, weight: FontWeight.w600);
  static final TextStyle numberS = _body(12, 16);

  /// 입력창 본문 17/24 Medium
  static final TextStyle input = _body(17, 24, weight: FontWeight.w500);
}
