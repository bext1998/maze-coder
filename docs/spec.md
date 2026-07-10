# maze-coder 規格 v2.0

> Issue #5 本文與第 26 節留言為本版需求基準。v1.5 未落地的 `maze-writing-skills`、`maze-update` 與 `update-skillpack.sh` 不屬於本版。

## 1. 目標

maze-coder 提供 12 個可攜式技能，將需求、規格、GitHub Issues、PR、QA 與 Session 狀態串成可追蹤工作流，並讓 Claude Code、Codex、Cursor、opencode 載入相同邏輯。

本版新增 `maze-spec-to-issues`，重構 `maze-session-closeout`，並在功能等價與安全限制不變的前提下精簡所有 SKILL.md。

## 2. 技能清單

1. `maze-idea-to-spec`
2. `maze-spec-hardening`
3. `maze-project-init`
4. `maze-spec-to-issues`
5. `maze-session-closeout`
6. `maze-github-safe-ops`
7. `maze-design-review`
8. `maze-qa-verification`
9. `maze-repo-map`
10. `maze-context-audit`
11. `maze-bug-reproduction`
12. `maze-handoff-summary`

## 3. Spec → Issues 契約

- Repository 與 spec 路徑必須來自 `MAZE_PROJECT.md`；缺漏或 repo 不一致時停止。
- 讀取規格、專案文件、Open/Closed Issues、Open/Merged PR、標籤與必要 Git 歷史。
- 抽取功能、品質、安全、相容性、測試、文件、遷移、部署、缺陷、研究、技術債及待決策工作。
- 排除背景、已完成、重複、非目標及無法驗證內容；不確定範圍列為候選。
- 每個正式 Issue 有單一目標、範圍／非範圍、依賴、可驗收 AC、一個 P0–P4 與至少一個類別。
- 優先重用 repo 既有同義標籤；新增標籤、Issue、Assignee 或修改前皆需確認。
- 預設只執行 Dry Run；10 項以下完整顯示，11–30 項分批，超過 30 項只提出 Parent／分組方案。
- 使用穩定 task-id 與 spec revision marker 去重；重試不得重建成功 Issue。
- Parent／Child 使用 GitHub Sub-issue；部分關聯失敗只重試原 Issue 的缺少操作。

## 4. 規格變更同步

- 新需求建立草稿；尚未開始的修改顯示 diff 後更新。
- 進行中修改標為 Scope Change，由使用者選擇更新或另建 Issue。
- 刪除未開始需求只建議 `not planned`；已完成需求保留歷史。
- 與已合併成果衝突時建立新修正 Issue，不改寫歷史 Issue。

## 5. Session Closeout 契約

- 依 Git branch、working tree、commit、Issue、PR、CI、QA、STATUS 與 NEXT_ACTION 判定狀態。
- 支援 `in-progress`、`blocked`、`awaiting-review`、`awaiting-merge`、`merged-awaiting-close`、`completed`、`research-only`、`untracked`。
- `completed` 必須同時滿足實作、AC、QA、適用 CI、文件、PR 合併及 Issue 關閉。
- GitHub 寫入先顯示 diff 並確認；不得自動 close／reopen、改優先級、改 Assignee、merge 或執行 QA。
- 必要輸出只有更新後的 `STATUS.md` 與 `NEXT_ACTION.md`；不建立任何 Session Summary／Report。

## 6. 專案文件

`maze-project-init` 產出 `MAZE_PROJECT.md`、`PROJECT_BRIEF.md`、`STATUS.md`、`NEXT_ACTION.md`、`DECISIONS.md` 與工具指令。

`MAZE_PROJECT.md` 記錄：spec 路徑、Repository、Issue tracking、Spec to Issues、優先級／類別標籤慣例、預設 Assignee 策略及是否允許建立標籤；不得包含憑證。

## 7. Adapter 與同步

- `skills/` 為唯一技能 source of truth；同步必須包含 SKILL.md 及其 references、templates、checklists。
- Claude Code 使用完整 `.claude/skills/`。
- Codex／opencode 使用精簡 `AGENTS.md` router 與 `.maze-coder/skills/` 資源。
- Cursor 使用單一 router rule 與 `.cursor/maze-coder/skills/` 資源。
- Adapter 只能轉換載入與包裝方式，不得增刪技能行為。
- `sync-adapters.sh` 只更新受管理產物；第二次執行不得產生差異。

## 8. SKILL.md 效率契約

- frontmatter 只有 `name`、`description`；本文使用目標、前置條件、執行流程、輸出契約、邊界。
- 高頻流程與高風險限制保留在 SKILL.md；長規則、模板、範例與低頻例外按需載入。
- 不得刪除必要輸入、停止條件、確認點、寫入、輸出、禁止行為、錯誤處理、冪等性與技能邊界。
- 12 份 SKILL.md 總字元數低於精簡前 11 份的 13,168；單檔超過 3,000 字元只警告。

## 9. 驗收條件

- [ ] 共 12 個來源技能且四個 Adapter 全部可解析。
- [ ] `maze-spec-to-issues` 具備讀取、抽取、去重、拆解、標籤、Dry Run、確認、部分失敗與規格同步規則。
- [ ] 正式 Issue 優先級互斥；候選與 P0–P4 互斥；每項至少一個類別。
- [ ] Issue template 包含 AC、完成條件與機器可辨識 marker。
- [ ] Closeout 能判定八種狀態，且未滿足全部條件時不宣告完成。
- [ ] STATUS／NEXT_ACTION／MAZE_PROJECT 模板已更新，Session Summary 模板已移除。
- [ ] README、核心文件、同步與驗證腳本均使用 12 技能。
- [ ] 所有 Adapter 資源與 source of truth 一致，引用路徑可解析。
- [ ] 驗證拒絕無 frontmatter、空必要章節、TODO／FIXME、技能數量或 Adapter 不一致。
- [ ] 同步第二次無差異，功能驗證與 shell syntax 通過。
- [ ] 12 份 SKILL.md 總字元數低於 13,168，且行為基準未退化。

## 10. 非目標

- 自動產品 Roadmap、Milestone、GitHub Project、merge、review、產品決策、優先級變更、候選升級、Issue 刪除或歷史 Issue 改寫。
- 自動建立 Session Report／日期型摘要，或以 AI 判斷取代人工 QA。
