import 'package:cake/utils/date_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('오프셋이 있는 서버 날짜는 그 오프셋으로 읽는다', () {
    final parsed = DateConverter.parseServerDate('2025-09-05T21:12:00+09:00');
    expect(parsed.toUtc(), DateTime.utc(2025, 9, 5, 12, 12));
  });

  test('오프셋이 없는 옛 응답은 KST로 간주한다', () {
    final parsed = DateConverter.parseServerDate('2025-09-05T21:12:00');
    expect(parsed.toUtc(), DateTime.utc(2025, 9, 5, 12, 12));
  });

  test('못 읽는 값은 1900-01-01', () {
    expect(DateConverter.parseServerDate('nope'), DateTime(1900, 1, 1));
    expect(DateConverter.parseServerDate(null), DateTime(1900, 1, 1));
  });
}
