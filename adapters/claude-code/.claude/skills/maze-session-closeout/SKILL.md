---
name: maze-session-closeout
description: 在 Coding Session 結束時同步 Git、GitHub、QA 與專案文件狀態。當使用者說「結束 session」、「更新狀態」或「今天先到這裡」時使用。
disable-model-invocation: true
---

# session-closeout

## 目標

以 GitHub／Git 可驗證證據辨識工作前線；僅在使用者明確要求 closeout 時重建精簡 `NEXT_ACTION.md`。

## 前置條件

- 讀取 `MAZE_PROJECT.md`、Git branch／working tree／commit、Issue、PR、CI、QA、規格與 `NEXT_ACTION.md`；忽略外部既有 `STATUS.md`，不得刪除它。
- Repository 設定與目前 repo 不一致時停止。

## 執行流程

1. 依 `references/state-model.md` 判定 `in-progress`、`blocked`、`awaiting-review`、`awaiting-merge`、`merged-awaiting-close`、`completed`、`research-only` 或 `untracked`。
2. 無法確定關聯 Issue 時，要求指定既有 Issue、建立新 Issue、標為未追蹤或研究；不得以相似度自行關聯。
3. GitHub 修改必須先顯示 diff 並取得確認，再逐項更新或關閉；失敗不得重做已成功項目。
4. 僅在使用者明確要求 closeout 時，以目前權威證據整體重建 `NEXT_ACTION.md`；否則只回報，不寫核心文件。

## 輸出契約

- 明確 closeout 時只重建 `NEXT_ACTION.md`：一項下一階段成果、最多三項動作、阻塞／待決策與必要權威連結；不得追加、寫入 `STATUS.md`、複製完整 Issue／PR 狀態或記錄 session 流水帳。
- 不建立 Session Closeout Report、`summary.md` 或任何日期型 session summary；交接需求改用 `maze-handoff-summary`。

## 邊界

- 不 commit、push、merge、執行新 QA、自動關閉／重開 Issue、改優先級、改 Assignee 或擴張 Issue 範圍。
