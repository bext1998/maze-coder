#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ERRORS=0
WARNINGS=0
TOTAL_CHARS=0
BASELINE_CHARS=13168

UTF8_LOCALE="$(locale -a 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /^(C|en_US)\.(UTF-8|utf8)$/{print; exit}')"
[ -n "${UTF8_LOCALE}" ] && export LC_ALL="${UTF8_LOCALE}"

SKILLS=(
  maze-idea-to-spec maze-spec-hardening maze-project-init maze-spec-to-issues
  maze-session-closeout maze-github-safe-ops maze-design-review
  maze-qa-verification maze-repo-map maze-context-audit
  maze-bug-reproduction maze-handoff-summary maze-token-efficiency-review
  maze-risk-driven-tdd
)
SECTIONS=(目標 前置條件 執行流程 輸出契約 邊界)

ok() { echo "  [OK]   $1"; }
err() { echo "  [FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "  [WARN] $1" >&2; WARNINGS=$((WARNINGS + 1)); }

section_nonempty() {
  local file="$1" section="$2"
  awk -v header="## ${section}" '
    $0 == header { found=1; next }
    found && /^## / { exit }
    found && $0 !~ /^[[:space:]]*$/ { content=1 }
    END { exit !(found && content) }
  ' "${file}"
}

validate_skill() {
  local skill="$1" file="${ROOT_DIR}/skills/${skill}/SKILL.md"
  [ -f "${file}" ] || { err "缺少 skills/${skill}/SKILL.md"; return; }

  local first last name fields chars
  first="$(head -n 1 "${file}")"
  last="$(awk '/^---$/{count++; if (count==2) {print NR; exit}}' "${file}")"
  [ "${first}" = "---" ] && [ "${last}" -gt 1 ] || err "${skill}: frontmatter 格式錯誤"

  name="$(awk 'NR>1 && /^---$/{exit} /^name:[[:space:]]*/{sub(/^name:[[:space:]]*/, ""); print}' "${file}")"
  [ "${name}" = "${skill}" ] || err "${skill}: name 與目錄不一致"
  fields="$(awk 'NR>1 && /^---$/{exit} NR>1 && /^[A-Za-z0-9_-]+:/{sub(/:.*/, ""); if ($0 != "name" && $0 != "description") print}' "${file}")"
  [ -z "${fields}" ] || err "${skill}: frontmatter 只能包含 name、description"
  awk 'NR>1 && /^---$/{exit} /^description:[[:space:]]*[^[:space:]]/{found=1} END{exit !found}' "${file}" || err "${skill}: description 不得為空"

  for section in "${SECTIONS[@]}"; do
    section_nonempty "${file}" "${section}" || err "${skill}: 缺少或留空「${section}」"
  done
  if grep -En 'TODO|FIXME' "${file}" >/dev/null; then
    err "${skill}: 含 TODO/FIXME"
  fi
  while IFS= read -r resource; do
    [ -e "$(dirname "${file}")/${resource}" ] || err "${skill}: 找不到資源 ${resource}"
  done < <(grep -Eo '(references|templates|checklists)/[A-Za-z0-9._/-]+' "${file}" | sort -u || true)

  chars="$(wc -m < "${file}" | tr -d ' ')"
  TOTAL_CHARS=$((TOTAL_CHARS + chars))
  [ "${chars}" -le 3000 ] || warn "${skill}: ${chars} 字元，超過建議值 3000"
  ok "${skill} (${chars} chars)"
}

echo "=== maze-coder validate-skillpack ==="
echo "--- Skills ---"
ACTUAL_SKILLS="$(find "${ROOT_DIR}/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
[ "${ACTUAL_SKILLS}" -eq 14 ] || err "skills/ 必須恰有 14 個 SKILL.md，目前為 ${ACTUAL_SKILLS}"
for skill in "${SKILLS[@]}"; do validate_skill "${skill}"; done

[ "${TOTAL_CHARS}" -lt "${BASELINE_CHARS}" ] \
  && ok "14 份 SKILL.md 共 ${TOTAL_CHARS} 字元，低於基準 ${BASELINE_CHARS}" \
  || err "SKILL.md 總字元 ${TOTAL_CHARS} 未低於基準 ${BASELINE_CHARS}"

RISK_TDD_CHARS="$(wc -m < "${ROOT_DIR}/skills/maze-risk-driven-tdd/SKILL.md" | tr -d ' ')"
[ "${RISK_TDD_CHARS}" -le 1200 ] \
  && ok "maze-risk-driven-tdd 為 ${RISK_TDD_CHARS} 字元，不超過 1200" \
  || err "maze-risk-driven-tdd 為 ${RISK_TDD_CHARS} 字元，超過 1200"

echo "--- Duplicate paragraphs ---"
duplicate_output="$(awk '
  function flush( key) {
    gsub(/[[:space:]]+/, " ", paragraph)
    sub(/^ /, "", paragraph); sub(/ $/, "", paragraph)
    if (length(paragraph) >= 120) {
      key=paragraph SUBSEP FILENAME
      if (!seen[key]++) { files[paragraph]++; sample[paragraph]=substr(paragraph,1,60) }
    }
    paragraph=""
  }
  /^[[:space:]]*$/ { flush(); next }
  { paragraph=paragraph " " $0 }
  ENDFILE { flush() }
  END {
    for (p in files) {
      if (length(p) >= 250 && files[p] >= 3) print "FAIL|" files[p] "|" sample[p]
      else if (files[p] >= 2) print "WARN|" files[p] "|" sample[p]
    }
  }
' "${ROOT_DIR}"/skills/*/SKILL.md)"
if [ -z "${duplicate_output}" ]; then
  ok "無跨技能長段落重複"
else
  while IFS='|' read -r level count sample; do
    [ "${level}" = FAIL ] && err "重複長段落出現在 ${count} 個技能：${sample}…" || warn "相同段落出現在 ${count} 個技能：${sample}…"
  done <<< "${duplicate_output}"
fi

echo "--- Adapter resources ---"
compare_tree() {
  local target="$1" label="$2"
  if [ -d "${target}" ] && diff -qr "${ROOT_DIR}/skills" "${target}" >/dev/null 2>&1; then
    ok "${label} 技能資源一致"
  else
    err "${label} 技能資源未同步"
  fi
}

compare_tree "${ROOT_DIR}/adapters/claude-code/.claude/skills" "Claude Code"
compare_tree "${ROOT_DIR}/adapters/codex/.maze-coder/skills" "Codex"
compare_tree "${ROOT_DIR}/adapters/opencode/.maze-coder/skills" "opencode"
compare_tree "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/skills" "Cursor"

for pair in \
  "adapters/claude-code/.claude/maze-coder/HARNESS_ENGINEERING.md" \
  "adapters/codex/.maze-coder/HARNESS_ENGINEERING.md" \
  "adapters/opencode/.maze-coder/HARNESS_ENGINEERING.md" \
  "adapters/cursor/.cursor/maze-coder/HARNESS_ENGINEERING.md"; do
  cmp -s "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${ROOT_DIR}/${pair}" \
    && ok "${pair}" || err "${pair} 未同步"
done

grep -q '所有 14 個技能' "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" \
  && ok "核心 Harness 標示 14 個技能" || err "核心 Harness 未標示 14 個技能"
for readme in \
  "adapters/claude-code/README.md" \
  "adapters/codex/README.md" \
  "adapters/cursor/README.md" \
  "adapters/opencode/README.md"; do
  grep -q '14 個' "${ROOT_DIR}/${readme}" \
    && ok "${readme} 標示 14 個技能" || err "${readme} 未標示 14 個技能"
done

for router in adapters/codex/AGENTS.md adapters/opencode/AGENTS.md adapters/cursor/.cursor/rules/maze-coder-router.mdc; do
  [ -f "${ROOT_DIR}/${router}" ] || { err "缺少 ${router}"; continue; }
  for skill in "${SKILLS[@]}"; do
    grep -q "${skill}" "${ROOT_DIR}/${router}" || err "${router} 缺少 ${skill} 路由"
  done
  ok "${router}"
done

for legacy in maze-coder-core.mdc maze-coder-qa.mdc maze-coder-git.mdc maze-coder-design-review.mdc; do
  [ ! -e "${ROOT_DIR}/adapters/cursor/.cursor/rules/${legacy}" ] || err "殘留舊 Cursor rule: ${legacy}"
done

echo "--- Templates and docs ---"
TEMPLATE_MAP=(
  "maze-idea-to-spec/templates/spec.template.md:spec.md"
  "maze-project-init/templates/AGENTS.template.md:AGENTS.md"
  "maze-project-init/templates/MAZE_PROJECT.template.md:MAZE_PROJECT.md"
  "maze-project-init/templates/PROJECT_BRIEF.template.md:PROJECT_BRIEF.md"
  "maze-project-init/templates/STATUS.template.md:STATUS.md"
  "maze-project-init/templates/NEXT_ACTION.template.md:NEXT_ACTION.md"
  "maze-project-init/templates/DECISIONS.template.md:DECISIONS.md"
  "maze-qa-verification/templates/QA_REPORT.template.md:QA_REPORT.md"
  "maze-design-review/templates/DESIGN_REVIEW.template.md:DESIGN_REVIEW.md"
  "maze-repo-map/templates/REPO_MAP.template.md:REPO_MAP.md"
  "maze-handoff-summary/templates/HANDOFF.template.md:HANDOFF.md"
)
for mapping in "${TEMPLATE_MAP[@]}"; do
  src="${mapping%%:*}"; dst="${mapping#*:}"
  cmp -s "${ROOT_DIR}/skills/${src}" "${ROOT_DIR}/templates/${dst}" \
    && ok "templates/${dst}" || err "templates/${dst} 未同步"
done

grep -q '## 14 Skills' "${ROOT_DIR}/README.md" || err "README 未標示 14 Skills"
if [ -d "${ROOT_DIR}/skills/maze-session-closeout/templates" ] \
  && find "${ROOT_DIR}/skills/maze-session-closeout/templates" -type f | grep -q .; then
  err "closeout 仍含 Session Report templates"
fi

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed (${WARNINGS} warnings) ==="
else
  echo "=== ${ERRORS} failures, ${WARNINGS} warnings ===" >&2
  exit 1
fi
