# fastlane 배포 자동화 설계

작성일: 2026-09-25 · 브랜치: `feature/fastlane-deploy`

## 목표

명령 한 번(`./scripts/deploy.sh android|ios|all`)으로 빌드부터 스토어 업로드까지 한다.
아이맥과 맥북 두 대에서 똑같이 동작해야 한다.

### 하는 것
- 배포 전 점검 → 테스트 → 빌드 → 결과물 버전 확인 → 업로드
- Android: Play Console **내부 테스트 트랙**에 업로드
- iOS: **TestFlight**에 업로드

### 하지 않는 것
- **심사 제출.** 사용자가 콘솔에서 직접 한다. 첫 배포가 잘 되면 옵션으로 추가한다 (아래 "나중에")
- **main 머지와 태그.** 릴리즈 규칙(CLAUDE.md "릴리즈")대로 스토어 승인 뒤에 사용자가 직접 한다. 거절당해도 main은 그대로다
- **빌드 번호 자동 증가.** 커밋된 번호와 실제로 올라간 번호가 달라지면 태그와 커밋의 대응이 깨진다
- **CI.** 지금은 로컬 전용이다. 다만 lane은 로컬 경로에 묶지 않고 환경변수로 받아서 CI에서도 그대로 쓸 수 있게 한다

## 실행 환경

- 두 맥의 홈 경로가 같다 (`/Users/seoyun`)
- Ruby: 시스템 Ruby(2.6)는 쓰지 않는다. rbenv 등으로 설치한 Ruby에 `bundle install`로 fastlane을 설치한다. 버전은 `.ruby-version`, `Gemfile.lock`으로 고정해 두 맥을 맞춘다
- iOS 서명: 지금처럼 Xcode 자동 서명(팀 `X2Z78T337C`)을 쓴다. `match`는 도입하지 않는다

## 비밀 파일

전부 `~/development/keys/`에 있고 깃 밖이다. 두 맥 사이는 에어드랍으로 맞춘다. 각 키의 설명은 같은 폴더의 `README.md`에 있다.

| 파일 | 용도 |
| --- | --- |
| `playstore-key.jks` | Android 업로드 키. `android/key.properties`가 절대경로로 가리킨다 |
| `cake-asc-api-<키 ID>.p8` | App Store Connect API 팀 키 (앱 관리 권한) |
| `cake-play-service-account.json` | Play Developer API 서비스 계정 `fastlane-play@…` (조각케이크 앱 권한만) |
| `fastlane.env` | 위 파일 경로, ASC 키 ID, Issuer ID |

`fastlane.env`에 들어갈 값 (실제 값은 `~/development/keys/README.md`에 있다. 저장소에는 적지 않는다):

```
ASC_KEY_ID=<키 ID>
ASC_ISSUER_ID=<Issuer ID>
ASC_KEY_PATH=<.p8 절대경로>
PLAY_JSON_KEY_PATH=<서비스 계정 JSON 절대경로>
```

`deploy.sh`는 이 파일 위치를 `CAKE_KEYS_DIR`(기본값 `~/development/keys`)로 찾는다. 저장소에는 비밀 값이 하나도 들어가지 않는다.

### 빌드 때 필요한 비밀 파일 목록

지금은 없다. 나중에 소셜 로그인 앱 키처럼 `--dart-define-from-file`로 넘길 파일이 생기면 `deploy.sh` 맨 위의 목록 한 곳에 추가한다. 점검 단계와 빌드 인자가 모두 이 목록을 읽는다.

## 버전 관리

`pubspec.yaml`의 `version`이 유일한 기준이다.

- `android/app/build.gradle.kts`: 하드코딩된 `versionCode = 6` / `versionName = "1.1.0"`을 `flutter.versionCode` / `flutter.versionName`으로 바꾼다
- `ios/Runner/Info.plist`: 하드코딩된 `1.0.0` / `3`을 `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`로 바꾼다
- `pubspec.yaml`: 다음 릴리즈 번호로 올린다. 두 스토어의 최신 빌드 번호(Android 6, iOS 3) 중 큰 쪽보다 커야 하므로 `+7`부터 쓴다. 두 플랫폼이 같은 번호를 쓴다
- CLAUDE.md "릴리즈" 1번의 "`build.gradle.kts`의 versionCode/versionName"을 "`pubspec.yaml`의 version"으로 고친다

**알려진 함정:** pubspec 버전은 `flutter build` 때 `ios/Flutter/Generated.xcconfig`로 복사된다. Xcode에서 바로 Archive하면 예전에 복사된 번호가 들어간다. 스크립트는 항상 `flutter build`를 거치므로 안전하다. 수동 Archive가 필요하면 먼저 `flutter build ipa`를 한 번 돌린다. 이 내용을 CLAUDE.md "함정"에 추가한다.

## 흐름

`./scripts/deploy.sh <android|ios|all>`

1. **점검** (빌드 전)
   - `fastlane.env`와 거기 적힌 키 파일, `android/key.properties`, 키스토어, 빌드용 비밀 파일 목록이 모두 있는가 → 없으면 빠진 파일 이름을 출력하고 멈춘다
   - `lib/config/di.dart`에 주석이 아닌 `=> Mock…` 등록이 있는가 → 있으면 멈춘다
   - 작업 트리가 깨끗한가 (커밋 안 된 변경, 추적 안 된 파일) → 아니면 멈춘다. 올라간 빌드가 정확히 어떤 커밋인지 알아야 승인 뒤 태그를 달 수 있다
   - pubspec 빌드 번호가 스토어 최신 번호보다 큰가 (Play: 모든 트랙의 versionCode, iOS: TestFlight 최신 빌드) → 아니면 멈춘다
2. **테스트**: `flutter test`. 실패하면 멈춘다
3. **빌드**: `flutter build appbundle --release` / `flutter build ipa --release`
4. **결과물 확인**: `.aab`/`.ipa` 안에 실제로 들어간 버전을 꺼내 pubspec과 비교한다. 다르면 업로드하지 않고 멈춘다
5. **업로드**: Play 내부 테스트 트랙(`upload_to_play_store`, 메타데이터·스크린샷은 건드리지 않음) / TestFlight(`upload_to_testflight`, 처리 완료를 기다리지 않음)
6. **안내 출력**: 올린 버전, 커밋 해시, 그리고 승인 뒤 할 일(main fast-forward 머지, `android/v1.1.0` 형식 태그)

`all`은 Android를 끝까지 돌린 뒤 iOS를 돌린다. 앞이 실패하면 뒤는 돌리지 않는다. 테스트는 한 번만 돌린다.

## 파일 구성

깃에 올리는 것:

```
scripts/deploy.sh      # 입구. 인자 파싱, 점검, 테스트, fastlane 호출
fastlane/Fastfile      # android/ios lane. 스토어 번호 조회, 빌드, 결과물 확인, 업로드
fastlane/Appfile       # 번들 ID com.momeokji.cake, 패키지명 com.momeokji.cake
Gemfile, Gemfile.lock  # fastlane 버전 고정
.ruby-version
```

`fastlane/`은 `android/`, `ios/` 아래가 아니라 저장소 루트에 하나 둔다. Flutter 빌드는 루트에서 돌리고, 두 플랫폼이 점검 로직을 공유한다.

`.gitignore`에 추가: `fastlane/report.xml`, `fastlane/Preview.html`, `fastlane/screenshots`, `fastlane/test_output`, `vendor/bundle`

## 에러 처리

- 모든 단계는 실패하면 즉시 멈추고, 무엇이 왜 실패했는지와 다음에 할 일을 한국어로 출력한다
- 업로드 전 단계(1–4)에서 멈추면 스토어에는 아무 영향이 없다
- Play 권한이 막 부여된 경우 반영에 최대 하루가 걸릴 수 있다. 권한 에러가 나면 그 가능성을 메시지에 함께 적는다

## 검증

- `deploy.sh <플랫폼> --check-only`는 1단계 점검만 하고 끝낸다. 빌드와 업로드 없이 확인할 수 있다
- 일부러 틀리게 만든 상황(키 파일 없음, mock 주석 해제, 더러운 작업 트리, 낮은 빌드 번호)에서 각각 멈추는지 확인한다
- 첫 실제 업로드는 `+7`로 한다. 업로드 뒤 Play Console 내부 테스트와 TestFlight에서 빌드 번호를 눈으로 확인한다
- 맥북에서도 `--check-only`를 한 번 돌려 파일이 다 있는지 확인한다

## 나중에

- **심사 제출 옵션.** 첫 배포가 잘 되면 `--submit`을 추가한다. Android는 production 트랙 + 심사, iOS는 `deliver`로 심사 제출
- **CI.** GitHub Actions로 옮기려면 키를 secrets로 옮기고 iOS 서명을 `match` 등으로 바꿔야 한다
- **소셜 로그인.** 앱 키 파일은 위의 "빌드 때 필요한 비밀 파일 목록"에 추가한다. 구글·카카오 로그인은 업로드 키 지문과 함께 **Play 앱 서명 키 지문**(Play Console → 앱 무결성)도 등록해야 스토어 빌드에서 동작한다. Sign in with Apple을 추가한 뒤 첫 빌드에서 프로필 에러가 나면 Xcode에서 서명 탭을 한 번 열어 자동 서명이 갱신되게 한다
