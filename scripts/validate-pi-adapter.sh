#!/usr/bin/env bash
# Pi Adapter 相容性驗證：技能探索、frontmatter 轉譯、user/model/both/internal 映射、
# 名稱碰撞與技能數量漂移。核心掃描邏輯依 Pi 官方文件的遞迴探索規則實作（不限固定深度、
# 也檢查根層 .md 檔），並先對 scripts/fixtures/pi-adapter-selftest/ 跑一次自我測試，
# 確認偵測邏輯本身沒有回歸。預設不執行 pi CLI 本身；設定 PI_ADAPTER_LIVE_CHECK=1 且本機
# 有 pi 時，額外跑一次真實 loader 交叉核對（會產生真實 API 呼叫成本，預設關閉）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PI_SKILLS_DIR="${ROOT_DIR}/adapters/pi/.pi/skills"
PI_INTERNAL_DIR="${ROOT_DIR}/adapters/pi/.pi/maze-coder/internal-skills"
PI_MAZE_DIR="${ROOT_DIR}/adapters/pi/.pi/maze-coder"
PI_ROOT="${ROOT_DIR}/adapters/pi/.pi"
PI_AGENTS="${ROOT_DIR}/adapters/pi/AGENTS.md"
FIXTURE_DIR="${SCRIPT_DIR}/fixtures/pi-adapter-selftest"
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
REPO_ROOT_SCRIPTS=(sync-adapters.sh validate-skillpack.sh validate-skills-functional.sh validate-adaptive-scenarios.sh validate-pi-adapter.sh)

ok() { echo "  [OK]   $1"; }
err() { echo "  [FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "  [WARN] $1" >&2; WARNINGS=$((WARNINGS + 1)); }

frontmatter_value() {
  # $1=file $2=key
  awk -v key="^${2}:[[:space:]]*" 'NR>1 && /^---$/{exit} $0 ~ key{sub(key, ""); print}' "$1"
}

is_repo_root_script() {
  local base="$1" known
  for known in "${REPO_ROOT_SCRIPTS[@]}"; do
    if [ "${base}" = "${known}" ]; then
      return 0
    fi
  done
  return 1
}

# 用 awk index()/substr() 做精確字串（非正則）替換，避免路徑裡的 . 等字元被 sed 當正則解讀。
# 找不到就原樣跳過（讓後續內容比對自然抓出差異），不在這裡報錯。
literal_replace_file() {
  local file="$1" old="$2" new="$3" tmp
  grep -qF -- "${old}" "${file}" || return 0
  tmp="${file}.tmp"
  awk -v old="${old}" -v new="${new}" '
    { line=$0; idx=index(line, old); if (idx>0) line = substr(line,1,idx-1) new substr(line, idx+length(old)); print line }
  ' "${file}" > "${tmp}"
  mv "${tmp}" "${file}"
}

# 內容一致性比對前，先把 canonical 內容套上 sync-adapters.sh 對這 4 個技能做的、已知且
# 唯一的 internal-skill 路徑改寫，這樣才能正確比對「除了已揭露的改寫之外，其餘完全一致」。
apply_known_pi_rewrites() {
  local skill="$1" file="$2"
  case "${skill}" in
    maze-grill)
      literal_replace_file "${file}" '../maze-grilling/SKILL.md' '../../maze-coder/internal-skills/maze-grilling/SKILL.md'
      ;;
    maze-grill-with-docs)
      literal_replace_file "${file}" '../maze-grilling/SKILL.md' '../../maze-coder/internal-skills/maze-grilling/SKILL.md'
      literal_replace_file "${file}" '../maze-domain-modeling/SKILL.md' '../../maze-coder/internal-skills/maze-domain-modeling/SKILL.md'
      ;;
    maze-github-safe-ops)
      literal_replace_file "${file}" '委派 internal `maze-github-cli`' '委派 internal `maze-github-cli`（Pi 路徑：`../../maze-coder/internal-skills/maze-github-cli/SKILL.md`）'
      ;;
    maze-pr-review)
      literal_replace_file "${file}" '透過 `maze-github-cli` Read 契約取得證據' '透過 `maze-github-cli`（Pi 路徑：`../../maze-coder/internal-skills/maze-github-cli/SKILL.md`）Read 契約取得證據'
      ;;
  esac
}

# 對單一 SKILL.md 檢查同目錄下 references/templates/checklists/scripts 引用是否存在。
# scripts/<repo 根層腳本檔名> 視為對 repo 根目錄 scripts/ 的文字提及（不是同目錄資源），
# 用已知檔名白名單排除，其餘 scripts/ 引用一律當同目錄資源檢查是否存在。
check_resource_paths() {
  local file="$1" dir resource base
  dir="$(dirname "${file}")"
  while IFS= read -r resource; do
    [ -n "${resource}" ] || continue
    base="$(basename "${resource}")"
    if [[ "${resource}" == scripts/* ]] && is_repo_root_script "${base}"; then
      continue
    fi
    [ -e "${dir}/${resource}" ] || echo "BAD_PATH:${file}:${resource}"
  done < <(grep -Eo '(references|templates|checklists|scripts)/[A-Za-z0-9._/-]+' "${file}" | sort -u || true)
}

# 遞迴掃描一個技能探索根目錄，比照 Pi 官方文件的規則：
#   - 任何深度、含 SKILL.md 的目錄都算一個技能（不限固定 maxdepth）
#   - 根層直接放置的 .md 檔案也會被 Pi 當成個別技能載入（本 adapter 不預期出現任何一個）
# 輸出格式化的 finding 行到 stdout，呼叫端自行決定要 err/warn 或拿去跟預期比對。
scan_skill_findings() {
  local root="$1"
  local f name desc
  declare -A name_paths=()

  while IFS= read -r f; do
    name="$(frontmatter_value "${f}" name)"
    desc="$(frontmatter_value "${f}" description)"
    if [ -z "${name}" ]; then
      echo "UNPARSEABLE:${f}"
    else
      name_paths["${name}"]+="${f};"
    fi
    [ -n "${desc}" ] || echo "EMPTY_DESC:${name:-（無法解析 name）}:${f}"
    check_resource_paths "${f}"
  done < <(find "${root}" -name SKILL.md -type f 2>/dev/null | sort)

  for name in "${!name_paths[@]}"; do
    local paths="${name_paths[${name}]}"
    local count
    count="$(printf '%s' "${paths}" | tr ';' '\n' | grep -c . || true)"
    if [ "${count}" -gt 1 ]; then
      echo "COLLISION:${name}:${count}:${paths%;}"
    fi
  done

  while IFS= read -r stray; do
    echo "STRAY_ROOT_MD:${stray}"
  done < <(find "${root}" -maxdepth 1 -type f -name '*.md' 2>/dev/null)
}

echo "=== maze-coder validate-pi-adapter ==="

echo "--- 驗證器自我測試（scripts/fixtures/pi-adapter-selftest/） ---"
if [ ! -d "${FIXTURE_DIR}" ]; then
  err "缺少驗證器自我測試 fixture：${FIXTURE_DIR}"
else
  FIXTURE_FINDINGS="$(scan_skill_findings "${FIXTURE_DIR}")"

  assert_finding() {
    local pattern="$1" label="$2"
    if printf '%s\n' "${FIXTURE_FINDINGS}" | grep -qE "${pattern}"; then
      ok "自我測試：正確偵測到 ${label}"
    else
      err "自我測試失敗：預期偵測到 ${label}，但沒有偵測到——validate-pi-adapter.sh 的檢查邏輯可能有回歸"
    fi
  }
  assert_absent() {
    local pattern="$1" label="$2"
    if printf '%s\n' "${FIXTURE_FINDINGS}" | grep -qE "${pattern}"; then
      err "自我測試失敗：不該出現 ${label}，但被誤判為問題"
    else
      ok "自我測試：未誤判 ${label}"
    fi
  }

  assert_finding '^COLLISION:fixture-collide-check:2:' "重複 name（fixture-collide-check 出現 2 次）"
  assert_finding '^EMPTY_DESC:fixture-empty-desc-check:' "description 為空"
  assert_finding 'references/missing\.md$' "無效 references 路徑"
  assert_finding 'STRAY_ROOT_MD:.*orphan\.md$' "根層 stray .md 檔案"
  assert_absent 'BAD_PATH:.*good-with-scripts.*scripts/real\.sh$' "同目錄 scripts/real.sh 被誤判為無效路徑"
  assert_absent 'BAD_PATH:.*good-with-scripts.*scripts/sync-adapters\.sh$' "repo 根層 scripts/sync-adapters.sh 提及被誤判為無效路徑"
fi

[ -d "${PI_SKILLS_DIR}" ] || { err "缺少 ${PI_SKILLS_DIR}"; echo "=== ${ERRORS} failures ===" >&2; exit 1; }
[ -d "${PI_INTERNAL_DIR}" ] || { err "缺少 ${PI_INTERNAL_DIR}"; echo "=== ${ERRORS} failures ===" >&2; exit 1; }

echo "--- 技能數量與探索（遞迴掃描，非固定深度） ---"
ACTUAL_PUBLIC="$(find "${PI_SKILLS_DIR}" -name SKILL.md -type f | wc -l | tr -d ' ')"
ACTUAL_INTERNAL="$(find "${PI_INTERNAL_DIR}" -name SKILL.md -type f | wc -l | tr -d ' ')"
[ "${ACTUAL_PUBLIC}" -eq 24 ] || err ".pi/skills/ 下遞迴可發現的 SKILL.md 應為 24，實際為 ${ACTUAL_PUBLIC}（技能數量漂移或有巢狀／額外 SKILL.md）"
[ "${ACTUAL_INTERNAL}" -eq 3 ] || err ".pi/maze-coder/internal-skills/ 下遞迴可發現的 SKILL.md 應為 3，實際為 ${ACTUAL_INTERNAL}"
[ "${#SKILLS[@]}" -eq 27 ] && [ "${#PUBLIC_SKILLS[@]}" -eq 24 ] && [ "${#INTERNAL_SKILLS[@]}" -eq 3 ] \
  && ok "validator 內建 27／24／3 技能拓撲" || err "validator 內建技能拓撲不是 27／24／3"

echo "--- internal skill 未落在 Pi 探索路徑內（核心回歸檢查） ---"
for skill in "${INTERNAL_SKILLS[@]}"; do
  if find "${PI_SKILLS_DIR}" -name SKILL.md -type f -path "*/${skill}/SKILL.md" 2>/dev/null | grep -q .; then
    err "internal skill ${skill} 出現在 ${PI_SKILLS_DIR} 底下——Pi 會發現它並註冊 /skill:${skill}，internal 隔離失效"
  else
    ok "${skill} 未出現在 .pi/skills/ 底下（Pi 不會發現、不會註冊 /skill:${skill}）"
  fi
done

echo "--- 逐技能：可解析、name、description、invocation 映射、內容一致性 ---"
for skill in "${SKILLS[@]}"; do
  is_internal=0
  for i in "${INTERNAL_SKILLS[@]}"; do
    if [ "${i}" = "${skill}" ]; then
      is_internal=1
    fi
  done
  if [ "${is_internal}" -eq 1 ]; then
    file="${PI_INTERNAL_DIR}/${skill}/SKILL.md"
  else
    file="${PI_SKILLS_DIR}/${skill}/SKILL.md"
  fi
  canonical="${ROOT_DIR}/skills/${skill}/SKILL.md"

  if [ ! -f "${file}" ]; then
    err "${skill}: 缺少預期位置的 SKILL.md（路徑：${file}，原因：sync-adapters.sh 未產生或未同步）"
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

  desc="$(frontmatter_value "${file}" description)"
  [ -n "${desc}" ] || err "${skill}: description 為空，Pi 會拒絕載入此技能（路徑：${file}）"

  canonical_invocation="$(frontmatter_value "${canonical}" invocation)"
  pi_disable="$(frontmatter_value "${file}" disable-model-invocation)"
  case "${canonical_invocation}" in
    user|internal)
      [ "${pi_disable}" = "true" ] || err "${skill}: canonical invocation=${canonical_invocation}，但 Pi 版本缺少 disable-model-invocation: true（路徑：${file}）"
      ;;
    both|model|"")
      [ -z "${pi_disable}" ] || err "${skill}: canonical invocation=${canonical_invocation:-（空）}，Pi 版本卻含 disable-model-invocation（路徑：${file}，原因：不應轉譯此類別）"
      [ "${canonical_invocation}" != "model" ] || warn "${skill}: invocation=model 在 Pi 下會被當成 both 對待，/skill:${skill} 指令仍會註冊（Pi 無逐技能停用使用者指令的機制，見 adapters/pi/README.md）"
      ;;
    *)
      err "${skill}: canonical invocation 值「${canonical_invocation}」不是 user/model/both/internal 之一（路徑：${canonical}）"
      ;;
  esac

  expected_tmp="$(mktemp)"
  grep -vE '^(invocation|disable-model-invocation):' "${canonical}" > "${expected_tmp}" || true
  apply_known_pi_rewrites "${skill}" "${expected_tmp}"
  if ! diff -q "${expected_tmp}" <(grep -vE '^(invocation|disable-model-invocation):' "${file}") >/dev/null 2>&1; then
    err "${skill}: Pi 版本行為內容與 canonical 不一致（已考慮已知的 internal skill 路徑改寫；路徑：${file}）"
  fi
  rm -f "${expected_tmp}"

  ok "${skill}"
done

echo "--- 名稱碰撞、資源路徑、根層 stray .md（整個 .pi/ 樹，遞迴） ---"
ADAPTER_FINDINGS="$(scan_skill_findings "${PI_ROOT}")"
if [ -n "${ADAPTER_FINDINGS}" ]; then
  while IFS= read -r line; do
    [ -n "${line}" ] || continue
    case "${line}" in
      COLLISION:*) err "技能名稱碰撞：${line#COLLISION:}（name:count:paths，會造成 Pi 只載入第一個、其餘被靜默忽略）" ;;
      EMPTY_DESC:*) : ;; # 已在逐技能檢查裡報過，這裡不重複計錯
      BAD_PATH:*) err "無效資源路徑：${line#BAD_PATH:}（file:resource）" ;;
      UNPARSEABLE:*) : ;; # 已在逐技能檢查裡報過
      STRAY_ROOT_MD:*) err "根層出現非預期的 stray .md 檔案：${line#STRAY_ROOT_MD:}（Pi 會把它當成獨立技能載入）" ;;
    esac
  done <<< "${ADAPTER_FINDINGS}"
else
  ok ".pi/ 內無名稱碰撞、無效路徑或根層 stray .md 檔案"
fi

echo "--- public／internal 邊界（AGENTS.md 路由表） ---"
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

echo "--- 核心契約與 Guidance 同步 ---"
cmp -s "${ROOT_DIR}/core/HARNESS_ENGINEERING.md" "${PI_MAZE_DIR}/HARNESS_ENGINEERING.md" \
  && ok "HARNESS_ENGINEERING.md 已同步" || err "adapters/pi/.pi/maze-coder/HARNESS_ENGINEERING.md 未同步"
for d in core profiles model-overlays; do
  diff -qr "${ROOT_DIR}/${d}" "${PI_MAZE_DIR}/${d}" >/dev/null 2>&1 \
    && ok "${d} 已同步" || err "adapters/pi/.pi/maze-coder/${d} 未同步"
done

echo "--- 選用：實際 Pi loader 交叉核對（PI_ADAPTER_LIVE_CHECK=1 且本機有 pi 才執行） ---"
if [ "${PI_ADAPTER_LIVE_CHECK:-0}" = "1" ] && command -v pi >/dev/null 2>&1; then
  LIVE_CWD="$(mktemp -d)"
  LIVE_OUT="$(cd "${LIVE_CWD}" && pi --skill "${PI_SKILLS_DIR}" --no-session -p \
    "List the exact <name> of every <skill> entry visible in your context right now, one per line, verbatim. Nothing else." 2>&1 || true)"
  for skill in "${PUBLIC_SKILLS[@]}"; do
    if echo "${LIVE_OUT}" | grep -q "${skill}"; then
      ok "實際 loader 看得到 ${skill}"
    else
      warn "實際 loader 呼叫中沒看到 ${skill}（模型摘要可能省略，不必然代表未載入，僅供參考）"
    fi
  done
  for skill in "${INTERNAL_SKILLS[@]}"; do
    if echo "${LIVE_OUT}" | grep -q "${skill}"; then
      err "實際 loader 呼叫中出現 internal skill ${skill}，internal 隔離失效"
    else
      ok "實際 loader 確認 internal skill ${skill} 未出現"
    fi
  done
else
  echo "  [SKIP] 未設定 PI_ADAPTER_LIVE_CHECK=1 或本機找不到 pi，略過真實 loader 呼叫（會產生真實 API 呼叫成本，預設不執行）"
fi

echo
if [ "${ERRORS}" -eq 0 ]; then
  echo "=== All checks passed (${WARNINGS} warnings) ==="
else
  echo "=== ${ERRORS} failures, ${WARNINGS} warnings ===" >&2
  exit 1
fi
