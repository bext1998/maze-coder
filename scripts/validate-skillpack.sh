#!/usr/bin/env bash
# validate-skillpack.sh — 驗證 maze-coder 技能包的完整性

set -euo pipefail

ERRORS=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

err() {
  echo "  [FAIL] $1" >&2
  ERRORS=$((ERRORS + 1))
}

ok() {
  echo "  [OK]   $1"
}

# ── 確認在正確的目錄執行 ──────────────────────────────────────────────────────
if [ ! -d "${ROOT_DIR}/skills" ]; then
  echo "ERROR: 必須在 maze-coder 根目錄執行本腳本（找不到 skills/ 目錄）" >&2
  exit 1
fi

echo "=== maze-coder validate-skillpack ==="
echo ""

# ── 1. 驗證 11 個技能的 SKILL.md 存在 ────────────────────────────────────────
echo "--- 檢查 skills/ 目錄 ---"

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

for skill in "${SKILLS[@]}"; do
  skill_path="${ROOT_DIR}/skills/${skill}/SKILL.md"
  if [ -f "${skill_path}" ]; then
    ok "skills/${skill}/SKILL.md"
  else
    err "缺少 skills/${skill}/SKILL.md"
  fi
done

echo ""

# ── 2. 驗證每個 SKILL.md 包含 5 個必要標題 ───────────────────────────────────
echo "--- 檢查 SKILL.md 內容結構 ---"

REQUIRED_SECTIONS=(
  "技能目標"
  "前置條件"
  "執行流程"
  "輸出"
  "技能邊界"
)

for skill in "${SKILLS[@]}"; do
  skill_path="${ROOT_DIR}/skills/${skill}/SKILL.md"
  if [ ! -f "${skill_path}" ]; then
    continue
  fi

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "${section}" "${skill_path}"; then
      :
    else
      err "skills/${skill}/SKILL.md 缺少必要標題：「${section}」"
    fi
  done
  ok "skills/${skill}/SKILL.md — 結構完整"
done

echo ""

# ── 3. 驗證 adapters/ 必要檔案存在 ──────────────────────────────────────────
echo "--- 檢查 adapters/ 目錄 ---"

# claude-code adapter：11 個技能子目錄的 SKILL.md
ADAPTER_CLAUDE="${ROOT_DIR}/adapters/claude-code/.claude/skills"
for skill in "${SKILLS[@]}"; do
  adapter_skill="${ADAPTER_CLAUDE}/${skill}/SKILL.md"
  if [ -f "${adapter_skill}" ]; then
    ok "adapters/claude-code/.claude/skills/${skill}/SKILL.md"
  else
    err "缺少 adapters/claude-code/.claude/skills/${skill}/SKILL.md"
  fi
done

# codex adapter
if [ -f "${ROOT_DIR}/adapters/codex/AGENTS.md" ]; then
  ok "adapters/codex/AGENTS.md"
else
  err "缺少 adapters/codex/AGENTS.md"
fi

# cursor adapter：4 個 .mdc 檔案
CURSOR_RULES_DIR="${ROOT_DIR}/adapters/cursor/.cursor/rules"
CURSOR_RULES=(
  "maze-coder-core.mdc"
  "maze-coder-qa.mdc"
  "maze-coder-git.mdc"
  "maze-coder-design-review.mdc"
)
for rule in "${CURSOR_RULES[@]}"; do
  if [ -f "${CURSOR_RULES_DIR}/${rule}" ]; then
    ok "adapters/cursor/.cursor/rules/${rule}"
  else
    err "缺少 adapters/cursor/.cursor/rules/${rule}"
  fi
done

# opencode adapter
if [ -f "${ROOT_DIR}/adapters/opencode/AGENTS.md" ]; then
  ok "adapters/opencode/AGENTS.md"
else
  err "缺少 adapters/opencode/AGENTS.md"
fi

echo ""

# ── 結果 ─────────────────────────────────────────────────────────────────────
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed ==="
  exit 0
else
  echo "=== ${ERRORS} 個問題需要修正 ===" >&2
  exit 1
fi
