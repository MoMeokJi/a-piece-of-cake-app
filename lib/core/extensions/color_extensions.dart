import 'dart:ui';

extension StringColorExtension on String {
  /// "#8196C3" / "8196C3" → Color. 못 읽으면 투명.
  Color toColor() {
    final hex = replaceAll('#', '').trim();
    if (hex.length != 6 && hex.length != 8) return const Color(0x00000000);
    final value = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return value == null ? const Color(0x00000000) : Color(value);
  }
}
