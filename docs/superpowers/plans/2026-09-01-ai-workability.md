# AI 작업성 리팩토링 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 새 세션이 이 저장소에서 기능을 추가할 때, 코드를 광범위하게 읽지 않고도 올바른 첫 수를 두게 만든다.

**Architecture:** 구조를 바꾸지 않는다. 이미 일관된 MVVM + get_it + go_router 구성을 문서화하고(Task 1), 검증 가능하게 만들고(Task 2~4), 네트워크 계층의 반복과 결함을 제거하고(Task 5~8), 레이어 규칙 위반을 실행 가능한 테스트로 못 박은 뒤 회수한다(Task 9~11).

**Tech Stack:** Flutter, provider(ChangeNotifier), get_it, go_router, freezed, sqflite, flutter_secure_storage, dio(신규)

**Spec:** `docs/superpowers/specs/2026-09-01-ai-workability-design.md`

## Global Constraints

- 브랜치: `refactor/ai-workability`. dev는 언제든 릴리즈 가능한 상태로 유지한다
- **기능 변경 금지.** 사용자에게 보이는 동작은 그대로여야 한다. 유일한 예외는 Task 6의 401 재시도 횟수 제한이며, 이는 스펙이 명시한 결함 수정이다
- **신규 런타임 의존성은 `dio` 하나만 추가한다.** 테스트용 패키지는 추가하지 않는다 — 손으로 쓴 Fake를 쓴다 (`lib/data/data_source/api/diary/mock_diary_api.dart`가 기존 선례다)
- **제거 대상 의존성:** `http`(Task 8), `flutter_dotenv`(Task 2, 미사용), `mockito`(Task 2, 미사용)
- 상태관리 교체(Riverpod/bloc), 화면 구조 변경, sqflite 스키마 변경은 이 계획의 범위가 아니다
- 각 태스크는 다음을 만족해야 끝난다: `flutter test` 통과, 그리고 `flutter analyze`가 **베이스라인 대비 새 이슈 0건**
  - `flutter test` 통과 요건은 **Task 2부터** 적용된다. 시작 시점에 `test/widget_test.dart`가 이미 실패하고 있으며(존재하지 않는 카운터 UI 검증), Task 2가 이 파일을 삭제한다. Task 1은 문서만 만들므로 이 실패를 고칠 수 없다
  - 베이스라인은 `858cd3f` 기준 6건이다 — `di.dart`의 미사용 mock import 2건(주석 처리된 mock 토글을 살려두기 위해 의도적으로 남음), `app_logger.dart`의 `avoid_print` 3건과 `mock_diary_api.dart` 1건(AppLogger가 print를 감싸는 것이 설계 의도)
  - 이 6건은 이 계획의 범위 밖이다. 건드리지 않는다
- 커밋 메시지는 한국어. 기존 컨벤션을 따른다 — `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- 테스트 파일은 `test/` 아래에 `lib/`의 디렉터리 구조를 그대로 반영해 배치한다
- 공용 Fake는 `test/fakes/` 아래 한 파일에 하나씩 둔다

## File Structure

**생성**

| 경로 | 책임 |
| --- | --- |
| `CLAUDE.md` | 이 앱에만 해당하는 맥락. 스킬과 겹치는 내용은 참조만 |
| `test/fakes/fake_token_repository.dart` | `TokenRepository` 인메모리 구현 |
| `test/fakes/fake_diary_api.dart` | `DiaryApi` 인메모리 구현. 호출 기록 |
| `test/fakes/fake_diary_dao.dart` | `DiaryDao` 대역. 호출 기록 |
| `test/fakes/fake_diary_repository.dart` | `DiaryRepository` 인메모리 구현 |
| `test/data/data_source/api/base_api_test.dart` | 헤더 구성, 응답 헤더에서 토큰 저장 |
| `test/data/repository/diary_repository_impl_test.dart` | DAO 위임과 DTO→도메인 매핑 |
| `test/presentation/diary_list/diary_list_view_model_test.dart` | 정렬 전환 상태 전이 |
| `test/data/data_source/api/auth_interceptor_test.dart` | 헤더 주입, 토큰 저장, 401 재시도 1회 제한 |
| `test/architecture_test.dart` | 레이어 의존 규칙을 실행 가능하게 강제 |
| `lib/utils/crash_reporter.dart` | 크래시 보고 추상화. 테스트에서 무력화 가능 |
| `lib/data/data_source/api/auth_interceptor.dart` | 헤더 주입 + 토큰 저장 + 401 재발급/재시도 |
| `lib/data/data_source/api/dio_client.dart` | dio 인스턴스 구성 |
| `lib/domain/model/local_image.dart` | 첨부 이미지의 도메인 표현 |
| `lib/domain/enum/app_permission.dart` | 권한의 도메인 표현 |

**수정**

| 경로 | 변경 내용 |
| --- | --- |
| `pubspec.yaml` | dio 추가, http/flutter_dotenv/mockito 제거 |
| `lib/data/data_source/api/base_api.dart` | 인터셉터로 이관 후 축소 또는 삭제 |
| `lib/data/data_source/api/api_exception.dart` | 크래시 보고를 `CrashReporter`로 위임 |
| `lib/data/data_source/api/diary/diary_api_impl.dart` | dio 전환 |
| `lib/data/data_source/api/user/user_api_impl.dart` | dio 전환 |
| `lib/data/repository/user_repository_impl.dart` | presentation 의존 제거 |
| `lib/presentation/splash/splash_view_model.dart` | `DiaryDao` 의존 제거 |
| `lib/domain/repository/diary_repository.dart` | `XFile` → `LocalImage` |
| `lib/domain/service/permission_handler_service.dart` | `Permission` → `AppPermission` |
| `lib/config/di.dart` | dio 등록, 의존성 변경 반영, ViewModel 리셋 함수 추가 |

**삭제**

- `test/widget_test.dart` — 존재하지 않는 카운터 UI를 검증하는 스캐폴드. 현재 `+0 -1`로 실패한다

---

### Task 1: CLAUDE.md 작성

**Files:**
- Create: `CLAUDE.md`

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (문서). 이후 모든 태스크의 실행자가 이 문서를 먼저 읽는다

- [ ] **Step 1: CLAUDE.md 작성**

프로젝트 루트에 아래 내용으로 생성한다. 스킬과 겹치는 서술은 넣지 않는다 — 같은 내용이 두 곳에 있으면 갈라진다.

```markdown
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
```

- [ ] **Step 2: 정적 분석 확인**

Run: `flutter analyze`
Expected: 무경고 (문서만 추가했으므로 변화 없음)

- [ ] **Step 3: 커밋**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md 추가

레이어 규칙, 화면 추가 절차, 명령어, 함정, 릴리즈 플로우를 정리.
코딩 패턴은 ~/.claude/skills의 flutter-* 스킬을 참조하도록 하고 중복 서술하지 않음."
```

---

### Task 2: 테스트 기반 마련 + BaseApi 토큰 흐름 테스트

깨진 스캐폴드 테스트를 걷어내고, 미사용 의존성을 정리하고, **Task 6에서 인터셉터로 옮길 동작을 먼저 테스트로 고정한다.** 이 테스트가 이후 네트워크 전환의 안전망이다.

**Files:**
- Delete: `test/widget_test.dart`
- Create: `test/fakes/fake_token_repository.dart`
- Create: `test/data/data_source/api/base_api_test.dart`
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: `TokenRepository` (`lib/domain/repository/token_repository.dart`), `BaseApi` (`lib/data/data_source/api/base_api.dart`)
- Produces: `FakeTokenRepository` — 이후 Task 6이 그대로 재사용한다. 공개 필드 `accessToken`, `refreshToken`, `fcmToken` (모두 `String?`)과 카운터 `saveJwtTokensCallCount` (`int`)를 노출한다

- [ ] **Step 1: 깨진 스캐폴드 테스트 삭제**

```bash
rm test/widget_test.dart
```

`MyApp`을 pump하려면 Firebase 초기화와 DI 구성이 필요하다. 이 파일은 존재하지 않는 카운터 UI를 검증하므로 고칠 가치가 없다. 위젯 테스트는 이 계획의 범위가 아니다.

- [ ] **Step 2: 미사용 의존성 제거**

`pubspec.yaml`에서 `flutter_dotenv`(dependencies)와 `mockito`(dev_dependencies) 두 줄을 삭제한다. 둘 다 `lib/`와 `test/` 어디에서도 쓰이지 않는다.

Run: `grep -rn "dotenv\|mockito" lib test`
Expected: 출력 없음

그다음:

```bash
flutter pub get
```

- [ ] **Step 3: FakeTokenRepository 작성**

`test/fakes/fake_token_repository.dart`:

```dart
import 'package:cake/domain/repository/token_repository.dart';

class FakeTokenRepository implements TokenRepository {
  String? accessToken;
  String? refreshToken;
  String? fcmToken;

  int saveJwtTokensCallCount = 0;

  @override
  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    saveJwtTokensCallCount++;
  }

  @override
  Future<void> saveFcmToken(String token) async => fcmToken = token;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getFcmToken() async => fcmToken;

  @override
  Future<bool> hasJwtTokens() async =>
      accessToken != null && refreshToken != null;

  @override
  Future<bool> hasFcmToken() async => fcmToken != null;

  @override
  Future<void> clearJwtTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<void> clearFcmToken() async => fcmToken = null;

  @override
  Future<void> clearAllSecureData() async {
    accessToken = null;
    refreshToken = null;
    fcmToken = null;
  }
}
```

- [ ] **Step 4: 실패하는 테스트 작성**

`test/data/data_source/api/base_api_test.dart`:

```dart
import 'package:cake/data/data_source/api/base_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_token_repository.dart';

// BaseApi는 abstract이므로 테스트용 최소 구현으로 감싼다.
class _TestApi extends BaseApi {
  _TestApi(super._tokenRepository);
}

void main() {
  late FakeTokenRepository tokenRepository;
  late _TestApi api;

  setUp(() {
    tokenRepository = FakeTokenRepository();
    api = _TestApi(tokenRepository);
  });

  group('getHeaders', () {
    test('토큰이 모두 있으면 Authorization과 Refresh-Token을 붙인다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';

      final headers = await api.getHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer access-1');
      expect(headers['Refresh-Token'], 'refresh-1');
    });

    test('needsAuth가 false면 인증 헤더를 붙이지 않는다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = 'refresh-1';

      final headers = await api.getHeaders(needsAuth: false);

      expect(headers.containsKey('Authorization'), isFalse);
      expect(headers.containsKey('Refresh-Token'), isFalse);
    });

    test('토큰이 하나라도 없으면 인증 헤더를 붙이지 않는다', () async {
      tokenRepository.accessToken = 'access-1';
      tokenRepository.refreshToken = null;

      final headers = await api.getHeaders();

      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('saveAllTokensFromHeader', () {
    test('Bearer 접두사를 떼고 두 토큰을 저장한다', () async {
      await api.saveAllTokensFromHeader({
        'authorization': 'Bearer new-access',
        'refresh-token': 'new-refresh',
      });

      expect(tokenRepository.accessToken, 'new-access');
      expect(tokenRepository.refreshToken, 'new-refresh');
      expect(tokenRepository.saveJwtTokensCallCount, 1);
    });

    test('refresh-token이 없으면 아무것도 저장하지 않는다', () async {
      await api.saveAllTokensFromHeader({
        'authorization': 'Bearer new-access',
      });

      expect(tokenRepository.saveJwtTokensCallCount, 0);
      expect(tokenRepository.accessToken, isNull);
    });
  });
}
```

- [ ] **Step 5: 테스트 실행**

Run: `flutter test test/data/data_source/api/base_api_test.dart`
Expected: PASS (5개). 이 테스트는 기존 동작을 기록하는 특성화 테스트이므로 구현 변경 없이 통과해야 한다. 실패한다면 `BaseApi`의 실제 동작이 기대와 다르다는 뜻이므로, 테스트를 실제 동작에 맞춰 고치고 그 차이를 커밋 메시지에 남긴다.

- [ ] **Step 6: 전체 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "test: BaseApi 토큰 흐름 특성화 테스트 추가

깨진 widget_test 스캐폴드 삭제. 미사용 의존성 flutter_dotenv, mockito 제거.
헤더 구성과 응답 헤더 토큰 저장 동작을 고정해 dio 전환의 안전망을 만듦."
```

---

### Task 3: DiaryRepositoryImpl 규칙 테스트

리포지토리에서 **실제 로직이 있는 곳만** 덮는다. DAO로 그대로 넘기기만 하는 메서드는 테스트 가치가 없으므로 제외한다.

**Files:**
- Create: `test/fakes/fake_diary_api.dart`
- Create: `test/fakes/fake_diary_dao.dart`
- Create: `test/data/repository/diary_repository_impl_test.dart`

**Interfaces:**
- Consumes: `DiaryApi`, `DiaryDao`, `DiaryRepositoryImpl`, `ServiceConfig.maxDiaryCount`(= 3)
- Produces: `FakeDiaryApi` — 필드 `List<String> questions`, `List<int> deletedDiaryIds`, `int deleteDiaryCallCount`. `FakeDiaryDao` — 필드 `int todayDiaryCount`, `List<int> deletedDiaryIds`, `int deleteAllDiariesCallCount`

- [ ] **Step 1: FakeDiaryApi 작성**

`test/fakes/fake_diary_api.dart`. 이 태스크가 쓰지 않는 메서드는 `UnimplementedError`를 던진다 — 테스트가 의도치 않은 경로를 타면 즉시 드러난다.

```dart
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:image_picker/image_picker.dart';

class FakeDiaryApi implements DiaryApi {
  List<String> questions = [];
  List<int> deletedDiaryIds = [];

  @override
  Future<List<String>> fetchQuestions() async => questions;

  @override
  Future<void> deleteDiary({required int id}) async {
    deletedDiaryIds.add(id);
  }

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  }) => throw UnimplementedError();

  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) =>
      throw UnimplementedError();

  @override
  Future<String> requestQnaDiary({required List<QnaRequestDto> qnaListDto}) =>
      throw UnimplementedError();

  @override
  Future<void> updateDiaryText({required int id, required String text}) =>
      throw UnimplementedError();
}
```

> Task 11에서 `DiaryApi`의 `XFile`이 `LocalImage`로 바뀐다. 그때 이 파일의 import와 두 메서드 시그니처를 함께 고친다.

- [ ] **Step 2: FakeDiaryDao 작성**

`test/fakes/fake_diary_dao.dart`. `DiaryDao`는 구체 클래스지만 Dart의 암묵적 인터페이스를 통해 `implements`할 수 있다. 비공개 필드는 구현할 필요가 없다.

```dart
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/model/diary.dart';

class FakeDiaryDao implements DiaryDao {
  int todayDiaryCount = 0;
  List<Diary> diaries = [];
  List<Diary> insertedDiaries = [];
  List<int> deletedDiaryIds = [];
  int deleteAllDiariesCallCount = 0;

  @override
  Future<int> getTodayDiaryCount() async => todayDiaryCount;

  @override
  Future<List<Diary>> getAllDiariesLatest() async => diaries;

  @override
  Future<List<Diary>> getAllDiariesOldest() async => diaries.reversed.toList();

  @override
  Future<List<Diary>> getCurrentMonthDiaries() async => diaries;

  @override
  Future<List<Diary>> getDiariesByMonth(int year, int month) async => diaries;

  @override
  Future<void> insertDiary(Diary diary) async => insertedDiaries.add(diary);

  @override
  Future<void> deleteDiary(int id) async => deletedDiaryIds.add(id);

  @override
  Future<int> deleteAllDiaries() async {
    deleteAllDiariesCallCount++;
    return 0;
  }

  @override
  Future<int> deleteAllSoftDeletedDiaries() async => 0;
}
```

- [ ] **Step 3: 실패하는 테스트 작성**

`test/data/repository/diary_repository_impl_test.dart`:

```dart
import 'package:cake/config/service_config.dart';
import 'package:cake/data/repository/diary_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_api.dart';
import '../../fakes/fake_diary_dao.dart';

void main() {
  late FakeDiaryApi api;
  late FakeDiaryDao dao;
  late DiaryRepositoryImpl repository;

  setUp(() {
    api = FakeDiaryApi();
    dao = FakeDiaryDao();
    repository = DiaryRepositoryImpl(diaryDao: dao, diaryApi: api);
  });

  group('isAbleToWriteDiaryToday', () {
    test('오늘 작성 수가 상한 미만이면 true', () async {
      dao.todayDiaryCount = ServiceConfig.maxDiaryCount - 1;

      expect(await repository.isAbleToWriteDiaryToday(), isTrue);
    });

    test('오늘 작성 수가 상한에 도달하면 false', () async {
      dao.todayDiaryCount = ServiceConfig.maxDiaryCount;

      expect(await repository.isAbleToWriteDiaryToday(), isFalse);
    });
  });

  group('getQuestionList', () {
    test('질문 문자열에 1부터 시작하는 id를 붙이고 answer를 비운다', () async {
      api.questions = ['오늘 무엇을 했나요', '기분은 어땠나요'];

      final result = await repository.getQuestionList();

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].question, '오늘 무엇을 했나요');
      expect(result[0].answer, '');
      expect(result[1].id, 2);
    });

    test('질문이 없으면 빈 목록을 반환한다', () async {
      api.questions = [];

      expect(await repository.getQuestionList(), isEmpty);
    });
  });

  group('removeDiary', () {
    test('로컬 DB와 서버 양쪽에서 삭제한다', () async {
      await repository.removeDiary(42);

      expect(dao.deletedDiaryIds, [42]);
      expect(api.deletedDiaryIds, [42]);
    });
  });
}
```

- [ ] **Step 4: 테스트 실행**

Run: `flutter test test/data/repository/diary_repository_impl_test.dart`
Expected: PASS (5개). 특성화 테스트이므로 구현 변경 없이 통과한다.

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "test: DiaryRepositoryImpl 규칙 테스트 추가

작성 가능 여부 판단, 질문 id 부여, 삭제 시 로컬/서버 동시 처리를 고정."
```

---

### Task 4: DiaryListViewModel 상태 전이 테스트

ViewModel 계층의 대표 사례 하나를 덮어, 이후 화면 ViewModel 테스트를 쓸 때 따라할 본보기를 만든다.

**Files:**
- Create: `test/fakes/fake_diary_repository.dart`
- Create: `test/presentation/diary_list/diary_list_view_model_test.dart`

**Interfaces:**
- Consumes: `DiaryRepository`, `DiaryListViewModel`, `SortType`
- Produces: `FakeDiaryRepository` — 필드 `List<Diary> latestDiaries`, `List<Diary> oldestDiaries`, `int getLatestCallCount`, `int getOldestCallCount`

- [ ] **Step 1: FakeDiaryRepository 작성**

`test/fakes/fake_diary_repository.dart`:

```dart
import 'package:cake/domain/enum/diary_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/domain/model/qna.dart';
import 'package:cake/domain/repository/diary_repository.dart';
import 'package:image_picker/image_picker.dart';

class FakeDiaryRepository implements DiaryRepository {
  List<Diary> latestDiaries = [];
  List<Diary> oldestDiaries = [];

  int getLatestCallCount = 0;
  int getOldestCallCount = 0;

  @override
  Future<List<Diary>> getLatestDiaryList() async {
    getLatestCallCount++;
    return latestDiaries;
  }

  @override
  Future<List<Diary>> getOldestDiaryList() async {
    getOldestCallCount++;
    return oldestDiaries;
  }

  @override
  Future<List<Diary>> getCurrentMonthlyDiaryList() async => latestDiaries;

  @override
  Future<List<Diary>> getMonthlyDiaryList({
    required int year,
    required int month,
  }) async => latestDiaries;

  @override
  Future<bool> isAbleToWriteDiaryToday() async => true;

  @override
  Future<DiaryDetail> getDiary({required int id}) =>
      throw UnimplementedError();

  @override
  Future<List<Qna>> getQuestionList() => throw UnimplementedError();

  @override
  Future<String> generateQnaDiary({required List<Qna> qnaList}) =>
      throw UnimplementedError();

  @override
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<XFile> images,
  }) => throw UnimplementedError();

  @override
  Future<void> editDiaryText({required int id, required String editText}) =>
      throw UnimplementedError();

  @override
  Future<void> removeDiary(int id) => throw UnimplementedError();
}
```

> Task 11에서 `DiaryRepository.saveDiary`의 `XFile`이 `LocalImage`로 바뀐다. 그때 이 파일도 함께 고친다.

- [ ] **Step 2: 실패하는 테스트 작성**

`test/presentation/diary_list/diary_list_view_model_test.dart`. `DiaryListViewModel`은 생성자에서 비동기 로드를 시작하므로, 각 테스트는 `await Future.delayed(Duration.zero)`로 최초 로드가 끝나기를 기다린다. 로드 체인이 여러 await 지점을 거치므로 마이크로태스크 하나를 기다리는 것으로는 부족하다 — 이벤트 루프 한 턴은 대기 중인 마이크로태스크를 모두 소진한다.

```dart
import 'package:cake/domain/enum/sort_type.dart';
import 'package:cake/domain/model/diary.dart';
import 'package:cake/presentation/diary_list/diary_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_diary_repository.dart';

Diary buildDiary({required int id, required String summary}) => Diary(
  id: id,
  summary: summary,
  createdAt: DateTime(2026, 1, id),
  firstColorHex: '#FFFFFF',
  secondColorHex: '#000000',
  musicTitle: '노래',
  musicArtist: '가수',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDiaryRepository repository;

  setUp(() {
    repository = FakeDiaryRepository()
      ..latestDiaries = [
        buildDiary(id: 2, summary: '나중 일기'),
        buildDiary(id: 1, summary: '먼저 일기'),
      ]
      ..oldestDiaries = [
        buildDiary(id: 1, summary: '먼저 일기'),
        buildDiary(id: 2, summary: '나중 일기'),
      ];
  });

  test('생성 시 최신순으로 목록을 불러온다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    addTearDown(viewModel.dispose);
    await Future.delayed(Duration.zero);

    expect(viewModel.sortType, SortType.latest);
    expect(viewModel.diaryList.map((d) => d.id), [2, 1]);
    expect(repository.getLatestCallCount, 1);
  });

  test('정렬을 바꾸면 해당 순서로 다시 불러오고 리스너에 알린다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    addTearDown(viewModel.dispose);
    await Future.delayed(Duration.zero);

    var notifyCount = 0;
    viewModel.addListener(() => notifyCount++);

    await viewModel.setSortType(SortType.oldest);

    expect(viewModel.sortType, SortType.oldest);
    expect(viewModel.diaryList.map((d) => d.id), [1, 2]);
    expect(repository.getOldestCallCount, 1);
    expect(notifyCount, 1);

    // 전제를 명시한다. animateTo는 notifyListeners를 부르지 않으므로
    // notifyCount로는 애니메이션 분기를 탔는지 구분할 수 없다.
    expect(viewModel.scrollController.hasClients, isFalse);
  });

  test('같은 정렬을 다시 선택하면 재조회하지 않는다', () async {
    final viewModel = DiaryListViewModel(diaryRepo: repository);
    addTearDown(viewModel.dispose);
    await Future.delayed(Duration.zero);

    await viewModel.setSortType(SortType.latest);

    expect(repository.getLatestCallCount, 1);
    expect(repository.getOldestCallCount, 0);
  });
}
```

- [ ] **Step 3: 테스트 실행**

Run: `flutter test test/presentation/diary_list/diary_list_view_model_test.dart`
Expected: PASS (3개)

`ScrollController`가 위젯 트리에 붙지 않아 `hasClients`가 false이므로 애니메이션 경로는 타지 않는다. 이 전제는 두 번째 테스트가 `expect(viewModel.scrollController.hasClients, isFalse)`로 직접 확인한다 — **`notifyCount`로는 확인할 수 없다.** `animateTo`는 `ScrollController` API라 `notifyListeners`를 부르지 않으므로, 분기를 타든 안 타든 `notifyCount`는 1이다. 이 테스트는 이후 ViewModel 테스트의 본보기가 되므로 전제를 추론에 맡기지 않고 명시한다.

`TestWidgetsFlutterBinding.ensureInitialized()`가 필요한 이유는 `ScrollController` 생성이 바인딩을 요구하기 때문이다. 각 테스트는 `addTearDown(viewModel.dispose)`로 `ScrollController`를 정리한다.

- [ ] **Step 4: 전체 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "test: DiaryListViewModel 상태 전이 테스트 추가

최초 로드, 정렬 전환, 동일 정렬 재선택 시 무동작을 고정.
이후 ViewModel 테스트의 본보기."
```

---

### Task 5: CrashReporter 도입

`ApiException` 생성자가 `FirebaseCrashlytics.instance`를 직접 호출한다. Firebase를 초기화하지 않는 단위 테스트에서 예외 경로를 검증할 수 없다. **Task 6의 인터셉터 테스트가 이 seam을 필요로 한다.**

**Files:**
- Create: `lib/utils/crash_reporter.dart`
- Modify: `lib/data/data_source/api/api_exception.dart`
- Create: `test/data/data_source/api/api_exception_test.dart`

**Interfaces:**
- Produces: `CrashReporter` 인터페이스 (`void recordError(Object error, StackTrace stack, {required String reason})`), 구현체 `FirebaseCrashReporter`, `NoopCrashReporter`. `ApiException.reporter` 정적 필드 (기본값 `FirebaseCrashReporter()`)로 테스트에서 교체한다

- [ ] **Step 1: CrashReporter 작성**

`lib/utils/crash_reporter.dart`:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

abstract interface class CrashReporter {
  void recordError(Object error, StackTrace stack, {required String reason});
}

class FirebaseCrashReporter implements CrashReporter {
  const FirebaseCrashReporter();

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: false,
      reason: reason,
    );
  }
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {}
}
```

- [ ] **Step 2: 실패하는 테스트 작성**

`test/data/data_source/api/api_exception_test.dart`:

```dart
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCrashReporter implements CrashReporter {
  final List<String> reasons = [];

  @override
  void recordError(Object error, StackTrace stack, {required String reason}) {
    reasons.add(reason);
  }
}

void main() {
  late _RecordingCrashReporter reporter;

  setUp(() {
    reporter = _RecordingCrashReporter();
    ApiException.reporter = reporter;
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('생성 시 상태코드와 엔드포인트를 담아 크래시 보고를 남긴다', () {
    ApiException(
      statusCode: 500,
      endpoint: 'createUser',
      responseBody: 'server error',
    );

    expect(reporter.reasons, ['[500] createUser']);
  });

  test('Firebase 초기화 없이 생성해도 예외가 나지 않는다', () {
    ApiException.reporter = const NoopCrashReporter();

    expect(
      () => ApiException(
        statusCode: 401,
        endpoint: 'deleteUser',
        responseBody: '',
      ),
      returnsNormally,
    );
  });
}
```

- [ ] **Step 3: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_source/api/api_exception_test.dart`
Expected: FAIL — `ApiException.reporter`가 정의되어 있지 않아 컴파일 에러

- [ ] **Step 4: ApiException 수정**

`lib/data/data_source/api/api_exception.dart`의 생성자에서 `FirebaseCrashlytics` 직접 호출을 걷어내고 `reporter`에 위임한다. `firebase_crashlytics` import는 제거한다.

```dart
import 'package:cake/utils/app_logger.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  /// 테스트에서 NoopCrashReporter로 교체한다.
  static CrashReporter reporter = const FirebaseCrashReporter();

  final int statusCode;
  final String endpoint;
  final String responseBody;

  ApiException({
    required this.statusCode,
    required this.endpoint,
    required this.responseBody,
  }) {
    AppLogger.error('API 에러 [$endpoint]: $statusCode');
    AppLogger.log('Response Body: $responseBody');
    reporter.recordError(
      this,
      StackTrace.current,
      reason: '[$statusCode] $endpoint',
    );
  }

  factory ApiException.fromResponse(http.Response response, String endpoint) {
    return ApiException(
      statusCode: response.statusCode,
      endpoint: endpoint,
      responseBody: response.body,
    );
  }

  static Future<ApiException> fromStreamedResponse(
    http.StreamedResponse streamedResponse,
    String endpoint,
  ) async {
    final response = await http.Response.fromStream(streamedResponse);
    return ApiException.fromResponse(response, endpoint);
  }
}
```

`http` import와 두 팩토리는 Task 8에서 제거한다. 지금은 기존 호출부가 살아 있어야 한다.

- [ ] **Step 5: 테스트 실행하여 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: ApiException의 크래시 보고를 CrashReporter로 분리

생성자가 FirebaseCrashlytics를 직접 호출해 단위 테스트에서 예외 경로를
검증할 수 없었음. 테스트는 NoopCrashReporter를 주입한다."
```

---

### Task 6: AuthInterceptor 구현 (TDD)

이 계획의 핵심이다. 8개 API 메서드에 흩어진 헤더 구성 / 토큰 저장 / 401 재발급을 인터셉터 하나로 모으고, **재시도를 1회로 제한해 무한 재귀를 끊는다.**

**설계 요지 — 재귀가 불가능한 구조로 만든다.** Dio 인스턴스를 셋으로 나눈다.

| 인스턴스 | 인터셉터 | 역할 |
| --- | --- | --- |
| `dio` | 헤더 주입 + 토큰 저장 + **401 처리** | 앱이 쓰는 기본 클라이언트 |
| `retryDio` | 헤더 주입 + 토큰 저장 | 401 후 재시도 전용. 401을 처리하지 않으므로 재시도가 다시 재시도를 부를 수 없다 |
| `reissueDio` | 없음 | 토큰 재발급 요청 전용. 재발급이 401 처리를 다시 타지 않는다 |

재시도 경로가 401 처리를 갖지 않으므로 **재귀가 구조적으로 불가능하다.** 횟수 세기에 의존하지 않는다.

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/data/data_source/api/auth_interceptor.dart`
- Create: `lib/data/data_source/api/dio_client.dart`
- Create: `test/data/data_source/api/auth_interceptor_test.dart`

**Interfaces:**
- Consumes: `TokenRepository`, `ApiConfig.baseUrl`, `ApiException`, `CrashReporter`(Task 5), `FakeTokenRepository`(Task 2)
- Produces:
  - `AuthInterceptor({required TokenRepository tokenRepository, required bool handleUnauthorized, Dio? retryDio, Dio? reissueDio})`
  - `Dio buildDio(TokenRepository tokenRepository)` — Task 7, 8이 이 함수로 만든 인스턴스를 주입받는다
  - 인증이 필요 없는 요청은 `Options(extra: {'needsAuth': false})`로 표시한다

- [ ] **Step 1: dio 추가**

```bash
flutter pub add dio
```

해석된 버전을 그대로 쓴다. `http`는 아직 제거하지 않는다 — Task 8까지 기존 구현이 살아 있어야 한다.

- [ ] **Step 2: 실패하는 테스트 작성**

`test/data/data_source/api/auth_interceptor_test.dart`:

```dart
import 'dart:typed_data';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/utils/crash_reporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_token_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  late ResponseBody Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, {Map<String, List<String>>? headers}) {
  return ResponseBody.fromString(
    '{}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    },
  );
}

void main() {
  late FakeTokenRepository tokenRepository;
  late _FakeAdapter adapter;
  late Dio dio;

  setUp(() {
    ApiException.reporter = const NoopCrashReporter();

    tokenRepository = FakeTokenRepository();
    adapter = _FakeAdapter();

    BaseOptions options() => BaseOptions(baseUrl: 'https://example.test');

    final reissueDio = Dio(options())..httpClientAdapter = adapter;
    final retryDio = Dio(options())
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenRepository: tokenRepository,
          handleUnauthorized: false,
        ),
      );

    dio = Dio(options())
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenRepository: tokenRepository,
          handleUnauthorized: true,
          retryDio: retryDio,
          reissueDio: reissueDio,
        ),
      );
  });

  tearDown(() {
    ApiException.reporter = const NoopCrashReporter();
  });

  test('토큰이 있으면 인증 헤더를 붙인다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = 'refresh-1';
    adapter.responder = (_) => _json(200);

    await dio.get('/diaries');

    final sent = adapter.requests.single;
    expect(sent.headers['Authorization'], 'Bearer access-1');
    expect(sent.headers['Refresh-Token'], 'refresh-1');
  });

  test('needsAuth가 false면 인증 헤더를 붙이지 않는다', () async {
    tokenRepository.accessToken = 'access-1';
    tokenRepository.refreshToken = 'refresh-1';
    adapter.responder = (_) => _json(200);

    await dio.post(
      '/users',
      options: Options(extra: {AuthInterceptor.needsAuthKey: false}),
    );

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('응답 헤더에 토큰이 오면 Bearer를 떼고 저장한다', () async {
    adapter.responder = (_) => _json(
      200,
      headers: {
        'authorization': ['Bearer new-access'],
        'refresh-token': ['new-refresh'],
      },
    );

    await dio.get('/diaries');

    expect(tokenRepository.accessToken, 'new-access');
    expect(tokenRepository.refreshToken, 'new-refresh');
  });

  test('401이면 재발급 후 한 번 재시도하고 성공 응답을 반환한다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString(
          '',
          204,
          headers: {
            'authorization': ['Bearer reissued'],
            'refresh-token': ['reissued-refresh'],
          },
        );
      }
      diariesCalls++;
      return _json(diariesCalls == 1 ? 401 : 200);
    };

    final response = await dio.get('/diaries');

    expect(response.statusCode, 200);
    expect(diariesCalls, 2);
    expect(tokenRepository.accessToken, 'reissued');
  });

  test('재시도한 요청도 401이면 더 재시도하지 않고 예외를 던진다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString(
          '',
          204,
          headers: {
            'authorization': ['Bearer reissued'],
            'refresh-token': ['reissued-refresh'],
          },
        );
      }
      diariesCalls++;
      return _json(401);
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    // 원요청 1 + 재시도 1. 무한 재귀가 없다는 것이 이 테스트의 요점이다.
    expect(diariesCalls, 2);
  });

  test('재발급 자체가 실패하면 재시도하지 않는다', () async {
    tokenRepository.fcmToken = 'device-1';
    var diariesCalls = 0;

    adapter.responder = (options) {
      if (options.path.contains('/auth/login')) {
        return ResponseBody.fromString('', 500);
      }
      diariesCalls++;
      return _json(401);
    };

    await expectLater(dio.get('/diaries'), throwsA(isA<DioException>()));

    expect(diariesCalls, 1);
  });
}
```

- [ ] **Step 3: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_source/api/auth_interceptor_test.dart`
Expected: FAIL — `auth_interceptor.dart`가 없어 컴파일 에러

- [ ] **Step 4: AuthInterceptor 구현**

`lib/data/data_source/api/auth_interceptor.dart`:

```dart
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// 인증이 필요 없는 요청은 Options(extra: {AuthInterceptor.needsAuthKey: false})로 표시한다.
class AuthInterceptor extends Interceptor {
  static const String needsAuthKey = 'needsAuth';

  final TokenRepository _tokenRepository;

  /// true인 인스턴스만 401을 처리한다.
  /// 재시도용 / 재발급용 Dio는 false여야 재귀가 생기지 않는다.
  final bool _handleUnauthorized;

  final Dio? _retryDio;
  final Dio? _reissueDio;

  AuthInterceptor({
    required TokenRepository tokenRepository,
    required bool handleUnauthorized,
    Dio? retryDio,
    Dio? reissueDio,
  }) : _tokenRepository = tokenRepository,
       _handleUnauthorized = handleUnauthorized,
       _retryDio = retryDio,
       _reissueDio = reissueDio,
       assert(
         !handleUnauthorized || (retryDio != null && reissueDio != null),
         '401을 처리하려면 retryDio와 reissueDio가 필요하다',
       );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[needsAuthKey] != false) {
      final accessToken = await _tokenRepository.getAccessToken();
      final refreshToken = await _tokenRepository.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        options.headers['Refresh-Token'] = refreshToken;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _saveTokensFromHeaders(response.headers);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_handleUnauthorized || err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      await _reissueTokens();
    } catch (e) {
      AppLogger.error('토큰 재발급 실패: $e');
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions;

      // 멀티파트 본문은 이미 소비되었으므로 복제해야 재전송할 수 있다.
      final data = options.data;
      if (data is FormData) {
        options.data = data.clone();
      }

      final retried = await _retryDio!.fetch(options);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _saveTokensFromHeaders(Headers headers) async {
    final rawAccessToken = headers.value('authorization');
    final refreshToken = headers.value('refresh-token');

    if (rawAccessToken != null && refreshToken != null) {
      await _tokenRepository.saveJwtTokens(
        accessToken: rawAccessToken.replaceFirst('Bearer ', ''),
        refreshToken: refreshToken,
      );
    }
  }

  Future<void> _reissueTokens() async {
    AppLogger.log('토큰 만료. 재발급 요청');
    final deviceId = await _tokenRepository.getFcmToken();

    final response = await _reissueDio!.post(
      '/auth/login',
      data: {'deviceId': deviceId},
    );

    if (response.statusCode == 204) {
      await _saveTokensFromHeaders(response.headers);
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'reissueTokens',
      responseBody: response.data?.toString() ?? '',
    );
  }
}
```

- [ ] **Step 5: dio_client 작성**

`lib/data/data_source/api/dio_client.dart`:

```dart
import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:dio/dio.dart';

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  headers: {Headers.contentTypeHeader: Headers.jsonContentType},
);

/// 앱이 쓰는 Dio 인스턴스를 만든다.
///
/// 401 처리를 갖지 않는 retryDio / reissueDio를 따로 두어
/// 재시도와 재발급이 다시 401 처리를 타지 않도록 한다.
///
/// [adapter]는 테스트 전용이다. 세 인스턴스 모두에 적용되므로
/// 이 배선 자체를 실제 네트워크 없이 검증할 수 있다.
Dio buildDio(TokenRepository tokenRepository, {HttpClientAdapter? adapter}) {
  Dio create() {
    final dio = Dio(_baseOptions());
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }

  final reissueDio = create();

  final retryDio = create()
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: false,
      ),
    );

  return create()
    ..interceptors.add(
      AuthInterceptor(
        tokenRepository: tokenRepository,
        handleUnauthorized: true,
        retryDio: retryDio,
        reissueDio: reissueDio,
      ),
    );
}

`adapter` 매개변수가 없으면 `buildDio`의 배선은 테스트할 수 없다. 그런데 이 배선의 단 한 줄(`retryDio`의 `handleUnauthorized`)이 `true`가 되는 순간 무한 재귀가 되살아난다 — 이 태스크가 존재하는 이유 그 자체다. 인터셉터만 테스트하고 배선을 테스트하지 않으면, 정확히 그 실수가 여섯 개 테스트를 모두 통과한다.
```

- [ ] **Step 6: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_source/api/auth_interceptor_test.dart`
Expected: PASS (6개)

- [ ] **Step 7: 전체 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 8: 커밋**

```bash
git add -A
git commit -m "feat: AuthInterceptor 추가

헤더 주입, 응답 헤더 토큰 저장, 401 재발급을 인터셉터로 통합.
재시도 전용 Dio가 401을 처리하지 않으므로 재귀가 구조적으로 불가능하다.
기존 구현의 무한 재시도 결함을 해소한다. 아직 API 구현체는 http를 쓴다."
```

---

### Task 7: 비멀티파트 API를 dio로 전환

멀티파트가 아닌 메서드를 먼저 옮긴다. 실패 시 되돌리기 쉽고, 이미지 업로드 경로를 마지막까지 건드리지 않는다.

**Files:**
- Modify: `lib/data/data_source/api/user/user_api_impl.dart`
- Modify: `lib/data/data_source/api/diary/diary_api_impl.dart` (멀티파트 2개 제외)
- Modify: `lib/config/di.dart`

**Interfaces:**
- Consumes: `buildDio(TokenRepository)` (Task 6)
- Produces: `UserApiImpl(Dio dio)`, `DiaryApiImpl(Dio dio)` — 생성자가 `TokenRepository` 대신 `Dio`를 받는다

- [ ] **Step 1: DI에 Dio 등록**

`lib/config/di.dart`에서 `TokenRepository` 등록 직후에 추가한다.

```dart
getIt.registerLazySingleton<Dio>(() => buildDio(getIt<TokenRepository>()));
```

`import 'package:cake/data/data_source/api/dio_client.dart';`와 `import 'package:dio/dio.dart';`를 추가한다.

- [ ] **Step 2: UserApiImpl 전환**

`BaseApi` 상속을 끊고 `Dio`를 주입받는다. 헤더 구성과 401 처리는 인터셉터가 맡으므로 메서드에서 사라진다.

```dart
import 'dart:io';

import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class UserApiImpl implements UserApi {
  final Dio _dio;
  final TokenRepository _tokenRepository;

  UserApiImpl({required Dio dio, required TokenRepository tokenRepository})
    : _dio = dio,
      _tokenRepository = tokenRepository;

  @override
  Future<void> createUser({required String preference}) async {
    final fcmToken = await _tokenRepository.getFcmToken();

    // 회원가입은 아직 토큰이 없으므로 인증 헤더를 붙이지 않는다.
    final response = await _dio.post(
      '/users',
      data: {
        'deviceId': fcmToken,
        'preference': preference,
        'mobileOS': Platform.isAndroid ? 'AND' : 'IOS',
      },
      options: Options(
        extra: {AuthInterceptor.needsAuthKey: false},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 204) {
      AppLogger.log('가입된 deviceId : $fcmToken');
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'createUser',
      responseBody: response.data?.toString() ?? '',
    );
  }

  @override
  Future<void> deleteUser() async {
    final response = await _dio.delete(
      '/users',
      options: Options(
        // 401은 통과시키지 않는다. DioException으로 떨어져야
        // 인터셉터가 재발급 후 재시도할 수 있다.
        validateStatus: (status) => status == 204 || status == 404,
      ),
    );

    if (response.statusCode == 204) {
      await _tokenRepository.clearJwtTokens();
      return;
    }

    if (response.statusCode == 404) {
      AppLogger.log('deleteUser 404 이미 삭제된 유저.');
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'deleteUser',
      responseBody: response.data?.toString() ?? '',
    );
  }
}
```

> **`validateStatus`에 401을 넣지 않는다.** 통과시키면 인터셉터의 `onError`가 타지 않아 재발급이 일어나지 않는다. 정상 처리로 취급할 상태코드만 나열하고, 나머지는 `DioException`으로 떨어뜨려 인터셉터에 맡긴다. `createUser`의 `status < 500`도 같은 이유로 주의가 필요하지만, 회원가입은 토큰이 없는 요청이라 401 재발급 대상이 아니다.

- [ ] **Step 3: DiaryApiImpl의 비멀티파트 메서드 전환**

`fetchDiary`, `fetchQuestions`, `requestQnaDiary`, `updateDiaryText`, `deleteDiary` 다섯 개를 옮긴다. 각 메서드는 다음 형태가 된다 — 헤더 구성도, 401 분기도, 토큰 저장도 없다.

```dart
  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) async {
    final response = await _dio.get('/diaries/$id');
    return DiaryDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDiary({required int id}) async {
    await _dio.delete('/diaries/$id');
  }

  @override
  Future<void> updateDiaryText({
    required int id,
    required String text,
  }) async {
    await _dio.patch('/diaries/$id', data: {'text': text});
  }
```

`fetchQuestions`와 `requestQnaDiary`는 기존 구현의 응답 파싱 로직(`jsonDecode` 이후 부분)을 그대로 옮긴다. dio가 JSON을 이미 파싱해 `response.data`로 주므로 `jsonDecode`와 `utf8.decode` 호출은 제거한다.

비2xx는 dio가 `DioException`으로 던지므로, 단순히 예외를 던지던 메서드에는 개별 분기가 필요 없다.

**단 `fetchQuestions`는 예외다.** 기존 구현은 비200 응답에서 예외를 던지지 않고 기본 질문 5개를 반환한다 — 서버가 죽어도 사용자가 문답일기를 계속 쓸 수 있게 한 의도적인 처리이며 코드에 주석으로 남아 있다. 이 동작을 유지해야 한다. dio 전환 후에는 `DioException`을 잡아 같은 기본 목록을 반환한다.

```dart
  @override
  Future<List<String>> fetchQuestions() async {
    try {
      final response = await _dio.get('/diaries/question');
      return List<String>.from(response.data['questions']);
    } on DioException catch (e) {
      // 응답을 받은 실패에만 fallback을 적용한다.
      // 네트워크 단절/타임아웃은 기존처럼 예외로 올려보낸다 — 오프라인 사용자에게
      // 기본 질문을 주면 답을 다 쓴 뒤 generateQnaDiary에서 실패한다.
      if (e.response == null) rethrow;

      // 서버 에러를 사용자에게 보여주기보다 기본 질문으로 대체한다.
      AppLogger.error('fetchQuestions 서버 에러. statusCode : ${e.response?.statusCode}');
      return [
        "지금 기분이 어때?",
        "오늘 특별한 일이나 기록하고 싶은 일이 있었어? ",
        "요즘 너의 최대 관심사는뭐야?",
        "오늘 가장 후회되는 지출이 있어? 꼭 오늘이 아니어도 괜찮아",
        "오늘의 너에게 해주고 싶은 말이 있다면?",
      ];
    }
  }
```

인터셉터가 401 재발급과 1회 재시도를 이미 시도한 뒤에야 `DioException`이 여기까지 오므로, 이 fallback은 진짜 실패에만 걸린다. 기존의 무한 재귀와 달리 지속적인 401도 기본 질문으로 떨어진다.

`createQnaDiary`와 `createFreeDiary` 두 메서드는 **이 태스크에서 건드리지 않는다.** 아직 `BaseApi`를 통해 `http`를 쓰도록 남겨둔다. 그러려면 이 태스크 동안 `DiaryApiImpl`이 `BaseApi`를 계속 상속하면서 `Dio`도 함께 받는 과도기 형태가 된다. 생성자는 다음과 같다.

```dart
class DiaryApiImpl extends BaseApi implements DiaryApi {
  final Dio _dio;

  DiaryApiImpl({required Dio dio, required TokenRepository tokenRepository})
    : _dio = dio,
      super(tokenRepository);
```

Task 8에서 `extends BaseApi`와 `super(tokenRepository)`가 사라지고 `Dio`만 남는다.

- [ ] **Step 4: DI 등록 갱신**

```dart
getIt.registerLazySingleton<UserApi>(
  () => UserApiImpl(
    dio: getIt<Dio>(),
    tokenRepository: getIt<TokenRepository>(),
  ),
);

getIt.registerLazySingleton<DiaryApi>(
  () => DiaryApiImpl(
    dio: getIt<Dio>(),
    tokenRepository: getIt<TokenRepository>(),
  ),
);
```

- [ ] **Step 4b: API 에러 텔레메트리 복원**

`ApiException`의 생성자가 이 앱의 유일한 API 에러 Crashlytics 훅이었다. dio로 옮기면 비2xx가 `DioException`으로 던져지고 상위 ViewModel들이 이를 `ResultState.error`로 삼켜, **출시된 앱에서 API 실패가 아무 데도 보고되지 않는다.** 마이그레이션이 잘못됐을 때 현장에서 알아챌 신호가 사라지는 것이므로 복원한다.

`lib/data/data_source/api/error_reporting_interceptor.dart`:

```dart
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:dio/dio.dart';

/// 응답을 받은 실패만 크래시 리포터에 남기고 그대로 통과시킨다.
/// dio 전환 이전 ApiException 생성자가 하던 역할을 대신한다.
class ErrorReportingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      ApiException.reporter.recordError(
        err,
        err.stackTrace,
        reason: '[${response.statusCode}] ${err.requestOptions.path}',
      );
    }
    handler.next(err);
  }
}
```

`buildDio`에서 **바깥 `dio`에만, `AuthInterceptor` 뒤에** 등록한다. 순서가 중요하다 — 401이 재발급 후 재시도로 복구되면 `onError` 체인 끝까지 오지 않으므로 보고되지 않고, 복구에 실패한 것만 보고된다. `retryDio`와 `reissueDio`에는 붙이지 않는다(재발급 실패는 `AuthInterceptor`가 이미 보고한다).

- [ ] **Step 5: 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 6: 실기기 확인**

`flutter run`으로 실행해 다음 경로를 직접 확인한다. **이 단계를 건너뛰지 않는다** — 인증 흐름은 단위 테스트만으로 안전을 보장할 수 없다.

스플래시 통과나 일기 목록 조회만으로는 부족하다. 일기 목록은 서버가 아니라 로컬 sqflite(`DiaryDao`)에서 읽으므로, 목록이 잘 뜬다고 해서 이 태스크가 바꾼 dio 이관이 검증되는 것은 아니다. 아래 항목을 모두 실행한다.

1. **회원가입 (`UserApiImpl.createUser`).**
   로그아웃/신규 설치 상태에서 회원가입을 끝까지 완료한다. 이 요청은 인증이 필요 없는 요청(`AuthInterceptor.needsAuthKey: false`)이라 401 재발급 경로를 타지 않지만, 성공 응답의 토큰 저장은 이제 `needsAuth` 여부와 무관하게 동작하는 `AuthInterceptor.onResponse`가 담당한다(기존의 인라인 `saveAllTokensFromHeader` 호출 대신).
   **문제가 있다면:** 가입은 성공(204)한 것처럼 보이는데 앱이 로그인 상태로 전환되지 않거나, 곧바로 다시 로그인을 요구한다 — 가입 응답에 실린 토큰이 저장되지 않았다는 뜻이다.

2. **탈퇴 (`UserApiImpl.deleteUser`).**
   로그인 상태에서 계정을 탈퇴한다. 이 메서드는 직접 작성한 `validateStatus`(`status == 204 || status == 404`)를 쓰는 유일한 곳이고, 성공 시 JWT를 지우는 유일한 경로다.
   **문제가 있다면:** 탈퇴가 끝나지 않거나(스피너가 멈추지 않음/성공해야 할 상황에서 에러 토스트), 탈퇴는 성공했는데 앱이 로그인/가입 화면으로 돌아가지 않는다 — 토큰이 실제로는 지워지지 않아 세션이 남아있다는 뜻이다. 가능하다면 서버에서 이미 삭제된 계정 상태로 한 번 더 탈퇴를 시도해 404-성공 처리 분기도 확인한다 — 이때 404가 에러로 처리되면 문제다.

3. **문답일기 질문 조회 + 생성 (`DiaryApiImpl.fetchQuestions`, `requestQnaDiary`).**
   문답일기 작성 화면을 열어(질문 조회) 모든 질문에 답하고 일기를 생성한다(`requestQnaDiary` — 마이그레이션된 메서드 중 요청 본문이 가장 긴 곳으로, 기존에는 수동으로 `jsonEncode`했지만 이제 dio가 인코딩하는 평범한 `Map`으로 바뀌었다).
   **문제가 있다면:** 질문 로딩이 실패한다(실제 질문 대신 에러 화면), 또는 생성이 실패/멈춘다, 또는 생성된 일기 텍스트가 깨지거나 잘려 보인다 — 요청 본문 인코딩 변경 쪽을 의심한다.

4. **일기 상세 / 수정 / 삭제 (`fetchDiary`, `updateDiaryText`, `deleteDiary`).**
   기존 일기의 상세를 열고, 텍스트를 수정해 저장한 뒤, 삭제한다.
   **문제가 있다면:** 상세가 로딩되지 않거나 내용이 깨져 보인다(`response.data as Map<String, dynamic>` 캐스트나 `DiaryDetailDto.fromJson`이 dio가 파싱한 응답 형태와 어긋난다는 뜻일 수 있다), 수정이 반영되지 않는다(새로고침하면 되돌아감), 또는 삭제가 앱에서는 "성공"했는데 새로고침하면 일기가 다시 나타난다 — 새 코드가 기본 2xx `validateStatus`(구 코드는 정확한 상태코드 204/200만 확인)로 서버 응답을 실제와 다르게 성공 처리했다는 뜻일 수 있다.

5. **만료된 액세스 토큰 상태에서 각 요청 형태를 한 번씩 (필수 — 이 마이그레이션 전체의 존재 이유).**
   액세스 토큰을 일부러 만료/무효 상태로 만든 채(리프레시 토큰은 유효하게 유지) 다음을 각각 실행한다: GET 하나(`fetchDiary` 또는 `fetchQuestions`), PATCH 하나(`updateDiaryText`), 그리고 직접 작성한 `validateStatus`를 쓰는 DELETE(`deleteUser` 또는 `deleteDiary`).
   **기대 동작:** 셋 다 정확히 한 번의 조용한 재발급+재시도 후 성공하며, 사용자에게 에러가 보이거나 재로그인을 요구하지 않는다.
   **문제가 있다면:** 위 요청 중 하나라도 사용자에게 에러를 보여주거나, 무한 재시도로 멈추거나 로딩이 끝나지 않는다(인터셉터의 "한 번만 재시도" 보장이 실제 엔드포인트에서는 지켜지지 않는다는 뜻), 또는 리프레시 토큰이 아직 유효한데도 사용자에게 재로그인을 요구한다.

6. **Content-Type 예외 상황 (3~4단계에서 자연히 함께 확인됨).**
   dio는 응답의 `Content-Type`이 JSON일 때만 `response.data`를 `Map`/`List`로 파싱한다. 마이그레이션 전 `http` 기반 코드는 헤더와 무관하게 `jsonDecode(utf8.decode(...))`로 항상 파싱을 시도했다. 만약 실제 서버가 `GET /diaries/question`, `GET /diaries/{id}`, `POST /diaries/qna` 중 하나에서라도 `Content-Type: application/json`을 빠뜨리면, `response.data`가 `Map`이 아니라 원문 `String`으로 오고 `response.data['questions']` / `response.data as Map<String, dynamic>` / `response.data['content']` 같은 코드가 `TypeError`를 던진다 — 이는 `DioException`이 아니므로 `fetchQuestions`의 기본 질문 fallback으로도 잡히지 않는다. 3단계(문답일기 질문+생성)와 4단계(일기 상세)를 실제 서버로 실행하면 이 세 엔드포인트가 모두 exercise되므로 별도 단계는 필요 없지만, 여기서 확인할 것은 "데이터가 맞게 보이는가"가 아니라 "애초에 정상적으로 동작하는가"다.
   **문제가 있다면:** 일기 상세나 문답일기 질문 화면을 열 때 (정상적인 `ApiException`/`DioException` 형태의 에러가 아니라) 크래시나 처리되지 않은 예외 화면이 뜬다.

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "refactor: 비멀티파트 API를 dio로 전환

헤더 구성, 401 분기, 토큰 저장이 각 메서드에서 사라지고 인터셉터로 이관.
이미지 업로드 두 메서드는 다음 커밋에서 전환."
```

---

### Task 8: 멀티파트 전환과 http 제거

이미지 업로드 두 메서드를 옮기고 `http` 의존성을 걷어낸다. 401 재시도 시 본문 재전송이 걸리는 지점이므로 마지막에 둔다.

**Files:**
- Modify: `lib/data/data_source/api/diary/diary_api_impl.dart`
- Modify: `lib/data/data_source/api/api_exception.dart`
- Delete: `lib/data/data_source/api/base_api.dart`
- Delete: `test/data/data_source/api/base_api_test.dart`
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: `AuthInterceptor`의 `FormData` 복제 처리 (Task 6에서 구현됨)
- Produces: `BaseApi` 제거. 이후 API 구현체는 `Dio`만 의존한다

- [ ] **Step 1: 멀티파트 두 메서드 전환**

`createQnaDiary`와 `createFreeDiary`를 `FormData`로 옮긴다. 두 메서드는 엔드포인트만 다르므로 비공개 헬퍼로 묶는다.

```dart
  Future<DiaryDetailDto> _createDiary({
    required String path,
    required String text,
    required List<XFile> images,
    required String endpointName,
  }) async {
    final formData = FormData.fromMap({
      // 일반 String으로 넣으면 FormData.fields로 가서 content-type이 붙지 않는다.
      // 옛 http 구현은 비ASCII 값(한글 본문)에 항상
      // `content-type: text/plain; charset=utf-8`을 실어 보냈다
      // (package:http MultipartRequest._headerForField). 서버가 이 선언에
      // 의존해 왔을 수 있으므로 MultipartFile로 감싸 같은 선언을 유지한다.
      'text': MultipartFile.fromString(
        text,
        contentType: DioMediaType('text', 'plain', {'charset': 'utf-8'}),
      ),
      'images': [
        for (final image in images)
          await MultipartFile.fromFile(image.path),
      ],
    });

    final response = await _dio.post(path, data: formData);

    if (response.statusCode == 201) {
      return DiaryDetailDto.fromJson(response.data as Map<String, dynamic>);
    }

    // dio의 기본 validateStatus는 2xx만 통과시키므로 4xx/5xx는 여기 오기 전에
    // DioException으로 던져진다. 이 분기는 200/202/204처럼 2xx이지만 201이
    // 아닌 응답에서만 실행된다 (auth_interceptor.dart:130-131과 동일한 패턴).
    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: endpointName,
      responseBody: response.data?.toString() ?? '',
    );
  }

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  }) => _createDiary(
    path: '/diaries',
    text: text,
    images: images,
    endpointName: 'createQnaDiary',
  );

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  }) => _createDiary(
    path: '/diaries/free',
    text: text,
    images: images,
    endpointName: 'createFreeDiary',
  );
```

401이 오면 `DioException`으로 떨어지고, 인터셉터가 재발급 후 `FormData.clone()`으로 본문을 복제해 재시도한다. 이 복제가 없으면 소비된 스트림 때문에 재전송이 실패한다.

- [ ] **Step 2: BaseApi 상속 제거**

`DiaryApiImpl`의 `extends BaseApi`를 걷어내고 `Dio`와 `TokenRepository`만 받는 형태로 정리한다. `lib/data/data_source/api/base_api.dart`를 삭제한다.

**`test/data/data_source/api/base_api_test.dart`도 함께 삭제한다.** `BaseApi`가 사라지면 컴파일되지 않는다. 이 테스트가 검증하던 헤더 구성과 토큰 저장 동작은 Task 6의 `auth_interceptor_test.dart`가 대체 구현에 대해 이미 검증하므로, 전환의 안전망 역할을 마친 시점에 수명이 끝난다.

Run: `grep -rn "BaseApi" lib test`
Expected: 출력 없음

- [ ] **Step 3: ApiException에서 http 제거**

`fromResponse`와 `fromStreamedResponse` 두 팩토리를 삭제하고 `http` import를 제거한다. 호출부가 모두 사라졌으므로 안전하다.

Run: `grep -rn "fromResponse\|fromStreamedResponse" lib test`
Expected: 출력 없음

- [ ] **Step 4: API 계층에서 http 사용 제거**

Run: `grep -rn "package:http/" lib/data/data_source test`
Expected: 출력 없음

**`pubspec.yaml`의 `http`는 제거하지 않는다.** 계획 수립 시 파일 조사가 API 계층에만 미쳐서 놓쳤는데, `lib/data/service/app_store_check_service_impl.dart`가 `http`를 별도로 쓴다 — Play 스토어 상세 페이지 HTML을 정규식으로 긁고 iTunes lookup API를 호출하는 **필수 업데이트 확인** 기능이다.

이 파일은 이번 마이그레이션과 인프라를 전혀 공유하지 않는다. `ApiConfig.baseUrl`도, `AuthInterceptor`도, 토큰도 쓰지 않는다. 공개 웹 페이지를 긁는 별개의 작업이다.

옮기지 않는 이유는 위험 대비 이득이다:

- 테스트가 0인 살아 있는 코드다
- 실패가 **조용하다.** `checkForUpdate`는 오류 시 `false`를 반환하므로, 깨져도 앱은 정상 동작하는 것처럼 보이고 **필수 업데이트를 더 이상 강제할 수 없게 된 사실을 아무도 모른다**
- 기계적 이관도 아니다. 현재 코드는 `response.body`를 원문 문자열로 읽는데, dio는 JSON 응답을 자동 파싱하므로 iTunes 경로의 `json.decode(response.body)`가 깨진다. 또 dio는 기본적으로 비2xx에 예외를 던지므로 `statusCode == 200` 분기가 죽는다
- 얻는 것은 의존성 한 줄뿐이다. API 계층의 일관성은 이미 확보된다

이 서비스의 이관은 **테스트를 먼저 붙인 뒤** 별도 과제로 다룬다. 지금은 `http`를 남기고, 왜 남았는지를 `CLAUDE.md`에 기록한다.

- [ ] **Step 4b: CLAUDE.md에 두 HTTP 클라이언트 공존 사유 기록**

`CLAUDE.md`의 "함정" 절에 추가한다. 이 기록이 없으면 다음 세션이 `http`를 보고 잘못된 쪽을 따라 쓰거나, 이유 없이 남은 의존성으로 오해한다.

```markdown
- **HTTP 클라이언트가 둘이다.** API 계층(`lib/data/data_source/api/`)은 `dio`를 쓴다 — 인증 헤더, 토큰 재발급, 에러 보고가 인터셉터에 붙어 있다. `lib/data/service/app_store_check_service_impl.dart`만 `http`를 쓰는데, 스토어 페이지를 긁는 별개 작업이라 그 인프라가 필요 없고 테스트가 없어 옮기지 않았다. **새 API 호출은 언제나 `dio`를 쓴다.**
```

- [ ] **Step 5: 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 6: 실기기 확인 — 이미지 업로드**

서브에이전트는 실기기 접근이 없어 이 단계를 수행할 수 없다. 브랜치를 머지하기 전에 사람이 `flutter run`으로 직접 확인해야 한다. 각 항목에 실패 시 나타날 증상을 함께 적는다 — 이 태스크가 정확히 무엇을 바꿨는지 알아야 증상과 원인을 연결할 수 있다.

1. **자유일기 작성 + 이미지 2장 이상 첨부 → 저장 성공.**
   실패 증상: 저장 버튼을 눌러도 에러 토스트가 뜨거나 로딩에서 멈춘다. `FormData`의 필드명(`text`/`images`)이 서버 기대와 다르면 서버가 400을 반환한다.
   저장 실패 시 로그에 `type 'String' is not a subtype of type 'Map<String, dynamic>'`가 있으면 서버 응답의 Content-Type이 JSON이 아니라는 뜻이다. 이 경우 서버에는 일기가 이미 생성됐는데 앱은 실패로 보이므로, 재시도하면 중복 생성되고 하루 3개 제한을 소진한다.
2. **문답일기 작성 + 이미지 첨부 → 저장 성공.**
   실패 증상: 1과 동일. `createQnaDiary`/`createFreeDiary`는 같은 비공개 헬퍼(`_createDiary`)를 쓰므로 한쪽만 성공하고 다른 쪽만 실패한다면 헬퍼가 아니라 호출부(`path`)의 문제다.
3. **이미지 4장(도메인 상한, `ServiceConfig.maxDiaryCount`가 아니라 이미지 개수 상한)까지 첨부 → 저장 성공.**
   실패 증상: 1~3장은 되는데 4장에서만 실패하면 `MultipartFile.fromFile`을 여러 장 순회하는 부분이나 요청 크기/타임아웃 관련 회귀다.
4. **목록에서 방금 쓴 일기 확인.**
   실패 증상: 방금 쓴 일기가 목록에 없거나 다른 일기와 섞여 보인다 — 이 태스크는 로컬 sqflite 저장 경로를 건드리지 않았으므로 여기서 실패하면 응답 파싱(`DiaryDetailDto.fromJson`)이 서버 응답 형태와 어긋났을 가능성이 높다.
5. **상세에서 이미지 표시 확인.**
   실패 증상: 이미지가 깨지거나 아예 보이지 않는다 — 서버가 돌려준 이미지 URL 필드와 `DiaryDetailDto`의 매핑이 어긋났다는 신호다.
6. **만료된 토큰 상태에서 이미지 첨부 일기 저장 — 이 태스크가 존재하는 이유 그 자체.**
   액세스 토큰을 만료시킨 뒤(서버 측에서 무효화하거나, 세션을 오래 열어둔 뒤) 이미지 첨부 일기 저장을 시도한다 → 401 → 인터셉터가 토큰을 재발급하고 `FormData.clone()`으로 본문을 복제해 한 번 재시도 → 저장 성공.
   실패 증상: 다른 항목은 다 되는데 이 시나리오에서만 저장이 실패하며 에러 토스트가 뜬다. 로그(또는 Crashlytics)에 `"The FormData has already been finalized"`가 남아 있으면 `AuthInterceptor.onError`의 `data.clone()` 호출이 빠졌거나 회귀한 것이다 — 정확히 `auth_interceptor_test.dart`의 새 테스트가 잡는 것과 같은 실패다.
7. **저장 직후 상세 화면에서 한글 본문이 입력한 그대로 보이는지 확인.**
   깨져 보이면 `text` 파트의 charset 선언 문제다. `text`는 이제 일반 String이 아니라 `MultipartFile.fromString(text, contentType: DioMediaType('text', 'plain', {'charset': 'utf-8'}))`으로 감싸 보낸다 — 옛 `http` 구현이 비ASCII 값에 항상 실어 보내던 `content-type: text/plain; charset=utf-8` 선언과 wire 포맷을 맞추기 위해서다(`diary_api_impl_test.dart`가 이 헤더를 고정한다). 이 항목은 그 자동 검증이 실기기·실서버 경로에서도 성립하는지에 대한 경험적 확인이다.

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "refactor: 멀티파트 API를 dio로 전환하고 API 계층에서 http 제거

FormData로 이관. 401 재시도 시 본문은 인터셉터가 clone하여 재전송한다.
BaseApi와 그 테스트 삭제, ApiException의 http 팩토리 제거.
app_store_check_service_impl은 스토어 페이지 스크래핑용으로 http를 계속 쓰며,
테스트가 없어 별도 과제로 미룬다 — 사유를 CLAUDE.md에 기록."
```

---

### Task 9: 아키텍처 테스트 추가와 data→presentation 위반 제거

레이어 규칙을 실행 가능한 테스트로 만든다. **이 테스트가 있어야 규칙이 문서가 아니라 제약이 된다.** 먼저 테스트를 추가해 현재 위반을 드러낸 뒤, 가장 심한 위반부터 고친다.

**Files:**
- Create: `test/architecture_test.dart`
- Modify: `lib/data/repository/user_repository_impl.dart`
- Modify: `lib/config/di.dart`
- Modify: `lib/presentation/settings/settings_view_model.dart`

**Interfaces:**
- Produces: `resetDiaryTabViewModels()` — `lib/config/di.dart`에 추가. `DiaryCalendarViewModel`, `DiaryListViewModel` lazySingleton을 재등록한다

- [ ] **Step 1: 실패하는 아키텍처 테스트 작성**

`test/architecture_test.dart`:

```dart
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
  });   // Step 2에서 skip을 건다 (Task 11이 해제)

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
  });   // Step 2에서 skip을 건다 (Task 10이 해제)
}
```

- [ ] **Step 2: 실패 확인 후, 후속 태스크 몫을 skip 처리**

먼저 세 개가 모두 빨간지 눈으로 확인한다.

Run: `flutter test test/architecture_test.dart`
Expected: 3개 중 3개 모두 FAIL

- `domain` — `diary_repository.dart`의 `image_picker`, `permission_handler_service.dart`의 `permission_handler` (Task 11이 고친다)
- `data → presentation` — `user_repository_impl.dart`의 ViewModel import 2건 (이 태스크가 고친다)
- `presentation → data_source` — `splash_view_model.dart`의 `DiaryDao` (Task 10이 고친다)

세 개가 모두 실패하는 것을 확인했으면, **이 태스크가 고치지 않는 두 개에 `skip`을 건다.** Global Constraints가 각 태스크 종료 시 `flutter test` 통과를 요구하므로, 아직 손대지 않은 위반이 스위트를 빨갛게 둘 수 없다.

domain 테스트의 닫는 괄호를 이렇게 바꾼다.

```dart
  }, skip: 'Task 11에서 domain의 플랫폼 의존을 제거하며 해제한다');
```

presentation 테스트의 닫는 괄호를 이렇게 바꾼다.

```dart
  }, skip: 'Task 10에서 SplashViewModel의 DAO 의존을 제거하며 해제한다');
```

`data는 presentation을 import하지 않는다`에는 skip을 걸지 않는다 — 이 태스크가 통과시킨다.

- [ ] **Step 3: di.dart에 ViewModel 리셋 함수 추가**

`lib/config/di.dart` 끝에 추가한다. `di.dart`는 합성 루트이므로 ViewModel을 알아도 규칙 위반이 아니다.

```dart
/// 탈퇴 후 일기 탭 ViewModel의 잔여 상태를 비운다.
void resetDiaryTabViewModels() {
  if (getIt.isRegistered<DiaryCalendarViewModel>()) {
    getIt.unregister<DiaryCalendarViewModel>();
    getIt.registerLazySingleton(
      () => DiaryCalendarViewModel(diaryRepo: getIt<DiaryRepository>()),
    );
  }

  if (getIt.isRegistered<DiaryListViewModel>()) {
    getIt.unregister<DiaryListViewModel>();
    getIt.registerLazySingleton(
      () => DiaryListViewModel(diaryRepo: getIt<DiaryRepository>()),
    );
  }
}
```

- [ ] **Step 4: UserRepositoryImpl에서 presentation 의존 제거**

`_resetAppState()`와 `GetIt` 필드, presentation import 두 줄을 삭제한다. `withdraw()`는 데이터 작업만 한다.

```dart
import 'package:cake/data/data_source/api/user/user_api.dart';
import 'package:cake/data/data_source/sqflite/diary_dao.dart';
import 'package:cake/domain/enum/diary_preference.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/fcm_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _userApi;
  final DiaryDao _diaryDao;
  final FCMService _fcmService;

  UserRepositoryImpl({
    required UserApi userApi,
    required DiaryDao diaryDao,
    required FCMService fcmService,
  }) : _userApi = userApi,
       _diaryDao = diaryDao,
       _fcmService = fcmService;

  @override
  Future<void> signUp({required DiaryPreference diaryPreference}) async {
    // 앱을 삭제하지 않고 재가입하는 경우에도 FCM 토큰을 갱신하기 위해 먼저 발급
    await _fcmService.getFCMTokenAndSave();
    await _userApi.createUser(preference: diaryPreference.toServer);
  }

  @override
  Future<void> withdraw() async {
    await _userApi.deleteUser();
    await _fcmService.deleteFCMToken();
    await _diaryDao.deleteAllDiaries();
  }
}
```

- [ ] **Step 5: SettingsViewModel에서 리셋 호출**

`lib/presentation/settings/settings_view_model.dart` 43행의 `await _userRepo.withdraw();` 바로 다음 줄에 `resetDiaryTabViewModels()` 호출을 넣는다. 45행에서 성공 상태를 설정하므로 그 사이다. `import 'package:cake/config/di.dart';`를 추가한다.

```dart
    await _userRepo.withdraw();
    resetDiaryTabViewModels();
```

- [ ] **Step 6: 아키텍처 테스트 재실행**

Run: `flutter test test/architecture_test.dart`
Expected: `data는 presentation을 import하지 않는다` PASS, 나머지 둘 skipped. 실패 0건

- [ ] **Step 7: 실기기 확인 — 탈퇴**

**구현 에이전트는 실기기/시뮬레이터에 접근할 수 없어 이 단계를 수행하지 못했다. 사람이 아래 체크리스트로 직접 확인해야 한다.** 어느 항목도 검증 완료로 표시하지 않았다.

`flutter run`으로 실행해 확인한다. 가장 위험한 증상은 탈퇴 후 재가입했을 때 일기 탭 ViewModel(`DiaryCalendarViewModel`, `DiaryListViewModel`)이 이전 계정 데이터를 그대로 들고 있는 것이다 — `resetDiaryTabViewModels()`가 `getIt`에서 재등록만 하고, 이미 화면에 붙어 있는 옛 인스턴스가 여전히 참조되고 있다면 증상이 재현된다.

1. 계정 A로 로그인한 상태에서 일기를 1개 이상 작성한다 (캘린더 탭과 목록 탭 양쪽에서 보이는지 확인)
2. 설정 → 탈퇴를 실행한다
3. 탈퇴 직후 회원가입 화면으로 이동하는지 확인한다 (에러 토스트 없이 정상 전환)
4. 같은 기기에서 (다른 계정으로든 같은 계정으로든) 재가입한다
5. 재가입 직후 캘린더 탭을 연다 — 계정 A의 일기가 표시되면 실패. 빈 상태여야 한다
6. 재가입 직후 목록 탭을 연다 — 계정 A의 일기가 표시되면 실패. 빈 상태여야 한다
7. 목록 탭에서 정렬을 한 번 바꿔본다 — 바뀐 정렬에서도 계정 A의 데이터가 나타나지 않는지 확인한다 (지연 로딩된 옛 데이터가 뒤늦게 섞여 나오는 경우를 잡기 위함)
8. 새 일기를 하나 작성해 정상적으로 캘린더/목록에 반영되는지 확인한다 (리셋 후 리포지토리 배선이 끊기지 않았는지)
9. 탈퇴 도중 앱을 백그라운드로 보냈다가 복귀시켜도 크래시나 예외 토스트가 없는지 확인한다

3번(이전 데이터 없이 빈 목록)이 이 태스크가 정확히 고치려는 동작이므로 가장 중요하다.

- [ ] **Step 8: 커밋**

```bash
git add -A
git commit -m "refactor: UserRepositoryImpl의 presentation 의존 제거

리포지토리가 GetIt으로 ViewModel을 재등록하며 data가 presentation을
역방향 의존하고 있었음. 리셋을 di.dart로 옮기고 SettingsViewModel이 호출한다.
레이어 규칙을 강제하는 architecture_test 추가."
```

---

### Task 10: SplashViewModel의 DAO 직접 의존 제거

**Files:**
- Modify: `lib/domain/repository/user_repository.dart`
- Modify: `lib/data/repository/user_repository_impl.dart`
- Modify: `lib/presentation/splash/splash_view_model.dart`
- Modify: `lib/config/di.dart`

**Interfaces:**
- Produces: `UserRepository.clearLocalDiaries()` — `Future<void>`. 비활성 사용자 데이터 초기화에 쓴다

- [ ] **Step 1: UserRepository에 메서드 추가**

`lib/domain/repository/user_repository.dart`:

```dart
import 'package:cake/domain/enum/diary_preference.dart';

abstract interface class UserRepository {
  Future<void> signUp({required DiaryPreference diaryPreference});
  Future<void> withdraw();

  /// 비활성 사용자 판정 시 로컬 일기를 모두 지운다.
  Future<void> clearLocalDiaries();
}
```

`UserRepositoryImpl`에 구현을 추가한다.

```dart
  @override
  Future<void> clearLocalDiaries() async {
    await _diaryDao.deleteAllDiaries();
  }
```

- [ ] **Step 2: SplashViewModel 수정**

`DiaryDao` 필드와 생성자 파라미터, import를 제거하고 `UserRepository`를 주입받는다.

```dart
import 'package:cake/data/data_source/shared_preferences/storage.dart';
import 'package:cake/domain/enum/app_init_state.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/domain/repository/user_repository.dart';
import 'package:cake/domain/service/app_store_check_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final TokenRepository _tokenRepo;
  final AppStoreCheckService _appStoreCheckService;
  final Storage _storage;
  final UserRepository _userRepo;

  SplashViewModel({
    required TokenRepository tokenRepo,
    required AppStoreCheckService appStoreCheckService,
    required Storage storage,
    required UserRepository userRepo,
  }) : _tokenRepo = tokenRepo,
       _appStoreCheckService = appStoreCheckService,
       _storage = storage,
       _userRepo = userRepo {
    _init();
  }
```

`clearDataAndProceed()`의 `_diaryDao.deleteAllDiaries()`를 `_userRepo.clearLocalDiaries()`로 바꾼다. 나머지 로직은 그대로 둔다.

- [ ] **Step 3: DI 등록 갱신**

```dart
  getIt.registerFactory(
    () => SplashViewModel(
      tokenRepo: getIt<TokenRepository>(),
      appStoreCheckService: getIt<AppStoreCheckService>(),
      storage: getIt<Storage>(),
      userRepo: getIt<UserRepository>(),
    ),
  );
```

- [ ] **Step 4: 아키텍처 테스트의 skip 해제 후 재실행**

`test/architecture_test.dart`에서 `presentation은 data_source를 직접 import하지 않는다` 테스트의 `skip:` 인자를 제거한다.

Run: `flutter test test/architecture_test.dart`
Expected: 2개 PASS, `domain` 1개 skipped (Task 11이 해제). 실패 0건

- [ ] **Step 5: 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과 (domain 항목은 skipped), 무경고

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: SplashViewModel의 DiaryDao 직접 의존 제거

presentation이 data_source를 직접 찌르고 리포지토리를 건너뛰고 있었음.
UserRepository.clearLocalDiaries를 통해 접근한다."
```

---

### Task 11: domain의 플랫폼 패키지 의존 제거

`domain`이 `image_picker`와 `permission_handler`에 묶여 있다. 도메인 표현을 만들고 변환을 경계로 밀어낸다. 이 태스크가 끝나면 아키텍처 테스트 3개가 모두 통과한다.

**Files:**
- Create: `lib/domain/model/local_image.dart`
- Create: `lib/domain/enum/app_permission.dart`
- Modify: `lib/domain/repository/diary_repository.dart`
- Modify: `lib/domain/service/permission_handler_service.dart`
- Modify: `lib/data/repository/diary_repository_impl.dart`
- Modify: `lib/data/data_source/api/diary/diary_api.dart`, `diary_api_impl.dart`, `mock_diary_api.dart`
- Modify: `lib/data/service/permission_handler_service_impl.dart`
- Modify: `lib/presentation/free_diary_create/free_diary_create_view_model.dart`
- Modify: `lib/presentation/qna_diary_edit/qna_diary_edit_view_model.dart`
- Modify: `test/fakes/fake_diary_api.dart`, `test/fakes/fake_diary_repository.dart`

**Interfaces:**
- Produces: `LocalImage`(`final String path`), `AppPermission` enum(`camera`, `photos`, `notification`)

- [ ] **Step 1: 도메인 표현 작성**

`lib/domain/model/local_image.dart`:

```dart
/// 기기에서 고른 첨부 이미지. 플랫폼 타입(XFile)을 도메인에서 걷어내기 위한 표현.
class LocalImage {
  final String path;

  const LocalImage(this.path);
}
```

`lib/domain/enum/app_permission.dart`:

```dart
enum AppPermission { camera, photos, notification }
```

- [ ] **Step 2: domain 인터페이스 수정**

`lib/domain/repository/diary_repository.dart`에서 `image_picker` import를 지우고 `LocalImage`를 쓴다.

```dart
  Future<DiaryDetail> saveDiary({
    required DiaryType diaryType,
    required String text,
    required List<LocalImage> images,
  });
```

`lib/domain/service/permission_handler_service.dart`에서 `permission_handler` import를 지우고 `AppPermission`을 쓴다.

```dart
import 'package:cake/domain/enum/app_permission.dart';

abstract interface class PermissionHandlerService {
  Future<void> requestEssentialPermissions();
  Future<bool> requestNotificationPermission();
  Future<bool> checkNotificationPermission();
  Future<bool> requestPermission(AppPermission permission);
  Future<bool> checkPermission(AppPermission permission);
  Future<bool> isPermanentlyDenied(AppPermission permission);
}
```

- [ ] **Step 3: data 구현체 수정**

`permission_handler_service_impl.dart`에 도메인 enum → `Permission` 매핑을 둔다.

```dart
  Permission _toPlatform(AppPermission permission) => switch (permission) {
    AppPermission.camera => Permission.camera,
    AppPermission.photos => Permission.photos,
    AppPermission.notification => Permission.notification,
  };
```

각 메서드는 `_toPlatform(permission)`을 거쳐 기존 로직을 호출한다.

`DiaryApi`, `DiaryApiImpl`, `MockDiaryApi`, `DiaryRepositoryImpl`의 `List<XFile>`를 `List<LocalImage>`로 바꾼다. `MultipartFile.fromFile(image.path)`는 `LocalImage.path`로도 그대로 동작하므로 본문 변경은 없다.

- [ ] **Step 4: presentation에서 변환**

`free_diary_create_view_model.dart`와 `qna_diary_edit_view_model.dart`는 `image_picker`를 계속 쓴다 (그것이 이 레이어의 일이다). 리포지토리를 호출하는 지점에서만 변환한다.

```dart
      images: _pickedImages.map((file) => LocalImage(file.path)).toList(),
```

`lib/ui/common_components/diary_image_grid.dart`의 `XFile`은 그대로 둔다. `ui`는 presentation 계열이므로 규칙 위반이 아니다.

- [ ] **Step 5: Fake 갱신**

`test/fakes/fake_diary_api.dart`와 `test/fakes/fake_diary_repository.dart`의 `image_picker` import를 `local_image.dart`로 바꾸고 시그니처의 `List<XFile>`를 `List<LocalImage>`로 바꾼다.

- [ ] **Step 6: 마지막 skip 해제 후 전체 통과 확인**

`test/architecture_test.dart`에서 `domain은 cake와 freezed_annotation 외의 패키지에 의존하지 않는다` 테스트의 `skip:` 인자를 제거한다. 이로써 파일에 남은 skip이 없어야 한다.

Run: `grep -n "skip:" test/architecture_test.dart`
Expected: 출력 없음

Run: `flutter test test/architecture_test.dart`
Expected: 3개 모두 PASS, skipped 0건

- [ ] **Step 7: 테스트와 분석**

Run: `flutter test && flutter analyze`
Expected: 모두 통과, 무경고

- [ ] **Step 8: 실기기 확인**

서브에이전트는 실기기 접근이 없어 이 단계를 수행할 수 없다. 브랜치를 머지하기 전에 사람이 `flutter run`으로 직접 확인해야 한다. 이 태스크에서 가장 위험한 대목은 `AppPermission` → `Permission` 매핑이다 — 잘못 매핑해도 컴파일되고 테스트를 통과하며, 실기기에서만 엉뚱한 권한을 요청하는 형태로 드러난다.

1. **자유일기 작성 + 갤러리에서 이미지 1장 이상 첨부 → 저장 성공.**
   경로: `FreeDiaryCreateViewModel.completeDiary`가 `_pickedImages`(`XFile`)를 `_pickedImages.map((file) => LocalImage(file.path)).toList()`로 변환해 `DiaryRepository.saveDiary`에 넘긴다.
   실패 증상: 저장 시 에러 토스트("일기 작성에 실패했습니다"). 변환이 깨져 `path`가 비거나 잘못된 파일을 가리키면 `DiaryApiImpl._createDiary`의 `MultipartFile.fromFile(image.path)`가 파일을 찾지 못해 예외를 던지거나 서버가 400을 반환한다.
2. **자유일기 작성 시 카메라로 촬영해 첨부 → 저장 성공.**
   `getImageFromCamera` 경로도 1과 동일한 변환을 타므로 갤러리 경로와 별개로 확인한다.
3. **문답일기 확정 후 편집 화면(`QnaDiaryEditViewModel`)에서 이미지 추가 → 저장 성공.**
   실패 증상은 1과 동일. `completeDiary`의 변환 코드가 자유일기 ViewModel과 같은 형태로 중복돼 있어 한쪽만 고치고 다른 쪽을 빠뜨렸을 위험이 있다.
4. **이미지를 첨부하지 않고 저장 (빈 리스트) → 저장 성공.**
   `_pickedImages.map(...).toList()`가 빈 리스트에서도 정상 동작하는지 확인 — 회귀 위험은 낮지만 흔한 경로다.
5. **알림 권한 요청/확인 동작 — 이 태스크가 가장 조심해야 하는 시나리오.**
   `FCMServiceImpl.initialize()`가 `PermissionHandlerService.checkPermission(AppPermission.notification)`을 호출하고, 구현체의 `_toPlatform`이 `AppPermission.notification → Permission.notification`으로 매핑한다.
   실패 증상: `_toPlatform`의 매핑이 뒤바뀌면(예: `notification`이 실수로 `Permission.camera` 등에 매핑되면) FCM이 알림 권한을 확인하지 못해 알림이 전혀 오지 않거나, 앱을 켤 때마다 불필요한 권한 다이얼로그가 반복된다. 알림을 새로 설치한 기기(권한 미결정 상태)에서 최초 실행 시 알림 권한 다이얼로그가 뜨는지, 허용/거부 각각 이후 FCM 토큰이 정상 저장되는지 확인한다.
6. **(참고, 실기기 확인 불필요) `AppPermission.camera`/`AppPermission.photos`는 현재 어떤 호출부도 쓰지 않는다.**
   `image_picker`의 `pickImage`/`pickMultiImage`가 카메라·사진 라이브러리 권한을 OS 다이얼로그로 자체 처리하며 `PermissionHandlerService`를 거치지 않는다 — grep으로 확인함(`Permission.camera`/`Permission.photos`를 참조하는 호출부가 `permission_handler_service_impl.dart`의 `_toPlatform` 정의 외에는 없음). 이 값들을 쓰는 호출부가 나중에 추가되면 그때 `_toPlatform`의 `camera → Permission.camera`, `photos → Permission.photos` 매핑을 실기기에서 다시 검증해야 한다.

- [ ] **Step 9: 커밋**

```bash
git add -A
git commit -m "refactor: domain의 플랫폼 패키지 의존 제거

XFile을 LocalImage로, Permission을 AppPermission으로 대체하고
플랫폼 타입 변환을 data/presentation 경계로 밀어냄.
architecture_test 3개 모두 통과."
```

---

## 완료 후

1~11이 끝나면 스펙의 항목 1~4가 완료된다. 남은 두 항목은 별도 계획으로 다룬다.

- **스펙 5번 `Result<D, E>` 도입** — 예외 발생 지점이 인터셉터 한 곳으로 모인 뒤라야 의미가 있다. 착수 여부를 다시 판단한다
- **스펙 6번 디자인 토큰 정착** — 독립적이고 위험이 낮다. 언제 해도 된다

dev 머지는 기능 변경이 없으므로 스토어 릴리즈와 무관하게 진행할 수 있다.
