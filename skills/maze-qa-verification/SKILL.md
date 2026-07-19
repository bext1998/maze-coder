---
name: maze-qa-verification
description: 依規格驗收功能並產出 QA_REPORT.md。當使用者要求 QA、驗收、測試功能或確認是否可合併時使用。
invocation: user
---

# qa-verification

## 目標

以可重現證據判定每項驗收條件通過、失敗或無法測試。

## 前置條件

- 取得功能描述或規格、測試目標與可用環境；缺少環境時列出限制，不得假設通過。

## 執行流程

1. 對照 Acceptance Criteria，標記不可測項目與原因。
2. 依 `checklists/test-plan-checklist.md` 與 `code-quality-checklist.md` 執行正常、空值、邊界、格式錯誤與中斷案例；GUI 原型另讀 `checklists/prototype-qa-checklist.md`。
3. 依 `checklists/regression-checklist.md` 確認相關既有行為未退化。
4. 記錄實際命令、結果、失敗重現步驟及風險，填寫 `templates/QA_REPORT.template.md`。

## 輸出契約

- 產出 `QA_REPORT.md`，逐項記錄通過／失敗／無法測試及整體 merge／release 建議；原型另標示是否可供方向或實作決策，不得等同 production-ready。

## 邊界

- 不修復程式碼、不隱藏失敗、不做未授權的壓力測試、安全滲透或視覺審查。
