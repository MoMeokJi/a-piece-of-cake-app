import 'dart:ui';

extension StringColorExtension on String {
  Color toColor() {
    // 스트링 헥사코드를 Color로 변환하는 익스텐션
    String hex = replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
