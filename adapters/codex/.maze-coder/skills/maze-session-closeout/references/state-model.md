# Session 狀態模型

依可驗證證據判定；`blocked` 優先於其他未完成狀態。

| 狀態 | 判定條件 |
|---|---|
| `in-progress` | 有未提交／未完成工作，Issue 尚未完成且無 Open PR |
| `blocked` | 依賴、權限、環境或外部條件阻止下一步 |
| `awaiting-review` | PR 已建立但尚未取得必要 review，或有 changes requested |
| `awaiting-merge` | 必要 review 與適用 CI 已通過，PR 尚未合併 |
| `merged-awaiting-close` | PR 已合併，但 Issue、AC、QA、CI 或文件仍未完成 |
| `completed` | AC、QA、適用 CI、文件、PR 合併與 Issue 關閉全部成立 |
| `research-only` | 僅調查／實驗，沒有正式程式碼交付 |
| `untracked` | 有實際程式碼變更但沒有 Issue，且不是研究工作 |

## STATUS 區段

保留進行中 Issues、Blocked Issues、Awaiting Review PR、Awaiting Merge PR、Merged Awaiting Close、最近完成 Issues、未追蹤本機工作及最後同步時間；只摘要並引用編號，不複製 Issue 全文。

## NEXT_ACTION 排序

依序為未完成 P0、P1、阻塞其他工作的前置 Issue、已開始工作、Awaiting Review、Awaiting Merge、Merged Awaiting Close、P2、P3、P4。候選任務不得自動加入，只保留下一個 Session 真正會執行的少量步驟。
