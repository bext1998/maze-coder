#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ERRORS=0
WARNINGS=0
TOTAL_CHARS=0
MAX_CHARS=22000

UTF8_LOCALE="$(locale -a 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /^(C|en_US)\.(UTF-8|utf8)$/{print; exit}')"
[ -n "${UTF8_LOCALE}" ] && export LC_ALL="${UTF8_LOCALE}"

SKILLS=(
  maze-wayfinder maze-idea-to-spec maze-spec-hardening maze-project-init maze-spec-to-issues
  maze-spec-review maze-pr-review maze-adversarial-review maze-threat-modeling
  maze-root-cause-diagnosis maze-github-cli
  maze-session-closeout maze-github-safe-ops maze-design-review
  maze-qa-verification maze-design-system maze-gui-prototyping maze-repo-map maze-context-audit
  maze-bug-reproduction maze-handoff-summary maze-token-efficiency-review maze-explain-for-dumbass
  maze-risk-driven-tdd maze-skill-authoring maze-grill maze-grill-with-docs maze-grilling
  maze-domain-modeling
)
PUBLIC_SKILLS=(
  maze-wayfinder maze-idea-to-spec maze-spec-hardening maze-project-init maze-spec-to-issues
  maze-spec-review maze-pr-review maze-adversarial-review maze-threat-modeling
  maze-root-cause-diagnosis
  maze-session-closeout maze-github-safe-ops maze-design-review
  maze-qa-verification maze-design-system maze-gui-prototyping maze-repo-map maze-context-audit
  maze-bug-reproduction maze-handoff-summary maze-token-efficiency-review maze-explain-for-dumbass
  maze-risk-driven-tdd maze-skill-authoring maze-grill maze-grill-with-docs
)
INTERNAL_SKILLS=(maze-grilling maze-domain-modeling maze-github-cli)

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

  local first last name fields chars invocation
  first="$(head -n 1 "${file}")"
  last="$(awk '/^---$/{count++; if (count==2) {print NR; exit}}' "${file}")"
  [ "${first}" = "---" ] && [ "${last}" -gt 1 ] || err "${skill}: frontmatter 格式錯誤"

  name="$(awk 'NR>1 && /^---$/{exit} /^name:[[:space:]]*/{sub(/^name:[[:space:]]*/, ""); print}' "${file}")"
  [ "${name}" = "${skill}" ] || err "${skill}: name 與目錄不一致"
  fields="$(awk 'NR>1 && /^---$/{exit} NR>1 && /^[A-Za-z0-9_-]+:/{sub(/:.*/, ""); if ($0 != "name" && $0 != "description" && $0 != "invocation") print}' "${file}")"
  [ -z "${fields}" ] || err "${skill}: frontmatter 含未知欄位 ${fields}"
  awk 'NR>1 && /^---$/{exit} /^description:[[:space:]]*[^[:space:]]/{found=1} END{exit !found}' "${file}" || err "${skill}: description 不得為空"
  invocation="$(awk 'NR>1 && /^---$/{exit} /^invocation:[[:space:]]*/{sub(/^invocation:[[:space:]]*/, ""); print}' "${file}")"
  case "${invocation}" in user|model|both|internal) ;; *) err "${skill}: invocation 必須為 user、model、both 或 internal" ;; esac

  section_nonempty "${file}" "目標" || err "${skill}: 缺少或留空「目標」"
  section_nonempty "${file}" "輸出契約" || err "${skill}: 缺少或留空「輸出契約」"
  section_nonempty "${file}" "邊界" || err "${skill}: 缺少或留空「邊界」"
  (section_nonempty "${file}" "前置條件" || section_nonempty "${file}" "必要輸入") || err "${skill}: 缺少必要輸入"
  (section_nonempty "${file}" "執行流程" || section_nonempty "${file}" "核心行為") || err "${skill}: 缺少核心行為"
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
[ "${ACTUAL_SKILLS}" -eq 29 ] || err "skills/ 必須恰有 29 個 SKILL.md，目前為 ${ACTUAL_SKILLS}"
[ "${#SKILLS[@]}" -eq 29 ] || err "validator canonical skill array 不是 29"
[ "${#PUBLIC_SKILLS[@]}" -eq 26 ] || err "validator public skill array 不是 26"
[ "${#INTERNAL_SKILLS[@]}" -eq 3 ] || err "validator internal skill array 不是 3"
for skill in "${SKILLS[@]}"; do validate_skill "${skill}"; done

[ "${TOTAL_CHARS}" -lt "${MAX_CHARS}" ] \
  && ok "29 份 SKILL.md 共 ${TOTAL_CHARS} 字元，低於上限 ${MAX_CHARS}" \
  || err "SKILL.md 總字元 ${TOTAL_CHARS} 超過上限 ${MAX_CHARS}"

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

for skill in "${SKILLS[@]}"; do
  canonical="${ROOT_DIR}/skills/${skill}/SKILL.md"
  claude="${ROOT_DIR}/adapters/claude-code/.claude/skills/${skill}/SKILL.md"
  [ -f "${claude}" ] || { err "Claude Code 缺少 ${skill}"; continue; }
  diff -u \
    <(grep -vE '^(invocation|user-invocable|disable-model-invocation):' "${canonical}") \
    <(grep -vE '^(invocation|user-invocable|disable-model-invocation):' "${claude}") >/dev/null \
    || err "Claude ${skill} 行為內容與 canonical 不一致"
  invocation="$(awk 'NR>1 && /^---$/{exit} /^invocation:[[:space:]]*/{sub(/^invocation:[[:space:]]*/, ""); print}' "${canonical}")"
  case "${invocation}" in
    user) grep -q '^disable-model-invocation: true$' "${claude}" || err "Claude ${skill} 未停用模型觸發" ;;
    model) grep -q '^user-invocable: false$' "${claude}" || err "Claude ${skill} 未停用使用者入口" ;;
    internal)
      grep -q '^user-invocable: false$' "${claude}" || err "Claude ${skill} internal 仍可由使用者觸發"
      grep -q '^disable-model-invocation: true$' "${claude}" || err "Claude ${skill} internal 仍可由模型觸發"
      ;;
  esac
done
ok "Claude Code invocation metadata 已轉譯"
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

grep -q '所有 29 個 canonical skills' "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" \
  && ok "核心 Harness 標示 29 個技能" || err "核心 Harness 未標示 29 個技能"
for readme in \
  "adapters/claude-code/README.md" \
  "adapters/codex/README.md" \
  "adapters/cursor/README.md" \
  "adapters/opencode/README.md"; do
  grep -q '29 個' "${ROOT_DIR}/${readme}" \
    && ok "${readme} 標示 29 個技能" || err "${readme} 未標示 29 個技能"
done

for router in adapters/codex/AGENTS.md adapters/opencode/AGENTS.md adapters/cursor/.cursor/rules/maze-coder-router.mdc; do
  [ -f "${ROOT_DIR}/${router}" ] || { err "缺少 ${router}"; continue; }
  for skill in "${PUBLIC_SKILLS[@]}"; do
    grep -q "${skill}" "${ROOT_DIR}/${router}" || err "${router} 缺少 ${skill} 路由"
  done
  for skill in "${INTERNAL_SKILLS[@]}"; do
    ! grep -q "${skill}" "${ROOT_DIR}/${router}" || err "${router} 公開 internal skill ${skill}"
  done
  ok "${router}"
done

for legacy in maze-coder-core.mdc maze-coder-qa.mdc maze-coder-git.mdc maze-coder-design-review.mdc; do
  [ ! -e "${ROOT_DIR}/adapters/cursor/.cursor/rules/${legacy}" ] || err "殘留舊 Cursor rule: ${legacy}"
done

echo "--- Templates and docs ---"
SPEC_FILE="${ROOT_DIR}/docs/spec.md"
grep -q '29 個 canonical skills：26 個公開或可由模型觸發的技能、3 個 internal skills' "${SPEC_FILE}" \
  && ok "spec 標示 29／26／3 技能拓撲" || err "spec 未標示 29／26／3 技能拓撲"
grep -q '26 個 adaptive scenarios' "${SPEC_FILE}" \
  && ok "spec 標示 26 個 adaptive scenarios" || err "spec 未標示 26 個 adaptive scenarios"
grep -q '總字元上限固定為 22,000' "${SPEC_FILE}" \
  && ok "spec 標示 22,000 字元上限" || err "spec 未標示 22,000 字元上限"
if grep -Eq '28 個 canonical skills|28 個 SKILL\.md|固定驗證 28 個 SKILL\.md|完成後技能數固定為 28／25／3' "${SPEC_FILE}"; then
  err "spec 仍含過期技能、情境或字元上限"
else
  ok "spec 無過期技能、情境或字元上限"
fi
awk -F '|' '
  NR > 6 && NF >= 5 {
    rows++
    if ($4 !~ /\]\((adr\/[^)]+|https:\/\/github\.com\/[^/]+\/[^/]+\/(issues|pull)\/[0-9]+)\)/) invalid=1
  }
  END { exit !(rows > 0 && !invalid) }
' "${ROOT_DIR}/docs/DECISIONS.md" \
  && ok "DECISIONS 僅索引 ADR／Issue／PR" || err "DECISIONS 含非 ADR／Issue／PR 的權威來源"

TEMPLATE_MAP=(
  "maze-wayfinder/templates/WAYFINDER_MAP.template.md:WAYFINDER_MAP.md"
  "maze-idea-to-spec/templates/spec.template.md:spec.md"
  "maze-project-init/templates/AGENTS.template.md:AGENTS.md"
  "maze-project-init/templates/MAZE_PROJECT.template.md:MAZE_PROJECT.md"
  "maze-project-init/templates/PROJECT_BRIEF.template.md:PROJECT_BRIEF.md"
  "maze-project-init/templates/NEXT_ACTION.template.md:NEXT_ACTION.md"
  "maze-project-init/templates/DECISIONS.template.md:DECISIONS.md"
  "maze-qa-verification/templates/QA_REPORT.template.md:QA_REPORT.md"
  "maze-design-review/templates/DESIGN_REVIEW.template.md:DESIGN_REVIEW.md"
  "maze-design-system/templates/DESIGN_SYSTEM.template.md:DESIGN_SYSTEM.md"
  "maze-gui-prototyping/templates/PROTOTYPE_BRIEF.template.md:PROTOTYPE_BRIEF.md"
  "maze-repo-map/templates/REPO_MAP.template.md:REPO_MAP.md"
  "maze-handoff-summary/templates/HANDOFF.template.md:HANDOFF.md"
  "maze-spec-review/templates/SPEC_REVIEW.template.md:SPEC_REVIEW.md"
)
for mapping in "${TEMPLATE_MAP[@]}"; do
  src="${mapping%%:*}"; dst="${mapping#*:}"
  cmp -s "${ROOT_DIR}/skills/${src}" "${ROOT_DIR}/templates/${dst}" \
    && ok "templates/${dst}" || err "templates/${dst} 未同步"
done

grep -q '## 29 Canonical Skills' "${ROOT_DIR}/README.md" || err "README 未標示 29 Canonical Skills"

echo "--- Adaptive architecture ---"
for file in core/invariants.md core/workflow-model.md profiles/minimal.md profiles/standard.md profiles/scaffolded.md model-overlays/gpt-5.6.md model-overlays/claude.md model-overlays/gemini.md model-overlays/local-small-model.md; do
  [ -s "${ROOT_DIR}/${file}" ] && ok "${file}" || err "缺少或空白 ${file}"
done
for root in \
  adapters/claude-code/.claude/maze-coder \
  adapters/codex/.maze-coder \
  adapters/opencode/.maze-coder \
  adapters/cursor/.cursor/maze-coder; do
  diff -qr "${ROOT_DIR}/core" "${ROOT_DIR}/${root}/core" >/dev/null 2>&1 || err "${root}/core 未同步"
  diff -qr "${ROOT_DIR}/profiles" "${ROOT_DIR}/${root}/profiles" >/dev/null 2>&1 || err "${root}/profiles 未同步"
  diff -qr "${ROOT_DIR}/model-overlays" "${ROOT_DIR}/${root}/model-overlays" >/dev/null 2>&1 || err "${root}/model-overlays 未同步"
done

if grep -R -En 'TODO|FIXME' "${ROOT_DIR}/skills" "${ROOT_DIR}/core" "${ROOT_DIR}/profiles" "${ROOT_DIR}/model-overlays" | grep -v 'TODO/FIXME\|禁止使用' >/dev/null; then
  err "canonical 內容含 TODO/FIXME"
fi
if [ -d "${ROOT_DIR}/skills/maze-session-closeout/templates" ] \
  && find "${ROOT_DIR}/skills/maze-session-closeout/templates" -type f | grep -q .; then
  err "closeout 仍含 Session Report templates"
fi
if [ -e "${ROOT_DIR}/docs/STATUS.md" ] || [ -e "${ROOT_DIR}/skills/maze-project-init/templates/STATUS.template.md" ] || [ -e "${ROOT_DIR}/templates/STATUS.md" ]; then
  err "STATUS.md 不得由 canonical 或根模板保留"
else
  ok "STATUS.md 已退休且不再生成"
fi

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed (${WARNINGS} warnings) ==="
else
  echo "=== ${ERRORS} failures, ${WARNINGS} warnings ===" >&2
  exit 1
fi
