import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? width;
  static double? height;
  static Orientation? orientation;
  static const double designWidth = 412.0; // 안드로이드 사이즈 기준으로 잡음
  static const double designHeight = 917.0; // 안드로이드 사이즈 기준으로 잡음

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
  }
}

// 세로 비율에 따른 높이
double getHeight(double inputHeight) {
  double screenHeightPortrait =
      (inputHeight / SizeConfig.designHeight) * SizeConfig.height!;
  double screenHeightLandscape =
      (inputHeight / SizeConfig.designWidth) * SizeConfig.width!;

  return SizeConfig.orientation == Orientation.portrait
      ? screenHeightPortrait
      : screenHeightLandscape;
}

// 가로 비율에 따른 너비
double getWidth(double inputWidth) {
  double screenWidthPortrait =
      (inputWidth / SizeConfig.designWidth) * SizeConfig.width!;
  double screenWidthLandscape =
      (inputWidth / SizeConfig.designWidth) * SizeConfig.height!;
  return SizeConfig.orientation == Orientation.portrait
      ? screenWidthPortrait
      : screenWidthLandscape;
}
