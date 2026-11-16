# maze-coder — Agent 規範

maze-coder 是跨 Coding Agent 的 Agent Skills 集合：每個 `maze-*` 技能都是獨立目錄，直接安裝到各 host 原生的技能目錄使用。

## Source of Truth

- `skills/` 是唯一來源；沒有生成物、沒有同步腳本，新增或修改技能只改這裡。
- 每個技能的 `references/`、`templates/`、`checklists/`、`examples/` 跟技能一起安裝，不複製到 repo 根目錄。
- 沒有 Harness 契約、Profiles、Model Overlays 與 Adapter 產物；不要再把它們加回來。

## 工作樹

- 集中放置於 `D:\AgentCoding\.codex\worktrees`。
- 命名格式：`maze/西元年-月-日-短雜湊`（例：`maze/2026-09-30-418b1ca`）。

## 工作流程

1. 動手前讀目標技能的 `SKILL.md` 與其資源目錄。
2. 技能 frontmatter 只允許 `name`、`description` 與選用的 `disable-model-invocation: true`；使用者明示觸發的技能才加該欄位，模型可主動載入的技能不加。
3. 路徑基準：`references/`、`templates/`、`checklists/`、`examples/` 這類資源路徑以**技能根目錄**為基準；`../` 開頭的路徑以**所在檔案的目錄**為基準。會被其他技能跨技能載入的 reference，要在檔案內寫明它的資源路徑基準是所屬技能根目錄；跨技能引用則在引用端 SKILL.md 寫明需要同時安裝哪個技能。
4. 修改後執行 `bash scripts/validate-skillpack.sh` 與 `bash scripts/validate-skills-functional.sh`。
5. Commit message 依 Conventional Commits，引用對應 Issue（`Closes #N` 僅用於完整完成）。

## 工作原則

- 先讀任務相關實作、文件、呼叫者與測試；不得猜測可查證行為。
- 只處理明確範圍，優先修正根因；不順手重構、清理或擴張產品決策。
- 證據（Git／GitHub／CI／QA／repo）優先於口述；無法查證時才詢問並標記限制。
- 不執行未授權的破壞性、不可逆或外部寫入；需要時先展示目標與變更並取得明確確認。
- 不偽造測試、工具結果、外部狀態或完成證據；未執行的檢查不得宣稱通過；未滿足驗收條件不得宣告完成。
- 不超出使用者明確工作範圍；新需求與旁支問題另行揭露。
- 不因模型能力放寬安全限制，也不因模型能力加碼無關流程。
- 不硬編或輸出 token、API key、密碼與私密憑證。
- 執行與風險相稱的測試、lint、型別或 build；完成前確認需求、驗證與剩餘風險都已處理。
- 技能缺少必要輸入時停止並列出缺漏；同名輸出已存在時不得靜默覆蓋。
- 回應以結果或下一步開始；不得為縮短內容刪掉安全規則。

## Git 與 GitHub

- Git／GitHub 操作遵守 `skills/maze-github-safe-ops/SKILL.md`；只有使用者明確要求時才 commit、push 或對外發布。
- Force push 到 main／master 必須停止；高風險操作需先確認並提供可回復方案。
- PR 完整完成 Issue 才能用 `Closes #N`；部分完成使用 `Related to #N`。
- Issue 僅在實作、AC、必要且適用的專案檢查、文件、PR 合併與 Issue 關閉全部成立時為完成；未確認存在的 QA／CI 不得作為完成條件。

## Release Label 與 PR 粒度

- Issue／PR 的 `release:major`（破壞性變更）、`release:minor`（新增功能，向下相容）、`release:patch`（修補、文件、內部調整）標籤，合併時會自動打對應版本 tag。
- 凡使用這些標籤，數個相關功能／修正應合併進同一個 PR，一個 PR 對應一次版本發佈，避免版本碎片化而難以管理。
- 不要為每個小 issue 各開一個帶 release 標籤的 PR；先累積成一個發佈單位再開 PR。

## 風格

- 不過度工程化：沒有具體消費端的欄位、流程、metadata 一律不加。
- 不做無謂的驗證，不寫防禦性的提示詞或程式碼。
- SKILL.md 保持精簡：觸發、必要流程、確認點、輸出與邊界；長規則、模板與低頻例外放一層深的資源。
- 階段可調整，契約不可省略；安全、範圍與真實驗證優先於精簡。

## 狀態

- 工作狀態權威是 GitHub Issues／PR 與 Git；`docs/NEXT_ACTION.md` 只保留當前前線，closeout 時重建。
- 目前 open issue：#59（技能包簡化為原生 Agent Skills，本 repo 正在進行）與 #58（全域安裝，已併入 #59 的安裝部分）。
