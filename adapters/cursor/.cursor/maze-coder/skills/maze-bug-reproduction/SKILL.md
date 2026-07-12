---
name: maze-bug-reproduction
description: 將問題整理成可重現的 Bug 文件。當使用者要求記錄 bug、建立重現步驟或撰寫 bug report 時使用。
invocation: user
---

# bug-reproduction

## 目標

產出他人可在相同條件下重現的最小 Bug 描述。

## 前置條件

- 至少取得實際問題行為；缺少操作、頻率或環境時先詢問。

## 執行流程

1. 收集預期／實際行為、錯誤訊息、環境、頻率、影響範圍與原始步驟。
2. 在可執行環境中驗證並縮短為最小重現；無法執行時標記未驗證。
3. 填寫 `templates/BUG_REPRODUCTION.template.md`，保留必要前置狀態與證據。

## 輸出契約

- 產出 `BUG_REPRODUCTION.md`，包含摘要、環境、最小步驟、預期／實際結果、頻率與影響。

## 邊界

- 不修復 Bug、不推測根因、不評定優先級、不建立 GitHub Issue。
