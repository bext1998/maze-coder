# maze-coder — Cursor Adapter

## 說明

本目錄是 maze-coder 技能包的 Cursor 適配格式（`.cursor/rules/*.mdc`）。

將 `.cursor/` 目錄複製到你的專案根目錄，Cursor 將自動套用對應的技能規則。

## 使用方式

```bash
cp -r .cursor/ /your-project/
```

## Rule 檔案說明

| Rule 檔案 | 包含技能 |
|---|---|
| `maze-coder-core.mdc` | idea-to-spec、spec-hardening、project-init、session-closeout、repo-map、context-audit |
| `maze-coder-qa.mdc` | qa-verification、bug-reproduction |
| `maze-coder-git.mdc` | github-safe-ops |
| `maze-coder-design-review.mdc` | design-review、handoff-summary |

## 呼叫方式

在 Cursor 的 Composer 中直接描述需求，對應的 rule 會自動觸發：

```
幫我把這個想法轉成 spec  → maze-coder-core.mdc (idea-to-spec)
我要 push 到 main       → maze-coder-git.mdc (github-safe-ops)
幫我做前端 QA           → maze-coder-design-review.mdc (design-review)
```

## 注意事項

`.cursor/rules/` 下的 `.mdc` 檔案由 `sync-adapters.sh` 從 `skills/` 目錄同步產生，請勿直接編輯。
若需修改技能內容，請修改 `skills/*/SKILL.md` 後重新執行 `bash scripts/sync-adapters.sh`。
