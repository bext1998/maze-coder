---
name: maze-handoff-summary
description: 建立跨人員或工具的 HANDOFF.md。當使用者要換工具、換人接手或要求交接文件時使用。
disable-model-invocation: true
---

# handoff-summary

## 目標

讓接手者在五分鐘內理解專案狀態、決策、風險與下一步。

## 前置條件

- 建議先完成明確 `maze-session-closeout`；讀取規格、Git／GitHub、NEXT_ACTION、DECISIONS 與可用 repo 證據，忽略既有 `STATUS.md`。
- 文件缺漏時只詢問交接必要資訊。

## 執行流程

1. 整合專案目的、技術棧、目前狀態、完成／進行中工作、阻塞與重要決策。
2. 補問文件沒有的陷阱、外部依賴或接手注意事項。
3. 填寫 `templates/HANDOFF.template.md`，讓 TL;DR 不超過五句。

## 輸出契約

- 產出 `HANDOFF.md`，包含 TL;DR、狀態快照、下一步、決策與注意事項。

## 邊界

- 不更新 NEXT_ACTION／DECISIONS、不評估品質、不做新決策、不建立功能或 Session Summary 文件。
