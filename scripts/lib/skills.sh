#!/usr/bin/env bash
# 技能清單單一來源：掃描 skills/*/SKILL.md，依 frontmatter 的 invocation 分 public／internal。
# 由 sync-adapters.sh、validate-skillpack.sh、validate-pi-adapter.sh 共用；需先設定 ROOT_DIR。
# 新增技能只需建立 skills/<name>/SKILL.md，不必改這些腳本裡的名單。

SKILLS=()
PUBLIC_SKILLS=()
INTERNAL_SKILLS=()

while IFS= read -r _skill_file; do
  _name="$(basename "$(dirname "${_skill_file}")")"
  _invocation="$(awk '/^---[[:space:]]*$/{n++; next} n==1 && /^invocation:/{sub(/^invocation:[[:space:]]*/, ""); sub(/[[:space:]\r]+$/, ""); print; exit} n>=2{exit}' "${_skill_file}")"
  case "${_invocation}" in
    internal) INTERNAL_SKILLS+=("${_name}") ;;
    user|both) PUBLIC_SKILLS+=("${_name}") ;;
    *) echo "[FAIL] skills/${_name}/SKILL.md invocation 缺失或非法：'${_invocation}'（允許 user／both／internal）" >&2; exit 1 ;;
  esac
  SKILLS+=("${_name}")
done < <(find "${ROOT_DIR}/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | LC_ALL=C sort)
unset _skill_file _name _invocation
