# maze-coder — Agent 規範

maze-coder 是跨模型的技能包：29 個 canonical skills（26 公開、3 internal）、核心契約與五個 Host Adapter。

## Source of Truth

- `skills/`、`core/`、`scripts/`、`docs/spec.md` 是唯一來源，直接修改這裡。
- `adapters/` 與根 `templates/` 由 `scripts/sync-adapters.sh` 產生，禁止手動編輯。
- 技能數量變更時，同步 `docs/spec.md`、README、`scripts/sync-adapters.sh` 的 skill arrays 與 validators 的 29／26／3 計數。

## 工作樹

- 集中放置於 `D:\AgentCoding\.codex\worktrees`。
- 命名格式：`maze/西元年-月-日-短雜湊`（例：`maze/2026-09-30-418b1ca`）。

## 工作流程

1. 動手前讀 `docs/spec.md`（現行 v3.4）與 `core/invariants.md`；技能相關變更先讀目標技能的 `SKILL.md` 與其資源目錄。
2. 修改 source of truth 後執行 `bash scripts/sync-adapters.sh` 同步產物。
3. 只跑與變更相稱的 `scripts/validate-*.sh`，不追加新的驗證步驟。
4. Commit message 依 Conventional Commits，引用對應 Issue（`Closes #N` 僅用於完整完成）。

## Release Label 與 PR 粒度

- Issue／PR 的 `release:major`（破壞性變更）、`release:minor`（新增功能，向下相容）、`release:patch`（修補、文件、內部調整）標籤，合併時會自動打對應版本 tag。
- 凡使用這些標籤，數個相關功能／修正應合併進同一個 PR，一個 PR 對應一次版本發佈，避免版本碎片化而難以管理。
- 不要為每個小 issue 各開一個帶 release 標籤的 PR；先累積成一個發佈單位再開 PR。

## 風格

- 不過度工程化：沒有具體消費端的欄位、流程、metadata 一律不加。
- 不做無謂的驗證，不寫防禦性的提示詞或程式碼。
- SKILL.md 保持精簡：細節放 references／templates／checklists，不塞進主檔。
- 階段可調整，契約不可省略；安全、範圍與真實驗證優先於精簡。

## 狀態

- 工作狀態權威是 GitHub Issues／PR 與 Git；`docs/NEXT_ACTION.md` 只保留當前前線，closeout 時重建。
- 目前無 open issues；工作狀態以 GitHub Issues 為準。
