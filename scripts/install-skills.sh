#!/usr/bin/env bash
# 把 skills/ 底下的技能以 symlink 安裝到各 host 原生的技能目錄。
#
# 只建立真正的 symlink，不提供複製模式：複製在 Windows 上會出現「目的地已存在時
# 塞成巢狀目錄、之後只覆蓋 SKILL.md」的損毀（見 PR #39／#41），而且 git pull 後
# 不會同步。MSYS=winsymlinks:nativestrict 強制 ln -s 建立真 NTFS symlink；建完
# 再用 test -L 驗證，失敗就直接報錯，不留一份看起來正常、實際上是死的複製品。
#
# 已存在的非空目錄不會被自動刪除：「裡面有 SKILL.md」不能證明那是舊版殘留，也可能
# 是使用者自己維護的技能。只有空目錄會自動清除，其餘要用 --force 明確覆蓋。

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
  *) echo "ERROR: --scope 只接受 user 或 project，收到 ${SCOPE}" >&2; exit 1 ;;
esac

case "${HOST}" in
  claude) user_dir="${HOME}/.claude/skills"   project_dir=".claude/skills" ;;
  codex)  user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  cursor) user_dir="${HOME}/.cursor/skills"   project_dir=".cursor/skills" ;;
  pi)     user_dir="${HOME}/.pi/agent/skills" project_dir=".pi/skills" ;;
  opencode) user_dir="${HOME}/.config/opencode/skills" project_dir=".opencode/skills" ;;
  agents) user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  *)
    echo "ERROR: 不支援的 --host ${HOST}（可用：claude、codex、cursor、pi、opencode、agents）" >&2
    exit 1
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

[ -d "${SKILLS_DIR}" ] || {
  echo "ERROR: 找不到 ${SKILLS_DIR}" >&2
  exit 1
}

# canon 用 `cd -P && pwd` 取代 `readlink -f`：後者不是所有平台都支援 -f。回傳非零
# 代表無法解析（目錄不存在、broken symlink 等），呼叫端一律用 `if canon ...; then`
# 接住，不能讓失敗直接觸發 set -e 中止腳本。
canon() {
  (cd -P "$1" 2>/dev/null && pwd)
}

shopt -s nullglob
all_dirs=("${SKILLS_DIR}"/*/)
shopt -u nullglob
[ "${#all_dirs[@]}" -gt 0 ] || {
  echo "ERROR: ${SKILLS_DIR} 底下沒有任何技能目錄" >&2
  exit 1
}

selected=()
if [ "${#REQUESTED[@]}" -eq 0 ]; then
  for dir in "${all_dirs[@]}"; do
    selected+=("$(basename "${dir}")")
  done
else
  for name in "${REQUESTED[@]}"; do
    if [ ! -d "${SKILLS_DIR}/${name}" ]; then
      echo "ERROR: 找不到技能 ${name}（可用技能見 ${SKILLS_DIR}）" >&2
      exit 1
    fi
    selected+=("${name}")
  done
fi

mkdir -p "${DEST_ROOT}"

for name in "${selected[@]}"; do
  src="${SKILLS_DIR}/${name}"
  target="${DEST_ROOT}/${name}"
  expected="$(canon "${src}")"

  if [ -z "${expected}" ]; then
    echo "ERROR: 無法解析來源路徑 ${src}" >&2
    exit 1
  fi

  if [ -L "${target}" ]; then
    current=""
    if resolved="$(canon "${target}")"; then
      current="${resolved}"
    fi
    if [ -n "${current}" ] && [ "${current}" = "${expected}" ]; then
      echo "  [SAME] ${name}"
      continue
    fi
    # 連結存在但指向錯誤位置（或已失效／懸空）：換成正確連結，安全直接覆蓋。
    rm -f "${target}"
  elif [ -e "${target}" ]; then
    # 既有實體檔案或目錄，且不是本腳本建立的連結。用 rmdir 判斷是否為空：成功就
    # 代表當下確實是空目錄，可以直接移除；失敗（非空、非目錄、權限問題）一律
    # 不動它，除非使用者用 --force 明確覆蓋。
    if rmdir "${target}" 2>/dev/null; then
      :
    elif [ "${FORCE}" = "1" ]; then
      rm -rf "${target}"
    else
      echo "ERROR: ${target} 已存在且非空，無法確認是否為舊版殘留。" >&2
      echo "       確認內容後手動刪除或搬移，或用 --force 明確覆蓋再重新執行。" >&2
      exit 1
    fi
  fi

  ln -sfn "${expected}" "${target}"
  if [ ! -L "${target}" ]; then
    echo "ERROR: ${target} 建立後不是 symlink——本機的 ln -s 無法建立目錄 symlink。" >&2
    echo "       Windows 請開啟開發人員模式（設定 → 系統 → 開發人員選項），" >&2
    echo "       或以具備建立 symlink 權限的身分執行；本腳本不提供複製模式。" >&2
    exit 1
  fi
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 ${#selected[@]} 個 maze-coder 技能已 symlink 到 ${SKILLS_DIR} ==="
