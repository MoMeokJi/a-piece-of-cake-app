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

echo "check_pushed_to_dev"
# origin(bare)의 dev에 푸시까지 된 저장소를 만들어 경로를 출력한다
make_pushed_repo() {
  local d remote
  d="$(make_repo)"
  remote="$(mktemp -d "$TMP_ROOT/remote.XXXXXX")"
  git init -q --bare "$remote"
  git -C "$d" remote add origin "$remote"
  git -C "$d" push -q origin HEAD:dev
  echo "$d"
}
r="$(make_pushed_repo)"
expect_ok "origin/dev에 있는 커밋은 통과" check_pushed_to_dev "$r"
git -C "$r" -c user.name=t -c user.email=t@t commit -q --allow-empty -m local
expect_fail "푸시 안 된 커밋은 막는다" "origin/dev에 없다" check_pushed_to_dev "$r"

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


echo "deploy.sh 전체 흐름 (가짜 flutter/bundle)"
FAKE_BIN="$TMP_ROOT/bin"
mkdir -p "$FAKE_BIN" "$TMP_ROOT/home"
cat > "$FAKE_BIN/flutter" <<'EOF'
#!/bin/bash
[[ "${1:-}" == "--version" ]] && echo "Flutter 0.0.0 (가짜)"
exit 0
EOF
cat > "$FAKE_BIN/bundle" <<'EOF'
#!/bin/bash
# bundle exec fastlane <platform> <lane>. FAKE_FAIL="ios deploy"처럼 주면 그 lane만 실패한다
if [[ "$3 $4" == "${FAKE_FAIL:-}" ]]; then echo "가짜 fastlane 실패: $3 $4"; exit 1; fi
echo "가짜 fastlane: $3 $4"
EOF
chmod +x "$FAKE_BIN/flutter" "$FAKE_BIN/bundle"

# scripts/와 키 파일까지 갖추고 origin/dev에 푸시된 저장소
make_deploy_repo() {
  local d keys
  d="$(make_pushed_repo)"
  keys="$d.keys"
  mkdir -p "$keys" "$d/scripts/lib"
  cp "$REPO/scripts/deploy.sh" "$d/scripts/"
  cp "$REPO/scripts/lib/preflight.sh" "$d/scripts/lib/"
  touch "$keys/upload.jks" "$keys/play.json" "$keys/asc.p8"
  printf 'storeFile=%s\n' "$keys/upload.jks" > "$d/android/key.properties"
  printf 'PLAY_JSON_KEY_PATH=%s\nASC_KEY_ID=K\nASC_ISSUER_ID=I\nASC_KEY_PATH=%s\n' "$keys/play.json" "$keys/asc.p8" > "$keys/fastlane.env"
  git -C "$d" add -A
  git -C "$d" -c user.name=t -c user.email=t@t commit -q -m scripts
  git -C "$d" push -q origin HEAD:dev
  echo "$d"
}

# 사용법: run_deploy <저장소> <FAKE_FAIL 값> deploy.sh 인자...
run_deploy() {
  local d="$1" fail="$2"; shift 2
  env HOME="$TMP_ROOT/home" PATH="$FAKE_BIN:$PATH" CAKE_KEYS_DIR="$d.keys" FAKE_FAIL="$fail" "$d/scripts/deploy.sh" "$@"
}

count_uploads() { run_deploy "$@" 2>&1 | grep -c "업로드 완료"; }

r="$(make_deploy_repo)"
expect_ok "all은 두 플랫폼을 모두 올린다" run_deploy "$r" "" all
expect_eq "플랫폼마다 완료를 알린다" "2" count_uploads "$r" "" all
expect_fail "iOS가 실패하면 이미 올라간 플랫폼을 알려준다" "이미 올라간 플랫폼: android" run_deploy "$r" "ios deploy" all
expect_fail "iOS가 실패하면 남은 것만 다시 돌리는 명령을 알려준다" "./scripts/deploy.sh ios" run_deploy "$r" "ios deploy" all
git -C "$r" -c user.name=t -c user.email=t@t commit -q --allow-empty -m local
expect_fail "푸시 안 된 커밋이면 배포하지 않는다" "origin/dev에 없다" run_deploy "$r" "" android --check-only
echo
echo "통과 $passed, 실패 $failed"
[[ $failed -eq 0 ]]
