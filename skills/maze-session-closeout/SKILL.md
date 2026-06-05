---
name: maze-session-closeout
description: |
  Coding session 結束後，更新 STATUS.md、NEXT_ACTION.md，不產出額外 summary 檔案。
  當使用者說「結束 session」、「更新狀態」、「今天先到這裡」時觸發。
---

# session-closeout：Session 結束更新

## 技能目標

Coding session 結束後，若不更新狀態文件，下一個 session 的 agent（或人類）需要花時間重建上下文。本技能確保每次 session 結束都留下清晰的狀態快照和明確的下一步。

## 前置條件（Preconditions）

- 使用者必須提供本次 session 的摘要（做了什麼、遇到什麼問題）
- 若摘要為空，列出需要填寫的問題，不得留空白模板：
  - 「本次 session 完成了哪些事？」
  - 「有沒有遇到問題或阻塞？」
  - 「下一步要做什麼？」
- 若存在 STATUS.md，讀取其當前內容後再更新

## 執行流程

### Phase 0：收集資訊

若使用者未提供，詢問：
1. 本次 session 完成的事項
2. 進行中但未完成的事項
3. 遇到的問題或阻塞
4. 下一步行動計畫

### Phase 1：更新 STATUS.md

- 移動「進行中」事項到「已完成」（若已完成）
- 更新「已知問題」
- 清除已解決的「阻塞項目」
- 更新最後更新時間

### Phase 2：更新 NEXT_ACTION.md

- 清除已完成的行動步驟
- 根據使用者提供的下一步更新「下一個 Session 的目標」
- 更新「需要決定的事項」

### Phase 3：確認不產出額外 summary 檔案

- 不建立 `summary.md`、`session-summary.md` 或 `session-summary-[日期].md`
- 本次 session 的完成事項、未解決問題與下一步，應整合進 `STATUS.md` 與 `NEXT_ACTION.md`
- 若使用者明確要求交接文件，改用 `maze-handoff-summary` 產出 `HANDOFF.md`

## 輸出（Output Contract）

- **STATUS.md**：更新後的當前狀態，帶有新的最後更新時間
- **NEXT_ACTION.md**：更新後的下一步行動
- **不產出 summary 檔案**：避免建立多餘的 `summary.md` 或 `session-summary-*` 文件

## 技能邊界（本技能不做的事）

- 不做 git commit 或 push
- 不修改 `spec.md` 或 `DECISIONS.md`
- 不評估本次 session 的工作品質
- 不決定技術方向（只記錄使用者的決策）
- 不產出 QA 報告（那是 `qa-verification` 的工作）
