# fastlane 배포 자동화 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `./scripts/deploy.sh android|ios|all` 한 번으로 점검 → 테스트 → 빌드 → 결과물 확인 → 업로드(Play 내부 테스트 / TestFlight)까지 한다. 아이맥과 맥북에서 똑같이 돈다.

**Architecture:** 비밀이 없는 로컬 점검은 bash(`scripts/lib/preflight.sh`)로 두고 bash 테스트로 검증한다. 스토어와 대화하는 부분(빌드 번호 조회, 업로드)은 fastlane(`fastlane/Fastfile`)이 맡는다. `scripts/deploy.sh`가 `~/development/keys/fastlane.env`를 읽어 둘을 순서대로 부른다. 버전은 `pubspec.yaml` 하나로 통일한다.

**Tech Stack:** bash 3.2 (macOS 기본), Ruby 3.4.6 (rbenv), Bundler, fastlane, bundletool, Flutter 3.47

**Spec:** `docs/superpowers/specs/2026-09-25-fastlane-deploy-design.md`

## Global Constraints

- 브랜치: `feature/fastlane-deploy`
- **스토어에 쓰는 동작(업로드)은 Task 8에서 사용자가 직접 확인할 때만 한다.** Task 1–7의 검증은 읽기 전용 조회(`check_store` lane)와 `CAKE_SKIP_UPLOAD=1` 빌드만 쓴다
- **비밀 값을 저장소에 쓰지 않는다.** 키 ID, Issuer ID, 서비스 계정 이메일, 비밀번호 모두 해당. 실제 값은 `~/development/keys/README.md`에만 있다. 키 파일(`.p8`, `.json`, `.jks`, `key.properties`) 내용을 출력하거나 로그에 남기지 않는다
- **bash 3.2 호환.** macOS `/bin/bash`가 3.2다. `mapfile`, 연관 배열, `${var,,}`를 쓰지 않는다. `set -u` 아래에서 빈 배열을 `"${arr[@]}"`로 전개하면 에러가 나므로 길이를 먼저 확인한다
- **`set -euo pipefail` 아래의 파이프라인.** 못 찾으면 1을 내는 `grep`이나 입력을 일찍 닫는 `head`를 파이프에 넣으면 스크립트가 메시지 없이 죽는다. `awk`/`sed -n 1p`를 쓰거나 `|| true`를 붙인다
- **Ruby는 rbenv 3.4.6.** 시스템 Ruby(2.6)에 gem을 설치하지 않는다
- **작업 시작 시점의 미커밋 변경(`analysis_options.yaml`, `pubspec.lock`)을 커밋에 섞지 않는다.** `git add`는 항상 경로를 명시한다. 이 둘의 처리는 사용자가 정한다 (Task 8 전제 조건)
- 사용자에게 보이는 메시지(스크립트 출력, 에러)는 한국어
- 커밋 메시지는 한국어, 기존 컨벤션(`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `build:`)을 따르고 끝에 `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
- 각 태스크 완료 조건: `bash scripts/test/preflight_test.sh` 통과(Task 2 이후), `flutter test` 통과. Dart 코드는 건드리지 않으므로 `flutter analyze`는 변화가 없어야 한다

## Review Focus

1. **다른 폴더에서 실행** (`cd scripts && ./deploy.sh android`, 또는 홈에서 절대경로로) → 저장소 루트에서 실행한 것과 똑같이 동작해야 한다. Task 6에 테스트
2. **`fastlane.env`는 있는데 값 하나가 비었다** (맥북의 옛 env 파일) → 네트워크에 나가기 전에 빠진 변수 이름을 알려주고 멈춰야 한다. Task 2에 테스트
3. **pubspec `version`이 `1.1.0`처럼 `+번호`가 없거나 뒤에 주석이 붙었다** → 없으면 형식을 알려주고 멈춘다. 주석은 무시하고 읽는다. Task 2에 테스트
4. **추적 안 되는 파일이 하나 있다** (메모 파일 등) → 수정 파일과 똑같이 작업 트리가 더럽다고 보고 멈춘다. Task 2에 테스트
5. **`key.properties`의 `storeFile`이 상대경로다** (맥북에서 누가 바꿔 적음) → Gradle처럼 `android/app/` 기준으로 풀어서 존재를 확인해야 한다. 그렇지 않으면 멀쩡한 키스토어를 "없다"고 한다. Task 2에 테스트

## File Structure

**생성**

| 경로 | 책임 |
| --- | --- |
| `.ruby-version` | rbenv가 쓸 Ruby 버전 (두 맥 공통) |
| `Gemfile`, `Gemfile.lock` | fastlane 버전 고정 |
| `scripts/lib/preflight.sh` | 비밀 없이 로컬에서 끝나는 점검 함수 모음. 부작용 없음 |
| `scripts/test/preflight_test.sh` | preflight 함수와 deploy.sh 인자 처리 테스트. 의존성 없는 순수 bash |
| `scripts/deploy.sh` | 입구. 인자 파싱, env 로드, 점검, 테스트, lane 호출, 마무리 안내 |
| `fastlane/Appfile` | 번들 ID, 패키지명, 팀 ID (공개 정보) |
| `fastlane/Fastfile` | `android`/`ios`의 `check_store`, `deploy` lane |
| `~/development/keys/fastlane.env` | **저장소 밖.** 키 경로와 ID |

**수정**

| 경로 | 변경 |
| --- | --- |
| `.gitignore` | fastlane 부산물 무시 |
| `android/app/build.gradle.kts:36-37` | 하드코딩 버전 → `flutter.versionCode` / `flutter.versionName` |
| `ios/Runner/Info.plist` | 하드코딩 버전 → `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` |
| `pubspec.yaml:4` | `1.0.0+1` → `1.1.0+7` |
| `CLAUDE.md` | 명령어, 릴리즈 1번, 함정 절 |
| `~/development/keys/README.md` | `fastlane.env` 항목 보강 (저장소 밖) |

---

### Task 1: Ruby·fastlane 도구 준비

**Files:**
- Create: `.ruby-version`, `Gemfile`, `Gemfile.lock`
- Modify: `.gitignore`

**Interfaces:**
- Produces: 저장소 루트에서 `bundle exec fastlane --version`이 동작한다. `bundletool`이 PATH에 있다

- [ ] **Step 1: ruby-build 목록 갱신 후 Ruby 3.4.6 설치**

```bash
brew upgrade ruby-build || brew install ruby-build
rbenv install -s 3.4.6
```

Expected: 끝에 `Installed ruby-3.4.6` 또는 이미 있으면 아무 출력 없음

- [ ] **Step 2: 버전 파일 작성**

`.ruby-version`:

```
3.4.6
```

Run: `cd /Users/seoyun/development/cake/a-piece-of-cake-app && ruby -v`
Expected: `ruby 3.4.6`. `system` 2.6이 나오면 셸에 rbenv 초기화가 없는 것이다. `eval "$(rbenv init - zsh)"`가 `~/.zshrc`에 있는지 확인한다

- [ ] **Step 3: Gemfile 작성과 설치**

`Gemfile`:

```ruby
source "https://rubygems.org"

gem "fastlane"
```

Run: `bundle install`
Expected: `Bundle complete!`, `Gemfile.lock` 생성. Ruby 3.4에서 기본 gem에서 빠진 gem(`abbrev`, `base64`, `nkf`, `mutex_m` 등)이 없다는 에러가 나면 그 gem을 `Gemfile`에 한 줄씩 추가하고 다시 설치한다

- [ ] **Step 4: 동작 확인**

Run: `bundle exec fastlane --version`
Expected: `fastlane 2.x.y` 출력

- [ ] **Step 5: bundletool 설치**

Run: `brew install bundletool && bundletool version`
Expected: `1.18.3` 이상

- [ ] **Step 6: `.gitignore`에 fastlane 부산물 추가**

`.gitignore` 맨 끝에 추가:

```
# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
fastlane/README.md
vendor/bundle
```

- [ ] **Step 7: Commit**

```bash
git add .ruby-version Gemfile Gemfile.lock .gitignore
git commit -m "build: fastlane 실행 환경을 고정한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: 로컬 점검 함수와 테스트

**Files:**
- Create: `scripts/lib/preflight.sh`
- Test: `scripts/test/preflight_test.sh`

**Interfaces:**
- Produces (모두 실패 시 stderr에 한국어 메시지를 쓰고 1을 반환한다. 성공 시 0):
  - `read_pubspec_version <root>` → stdout `"<이름> <번호>"` (예: `1.1.0 7`)
  - `check_env_vars <변수이름>...` → 비어 있거나 없는 변수를 한 번에 나열
  - `check_files_exist <경로>...` → 없는 파일을 한 번에 나열
  - `keystore_path <root>` → stdout 키스토어 절대경로
  - `check_no_mock_api <root>` → `lib/config/di.dart`에 주석 아닌 `=> Mock…` 등록이 있으면 실패
  - `check_clean_tree <root>` → `git status --porcelain`이 비어 있지 않으면 실패

- [ ] **Step 1: 실패하는 테스트 작성**

`scripts/test/preflight_test.sh`:

```bash
#!/bin/bash
# scripts/lib/preflight.sh와 scripts/deploy.sh 인자 처리 테스트.
# 실행: bash scripts/test/preflight_test.sh
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
# shellcheck source=../lib/preflight.sh
source "$REPO/scripts/lib/preflight.sh"

passed=0
failed=0
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { passed=$((passed + 1)); printf '  ok   %s\n' "$1"; }
flunk() { failed=$((failed + 1)); printf '  FAIL %s\n       %s\n' "$1" "$2"; }

# 사용법: expect_ok "설명" 명령...
expect_ok() {
  local desc="$1" out; shift
  if out="$("$@" 2>&1)"; then pass "$desc"; else flunk "$desc" "실패했다: $out"; fi
}

# 사용법: expect_fail "설명" "출력에 있어야 할 문자열" 명령...
expect_fail() {
  local desc="$1" needle="$2" out; shift 2
  if out="$("$@" 2>&1)"; then
    flunk "$desc" "성공하면 안 된다: $out"
  elif [[ "$out" != *"$needle"* ]]; then
    flunk "$desc" "'$needle'이 출력에 없다: $out"
  else
    pass "$desc"
  fi
}

# 사용법: expect_eq "설명" "기대값" 명령...
expect_eq() {
  local desc="$1" want="$2" got; shift 2
  got="$("$@" 2>&1)"
  if [[ "$got" == "$want" ]]; then pass "$desc"; else flunk "$desc" "기대 '$want', 실제 '$got'"; fi
}

# 커밋까지 된 최소 저장소를 만들어 경로를 출력한다
make_repo() {
  local d
  d="$(mktemp -d "$TMP_ROOT/repo.XXXXXX")"
  mkdir -p "$d/lib/config" "$d/android/app"
  printf 'name: cake\nversion: 1.1.0+7\n' > "$d/pubspec.yaml"
  cat > "$d/lib/config/di.dart" <<'EOF'
import 'package:cake/data/data_source/api/diary/mock_diary_api.dart';

void diSetup() {
  getIt.registerLazySingleton<DiaryApi>(() => DiaryApiImpl());
  // getIt.registerLazySingleton<DiaryApi>(() => MockDiaryApi());
}
EOF
  printf 'storeFile=/abs/upload.jks\n' > "$d/android/key.properties"
  git -C "$d" init -q
  git -C "$d" add -A
  git -C "$d" -c user.name=t -c user.email=t@t commit -q -m init
  echo "$d"
}

echo "read_pubspec_version"
r="$(make_repo)"
expect_eq "이름과 번호를 나눠 읽는다" "1.1.0 7" read_pubspec_version "$r"
printf 'name: cake\nversion: 1.1.0+7 # 다음 릴리즈\n' > "$r/pubspec.yaml"
expect_eq "뒤에 붙은 주석은 무시한다" "1.1.0 7" read_pubspec_version "$r"
printf 'name: cake\nversion: 1.1.0\n' > "$r/pubspec.yaml"
expect_fail "+번호가 없으면 형식을 알려준다" "1.2.3+4" read_pubspec_version "$r"

echo "check_env_vars"
expect_ok "모두 있으면 통과" env A=1 B=2 bash -c "source '$REPO/scripts/lib/preflight.sh'; check_env_vars A B"
expect_fail "빈 값과 없는 값을 모두 이름으로 알려준다" "B C" \
  env A=1 B= bash -c "source '$REPO/scripts/lib/preflight.sh'; check_env_vars A B C"

echo "check_files_exist"
touch "$TMP_ROOT/present"
expect_ok "있으면 통과" check_files_exist "$TMP_ROOT/present"
expect_fail "없는 파일을 전부 나열한다" "$TMP_ROOT/gone2" \
  check_files_exist "$TMP_ROOT/present" "$TMP_ROOT/gone1" "$TMP_ROOT/gone2"

echo "keystore_path"
r="$(make_repo)"
expect_eq "절대경로는 그대로" "/abs/upload.jks" keystore_path "$r"
printf 'storeFile=../keys/upload.jks\n' > "$r/android/key.properties"
expect_eq "상대경로는 android/app 기준 (Gradle과 같음)" "$r/android/app/../keys/upload.jks" keystore_path "$r"
printf 'keyAlias=cake\n' > "$r/android/key.properties"
expect_fail "storeFile이 없으면 실패" "storeFile" keystore_path "$r"

echo "check_no_mock_api"
r="$(make_repo)"
expect_ok "주석 처리된 mock과 mock import는 통과" check_no_mock_api "$r"
sed -i '' 's|  // getIt|  getIt|' "$r/lib/config/di.dart"
expect_fail "주석이 풀린 mock 등록은 막는다" "MockDiaryApi" check_no_mock_api "$r"

echo "check_clean_tree"
r="$(make_repo)"
expect_ok "깨끗하면 통과" check_clean_tree "$r"
echo "memo" > "$r/notes.txt"
expect_fail "추적 안 되는 파일도 막는다" "notes.txt" check_clean_tree "$r"
rm "$r/notes.txt"
echo "# 변경" >> "$r/pubspec.yaml"
expect_fail "수정된 파일을 막는다" "pubspec.yaml" check_clean_tree "$r"

echo
echo "통과 $passed, 실패 $failed"
[[ $failed -eq 0 ]]
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

Run: `bash scripts/test/preflight_test.sh`
Expected: `scripts/lib/preflight.sh: No such file or directory`로 실패

- [ ] **Step 3: 구현**

`scripts/lib/preflight.sh`:

```bash
# shellcheck shell=bash
# 배포 전 로컬 점검. 비밀 값을 읽지 않고, 네트워크에 나가지 않고, 아무것도 바꾸지 않는다.
# scripts/deploy.sh와 scripts/test/preflight_test.sh가 source한다. bash 3.2에서 돈다.

_fail() { printf '❌ %s\n' "$*" >&2; }

# pubspec.yaml의 version을 "이름 번호"로 출력한다. 예: "1.1.0 7"
read_pubspec_version() {
  local root="$1" raw
  # grep | head 대신 awk: 못 찾아도 0으로 끝나서 pipefail 아래에서 조용히 죽지 않는다
  raw="$(awk '/^version:/ { sub(/^version:[[:space:]]*/, ""); sub(/[[:space:]]*(#.*)?$/, ""); print; exit }' "$root/pubspec.yaml")"
  if [[ ! "$raw" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$ ]]; then
    _fail "pubspec.yaml의 version이 '1.2.3+4' 형식이 아니다: '$raw'"
    return 1
  fi
  printf '%s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
}

# 이름으로 받은 환경변수가 모두 비어 있지 않은지 본다
check_env_vars() {
  local missing="" name
  for name in "$@"; do
    [[ -n "${!name:-}" ]] || missing="$missing $name"
  done
  if [[ -n "$missing" ]]; then
    _fail "fastlane.env에 값이 없다:${missing}"
    return 1
  fi
}

# 파일이 모두 있는지 본다. 없는 것을 한 번에 나열한다
check_files_exist() {
  local missing="" path
  for path in "$@"; do
    [[ -f "$path" ]] || missing="$missing
   - $path"
  done
  if [[ -n "$missing" ]]; then
    _fail "파일이 없다:${missing}"
    return 1
  fi
}

# android/key.properties의 storeFile을 절대경로로 출력한다.
# 상대경로는 Gradle의 file()처럼 android/app 기준으로 푼다
keystore_path() {
  local root="$1" store
  store="$(awk '/^storeFile=/ { sub(/^storeFile=/, ""); print; exit }' "$root/android/key.properties")"
  if [[ -z "$store" ]]; then
    _fail "android/key.properties에 storeFile이 없다"
    return 1
  fi
  case "$store" in
    /*) printf '%s\n' "$store" ;;
    *) printf '%s\n' "$root/android/app/$store" ;;
  esac
}

# 주석 처리된 mock 등록이 풀려 있으면 막는다 (CLAUDE.md "함정")
check_no_mock_api() {
  local root="$1" hits
  hits="$(grep -nE '^[[:space:]]*[^/[:space:]].*=>[[:space:]]*Mock' "$root/lib/config/di.dart" || true)"
  if [[ -n "$hits" ]]; then
    _fail "lib/config/di.dart에서 mock 등록이 켜져 있다. 목 데이터로 빌드된다:"
    printf '%s\n' "$hits" >&2
    return 1
  fi
}

# 커밋 안 된 변경과 추적 안 되는 파일이 없는지 본다.
# 올라간 빌드가 정확히 어떤 커밋인지 알아야 승인 뒤 태그를 달 수 있다
check_clean_tree() {
  local root="$1" status
  status="$(git -C "$root" status --porcelain)"
  if [[ -n "$status" ]]; then
    _fail "커밋 안 된 변경이 있다. 커밋하거나 되돌린 뒤 다시 돌려라:"
    printf '%s\n' "$status" >&2
    return 1
  fi
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `bash scripts/test/preflight_test.sh`
Expected: 마지막 줄 `통과 15, 실패 0`, 종료 코드 0

- [ ] **Step 5: Commit**

```bash
git add scripts/lib/preflight.sh scripts/test/preflight_test.sh
git commit -m "feat: 배포 전 로컬 점검 함수를 추가한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: 버전을 pubspec.yaml 하나로 통일

**Files:**
- Modify: `android/app/build.gradle.kts:36-37`
- Modify: `ios/Runner/Info.plist`
- Modify: `pubspec.yaml:4`

**Interfaces:**
- Produces: 빌드된 `.aab`/`.ipa`의 버전이 pubspec `version`과 같다. Task 5의 결과물 확인이 이것을 전제로 한다

- [ ] **Step 1: 지금 상태가 어긋나 있음을 확인 (실패하는 검증)**

Run: `grep -nE '^version:' pubspec.yaml && grep -nE 'versionCode|versionName' android/app/build.gradle.kts`
Expected: pubspec `1.0.0+1`, gradle `6` / `"1.1.0"`. 서로 다르다

- [ ] **Step 2: Gradle이 pubspec을 읽게 한다**

`android/app/build.gradle.kts`에서

```kotlin
        versionCode = 6
        versionName = "1.1.0"
```

를

```kotlin
        versionCode = flutter.versionCode
        versionName = flutter.versionName
```

로 바꾼다.

- [ ] **Step 3: Info.plist가 pubspec을 읽게 한다**

`ios/Runner/Info.plist`에서

```xml
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
```

를

```xml
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
```

로, 그리고

```xml
	<key>CFBundleVersion</key>
	<string>3</string>
```

를

```xml
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
```

로 바꾼다. `plutil -replace`는 파일 전체 서식을 바꾸므로 쓰지 않는다.

- [ ] **Step 4: pubspec 버전을 올린다**

`pubspec.yaml`의 `version: 1.0.0+1`을 `version: 1.1.0+7`로 바꾼다. 두 스토어의 최신 번호(Play 6, TestFlight 3)보다 커야 한다.

- [ ] **Step 5: Android 결과물로 확인**

```bash
flutter build appbundle --release
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab --xpath=/manifest/@android:versionCode
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab --xpath=/manifest/@android:versionName
```

Expected: `7`, `1.1.0`

- [ ] **Step 6: iOS 결과물로 확인**

```bash
flutter build ipa --release
tmp="$(mktemp -d)" && unzip -q -o build/ios/ipa/*.ipa 'Payload/*.app/Info.plist' -d "$tmp"
plutil -extract CFBundleShortVersionString raw "$tmp"/Payload/*.app/Info.plist
plutil -extract CFBundleVersion raw "$tmp"/Payload/*.app/Info.plist
```

Expected: `1.1.0`, `7`. 서명 에러가 나면 Xcode에서 `ios/Runner.xcworkspace`를 열어 Signing & Capabilities 탭이 스스로 갱신되게 한 뒤 다시 돌린다

- [ ] **Step 7: 테스트 확인**

Run: `flutter test`
Expected: 모두 통과

- [ ] **Step 8: Commit**

`flutter build`가 `pubspec.lock`을 건드렸을 수 있지만 커밋하지 않는다 (Global Constraints). `git status`에 위 세 파일과 `pubspec.lock`, `analysis_options.yaml` 말고 다른 변경(예: `ios/Podfile.lock`, `project.pbxproj`)이 보이면 커밋하지 말고 사용자에게 보고한다.

```bash
git add android/app/build.gradle.kts ios/Runner/Info.plist pubspec.yaml
git commit -m "build: 버전을 pubspec.yaml 하나로 통일한다

Android는 build.gradle.kts, iOS는 Info.plist에 버전이 따로 하드코딩되어
있었다. 두 플랫폼 모두 pubspec의 version을 읽게 하고, 두 스토어의 최신
빌드 번호(Play 6, iOS 3)보다 큰 1.1.0+7로 올린다.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: fastlane 설정과 스토어 빌드 번호 조회

**Files:**
- Create: `fastlane/Appfile`, `fastlane/Fastfile`
- Create (저장소 밖): `~/development/keys/fastlane.env`

**Interfaces:**
- Consumes: Task 1의 `bundle exec fastlane`
- Produces:
  - lane `android check_store`, `ios check_store`: pubspec 빌드 번호 ≤ 스토어 최신이면 `UI.user_error!`로 실패. 읽기 전용
  - Fastfile 헬퍼 `pubspec_version` → `[이름(String), 번호(Integer)]`, `ensure_artifact_version!(label, name, number)`, `asc_api_key`, `skip_upload?`, `flutter_build(target)` (Task 5가 씀)
  - 환경변수: `PLAY_JSON_KEY_PATH`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`, `DART_DEFINE_FILES`(콜론 구분, 비어도 됨), `CAKE_SKIP_UPLOAD`(`1`이면 업로드 생략)

- [ ] **Step 1: `fastlane.env` 작성 (저장소 밖)**

`~/development/keys/README.md`의 `cake-asc-api-*.p8` 절에서 키 ID와 Issuer ID를 옮겨 적는다.

`~/development/keys/fastlane.env`:

```
ASC_KEY_ID=<README의 키 ID>
ASC_ISSUER_ID=<README의 Issuer ID>
ASC_KEY_PATH=/Users/seoyun/development/keys/cake-asc-api-<키 ID>.p8
PLAY_JSON_KEY_PATH=/Users/seoyun/development/keys/cake-play-service-account.json
```

Run: `chmod 600 ~/development/keys/fastlane.env`

- [ ] **Step 2: Appfile 작성**

`fastlane/Appfile`:

```ruby
# 공개 정보만 둔다. 비밀 값은 scripts/deploy.sh가 ~/development/keys/fastlane.env에서 읽어 환경변수로 넘긴다
app_identifier("com.momeokji.cake")
package_name("com.momeokji.cake")
team_id("X2Z78T337C")
```

- [ ] **Step 3: Fastfile 작성 (check_store까지)**

`fastlane/Fastfile`:

```ruby
# 조각케이크 배포 lane. scripts/deploy.sh를 거쳐 실행한다.
# 로컬 점검, flutter test, fastlane.env 로드는 deploy.sh가 먼저 한다.
require "fileutils"
require "tmpdir"

opt_out_usage

ROOT = File.expand_path("..", __dir__)
PLAY_TRACKS = %w[internal alpha beta production].freeze

# pubspec.yaml의 version → ["1.1.0", 7]
def pubspec_version
  raw = File.read(File.join(ROOT, "pubspec.yaml"))[/^version:\s*(\S+)/, 1].to_s
  name, number = raw.split("+", 2)
  unless name.to_s.match?(/\A\d+\.\d+\.\d+\z/) && number.to_s.match?(/\A\d+\z/)
    UI.user_error!("pubspec.yaml의 version이 '1.2.3+4' 형식이 아니다: '#{raw}'")
  end
  [name, number.to_i]
end

def ensure_newer_than_store!(store_label, store_latest)
  _, number = pubspec_version
  if number <= store_latest
    UI.user_error!(
      "pubspec 빌드 번호(#{number})가 #{store_label} 최신(#{store_latest})보다 커야 한다. " \
      "pubspec.yaml의 +#{number}를 +#{store_latest + 1} 이상으로 올려 dev에 커밋한 뒤 다시 돌려라"
    )
  end
  UI.success("#{store_label} 최신 #{store_latest} < pubspec #{number}")
end

def ensure_artifact_version!(label, name, number)
  want_name, want_number = pubspec_version
  unless name == want_name && number.to_s == want_number.to_s
    UI.user_error!("#{label}에 들어간 버전(#{name}+#{number})이 pubspec(#{want_name}+#{want_number})과 다르다. 업로드하지 않는다")
  end
  UI.success("#{label} 버전 확인: #{name}+#{number}")
end

def asc_api_key
  app_store_connect_api_key(
    key_id: ENV.fetch("ASC_KEY_ID"),
    issuer_id: ENV.fetch("ASC_ISSUER_ID"),
    key_filepath: ENV.fetch("ASC_KEY_PATH")
  )
end

def skip_upload?
  ENV["CAKE_SKIP_UPLOAD"] == "1"
end

def flutter_build(target)
  defines = ENV.fetch("DART_DEFINE_FILES", "").split(":").reject(&:empty?)
  args = ["flutter", "build", target, "--release"] + defines.map { |f| "--dart-define-from-file=#{f}" }
  Dir.chdir(ROOT) { sh(*args) }
end

platform :android do
  desc "Play의 모든 트랙에서 가장 큰 versionCode보다 pubspec 번호가 큰지 본다 (읽기 전용)"
  lane :check_store do
    codes = PLAY_TRACKS.flat_map do |track|
      google_play_track_version_codes(track: track, json_key: ENV.fetch("PLAY_JSON_KEY_PATH"))
    rescue StandardError => e
      UI.important("#{track} 트랙 조회 실패 (한 번도 안 쓴 트랙이면 정상): #{e.message}")
      []
    end
    if codes.empty?
      UI.user_error!("Play의 어느 트랙도 조회하지 못했다. 서비스 계정 권한을 확인해라 (막 초대했다면 반영까지 최대 하루)")
    end
    ensure_newer_than_store!("Play", codes.max)
  end
end

platform :ios do
  desc "TestFlight 최신 빌드 번호보다 pubspec 번호가 큰지 본다 (읽기 전용)"
  lane :check_store do
    latest = latest_testflight_build_number(api_key: asc_api_key, initial_build_number: 0)
    ensure_newer_than_store!("TestFlight", latest.to_i)
  end
end
```

- [ ] **Step 4: 읽기 전용 조회로 확인**

```bash
set -a; source ~/development/keys/fastlane.env; set +a
bundle exec fastlane android check_store
bundle exec fastlane ios check_store
```

Expected: 각각 `Play 최신 6 < pubspec 7`, `TestFlight 최신 3 < pubspec 7`. Play가 권한 에러면 서비스 계정 초대(2026-09-25)가 아직 반영되지 않은 것일 수 있다. 사용자에게 알리고 기다린다. 여기서 코드를 고치지 않는다

- [ ] **Step 5: 실패 경로 확인**

`pubspec.yaml`을 임시로 `version: 1.1.0+6`으로 바꾸고 `bundle exec fastlane android check_store`를 돌린다.
Expected: `pubspec 빌드 번호(6)가 Play 최신(6)보다 커야 한다`로 실패. 확인 후 `git checkout pubspec.yaml`로 되돌린다

- [ ] **Step 6: Commit**

```bash
git add fastlane/Appfile fastlane/Fastfile
git commit -m "feat: 스토어 빌드 번호를 조회하는 fastlane lane을 추가한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: 빌드·결과물 확인·업로드 lane

**Files:**
- Modify: `fastlane/Fastfile`

**Interfaces:**
- Consumes: Task 4의 `flutter_build`, `ensure_artifact_version!`, `asc_api_key`, `skip_upload?`
- Produces: lane `android deploy`, `ios deploy`. 빌드 번호 조회는 하지 않는다 (deploy.sh가 먼저 `check_store`를 부른다)

- [ ] **Step 1: android deploy lane 추가**

`platform :android do` 블록 안, `check_store` 아래에 추가:

```ruby
  desc "AAB를 빌드하고, 들어간 버전을 확인하고, 내부 테스트 트랙에 올린다"
  lane :deploy do
    flutter_build("appbundle")
    aab = File.join(ROOT, "build/app/outputs/bundle/release/app-release.aab")
    read = ->(attr) { sh("bundletool", "dump", "manifest", "--bundle=#{aab}", "--xpath=/manifest/@android:#{attr}", log: false).strip }
    ensure_artifact_version!("AAB", read.call("versionName"), read.call("versionCode"))
    next UI.important("CAKE_SKIP_UPLOAD=1: 업로드하지 않는다") if skip_upload?

    upload_to_play_store(
      json_key: ENV.fetch("PLAY_JSON_KEY_PATH"),
      track: "internal",
      aab: aab,
      skip_upload_apk: true,
      skip_upload_metadata: true,
      skip_upload_changelogs: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
```

- [ ] **Step 2: ios deploy lane 추가**

`platform :ios do` 블록 안, `check_store` 아래에 추가:

```ruby
  desc "IPA를 빌드하고, 들어간 버전을 확인하고, TestFlight에 올린다"
  lane :deploy do
    ipa_dir = File.join(ROOT, "build/ios/ipa")
    FileUtils.rm_rf(ipa_dir) # 예전 빌드의 .ipa를 집어 들지 않게
    flutter_build("ipa")
    ipa = Dir[File.join(ipa_dir, "*.ipa")].first
    UI.user_error!("#{ipa_dir}에 .ipa가 없다") unless ipa

    Dir.mktmpdir do |dir|
      sh("unzip", "-q", "-o", ipa, "Payload/*.app/Info.plist", "-d", dir, log: false)
      plist = Dir[File.join(dir, "Payload/*.app/Info.plist")].first
      read = ->(key) { sh("plutil", "-extract", key, "raw", plist, log: false).strip }
      ensure_artifact_version!("IPA", read.call("CFBundleShortVersionString"), read.call("CFBundleVersion"))
    end
    next UI.important("CAKE_SKIP_UPLOAD=1: 업로드하지 않는다") if skip_upload?

    upload_to_testflight(
      api_key: asc_api_key,
      ipa: ipa,
      skip_waiting_for_build_processing: true
    )
  end
```

- [ ] **Step 3: 업로드 없이 Android 확인**

```bash
set -a; source ~/development/keys/fastlane.env; set +a
CAKE_SKIP_UPLOAD=1 bundle exec fastlane android deploy
```

Expected: `AAB 버전 확인: 1.1.0+7`, `CAKE_SKIP_UPLOAD=1: 업로드하지 않는다`, `fastlane.tools finished successfully`

- [ ] **Step 4: 업로드 없이 iOS 확인**

Run: `CAKE_SKIP_UPLOAD=1 bundle exec fastlane ios deploy` (Step 3과 같은 셸)
Expected: `IPA 버전 확인: 1.1.0+7`, 업로드 생략, 성공

- [ ] **Step 5: 결과물 확인이 실제로 막는지 확인**

`fastlane/Fastfile`의 `ensure_artifact_version!("AAB", ...)` 호출에서 `read.call("versionCode")`를 임시로 `"999"`로 바꾸고 Step 3을 다시 돌린다.
Expected: `AAB에 들어간 버전(1.1.0+999)이 pubspec(1.1.0+7)과 다르다`로 실패. 확인 후 `git checkout fastlane/Fastfile`로 되돌린다

- [ ] **Step 6: Commit**

```bash
git add fastlane/Fastfile
git commit -m "feat: 빌드하고 결과물 버전을 확인한 뒤 업로드하는 lane을 추가한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: deploy.sh 입구

**Files:**
- Create: `scripts/deploy.sh`
- Test: `scripts/test/preflight_test.sh` (deploy.sh 절 추가)

**Interfaces:**
- Consumes: Task 2의 preflight 함수 전부, Task 4·5의 lane `check_store`, `deploy`, 환경변수 계약
- Produces: `./scripts/deploy.sh <android|ios|all> [--check-only|--build-only]`. 종료 코드: 성공 0, 점검·빌드·업로드 실패 1, 잘못된 인자 2

- [ ] **Step 1: 실패하는 테스트 추가**

`scripts/test/preflight_test.sh`에서 마지막의 `echo` / `echo "통과 ..."` 두 줄 **바로 앞에** 추가:

```bash
echo "deploy.sh"
expect_ok "--help는 사용법을 보여준다" "$REPO/scripts/deploy.sh" --help
expect_fail "인자가 없으면 사용법과 함께 실패" "사용법" "$REPO/scripts/deploy.sh"
expect_fail "모르는 플랫폼은 거절" "사용법" "$REPO/scripts/deploy.sh" windows
empty_keys="$(mktemp -d "$TMP_ROOT/keys.XXXXXX")"
expect_fail "fastlane.env가 없으면 네트워크 전에 멈춘다" "$empty_keys/fastlane.env" \
  env CAKE_KEYS_DIR="$empty_keys" "$REPO/scripts/deploy.sh" android --check-only
expect_fail "다른 폴더에서 실행해도 같은 점검을 한다" "$empty_keys/fastlane.env" \
  bash -c "cd '$REPO/scripts' && CAKE_KEYS_DIR='$empty_keys' ./deploy.sh android --check-only"
expect_fail "잘못된 인자의 종료 코드는 2" "exit=2" \
  bash -c "'$REPO/scripts/deploy.sh' windows >/dev/null 2>&1; echo exit=\$?; exit 1"
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

Run: `bash scripts/test/preflight_test.sh`
Expected: `deploy.sh` 절의 항목이 모두 `FAIL` (파일 없음)

- [ ] **Step 3: 구현**

`scripts/deploy.sh`:

```bash
#!/bin/bash
# 조각케이크 배포: 점검 → 테스트 → 빌드 → 결과물 확인 → 업로드.
# 심사 제출, main 머지, 태그는 하지 않는다. 사용법: ./scripts/deploy.sh --help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/preflight.sh
source "$ROOT/scripts/lib/preflight.sh"

KEYS_DIR="${CAKE_KEYS_DIR:-$HOME/development/keys}"
ENV_FILE="$KEYS_DIR/fastlane.env"

# 빌드 때 --dart-define-from-file로 넘길 비밀 파일. 깃 밖(KEYS_DIR)에 둔다.
# 점검과 빌드 인자가 모두 이 목록을 읽는다. 예: "$KEYS_DIR/cake-social-login.json"
BUILD_SECRET_FILES=()

usage() {
  cat <<'EOF'
사용법: ./scripts/deploy.sh <android|ios|all> [--check-only | --build-only]

  android       Play 내부 테스트 트랙에 올린다
  ios           TestFlight에 올린다
  all           android를 끝낸 뒤 ios. 앞이 실패하면 뒤는 돌지 않는다

  --check-only  점검만 한다 (파일, mock, 작업 트리, 스토어 빌드 번호)
  --build-only  업로드 직전까지만 한다 (점검, 테스트, 빌드, 결과물 확인)

심사 제출, main 머지, 태그는 하지 않는다. 스토어 승인 뒤 직접 한다.
비밀 파일 위치: $CAKE_KEYS_DIR (기본값 ~/development/keys, 설명은 그 안의 README.md)
EOF
}

step() { printf '\n▶ %s\n' "$*"; }

platforms=""
mode="deploy"
for arg in "$@"; do
  case "$arg" in
    android | ios) platforms="$arg" ;;
    all) platforms="android ios" ;;
    --check-only) mode="check" ;;
    --build-only) mode="build" ;;
    -h | --help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[[ -n "$platforms" ]] || { usage >&2; exit 2; }

step "점검"
check_files_exist "$ENV_FILE" || { echo "   → $KEYS_DIR/README.md를 보고 만든다" >&2; exit 1; }
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

for platform in $platforms; do
  case "$platform" in
    android)
      check_env_vars PLAY_JSON_KEY_PATH
      check_files_exist "$ROOT/android/key.properties"
      keystore="$(keystore_path "$ROOT")"
      check_files_exist "$PLAY_JSON_KEY_PATH" "$keystore"
      ;;
    ios)
      check_env_vars ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_PATH
      check_files_exist "$ASC_KEY_PATH"
      ;;
  esac
done
if [[ ${#BUILD_SECRET_FILES[@]} -gt 0 ]]; then
  check_files_exist "${BUILD_SECRET_FILES[@]}"
fi
check_no_mock_api "$ROOT"
check_clean_tree "$ROOT"
version="$(read_pubspec_version "$ROOT")"
read -r version_name build_number <<<"$version"
commit="$(git -C "$ROOT" rev-parse --short HEAD)"
# head 대신 sed: head가 먼저 닫으면 flutter가 SIGPIPE로 죽고 pipefail이 스크립트를 끝낸다
echo "버전 $version_name+$build_number · 커밋 $commit · $(flutter --version 2>/dev/null | sed -n 1p)"

cd "$ROOT"
for platform in $platforms; do
  bundle exec fastlane "$platform" check_store
done

if [[ "$mode" == "check" ]]; then
  echo
  echo "✅ 점검 통과. 빌드와 업로드는 하지 않았다"
  exit 0
fi

step "테스트"
flutter test

if [[ ${#BUILD_SECRET_FILES[@]} -gt 0 ]]; then
  DART_DEFINE_FILES="$(IFS=:; echo "${BUILD_SECRET_FILES[*]}")"
  export DART_DEFINE_FILES
fi
[[ "$mode" == "build" ]] && export CAKE_SKIP_UPLOAD=1

for platform in $platforms; do
  step "$platform 빌드·확인·업로드"
  bundle exec fastlane "$platform" deploy
done

echo
if [[ "$mode" == "build" ]]; then
  echo "✅ 빌드 완료: $version_name+$build_number (커밋 $commit). 업로드는 하지 않았다"
  exit 0
fi
echo "✅ 업로드 완료: $version_name+$build_number (커밋 $commit)"
echo
echo "다음 할 일"
echo "  1. 콘솔에서 심사 제출"
echo "     Play: 내부 테스트 트랙의 이 빌드를 프로덕션으로 승격"
echo "     iOS: App Store Connect에서 새 버전에 이 빌드를 붙여 제출"
echo "  2. 승인이 나면 (거절되면 dev에서 고치고 빌드 번호를 올려 다시 돌린다)"
echo "     git switch main && git merge --ff-only $commit"
for platform in $platforms; do
  echo "     git tag $platform/v$version_name $commit    # 같은 versionName 재업로드면 $platform/v$version_name+$build_number"
done
```

Run: `chmod +x scripts/deploy.sh`

- [ ] **Step 4: 테스트 통과 확인**

Run: `bash scripts/test/preflight_test.sh`
Expected: `통과 21, 실패 0`

- [ ] **Step 5: 실제 저장소에서 점검만 돌려보기**

Run: `./scripts/deploy.sh all --check-only`
Expected: 작업 시작 전부터 있던 `analysis_options.yaml`, `pubspec.lock` 변경 때문에 `커밋 안 된 변경이 있다`로 멈춘다. 이게 맞는 동작이다. 두 파일을 커밋하거나 되돌리지 **않는다**. 그건 사용자가 정한다. `git stash`로 잠깐 치운 뒤 다시 돌려 `✅ 점검 통과`까지 확인하고 `git stash pop`으로 되돌려도 된다

- [ ] **Step 6: Commit**

```bash
git add scripts/deploy.sh scripts/test/preflight_test.sh
git commit -m "feat: 명령 한 번으로 배포하는 deploy.sh를 추가한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: 문서

**Files:**
- Modify: `CLAUDE.md`
- Modify (저장소 밖): `~/development/keys/README.md`

- [ ] **Step 1: CLAUDE.md "명령어" 절에 추가**

` ```bash ` 블록 안 `dart run build_runner ...` 줄 아래에 추가:

```bash
./scripts/deploy.sh android          # Play 내부 테스트 트랙에 업로드 (ios / all)
./scripts/deploy.sh all --check-only # 빌드 없이 점검만
bash scripts/test/preflight_test.sh  # 배포 스크립트 테스트
```

블록 아래에 추가:

```markdown
배포 스크립트는 rbenv Ruby(`.ruby-version`)와 `bundletool`이 필요하다. 새 맥에서는
`brew install rbenv ruby-build bundletool && rbenv install && bundle install`, 그리고
`~/development/keys/`를 다른 맥에서 에어드랍으로 받아 같은 경로에 둔다.
```

- [ ] **Step 2: CLAUDE.md "릴리즈" 절 1번을 고친다**

```markdown
1. 버전 커밋(`android/app/build.gradle.kts`의 versionCode/versionName)을 `dev`에 푸시한다
```

를

```markdown
1. `pubspec.yaml`의 `version`을 올린 커밋을 `dev`에 푸시하고 `./scripts/deploy.sh all`을 돌린다. 빌드 번호(`+N`)는 두 플랫폼이 같이 쓰며, 두 스토어의 최신 번호보다 커야 한다. 심사 제출은 콘솔에서 직접 한다
```

로 바꾼다.

- [ ] **Step 3: CLAUDE.md "함정" 절 끝에 추가**

```markdown
- **Xcode에서 바로 Archive하지 않는다.** 버전은 `flutter build`가 `pubspec.yaml`에서 `ios/Flutter/Generated.xcconfig`로 복사할 때 들어간다. Xcode Archive만 하면 예전 번호가 들어간다. 꼭 해야 하면 먼저 `flutter build ipa`를 돌린다
- **배포 키는 저장소 밖 `~/development/keys/`에 있다.** 무엇이 어디 쓰이는지는 그 폴더의 `README.md`. 키 ID·Issuer ID도 저장소에 적지 않는다
```

- [ ] **Step 4: 키 폴더 README의 `fastlane.env` 절 보강 (저장소 밖)**

`~/development/keys/README.md`의 `## fastlane.env` 절을 다음으로 바꾼다:

```markdown
## fastlane.env
- 용도: `scripts/deploy.sh`가 읽어 fastlane에 넘기는 설정값
- 들어 있는 값: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`, `PLAY_JSON_KEY_PATH`
- 새 맥에서: 이 폴더를 통째로 에어드랍하면 된다. 경로가 절대경로라 홈 경로(`/Users/seoyun`)가 같아야 한다
- 확인: 저장소에서 `./scripts/deploy.sh all --check-only`
```

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: 배포 스크립트 사용법과 버전 관리 변경을 CLAUDE.md에 반영한다

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: 첫 실제 배포 (사용자와 함께)

**에이전트 혼자 진행하지 않는다.** 각 단계는 사용자가 확인한 뒤에 한다.

**전제 조건:**
- `analysis_options.yaml`, `pubspec.lock`의 미커밋 변경을 사용자가 처리했다
- `feature/fastlane-deploy`가 `dev`에 머지됐다 (배포는 `dev`의 커밋으로 한다)

- [ ] **Step 1: 점검**

Run: `./scripts/deploy.sh all --check-only`
Expected: `✅ 점검 통과`

- [ ] **Step 2: 업로드 없이 끝까지**

Run: `./scripts/deploy.sh all --build-only`
Expected: `AAB 버전 확인: 1.1.0+7`, `IPA 버전 확인: 1.1.0+7`, `✅ 빌드 완료`

- [ ] **Step 3: 사용자 확인 후 실제 업로드**

Run: `./scripts/deploy.sh all`
Expected: `✅ 업로드 완료`와 다음 할 일 안내

- [ ] **Step 4: 콘솔에서 눈으로 확인**
  - Play Console → 테스트 → 내부 테스트에 `7 (1.1.0)`이 있다
  - App Store Connect → TestFlight에 `1.1.0 (7)`이 처리 중이거나 완료됐다

- [ ] **Step 5: 맥북에서 점검**

맥북에 `~/development/keys/`를 에어드랍하고, 저장소를 pull한 뒤 Task 7 Step 1의 설치 명령을 돌리고 `./scripts/deploy.sh all --check-only`.
Expected: `✅ 점검 통과`. 빠진 파일이 있으면 그 이름이 나온다
