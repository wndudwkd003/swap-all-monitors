#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UUID='swapall@local'
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions/$UUID"

if [[ ${EUID} -eq 0 ]]; then
    echo 'sudo 없이 일반 사용자로 실행하세요.' >&2
    exit 1
fi

for tool in gnome-shell gnome-extensions glib-compile-schemas gsettings; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "필수 명령을 찾을 수 없습니다: $tool" >&2
        exit 1
    fi
done

shell_version="$(gnome-shell --version)"
if [[ ! "$shell_version" =~ (^|[[:space:]])42([.]|$) ]]; then
    echo "이 확장은 GNOME Shell 42용입니다. 현재 버전: $shell_version" >&2
    exit 1
fi

# 설치 전에 임시 폴더에서 스키마를 검사하고 컴파일합니다.
STAGING="$(mktemp -d)"
trap 'rm -rf -- "$STAGING"' EXIT
cp -R -- "$SCRIPT_DIR/extension/." "$STAGING/"
glib-compile-schemas --strict "$STAGING/schemas"

if [[ -e "$DEST" ]]; then
    BACKUP="$(mktemp -d "${DEST}.backup.XXXXXXXX")"
    cp -a -- "$DEST/." "$BACKUP/"
    echo "기존 확장 백업: $BACKUP"
fi

mkdir -p -- "$DEST"
cp -R -- "$STAGING/." "$DEST/"
echo "설치 완료: $DEST"

# 새 확장을 현재 Shell이 아직 인식하지 못해도 다음 로그인에 로드하도록 저장합니다.
# 기존에 활성화된 다른 확장 목록은 유지합니다.
enabled_extensions="$(gsettings get org.gnome.shell enabled-extensions)"
if [[ "$enabled_extensions" != *"'$UUID'"* ]]; then
    case "$enabled_extensions" in
        '[]'|'@as []') enabled_extensions="['$UUID']" ;;
        *) enabled_extensions="${enabled_extensions%]}, '$UUID']" ;;
    esac
    gsettings set org.gnome.shell enabled-extensions "$enabled_extensions"
fi

# 사용자 확장 전체가 꺼져 있으면 자동 시작도 막히므로 다시 켭니다.
gsettings set org.gnome.shell disable-user-extensions false
echo '로그인 시 자동 활성화 설정을 저장했습니다. 재부팅 후에도 유지됩니다.'
echo 'GNOME 사용자 확장 기능도 켰습니다. 기존 활성화 목록의 다른 확장도 실행될 수 있습니다.'

if gnome-extensions enable "$UUID"; then
    echo '확장 활성화를 요청했습니다.'
else
    echo '현재 세션에서는 아직 확장을 불러올 수 없습니다. 로그아웃 후 다시 로그인하면 자동 활성화됩니다.'
fi
echo '새 설치 또는 업데이트 후에는 로그아웃 후 다시 로그인하세요.'
echo '사용 단축키: Super(윈도우 키) + Shift + S'
