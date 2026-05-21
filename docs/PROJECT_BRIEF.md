# maze-coder — 專案說明

> 建立日期：2026-05-20
> 最後更新：2026-05-20

---

## 一句話說明

maze-coder 是一套可攜式 Harness Engineering 技能包，讓使用者在 Claude Code、Codex、Cursor、opencode 之間切換時，仍能保持一致的工作流程。

---

## 核心問題

使用者在多個 coding agent 工具之間切換時，常遇到：規格書不完整、session 結束後失去方向、Git 操作風險、前端 AI slop、QA 驗證不可追蹤。

---

## 技術棧

- **主要格式**：Markdown（`.md`）
- **Adapter 格式**：SKILL.md（Claude Code）、AGENTS.md（Codex / opencode）、.mdc（Cursor）
- **腳本**：Bash（`#!/usr/bin/env bash`）
- **目標平台**：macOS、Linux、Windows（via Git Bash）

---

## Coding Agent 工具

- **主要工具**：Claude Code
- **支援目標**：Codex、Cursor、opencode

---

## 相關文件

- 規格書：`docs/spec.md`
- 當前狀態：`docs/STATUS.md`
- 下一步：`docs/NEXT_ACTION.md`
- 決策紀錄：`docs/DECISIONS.md`

---

## 重要限制

- 本專案不含任何可執行程式碼（scripts 除外）
- 所有交付物以 `.md` 為主，`.sh` 為輔
- 「可攜式」定義：複製整個目錄到任何機器，無需安裝任何依賴即可使用
