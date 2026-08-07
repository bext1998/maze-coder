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
# Windows 上的 Git Bash 預設不會替換為 symlink：MSYS 的 `ln -s` 在沒有
# SeCreateSymbolicLinkPrivilege（未開發人員模式／未提權）時會靜默退化成複製整份
# 目錄，之後對來源的修改不會反映到目的地，等於白做。設定 MSYS=winsymlinks:nativestrict
# 強制要求建立真正的 NTFS symlink；建立後另外用 `test -L` 驗證，失敗就直接報錯，
# 不留下一份看起來正常、實際上是死的複製品。
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

# Windows 上強制 ln -s 建立真正的 symlink，而不是靜默複製整份目錄；其他平台上這個
# 環境變數無作用，可安全設定。
export MSYS=winsymlinks:nativestrict

[ -d "${SRC_ROOT}" ] || {
  echo "ERROR: 找不到 ${SRC_ROOT}，請先執行 scripts/sync-adapters.sh 產生 adapters/" >&2
  exit 1
}

mkdir -p "${DEST_ROOT}"

# canon 用 `cd -P && pwd` 取代 `readlink -f`：後者不是所有平台都支援 -f（例如較舊版
# macOS 內建 readlink），且原本用 `|| true` 吞掉的錯誤會讓「已是正確連結」永遠判斷不出
# 來，每次都重建。`cd -P` 是 POSIX 內建行為，任何 bash 都有，失敗時讓呼叫端明確處理。
canon() {
  (cd -P "$1" 2>/dev/null && pwd)
}

shopt -s nullglob
src_dirs=("${SRC_ROOT}"/*/)
shopt -u nullglob
[ "${#src_dirs[@]}" -gt 0 ] || {
  echo "ERROR: ${SRC_ROOT} 底下沒有任何技能子目錄，請確認 sync-adapters.sh 有正確產生內容" >&2
  exit 1
}

for src in "${src_dirs[@]}"; do
  name="$(basename "${src}")"
  target="${DEST_ROOT}/${name}"
  expected="$(canon "${src}")"

  if [ -L "${target}" ]; then
    current="$(canon "${target}")"
    if [ -n "${current}" ] && [ "${current}" = "${expected}" ]; then
      echo "  [SAME] ${name}"
      continue
    fi
    # 連結存在但指向錯誤位置（或已失效/懸空）：換成正確連結，安全直接覆蓋。
    rm -f "${target}"
  elif [ -e "${target}" ]; then
    # 既有實體資料夾／檔案，且不是這支腳本建立的連結。只在看得出是舊版技能安裝
    # （含 SKILL.md）或是空資料夾時才視為可安全清除的殘留；否則裡面可能是使用者
    # 自己放的、無關的東西，直接停下來讓人手動處理，不要幫忙猜測後代為刪除。
    if [ -f "${target}/SKILL.md" ] || [ -z "$(ls -A "${target}" 2>/dev/null)" ]; then
      rm -rf "${target}"
    else
      echo "ERROR: ${target} 已存在，且看起來不是本腳本管理的技能安裝（沒有 SKILL.md 且非空）。" >&2
      echo "       請確認內容後手動處理（搬移或刪除），再重新執行本腳本。" >&2
      exit 1
    fi
  fi

  ln -sfn "${expected}" "${target}"
  [ -L "${target}" ] || {
    echo "ERROR: ${target} 建立後不是 symlink——本機的 ln -s 可能不支援目錄 symlink" \
      "（Windows 上通常代表未啟用開發人員模式／缺少 SeCreateSymbolicLinkPrivilege）。" >&2
    exit 1
  }
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 maze-* 技能已 symlink 到 ${SRC_ROOT} ==="
