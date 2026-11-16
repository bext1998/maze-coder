#!/usr/bin/env bash
# 把 skills/ 底下的技能以 symlink 安裝到各 host 原生的技能目錄。
#
# 腳本只做兩件事：建立新的 symlink，或替換既有的 symlink。它**永遠不刪除實體目錄
# 或檔案**——目標若已存在且不是 symlink，一律視為衝突並在使用者自行處理前停下。
#
# 只建立真正的 symlink，不提供複製模式：複製在 Windows 上會出現「目的地已存在時
# 塞成巢狀目錄、之後只覆蓋 SKILL.md」的損毀（見 PR #39／#41），而且 git pull 後
# 不會同步。MSYS=winsymlinks:nativestrict 強制 ln -s 建立真 NTFS symlink；建完
# 再用 test -L 驗證，失敗就直接報錯，不留一份看起來正常、實際上是死的複製品。
#
# 安全前提：
#   1. 位置參數只接受 skills/ 直接子目錄的精確名稱，目標永遠是安裝目錄的直接子項。
#   2. 安裝目錄的實體路徑不得與 skills/ 相同、也不得互相包含（MINGW／MSYS／
#      Cygwin 下比對前轉小寫，因為 NTFS 不分大小寫）。
#   3. 目標是實體目錄或檔案時整批停下，不做任何搬移、備份或刪除。
#   4. 替換 symlink 用暫存連結加 mv -T 原子換上；失敗時原本的連結不動。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_DIR}/skills"

usage() {
  echo "用法：bash scripts/install-skills.sh --host <host> [--scope user|project] [skill-name ...]" >&2
  echo "  --host   claude | codex | cursor | pi | opencode | agents（必填）" >&2
  echo "  --scope  user（預設）或 project（相對於目前工作目錄）" >&2
  echo "  未給技能名稱時安裝 skills/ 底下全部技能" >&2
  echo "  既有實體目錄或檔案不會被刪除；請先自行搬走或刪除（見 README「從舊版遷移」）" >&2
}

die() {
  echo "ERROR: $1" >&2
  shift
  while [ "$#" -gt 0 ]; do
    echo "       $1" >&2
    shift
  done
  exit 1
}

HOST=""
SCOPE="user"
REQUESTED=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --host)
      [ "$#" -ge 2 ] || { usage; exit 1; }
      HOST="$2"
      shift 2
      ;;
    --host=*)
      HOST="${1#--host=}"
      shift
      ;;
    --scope)
      [ "$#" -ge 2 ] || { usage; exit 1; }
      SCOPE="$2"
      shift 2
      ;;
    --scope=*)
      SCOPE="${1#--scope=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: 未知參數 $1" >&2
      usage
      exit 1
      ;;
    *)
      REQUESTED+=("$1")
      shift
      ;;
  esac
done

[ -n "${HOST}" ] || { usage; exit 1; }

case "${SCOPE}" in
  user|project) ;;
  *) die "--scope 只接受 user 或 project，收到 ${SCOPE}" ;;
esac

case "${HOST}" in
  claude) user_dir="${HOME}/.claude/skills"   project_dir=".claude/skills" ;;
  codex)  user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  cursor) user_dir="${HOME}/.cursor/skills"   project_dir=".cursor/skills" ;;
  pi)     user_dir="${HOME}/.pi/agent/skills" project_dir=".pi/skills" ;;
  opencode) user_dir="${HOME}/.config/opencode/skills" project_dir=".opencode/skills" ;;
  agents) user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  *)
    die "不支援的 --host ${HOST}（可用：claude、codex、cursor、pi、opencode、agents）"
    ;;
esac

if [ "${SCOPE}" = "user" ]; then
  DEST_ROOT="${user_dir}"
else
  DEST_ROOT="${PWD}/${project_dir}"
fi

# Windows 上強制 ln -s 建立真正的 symlink，而不是靜默複製整份目錄；其他平台上這個
# 環境變數無作用，可安全設定。
export MSYS=winsymlinks:nativestrict

[ -d "${SKILLS_DIR}" ] || die "找不到 ${SKILLS_DIR}"

# canon 用 `cd -P && pwd` 取代 `readlink -f`：後者不是所有平台都支援 -f。回傳非零
# 代表無法解析（目錄不存在、broken symlink 等）。
canon() {
  (cd -P "$1" 2>/dev/null && pwd)
}

shopt -s nullglob
all_dirs=("${SKILLS_DIR}"/*/)
shopt -u nullglob
[ "${#all_dirs[@]}" -gt 0 ] || die "${SKILLS_DIR} 底下沒有任何技能目錄"

AVAILABLE=()
for dir in "${all_dirs[@]}"; do
  AVAILABLE+=("$(basename "${dir}")")
done

is_available() {
  local candidate="$1" name
  for name in "${AVAILABLE[@]}"; do
    if [ "${name}" = "${candidate}" ]; then
      return 0
    fi
  done
  return 1
}

# --- 先驗證所有名稱，任何一個不合法就完全不動任何目錄 ---
selected=()
if [ "${#REQUESTED[@]}" -eq 0 ]; then
  selected=("${AVAILABLE[@]}")
else
  for name in "${REQUESTED[@]}"; do
    case "${name}" in
      ""|.|..|*/*)
        die "技能名稱不合法：'${name}'" "位置參數只接受 skills/ 直接子目錄的精確名稱（不可含 / . ..）"
        ;;
    esac
    case "${name}" in
      *[!A-Za-z0-9._-]*) die "技能名稱含不允許的字元：${name}" ;;
    esac
    is_available "${name}" \
      || die "找不到技能 ${name}（可用技能：$(printf '%s ' "${AVAILABLE[@]}")）"
    selected+=("${name}")
  done
fi

# --- 路徑安全檢查：目標永遠只能是 DEST_ROOT 的直接子項 ---
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  case "${target}" in
    "${DEST_ROOT}/"*) ;;
    *) die "目標路徑異常：${target}" ;;
  esac
  case "${target#"${DEST_ROOT}/"}" in
    */*|.|..) die "目標路徑異常：${target}" ;;
  esac
done

# --- 安裝目錄與來源目錄不得重疊（用實體路徑判斷；MINGW 下轉小寫比對） ---
# mkdir -p 是為了能 `cd -P` 取實體路徑；若最後判定重疊，只把本次新建的空目錄收回去。
created_dirs=()
probe="${DEST_ROOT}"
while [ ! -d "${probe}" ]; do
  created_dirs+=("${probe}")
  parent="$(dirname "${probe}")"
  case "${parent}" in ""|"${probe}"|"/") break ;; esac
  probe="${parent}"
done
mkdir -p "${DEST_ROOT}" || die "無法建立安裝目錄 ${DEST_ROOT}"

remove_created_dirs() {
  local i
  for ((i = ${#created_dirs[@]} - 1; i >= 0; i--)); do
    rmdir "${created_dirs[$i]}" 2>/dev/null || true
  done
}

DEST_REAL="$(cd -P "${DEST_ROOT}" 2>/dev/null && pwd -P)" || die "無法解析安裝目錄 ${DEST_ROOT}"
SKILLS_REAL="$(cd -P "${SKILLS_DIR}" 2>/dev/null && pwd -P)" || die "無法解析來源目錄 ${SKILLS_DIR}"

case "$(uname -s 2>/dev/null || echo unknown)" in
  MINGW*|MSYS*|CYGWIN*)
    DEST_REAL="$(printf '%s' "${DEST_REAL}" | tr 'A-Z' 'a-z')"
    SKILLS_REAL="$(printf '%s' "${SKILLS_REAL}" | tr 'A-Z' 'a-z')"
    ;;
esac

if [ "${DEST_REAL}" = "${SKILLS_REAL}" ]; then
  remove_created_dirs
  die "安裝目錄就是技能來源：${DEST_REAL}" "這會讓安裝產物覆蓋 repo 的 skills/，本腳本拒絕執行。"
fi
case "${DEST_REAL}" in
  "${SKILLS_REAL}"/*)
    remove_created_dirs
    die "安裝目錄位於技能來源之內：${DEST_REAL}" "本腳本拒絕在 skills/ 底下建立安裝產物。"
    ;;
esac
case "${SKILLS_REAL}" in
  "${DEST_REAL}"/*)
    remove_created_dirs
    die "安裝目錄包含技能來源：${DEST_REAL}" "來源與安裝產物不得互相包含，請改用其他安裝目錄。"
    ;;
esac

# --- 衝突預檢：目標是實體目錄或檔案（含空目錄）就在建立任何連結前停下 ---
# 懸空或指錯位置的 symlink 不算衝突，會被替換。
conflicts=()
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  if [ -L "${target}" ]; then
    continue
  fi
  if [ -e "${target}" ]; then
    conflicts+=("${target}")
  fi
done

if [ "${#conflicts[@]}" -gt 0 ]; then
  {
    echo "ERROR: 下列目標已存在且不是 symlink，本腳本不會刪除或搬移它們："
    printf '       %s\n' "${conflicts[@]}"
    echo "       請確認內容後自行搬走或刪除（舊版安裝請照 README「從舊版遷移」操作），"
    echo "       再重新執行。本次沒有安裝或刪除任何東西。"
  } >&2
  exit 1
fi

# GNU mv 才有 -T；沒有時退回「先 unlink symlink 再 rename」（目標已被預檢保證是
# symlink 或不存在，所以 unlink 只會動到連結本身）。
MV_T_SUPPORTED=0
if mv --help 2>/dev/null | grep -q -- '-T'; then
  MV_T_SUPPORTED=1
fi

replace_link() {
  local staging_link="$1" target="$2" previous="$3"
  if [ "${MV_T_SUPPORTED}" = "1" ]; then
    mv -T "${staging_link}" "${target}"
    return
  fi
  # 沒有 -T 的環境：先把舊連結「搬進」暫存目錄（不是刪除），再放上新的；
  # 失敗就把舊連結搬回原位，使用者原本的連結不會消失。
  if [ -L "${target}" ]; then
    mv "${target}" "${previous}" || return 1
    if mv "${staging_link}" "${target}"; then
      return 0
    fi
    if mv "${previous}" "${target}"; then
      return 1
    fi
    KEEP_STAGING=1
    die "無法把暫存連結換到 ${target}" "還原也失敗：原本的連結仍在 ${previous}，請手動移回。"
  fi
  mv "${staging_link}" "${target}"
}

STAGING_DIR=""
KEEP_STAGING=0
cleanup_staging() {
  if [ "${KEEP_STAGING}" = "1" ]; then
    return 0
  fi
  if [ -n "${STAGING_DIR}" ]; then
    rm -rf "${STAGING_DIR}" 2>/dev/null || true
  fi
  STAGING_DIR=""
}
trap cleanup_staging EXIT

for name in "${selected[@]}"; do
  src="${SKILLS_DIR}/${name}"
  target="${DEST_ROOT}/${name}"
  expected="$(canon "${src}")" || die "無法解析來源路徑 ${src}"

  if [ -L "${target}" ] && [ "$(canon "${target}")" = "${expected}" ]; then
    echo "  [SAME] ${name}"
    continue
  fi

  # 暫存目錄只用來放一個 symlink；裡面不會出現實體檔案或目錄。
  STAGING_DIR="$(mktemp -d "${DEST_ROOT}/.install-staging.XXXXXX")" \
    || die "無法在 ${DEST_ROOT} 建立暫存目錄"
  staging_link="${STAGING_DIR}/link"

  if ! ln -s "${expected}" "${staging_link}" 2>/dev/null; then
    cleanup_staging
    die "無法在 ${DEST_ROOT} 建立 symlink（${name}）" \
        "Windows 請開啟開發人員模式（設定 → 系統 → 開發人員選項），或以具備建立 symlink 權限的身分執行。" \
        "本腳本不提供複製模式；原本的連結沒有任何變動。"
  fi
  if [ ! -L "${staging_link}" ] || [ ! -e "${staging_link}/SKILL.md" ]; then
    cleanup_staging
    die "暫存 symlink 驗證失敗（${name}）：ln -s 可能退化成複製" \
        "Windows 請開啟開發人員模式（設定 → 系統 → 開發人員選項），或以具備建立 symlink 權限的身分執行。" \
        "本腳本不提供複製模式；原本的連結沒有任何變動。"
  fi

  if ! replace_link "${staging_link}" "${target}" "${STAGING_DIR}/previous"; then
    cleanup_staging
    die "無法把暫存連結換到 ${target}" "原本的連結沒有任何變動。"
  fi

  cleanup_staging
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 ${#selected[@]} 個 maze-coder 技能已 symlink 到 ${SKILLS_DIR} ==="
