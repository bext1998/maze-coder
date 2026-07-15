# maze-coder v3.1 驗證報告

> 日期：2026-07-15
> 範圍：Issues #16–#19 本機實作

## 結果

| 驗證 | 結果 | 證據 |
|---|---|---|
| Shell syntax | 通過 | 三份 `.sh` 皆通過 `bash -n` |
| 結構與同步 | 通過 | `validate-skillpack.sh`：0 failures、0 warnings；22 canonical／19 public／3 internal |
| 功能契約 | 通過 | `validate-skills-functional.sh` 全數通過 |
| Adaptive scenarios | 通過 | `validate-adaptive-scenarios.sh`：11 組情境通過，估計指標未退化 |
| Token／字元上限 | 通過 | 22 份 SKILL.md 共 15,240 字元，低於 16,500 上限 |
| 同步冪等 | 通過 | 第二次 `sync-adapters.sh` 輸出 `no changes` |
| Adapter 資源 | 通過 | Claude Code、Codex、Cursor、opencode 的 router、skills、core 與 templates 一致 |
| Ubuntu 原生執行 | 未執行 | 目前為 Windows／Git Bash；功能腳本將此案例標為 SKIP |

## 行為等價基準

- 所有技能保留必要輸入、停止條件、確認點、寫入行為、輸出契約、禁止行為與交接邊界。
- GitHub 寫入、Assignee、標籤與狀態修改仍需使用者確認。
- Force push 到 main／master 的禁止規則與 `git revert` 替代方案保留。
- 新增規格審查六面向／穩定 finding ID、PR review 證據與降級契約，以及 GitHub CLI 結構化輸出、預覽確認與冪等失敗處理。
- 保留 Dry Run、task-id 去重、優先級互斥、部分失敗與 Closeout 八狀態契約。

## 剩餘風險

- 未在正式 GitHub Repository 執行 GitHub CLI 寫入情境；本次驗證只檢查文件契約，不操作正式資源。
- 尚未執行獨立 subagent 的對抗式壓力驗證；高風險寫入邊界仍需後續補驗。
- Ubuntu 原生可攜性需在 Linux 或 CI 環境補驗。
