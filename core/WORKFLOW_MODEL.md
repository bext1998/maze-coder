# 標準工作流模型

> **受眾：AI agent + 人類維護者**
> 本文件描述技能之間的標準執行順序。

---

## 主要工作流：從想法到可交付的專案

```
使用者有模糊想法
       │
       ▼
[idea-to-spec] ──────────────────── 產出：spec.md（草稿）
       │
       ▼
[spec-hardening] ────────────────── 產出：spec.md（補強版，含 Contract/Invariants/AC）
       │
       ▼
[project-init] ──────────────────── 產出：PROJECT_BRIEF / STATUS / NEXT_ACTION / DECISIONS
       │
       ▼
     開始 coding session
       │
  ┌────┴────┐
  │         │
  ▼         ▼
[repo-map]  [context-audit] ──────── 視需要執行，建立或驗證當前狀態理解
  │         │
  └────┬────┘
       │
       ▼
     工作中（coding / debugging）
       │
  ┌────┴──────────────────┐
  │                       │
  ▼                       ▼
[bug-reproduction]    [design-review] ── 遇到 bug 或前端輸出時觸發
       │                   │
       └────────┬──────────┘
                │
                ▼
         [qa-verification] ────────── 功能完成後執行 QA
                │
                ▼
        [github-safe-ops] ─────────── commit / push 前執行
                │
                ▼
       [session-closeout] ─────────── session 結束時執行
                │
                ▼
       [handoff-summary] ──────────── 交接給其他人或其他工具前執行
```

---

## 技能觸發時機

| 技能 | 典型觸發點 | 呼叫頻率 |
|---|---|---|
| `idea-to-spec` | 新專案開始、有新功能想法 | 每個新主題一次 |
| `spec-hardening` | spec.md 草稿完成後 | 每次 spec 更新後 |
| `project-init` | spec 補強完成後，開始實作前 | 每個專案一次 |
| `repo-map` | 進入陌生 repo、長期未工作後 | 按需 |
| `context-audit` | 懷疑 agent 上下文不一致時 | 按需 |
| `bug-reproduction` | 發現 bug 需要記錄重現步驟時 | 每個 bug 一次 |
| `design-review` | 前端輸出完成後、PR 前 | 每個前端功能一次 |
| `qa-verification` | 功能完成後，準備 merge 前 | 每個功能完成後 |
| `github-safe-ops` | 任何 Git 操作前 | 每次 Git 操作 |
| `session-closeout` | 每次 coding session 結束時 | 每個 session 一次 |
| `handoff-summary` | 切換工具、換人接手前 | 按需 |

---

## 跨工具遷移流程

從任何工具切換到另一個工具時：

```
當前工具（Claude Code / Codex / Cursor / opencode）
       │
       ▼
[session-closeout] ── 更新 STATUS.md + 產出 session-summary
       │
       ▼
[handoff-summary] ─── 產出 HANDOFF.md（含狀態、決策、下一步）
       │
       ▼
目標工具讀取 HANDOFF.md + STATUS.md + NEXT_ACTION.md
       │
       ▼
繼續工作
```

---

## 技能之間的依賴

- `spec-hardening` 依賴 `idea-to-spec` 的輸出（需要 spec.md 存在）
- `project-init` 建議在 spec.md 補強後執行（但非強制）
- `qa-verification` 需要功能描述（通常來自 spec.md）
- `github-safe-ops` 無前置依賴，可獨立呼叫
- `session-closeout` 需要使用者提供本次 session 摘要
