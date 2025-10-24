import 'dart:io';

import 'package:cake/config/di.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/service/fcm_service.dart';
import 'package:cake/domain/service/notification_service.dart';
import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/my_app.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'package:cake/config/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_logger.dart';

// Background 메시지 처리를 위한 top-level function
// 반드시 main 파일의 최상단에 위치해야 함
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler에서는 DI를 사용할 수 없어서 직접 인스턴스 생성
  await Firebase.initializeApp();

  AppLogger.log('FCM 수신 (top level) : Background 메시지');
  AppLogger.log('제목: ${message.data['title']}', tag: 'FCM');
  AppLogger.log('내용: ${message.data['body']}', tag: 'FCM');
  AppLogger.log('타입: ${message.data['type']}', tag: 'FCM');

  // Android인 경우에만 로컬 노티피케이션 표시 (iOS는 FCM이 자체적으로 처리)
  if (Platform.isAndroid) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // 로컬 노티피케이션 초기화
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
      ),
    );

    // Background에서 로컬 노티피케이션 표시
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'test',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.data['title'] ?? 'message.data[title]이 null. background임니다용',
      message.data['body'] ?? '',
      notificationDetails,
    );
  }
}

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 날짜포맷팅 초기화
  await initializeDateFormatting('ko');

  // 3. FCM Background Handler 등록 (반드시 다른 Firebase 작업 전에 호출)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  // Firebase 초기화
  await _initializeFirebase();
  await diSetup();

  await getIt<PermissionHandlerService>().requestEssentialPermissions();
  await getIt<NotificationService>().initialize();
  await getIt<FCMService>().initialize();

  // 테스트 데이터 생성 (개발용) -> 이거 대신에 나중에 여기서 메인 탭 뷰모델들 초기화시켜서 데이터 가져오게 할수도 있겠다. 아닌가 이건 스플래쉬에서 하려나?
  await _createTestData();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.log(
    '파이어베이스 초기화 appId : ${DefaultFirebaseOptions.currentPlatform.appId}',
  );
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
    for (int month = 9; month <= 9; month++) {
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

Future<void> _createTodayData() async {
  try {
    final diaryDao = getIt<DiaryDao>();

    print('오늘 일기 데이터를 생성합니다...');

    final random = Random();

    // 오늘 날짜로 일기 3개 추가
    final today = DateTime(2025, 10, 24);

    for (int i = 0; i < 3; i++) {
      final hour = random.nextInt(23) + 1; // 1-23시
      final minute = random.nextInt(60); // 0-59분

      final todayDiary = Diary(
        id: random.nextInt(10000) + 10000, // 기존 ID와 겹치지 않게
        summary: _generateRandomSummary(),
        createdAt: DateTime(today.year, today.month, today.day, hour, minute),
        firstColorHex: _getRandomColorHex(),
        secondColorHex: _getRandomColorHex(),
        musicTitle: _getRandomMusicTitle(),
        musicArtist: _getRandomMusicArtist(),
      );

      await diaryDao.insertDiary(todayDiary);
    }
  } catch (e) {
    print('오늘 데이터 생성 중 에러: $e');
  }
}

String _generateRandomSummary() {
  final summaries = [
    '오늘은 정말 좋은 하루였다. 햇살이 따뜻하고 바람도 시원해서 산책하기에 완벽한 날씨였다. 공원을 걸으며 계절의 변화를 느낄 수 있었다.',
    '친구들과 함께 새로 오픈한 이탈리안 레스토랑에서 맛있는 파스타와 피자를 먹었다. 오랜만에 모여서 이야기꽃을 피우며 정말 행복한 시간을 보냈다.',
    '새로운 추리소설을 읽기 시작했다. 첫 장부터 긴장감 넘치는 전개와 흥미로운 캐릭터들이 등장해서 밤늦게까지 읽게 되었다.',
    '오랜만에 헬스장에서 운동을 하고 나니 몸이 개운하고 기분이 좋아졌다. 앞으로도 꾸준히 해야겠다.',
    '가족과 함께 할머니 댁을 방문해서 맛있는 저녁식사를 함께했다. 할머니가 직접 만드신 된장찌개와 김치전이 정말 맛있었다.',
    '유튜브에서 우연히 발견한 인디 밴드의 음악이 정말 마음에 들었다. 하루 종일 반복해서 들었다.',
    '동네 카페에서 맛있는 아메리카노를 마시며 여유로운 시간을 가졌다.',
    '대학교 때 친구와 긴 통화를 했다. 서로의 근황을 나누고 추억을 회상하며 정말 즐거웠다.',
    '평점이 좋다고 해서 본 SF 영화가 기대 이상으로 재미있었다.',
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
