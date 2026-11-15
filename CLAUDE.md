# 조각케이크 (a-piece-of-cake-app)

하루를 일기로 기록하는 Flutter 앱. 안드로이드/iOS 출시 중.

## 도메인 개념

- **계정** — Apple·Google 소셜 로그인. Android는 Google만. 서버는 `deviceId`(설치당 UUID, secure storage)로 기기를 구분하고, 토큰은 응답 **바디**로 온다 (`AuthSession`)
- **닉네임** — 완성형 한글·영문·숫자 2~10자 (`ServiceConfig.nicknamePattern`). 중복 허용, 실시간 검사 없음. 가입 직후 설정 화면에서 SDK 이름을 미리 채운다
- **자유일기 (free)** — 사용자가 직접 쓴다
- **문답일기 (qna)** — 서버가 준 질문 5개(앞 2개 필수)에 답하면 서버가 일기를 생성한다. 선택 문항은 건너뛸 수 있는데, 그러면 응답의 `optionalSpares`에서 하나 꺼내 **같은 자리**에 넣는다. 여분이 떨어지면 건너뛰기는 토스트로 막는다. 그래서 생성 요청엔 항상 5문항의 답이 간다. 질문 조회는 진입 때 한 번뿐
- 일기에는 이미지(최대 4장), 요약, 색상 2개(`{name, hex}`, name은 없을 수 있음), 추천 음악(YouTube, 길이는 없을 수 있음)이 붙는다
- **시식평(feedback)** — 작성 후 약 10분 뒤 서버 배치가 만든다. 그 전엔 null이라 "곧 도착해요" 상태를 보여준다
- 하루 한도는 서버 `GET /users/me/stats`의 `dailyLimit`이 기준이고 `ServiceConfig.maxDiaryCount`는 fallback. 초과하면 서버가 429 `DIARY_DAILY_LIMIT_EXCEEDED`
- 목록·캘린더는 서버가 원본이다 (`GET /diaries` 페이지, `GET /diaries/calendar`). 로컬 DB는 없다
- 알림은 토글 하나(`PUT /users/me/notification`)로 리마인드·공감 푸시를 함께 켠다. 관리자 공지는 무관
- **푸시 페이로드** — 서버는 두 플랫폼 모두 `notification{title, body}` + `data{type, diaryId?}`를 보낸다. `type`은 `FEEDBACK`(diaryId 문자열 동반)·`REMIND`·`ADMIN_MESSAGE` 셋뿐. Android 채널 ID는 `high_importance_channel`(서버 AndroidConfig·매니페스트·`NotificationServiceImpl` 세 곳이 같아야 한다)

## 레이어

`presentation` → `domain` ← `data`

- `lib/domain/` — 모델, 리포지토리/서비스 인터페이스, enum. **외부 패키지에 의존하지 않는다** (freezed_annotation만 예외)
- `lib/data/` — API, sqflite DAO, shared_preferences, 리포지토리 구현, DTO, 매퍼. **presentation을 import하지 않는다**
- `lib/presentation/` — 화면과 ViewModel. **`lib/data/data_source/`를 직접 쓰지 않는다.** 항상 리포지토리를 거친다 (단, 아래 예외 참고)
- `lib/ui/` — 공용 위젯과 디자인 토큰 (`color_config`, `text_config`)
- `lib/core/` — `extensions/`에 확장 메서드를 둔다 (예: `color_extensions.dart`)
- `lib/utils/` — `AppLogger`, `CrashReporter`, 날짜 변환, 다이얼로그 유틸
- `lib/config/` — DI, 라우터, 설정 상수. 합성 루트이므로 모든 레이어를 안다

이 규칙은 `test/architecture_test.dart`가 강제한다. 어기면 테스트가 실패한다.
`lib/ui/`도 presentation·data를 import하지 않는다 (공용 위젯은 도메인 모델과 토큰만 안다).

shared_preferences는 `AppPrefsRepository` 뒤에 있다. 예외 없이 presentation은 항상 리포지토리를 거친다.

화면끼리 직접 참조하지 않는다. 일기가 생성·수정·삭제되면 `DiaryChangeNotifier`(DI 싱글턴)를
울리고, `HomeViewModel`·`MyViewModel`이 듣고 다시 불러온다.

## 화면 하나를 추가할 때

순서대로 손댄다.

1. `lib/presentation/<feature>/<feature>_view_model.dart` — `ChangeNotifier` 상속, 리포지토리를 생성자 주입
2. `lib/presentation/<feature>/<feature>_screen.dart` — `context.watch<T>()`로 구독, `context.read<T>()`로 호출
3. `lib/config/di.dart` — ViewModel 등록. 탭처럼 상태를 유지해야 하면 `registerLazySingleton`, 아니면 `registerFactory`. 라우트 extra를 생성자에 넣어야 하면 `registerFactoryParam`
4. `lib/config/app_router.dart` — 경로 추가
5. `test/presentation/<feature>/<feature>_view_model_test.dart` — Fake 리포지토리로 상태 전이 검증

화면이 커지면 `lib/presentation/<feature>/components/` 아래로 위젯을 뺀다.

디자인은 피그마 `QCsx45ysi49gwfY76gYMT9` (Screens / Components / Foundations)가 기준이다.
색은 `ColorConfig`의 의미 이름(bg/text/action/border)만, 글자는 `TextConfig`의 16개 스타일만 쓴다
(제목 계열 NanumSquareRound Bold, 본문 계열 Pretendard, 자간 -1%). 간격·모서리는 `AppSpacing`·`AppRadius`.
공용 위젯은 `lib/ui/common_components/`에 피그마 Components와 1:1로 있다. 치수는 피그마 값(390 기준) 그대로 쓰고 비율 스케일링을 하지 않는다.

## 명령어

```bash
flutter run --dart-define-from-file=$HOME/development/keys/cake-social-login.json   # 실행 (소셜 로그인 ID 필요)
flutter run --dart-define=API_BASE_URL=https://test.example   # 테스트 서버로
flutter test                         # 테스트
flutter analyze                      # 정적 분석
dart run build_runner build --delete-conflicting-outputs   # freezed / json_serializable 생성
dart run flutter_launcher_icons       # 앱 아이콘 재생성 (assets/icon/ 원본이 바뀌었을 때)
./scripts/deploy.sh android          # Play 내부 테스트 트랙에 업로드 (ios / all)
./scripts/deploy.sh all --check-only # 빌드 없이 점검만 (--build-only: 업로드 직전까지)
bash scripts/test/preflight_test.sh  # 배포 스크립트 테스트
```

배포 스크립트는 rbenv Ruby(`.ruby-version`)와 Android SDK의 `aapt2`를 쓴다. 새 맥에서는
`brew install rbenv ruby-build && rbenv install && bundle install`, 그리고 `~/development/keys/`를
다른 맥에서 에어드랍으로 받아 같은 경로에 둔다. PATH의 brew가 인텔용(`/usr/local`)인 애플 실리콘 맥은
Ruby 빌드가 OpenSSL을 못 찾는다 — `/opt/homebrew/bin/brew install openssl@3 libyaml` 후
`RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@3 --with-libyaml-dir=/opt/homebrew/opt/libyaml" rbenv install`

freezed 모델이나 DTO를 고치면 build_runner를 반드시 다시 돌린다.

## 함정

- **비밀값은 dart-define으로 받는다.** `ApiConfig.baseUrl`(기본 운영 서버), `AuthConfig.googleServerClientId`·`googleIosClientId`는 `String.fromEnvironment`다. 배포 스크립트는 `~/development/keys/cake-social-login.json`을 `--dart-define-from-file`로 넘긴다. 로컬 실행도 같은 파일을 넘겨야 Google 로그인이 된다
- **Google 서버 검증은 웹 클라이언트 ID로 한다.** `GOOGLE_SERVER_CLIENT_ID`에 넣는 값은 서버가 idToken audience로 검사하는 값과 같아야 한다. Firebase 콘솔에서 Google 로그인을 켜고 SHA-1을 등록한 뒤 `google-services.json`·`GoogleService-Info.plist`를 다시 받아야 하며, iOS `Info.plist`의 URL scheme(`REPLACE_WITH_REVERSED_CLIENT_ID`)을 plist의 `REVERSED_CLIENT_ID`로 바꿔야 한다
- **테스트에서 Firebase를 초기화하지 않는다.** 크래시 보고는 `CrashReporter`(테스트는 `NoopCrashReporter`), 애널리틱스는 `AnalyticsService`(테스트는 `NoopAnalyticsService`)를 거친다. ViewModel에서 `FirebaseAnalytics.instance`를 직접 부르지 말 것
- **HTTP 클라이언트는 `dio` 하나다.** 인증 헤더, 재발급(single-flight), 에러 보고가 `AuthInterceptor`·`ErrorReportingInterceptor`에 붙어 있다. 401 처리 규칙: `TOKEN_EXPIRED` → refresh 후 재시도, `TOKEN_INVALID`·`REFRESH_INVALID` → 토큰 삭제 + 로그인 화면(`di.dart`의 `_handleSessionExpired`). 인증이 필요 없는 요청은 `AuthInterceptor.needsAuthKey: false`
- **서버 에러는 RFC 9457 `code`로 구분한다.** `api_error_mapper.dart`가 dio 예외를 도메인 예외(`DiaryDailyLimitExceededException` 등)로 바꾼다. 리포지토리는 `on DioException catch (e) { throw mapOrRethrow(e); }`
- **deviceId 시절 유저는 버렸다.** 업데이트 후 첫 실행에서 `LegacyDataCleanupService`가 옛 토큰·sqflite(`cake.db`)·prefs를 지우고, 옛 세션이 있었으면 "계정 방식 변경" 안내를 한 번 띄운다. `sqflite` 의존성은 이 삭제 한 줄 때문에만 남아 있다
- **푸시 탭은 data 서비스가 화면을 옮기지 않는다.** `FCMServiceImpl`·`NotificationServiceImpl`은 탭을 `PushEventService.publish`로 넘기기만 하고, 로그인된 `MainViewModel`이 받아 `diaryIdToOpen`을 세우면 `MainScreen`이 `/diary-detail`을 push한다. 같은 일기 상세가 맨 위에 있으면 push하지 않는다. 듣는 쪽이 없을 때(앱이 알림으로 켜짐, 로그인 전) 들어온 탭은 `takePending`으로 보류된다. 포그라운드 수신은 어느 플랫폼도 이동하지 않고 `publishReceived`로만 알린다 (iOS는 OS 배너, Android는 로컬 알림). 열려 있는 `DiaryDetailViewModel`은 자기 일기의 시식평 수신·탭을 듣고 `refreshQuietly`로 로딩 없이 갱신한다. 백그라운드 아이솔레이트 핸들러는 없다. 토큰은 세션이 있을 때 `AuthRepository.registerFcmToken`이 등록하고 `onTokenRefresh`에도 다시 등록한다. 알림 권한은 `FCMService.initialize`의 `requestPermission` 한 곳에서만 묻는다
- **서버 PATCH는 본문만 받는다.** 상세의 "수정하기"(`/diary-edit`)에서 사진은 보여주기만 하고 추가·삭제를 지원하지 않는다
- **Xcode에서 바로 Archive하지 않는다.** 버전은 `flutter build`가 `pubspec.yaml`에서 `ios/Flutter/Generated.xcconfig`로 복사할 때 들어간다. Xcode Archive만 하면 예전 번호가 들어간다. 꼭 해야 하면 먼저 `flutter build ipa`를 돌린다
- **배포 키는 저장소 밖 `~/development/keys/`에 있다.** 무엇이 어디 쓰이는지는 그 폴더의 `README.md`. 키 ID·Issuer ID도 저장소에 적지 않는다

## 릴리즈

1. `pubspec.yaml`의 `version`을 올린 커밋을 `dev`에 푸시하고 `./scripts/deploy.sh all`을 돌린다. 빌드 번호(`+N`)는 두 플랫폼이 같이 쓰며, 두 스토어의 최신 번호보다 커야 한다. 심사 제출은 콘솔에서 직접 한다
2. **스토어 승인이 난 뒤에** `main`으로 fast-forward 머지하고 태그를 단다
3. 태그는 lightweight, `android/v1.1.0` · `ios/v1.0.0` 형식. versionName은 그대로인데 versionCode만 오른 재업로드는 `android/v1.1.0+6`

승인 전에는 main 머지도 태그도 하지 않는다.

## 패턴 참고

이 저장소의 규칙은 이 문서가 기준이다. `~/.claude/skills/`의 `flutter-*` 스킬은 여러 Flutter 프로젝트에서 공용으로 쓰는 일반 문서라 **경로와 구조가 이 앱과 다르다.** 충돌하면 이 문서가 이긴다.

| 스킬 | 이 앱에 적용되는가 |
| --- | --- |
| `flutter-presentation-mvvm` | 적용된다. `context.watch/read` + ChangeNotifier getter 방식이 이 앱과 같다 |
| `flutter-data-layer` | 부분적으로 적용된다. DataSource 인터페이스 + Repository + DTO/매퍼 구조는 같다. 단 `rxdart`/`BehaviorSubject` 반응형 저장소 절은 **적용되지 않는다** (의존성도 없다). 로컬 DB도 없다 |
| `flutter-testing` | 적용된다 |
| `flutter-widget-ui` | 적용된다. 단 공용 위젯 경로는 다르다 — 스킬은 `lib/core/presentation/components/`, 이 앱은 `lib/ui/common_components/` |
| `flutter-di-get-it` | 개념은 적용되지만 세부는 이 문서가 기준이다. 등록 규칙은 위 "화면 하나를 추가할 때" 3번을 따른다. 경로도 다르다 — 스킬은 `lib/core/di/di_setup.dart`, 이 앱은 `lib/config/di.dart` |
| `flutter-navigation-go-router` | 라우팅 개념만 적용된다. 경로는 다르다 — 스킬은 `lib/core/routing/`, 이 앱은 `lib/config/app_router.dart` |
| `flutter-project-structure` | **적용되지 않는다.** `lib/core/` + `lib/domain/use_case/` 레이아웃을 서술하며 예시도 다른 앱의 것이다. 이 앱의 구조는 위 "레이어" 절이 기준이다 |
| `flutter-presentation-mvi` | **적용되지 않는다.** 이 앱은 sealed Action도 Root/Screen 분리도 쓰지 않는다 |
| `flutter-error-handling` | **아직 적용되지 않는다.** 이 앱에는 `Result<D, E>`가 없다. 도입 여부는 미정 |
