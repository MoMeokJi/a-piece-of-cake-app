import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 디렉터리 아래 모든 dart 파일의 (경로, import 목록)을 모은다.
Map<String, List<String>> _importsUnder(String directory) {
  final result = <String, List<String>>{};
  final dir = Directory(directory);
  if (!dir.existsSync()) return result;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') ||
        entity.path.endsWith('.freezed.dart')) {
      continue;
    }

    final imports = entity
        .readAsLinesSync()
        .where(
          (line) => line.startsWith('import ') || line.startsWith('export '),
        )
        .toList();
    result[entity.path] = imports;
  }
  return result;
}

void main() {
  test('domain은 cake와 freezed_annotation 외의 패키지에 의존하지 않는다', () {
    const allowed = {'package:cake/', 'package:freezed_annotation/'};
    final violations = <String>[];

    _importsUnder('lib/domain').forEach((path, imports) {
      for (final import in imports) {
        if (!import.contains('package:')) continue;
        if (allowed.any(import.contains)) continue;
        violations.add('$path → $import');
      }
    });

    expect(violations, isEmpty, reason: 'domain 레이어의 외부 패키지 의존');
  });

  test('domain은 data·presentation·ui를 import하지 않는다', () {
    final violations = <String>[];

    _importsUnder('lib/domain').forEach((path, imports) {
      for (final import in imports) {
        if (import.contains('package:cake/data/') ||
            import.contains('package:cake/presentation/') ||
            import.contains('package:cake/ui/')) {
          violations.add('$path → $import');
        }
      }
    });

    expect(violations, isEmpty, reason: 'domain → 바깥 레이어 의존');
  });

  test('data는 presentation을 import하지 않는다', () {
    final violations = <String>[];

    _importsUnder('lib/data').forEach((path, imports) {
      for (final import in imports) {
        if (import.contains('package:cake/presentation/')) {
          violations.add('$path → $import');
        }
      }
    });

    expect(violations, isEmpty, reason: 'data → presentation 역방향 의존');
  });

  test('presentation은 data_source를 직접 import하지 않는다', () {
    final violations = <String>[];

    _importsUnder('lib/presentation').forEach((path, imports) {
      for (final import in imports) {
        if (import.contains('package:cake/data/data_source/')) {
          violations.add('$path → $import');
        }
      }
    });

    expect(violations, isEmpty, reason: 'presentation → data_source 직접 의존');
  });

  test('ui(공용 위젯)는 presentation과 data를 import하지 않는다', () {
    final violations = <String>[];

    _importsUnder('lib/ui').forEach((path, imports) {
      for (final import in imports) {
        if (import.contains('package:cake/presentation/') ||
            import.contains('package:cake/data/')) {
          violations.add('$path → $import');
        }
      }
    });

    expect(violations, isEmpty, reason: 'ui → presentation/data 의존');
  });
}
