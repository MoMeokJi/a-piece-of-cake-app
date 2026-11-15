/// 에셋 경로 상수. 피그마 Components › Images / Icons와 1:1.
class AppImages {
  AppImages._();

  /// 세로형 흰 로고 (벡터). 스플래시·로그인·안내 배경. 너비 150 기준.
  static const String logoStacked = 'assets/images/logo_stacked_white.svg';

  /// 납작 케이크 조각. 로딩·빈 상태·브랜드 마크·봇 아바타 공통 (2.0x/3.0x 포함).
  static const String cakeSlice = 'assets/images/cake_slice.png';
  static const String cake3dStrawberry =
      'assets/images/figma/cake_3d_strawberry.png';
  static const String cake3dBlueberry =
      'assets/images/figma/cake_3d_blueberry.png';
  static const String iconFlavor = 'assets/images/figma/icon_flavor.png';
  static const String iconColor = 'assets/images/figma/icon_color.png';
  static const String iconMusic = 'assets/images/figma/icon_music.png';

  static const String loadingHalo = 'assets/images/figma/loading_halo.svg';
  static const String toastIconInfo = 'assets/images/figma/toast_icon_info.svg';
  static const String toastIconError =
      'assets/images/figma/toast_icon_error.svg';
  static const String fieldIconValid =
      'assets/images/figma/field_icon_valid.svg';
  static const String fieldIconError =
      'assets/images/figma/field_icon_error.svg';
  static const String chipIconPen = 'assets/images/figma/chip_icon_pen.svg';
}

/// 24px 라인 아이콘. 색은 AppIcon 위젯에서 바꾼다.
enum AppIcons {
  back,
  chevronRight,
  chevronDown,
  home,
  user,
  pen,
  plus,
  arrowUp,
  camera,
  image,
  headphones,
  chat,
  trash,
  info,
  check,
  close,
  play,
  more,
  clear,
  spinner;

  String get path => 'assets/icons/ui/${_fileName()}.svg';

  String _fileName() => switch (this) {
    AppIcons.chevronRight => 'chevron_right',
    AppIcons.chevronDown => 'chevron_down',
    AppIcons.arrowUp => 'arrow_up',
    _ => name,
  };
}
