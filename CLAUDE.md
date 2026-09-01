# 조각케이크 (a-piece-of-cake-app)

하루를 일기로 기록하는 Flutter 앱. 안드로이드/iOS 출시 중.

## 도메인 개념

- **자유일기 (free)** — 사용자가 직접 쓴다
- **문답일기 (qna)** — 서버가 준 질문에 답하면 서버가 일기를 생성한다
- 일기에는 이미지(최대 4장), 요약, 대표 색상 2개, 추천 음악이 붙는다
- 하루 최대 3개까지 쓸 수 있다 (`ServiceConfig.maxDiaryCount`)

## 레이어

`presentation` → `domain` ← `data`

- `lib/domain/` — 모델, 리포지토리/서비스 인터페이스, enum. **외부 패키지에 의존하지 않는다** (freezed_annotation만 예외)
- `lib/data/` — API, sqflite DAO, shared_preferences, 리포지토리 구현, DTO, 매퍼. **presentation을 import하지 않는다**
- `lib/presentation/` — 화면과 ViewModel. **`lib/data/data_source/`를 직접 쓰지 않는다.** 항상 리포지토리를 거친다
- `lib/ui/` — 공용 위젯과 디자인 토큰 (`color_config`, `text_config`)
- `lib/config/` — DI, 라우터, 설정 상수. 합성 루트이므로 모든 레이어를 안다

이 규칙은 `test/architecture_test.dart`가 강제한다. 어기면 테스트가 실패한다.

## 화면 하나를 추가할 때

순서대로 손댄다.

1. `lib/presentation/<feature>/<feature>_view_model.dart` — `ChangeNotifier` 상속, 리포지토리를 생성자 주입
2. `lib/presentation/<feature>/<feature>_screen.dart` — `context.watch<T>()`로 구독, `context.read<T>()`로 호출
3. `lib/config/di.dart` — ViewModel 등록. 탭처럼 상태를 유지해야 하면 `registerLazySingleton`, 아니면 `registerFactory`
4. `lib/config/app_router.dart` — 경로 추가
5. `test/presentation/<feature>/<feature>_view_model_test.dart` — Fake 리포지토리로 상태 전이 검증

화면이 커지면 `lib/presentation/<feature>/components/` 아래로 위젯을 뺀다.

## 명령어

```bash
flutter run                          # 실행
flutter test                         # 테스트
flutter analyze                      # 정적 분석
dart run build_runner build --delete-conflicting-outputs   # freezed / json_serializable 생성
```

freezed 모델이나 DTO를 고치면 build_runner를 반드시 다시 돌린다.

## 함정

- **`lib/config/di.dart`의 mock API 토글.** `MockDiaryApi` 등록 줄이 주석 처리되어 있다. 실수로 주석을 풀고 커밋하면 앱이 목 데이터로 빌드된다
- **`ApiConfig.baseUrl`이 하드코딩되어 있다.** `flutter_dotenv`는 의존성에 있었지만 쓰이지 않아 제거했다
- **테스트에서 Firebase를 초기화하지 않는다.** 크래시 보고는 `CrashReporter`를 거치며, 테스트는 `NoopCrashReporter`를 주입한다

## 릴리즈

1. 버전 커밋(`android/app/build.gradle.kts`의 versionCode/versionName)을 `dev`에 푸시한다
2. **스토어 승인이 난 뒤에** `main`으로 fast-forward 머지하고 태그를 단다
3. 태그는 lightweight, `android/v1.1.0` · `ios/v1.0.0` 형식. versionName은 그대로인데 versionCode만 오른 재업로드는 `android/v1.1.0+6`

승인 전에는 main 머지도 태그도 하지 않는다.

## 패턴 참고

코딩 패턴은 `~/.claude/skills/`의 `flutter-*` 스킬을 따른다. 이 문서는 그 내용을 반복하지 않는다.
