#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FILE="${ROOT_DIR}/tests/adaptive-scenarios.tsv"

[ -s "${FILE}" ] || { echo "[FAIL] 缺少情境資料" >&2; exit 1; }
[ "$(wc -l < "${FILE}" | tr -d ' ')" -eq 27 ] || { echo "[FAIL] 必須有 26 個情境" >&2; exit 1; }

awk -F '\t' '
NR == 1 {
  if (NF != 14) { print "[FAIL] 情境欄位數錯誤" > "/dev/stderr"; exit 1 }
  next
}
{
  if (NF != 14) { print "[FAIL] 第 " NR " 列欄位數錯誤" > "/dev/stderr"; exit 1 }
  for (i=1; i<=NF; i++) if ($i == "") { print "[FAIL] 第 " NR " 列有空欄" > "/dev/stderr"; exit 1 }
  if ($2 !~ /^(minimal|standard|scaffolded)$/) { print "[FAIL] Profile 不合法: " $2 > "/dev/stderr"; exit 1 }
  if ($8 > $7 || $10 > $9 || $12 > $11 || $14 > $13) {
    print "[FAIL] adaptive 預估退化: " $1 > "/dev/stderr"; exit 1
  }
}
END { print "[OK] 26 個代表性情境契約與靜態比較通過" }
' "${FILE}"

while IFS=$'\t' read -r id profile skill resources rest; do
  [ "${id}" = id ] && continue
  [ -f "${ROOT_DIR}/skills/${skill}/SKILL.md" ] || { echo "[FAIL] ${id}: 缺少 ${skill}" >&2; exit 1; }
  IFS=';' read -ra paths <<< "${resources}"
  for path in "${paths[@]}"; do [ -e "${ROOT_DIR}/${path}" ] || { echo "[FAIL] ${id}: 缺少 ${path}" >&2; exit 1; }; done
done < "${FILE}"
