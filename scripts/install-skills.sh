#!/usr/bin/env bash
# 把 skills/ 底下的技能以 symlink 安裝到各 host 原生的技能目錄。
#
# 只建立真正的 symlink，不提供複製模式：複製在 Windows 上會出現「目的地已存在時
# 塞成巢狀目錄、之後只覆蓋 SKILL.md」的損毀（見 PR #39／#41），而且 git pull 後
# 不會同步。MSYS=winsymlinks:nativestrict 強制 ln -s 建立真 NTFS symlink；建完
# 再用 test -L 驗證，失敗就直接報錯，不留一份看起來正常、實際上是死的複製品。
#
# 安全前提：
#   1. 位置參數只接受 skills/ 直接子目錄的精確名稱，且目標永遠是安裝目錄的直接
#      子項；含 / 或 . / .. 一律在寫入前拒絕。
#   2. 安裝目錄與來源目錄（實體路徑）不得相同、也不得互相包含；目標若解析後落在
#      來源目錄內一律拒絕，避免把 repo 的技能目錄當成安裝產物刪掉。
#   3. 所有衝突在任何寫入前一次預檢；無法讀取的目標視為衝突。
#   4. 暫存連結建在本次專屬的 mktemp 目錄；換手失敗會把舊安裝搬回原位，成功後才
#      刪除舊內容。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_DIR}/skills"

usage() {
  echo "用法：bash scripts/install-skills.sh --host <host> [--scope user|project] [--force] [skill-name ...]" >&2
  echo "  --host   claude | codex | cursor | pi | opencode | agents（必填）" >&2
  echo "  --scope  user（預設）或 project（相對於目前工作目錄）" >&2
  echo "  --force  覆蓋已存在且非空的同名目錄" >&2
  echo "  未給技能名稱時安裝 skills/ 底下全部技能" >&2
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
FORCE=0
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
    --force)
      FORCE=1
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
# 代表無法解析（目錄不存在、broken symlink 等），呼叫端一律用 `if canon ...; then`
# 接住，不能讓失敗直接觸發 set -e 中止腳本。
canon() {
  (cd -P "$1" 2>/dev/null && pwd)
}

# 解析「可能還不存在」的路徑：從最深的既有祖先往上找，再把不存在的尾段接回去。
canon_path() {
  local p="$1" suffix="" base
  while [ ! -d "${p}" ]; do
    suffix="/$(basename "${p}")${suffix}"
    p="$(dirname "${p}")"
    case "${p}" in ""|"/"|".") break ;; esac
  done
  base="$(canon "${p}")" || return 1
  printf '%s%s' "${base}" "${suffix}"
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
    is_available "${name}" \
      || die "找不到技能 ${name}（可用技能：$(printf '%s ' "${AVAILABLE[@]}")）"
    selected+=("${name}")
  done
fi

# --- 路徑安全檢查：目標永遠只能是 DEST_ROOT 的直接子項 ---
for name in "${selected[@]}"; do
  case "${name}" in
    *[!A-Za-z0-9._-]*) die "技能名稱含不允許的字元：${name}" ;;
  esac
  target="${DEST_ROOT}/${name}"
  case "${target}" in
    "${DEST_ROOT}/"*) ;;
    *) die "目標路徑異常：${target}" ;;
  esac
  case "${target#"${DEST_ROOT}/"}" in
    */*|.|..) die "目標路徑異常：${target}" ;;
  esac
done

# --- 安裝目錄與來源目錄不得重疊（用實體路徑判斷，symlink 會先被解析） ---
SKILLS_REAL="$(canon "${SKILLS_DIR}")" || die "無法解析來源目錄 ${SKILLS_DIR}"
DEST_REAL="$(canon_path "${DEST_ROOT}")" || die "無法解析安裝目錄 ${DEST_ROOT}"

if [ "${DEST_REAL}" = "${SKILLS_REAL}" ]; then
  die "安裝目錄就是技能來源：${DEST_REAL}" \
      "這會讓安裝產物覆蓋 repo 的 skills/，本腳本拒絕執行。"
fi
case "${DEST_REAL}" in
  "${SKILLS_REAL}"/*)
    die "安裝目錄位於技能來源之內：${DEST_REAL}" "本腳本拒絕在 skills/ 底下建立安裝產物。"
    ;;
esac
case "${SKILLS_REAL}" in
  "${DEST_REAL}"/*)
    die "安裝目錄包含技能來源：${DEST_REAL}" "來源與安裝產物不得互相包含，請改用其他安裝目錄。"
    ;;
esac

# --- 每個目標若解析後落在來源目錄內，一律拒絕（避免刪到 repo 內容） ---
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  if [ -e "${target}" ] && [ ! -L "${target}" ]; then
    target_real="$(canon "${target}")" || target_real=""
    case "${target_real}" in
      "${SKILLS_REAL}"|"${SKILLS_REAL}"/*)
        die "目標 ${target} 解析後位於技能來源 ${SKILLS_REAL} 之內" \
            "安裝目錄與來源重疊，本腳本拒絕執行。"
        ;;
    esac
  fi
done

# --- 衝突預檢：有任何未經 --force 的既有非空項目，就在建立第一個連結前停下 ---
conflicts=()
unreadable=()
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  if [ -L "${target}" ]; then
    continue
  fi
  if [ -e "${target}" ]; then
    if [ -d "${target}" ]; then
      # 空目錄可以直接接管；find 失敗（權限等）一律視為衝突，不能當成空目錄。
      if ! listing="$(find "${target}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)"; then
        unreadable+=("${target}")
        continue
      fi
      if [ -z "${listing}" ]; then
        continue
      fi
    fi
    if [ "${FORCE}" != "1" ]; then
      conflicts+=("${target}")
    fi
  fi
done

if [ "${#unreadable[@]}" -gt 0 ]; then
  {
    echo "ERROR: 下列目標無法讀取內容，無法判斷是否為舊版殘留："
    printf '       %s\n' "${unreadable[@]}"
    echo "       請先確認權限或手動處理；本次沒有安裝或刪除任何東西。"
  } >&2
  exit 1
fi

if [ "${#conflicts[@]}" -gt 0 ]; then
  {
    echo "ERROR: 下列目標已存在且非空，無法確認是否為舊版殘留："
    printf '       %s\n' "${conflicts[@]}"
    echo "       確認內容後手動刪除或搬移，或用 --force 明確覆蓋再重新執行。"
    echo "       本次沒有安裝或刪除任何東西。"
  } >&2
  exit 1
fi

mkdir -p "${DEST_ROOT}"

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

  # 本次專屬的暫存目錄：連結與舊安裝都先放這裡，絕不與既有檔案同名。
  STAGING_DIR="$(mktemp -d "${DEST_ROOT}/.install-staging.XXXXXX")" \
    || die "無法在 ${DEST_ROOT} 建立暫存目錄"
  staging_link="${STAGING_DIR}/link"

  if ! ln -s "${expected}" "${staging_link}" 2>/dev/null; then
    cleanup_staging
    die "無法在 ${DEST_ROOT} 建立 symlink（${name}）" \
        "Windows 請開啟開發人員模式（設定 → 系統 → 開發人員選項），或以具備建立 symlink 權限的身分執行。" \
        "本腳本不提供複製模式；原本的安裝沒有任何變動。"
  fi
  if [ ! -L "${staging_link}" ] || [ ! -e "${staging_link}/SKILL.md" ]; then
    cleanup_staging
    die "暫存 symlink 驗證失敗（${name}）：ln -s 可能退化成複製" \
        "Windows 請開啟開發人員模式（設定 → 系統 → 開發人員選項），或以具備建立 symlink 權限的身分執行。" \
        "本腳本不提供複製模式；原本的安裝沒有任何變動。"
  fi

  # 先把既有安裝搬到暫存目錄（同檔案系統的 rename），再換上新的連結。
  backup=""
  if [ -L "${target}" ] || [ -e "${target}" ]; then
    backup="${STAGING_DIR}/previous"
    if ! mv "${target}" "${backup}"; then
      cleanup_staging
      die "無法把既有 ${target} 移到暫存位置" "既有安裝沒有任何變動。"
    fi
  fi

  if ! mv "${staging_link}" "${target}"; then
    if [ -z "${backup}" ]; then
      cleanup_staging
      die "無法把暫存連結換到 ${target}" "原本沒有既有安裝，沒有東西需要還原。"
    fi
    if mv "${backup}" "${target}"; then
      cleanup_staging
      die "無法把暫存連結換到 ${target}" "已把先前的安裝還原回原位。"
    fi
    KEEP_STAGING=1
    die "無法把暫存連結換到 ${target}" \
        "還原也失敗：先前的安裝仍在 ${backup}，請手動移回 ${target}。"
  fi

  cleanup_staging
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 ${#selected[@]} 個 maze-coder 技能已 symlink 到 ${SKILLS_DIR} ==="
