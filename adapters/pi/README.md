# Pi Adapter

`AGENTS.md` 是精簡 Router（Pi 原生支援 `AGENTS.md`／`CLAUDE.md` 自動載入，可用 `--no-context-files` 關閉）；`.pi/` 提供 29 個 canonical skills、Profiles、Overlays 與核心契約。26 個公開或可由模型觸發的技能放在 Pi 原生會掃描的 `.pi/skills/`；3 個 internal skills（`maze-grilling`、`maze-domain-modeling`、`maze-github-cli`）刻意放在 `.pi/maze-coder/internal-skills/`——這個路徑不在 Pi 的任何技能探索位置內，因此完全不會被發現、不會注入模型系統提示、也不會註冊 `/skill:<name>` 指令（原因與驗證見下方「internal skill 的實體隔離」）。兩者必須一起安裝：

```bash
cp AGENTS.md /your-project/
cp -r .pi /your-project/
```

安裝後，第一次在該專案執行 `pi` 時會出現專案信任（project trust）提示；`.pi/skills/` 必須在專案被信任後才會被 Pi 自動探索。若要免互動信任，可在啟動時加上 `--approve`，或先前手動同意過的專案會記錄在 Pi 的全域 `trust.json`。

產物由 `scripts/sync-adapters.sh` 維護，請勿直接編輯；相容性驗證見 `scripts/validate-pi-adapter.sh`。

## 與其他四種 Adapter 的差異

Pi 原生支援 [Agent Skills 規格](https://agentskills.io/specification)：會自動掃描 `.pi/skills/` 下每個含 `SKILL.md` 的目錄，把每個技能的 `name`／`description` 注入系統提示，並註冊 `/skill:<name>` 使用者指令——這是 Codex／opencode／Cursor 都沒有的原生能力，因此：

- 技能的「意圖 → 技能」路由表（`AGENTS.md` 裡的表格）對 Pi 來說是輔助說明，不是唯一入口；Pi 會自己把每個技能的 description 放進模型看得到的上下文，模型仍可能不經路由表直接選用某個技能。
- `.pi/maze-coder/`（`core`／`profiles`／`model-overlays`／`HARNESS_ENGINEERING.md`）不是 Pi 認得的技能格式，純粹是給模型讀取的參考文件，靠 `AGENTS.md` 的第一句指示帶入，跟 Codex／opencode 的 `.maze-coder/` 用法一致。

## internal skill 的實體隔離（取代原本的 disable-model-invocation-only 方案）

Pi 會**遞迴掃描**任何技能探索路徑（`.pi/skills/`、`.agents/skills/` 等）下含 `SKILL.md` 的目錄，對每一個都注入模型系統提示、並註冊 `/skill:<name>` 使用者指令；`disable-model-invocation: true` 只隱藏「模型主動選用」那一半，**不會**阻止 `/skill:<name>` 註冊，而 Pi 也沒有逐技能停用使用者指令的欄位（`enableSkillCommands` 只有全域開關）。這代表光靠 frontmatter 沒辦法讓 internal skill 真正不出現在公開入口。

因此本 adapter 改用**實體隔離**：3 個 internal skills 完全不放進 `.pi/skills/`，而是放在 `.pi/maze-coder/internal-skills/`——不在 Pi 文件列出的任何技能探索位置內，Pi 根本不會掃到，也就沒有 `/skill:<name>` 指令、也不會出現在模型可見清單裡。

公開技能原本用相對路徑或純文字引用這 3 個 internal skill 的內容（例如 `maze-grill/SKILL.md` 讀取 `../maze-grilling/SKILL.md`），搬家後 `scripts/sync-adapters.sh` 會對**已知的 4 個引用點**做精確字串替換（不是全域正則猜測），改指向新路徑：

| 公開技能 | 原始引用 | Pi 版本改寫為 |
|---|---|---|
| `maze-grill` | `../maze-grilling/SKILL.md` | `../../maze-coder/internal-skills/maze-grilling/SKILL.md` |
| `maze-grill-with-docs` | `../maze-grilling/SKILL.md`、`../maze-domain-modeling/SKILL.md` | 對應改為 `../../maze-coder/internal-skills/<name>/SKILL.md` |
| `maze-github-safe-ops` | 純文字提及 `` `maze-github-cli` ``（無路徑） | 提及後方附加「（Pi 路徑：`../../maze-coder/internal-skills/maze-github-cli/SKILL.md`）」 |
| `maze-pr-review` | 純文字提及 `` `maze-github-cli` ``（無路徑） | 同上附加 Pi 路徑 |

這是唯一對 canonical 內容做的字串層級改動，僅限這 4 個檔案裡「已知會指向被搬家的 internal skill」的那幾個精確子字串；`scripts/sync-adapters.sh` 在替換前後都會斷言字串真的存在／已改到，canonical 內容變了就直接失敗，不會靜默略過或誤改到無關文字。除此之外，`.pi/skills/`、`.pi/maze-coder/internal-skills/` 的所有技能內容（含 3 個 internal skill 本身）逐字元對照 canonical 的 `skills/` 完全一致（只排除 invocation frontmatter 轉譯與上述 4 處已知改寫）。

**實測驗證**：用本機 Pi CLI（0.82.1）建了一個對照本 adapter 結構的最小 fixture——一個公開技能位於被掃描的根目錄下，引用另一個放在根目錄之外、以相對路徑指向的「internal」技能。`pi --skill <公開根目錄>` 非互動模式下，模型可見清單只出現公開技能，被搬到根目錄之外的 internal 技能完全沒有出現，確認「不在探索路徑內＝不會被發現、不會取得 `/skill:<name>` 入口」這個結論成立，不是憑空推測。

## user／model／both／internal 在 Pi 下的對應

| canonical `invocation` | Pi 對應 | 實際效果 |
|---|---|---|
| `user` | `.pi/skills/` 內，`disable-model-invocation: true` | 模型不會主動選用；使用者可用 `/skill:<name>` 呼叫 |
| `both` | `.pi/skills/` 內，不轉譯（保持預設） | 模型可主動選用，使用者也可 `/skill:<name>` |
| `internal` | 移出 `.pi/skills/`，放到 `.pi/maze-coder/internal-skills/` | Pi 完全不會發現：不進系統提示、不會有 `/skill:<name>` 指令（見上方「實體隔離」） |
| `model` | `.pi/skills/` 內，不轉譯（保持預設，等同 `both`） | 模型可主動選用；`/skill:<name>` 指令**仍會註冊** |

**唯一剩餘的已知限制（`model` 這一類）**：Pi 沒有等同 Claude Code `user-invocable: false` 的欄位，無法只隱藏使用者指令、保留模型可見度——`model` 類技能在 Pi 下會被當成 `both` 對待（`/skill:<name>` 一樣可呼叫）。目前 29 個 canonical skills 沒有任何一個實際使用 `invocation: model`，所以現況沒有實際落差；這裡記錄下來是給未來新增 `model` 類技能時的既知限制，不是現在就存在的問題。`scripts/validate-pi-adapter.sh` 會在真的出現 `model` 類技能時對此輸出 `[WARN]`。

## 名稱碰撞行為（實測）

Pi 官方文件與本次相容性驗證都確認：同名技能（不同來源）採「先載入者優先，其餘警告後保留第一個」的策略。`scripts/validate-pi-adapter.sh` 會檢查 `.pi/skills/` 內部是否有重複 `name`，但無法控制使用者自己額外安裝、剛好撞名的其他技能來源（`~/.pi/agent/skills/`、其他 packages 等）——那屬於使用者環境的責任範圍。

## 已知限制與非目標

- 不 fork、不重寫任何 canonical skill 的實質內容；`.pi/skills/`、`.pi/maze-coder/internal-skills/` 一律由 `scripts/sync-adapters.sh` 從 `skills/` 同步而來。唯一例外是上方「internal skill 的實體隔離」表列的 4 處精確字串替換——純粹是因為檔案物理搬家後路徑跟著變，不是內容或行為上的改寫，且改寫前後都有斷言，不會靜默漂移。
- 不建立 Pi extension（`.ts`／`.js`）；第一階段只用 Pi 原生的 skills／AGENTS.md context file 機制。
- 不含 `pi.skills` package manifest；`.pi/skills/` 走 Pi 的專案層原生路徑自動探索，不需要額外 manifest。
