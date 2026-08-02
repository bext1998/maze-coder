#!/usr/bin/env bash
# 從 skills/ 與 core/ 產生五種 Adapter 及根 templates/。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHANGES=0

SKILLS=(
  maze-wayfinder
  maze-idea-to-spec
  maze-spec-hardening
  maze-project-init
  maze-spec-to-issues
  maze-spec-review
  maze-pr-review
  maze-adversarial-review
  maze-threat-modeling
  maze-root-cause-diagnosis
  maze-github-cli
  maze-session-closeout
  maze-github-safe-ops
  maze-design-review
  maze-qa-verification
  maze-design-system
  maze-gui-prototyping
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

# 對單一檔案做精確字串（非正則）替換：用 awk index()/substr() 逐行找第一個相符位置替換，
# 避免 sed 正則特殊字元（如路徑裡的 .）造成誤判。替換前後都斷言字串真的存在／已替換，
# 找不到就直接失敗，不靜默略過——canonical 內容變了，這裡的改寫表也要跟著更新。
literal_replace() {
  local target="$1" old="$2" new="$3" tmp
  grep -qF -- "${old}" "${target}" \
    || { echo "ERROR: 預期在 ${target} 找到「${old}」以改寫參照，但找不到（canonical 內容可能已變更，需同步更新 sync-adapters.sh 的改寫表）" >&2; exit 1; }
  tmp="${target}.tmp"
  awk -v old="${old}" -v new="${new}" '
    {
      line = $0
      idx = index(line, old)
      if (idx > 0) { line = substr(line, 1, idx - 1) new substr(line, idx + length(old)) }
      print line
    }
  ' "${target}" > "${tmp}"
  mv "${tmp}" "${target}"
  grep -qF -- "${new}" "${target}" \
    || { echo "ERROR: 改寫 ${target} 的參照後未生效" >&2; exit 1; }
}

router_body() {
  local skill_root="$1" harness="$2"
  cat <<EOF
先讀取 \`${harness}\`，依 Host 與模型能力選擇最輕可用 Profile，再按需載入一份 Model Overlay。依意圖只載入一個最相關的公開技能；技能明示組合時才載入 internal skill，其他 references、templates 或 checklists 也只按指標讀取。

| 意圖 | 技能 |
|---|---|
| 需求太模糊、連想要什麼都不確定 | maze-wayfinder |
| 想法轉規格 | maze-idea-to-spec |
| 補強規格 | maze-spec-hardening |
| 初始化專案文件 | maze-project-init |
| 規格拆成或同步 GitHub Issues | maze-spec-to-issues |
| 規格審查／複審 | maze-spec-review |
| PR review／審查 PR | maze-pr-review |
| 實作前挑戰方案／找反證 | maze-adversarial-review |
| 實作前威脅模型／濫用分析 | maze-threat-modeling |
| Bug 根因診斷 | maze-root-cause-diagnosis |
| 結束 session／同步狀態 | maze-session-closeout |
| Git／GitHub 安全操作 | maze-github-safe-ops |
| 設計審查 | maze-design-review |
| QA／驗收 | maze-qa-verification |
| 建立／演進設計語言、Design Tokens 或指定元件 | maze-design-system |
| 桌面 GUI／HTML、CSS、SVG 原型 | maze-gui-prototyping |
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

PI_INTERNAL_SKILLS=(maze-grilling maze-domain-modeling maze-github-cli)

sync_pi_skills() {
  local tmp_root skill file invocation transformed internal_skill
  tmp_root="$(mktemp -d)"
  cp -R "${ROOT_DIR}/skills" "${tmp_root}/skills"
  for skill in "${SKILLS[@]}"; do
    file="${tmp_root}/skills/${skill}/SKILL.md"
    invocation="$(awk 'NR>1 && /^---$/{exit} /^invocation:[[:space:]]*/{sub(/^invocation:[[:space:]]*/, ""); print}' "${file}")"
    transformed="${file}.tmp"
    awk -v mode="${invocation}" '
      /^invocation:/ {
        if (mode == "user" || mode == "internal") print "disable-model-invocation: true"
        next
      }
      { print }
    ' "${file}" > "${transformed}"
    mv "${transformed}" "${file}"
  done

  # Pi 會遞迴掃描 .pi/skills/ 底下任何含 SKILL.md 的目錄並各自註冊一個 /skill:<name> 使用者
  # 指令；disable-model-invocation 只能隱藏「模型主動選用」那一半，Pi 沒有逐技能停用使用者
  # 指令的欄位，無法只靠 frontmatter 讓 internal skill 不出現在公開入口。唯一作法是讓這 3 個
  # internal skill 完全不落在 Pi 會掃描的路徑下：搬到 .pi/maze-coder/internal-skills/——這裡
  # 不在 Pi 文件列出的任何技能探索位置（.pi/skills、.agents/skills、套件 skills/、settings
  # skills 陣列、CLI --skill）之內，Pi 不會發現它，也就不會註冊指令或列進模型可見清單。
  #
  # 公開技能原本用相對路徑或純文字提及這 3 個 internal skill 來組合內容，搬家後必須同步改寫，
  # 否則模型照原文字讀不到。以下只對「已知會引用這 3 個 internal skill」的固定檔案做精確字串
  # 替換（見 literal_replace），不是全域正則猜測，避免誤改到無關文字。
  literal_replace "${tmp_root}/skills/maze-grill/SKILL.md" \
    '../maze-grilling/SKILL.md' '../../maze-coder/internal-skills/maze-grilling/SKILL.md'
  literal_replace "${tmp_root}/skills/maze-grill-with-docs/SKILL.md" \
    '../maze-grilling/SKILL.md' '../../maze-coder/internal-skills/maze-grilling/SKILL.md'
  literal_replace "${tmp_root}/skills/maze-grill-with-docs/SKILL.md" \
    '../maze-domain-modeling/SKILL.md' '../../maze-coder/internal-skills/maze-domain-modeling/SKILL.md'
  literal_replace "${tmp_root}/skills/maze-github-safe-ops/SKILL.md" \
    '委派 internal `maze-github-cli`' \
    '委派 internal `maze-github-cli`（Pi 路徑：`../../maze-coder/internal-skills/maze-github-cli/SKILL.md`）'
  literal_replace "${tmp_root}/skills/maze-pr-review/SKILL.md" \
    '透過 `maze-github-cli` Read 契約取得證據' \
    '透過 `maze-github-cli`（Pi 路徑：`../../maze-coder/internal-skills/maze-github-cli/SKILL.md`）Read 契約取得證據'

  mkdir -p "${tmp_root}/internal-skills"
  for internal_skill in "${PI_INTERNAL_SKILLS[@]}"; do
    mv "${tmp_root}/skills/${internal_skill}" "${tmp_root}/internal-skills/${internal_skill}"
  done

  sync_dir "${tmp_root}/skills" "${ROOT_DIR}/adapters/pi/.pi/skills" "25 個公開／模型可觸發技能資源與 invocation metadata（Pi 原生對應，僅 disable-model-invocation 有對等欄位）"
  sync_dir "${tmp_root}/internal-skills" "${ROOT_DIR}/adapters/pi/.pi/maze-coder/internal-skills" "3 個 internal skill 內容，移出 Pi 技能探索路徑以避免 /skill:<name> 曝光"
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
  echo "description: maze-coder 技能路由；處理規格、對抗審查、威脅模型、根因診斷、Issues、Git、設計系統、GUI 原型、QA、TDD、Session、交接與 token 效率稽核"
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

echo "--- Pi ---"
sync_pi_skills
copy_file "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${ROOT_DIR}/adapters/pi/.pi/maze-coder/HARNESS_ENGINEERING.md" "共用規則"
sync_dir "${ROOT_DIR}/core" "${ROOT_DIR}/adapters/pi/.pi/maze-coder/core" "核心契約"
sync_dir "${ROOT_DIR}/profiles" "${ROOT_DIR}/adapters/pi/.pi/maze-coder/profiles" "Guidance Profiles"
sync_dir "${ROOT_DIR}/model-overlays" "${ROOT_DIR}/adapters/pi/.pi/maze-coder/model-overlays" "Model Overlays"
{
  echo "# maze-coder — Pi Router"
  echo
  echo "> 由 sync-adapters.sh 產生，請勿手動編輯。"
  echo
  router_body ".pi/maze-coder/skills" ".pi/maze-coder/HARNESS_ENGINEERING.md"
} | write_if_changed "${ROOT_DIR}/adapters/pi/AGENTS.md" "精簡 Router"

echo "--- Root templates ---"
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
  src_rel="${mapping%%:*}"
  dst_rel="${mapping#*:}"
  copy_file "${ROOT_DIR}/skills/${src_rel}" "${ROOT_DIR}/templates/${dst_rel}" "templates/${dst_rel}"
done

if [ "${CHANGES}" -eq 0 ]; then
  echo "=== synced（no changes）==="
else
  echo "=== synced（${CHANGES} 個受管理產物已更新）==="
fi
