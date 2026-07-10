---
name: maze-spec-hardening
description: 補強既有規格的工程契約、邊界與驗收條件。當使用者要求補強、完善或工程化 spec 時使用。
---

# spec-hardening

## 目標

把既有規格補成可實作、可拆 Issue、可驗收且不易漂移的工程契約。

## 前置條件

- 優先從 `MAZE_PROJECT.md` 取得規格實際路徑；未記錄時要求使用者指定，不得猜測根目錄 `spec.md`。
- 輸入不完整時標示待確認，只處理可確認部分。

## 執行流程

1. 依序補強 Contract、Invariants、Edge Cases、Acceptance Criteria、Test Plan、FROZEN、Drift Risk、Open Questions。
2. 對每項主要需求補上穩定 Task ID、目標、範圍、非範圍、依賴、風險、優先級判斷資訊及正式／候選狀態。
3. 使用 `checklists/` 的產品、工程與測試清單檢查缺漏；未確認項目不得自行定案。
4. 顯示修改摘要與仍待確認事項，取得確認後才更新原文件。

## 輸出契約

- 更新指定規格，保留原需求語意並包含上述 8 個補強區塊，缺一不可。
- 所有驗收條件必須可觀察或可測量。

## 邊界

- 不擴張產品範圍、不實作功能、不建立 GitHub Issue、不將候選需求自動升級為正式需求。
