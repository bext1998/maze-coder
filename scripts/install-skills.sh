#!/usr/bin/env bash
# 把 skills/ 底下的技能以 symlink 安裝到各 host 原生的技能目錄。
#
# 腳本只做兩件事：建立新的 symlink，或替換既有的 symlink。它**永遠不刪除實體目錄
# 或檔案**——目標若已存在且不是 symlink，一律視為衝突並在使用者自行處理前停下。
#
# 只建立真正的 symlink，不提供複製模式：複製在 Windows 上會出現「目的地已存在時
# 塞成巢狀目錄、之後只覆蓋 SKILL.md」的損毀（見 PR #39／#41），而且 git pull 後
# 不會同步。MSYS=winsymlinks:nativestrict 強制 ln -s 建立真 NTFS symlink；建完
# 再用 test -L 驗證，失敗就直接報錯，不留一份看起來正常、實際上是死的複製品。
#
# 安全前提：
#   1. 位置參數只接受 skills/ 直接子目錄中含 SKILL.md 的精確名稱；目標永遠是安裝
#      目錄的直接子項。
#   2. 安裝目錄的實體路徑不得與 skills/ 相同、也不得互相包含（一律轉小寫比對，
#      因為 NTFS 與 macOS 預設都不分大小寫）。
#   3. 目標是實體目錄或檔案時整批停下，不做任何搬移、備份或刪除。
#   4. 替換 symlink 用暫存連結加 mv -T 原子換上；沒有 -T 的環境退回「搬走舊連結 →
#      放上新的 → 失敗搬回」，任何失敗都不會弄掉原本的連結。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_DIR}/skills"

usage() {
  echo "用法：bash scripts/install-skills.sh --host <host> [--scope user|project] [skill-name ...]" >&2
  echo "  --host   claude | codex | cursor | pi | opencode | agents（必填）" >&2
  echo "  --scope  user（預設）或 project（相對於目前工作目錄）" >&2
  echo "  未給技能名稱時安裝 skills/ 底下全部技能" >&2
  echo "  既有實體目錄或檔案不會被刪除；請先自行搬走或刪除（見 README「從舊版遷移」）" >&2
}

die() {
  echo "ERROR: $1" >&2
  shift
  while [ "$#" -gt 0 ]; do
    echo "       $1" >&2
    shift
  done
  exit 1
}

HOST=""
SCOPE="user"
REQUESTED=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --host)
      [ "$#" -ge 2 ] || { usage; exit 1; }
      HOST="$2"
      shift 2
      ;;
    --host=*)
      HOST="${1#--host=}"
      shift
      ;;
    --scope)
      [ "$#" -ge 2 ] || { usage; exit 1; }
      SCOPE="$2"
      shift 2
      ;;
    --scope=*)
      SCOPE="${1#--scope=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: 未知參數 $1" >&2
      usage
      exit 1
      ;;
    *)
      REQUESTED+=("$1")
      shift
      ;;
  esac
done

[ -n "${HOST}" ] || { usage; exit 1; }

case "${SCOPE}" in
  user|project) ;;
  *) die "--scope 只接受 user 或 project，收到 ${SCOPE}" ;;
esac

if [ "${SCOPE}" = "user" ] && [ -z "${HOME:-}" ]; then
  die "--scope user 需要 HOME 環境變數，但目前是空的" "請設定 HOME，或改用 --scope project。"
fi

case "${HOST}" in
  claude) user_dir="${HOME}/.claude/skills"   project_dir=".claude/skills" ;;
  codex)  user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  cursor) user_dir="${HOME}/.cursor/skills"   project_dir=".cursor/skills" ;;
  pi)     user_dir="${HOME}/.pi/agent/skills" project_dir=".pi/skills" ;;
  opencode) user_dir="${HOME}/.config/opencode/skills" project_dir=".opencode/skills" ;;
  agents) user_dir="${HOME}/.agents/skills"   project_dir=".agents/skills" ;;
  *)
    die "不支援的 --host ${HOST}（可用：claude、codex、cursor、pi、opencode、agents）"
    ;;
esac

if [ "${SCOPE}" = "user" ]; then
  DEST_ROOT="${user_dir}"
else
  DEST_ROOT="${PWD}/${project_dir}"
fi

# Windows 上強制 ln -s 建立真正的 symlink，而不是靜默複製整份目錄；其他平台上這個
# 環境變數無作用，可安全設定。
export MSYS=winsymlinks:nativestrict

[ -d "${SKILLS_DIR}" ] || die "找不到 ${SKILLS_DIR}"

# canon 用 `cd -P && pwd` 取代 `readlink -f`：後者不是所有平台都支援 -f。回傳非零
# 代表無法解析（目錄不存在、broken symlink 等）。
canon() {
  (cd -P "$1" 2>/dev/null && pwd)
}

# 只做詞法正規化（收掉 . 與多餘的 /、消掉 x/..），不解析 symlink；symlink 的實體
# 解析留給後面的 cd -P 比對。先正規化可以避免 `mkdir -p a/missing/../b` 順手建出
# 一個 `a/missing` 空目錄。
normalize_path() {
  local input="$1" part out_abs=0
  local -a parts=() out=()
  case "${input}" in /*) out_abs=1 ;; esac
  IFS='/' read -r -a parts <<< "${input}"
  for part in "${parts[@]}"; do
    case "${part}" in
      ""|.) continue ;;
      ..)
        if [ "${#out[@]}" -gt 0 ] && [ "${out[${#out[@]}-1]}" != ".." ]; then
          unset "out[$(( ${#out[@]} - 1 ))]"
        elif [ "${out_abs}" = "0" ]; then
          out+=("..")
        fi
        ;;
      *) out+=("${part}") ;;
    esac
  done
  local joined="" i
  for i in "${!out[@]}"; do
    joined="${joined}${out[$i]}/"
  done
  joined="${joined%/}"
  if [ "${out_abs}" = "1" ]; then
    printf '/%s' "${joined}"
  else
    printf '%s' "${joined}"
  fi
}

DEST_ROOT="$(normalize_path "${DEST_ROOT}")"

shopt -s nullglob
all_dirs=("${SKILLS_DIR}"/*/)
shopt -u nullglob
[ "${#all_dirs[@]}" -gt 0 ] || die "${SKILLS_DIR} 底下沒有任何技能目錄"

# 只有含 SKILL.md 的目錄才算技能，跟 validate-skillpack.sh 的掃描規則一致。
AVAILABLE=()
for dir in "${all_dirs[@]}"; do
  if [ -f "${dir}SKILL.md" ]; then
    AVAILABLE+=("$(basename "${dir}")")
  fi
done
[ "${#AVAILABLE[@]}" -gt 0 ] || die "${SKILLS_DIR} 底下沒有任何含 SKILL.md 的技能目錄"

is_available() {
  local candidate="$1" name
  for name in "${AVAILABLE[@]}"; do
    if [ "${name}" = "${candidate}" ]; then
      return 0
    fi
  done
  return 1
}

# --- 先驗證所有名稱，任何一個不合法就完全不動任何目錄 ---
selected=()
if [ "${#REQUESTED[@]}" -eq 0 ]; then
  selected=("${AVAILABLE[@]}")
else
  for name in "${REQUESTED[@]}"; do
    case "${name}" in
      ""|.|..|*/*)
        die "技能名稱不合法：'${name}'" "位置參數不可為 \`.\`、\`..\`，也不可含 \`/\`。"
        ;;
    esac
    case "${name}" in
      *[!A-Za-z0-9._-]*) die "技能名稱含不允許的字元：${name}" ;;
    esac
    is_available "${name}" \
      || die "找不到技能 ${name}（可用技能：$(printf '%s ' "${AVAILABLE[@]}")）"
    selected+=("${name}")
  done
fi

# --- 路徑安全檢查：目標永遠只能是 DEST_ROOT 的直接子項 ---
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  case "${target}" in
    "${DEST_ROOT}/"*) ;;
    *) die "目標路徑異常：${target}" ;;
  esac
  case "${target#"${DEST_ROOT}/"}" in
    */*|.|..) die "目標路徑異常：${target}" ;;
  esac
done

# --- 安裝目錄與來源目錄不得重疊 ---
# 為了用 cd -P 取實體路徑，必須先建目錄；先記下「這次才會被建立」的路徑，若最後
# 判定重疊就由深到淺把它們收回去，讓 skills/ 保持原樣。
created_dirs=()
probe="${DEST_ROOT}"
while [ -n "${probe}" ] && [ "${probe}" != "/" ] && [ ! -d "${probe}" ]; do
  created_dirs+=("${probe}")
  probe="$(dirname "${probe}")"
done
mkdir -p "${DEST_ROOT}" || die "無法建立安裝目錄 ${DEST_ROOT}"

remove_created_dirs() {
  local d
  for d in "${created_dirs[@]}"; do
    rmdir "${d}" 2>/dev/null || true
  done
  created_dirs=()
}

DEST_REAL="$(cd -P "${DEST_ROOT}" 2>/dev/null && pwd -P)" || {
  remove_created_dirs
  die "無法解析安裝目錄 ${DEST_ROOT}"
}
SKILLS_REAL="$(cd -P "${SKILLS_DIR}" 2>/dev/null && pwd -P)" || die "無法解析來源目錄 ${SKILLS_DIR}"

# NTFS 與 macOS 預設不分大小寫，WSL 的 /mnt/* 亦然；一律轉小寫比對，寧可多擋。
DEST_CMP="$(printf '%s' "${DEST_REAL}" | tr 'A-Z' 'a-z')"
SKILLS_CMP="$(printf '%s' "${SKILLS_REAL}" | tr 'A-Z' 'a-z')"

if [ "${DEST_CMP}" = "/" ]; then
  remove_created_dirs
  die "安裝目錄不得是檔案系統根目錄：${DEST_REAL}"
fi
if [ "${DEST_CMP}" = "${SKILLS_CMP}" ]; then
  remove_created_dirs
  die "安裝目錄就是技能來源：${DEST_REAL}" "這會讓安裝產物覆蓋 repo 的 skills/，本腳本拒絕執行。"
fi
case "${DEST_CMP}" in
  "${SKILLS_CMP}"/*)
    remove_created_dirs
    die "安裝目錄位於技能來源之內：${DEST_REAL}" "本腳本拒絕在 skills/ 底下建立安裝產物。"
    ;;
esac
case "${SKILLS_CMP}" in
  "${DEST_CMP}"/*)
    remove_created_dirs
    die "安裝目錄包含技能來源：${DEST_REAL}" "來源與安裝產物不得互相包含，請改用其他安裝目錄。"
    ;;
esac

# --- 衝突預檢：目標是實體目錄或檔案（含空目錄）就在建立任何連結前停下 ---
# 懸空或指錯位置的 symlink 不算衝突，會被替換。
conflicts=()
for name in "${selected[@]}"; do
  target="${DEST_ROOT}/${name}"
  if [ -L "${target}" ]; then
    continue
  fi
  if [ -e "${target}" ]; then
    conflicts+=("${target}")
  fi
done

if [ "${#conflicts[@]}" -gt 0 ]; then
  {
    echo "ERROR: 下列目標已存在且不是 symlink，本腳本不會刪除或搬移它們："
    printf '       %s\n' "${conflicts[@]}"
    echo "       請確認內容後自行搬走或刪除（舊版安裝請照 README「從舊版遷移」操作），"
    echo "       再重新執行。本次沒有安裝或刪除任何東西。"
  } >&2
  exit 1
fi

# GNU mv 才有 -T。用變數承接 --help 輸出再比對，避免 `| grep -q` 在 pipefail 下
# 因 SIGPIPE 誤判。
MV_T_SUPPORTED=0
mv_help="$(mv --help 2>/dev/null || true)"
case "${mv_help}" in
  *"--no-target-directory"*|*"-T"*) MV_T_SUPPORTED=1 ;;
esac

replace_link() {
  local staging_link="$1" target="$2" previous="$3"
  if [ "${MV_T_SUPPORTED}" = "1" ]; then
    mv -T "${staging_link}" "${target}"
    return
  fi
  # 沒有 -T 的環境：先把舊連結「搬進」暫存目錄（不是刪除），再放上新的；
  # 失敗就把舊連結搬回原位，使用者原本的連結不會消失。
  if [ -L "${target}" ]; then
    mv "${target}" "${previous}" || return 1
    if mv "${staging_link}" "${target}"; then
      return 0
    fi
    if mv "${previous}" "${target}"; then
      return 1
    fi
    die "無法把暫存連結換到 ${target}" "還原也失敗：原本的連結仍在 ${previous}，請手動移回。"
  fi
  mv "${staging_link}" "${target}"
}

STAGING_DIR=""
CURRENT_TARGET=""
cleanup_staging() {
  if [ -n "${STAGING_DIR}" ] && [ -d "${STAGING_DIR}" ]; then
    # 中斷發生在「舊連結已搬進暫存、新連結還沒換上」的空檔時，先把舊連結搬回去。
    if [ -n "${CURRENT_TARGET}" ] && [ ! -e "${CURRENT_TARGET}" ] && [ ! -L "${CURRENT_TARGET}" ] \
       && [ -L "${STAGING_DIR}/previous" ]; then
      mv "${STAGING_DIR}/previous" "${CURRENT_TARGET}" 2>/dev/null || true
      echo "WARN: 中斷時已把先前的連結搬回 ${CURRENT_TARGET}" >&2
    fi
    rm -rf "${STAGING_DIR}" 2>/dev/null || true
  fi
  STAGING_DIR=""
  CURRENT_TARGET=""
}
trap cleanup_staging EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

installed=()
report_failure() {
  local idx="$1"
  shift
  local pending="" line i
  for ((i = idx; i < ${#selected[@]}; i++)); do
    pending="${pending}${selected[$i]} "
  done
  {
    for line in "$@"; do
      echo "${line}" >&2
    done
    echo "       已安裝完成：${installed[*]:-（無）}" >&2
    echo "       尚未安裝：${pending:-（無）}" >&2
    echo "       修正原因後重跑同一條指令即可補齊；已正確安裝的項目會顯示 [SAME]。" >&2
  }
  exit 1
}

for idx in "${!selected[@]}"; do
  name="${selected[$idx]}"
  src="${SKILLS_DIR}/${name}"
  target="${DEST_ROOT}/${name}"
  expected="$(canon "${src}")" || report_failure "${idx}" "ERROR: 無法解析來源路徑 ${src}"

  if [ -L "${target}" ] && [ "$(canon "${target}")" = "${expected}" ]; then
    echo "  [SAME] ${name}"
    installed+=("${name}")
    continue
  fi

  # 暫存目錄只用來放 symlink；裡面不會出現實體檔案或目錄。
  STAGING_DIR="$(mktemp -d "${DEST_ROOT}/.install-staging.XXXXXX")" \
    || report_failure "${idx}" "ERROR: 無法在 ${DEST_ROOT} 建立暫存目錄"
  staging_link="${STAGING_DIR}/link"
  CURRENT_TARGET="${target}"

  ln_err=""
  if ! ln_err="$(ln -s "${expected}" "${staging_link}" 2>&1)"; then
    CURRENT_TARGET=""
    cleanup_staging
    report_failure \
      "${idx}" \
      "ERROR: 無法建立 symlink（${name}）" \
      "       ln: ${ln_err:-（無輸出）}" \
      "       可能原因：Windows 未開啟開發人員模式（設定 → 系統 → 開發人員選項）、權限不足，或目的地所在磁碟不支援 symlink。" \
      "       既有連結未被變更。"
  fi
  if [ ! -L "${staging_link}" ] || [ ! -e "${staging_link}/SKILL.md" ]; then
    CURRENT_TARGET=""
    cleanup_staging
    report_failure \
      "${idx}" \
      "ERROR: 暫存連結驗證失敗（${name}）：ln -s 可能退化成複製" \
      "       既有連結未被變更。"
  fi

  if ! replace_link "${staging_link}" "${target}" "${STAGING_DIR}/previous"; then
    CURRENT_TARGET=""
    cleanup_staging
    report_failure "${idx}" "ERROR: 無法把暫存連結換到 ${target}" "       原本的連結未變動。"
  fi

  CURRENT_TARGET=""
  cleanup_staging
  installed+=("${name}")
  echo "  [LINK] ${name} -> ${expected}"
done

echo "=== 完成：${DEST_ROOT} 下的 ${#selected[@]} 個 maze-coder 技能已 symlink 到 ${SKILLS_DIR} ==="
