# 自適應 Harness 契約

> 供 AI agent 與 Adapter 使用。先讀 `core/invariants.md` 與 `core/workflow-model.md`；階段可調整，契約不可省略。

## 範圍與證據

- 必須先讀取任務相關實作、文件、呼叫者與測試；不得猜測可查證行為。
- 只處理明確範圍，優先修正根因；不得順手重構、清理或擴張產品決策。
- Git、GitHub、CI、QA 與 repo 證據優先於口述；無法查證時才詢問並標記限制。

## 寫入與確認

- 規格、Issue、PR、標籤、Assignee、狀態或既有文件的破壞性／外部寫入，必須先顯示目標與變更並取得明確確認。
- 批次操作必須逐項記錄結果；部分失敗不得重做成功項目，重試前先以穩定識別碼去重。
- 不得硬編或輸出 token、API key、密碼與私密憑證。

## Git 與 GitHub

- Commit、push、merge、rebase 等操作遵守 `maze-github-safe-ops`；只有使用者明確要求時才執行 commit 或外部發布。
- Force push 到 main／master 必須停止；高風險操作需先確認並提供可回復方案。
- PR 完整完成 Issue 才能用 `Closes #N`；部分完成使用 `Related to #N`。
- Issue 僅在實作、AC、QA、適用 CI、文件、PR 合併與 Issue 關閉全部成立時為完成。

## 文件與技能

- `skills/` 是技能 source of truth；模板與 references 跟隨技能保存，根 `templates/` 與 Adapter 由同步腳本產生。
- 技能缺少必要輸入時停止並列出缺漏；同名輸出已存在時不得靜默覆蓋。
- SKILL.md 只保留觸發、必要流程、確認點、輸出與邊界；長規則、模板與低頻例外放入一層深資源。
- 所有 29 個 canonical skills、Profiles、Overlays 與核心契約必須出現在各 Adapter；Adapter 只能改變包裝與載入方式，不得改變技能邏輯。

## Adapter 與 Token 效率

- Router 只描述共用規則、觸發對應與資源路徑；觸發後才讀取目標 SKILL.md，再按指示讀 references／templates／checklists。
- 不得在每個 Adapter 重複內嵌全部技能；同步產物必須自包含且引用路徑可解析。
- 回應以結果或下一步開始，並行處理獨立讀取；不得以刪除安全規則換取更短內容。

## 驗證與完成

- 執行與風險相稱的測試、lint、型別或 build；未執行的檢查不得宣稱通過。
- 修改同步或生成流程時，第二次執行必須無差異。
- 只有需求、驗證、文件同步與剩餘風險都已處理，才能宣告完成。
