# maze-coder — 專案說明

> 建立日期：2026-05-20
> 最後更新：2026-11-17

---

## 一句話說明

maze-coder 是一組以 Markdown 寫成的 Agent Skills，直接安裝到 Claude Code、Codex、Cursor、Pi、opencode 原生的技能目錄，讓使用者在不同 coding agent 之間切換時仍能沿用同一套工作流程。

---

## 核心問題

使用者在多個 coding agent 工具之間切換時，常遇到：規格書不完整、session 結束後失去方向、Git 操作風險、前端 AI slop、QA 驗證不可追蹤。

---

## 技術棧

- **主要格式**：Markdown（`SKILL.md` + 按需資源）
- **腳本**：Bash（`install-skills.sh` 與兩支驗證腳本）
- **目標平台**：macOS、Linux、Windows（via Git Bash）

---

## Coding Agent 工具

- **主要工具**：Claude Code
- **支援**：Codex、Cursor、Pi、opencode（皆走原生 Agent Skills 探索，不做 per-host 內容轉換）

---

## 相關文件

- 規格書：`docs/spec.md`
- 下一步：`docs/NEXT_ACTION.md`
- 決策紀錄：`docs/adr/`（ADR）

---

## 重要限制

- 本專案不含任何可執行程式碼（`scripts/` 除外）
- 所有交付物以 `.md` 為主，`.sh` 為輔
- 「可攜式」定義：複製技能目錄到 host 原生的技能路徑即可使用，不需要安裝依賴
- Codex 不支援 `disable-model-invocation`，使用者觸發的技能在該 host 可能被模型自動選用
