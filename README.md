# maze-coder

<p align="center">
  <img src="./assets/maze-coder-logo.png" alt="maze-coder pixel wordmark logo" width="480">
</p>

**Agent Skills collection** — 一組以 Markdown 寫成的 Agent Skills，直接安裝到 Claude Code、Codex、Cursor、Pi、opencode 原生的技能目錄即可使用。沒有 Adapter、沒有 Guidance Profile、沒有 Model Overlay，也沒有需要維護的同步腳本。

## 技能

「觸發」欄說明誰能啟動技能：**使用者**表示只能由使用者明示呼叫（frontmatter 帶 `disable-model-invocation: true`）；**使用者＋模型**表示模型也能依 description 自行選用。

| 技能 | 用途 | 觸發 |
|---|---|---|
| `maze-wayfinder` | 連想要什麼都不確定時的結構化探路與決策地圖 | 使用者＋模型 |
| `maze-idea-to-spec` | 模糊想法 → 結構化規格 | 使用者＋模型 |
| `maze-spec-hardening` | 補強規格的工程契約、邊界與驗收條件 | 使用者＋模型 |
| `maze-project-init` | 初始化專案文件與 GitHub 工作流設定 | 使用者 |
| `maze-spec-to-issues` | 規格 → GitHub Issues 的 Dry Run 與同步 | 使用者 |
| `maze-spec-review` | 規格完整審查與 `--verify` 複審 | 使用者 |
| `maze-pr-review` | PR 的高訊號、可定位、唯讀審查 | 使用者 |
| `maze-adversarial-review` | 實作前對抗性審查與證偽 | 使用者 |
| `maze-threat-modeling` | 實作前威脅模型與濫用分析 | 使用者 |
| `maze-root-cause-diagnosis` | 以區辨實驗與反證收斂 Bug 根因 | 使用者 |
| `maze-bug-reproduction` | Bug 最小重現文件 | 使用者 |
| `maze-risk-driven-tdd` | 風險導向的測試與實作流程 | 使用者＋模型 |
| `maze-qa-verification` | 依規格驗收並產出 QA 報告 | 使用者 |
| `maze-session-closeout` | 以 Git／GitHub 證據重建 `NEXT_ACTION.md` | 使用者 |
| `maze-handoff-summary` | 跨工具／人員交接文件 | 使用者 |
| `maze-github-safe-ops` | Git／GitHub 安全操作與 Issue 關聯規則 | 使用者＋模型 |
| `maze-design-review` | 前端視覺、UX 與 AI slop 審查 | 使用者 |
| `maze-design-system` | 設計語言、Design Tokens 與元件規則 | 使用者 |
| `maze-gui-prototyping` | 桌面 WebView 應用的可執行 GUI 原型 | 使用者 |
| `maze-repo-map` | Repo 結構地圖與關鍵路徑 | 使用者 |
| `maze-context-audit` | 比對 agent 理解與專案文件的落差 | 使用者＋模型 |
| `maze-token-efficiency-review` | 執行 trace 與 token 效率稽核 | 使用者 |
| `maze-explain-for-dumbass` | 把技術回覆重講成白話，保留具體資訊 | 使用者＋模型 |
| `maze-grill` | 逐題壓力測試，不產生文件 | 使用者 |
| `maze-grill-with-docs` | 逐題壓力測試並同步必要的專案文件 | 使用者 |
| `maze-skill-authoring` | 評估該新增技能或擴充既有技能 | 使用者＋模型 |

## 安裝

技能就是目錄：`skills/<技能名>/` 內含 `SKILL.md` 與按需載入的 `references/`、`templates/`、`checklists/`、`examples/`。安裝 = 讓該目錄出現在 host 會掃描的技能路徑下，有兩種做法。

### 方式 1：`install-skills.sh`（symlink，建議）

建議設定就兩行：`--host agents` 蓋住 Codex、Cursor、Pi、opencode，`--host claude` 給 Claude Code。

```bash
# 一般情況：兩個安裝根就夠
bash scripts/install-skills.sh --host agents
bash scripts/install-skills.sh --host claude

# 逐專案：在專案根目錄執行（改成裝到 <專案>/.agents/skills 與 <專案>/.claude/skills）
cd /your/project && bash /path/to/maze-coder/scripts/install-skills.sh --host agents --scope project

# 只用單一工具時，才用個別 host 參數
bash scripts/install-skills.sh --host pi

# 只裝需要的技能（跨技能依賴不會自動補裝，見下節）
bash scripts/install-skills.sh --host agents maze-grill maze-grill-with-docs
```

! 不要把同一批技能同時裝到 `--host agents` 和 `--host pi`（或 `codex`、`cursor`、`opencode`）：這些 host 都會讀 `~/.agents/skills`，而 Pi 另外也會讀 `~/.pi/agent/skills`，結果同一個技能被找到兩份，依各 host 規則可能只載入先找到的那份或同名提示。選一組就好。

`--host` 可為 `claude`、`codex`、`cursor`、`pi`、`opencode`、`agents`；`--scope` 預設 `user`，可改 `project`。腳本只建立 symlink，因此 `git pull` 這個 repo 之後技能內容自動更新，不需要重新安裝。

安全行為：

- 位置參數只接受 `skills/` 直接子目錄的精確名稱；給 `maze-grill/`、`../skills` 這類含 `/`、`.`、`..` 的值會直接報錯，不會有任何寫入。
- 安裝目錄不得與 repo 的 `skills/` 重疊（含「安裝目錄是指向 `skills/` 的 symlink」）：兩者實體路徑相同或互相包含時直接拒絕。
- **腳本永遠不刪除實體目錄或檔案。** 目標已存在且不是 symlink（包括舊版 `cp -r` 的副本、空目錄、使用者自己維護的同名技能）時，**整批**停在任何寫入之前，並列出衝突路徑；請自行搬走或刪除後再跑（見下面「從舊版遷移」）。
- 目標是 symlink（指錯位置或懸空）時才替換：先在本次專屬的暫存目錄建立新連結並驗證，再用 `mv -T` 換上；建立或換手失敗時原本的連結不動。
- 同一指令可重複執行：已正確指向的項目會輸出 `[SAME]`，不會重建。

### 方式 2：手動複製

不想用腳本就直接複製目錄，副作用是之後要自己重新複製：

```bash
mkdir -p ~/.claude/skills ~/.agents/skills
cp -r skills/maze-grill skills/maze-grill-with-docs ~/.claude/skills/

# 專案層：多數 host 都讀 .agents/skills，目的地也要先建立
mkdir -p /your/project/.agents/skills
cp -r skills/* /your/project/.agents/skills/
```

多來源複製前一定要先 `mkdir -p` 目的目錄：`cp -r a b dest/` 在 `dest` 不存在時會失敗。

### 各 host 的安裝位置

| Host | `--scope user` | `--scope project` | 備註 |
|---|---|---|---|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` | 全域與專案都支援 symlink |
| Codex | `~/.agents/skills/` | `.agents/skills/` | 官方文件列 `~/.agents/skills`；舊版 `~/.codex/skills` 仍可讀但已不被文件列入 |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` | 也讀 `~/.agents/skills`、`.agents/skills`，以及 Claude／Codex 的相容目錄 |
| Pi | `~/.pi/agent/skills/` | `.pi/skills/` | 也讀 `~/.agents/skills`、`.agents/skills`；會遞迴掃描 |
| opencode | `~/.config/opencode/skills/` | `.opencode/skills/` | 也讀 `.claude/skills`、`.agents/skills`；技能 ID 由路徑決定 |

`--host agents`（`.agents/skills`）一次覆蓋 Codex、Cursor、Pi、opencode 四個 host 的使用者層與專案層；Claude Code 另用 `.claude/skills`。因此**推薦只需兩個安裝根**；個別 host 參數是給「機器上只有那一種工具」的人用的，不要拿它與 `--host agents` 並存。

Pi 確實會讀 `~/.agents/skills/` 與 `.agents/skills/` 的依據：本機 Pi 1.5.0 內建文件 `docs/skills.md:61`（“Pi also supports the Agent Skills locations `~/.agents/skills/` and `.agents/skills/`”）。

## 跨技能依賴

技能之間用相對路徑引用彼此，所以**只安裝單一技能時，被引用的檔案可能不存在**。腳本不會自動補裝，需要的話自己一起裝：

| 技能 | 需要同時安裝 | 原因 |
|---|---|---|
| `maze-grill-with-docs` | `maze-grill` | 讀 `../maze-grill/references/grilling-protocol.md` |
| `maze-pr-review` | `maze-github-safe-ops` | 讀 `../maze-github-safe-ops/references/github-cli-contract.md` |
| `maze-wayfinder` | `maze-github-safe-ops`、`maze-grill`、`maze-grill-with-docs`、`maze-gui-prototyping`、`maze-idea-to-spec`、`maze-spec-to-issues` | references 直接引用，並會委派這些技能 |

`scripts/validate-skillpack.sh` 會檢查「有 `../maze-X/` 引用就必須在 SKILL.md 寫明同時安裝」，所以上表與程式碼不會漂移。

## 驗證

```bash
bash scripts/validate-skillpack.sh          # frontmatter、必要區段、資源路徑、引用邊界
bash scripts/validate-skills-functional.sh  # 各技能的觸發／輸出契約／安全邊界
```

改動技能後兩支都要跑；新增技能時 frontmatter 只允許 `name`、`description` 與選用的 `disable-model-invocation: true`。

## 已知限制

- **Codex 不支援 `disable-model-invocation`**（本機 `codex-cli 0.169.0` 實測：該欄位被忽略，技能仍會列進模型可見清單）。也就是說「使用者明示觸發」的技能在 Codex 上可能被模型自動選用。Codex 的替代做法是每個技能加一個 `agents/openai.yaml` 設 `policy.allow_implicit_invocation: false`，本 repo 目前刻意不維護這份重複資料。
- **Windows 需要開發人員模式**才能建立目錄 symlink；`install-skills.sh` 不提供複製模式，建立失敗時會直接報錯並保留原本的安裝。
- **Cursor、opencode 未在本機實測**（本機未安裝）；上表的路徑來自官方文件，實際行為請以各 host 版本為準。
- **`--host codex` 裝到 `~/.agents/skills`**；若你原本用舊的 `~/.codex/skills`，遷移方式見下節。
- 手動 `cp -r` 安裝的副本不會隨 `git pull` 更新，需自行重新複製。

## Extension Skills

選用、不進預設安裝、不保證跨 host 可攜；每個技能只服務特定工具組合。安裝方式是直接複製到該工具自己的使用者層技能目錄，不經過本 repo 的驗證管線。

| Skill | 用途 | 安裝位置 |
|---|---|---|
| `consult-claude` | Codex 端：呼叫本機 `claude` CLI 取得第二意見 | `~/.agents/skills/consult-claude/` |
| `consult-codex` | Claude Code 端：呼叫本機 `codex` CLI 取得第二意見 | `~/.claude/skills/consult-codex/` |

```bash
cp -r extensions/consult-claude ~/.agents/skills/
cp -r extensions/consult-codex ~/.claude/skills/
```

兩者互相排斥：不要把 `consult-claude` 裝到 Claude Code 端，也不要把 `consult-codex` 裝到 Codex 端，否則會形成自我遞迴諮詢。

## 從舊版遷移

舊版（含 Adapter、Profile、Overlay 的版本）的技能是複本，或是指向本 repo 舊產物目錄 `adapters/claude-code/.claude/skills/` 的連結。新版是「repo 的 `skills/` 直接 symlink 到 host 目錄」，而 `install-skills.sh` **只建立或替換 symlink，永遠不刪除實體目錄或檔案**——所以舊的實體安裝必須先由你搬走，否則安裝會停下並列出衝突。

順序是「**先備份 → 把所有舊的實體安裝搬進備份 → 再安裝 → 確認可用後才刪備份**」。第 2 步全部成功之後才能進第 3 步。

1. 建立本次專屬的備份目錄（每次都是新的唯一目錄，依 host 分子目錄）：

   ```bash
   BAK=$(mktemp -d ~/maze-coder-skills-backup.XXXXXX)
   mkdir -p "$BAK/claude" "$BAK/codex" "$BAK/pi"
   ```

2. 把舊的實體安裝**搬**進備份（不是複製：新舊同時存在會讓安裝因衝突停下）：

   ```bash
   mv ~/.claude/skills/maze-*   "$BAK/claude"/ 2>/dev/null || true   # 舊版 cp -r 安裝
   mv ~/.codex/skills/maze-*    "$BAK/codex"/  2>/dev/null || true   # 舊版 Codex 位置
   mv ~/.pi/agent/skills/maze-* "$BAK/pi"/     2>/dev/null || true   # 舊版 Pi 位置（新舊位置相同）
   ```

   Claude Code 的舊安裝也可能是**指向舊產物目錄的連結**（不是實體目錄）。先列出、確認只有本 repo 的項目，再刪：

   ```bash
   REPO="$(cd /path/to/maze-coder && pwd -P)"   # Git Bash 下的實體路徑，例如 /d/AgentCoding/maze-coder
   find ~/.claude/skills -maxdepth 1 -type l -lname "${REPO}/adapters/claude-code/*" -print
   # 清單確認無誤後，把同一條指令的 -print 改成 -delete
   ```

3. 安裝新版（推薦的兩個安裝根）：

   ```bash
   bash scripts/install-skills.sh --host agents
   bash scripts/install-skills.sh --host claude
   ```

   只使用 Pi 一個工具的人改用 `--host pi`，驗證時看 `~/.pi/agent/skills`：

   ```bash
   ls -l ~/.pi/agent/skills/maze-grill   # 應為指向 <repo>/skills/maze-grill 的連結
   ```

   不要同時用 `agents` 與 `pi`：兩者都會被 Pi 讀到，同一個技能會出現兩份。

4. 確認新安裝指回 repo：

   ```bash
   ls -l ~/.agents/skills/maze-grill ~/.claude/skills/maze-grill
   ```

5. 確認可用後才刪備份：`rm -rf "$BAK"`（只刪這次建立的那個目錄）；在那之前 `$BAK` 就是你唯一的回復點。
6. 清掉舊版遺留的契約副本（不再有用途）：`~/.claude/maze-coder/`、`~/.pi/agent/maze-coder/`。
7. 更新你自己的指示檔：`~/.codex/AGENTS.md`、`~/.pi/agent/AGENTS.md`、`~/.claude/CLAUDE.md` 若引用舊的 Harness／Profile／Adapter 路徑，改成指向新安裝的技能目錄即可（技能本身已自帶觸發描述，不需要 Router 表格）。
8. 回復：任何一步失敗，把 `$BAK/<host>/` 裡的目錄搬回原位即可；安裝腳本本身不會刪掉你的資料。

## 設計原則

- **Markdown 優先**：host 換格式、換版本，技能還是純文字。
- **不做 CLI／framework**：沒有 npm、沒有 venv；`cp -r` 就是一種完整的安裝方式。
- **不重複儲存**：`skills/` 是唯一來源，沒有生成物，也就不需要同步。
- **約束結果，不約束過程**：技能只寫觸發、必要流程、確認點、輸出契約與邊界；探索、規劃、工具選擇留給模型。
- **優先擴充既有技能**：先問能不能加一條 checklist／reference，真的無法歸類才開新技能（判斷流程見 `maze-skill-authoring`）。

## Structure

```text
assets/     品牌與視覺資產
skills/     技能唯一來源，每個目錄一個技能
extensions/ 選用、單一 host 專屬、不進預設安裝的技能
scripts/    install-skills.sh 與兩支驗證腳本
docs/       本 repo 自身的規格、專案說明與 ADR
```

## Contributing

1. 只改 `skills/`（安裝與驗證腳本除外）。
2. 執行 `bash scripts/validate-skillpack.sh` 與 `bash scripts/validate-skills-functional.sh`。
3. Commit message 依 Conventional Commits，並引用對應 Issue。

[MIT License](LICENSE)
