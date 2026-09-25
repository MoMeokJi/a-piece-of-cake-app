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

# 지금 커밋이 origin/dev에 푸시되어 있는지 본다 (CLAUDE.md 릴리즈 1번).
# 승인 뒤 main에 fast-forward할 커밋이 dev에 있어야 한다
check_pushed_to_dev() {
  local root="$1"
  if ! git -C "$root" fetch -q origin dev; then
    _fail "origin/dev를 가져오지 못했다. 네트워크를 확인해라"
    return 1
  fi
  if ! git -C "$root" merge-base --is-ancestor HEAD origin/dev; then
    _fail "지금 커밋($(git -C "$root" rev-parse --short HEAD))이 origin/dev에 없다. dev에 푸시한 커밋으로 배포한다"
    return 1
  fi
}
