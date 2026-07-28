# Pi Adapter

`AGENTS.md` 是精簡 Router（Pi 原生支援 `AGENTS.md`／`CLAUDE.md` 自動載入，可用 `--no-context-files` 關閉）；`.pi/` 提供 27 個 canonical skills（24 個公開或可由模型觸發、3 個 internal）、Profiles、Overlays 與核心契約。兩者必須一起安裝：

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

## user／model／both／internal 在 Pi 下的對應（含已知限制）

maze-coder 的 canonical `invocation` 欄位有四種值；Pi 的 SKILL.md frontmatter 只原生支援 `disable-model-invocation`（true 時模型不會在系統提示看到、也不會主動選用該技能，但 `/skill:<name>` 使用者指令仍會註冊）。對應如下：

| canonical `invocation` | Pi frontmatter 轉譯 | 實際效果 | 限制 |
|---|---|---|---|
| `user` | `disable-model-invocation: true` | 模型不會主動選用；使用者可用 `/skill:<name>` 呼叫 | 完整對應，無降級 |
| `both` | 不轉譯（保持預設） | 模型可主動選用，使用者也可 `/skill:<name>` | 完整對應，即 Pi 預設行為 |
| `model` | 不轉譯（保持預設，等同 `both`） | 模型可主動選用；`/skill:<name>` 指令**仍會註冊** | **降級**：Pi 沒有等同 Claude Code `user-invocable: false` 的欄位，無法只隱藏使用者指令、保留模型可見度；目前所有 canonical skills 中沒有實際使用 `model` 值的技能，此列為未來新增時的既知限制 |
| `internal` | `disable-model-invocation: true` | 模型不會主動選用 | **降級**：`/skill:<name>` 指令**仍會註冊**（同上，Pi 的 `enableSkillCommands` 只有全域開關，沒有逐技能停用使用者指令的機制）；internal skill 不會出現在 `AGENTS.md` 路由表裡（本文件與其他 Adapter 一致，路由表本身不含 3 個 internal skill 名稱），但 `.pi/skills/` 目錄與 `/skill:<name>` 入口仍實際存在，因為 internal skill 的內容需要被同層公開技能以相對路徑（例如 `maze-grill/SKILL.md` 讀取 `../maze-grilling/SKILL.md`）引用，物理移除會破壞既有 canonical skill 內容、等同 fork |

**已知限制總結（不得假裝已完整支援）**：Pi 沒有逐技能停用 `/skill:<name>` 使用者指令的原生機制；`enableSkillCommands`（`~/.pi/agent/settings.json`）是全域開關，關閉會連同「公開」技能的使用者指令一起關閉。因此 3 個 internal skills（`maze-grilling`、`maze-domain-modeling`、`maze-github-cli`）在 Pi 下无法做到跟 Claude Code adapter 一樣的「使用者與模型都無法直接觸發」——這是 Pi 平台限制，不是本 adapter 的實作疏漏；`scripts/validate-pi-adapter.sh` 對此會輸出 `[WARN]`（非 `FAIL`）明確記錄這個已知落差，而不是略過或假裝已擋下。

## 名稱碰撞行為（實測）

Pi 官方文件與本次相容性驗證都確認：同名技能（不同來源）採「先載入者優先，其餘警告後保留第一個」的策略。`scripts/validate-pi-adapter.sh` 會檢查 `.pi/skills/` 內部是否有重複 `name`，但無法控制使用者自己額外安裝、剛好撞名的其他技能來源（`~/.pi/agent/skills/`、其他 packages 等）——那屬於使用者環境的責任範圍。

## 已知限制與非目標

- 不 fork、不重寫任何 canonical skill 內容；`.pi/skills/` 一律由 `scripts/sync-adapters.sh` 從 `skills/` 同步而來。
- 不建立 Pi extension（`.ts`／`.js`）；第一階段只用 Pi 原生的 skills／AGENTS.md context file 機制。
- 不含 `pi.skills` package manifest；`.pi/skills/` 走 Pi 的專案層原生路徑自動探索，不需要額外 manifest。
