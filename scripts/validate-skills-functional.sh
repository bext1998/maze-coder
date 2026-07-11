#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

ok() { echo "  [OK]   $1"; }
err() { echo "  [FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }

require_text() {
  local file="$1" pattern="$2" label="$3"
  grep -Eq "${pattern}" "${ROOT_DIR}/${file}" && ok "${label}" || err "${label} (${file})"
}

echo "=== Functional contract validation ==="

echo "--- Existing behavior baselines ---"
require_text "skills/maze-idea-to-spec/SKILL.md" "專案概述.*核心問題.*目標.*非目標.*功能清單.*技術考量.*成功指標" "idea-to-spec 保留 7 個必要區塊"
require_text "skills/maze-spec-hardening/SKILL.md" "Contract.*Invariants.*Edge Cases.*Acceptance Criteria.*Test Plan.*FROZEN.*Drift Risk.*Open Questions" "spec-hardening 保留 8 個補強區塊"
require_text "skills/maze-github-safe-ops/SKILL.md" "Force push 到 main / master 可能覆蓋其他人的工作" "保留 force-push 明確警告"
require_text "skills/maze-github-safe-ops/SKILL.md" "git revert" "保留安全替代方案"

echo "--- token-efficiency-review contracts ---"
TOKEN_REVIEW="skills/maze-token-efficiency-review/SKILL.md"
require_text "${TOKEN_REVIEW}" "重複讀取.*過度探索.*錯誤技能／模型.*可腳本化工作.*無效輸出" "token 稽核範圍完整"
require_text "${TOKEN_REVIEW}" "可驗證且維持正確性、覆蓋率與能力" "token 變更不得降低能力"
require_text "${TOKEN_REVIEW}" "證據不足" "證據不足僅建議"
require_text "${TOKEN_REVIEW}" "發現.*已採變更.*驗證結果.*剩餘風險" "token 稽核輸出完整"

echo "--- spec-to-issues contracts ---"
SPEC="skills/maze-spec-to-issues/SKILL.md"
require_text "${SPEC}" "預設輸出完整 Dry Run" "預設 Dry Run"
require_text "${SPEC}" "本人、不指派、逐項或指定帳號" "四種 Assignee 策略"
require_text "${SPEC}" "取得確認" "GitHub 寫入確認"
require_text "${SPEC}" "成功、失敗、略過、重複、已存在、權限、Assignee" "部分失敗逐項結果"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "只能使用一個 P0–P4" "正式優先級互斥"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "不得同時有 P0–P4" "候選與優先級互斥"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "至少一個類別" "類別標籤必要"
require_text "skills/maze-spec-to-issues/references/sync-and-errors.md" "精確比對.*task-id" "marker 優先去重"
require_text "skills/maze-spec-to-issues/references/sync-and-errors.md" "重試前重新搜尋 marker" "冪等重試"

for heading in 背景 目標 工作範圍 不在範圍內 驗收條件 相依關係 規格來源 完成條件; do
  require_text "skills/maze-spec-to-issues/templates/issue.template.md" "^## ${heading}$" "Issue template: ${heading}"
done
require_text "skills/maze-spec-to-issues/templates/issue.template.md" "<!-- maze-coder" "Issue marker"

echo "--- closeout contracts ---"
for state in in-progress blocked awaiting-review awaiting-merge merged-awaiting-close completed research-only untracked; do
  require_text "skills/maze-session-closeout/references/state-model.md" "${state}" "Closeout state: ${state}"
done
require_text "skills/maze-session-closeout/references/state-model.md" "AC、QA、適用 CI、文件、PR 合併與 Issue 關閉全部成立" "completed 完整門檻"
require_text "skills/maze-session-closeout/SKILL.md" "不建立 Session Closeout Report" "禁止 Closeout Report"

if find "${ROOT_DIR}/skills/maze-session-closeout" -iname '*summary*' -o -iname '*status-update*' | grep -q .; then
  err "closeout 含已禁止的 summary/status-update 產物"
else
  ok "closeout 無 summary/status-update 產物"
fi

echo "--- portability ---"
bash -n "${ROOT_DIR}/scripts/sync-adapters.sh" && ok "sync-adapters.sh syntax" || err "sync-adapters.sh syntax"
bash -n "${ROOT_DIR}/scripts/validate-skillpack.sh" && ok "validate-skillpack.sh syntax" || err "validate-skillpack.sh syntax"
if [[ "$(uname -s)" == Linux ]]; then
  ok "Linux runtime"
else
  echo "  [SKIP] Ubuntu runtime case（current: $(uname -s)）"
fi

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All functional checks passed ==="
else
  echo "=== ${ERRORS} functional failures ===" >&2
  exit 1
fi
