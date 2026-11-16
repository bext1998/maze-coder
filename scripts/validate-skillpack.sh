#!/usr/bin/env bash
# 技能結構檢查：frontmatter、必要區段、資源路徑與已移除架構的殘留字串。
# 只依 skills/ 為事實來源；不檢查任何生成物，也不寫死技能總數。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${ROOT_DIR}/skills"
ERRORS=0
WARNINGS=0
MAX_DESC_CHARS=200
MAX_SKILL_CHARS=3000

# 可由模型主動載入的技能：不加 disable-model-invocation，使用者也可直接呼叫。
# 新增技能時先決定它屬於哪一類，再更新這份清單或加上 frontmatter 欄位。
MODEL_INVOCABLE_SKILLS=(
  maze-context-audit
  maze-explain-for-dumbass
  maze-github-safe-ops
  maze-idea-to-spec
  maze-risk-driven-tdd
  maze-skill-authoring
  maze-spec-hardening
  maze-wayfinder
)

UTF8_LOCALE="$(locale -a 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /^(C|en_US)\.(UTF-8|utf8)$/{print; exit}')"
[ -n "${UTF8_LOCALE}" ] && export LC_ALL="${UTF8_LOCALE}"

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

is_model_invocable() {
  local name="$1" candidate
  for candidate in "${MODEL_INVOCABLE_SKILLS[@]}"; do
    [ "${candidate}" = "${name}" ] && return 0
  done
  return 1
}

# 取出反引號內的候選相對路徑，解析後回報不存在的檔案。
# 以技能根目錄為基準解 references/、templates/、checklists/；以檔案所在目錄為基準解 ../。
# 取出反引號內的候選相對路徑，解析後回報不存在的檔案或目錄。
# 以技能根目錄為基準解 references/、templates/、checklists/、examples/；以檔案所在目錄為基準解 ../。
check_reference_paths() {
  local skill="$1" file="$2" skill_dir="${SKILLS_DIR}/${skill}" token base rel resolved
  rel="${file#"${skill_dir}"/}"
  while IFS= read -r token; do
    [ -n "${token}" ] || continue
    case "${token}" in
      http://*|https://*|*'://'*) continue ;;
      ../*) base="${skill_dir}/$(dirname "${rel}")" ;;
      references/*|templates/*|checklists/*|examples/*) base="${skill_dir}" ;;
      *) continue ;;
    esac
    case "${token}" in
      */)
        [ -d "${base}/${token}" ] \
          || err "${skill}: 找不到目錄 ${token}（相對於 ${base}，出自 ${file#"${ROOT_DIR}/"}）"
        ;;
      *)
        [ -e "${base}/${token}" ] \
          || err "${skill}: 找不到 ${token}（相對於 ${base}，出自 ${file#"${ROOT_DIR}/"}）"
        ;;
    esac
    case "${token}" in
      ../*)
        resolved="$(cd "${base}" 2>/dev/null && cd "$(dirname "${token}")" 2>/dev/null && pwd)"
        case "${resolved}" in
          "${SKILLS_DIR}"*) ;;
          "") ;;
          *) err "${skill}: ${token} 解析後離開 skills/（${resolved}）" ;;
        esac
        ;;
    esac
  done < <(awk '{
      line=$0
      while (match(line, /`[^`]+`/)) {
        print substr(line, RSTART+1, RLENGTH-2)
        line=substr(line, RSTART+RLENGTH)
      }
    }' "${file}" | grep -E '(^\.\./)|^references/|^templates/|^checklists/|^examples/' || true)
  return 0
}

# 技能目錄任一檔案若以相對路徑引用其他技能（`../maze-X/`），SKILL.md 必須寫明
# 需要同時安裝 maze-X；只安裝單一技能時，那條引用會斷。
check_cross_skill_install() {
  local skill="$1" dep
  while IFS= read -r dep; do
    [ -n "${dep}" ] || continue
    grep -Eq "同時安裝.*${dep}|${dep}.*同時安裝" "${SKILLS_DIR}/${skill}/SKILL.md" \
      || err "${skill}: 引用 ${dep} 的檔案，但 SKILL.md 未寫明需要同時安裝 ${dep}"
  done < <(grep -rhoE '\.\./(\.\./)*maze-[a-z0-9-]+/' "${SKILLS_DIR}/${skill}" \
             | sed -E 's|^(\.\./)+||; s|/$||' | sort -u)
}

validate_skill() {
  local skill="$1" skill_dir="${SKILLS_DIR}/${skill}" file="${SKILLS_DIR}/${skill}/SKILL.md"
  if [ ! -f "${file}" ]; then
    err "缺少 skills/${skill}/SKILL.md"
    return
  fi

  local first close name desc_len chars fields invocation_key
  first="$(head -n 1 "${file}")"
  close="$(awk '/^---$/{count++; if (count==2) {print NR; exit}}' "${file}")"
  [ "${first}" = "---" ] && [ "${close}" -gt 1 ] || err "${skill}: frontmatter 格式錯誤"

  name="$(awk 'NR>1 && /^---$/{exit} /^name:[[:space:]]*/{sub(/^name:[[:space:]]*/, ""); print}' "${file}")"
  [ "${name}" = "${skill}" ] || err "${skill}: name 與目錄不一致"

  fields="$(awk 'NR>1 && /^---$/{exit} NR>1 && /^[A-Za-z0-9_-]+:/{sub(/:.*/, ""); if ($0 != "name" && $0 != "description" && $0 != "disable-model-invocation") print}' "${file}")"
  [ -z "${fields}" ] || err "${skill}: frontmatter 含未允許欄位 ${fields}（只允許 name、description、disable-model-invocation）"

  awk 'NR>1 && /^---$/{exit} /^description:[[:space:]]*[^[:space:]]/{found=1} END{exit !found}' "${file}" \
    || err "${skill}: description 不得為空"
  desc_len="$(awk 'NR>1 && /^---$/{exit} /^description:/{sub(/^description:[[:space:]]*/, ""); print length($0)}' "${file}")"
  [ "${desc_len}" -le "${MAX_DESC_CHARS}" ] || err "${skill}: description ${desc_len} 字元超過 ${MAX_DESC_CHARS} 上限（觸發詞應前置，細節留在 SKILL.md）"

  invocation_key="$(awk 'NR>1 && /^---$/{exit} /^invocation:/{print}' "${file}")"
  [ -z "${invocation_key}" ] || err "${skill}: 不得再使用自訂 invocation 欄位，請改用 disable-model-invocation"

  dmi="$(awk 'NR>1 && /^---$/{exit} /^disable-model-invocation:/{sub(/^disable-model-invocation:[[:space:]]*/, ""); gsub(/[[:space:]]+$/, ""); print}' "${file}")"
  if [ -n "${dmi}" ]; then
    if [ "${dmi}" = "true" ]; then
      is_model_invocable "${skill}" && err "${skill}: 列在 MODEL_INVOCABLE_SKILLS，frontmatter 卻含 disable-model-invocation: true"
    else
      err "${skill}: frontmatter 的 disable-model-invocation 只接受 true"
    fi
  else
    is_model_invocable "${skill}" || err "${skill}: 使用者明示觸發的技能必須在 frontmatter 含 disable-model-invocation: true（或把它加入 MODEL_INVOCABLE_SKILLS）"
  fi

  section_nonempty "${file}" "目標" || err "${skill}: 缺少或留空「目標」"
  section_nonempty "${file}" "輸出契約" || err "${skill}: 缺少或留空「輸出契約」"
  section_nonempty "${file}" "邊界" || err "${skill}: 缺少或留空「邊界」"
  (section_nonempty "${file}" "前置條件" || section_nonempty "${file}" "必要輸入") || err "${skill}: 缺少必要輸入"
  (section_nonempty "${file}" "執行流程" || section_nonempty "${file}" "核心行為") || err "${skill}: 缺少核心行為"
  grep -En 'TODO|FIXME' "${file}" >/dev/null && err "${skill}: 含 TODO/FIXME"

  while IFS= read -r resource_file; do
    check_reference_paths "${skill}" "${resource_file}"
  done < <(find "${skill_dir}" -type f -name '*.md' | LC_ALL=C sort)

  check_cross_skill_install "${skill}"

  chars="$(wc -m < "${file}" | tr -d ' ')"
  [ "${chars}" -le "${MAX_SKILL_CHARS}" ] || warn "${skill}: ${chars} 字元，超過建議值 ${MAX_SKILL_CHARS}"
  ok "${skill} (${chars} chars)"
}

echo "=== maze-coder validate-skillpack ==="
echo "--- Skills ---"
ACTUAL_SKILLS="$(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
[ "${ACTUAL_SKILLS}" -ge 1 ] || err "skills/ 底下找不到任何 SKILL.md"
ok "skills/ 底下共 ${ACTUAL_SKILLS} 個技能（不寫死總數）"

for listed in "${MODEL_INVOCABLE_SKILLS[@]}"; do
  [ -d "${SKILLS_DIR}/${listed}" ] || err "MODEL_INVOCABLE_SKILLS 列出的 ${listed} 不存在於 skills/"
done

for skill in $(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md | LC_ALL=C sort | while IFS= read -r f; do basename "$(dirname "$f")"; done); do
  validate_skill "${skill}"
done


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
' "${SKILLS_DIR}"/*/SKILL.md)"
if [ -z "${duplicate_output}" ]; then
  ok "無跨技能長段落重複"
else
  while IFS='|' read -r level count sample; do
    [ "${level}" = FAIL ] && err "重複長段落出現在 ${count} 個技能：${sample}…" || warn "相同段落出現在 ${count} 個技能：${sample}…"
  done <<< "${duplicate_output}"
fi

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed (${WARNINGS} warnings) ==="
else
  echo "=== ${ERRORS} failures, ${WARNINGS} warnings ===" >&2
  exit 1
fi
