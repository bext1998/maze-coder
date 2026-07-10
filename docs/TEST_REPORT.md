# maze-coder v2.0 驗證報告

> 日期：2026-07-10
> 範圍：Issue #5 本機實作

## 結果

| 驗證 | 結果 | 證據 |
|---|---|---|
| Shell syntax | 通過 | 三份 `.sh` 皆通過 `bash -n` |
| 結構與同步 | 通過 | `validate-skillpack.sh`：0 failures、0 warnings |
| 功能契約 | 通過 | `validate-skills-functional.sh` 全數通過 |
| 技能數量 | 通過 | 12 個來源技能，四種 Adapter 資源一致 |
| Token／字元基準 | 通過 | 12 份 SKILL.md 共 7,655 字元；原 11 份為 13,168，減少 5,513（41.9%） |
| 同步冪等 | 通過 | 第二次 `sync-adapters.sh` 輸出 `no changes` |
| Adapter 安裝煙霧 | 通過 | Claude Code、Codex、Cursor、opencode 的 router 與按需資源可解析 |
| Ubuntu 原生執行 | 未執行 | 目前為 Windows／Git Bash；功能腳本將此案例標為 SKIP |

## 行為等價基準

- 所有技能保留必要輸入、停止條件、確認點、寫入行為、輸出契約、禁止行為與交接邊界。
- GitHub 寫入、Assignee、標籤與狀態修改仍需使用者確認。
- Force push 到 main／master 的禁止規則與 `git revert` 替代方案保留。
- 新增 Dry Run、task-id 去重、優先級互斥、部分失敗與 Closeout 八狀態契約。

## 剩餘風險

- 尚未在正式 GitHub Repository 執行任何寫入情境；依計畫測試只驗證文件契約，不操作正式資源。
- Ubuntu 原生可攜性需在 Linux 或 CI 環境補驗。
