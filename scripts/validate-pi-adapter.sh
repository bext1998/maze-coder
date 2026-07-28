#!/usr/bin/env bash
# Pi Adapter 相容性驗證：技能探索、frontmatter 轉譯、user/model/both/internal 映射、
# 名稱碰撞與技能數量漂移。不執行 pi CLI 本身，純靜態檢查 adapters/pi/ 產物。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PI_SKILLS_DIR="${ROOT_DIR}/adapters/pi/.pi/skills"
PI_MAZE_DIR="${ROOT_DIR}/adapters/pi/.pi/maze-coder"
PI_AGENTS="${ROOT_DIR}/adapters/pi/AGENTS.md"
ERRORS=0
WARNINGS=0

SKILLS=(
  maze-idea-to-spec maze-spec-hardening maze-project-init maze-spec-to-issues
  maze-spec-review maze-pr-review maze-adversarial-review maze-threat-modeling
  maze-root-cause-diagnosis maze-github-cli
  maze-session-closeout maze-github-safe-ops maze-design-review
  maze-qa-verification maze-design-system maze-gui-prototyping maze-repo-map maze-context-audit
  maze-bug-reproduction maze-handoff-summary maze-token-efficiency-review
  maze-risk-driven-tdd maze-skill-authoring maze-grill maze-grill-with-docs maze-grilling
  maze-domain-modeling
)
PUBLIC_SKILLS=(
  maze-idea-to-spec maze-spec-hardening maze-project-init maze-spec-to-issues
  maze-spec-review maze-pr-review maze-adversarial-review maze-threat-modeling
  maze-root-cause-diagnosis
  maze-session-closeout maze-github-safe-ops maze-design-review
  maze-qa-verification maze-design-system maze-gui-prototyping maze-repo-map maze-context-audit
  maze-bug-reproduction maze-handoff-summary maze-token-efficiency-review
  maze-risk-driven-tdd maze-skill-authoring maze-grill maze-grill-with-docs
)
INTERNAL_SKILLS=(maze-grilling maze-domain-modeling maze-github-cli)

ok() { echo "  [OK]   $1"; }
err() { echo "  [FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "  [WARN] $1" >&2; WARNINGS=$((WARNINGS + 1)); }

frontmatter_value() {
  # $1=file $2=key
  awk -v key="^${2}:[[:space:]]*" 'NR>1 && /^---$/{exit} $0 ~ key{sub(key, ""); print}' "$1"
}

echo "=== maze-coder validate-pi-adapter ==="

[ -d "${PI_SKILLS_DIR}" ] || { err "缺少 ${PI_SKILLS_DIR}"; echo "=== ${ERRORS} failures ===" >&2; exit 1; }

echo "--- 技能數量與探索 ---"
ACTUAL_DIRS="$(find "${PI_SKILLS_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
ACTUAL_SKILL_MD="$(find "${PI_SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
[ "${ACTUAL_DIRS}" -eq 27 ] || err "adapters/pi/.pi/skills 目錄數應為 27，實際為 ${ACTUAL_DIRS}（技能數量漂移）"
[ "${ACTUAL_SKILL_MD}" -eq 27 ] || err "adapters/pi/.pi/skills 下可解析的 SKILL.md 應為 27，實際為 ${ACTUAL_SKILL_MD}（Pi 實際可發現數量與預期不符）"
[ "${#SKILLS[@]}" -eq 27 ] && [ "${#PUBLIC_SKILLS[@]}" -eq 24 ] && [ "${#INTERNAL_SKILLS[@]}" -eq 3 ] \
  && ok "validator 內建 27／24／3 技能拓撲" || err "validator 內建技能拓撲不是 27／24／3"

echo "--- 逐技能：可解析、name、description、路徑引用 ---"
declare -A NAME_TO_PATH
for skill in "${SKILLS[@]}"; do
  file="${PI_SKILLS_DIR}/${skill}/SKILL.md"
  canonical="${ROOT_DIR}/skills/${skill}/SKILL.md"

  if [ ! -f "${file}" ]; then
    err "${skill}: 缺少 adapters/pi/.pi/skills/${skill}/SKILL.md（路徑：${file}，原因：sync-adapters.sh 未產生或未同步）"
    continue
  fi

  first="$(head -n 1 "${file}")"
  last="$(awk '/^---$/{count++; if (count==2) {print NR; exit}}' "${file}")"
  if [ "${first}" != "---" ] || [ -z "${last}" ]; then
    err "${skill}: SKILL.md frontmatter 無法解析（路徑：${file}，原因：缺少成對的 --- fence）"
    continue
  fi

  name="$(frontmatter_value "${file}" name)"
  [ "${name}" = "${skill}" ] || err "${skill}: frontmatter name 為「${name}」，與目錄名不一致（路徑：${file}）"
  [ -n "${name}" ] && NAME_TO_PATH["${name}"]+="${file};"

  desc="$(frontmatter_value "${file}" description)"
  [ -n "${desc}" ] || err "${skill}: description 為空，Pi 會拒絕載入此技能（路徑：${file}）"

  # invocation 映射正確性：對照 canonical invocation 值
  canonical_invocation="$(frontmatter_value "${canonical}" invocation)"
  pi_disable="$(frontmatter_value "${file}" disable-model-invocation)"
  case "${canonical_invocation}" in
    user|internal)
      [ "${pi_disable}" = "true" ] || err "${skill}: canonical invocation=${canonical_invocation}，但 Pi 版本缺少 disable-model-invocation: true（路徑：${file}，原因：sync 轉譯未套用或已被覆寫）"
      ;;
    both|model|"")
      [ -z "${pi_disable}" ] || err "${skill}: canonical invocation=${canonical_invocation:-（空）}，Pi 版本卻含 disable-model-invocation（路徑：${file}，原因：不應轉譯此類別）"
      ;;
    *)
      err "${skill}: canonical invocation 值「${canonical_invocation}」不是 user/model/both/internal 之一（路徑：${canonical}）"
      ;;
  esac

  # references/templates/checklists 路徑有效性（不含 scripts：該詞在技能內文常指 repo 根目錄的
  # scripts/sync-adapters.sh 等指令範例，不是技能自身目錄下的資源，納入會誤判，故與
  # validate-skillpack.sh 採用相同、已驗證過的比對範圍）
  while IFS= read -r resource; do
    [ -e "$(dirname "${file}")/${resource}" ] || err "${skill}: 引用的資源路徑不存在：${resource}（路徑：$(dirname "${file}")/${resource}）"
  done < <(grep -Eo '(references|templates|checklists)/[A-Za-z0-9._/-]+' "${file}" | sort -u || true)

  # 內容一致性（排除 invocation/disable-model-invocation 轉譯欄位）
  if ! diff -q \
      <(grep -vE '^(invocation|disable-model-invocation):' "${canonical}") \
      <(grep -vE '^(invocation|disable-model-invocation):' "${file}") >/dev/null 2>&1; then
    err "${skill}: Pi 版本行為內容與 canonical 不一致（路徑：${file}）"
  fi

  ok "${skill}"
done

echo "--- 名稱碰撞（adapter 內部） ---"
collision_found=0
for name in "${!NAME_TO_PATH[@]}"; do
  paths="${NAME_TO_PATH[${name}]}"
  count="$(echo "${paths}" | tr ';' '\n' | grep -c . || true)"
  if [ "${count}" -gt 1 ]; then
    err "技能名稱「${name}」在 adapters/pi/.pi/skills 內出現 ${count} 次，會造成 Pi 只載入第一個、其餘被靜默忽略（路徑：${paths%;}）"
    collision_found=1
  fi
done
[ "${collision_found}" -eq 0 ] && ok "adapters/pi/.pi/skills 內無重複 name（無同技能被重複來源載入兩次的風險）"

echo "--- public／internal 邊界（AGENTS.md 路由表 + disable-model-invocation） ---"
[ -f "${PI_AGENTS}" ] || err "缺少 ${PI_AGENTS}"
if [ -f "${PI_AGENTS}" ]; then
  for skill in "${PUBLIC_SKILLS[@]}"; do
    grep -q "${skill}" "${PI_AGENTS}" || err "adapters/pi/AGENTS.md 缺少公開技能 ${skill} 的路由（路徑：${PI_AGENTS}）"
  done
  for skill in "${INTERNAL_SKILLS[@]}"; do
    ! grep -q "${skill}" "${PI_AGENTS}" || err "adapters/pi/AGENTS.md 路由表公開了 internal skill ${skill}（路徑：${PI_AGENTS}）"
  done
  ok "adapters/pi/AGENTS.md 路由表 24 公開／不含 3 internal"
fi
for skill in "${INTERNAL_SKILLS[@]}"; do
  file="${PI_SKILLS_DIR}/${skill}/SKILL.md"
  [ -f "${file}" ] || continue
  pi_disable="$(frontmatter_value "${file}" disable-model-invocation)"
  if [ "${pi_disable}" = "true" ]; then
    warn "${skill}: 已設定 disable-model-invocation（模型不會主動選用），但 Pi 無逐技能停用 /skill:${skill} 使用者指令的機制——此技能的 /skill:${skill} 入口在 Pi 下仍會註冊，屬已記錄的平台限制（見 adapters/pi/README.md），非本次同步可修復"
  fi
done

echo "--- 核心契約與 Guidance 同步 ---"
cmp -s "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${PI_MAZE_DIR}/HARNESS_ENGINEERING.md" \
  && ok "HARNESS_ENGINEERING.md 已同步" || err "adapters/pi/.pi/maze-coder/HARNESS_ENGINEERING.md 未同步"
for d in core profiles model-overlays; do
  diff -qr "${ROOT_DIR}/${d}" "${PI_MAZE_DIR}/${d}" >/dev/null 2>&1 \
    && ok "${d} 已同步" || err "adapters/pi/.pi/maze-coder/${d} 未同步"
done

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed (${WARNINGS} warnings，含已記錄的 Pi 平台限制) ==="
else
  echo "=== ${ERRORS} failures, ${WARNINGS} warnings ===" >&2
  exit 1
fi
