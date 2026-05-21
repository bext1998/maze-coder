# maze-coder — opencode Adapter

## 說明

本目錄是 maze-coder 技能包的 opencode 適配格式。

將 `AGENTS.md` 複製到你的專案根目錄，opencode 將在每個 session 開始時自動讀取技能指令。

## 使用方式

```bash
cp AGENTS.md /your-project/
```

## 技能清單

| 技能 | 用途 |
|---|---|
| `idea-to-spec` | 將想法轉換成 spec.md |
| `spec-hardening` | 補強 spec.md 的工程細節 |
| `project-init` | 初始化專案文件集 |
| `session-closeout` | Session 結束更新 |
| `github-safe-ops` | Git 安全操作 |
| `design-review` | 前端設計審查 |
| `qa-verification` | QA 驗證 |
| `repo-map` | 產生 Repo 結構地圖 |
| `context-audit` | 上下文一致性稽核 |
| `bug-reproduction` | Bug 重現文件 |
| `handoff-summary` | 交接摘要 |

## 注意事項

`AGENTS.md` 由 `sync-adapters.sh` 從 `skills/` 目錄同步產生，請勿直接編輯。
若需修改技能內容，請修改 `skills/*/SKILL.md` 後重新執行 `bash scripts/sync-adapters.sh`。
