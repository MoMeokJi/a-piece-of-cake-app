import 'package:cake/config/di.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/my_app.dart';
import 'package:cake/config/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 시스템 UI(상태바/내비게이션바) 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: ColorConfig.bottomNavi,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      // systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  await diSetup();

  // 테스트 데이터 생성 (개발용)
  await _createTestData();

  runApp(const MyApp());
}

// 테스트 데이터 생성 함수
Future<void> _createTestData() async {
  try {
    final diaryDao = getIt<DiaryDao>();

    // 기존 일기 개수 확인
    final existingDiaries = await diaryDao.getAllDiariesLatest();

    // 이미 테스트 데이터가 있으면 스킵
    if (existingDiaries.isNotEmpty) {
      print('테스트 데이터가 이미 존재합니다. 스킵합니다.');
      return;
    }

    print('테스트 데이터를 생성합니다...');

    final random = Random();
    final now = DateTime.now();

    // 7, 8, 9월에 무작위로 일기 생성
    for (int month = 7; month <= 9; month++) {
      // 각 월에 5-15개의 일기 생성
      final diaryCount = random.nextInt(11) + 5; // 5-15개

      for (int i = 0; i < diaryCount; i++) {
        final day = random.nextInt(28) + 1; // 1-28일
        final hour = random.nextInt(23) + 1; // 1-23시
        final minute = random.nextInt(60); // 0-59분

        final createdAt = DateTime(now.year, month, day, hour, minute);

        final diary = Diary(
          id: random.nextInt(10000) + 1,
          summary: _generateRandomSummary(),
          createdAt: createdAt,
          firstColorHex: _getRandomColorHex(),
          secondColorHex: _getRandomColorHex(),
          musicTitle: _getRandomMusicTitle(),
          musicArtist: _getRandomMusicArtist(),
        );

        // DAO에 직접 저장
        await diaryDao.insertDiary(diary);
      }
    }

    print('테스트 데이터 생성 완료!');
  } catch (e) {
    print('테스트 데이터 생성 중 에러: $e');
  }
}

String _generateRandomSummary() {
  final summaries = [
    '오늘은 정말 좋은 하루였다. 햇살이 따뜻하고 바람도 시원했다.',
    '친구들과 함께 맛있는 음식을 먹었다. 정말 행복한 시간이었다.',
    '새로운 책을 읽기 시작했다. 흥미로운 내용이 많다.',
    '운동을 하고 나니 기분이 좋아졌다. 앞으로도 꾸준히 해야겠다.',
    '가족과 함께 시간을 보냈다. 소중한 순간들이었다.',
    '새로운 음악을 발견했다. 정말 좋은 곡이다.',
    '맛있는 커피를 마시며 여유로운 시간을 가졌다.',
    '친구와 긴 통화를 했다. 정말 즐거웠다.',
    '새로운 영화를 봤다. 정말 재미있었다.',
    '책을 읽으며 조용한 시간을 가졌다.',
  ];
  return summaries[Random().nextInt(summaries.length)];
}

String _getRandomColorHex() {
  final colors = [
    '#E57373', // 빨강
    '#81C784', // 초록
    '#64B5F6', // 파랑
    '#FFB74D', // 주황
    '#BA68C8', // 보라
    '#4DB6AC', // 청록
    '#FF8A65', // 주황빨강
    '#9575CD', // 연보라
  ];
  return colors[Random().nextInt(colors.length)];
}

String _getRandomMusicTitle() {
  final titles = [
    '좋은 날',
    '봄날',
    '여름밤',
    '가을비',
    '겨울노래',
    '별이 빛나는 밤',
    '햇살',
    '바람',
    '꽃',
    '나비',
  ];
  return titles[Random().nextInt(titles.length)];
}

String _getRandomMusicArtist() {
  final artists = [
    '아이유',
    '태연',
    '에일리',
    '선미',
    '청하',
    'ITZY',
    'NewJeans',
    'LE SSERAFIM',
    'aespa',
    'IVE',
  ];
  return artists[Random().nextInt(artists.length)];
}
