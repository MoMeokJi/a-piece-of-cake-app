#!/bin/bash
# 조각케이크 배포: 점검 → 테스트 → 빌드 → 결과물 확인 → 업로드.
# 심사 제출, main 머지, 태그는 하지 않는다. 사용법: ./scripts/deploy.sh --help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/preflight.sh
source "$ROOT/scripts/lib/preflight.sh"

# 셸에 rbenv 초기화가 없어도(새 맥 등) .ruby-version의 Ruby와 그 fastlane을 쓰게 한다
if [[ -d "$HOME/.rbenv/shims" ]]; then
  export PATH="$HOME/.rbenv/shims:$PATH"
fi

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
check_pushed_to_dev "$ROOT"
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

uploaded=""
remaining="$platforms"
for platform in $platforms; do
  step "$platform 빌드·확인·업로드"
  if ! bundle exec fastlane "$platform" deploy; then
    echo >&2
    _fail "$platform 단계에서 멈췄다"
    if [[ -n "$uploaded" ]]; then
      echo "   이미 올라간 플랫폼:$uploaded (커밋 $commit)" >&2
      echo "   전체를 다시 돌리면 빌드 번호가 겹쳐 막힌다. 남은 것만 돌려라: ./scripts/deploy.sh $remaining" >&2
    fi
    exit 1
  fi
  remaining="${remaining#"$platform"}"
  remaining="${remaining# }"
  if [[ "$mode" == "build" ]]; then
    echo "✅ $platform 빌드 완료: $version_name+$build_number (커밋 $commit). 업로드는 하지 않았다"
  else
    uploaded="$uploaded $platform"
    echo "✅ $platform 업로드 완료: $version_name+$build_number (커밋 $commit)"
  fi
done

[[ "$mode" == "build" ]] && exit 0

echo
echo "다음 할 일"
echo "  1. 콘솔에서 심사 제출"
echo "     Play: 내부 테스트 트랙의 이 빌드를 프로덕션으로 승격"
echo "     iOS: App Store Connect에서 새 버전에 이 빌드를 붙여 제출"
echo "  2. 승인이 나면 (거절되면 dev에서 고치고 빌드 번호를 올려 다시 돌린다)"
echo "     git switch main && git pull --ff-only && git merge --ff-only $commit"
for platform in $platforms; do
  echo "     git tag $platform/v$version_name $commit    # 같은 versionName 재업로드면 $platform/v$version_name+$build_number"
done
