#!/usr/bin/env bash
# 從 skills/ 與 core/ 產生四種 Adapter 及根 templates/。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHANGES=0

SKILLS=(
  maze-idea-to-spec
  maze-spec-hardening
  maze-project-init
  maze-spec-to-issues
  maze-spec-review
  maze-pr-review
  maze-github-cli
  maze-session-closeout
  maze-github-safe-ops
  maze-design-review
  maze-qa-verification
  maze-repo-map
  maze-context-audit
  maze-bug-reproduction
  maze-handoff-summary
  maze-token-efficiency-review
  maze-risk-driven-tdd
  maze-skill-authoring
  maze-grill
  maze-grill-with-docs
  maze-grilling
  maze-domain-modeling
)

[ -d "${ROOT_DIR}/skills" ] || { echo "ERROR: 找不到 skills/" >&2; exit 1; }

same_dir() {
  [ -d "$1" ] && diff -qr "$1" "$2" >/dev/null 2>&1
}

sync_dir() {
  local src="$1" dst="$2" label="$3"
  if same_dir "${src}" "${dst}"; then
    echo "  [SAME] ${label}"
    return
  fi
  mkdir -p "$(dirname "${dst}")"
  rm -rf "${dst}"
  cp -R "${src}" "${dst}"
  echo "  [SYNC] ${label}"
  CHANGES=$((CHANGES + 1))
}

copy_file() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "${dst}")"
  if [ -f "${dst}" ] && cmp -s "${src}" "${dst}"; then
    echo "  [SAME] ${label}"
  else
    cp "${src}" "${dst}"
    echo "  [SYNC] ${label}"
    CHANGES=$((CHANGES + 1))
  fi
}

write_if_changed() {
  local dst="$1" label="$2"
  local tmp="${dst}.tmp"
  mkdir -p "$(dirname "${dst}")"
  cat > "${tmp}"
  if [ -f "${dst}" ] && cmp -s "${tmp}" "${dst}"; then
    rm "${tmp}"
    echo "  [SAME] ${label}"
  else
    mv "${tmp}" "${dst}"
    echo "  [SYNC] ${label}"
    CHANGES=$((CHANGES + 1))
  fi
}

router_body() {
  local skill_root="$1" harness="$2"
  cat <<EOF
先讀取 \`${harness}\`，依 Host 與模型能力選擇最輕可用 Profile，再按需載入一份 Model Overlay。依意圖只載入一個最相關的公開技能；技能明示組合時才載入 internal skill，其他 references、templates 或 checklists 也只按指標讀取。

| 意圖 | 技能 |
|---|---|
| 想法轉規格 | maze-idea-to-spec |
| 補強規格 | maze-spec-hardening |
| 初始化專案文件 | maze-project-init |
| 規格拆成或同步 GitHub Issues | maze-spec-to-issues |
| 規格審查／複審 | maze-spec-review |
| PR review／審查 PR | maze-pr-review |
| 結束 session／同步狀態 | maze-session-closeout |
| Git／GitHub 安全操作 | maze-github-safe-ops |
| 設計審查 | maze-design-review |
| QA／驗收 | maze-qa-verification |
| repo 結構地圖 | maze-repo-map |
| 上下文一致性稽核 | maze-context-audit |
| Bug 重現文件 | maze-bug-reproduction |
| 跨工具／人員交接 | maze-handoff-summary |
| Token 效率稽核 | maze-token-efficiency-review |
| 新增功能、修 Bug、可觀察行為變更／TDD | maze-risk-driven-tdd |
| 評估是否新增或擴充技能 | maze-skill-authoring |
| 逐題壓力測試 | maze-grill |
| 逐題壓力測試並同步文件 | maze-grill-with-docs |
EOF
}

sync_claude_skills() {
  local tmp_root skill file invocation transformed
  tmp_root="$(mktemp -d)"
  cp -R "${ROOT_DIR}/skills" "${tmp_root}/skills"
  for skill in "${SKILLS[@]}"; do
    file="${tmp_root}/skills/${skill}/SKILL.md"
    invocation="$(awk 'NR>1 && /^---$/{exit} /^invocation:[[:space:]]*/{sub(/^invocation:[[:space:]]*/, ""); print}' "${file}")"
    transformed="${file}.tmp"
    awk -v mode="${invocation}" '
      /^invocation:/ {
        if (mode == "user") print "disable-model-invocation: true"
        else if (mode == "model") print "user-invocable: false"
        else if (mode == "internal") {
          print "user-invocable: false"
          print "disable-model-invocation: true"
        }
        next
      }
      { print }
    ' "${file}" > "${transformed}"
    mv "${transformed}" "${file}"
  done
  sync_dir "${tmp_root}/skills" "${ROOT_DIR}/adapters/claude-code/.claude/skills" "完整技能資源與 invocation metadata"
  rm -rf "${tmp_root}"
}

echo "=== maze-coder sync-adapters ==="

echo "--- Claude Code ---"
sync_claude_skills
copy_file "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${ROOT_DIR}/adapters/claude-code/.claude/maze-coder/HARNESS_ENGINEERING.md" "共用規則"
sync_dir "${ROOT_DIR}/core" "${ROOT_DIR}/adapters/claude-code/.claude/maze-coder/core" "核心契約"
sync_dir "${ROOT_DIR}/profiles" "${ROOT_DIR}/adapters/claude-code/.claude/maze-coder/profiles" "Guidance Profiles"
sync_dir "${ROOT_DIR}/model-overlays" "${ROOT_DIR}/adapters/claude-code/.claude/maze-coder/model-overlays" "Model Overlays"

for adapter in codex opencode; do
  echo "--- ${adapter} ---"
  sync_dir "${ROOT_DIR}/skills" "${ROOT_DIR}/adapters/${adapter}/.maze-coder/skills" "完整技能資源"
  copy_file "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${ROOT_DIR}/adapters/${adapter}/.maze-coder/HARNESS_ENGINEERING.md" "共用規則"
  sync_dir "${ROOT_DIR}/core" "${ROOT_DIR}/adapters/${adapter}/.maze-coder/core" "核心契約"
  sync_dir "${ROOT_DIR}/profiles" "${ROOT_DIR}/adapters/${adapter}/.maze-coder/profiles" "Guidance Profiles"
  sync_dir "${ROOT_DIR}/model-overlays" "${ROOT_DIR}/adapters/${adapter}/.maze-coder/model-overlays" "Model Overlays"
  {
    if [ "${adapter}" = codex ]; then
      echo "# maze-coder — Codex Router"
    else
      echo "# maze-coder — opencode Router"
    fi
    echo
    echo "> 由 sync-adapters.sh 產生，請勿手動編輯。"
    echo
    router_body ".maze-coder/skills" ".maze-coder/HARNESS_ENGINEERING.md"
  } | write_if_changed "${ROOT_DIR}/adapters/${adapter}/AGENTS.md" "精簡 Router"
done

echo "--- Cursor ---"
sync_dir "${ROOT_DIR}/skills" "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/skills" "完整技能資源"
copy_file "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/HARNESS_ENGINEERING.md" "共用規則"
sync_dir "${ROOT_DIR}/core" "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/core" "核心契約"
sync_dir "${ROOT_DIR}/profiles" "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/profiles" "Guidance Profiles"
sync_dir "${ROOT_DIR}/model-overlays" "${ROOT_DIR}/adapters/cursor/.cursor/maze-coder/model-overlays" "Model Overlays"
{
  echo "---"
  echo "description: maze-coder 技能路由；處理規格、Issues、Git、QA、TDD、Session、交接與 token 效率稽核"
  echo "alwaysApply: true"
  echo "---"
  echo
  router_body ".cursor/maze-coder/skills" ".cursor/maze-coder/HARNESS_ENGINEERING.md"
} | write_if_changed "${ROOT_DIR}/adapters/cursor/.cursor/rules/maze-coder-router.mdc" "精簡 Router"

for legacy in maze-coder-core.mdc maze-coder-qa.mdc maze-coder-git.mdc maze-coder-design-review.mdc; do
  path="${ROOT_DIR}/adapters/cursor/.cursor/rules/${legacy}"
  if [ -e "${path}" ]; then
    rm -f "${path}"
    echo "  [REMOVE] 舊版 ${legacy}"
    CHANGES=$((CHANGES + 1))
  fi
done

echo "--- Root templates ---"
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
  "maze-spec-review/templates/SPEC_REVIEW.template.md:SPEC_REVIEW.md"
)

for mapping in "${TEMPLATE_MAP[@]}"; do
  src_rel="${mapping%%:*}"
  dst_rel="${mapping#*:}"
  copy_file "${ROOT_DIR}/skills/${src_rel}" "${ROOT_DIR}/templates/${dst_rel}" "templates/${dst_rel}"
done

if [ "${CHANGES}" -eq 0 ]; then
  echo "=== synced（no changes）==="
else
  echo "=== synced（${CHANGES} 個受管理產物已更新）==="
fi
