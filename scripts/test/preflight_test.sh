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

echo
echo "통과 $passed, 실패 $failed"
[[ $failed -eq 0 ]]
