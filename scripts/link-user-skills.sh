#!/usr/bin/env bash
# 將本 repo 已產生的 Claude Code 技能，以 symlink 方式安裝到全域 ~/.claude/skills/。
#
# 背景：先前用複製方式（cp -r / PowerShell Copy-Item -Recurse）手動安裝到
# ~/.claude/skills/ 時，Windows 的 Copy-Item -Recurse 在目的地資料夾已存在時
# 會把來源整個塞進目的地變成巢狀子目錄（例如 maze-design-review/maze-design-review/），
# 之後的更新又只覆蓋單一 SKILL.md，導致子目錄（checklists/templates/…）長期停留在
# 最舊的安裝內容。改用 symlink 從根本避開「複製到已存在目的地」這整類問題：
# repo 更新（git pull）後全域技能自動同步，不需要重新安裝。
#
# 這是「全域安裝」路徑，跟 README 記載的「cp -r 進單一專案 .claude/」是兩種互不衝突
# 的用途：全域 symlink 適合想在所有專案共用同一份技能的人；per-project cp 適合想把
# 技能版本釘死、跟著該專案一起進版控的人。
#
# 執行前需先跑過 scripts/sync-adapters.sh，確保 adapters/claude-code/.claude/skills/
# 是最新內容。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_ROOT="${REPO_DIR}/adapters/claude-code/.claude/skills"
DEST_ROOT="${HOME}/.claude/skills"

[ -d "${SRC_ROOT}" ] || {
  echo "ERROR: 找不到 ${SRC_ROOT}，請先執行 scripts/sync-adapters.sh 產生 adapters/" >&2
  exit 1
}

mkdir -p "${DEST_ROOT}"

for src in "${SRC_ROOT}"/*/; do
  name="$(basename "${src}")"
  target="${DEST_ROOT}/${name}"
  expected="$(cd "${src}" && pwd)"

  if [ -L "${target}" ]; then
    current="$(readlink -f "${target}" 2>/dev/null || true)"
    if [ "${current}" = "${expected}" ]; then
      echo "  [SAME] ${name}"
      continue
    fi
  elif [ -e "${target}" ]; then
    # 既有實體資料夾（例如舊版複製留下的巢狀殘留或過期內容）：清掉再換成 symlink。
    rm -rf "${target}"
  fi

  ln -sfn "${expected}" "${target}"
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 maze-* 技能已 symlink 到 ${SRC_ROOT} ==="
