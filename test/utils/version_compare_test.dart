import 'package:cake/utils/version_compare.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('semver 비교', () {
    expect(compareVersions('1.0.0', '1.0.0'), 0);
    expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
    expect(compareVersions('1.2.0', '1.10.0'), lessThan(0));
    expect(compareVersions('2.0.0', '1.99.99'), greaterThan(0));
    expect(compareVersions('1.1', '1.1.0'), 0);
    expect(compareVersions('1.1.0+7', '1.1.0'), 0);
  });
}
