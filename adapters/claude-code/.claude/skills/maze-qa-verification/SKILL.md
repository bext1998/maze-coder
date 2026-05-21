---
name: maze-qa-verification
description: |
  驗證功能是否符合 spec.md 的驗收標準，產出 QA_REPORT.md。
  當使用者說「幫我做 QA」、「驗收功能」、「測試這個功能」時觸發。
---

# qa-verification：QA 驗證

## 技能目標

功能開發完成後，若缺乏系統性的 QA 流程，容易遺漏邊界情況和迴歸問題。本技能依照 spec.md 的驗收標準，建立可追蹤的 QA 報告。

## 前置條件（Preconditions）

- 必須提供：功能描述或 spec.md 中的對應功能說明
- 必須提供：測試目標（驗收哪些條件）
- 若測試環境未就緒，列出缺漏的環境條件，不得假設環境已就緒

## 執行流程

### Phase 0：確認測試範圍

- 閱讀 spec.md 中的 Acceptance Criteria（若存在）
- 確認測試環境狀態（本地 / staging / 其他）
- 識別不可測試的項目，標注原因

### Phase 1：功能測試（Happy Path）

對每個核心功能執行：
- 正常輸入 → 預期輸出
- 確認與 spec.md 驗收標準一致

### Phase 2：邊界情況測試

使用 `code-quality-checklist.md` 和 `test-plan-checklist.md`，測試：
- 空輸入 / 空狀態
- 最大值 / 最小值邊界
- 非預期格式輸入
- 中途中斷的情況

### Phase 3：迴歸測試

使用 `regression-checklist.md`，確認：
- 現有功能未受影響
- 以前的 bug 未重現

### Phase 4：產出報告

填寫 `QA_REPORT.template.md`，記錄：
- 測試結果（通過 / 失敗 / 無法測試）
- 發現的問題（嚴重度、重現步驟）
- 整體結論（是否可以 merge / release）

## 輸出（Output Contract）

- **位置**：`QA_REPORT.md`（使用者指定目錄）
- **格式**：符合 `QA_REPORT.template.md` 的報告
- **必要內容**：每個測試案例的結果、發現的問題清單、整體結論

## 技能邊界（本技能不做的事）

- 不修改程式碼（只報告問題，修復由使用者或其他技能負責）
- 不做效能壓力測試
- 不做安全滲透測試
- 不在測試環境未就緒時假設測試通過
- 不做視覺設計審查（那是 `design-review` 的工作）
