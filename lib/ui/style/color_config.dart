import 'package:flutter/material.dart';

/// 피그마 Foundations의 의미 색 변수. 화면에서는 이 이름만 쓴다.
class ColorConfig {
  ColorConfig._();

  // 브랜드 원색
  static const Color brandBlue = Color(0xFF8196C3);
  static const Color brandPink = Color(0xFFEEB5BE);

  // 배경 · 표면
  static const Color bgPage = Color(0xFFF7F7FA);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFECEFF6);
  static const Color bgTintBlue = Color(0xFFE0E5F0);
  static const Color bgTintPink = Color(0xFFFBECEF);
  static const Color bgTintPinkSubtle = Color(0xFFFBF0F2);
  static const Color bgChip = Color(0xFFE6EAF3);
  static const Color bgSegment = Color(0xFFE9EBF2);
  static const Color bgPlaceholder = Color(0xFFE4E6EE);
  static const Color bgDangerSubtle = Color(0xFFFBE3EA);
  static const Color bgDim = Color(0x73141622); // rgba(20,22,34,0.45)
  static const Color bgToast = Color(0xF01F2230); // rgba(31,34,48,0.94)
  static const Color bgPhotoViewer = Color(0xFF12131A);
  static const Color bgVideoPlaceholder = Color(0xFF4A5072);

  // 글자
  static const Color textPrimary = Color(0xFF1F2230);
  static const Color textSecondary = Color(0xFF4A4F5E);
  static const Color textTertiary = Color(0xFF6E7383);
  static const Color textDisabled = Color(0xFF8F94A3);
  static const Color textAccent = Color(0xFF41598B);
  static const Color textRose = Color(0xFF9B3B49);
  static const Color textDanger = Color(0xFFC2475E);
  static const Color textSuccess = Color(0xFF3F7A3A);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // 액션
  static const Color actionPrimary = Color(0xFFADBBD8);
  static const Color actionDisabled = Color(0xFFE4E6EE);
  static const Color actionDanger = Color(0xFFC2475E);
  static const Color actionNeutral = Color(0xFFEEF0F4);
  static const Color actionDark = Color(0xFF000000);

  // 테두리
  static const Color borderDefault = Color(0xFFD5D8E0);
  static const Color borderSubtle = Color(0xFFEEF0F4);
  static const Color borderFocus = Color(0xFF8196C3);

  // 기타
  static const Color removeBadge = Color(0xFF3A3F4F);
}

/// 그라데이션 (쓰는 곳 한정).
class AppGradients {
  AppGradients._();

  static const Color _headerStart = Color(0xFFADBBD8);
  static const Color _headerEnd = Color(0xFFF4CFD5);

  /// 홈 헤더
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_headerStart, _headerEnd],
  );

  /// 로그인·스플래시·약관 배경
  static const LinearGradient onboarding = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_headerStart, _headerEnd],
  );

  /// 일기 쓰기 버튼·아바타·진행 바
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ColorConfig.brandBlue, ColorConfig.brandPink],
  );

  /// 시식평·프로필·빈 상태 카드
  static const LinearGradient cardTint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ColorConfig.bgTintBlue, ColorConfig.bgTintPink],
  );

  /// 전체 로딩 링 (Full Loading)
  static const LinearGradient loadingRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9D3EA), Color(0xFFF2CDD5)],
  );

  /// 상세·문답·입력 화면 배경
  static const LinearGradient pageTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE6EAF3), Color(0xFFF1EDF3), ColorConfig.bgPage],
    stops: [0.0, 0.5, 1.0],
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F1F2230),
      offset: Offset(0, 2),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> segment = [
    BoxShadow(
      color: Color(0x1F1F2230),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> bubble = [
    BoxShadow(
      color: Color(0x0F1F2230),
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x668196C3),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> option = [
    BoxShadow(
      color: Color(0x338C96C8),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> toast = [
    BoxShadow(
      color: Color(0x2E1F2230),
      offset: Offset(0, 6),
      blurRadius: 8,
    ),
  ];
}
