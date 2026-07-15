---
name: maze-pr-review
description: 以 GitHub PR 為單位執行高訊號、可定位且唯讀的程式碼審查。
invocation: user
---

# pr-review

## 目標

整合 PR 說明、base／head、diff、checks、comments、關聯 Issue／規格與測試，找出值得修改的問題。

## 前置條件

- 接受 PR URL／number，或只在目前 repo／branch 能唯一辨識時推定目標。
- 透過 `maze-github-cli` Read 契約取得證據；讀取相關實作與測試，依 `checklists/pr-review-checklist.md` 審查。
- `gh` 不可用、未登入或權限不足時，僅在 base 可確認且工作樹不污染結果時降級為本地 diff，列出缺少證據。

## 執行流程

1. 檢查說明符合度、正確性、錯誤／回歸／相容性、狀態／競態、資料／安全、測試與無關改動。
2. 以 Blocker、Major、Minor、Nit 回報可重現且可定位的 finding；映射 Request changes、Comment、Approve 或 Insufficient evidence。

## 輸出契約

輸出 findings、測試缺口、已審查且未發現問題區域、限制與合併條件；降級或證據不足不得 Approve。

## 邊界

唯讀；不留言、批准、request changes、修改 PR／Issue／branch，不修復程式碼。
