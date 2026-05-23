#!/usr/bin/env bash
# sync-adapters.sh — 從 skills/ 同步內容到 adapters/ 和根目錄 templates/
#
# 冪等覆蓋策略：每次執行都完整覆寫 adapter 檔案（INV-6、OQ-2）
# 只讀 skills/，只寫 adapters/ 和根目錄 templates/（INV-6）

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHANGES=0
WARNINGS=0

info() { echo "  [INFO]  $1"; }
warn() { echo "  [WARN]  $1" >&2; WARNINGS=$((WARNINGS + 1)); }

# 複製檔案，僅在內容有變更時計入 CHANGES
copy_if_changed() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "${dst}")"
  if [ -f "${dst}" ] && cmp -s "${src}" "${dst}"; then
    echo "  [SAME]  ${label}"
  else
    cp "${src}" "${dst}"
    echo "  [SYNC]  ${label}"
    CHANGES=$((CHANGES + 1))
  fi
}

synced() { echo "  [SYNC]  $1"; CHANGES=$((CHANGES + 1)); }

# ── 確認在正確的目錄執行 ──────────────────────────────────────────────────────
if [ ! -d "${ROOT_DIR}/skills" ]; then
  echo "ERROR: 必須在 maze-coder 根目錄執行本腳本（找不到 skills/ 目錄）" >&2
  exit 1
fi

echo "=== maze-coder sync-adapters ==="
echo ""

SKILLS=(
  "maze-idea-to-spec"
  "maze-spec-hardening"
  "maze-project-init"
  "maze-session-closeout"
  "maze-github-safe-ops"
  "maze-design-review"
  "maze-qa-verification"
  "maze-repo-map"
  "maze-context-audit"
  "maze-bug-reproduction"
  "maze-handoff-summary"
)

# ── 1. 同步 claude-code adapter ───────────────────────────────────────────────
echo "--- 同步 claude-code adapter ---"
CLAUDE_SKILLS_DIR="${ROOT_DIR}/adapters/claude-code/.claude/skills"

for skill in "${SKILLS[@]}"; do
  src="${ROOT_DIR}/skills/${skill}/SKILL.md"
  dst_dir="${CLAUDE_SKILLS_DIR}/${skill}"
  dst="${dst_dir}/SKILL.md"

  if [ ! -f "${src}" ]; then
    warn "skills/${skill}/SKILL.md 不存在，跳過同步"
    continue
  fi

  copy_if_changed "${src}" "${dst}" "skills/${skill}/SKILL.md → adapters/claude-code/.claude/skills/${skill}/SKILL.md"
done

echo ""

# ── 2. 同步 codex adapter（整合 11 個技能到 AGENTS.md）────────────────────────
echo "--- 同步 codex adapter ---"
CODEX_DIR="${ROOT_DIR}/adapters/codex"
mkdir -p "${CODEX_DIR}"
CODEX_AGENTS="${CODEX_DIR}/AGENTS.md"

{
  echo "# maze-coder — Codex Agent 指令"
  echo ""
  echo "> 本文件由 sync-adapters.sh 自動產生，請勿手動編輯。"
  echo "> source of truth：skills/ 目錄下的各 SKILL.md"
  echo ""
  echo "---"
  echo ""

  for skill in "${SKILLS[@]}"; do
    src="${ROOT_DIR}/skills/${skill}/SKILL.md"
    if [ ! -f "${src}" ]; then
      warn "skills/${skill}/SKILL.md 不存在，跳過加入 codex AGENTS.md"
      continue
    fi
    echo "## 技能：${skill}"
    echo ""
    cat "${src}"
    echo ""
    echo "---"
    echo ""
  done
} > "${CODEX_AGENTS}.tmp"
if [ -f "${CODEX_AGENTS}" ] && cmp -s "${CODEX_AGENTS}.tmp" "${CODEX_AGENTS}"; then
  echo "  [SAME]  11 個技能 → adapters/codex/AGENTS.md"
  rm "${CODEX_AGENTS}.tmp"
else
  mv "${CODEX_AGENTS}.tmp" "${CODEX_AGENTS}"
  echo "  [SYNC]  11 個技能 → adapters/codex/AGENTS.md"
  CHANGES=$((CHANGES + 1))
fi

echo ""

# ── 3. 同步 opencode adapter（格式同 codex）──────────────────────────────────
echo "--- 同步 opencode adapter ---"
OPENCODE_DIR="${ROOT_DIR}/adapters/opencode"
mkdir -p "${OPENCODE_DIR}"
OPENCODE_AGENTS="${OPENCODE_DIR}/AGENTS.md"

{
  echo "# maze-coder — opencode Agent 指令"
  echo ""
  echo "> 本文件由 sync-adapters.sh 自動產生，請勿手動編輯。"
  echo "> source of truth：skills/ 目錄下的各 SKILL.md"
  echo ""
  echo "---"
  echo ""

  for skill in "${SKILLS[@]}"; do
    src="${ROOT_DIR}/skills/${skill}/SKILL.md"
    if [ ! -f "${src}" ]; then
      warn "skills/${skill}/SKILL.md 不存在，跳過加入 opencode AGENTS.md"
      continue
    fi
    echo "## 技能：${skill}"
    echo ""
    cat "${src}"
    echo ""
    echo "---"
    echo ""
  done
} > "${OPENCODE_AGENTS}.tmp"
if [ -f "${OPENCODE_AGENTS}" ] && cmp -s "${OPENCODE_AGENTS}.tmp" "${OPENCODE_AGENTS}"; then
  echo "  [SAME]  11 個技能 → adapters/opencode/AGENTS.md"
  rm "${OPENCODE_AGENTS}.tmp"
else
  mv "${OPENCODE_AGENTS}.tmp" "${OPENCODE_AGENTS}"
  echo "  [SYNC]  11 個技能 → adapters/opencode/AGENTS.md"
  CHANGES=$((CHANGES + 1))
fi

echo ""

# ── 4. 同步 cursor adapter（4 個 .mdc 檔案）──────────────────────────────────
echo "--- 同步 cursor adapter ---"
CURSOR_RULES_DIR="${ROOT_DIR}/adapters/cursor/.cursor/rules"
mkdir -p "${CURSOR_RULES_DIR}"

sync_mdc() {
  local dst="$1" label="$2"
  shift 2
  local tmpfile="${dst}.tmp"
  cat > "${tmpfile}"
  if [ -f "${dst}" ] && cmp -s "${tmpfile}" "${dst}"; then
    echo "  [SAME]  ${label}"
    rm "${tmpfile}"
  else
    mv "${tmpfile}" "${dst}"
    echo "  [SYNC]  ${label}"
    CHANGES=$((CHANGES + 1))
  fi
}

# maze-coder-core.mdc：maze-idea-to-spec, maze-spec-hardening, maze-project-init, maze-session-closeout, maze-repo-map, maze-context-audit
{
  echo "---"
  echo "description: maze-coder 核心工作流技能"
  echo "---"
  echo ""
  for skill in "maze-idea-to-spec" "maze-spec-hardening" "maze-project-init" "maze-session-closeout" "maze-repo-map" "maze-context-audit"; do
    src="${ROOT_DIR}/skills/${skill}/SKILL.md"
    [ -f "${src}" ] && cat "${src}" && echo "" && echo "---" && echo ""
  done
} | sync_mdc "${CURSOR_RULES_DIR}/maze-coder-core.mdc" "6 個核心技能 → adapters/cursor/.cursor/rules/maze-coder-core.mdc"

# maze-coder-qa.mdc：maze-qa-verification, maze-bug-reproduction
{
  echo "---"
  echo "description: maze-coder QA 與 Bug 追蹤技能"
  echo "---"
  echo ""
  for skill in "maze-qa-verification" "maze-bug-reproduction"; do
    src="${ROOT_DIR}/skills/${skill}/SKILL.md"
    [ -f "${src}" ] && cat "${src}" && echo "" && echo "---" && echo ""
  done
} | sync_mdc "${CURSOR_RULES_DIR}/maze-coder-qa.mdc" "2 個 QA 技能 → adapters/cursor/.cursor/rules/maze-coder-qa.mdc"

# maze-coder-git.mdc：maze-github-safe-ops
{
  echo "---"
  echo "description: maze-coder Git 安全操作技能"
  echo "---"
  echo ""
  src="${ROOT_DIR}/skills/maze-github-safe-ops/SKILL.md"
  [ -f "${src}" ] && cat "${src}"
} | sync_mdc "${CURSOR_RULES_DIR}/maze-coder-git.mdc" "github-safe-ops → adapters/cursor/.cursor/rules/maze-coder-git.mdc"

# maze-coder-design-review.mdc：maze-design-review, maze-handoff-summary
{
  echo "---"
  echo "description: maze-coder 設計審查與交接技能"
  echo "---"
  echo ""
  for skill in "maze-design-review" "maze-handoff-summary"; do
    src="${ROOT_DIR}/skills/${skill}/SKILL.md"
    [ -f "${src}" ] && cat "${src}" && echo "" && echo "---" && echo ""
  done
} | sync_mdc "${CURSOR_RULES_DIR}/maze-coder-design-review.mdc" "2 個設計技能 → adapters/cursor/.cursor/rules/maze-coder-design-review.mdc"

echo ""

# ── 5. 同步根目錄 templates/（從 skills/*/templates/ 複製）──────────────────
echo "--- 同步根目錄 templates/ ---"
TEMPLATES_DIR="${ROOT_DIR}/templates"
mkdir -p "${TEMPLATES_DIR}"

# 定義 skills/ 模板到根目錄 templates/ 的映射
declare -A TEMPLATE_MAP=(
  ["maze-idea-to-spec/templates/spec.template.md"]="spec.md"
  ["maze-project-init/templates/AGENTS.template.md"]="AGENTS.md"
  ["maze-project-init/templates/PROJECT_BRIEF.template.md"]="PROJECT_BRIEF.md"
  ["maze-project-init/templates/STATUS.template.md"]="STATUS.md"
  ["maze-project-init/templates/NEXT_ACTION.template.md"]="NEXT_ACTION.md"
  ["maze-project-init/templates/DECISIONS.template.md"]="DECISIONS.md"
  ["maze-project-init/templates/MAZE_PROJECT.template.md"]="MAZE_PROJECT.md"
  ["maze-qa-verification/templates/QA_REPORT.template.md"]="QA_REPORT.md"
  ["maze-design-review/templates/DESIGN_REVIEW.template.md"]="DESIGN_REVIEW.md"
  ["maze-repo-map/templates/REPO_MAP.template.md"]="REPO_MAP.md"
  ["maze-handoff-summary/templates/HANDOFF.template.md"]="HANDOFF.md"
)

for src_rel in "${!TEMPLATE_MAP[@]}"; do
  src="${ROOT_DIR}/skills/${src_rel}"
  dst="${TEMPLATES_DIR}/${TEMPLATE_MAP[$src_rel]}"
  if [ -f "${src}" ]; then
    copy_if_changed "${src}" "${dst}" "skills/${src_rel} → templates/${TEMPLATE_MAP[$src_rel]}"
  else
    warn "skills/${src_rel} 不存在，跳過同步"
  fi
done

# TASK_PLAN.md — 獨立模板（無對應技能）
TASK_PLAN="${TEMPLATES_DIR}/TASK_PLAN.md"
if [ ! -f "${TASK_PLAN}" ]; then
  {
    echo "# [專案名稱] — 任務計畫"
    echo ""
    echo "> 建立日期：[日期]"
    echo ""
    echo "---"
    echo ""
    echo "## 目標"
    echo ""
    echo "[本次任務要達成什麼。]"
    echo ""
    echo "---"
    echo ""
    echo "## 任務拆解"
    echo ""
    echo "- [ ] [子任務一]"
    echo "- [ ] [子任務二]"
    echo "- [ ] [子任務三]"
    echo ""
    echo "---"
    echo ""
    echo "## 驗收條件"
    echo ""
    echo "- [任務完成的判斷標準]"
  } > "${TASK_PLAN}"
  synced "建立 templates/TASK_PLAN.md"
fi

echo ""

# ── 6. 檢查 skills/ 下是否有新技能尚未在 adapter 中 ─────────────────────────
echo "--- 檢查新技能同步狀態 ---"
while IFS= read -r -d '' skill_md; do
  skill_dir="$(basename "$(dirname "${skill_md}")")"
  found=0
  for known_skill in "${SKILLS[@]}"; do
    [ "${skill_dir}" = "${known_skill}" ] && found=1 && break
  done
  if [ "${found}" -eq 0 ]; then
    warn "以下技能尚未同步到所有 adapter：${skill_dir}"
  fi
done < <(find "${ROOT_DIR}/skills" -name "SKILL.md" -print0)

echo ""

# ── 結果 ─────────────────────────────────────────────────────────────────────
if [ "${CHANGES}" -eq 0 ]; then
  echo "=== synced（no changes）==="
else
  echo "=== synced（${CHANGES} 個檔案已更新）==="
fi

if [ "${WARNINGS}" -gt 0 ]; then
  echo "=== ${WARNINGS} 個警告，請檢查上方輸出 ===" >&2
fi

exit 0
