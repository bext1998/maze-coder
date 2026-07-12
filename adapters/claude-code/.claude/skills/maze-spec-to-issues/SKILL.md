---
name: maze-spec-to-issues
description: 將規格中的未完成工作轉成可追蹤、可驗收的 GitHub Issues，並同步規格變更。當使用者要求把 spec 拆成 Issues、建立開發待辦或同步 spec 與 GitHub 時使用。
disable-model-invocation: true
---

# spec-to-issues

## 目標

從正確規格抽取工作、去重並產生 GitHub Issue Dry Run；取得確認後才建立或更新資源。

## 前置條件

- 從 `MAZE_PROJECT.md` 取得 Repository 與 spec 實際路徑；缺少設定、檔案、讀取權限或 repo 不一致時停止。
- 實際寫入需有 GitHub 權限及使用者明確允許；不得因 repo 擁有者身分推定 Assignee。
- 執行前讀取 `references/issue-model.md`；同步既有 Issue 或處理失敗時再讀 `references/sync-and-errors.md`。

## 執行流程

1. 讀取規格、PROJECT_BRIEF、DECISIONS、STATUS、Open/Closed Issues、Open/Merged PR、標籤與必要 Git 歷史。
2. 抽取正式與候選工作，排除背景、完成、重複、非目標及不可驗證描述。
3. 以 marker、來源、Issue／PR 關聯與內容判斷已存在、完成、進行中或需建立；不確定時列為候選。
4. 拆成單一目標且可由主要 PR 驗收的 Issue，套用一個優先級與至少一個類別；大型成果使用 Parent/Sub-issue。
5. 預設輸出完整 Dry Run：建立、更新、略過、完成、候選、標籤、Assignee、依賴與新增標籤建議。
6. 詢問 Assignee 採本人、不指派、逐項或指定帳號；顯示所有 GitHub 寫入後取得確認，再逐項執行並記錄結果。

## 輸出契約

- Issue 使用 `templates/issue.template.md`，包含可驗證 AC、規格 revision、穩定 task-id 與 `maze-coder` marker。
- 10 項以下完整顯示；11–30 項分批；超過 30 項只提出分組方案。
- 寫入結果逐項標示成功、失敗、略過、重複、已存在、權限、Assignee 與標籤狀態。

## 邊界

- 不自動建立／修改／關閉 Issue 或標籤、不自動改優先級／Assignee、不建立 Milestone／Project、不把候選工作升級為承諾、不補建歷史 Issue。
