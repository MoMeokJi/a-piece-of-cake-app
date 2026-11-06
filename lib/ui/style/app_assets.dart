/// 에셋 경로 상수. 피그마 Components › Images / Icons와 1:1.
class AppImages {
  AppImages._();

  static const String logo = 'assets/images/figma/logo.png';
  static const String cake3dStrawberry =
      'assets/images/figma/cake_3d_strawberry.png';
  static const String cake3dBlueberry =
      'assets/images/figma/cake_3d_blueberry.png';
  static const String cakePlateStrawberry =
      'assets/images/figma/cake_plate_strawberry.png';
  static const String cakePlateBlueberry =
      'assets/images/figma/cake_plate_blueberry.png';
  static const String cakeFlatStrawberry =
      'assets/images/figma/cake_flat_strawberry.png';
  static const String cakeFlatBlueberry =
      'assets/images/figma/cake_flat_blueberry.png';
  static const String iconFlavor = 'assets/images/figma/icon_flavor.png';
  static const String iconColor = 'assets/images/figma/icon_color.png';
  static const String iconMusic = 'assets/images/figma/icon_music.png';

  static const String loadingHalo = 'assets/images/figma/loading_halo.svg';
  static const String loadingRing = 'assets/images/figma/loading_ring.svg';
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
