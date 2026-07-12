# 相容入口：自適應工作模型

> Canonical 規則位於 `workflow-model.md`。以下只保留技能關聯與 GitHub 狀態語意，不代表強制階段。

## 可組合能力

```text
idea-to-spec／spec-hardening／grill
spec-to-issues／risk-driven-tdd／qa-verification
github-safe-ops／session-closeout／handoff-summary
```

## 按需技能

- `repo-map`：進入陌生 repo 或結構重大變更後。
- `context-audit`：agent 理解疑似與文件／repo 不一致時。
- `bug-reproduction`：Bug 需要最小重現與可交付紀錄時。
- `design-review`：前端視覺與 UX 需要證據式審查時。
- `handoff-summary`：closeout 後需要跨工具或跨人員交接時。

## Issue 與 PR 狀態

- `spec-to-issues` 建立穩定 task-id 與規格來源；重跑時先同步，不建立副本。
- 開發前選定 Issue；Commit／PR 引用該 Issue。
- 部分 PR 使用 `Related to`；只有完成全部 AC 的最後 PR 使用 `Closes`。
- PR 合併不等於完成；closeout 必須再核對 QA、CI、文件、Issue checklist 與關閉狀態。

## 交接組合

```text
session-closeout → 同步 GitHub 與專案文件 → handoff-summary → HANDOFF.md
```

`session-closeout` 不建立 Session 報告；只有明確交接需求才建立 `HANDOFF.md`。
