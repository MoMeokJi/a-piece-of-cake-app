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
        .where((line) => line.startsWith('import '))
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
  }, skip: 'Task 11에서 domain의 플랫폼 의존을 제거하며 해제한다');

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
    // shared_preferences의 Storage는 아직 예외로 둔다.
    // 별도 과제로 리포지토리 뒤로 감춘다.
    const exempt = 'package:cake/data/data_source/shared_preferences/';
    final violations = <String>[];

    _importsUnder('lib/presentation').forEach((path, imports) {
      for (final import in imports) {
        if (!import.contains('package:cake/data/data_source/')) continue;
        if (import.contains(exempt)) continue;
        violations.add('$path → $import');
      }
    });

    expect(violations, isEmpty, reason: 'presentation → data_source 직접 의존');
  });
}
