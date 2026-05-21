#!/usr/bin/env bash
# validate-skills-functional.sh — 技能層級功能驗證測試
# 對應 spec.md Section 12：T-004 ~ T-008

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

err() {
  echo "  [FAIL] $1" >&2
  ERRORS=$((ERRORS + 1))
}

ok() {
  echo "  [OK]   $1"
}

# 輔助函式：擷取 Markdown 中特定 ## 標題區段（到下一個 ## 為止）
# 使用 index() 避免正規表示式特殊字元問題（如括號）
extract_section() {
  local file="$1"
  local header="$2"
  awk -v h="## ${header}" 'index($0, h) == 1 {found=1; next} found && /^## / {exit} found {print}' "$file"
}

# ── T-004：idea-to-spec 功能驗證 ─────────────────────────────────────────────
validate_t004() {
  echo "=== T-004: idea-to-spec functional validation ==="
  local skill_file="${ROOT_DIR}/skills/idea-to-spec/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    err "skills/idea-to-spec/SKILL.md not found"
    return
  fi

  # 驗證 Phase 0-3 存在
  for phase in "Phase 0" "Phase 1" "Phase 2" "Phase 3"; do
    if grep -q "$phase" "$skill_file"; then
      ok "Contains $phase"
    else
      err "Missing $phase in idea-to-spec SKILL.md"
    fi
  done

  # 驗證引用 spec.template.md 全部 7 個必要 section
  local required_sections=("專案概述" "核心問題" "目標" "非目標" "功能清單" "技術考量" "成功指標")
  for sec in "${required_sections[@]}"; do
    if grep -q "$sec" "$skill_file"; then
      ok "References spec section: $sec"
    else
      err "Missing reference to spec section: $sec"
    fi
  done

  # 驗證 Output Contract 引用 spec.template.md 並要求完整性
  if grep -q "spec.template.md" "$skill_file"; then
    ok "Output Contract references spec.template.md"
  else
    err "Output Contract missing reference to spec.template.md"
  fi

  if grep -q "所有必要 section" "$skill_file"; then
    ok "Output Contract requires all necessary sections"
  else
    err "Output Contract missing completeness requirement"
  fi
}

# ── T-005：spec-hardening 功能驗證 ─────────────────────────────────────────
validate_t005() {
  echo ""
  echo "=== T-005: spec-hardening functional validation ==="
  local skill_file="${ROOT_DIR}/skills/spec-hardening/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    err "skills/spec-hardening/SKILL.md not found"
    return
  fi

  # 驗證 Phase 0-8 存在
  for phase in "Phase 0" "Phase 1" "Phase 2" "Phase 3" "Phase 4" "Phase 5" "Phase 6" "Phase 7" "Phase 8"; do
    if grep -q "$phase" "$skill_file"; then
      ok "Contains $phase"
    else
      err "Missing $phase in spec-hardening SKILL.md"
    fi
  done

  # 驗證 8 個補強區塊存在
  local blocks=("Contract" "Invariants" "Edge Cases" "Acceptance Criteria" "Test Plan" "FROZEN" "Drift Risk" "Open Questions")
  for block in "${blocks[@]}"; do
    if grep -q "$block" "$skill_file"; then
      ok "Contains hardening block: $block"
    else
      err "Missing hardening block: $block"
    fi
  done

  # 驗證 Output Contract 明確要求 8 個區塊且缺一不可
  if grep -q "8 個補強區塊" "$skill_file"; then
    ok "Output Contract mentions 8 hardening blocks"
  else
    err "Output Contract missing '8 個補強區塊'"
  fi

  if grep -q "缺一不可" "$skill_file"; then
    ok "Output Contract requires all 8 blocks (缺一不可)"
  else
    err "Output Contract missing '缺一不可' requirement"
  fi
}

# ── T-006 [FROZEN]：github-safe-ops 功能驗證 ───────────────────────────────
validate_t006() {
  echo ""
  echo "=== T-006 [FROZEN]: github-safe-ops functional validation ==="
  local skill_file="${ROOT_DIR}/skills/github-safe-ops/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    err "skills/github-safe-ops/SKILL.md not found"
    return
  fi

  # 驗證風險等級表正確標記 force push
  if grep -q "git push --force" "$skill_file" && grep -q "極高\|禁止" "$skill_file"; then
    ok "Risk table correctly labels force push as high risk / forbidden"
  else
    err "Risk table missing correct force push risk label"
  fi

  # 驗證包含明確警告文字（嚴格字串匹配）
  if grep -q "Force push 到 main / master 可能覆蓋其他人的工作" "$skill_file"; then
    ok "Contains explicit warning for force push to main/master"
  else
    err "Missing explicit warning text for force push to main/master"
  fi

  # 【關鍵】驗證 Output Contract 區段內絕對不能包含 git push --force 指令
  local output_contract
  output_contract=$(extract_section "$skill_file" "輸出（Output Contract）")

  if echo "$output_contract" | grep -q "git push --force"; then
    err "Output Contract contains forbidden instruction 'git push --force'"
  else
    ok "Output Contract does not contain 'git push --force' instruction"
  fi

  # 驗證提供替代方案
  if grep -q "git revert" "$skill_file" || grep -q "替代方案" "$skill_file"; then
    ok "Contains alternative solution guidance"
  else
    err "Missing alternative solution guidance"
  fi
}

# ── T-007：codex/AGENTS.md 包含全部 11 個技能 ─────────────────────────────
validate_t007() {
  echo ""
  echo "=== T-007: codex/AGENTS.md skill completeness ==="
  local agents_file="${ROOT_DIR}/adapters/codex/AGENTS.md"

  if [ ! -f "$agents_file" ]; then
    err "adapters/codex/AGENTS.md not found"
    return
  fi

  local skills=("idea-to-spec" "spec-hardening" "project-init" "session-closeout" "github-safe-ops" "design-review" "qa-verification" "repo-map" "context-audit" "bug-reproduction" "handoff-summary")

  for skill in "${skills[@]}"; do
    if grep -q "## 技能：${skill}" "$agents_file"; then
      ok "AGENTS.md contains skill: ${skill}"
    else
      err "AGENTS.md missing skill: ${skill}"
    fi
  done
}

# ── T-008：Linux 環境可攜性測試 ─────────────────────────────────────────────
validate_t008() {
  echo ""
  echo "=== T-008: validate-skillpack.sh portability (Linux) ==="

  # 驗證 Linux 環境
  if [[ "$(uname -s)" != "Linux" ]]; then
    err "Not running on Linux (current: $(uname -s))"
    return
  fi
  ok "Running on Linux"

  local validate_script="${ROOT_DIR}/scripts/validate-skillpack.sh"
  if ! bash "$validate_script" > /tmp/validate-output.txt 2>&1; then
    err "validate-skillpack.sh exited with non-zero code"
    cat /tmp/validate-output.txt >&2
    return
  fi
  ok "validate-skillpack.sh exits 0"

  if grep -q "All checks passed" /tmp/validate-output.txt; then
    ok "Output contains 'All checks passed'"
  else
    err "Output missing 'All checks passed'"
  fi
}

# ── 主程式 ─────────────────────────────────────────────────────────────────
validate_t004
validate_t005
validate_t006
validate_t007
validate_t008

echo ""
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All functional checks passed (T-004 ~ T-008) ==="
  exit 0
else
  echo "=== ${ERRORS} functional test failures ===" >&2
  exit 1
fi
