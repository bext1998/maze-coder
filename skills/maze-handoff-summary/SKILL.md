---
name: maze-handoff-summary
description: |
  產出結構化的 HANDOFF.md，讓接手的人或工具能快速理解當前狀態並繼續工作。
  當使用者說「幫我建立交接文件」、「我要換工具」、「其他人要接手這個專案」時觸發。
---

# handoff-summary：交接摘要

## 技能目標

在工具切換或人員交接時，若沒有清晰的狀態摘要，接手者需要大量時間重建上下文。本技能產出一份完整的交接文件，讓接手者在 5 分鐘內理解當前狀態並知道下一步。

## 前置條件（Preconditions）

- 建議已完成 `session-closeout`，確保 STATUS.md 和 NEXT_ACTION.md 是最新的
- 需要能讀取（若存在）：
  - `spec.md`
  - `STATUS.md`
  - `NEXT_ACTION.md`
  - `DECISIONS.md`

## 執行流程

### Phase 1：收集當前狀態

閱讀所有可用的專案文件，整合：
- 專案概述（目標、技術棧）
- 當前開發階段
- 已完成的工作
- 進行中的工作
- 未解決的問題
- 重要的技術決策

### Phase 2：詢問補充資訊

若文件不完整，詢問：
- 「有什麼是文件裡沒有記錄的重要脈絡？」
- 「接手者需要特別注意什麼？」
- 「有什麼已知的地雷或陷阱？」

### Phase 3：產出 HANDOFF.md

填寫 `HANDOFF.template.md`，包含：
- 5 分鐘讀完的 TL;DR
- 當前狀態快照
- 下一步行動
- 技術決策摘要
- 注意事項（地雷、陷阱）

## 輸出（Output Contract）

- **位置**：`HANDOFF.md`（使用者指定目錄）
- **格式**：符合 `HANDOFF.template.md` 的文件
- **TL;DR**：必須在 5 句話內可讀完

## 技能邊界（本技能不做的事）

- 不評估工作品質
- 不做技術決策（只記錄已做的決策）
- 不更新 STATUS.md 或 NEXT_ACTION.md（先做 session-closeout）
- 不建立新的功能文件
- 不包含程式碼說明（只包含狀態和決策）
