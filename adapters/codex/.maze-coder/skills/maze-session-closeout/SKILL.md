---
name: maze-session-closeout
description: 在 Coding Session 結束時同步 Git、GitHub、QA 與專案文件狀態。當使用者說「結束 session」、「更新狀態」或「今天先到這裡」時使用。
invocation: user
---

# session-closeout

## 目標

以可驗證證據更新 `STATUS.md` 與 `NEXT_ACTION.md`，並辨識尚未完成的 GitHub 狀態。

## 前置條件

- 讀取 `MAZE_PROJECT.md`、Git branch／working tree／commit、Issue、PR、CI、QA、STATUS 與 NEXT_ACTION；無法取得的資訊才詢問使用者。
- Repository 設定與目前 repo 不一致時停止。

## 執行流程

1. 依 `references/state-model.md` 判定 `in-progress`、`blocked`、`awaiting-review`、`awaiting-merge`、`merged-awaiting-close`、`completed`、`research-only` 或 `untracked`。
2. 無法確定關聯 Issue 時，要求指定既有 Issue、建立新 Issue、標為未追蹤或研究；不得以相似度自行關聯。
3. GitHub 修改必須先顯示 diff 並取得確認，再逐項更新或關閉；失敗不得重做已成功項目。
4. 更新 STATUS 的 Issue/PR 分區，再依優先規則精簡 NEXT_ACTION。

## 輸出契約

- 更新 `STATUS.md`、`NEXT_ACTION.md` 與最後同步時間。
- 不建立 Session Closeout Report、`summary.md` 或任何日期型 session summary；交接需求改用 `maze-handoff-summary`。

## 邊界

- 不 commit、push、merge、執行新 QA、自動關閉／重開 Issue、改優先級、改 Assignee 或擴張 Issue 範圍。
