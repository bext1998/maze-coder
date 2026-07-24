---
name: maze-context-audit
description: 比對 agent 當前理解與專案文件，找出過期或矛盾假設。當使用者懷疑 agent 搞錯方向或上下文失真時使用。
invocation: both
---

# context-audit

## 目標

以專案證據列出上下文差異與修正建議。

## 前置條件

- 讀取可用的 `MAZE_PROJECT.md`、規格、Git／GitHub 證據、`NEXT_ACTION.md`、`DECISIONS.md`；忽略外部既有 `STATUS.md`，缺少文件時標記無法稽核範圍。

## 執行流程

1. 明列 agent 對專案目標、階段、下一步與已確認決策的理解。
2. 逐項對照文件與 repo 證據，執行 `checklists/context-consistency-checklist.md`。
3. 對每個差異列出「目前理解／證據記載／建議修正」，不自行選定哪一方正確。

## 輸出契約

- 輸出差異、證據位置與修正建議；無差異時明確回報稽核通過。

## 邊界

- 不修改文件、不審查程式碼、不評價技術決策、不建立新文件或用猜測補缺漏。
