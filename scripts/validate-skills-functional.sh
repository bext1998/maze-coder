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

echo "--- adaptive and grill contracts ---"
require_text "core/invariants.md" "階段.*可調整.*契約.*不可省略" "核心自適應原則"
require_text "core/workflow-model.md" "只有出現具體失敗才依序加強" "Profile 只因具體失敗加強"
require_text "core/workflow-model.md" "scaffolded" "Profile 加強包含 scaffolded"
require_text "profiles/minimal.md" "不得要求固定 Phase、Todo、進度報告" "Minimal 不強制重型流程"
require_text "model-overlays/gpt-5.6.md" "原生代理" "GPT-5.6 保留原生代理"
require_text "model-overlays/gpt-5.6.md" "Subagent 或平行工具" "GPT-5.6 保留平行與委派"
require_text "skills/maze-grilling/SKILL.md" "每次只問一個.*推薦答案.*理由" "Grill 逐題契約"
require_text "skills/maze-grilling/SKILL.md" "查證.*事實" "Grill 自行查證"
require_text "skills/maze-grilling/SKILL.md" "本輪目標" "Grill 先界定單輪目標"
require_text "skills/maze-grilling/SKILL.md" "直接改變.*方案選擇.*工作範圍.*非目標.*不可逆.*高成本.*驗收條件" "Grill 問題准入門檻"
require_text "skills/maze-grilling/SKILL.md" "非阻塞.*待辦分支" "Grill 收納非阻塞問題"
require_text "skills/maze-grilling/SKILL.md" "第 5 題.*最多 7 題" "Grill 題數與收斂上限"
require_text "skills/maze-grilling/SKILL.md" "已決定.*未決分支.*推薦預設值.*另一輪 Grill" "Grill 到限輸出收斂摘要"
require_text "skills/maze-domain-modeling/SKILL.md" "難以逆轉.*缺背景.*替代方案" "ADR 三項門檻"
require_text "skills/maze-grill/SKILL.md" "不建立文件" "Grill 無文件輸出"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "乾淨 Context Window" "Issue 單一 Context"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "垂直切片" "Issue 垂直切片"
require_text "skills/maze-spec-to-issues/references/issue-model.md" "阻塞.*可執行前線" "Issue 阻塞前線"

echo "--- risk-driven-tdd contracts ---"
RISK_TDD="skills/maze-risk-driven-tdd/SKILL.md"
require_text "${RISK_TDD}" "最小可觀察驗證" "TDD 定義最小可觀察驗證"
require_text "${RISK_TDD}" "修改前因正確原因失敗" "TDD 要求修改前失敗證據"
require_text "${RISK_TDD}" "原因、預期失敗的替代證據與未覆蓋風險" "TDD 無自動紅燈時揭露替代證據與風險"
require_text "${RISK_TDD}" "基線失敗必須分列" "TDD 區分既有基線失敗"
require_text "${RISK_TDD}" "純文件、格式、生成物同步.*機械重構不適用" "TDD 排除零行為變更"
require_text "${RISK_TDD}" "不得因測試困難跳過驗證、忽略退出碼、弱化斷言或修改測試迎合錯誤結果" "TDD 禁止弱化驗證"
require_text "${RISK_TDD}" "無法達成時不得假裝已完成，須誠實回報卡在哪一步與原因" "TDD 卡關須誠實回報"
require_text "${RISK_TDD}" "未取得使用者明確同意前，不得降低驗收標準或縮小範圍" "TDD 禁止未經同意降低驗收標準"
require_text "${RISK_TDD}" "察覺抄捷徑或省略已承諾／驗收所需步驟時，須立即停止、主動揭露並補回；無法補回則先取得使用者明確同意才可調整" "TDD 要求停止、揭露、補回或取得同意"

echo "--- token-efficiency-review contracts ---"
TOKEN_REVIEW="skills/maze-token-efficiency-review/SKILL.md"
require_text "${TOKEN_REVIEW}" "重複讀取.*過度探索.*錯誤技能／模型.*可腳本化工作.*無效輸出" "token 稽核範圍完整"
require_text "${TOKEN_REVIEW}" "可驗證且維持正確性、覆蓋率與能力" "token 變更不得降低能力"
require_text "${TOKEN_REVIEW}" "證據不足" "證據不足僅建議"
require_text "${TOKEN_REVIEW}" "發現.*已採變更.*驗證結果.*剩餘風險" "token 稽核輸出完整"

echo "--- design-system and GUI prototype contracts ---"
DESIGN_SYSTEM="skills/maze-design-system/SKILL.md"
GUI_PROTOTYPE="skills/maze-gui-prototyping/SKILL.md"
require_text "${DESIGN_SYSTEM}" "建立或增量演進" "設計系統支援新建與演進"
require_text "${DESIGN_SYSTEM}" "使用者選定.*Design Tokens" "設計方向由人決定"
require_text "${DESIGN_SYSTEM}" "CSS custom properties" "Greenfield WebView token 預設"
require_text "${DESIGN_SYSTEM}" "明確要求.*元件" "元件庫需明確要求"
require_text "${GUI_PROTOTYPE}" "既有 App.*優先" "GUI 原型優先嵌入既有 App"
require_text "${GUI_PROTOTYPE}" "HTML/CSS/SVG" "GUI 原型提供獨立 fallback"
require_text "${GUI_PROTOTYPE}" "三個.*方向" "GUI 原型預設三方向"
require_text "${GUI_PROTOTYPE}" "使用者.*選定" "GUI 方向由人決定"
require_text "${GUI_PROTOTYPE}" "不得直接.*production" "原型不得直接升格 production"
require_text "skills/maze-design-review/SKILL.md" "Design System Conformance" "設計審查支援系統一致性"
require_text "skills/maze-qa-verification/SKILL.md" "prototype-qa-checklist" "QA 支援原型驗收"

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
require_text "skills/maze-session-closeout/SKILL.md" "明確要求 closeout.*整體重建" "closeout 需明確授權且整體重建"
require_text "skills/maze-session-closeout/SKILL.md" "不得追加.*STATUS" "closeout 不追加且不寫 STATUS"
require_text "skills/maze-project-init/SKILL.md" '不得建立 `STATUS.md`' "project-init 不建立 STATUS"
require_text "skills/maze-context-audit/SKILL.md" '忽略外部既有 `STATUS.md`' "context-audit 忽略舊 STATUS"
require_text "skills/maze-project-init/templates/NEXT_ACTION.template.md" "整體重建" "NEXT 模板整體重建契約"
require_text "skills/maze-project-init/templates/NEXT_ACTION.template.md" "最多 3 項" "NEXT 模板最多三項行動"
require_text "skills/maze-project-init/templates/DECISIONS.template.md" "唯一權威.*更新或移除" "DECISIONS 模板有效索引契約"
if [ ! -e "${ROOT_DIR}/docs/STATUS.md" ] && [ ! -e "${ROOT_DIR}/skills/maze-project-init/templates/STATUS.template.md" ] && [ ! -e "${ROOT_DIR}/templates/STATUS.md" ]; then
  ok "STATUS 不再生成且 repo 舊檔已移除"
else
  err "STATUS 仍存在於受管理位置"
fi

if find "${ROOT_DIR}/skills/maze-session-closeout" -iname '*summary*' -o -iname '*status-update*' | grep -q .; then
  err "closeout 含已禁止的 summary/status-update 產物"
else
  ok "closeout 無 summary/status-update 產物"
fi

echo "--- v3.1 review and GitHub CLI contracts ---"
SPEC_REVIEW="skills/maze-spec-review/SKILL.md"
require_text "${SPEC_REVIEW}" "六面向" "Spec review 六面向"
require_text "${SPEC_REVIEW}" "SR-xxx" "Spec review 穩定 finding ID"
require_text "${SPEC_REVIEW}" "Blocker.*Major.*Minor.*Suggestion" "Spec review 四級 finding"
require_text "${SPEC_REVIEW}" "\\-\\-verify.*複審" "Spec review verify trigger"
require_text "skills/maze-spec-review/references/verify-rules.md" "resolved.*open.*partial.*unverifiable" "Spec review verify 狀態"
require_text "skills/maze-spec-review/references/verify-rules.md" "revision.*核心範圍.*停止" "Spec review 來源變更停止"
require_text "${SPEC_REVIEW}" "不修改原規格" "Spec review 唯讀邊界"
for heading in Summary Findings "Undecided Items" "Suggested Acceptance Criteria" "Suggested Revision Order" "Unverified Limitations" "Source Identification"; do
  require_text "skills/maze-spec-review/templates/SPEC_REVIEW.template.md" "^## ${heading}$" "SPEC_REVIEW template: ${heading}"
done

PR_REVIEW="skills/maze-pr-review/SKILL.md"
require_text "${PR_REVIEW}" "PR 說明.*base.*head.*diff.*checks.*comments" "PR review 證據來源"
require_text "${PR_REVIEW}" "Blocker.*Major.*Minor.*Nit" "PR review 四級 finding"
require_text "${PR_REVIEW}" "Request changes.*Comment.*Approve.*Insufficient evidence" "PR review 結論映射"
require_text "${PR_REVIEW}" "降級.*不得 Approve" "PR review 降級限制"
require_text "${PR_REVIEW}" "已審查且未發現問題" "PR review 覆蓋範圍"
require_text "${PR_REVIEW}" "不留言.*批准.*request changes" "PR review 遠端唯讀邊界"

CLI="skills/maze-github-cli/SKILL.md"
require_text "${CLI}" "gh.*可用且已登入" "GitHub CLI auth 前置檢查"
require_text "${CLI}" "repository.*remote.*branch" "GitHub CLI repo/remote 前置檢查"
require_text "${CLI}" "\\-\\-json.*\\-\\-jq" "GitHub CLI 結構化輸出"
require_text "${CLI}" "Read.*Create／Update.*Destructive" "GitHub CLI 操作分級"
require_text "${CLI}" "預覽.*明確確認" "GitHub CLI 寫入確認"
require_text "${CLI}" "\\-\\-admin.*force.*保護規則" "GitHub CLI 禁止繞過"
require_text "${CLI}" "失敗後重新查詢.*重試未完成" "GitHub CLI 冪等失敗處理"
require_text "skills/maze-github-safe-ops/SKILL.md" "使用者明確請求.*預覽.*確認.*委派.*internal" "safe-ops internal CLI 委派"

echo "--- wayfinder contract ---"
require_text "skills/maze-wayfinder/SKILL.md" "Mode 1 建圖.*不解決 issue.*Mode 2 推進.*每次只解決一個 issue" "Wayfinder Mode 1／Mode 2 分離"
require_text "skills/maze-wayfinder/references/issue-types.md" "HITL 規則.*agent 不得替使用者回答問題" "Wayfinder HITL 邊界"
require_text "skills/maze-wayfinder/references/execution-flow.md" "地圖是索引，不是倉庫" "Wayfinder 地圖索引原則"
require_text "skills/maze-wayfinder/SKILL.md" "不寫規格書.*不實作.*不寫程式碼.*不產 PR.*不替使用者決策" "Wayfinder 唯讀邊界"
require_text "skills/maze-wayfinder/SKILL.md" "剩餘問題已確認不影響 Destination（可提前收斂）" "Wayfinder 提前收斂條件"
require_text "skills/maze-wayfinder/templates/WAYFINDER_MAP.template.md" "^## Questions$" "Wayfinder Local Markdown Questions section"
for field in "type: grilling" "status: open" "blocked-by:" "question:" "answer:"; do
  require_text "skills/maze-wayfinder/templates/WAYFINDER_MAP.template.md" "${field}" "Wayfinder Questions 欄位: ${field}"
done
require_text "skills/maze-wayfinder/references/issue-types.md" "Local Markdown 載體.*Questions.*section.*Q-ID、type、status、blocked-by、question、answer" "Wayfinder Local Markdown 六欄位契約"
require_text "skills/maze-wayfinder/references/execution-flow.md" "載入地圖時記錄檔案內容的 hash.*重新計算並比對" "Wayfinder Local Markdown hash 偵測外部修改"
require_text "skills/maze-wayfinder/checklists/wayfinder-checklist.md" "Local Markdown 載體.*寫入前已比對 hash" "Wayfinder checklist hash 自查"
require_text "skills/maze-wayfinder/references/issue-types.md" '\.\./\.\./maze-spec-to-issues/references/issue-model\.md' "Wayfinder issue-types 巢狀路徑正確"
if awk '
  /<!--/ { in_comment=1 }
  !in_comment { print }
  /-->/ { in_comment=0 }
' "${ROOT_DIR}/skills/maze-wayfinder/templates/WAYFINDER_MAP.template.md" | grep -Eq '<[^>]*>'; then
  err "Wayfinder WAYFINDER_MAP.template.md 仍含非 HTML comment 的 angle-bracket placeholder"
else
  ok "Wayfinder WAYFINDER_MAP.template.md 無殘留 angle-bracket placeholder（已改為方括號）"
fi

echo "--- adversarial, threat-modeling, and diagnosis contracts ---"
ADVERSARIAL_REVIEW="skills/maze-adversarial-review/SKILL.md"
require_text "${ADVERSARIAL_REVIEW}" "核心主張.*隱藏假設.*可推翻條件" "Adversarial review 定義證偽目標"
require_text "${ADVERSARIAL_REVIEW}" "go.*revise.*stop.*insufficient evidence" "Adversarial review 限定結論"
require_text "${ADVERSARIAL_REVIEW}" "乾淨上下文.*獨立.*降級.*framing bias" "Adversarial review 揭露 reviewer 獨立性"
require_text "${ADVERSARIAL_REVIEW}" "不取代.*maze-grill.*maze-spec-review" "Adversarial review 邊界"

THREAT_MODELING="skills/maze-threat-modeling/SKILL.md"
require_text "${THREAT_MODELING}" "資產.*信任邊界.*攻擊者.*濫用途徑.*緩解" "Threat modeling 核心分析面"
require_text "${THREAT_MODELING}" "優先威脅.*未驗證假設.*安全條件" "Threat modeling 輸出"
require_text "${THREAT_MODELING}" "不.*程式碼漏洞掃描.*滲透測試.*security audit" "Threat modeling 不越界掃描"

ROOT_CAUSE="skills/maze-root-cause-diagnosis/SKILL.md"
require_text "${ROOT_CAUSE}" "候選假設.*預測.*區辨實驗.*觀察結果.*替代假設" "Root cause diagnosis 收斂流程"
require_text "${ROOT_CAUSE}" "穩定觸發.*消除症狀.*排除至少一個有力替代假設" "Root cause diagnosis 證實門檻"
require_text "${ROOT_CAUSE}" "證據不足.*候選根因.*下一個最小區辨實驗" "Root cause diagnosis 證據不足輸出"
require_text "${ROOT_CAUSE}" "不得因.*修正後測試通過.*根因" "Root cause diagnosis 禁止症狀修補誤判"

echo "--- portability ---"
bash -n "${ROOT_DIR}/scripts/sync-adapters.sh" && ok "sync-adapters.sh syntax" || err "sync-adapters.sh syntax"
bash -n "${ROOT_DIR}/scripts/validate-skillpack.sh" && ok "validate-skillpack.sh syntax" || err "validate-skillpack.sh syntax"
bash -n "${ROOT_DIR}/scripts/validate-adaptive-scenarios.sh" && ok "validate-adaptive-scenarios.sh syntax" || err "validate-adaptive-scenarios.sh syntax"
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
