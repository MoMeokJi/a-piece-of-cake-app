# 조각케이크 앱 — AI 작업성 리팩토링 설계

작성일: 2026-09-01
브랜치: `refactor/ai-workability`
기준 커밋: `ddbbdba` (dev)

## 배경

이 앱은 Claude Code를 쓰지 않던 시기에 만들어졌다. 코드 자체는 이미 스토어에
출시되어 동작 중이고, 구조도 무너져 있지 않다. 문제는 **새 세션이 이 코드를
안전하게 고칠 수 있는 조건이 갖춰져 있지 않다**는 것이다.

AI가 코드를 잘 다루기 위한 조건은 세 가지다.

| 조건 | 현황 |
| --- | --- |
| 맥락 문서 | 없음 (CLAUDE.md 부재) |
| 검증 수단 | 없음 (테스트 0개) |
| 패턴 일관성 | 대체로 양호, 국소적 이탈 존재 |

세 번째가 이미 좋다는 점이 이 리팩토링의 성격을 결정한다. **구조를 바꾸는
작업이 아니라, 이미 있는 구조를 문서화하고 검증 가능하게 만들고 이탈을
회수하는 작업이다.**

## 목표

새 세션(사람이든 AI든)이 이 저장소에서 기능을 추가할 때,
코드를 광범위하게 읽지 않고도 올바른 첫 수를 두게 만든다.

성공 기준:

- CLAUDE.md만 읽고 "화면 하나 추가"의 손댈 파일과 순서를 알 수 있다
- 인증/네트워크 계층을 고칠 때 회귀를 잡아줄 테스트가 있다
- 엔드포인트 추가에 필요한 코드가 지금의 절반 이하다
- 레이어 규칙을 어긴 선례가 코드에 남아 있지 않다

## 현황 분석

측정 기준: `lib/` 아래 dart 파일 119개, 8,876줄.

### 잘 되어 있는 것

- `data / domain / presentation` 레이어 분리와 디렉터리 규칙이 일관적이다
- 화면 10개가 예외 없이 같은 MVVM 형태다 — `*_screen.dart` + `*_view_model.dart`,
  `context.watch/read` + `ChangeNotifierProvider` + get_it 조합
- `lib/config/`에 DI, 라우터, 설정이 모여 있다
- 파일이 작다. 가장 큰 파일이 270줄이다

이 구성은 `~/.claude/skills/`의 `flutter-presentation-mvvm`,
`flutter-di-get-it`, `flutter-navigation-go-router`, `flutter-data-layer`
스킬이 서술하는 모습과 거의 일치한다. **목표 상태의 스펙이 이미 스킬 문서로
존재하며, 코드가 거기서 이탈한 지점만 회수하면 된다.**

### 비어 있는 것

**테스트가 사실상 0.** `test/widget_test.dart`는 Flutter 기본 스캐폴드
그대로다 (존재하지 않는 카운터 UI를 검증한다). 2026-09-01 기준 `flutter test`
실행 결과 `+0 -1`로 실패한다.

**API 계층의 중복.** `diary_api_impl.dart`와 `user_api_impl.dart`의 API
메서드 9개 중 8개가 같은 절차를 손으로 반복한다 (인증이 필요 없는 메서드
하나만 예외다).

```
getHeaders() → 상태코드 분기 → saveAllTokensFromHeader() → 401이면 reissueTokens() 후 재귀 호출 → jsonDecode
```

측정치: `getHeaders()` 8회, `statusCode == 401` 8회, `reissueTokens()` 8회,
`saveAllTokensFromHeader` 8회, `jsonDecode` 5회.

**401 재시도에 횟수 제한이 없다.** 각 API 메서드는 401을 받으면
`reissueTokens()` 후 자기 자신을 재귀 호출한다. 재발급이 204로 성공하는데
서버가 계속 401을 반환하는 상황에서 요청이 무한히 반복된다. 실사용 중인
앱에서 발생 가능한 결함이다.

### 이탈한 것

**presentation → data 직접 의존.** `splash_view_model.dart`가 `DiaryDao`를
직접 주입받아 `deleteAllDiaries()`를 호출한다 (83행). Repository를 건너뛴다.

**domain → 플랫폼 패키지 의존.** `DiaryRepository.saveDiary`가 `XFile`
(image_picker 타입)을 파라미터로 받는다. domain 레이어가 플랫폼 패키지에
묶인다.

**디자인 토큰 우회.** `color_config.dart`, `text_config.dart`가 있는데도
`Color(0x...)` 하드코딩 35곳, 인라인 `TextStyle(...)` 76곳이 존재한다.

### 정리 대상

- `flutter_dotenv`가 의존성에 있으나 `lib/` 어디서도 사용하지 않는다.
  `ApiConfig`는 baseUrl을 하드코딩한다
- `mockito`가 dev_dependencies에 있으나 사용처가 없다
- mock API 전환이 `di.dart` 63행 주석 토글로 되어 있다. 실수로 커밋되면
  앱이 목 데이터로 빌드된다

## 범위

### 포함

1. CLAUDE.md 작성
2. 테스트 안전망 구축
3. dio + Interceptor 전환
4. 레이어 누수 정리
5. `Result<D, E>` 도입
6. 디자인 토큰 정착

### 제외

**상태관리 교체 (Riverpod / bloc).** 현재 MVVM 구성이 10개 화면에서 일관되게
유지되고 있다. AI 작업성을 결정하는 것은 패키지의 최신성이 아니라 일관성과
검증 가능성이며, 이 앱은 전자를 이미 갖췄다. 테스트가 없는 상태에서 출시된
앱의 상태관리를 전면 교체하는 것은 회귀 위험이 크고 목표에 기여하는 바가
작다. 필요해지는 시점에 별도 과제로 다룬다.

기능 변경, 화면 구조 변경, sqflite 스키마 변경은 이번 작업에 포함하지 않는다.

## 작업 항목

### 1. CLAUDE.md

프로젝트 루트에 작성한다.

담을 내용:

- 앱 한 줄 요약과 주요 도메인 개념 (일기 종류: 자유 / 문답)
- 레이어 구조와 의존 방향
- **화면 하나를 추가할 때 손대는 파일과 순서** — screen → view_model → di → router
- 명령어 — `flutter run`, `flutter test`, `dart run build_runner build`
- 함정 — di.dart의 mock 토글, 사용하지 않는 dotenv
- 릴리즈 플로우 — dev 푸시 → 스토어 승인 후 main 머지 + `플랫폼/v버전` 태그

`~/.claude/skills/`의 `flutter-*` 스킬과 겹치는 내용은 서술하지 않고 참조만
한다. 같은 내용을 두 곳에 두면 갈라진다. CLAUDE.md에는 이 앱에만 해당하는
것만 적는다.

완료 기준: 이 문서만 읽고 새 화면 추가의 첫 수를 둘 수 있다.

### 2. 테스트 안전망

**새 의존성을 추가하지 않는다.** `MockDiaryApi` 같은 손으로 쓴 목이 이미
`lib/`에 있고, `flutter-testing` 스킬도 Fake Repository 방식을 따른다.
기존 결과 같은 방식으로 Fake 클래스를 작성한다. 사용하지 않는 `mockito`는
dev_dependencies에서 제거한다.

우선순위는 **3번에서 건드릴 곳을 먼저 덮는다**로 정한다.

1. `BaseApi` 토큰 흐름 — 헤더 구성, 401 → 재발급 → 재시도, 응답 헤더에서
   토큰 저장. 3번 작업의 안전망 그 자체이므로 최우선
2. Repository 매핑 — DTO → 도메인 변환
3. ViewModel 상태 전이 — `ResultState` 흐름. 대표 화면 2~3개

위젯 테스트는 이번 범위에서 제외한다. 비용 대비 회귀 검출력이 낮다.
`test/widget_test.dart`는 삭제하거나 실제로 통과하는 최소 스모크 테스트로
교체한다.

완료 기준: `flutter test`가 통과하며, 3번 작업 중 토큰 흐름이 깨지면
테스트가 실패한다.

### 3. dio + Interceptor 전환

`AuthInterceptor` 하나가 다음을 흡수한다.

- 요청 헤더 주입 (Authorization, Refresh-Token)
- 응답 헤더에서 토큰 저장
- 401 처리 — 재발급 후 **재시도 1회로 제한**

재시도 제한이 이번 작업의 핵심이다. 현재의 무한 재귀를 여기서 끊는다.
재발급 자체가 실패하거나 재시도 후에도 401이면 인증 실패로 확정하고 상위에
전달한다.

API 메서드에는 요청 구성과 응답 파싱만 남는다. `ApiException`은 dio 에러에서
생성하도록 진입점을 바꾸되 형태는 유지한다. 전환이 끝나면 `http` 의존성을
제거한다.

멀티파트 업로드(`createQnaDiary`, `createFreeDiary`)는 dio의 `FormData`로
옮긴다. 이 두 메서드가 가장 손이 많이 가므로 전환 순서상 마지막에 둔다.

완료 기준: API 메서드에 `getHeaders`, `statusCode == 401`,
`saveAllTokensFromHeader` 호출이 남아 있지 않다. 2번의 토큰 흐름 테스트가
통과한다.

### 4. 레이어 누수 정리

- `splash_view_model.dart`의 `DiaryDao` 직접 의존을 제거한다. 데이터 삭제를
  Repository 메서드로 노출하고 ViewModel은 그것을 호출한다
- `DiaryRepository.saveDiary`의 `XFile`을 도메인 타입으로 교체한다. 파일
  경로 등 필요한 정보만 담는 도메인 모델을 정의하고, `XFile` → 도메인 변환은
  presentation 또는 data 경계에서 수행한다

범위가 작고 3번과 성격이 붙어 있어, 3번을 끝낸 직후 이어서 진행한다.

완료 기준: `lib/presentation/` 아래에서 `DiaryDao`와 `sqflite` 참조가
사라진다. `lib/domain/` 아래에서 `image_picker` import가 사라진다.

### 5. `Result<D, E>` 도입

3번으로 예외 발생 지점이 Interceptor 한 곳에 모인 뒤에 착수한다.

- freezed 기반 `Result<D, E>` sealed 클래스 정의
- 기능별 에러 enum 정의 (네트워크, 인증, 검증)
- Repository 시그니처를 `Result` 반환으로 변경
- ViewModel의 `try/catch`를 `switch` 패턴 매칭으로 교체

현재 `try/catch`는 10개 ViewModel에 흩어져 있다. `ResultState` enum은 UI
상태 표현으로 계속 쓰되, 에러의 원인 전달은 `Result`가 맡는다.

범위가 가장 크고 긴급하지 않다. 1~4가 끝난 뒤 착수 여부를 다시 판단한다.

완료 기준: `lib/presentation/` 아래 `catch` 블록이 사라진다.

### 6. 디자인 토큰 정착

하드코딩된 `Color(0x...)` 35곳과 인라인 `TextStyle(...)` 76곳을
`color_config` / `text_config`로 회수한다. 토큰에 없는 값은 토큰을 추가한 뒤
참조한다.

완전히 독립적이고 위험이 낮다. 언제든 잘라낼 수 있고 별도 작업으로 미뤄도
된다. 순서상 맨 뒤에 둔다.

완료 기준: `lib/presentation/` 아래 `Color(0x` 리터럴이 없다.

## 위험과 완화

| 위험 | 완화 |
| --- | --- |
| 3번에서 인증 흐름이 깨지면 전체 사용자가 로그아웃된다 | 2번의 토큰 흐름 테스트를 먼저 통과시킨 뒤 착수한다. 이 순서는 협상 대상이 아니다 |
| dio 전환 중 멀티파트 업로드가 깨진다 | 멀티파트를 마지막에 전환하고, 실기기에서 일기 작성을 직접 확인한다 |
| 5번이 거의 모든 파일을 건드려 회귀를 만든다 | 1~4 완료 후 착수 여부를 재판단한다. 착수 시 Repository 단위로 나눠 진행한다 |
| 리팩토링 중 dev에 릴리즈가 필요해진다 | 브랜치를 분리해 두었다. dev는 언제든 릴리즈 가능한 상태로 유지한다 |

## 검증

각 항목 완료 시:

- `flutter analyze` 무경고
- `flutter test` 통과
- 3번, 4번 완료 후에는 실기기에서 로그인 → 일기 작성(이미지 포함) →
  목록 조회 → 삭제 경로를 직접 확인한다

## 진행 방식

작업 항목 1 → 2 → 3 → 4 순서는 의존 관계가 있어 고정이다. 5와 6은 독립적이며
착수 여부와 시점을 따로 판단한다.

각 항목은 별도 커밋으로 남긴다. 리팩토링이 끝나면 dev로 머지한다. 이 브랜치의
작업은 기능 변경이 없으므로 스토어 릴리즈와 무관하게 머지할 수 있다.
