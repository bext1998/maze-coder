# maze-coder — 交接文件

> 建立日期：2026-05-20

---

## TL;DR

maze-coder 是一個可攜式 Harness Engineering 技能包，初始建置（Phase 1）已完成。所有 11 個技能、4 個 adapter、2 個腳本均已就緒，`validate-skillpack.sh` 通過（exit 0）。下一步是執行手動驗證測試（T-004 至 T-008）。

---

## 專案概述

- **專案名稱**：maze-coder
- **目標**：讓 coding agent 在多工具環境中保持一致的工作流程
- **技術棧**：Markdown + Bash（無其他依賴）
- **Repo**：`D:\AgentCoding\maze-coder`

---

## 當前狀態

**開發階段**：Phase 1 完成，進入手動驗證

**已完成**：
- 11 個技能 SKILL.md + 附屬文件（checklists / templates）
- 4 個 adapter（claude-code、codex、cursor、opencode）
- 2 個腳本（validate + sync），`validate` 已通過 T-001
- 根目錄 templates/（11 個使用者範本，由 sync 腳本產生）
- 完整的 docs/ 和 README.md

**進行中**：無

**已知問題**：無

---

## 下一步行動

1. 手動測試 T-004 到 T-009（見 `docs/NEXT_ACTION.md`）
2. 決定是否建立 git repo 並發布

---

## 重要技術決策

| 決策 | 原因 |
|---|---|
| sync-adapters.sh 冪等覆蓋 | 避免 adapter 殘留過期內容 |
| skills/\*/templates/ 是 source of truth | 避免兩處維護導致分歧 |
| Claude Code adapter 11 個技能 | OQ-1 確認原始 spec 遺漏 |
| validate 腳本驗證 5 個 section 標題 | OQ-3 確認，grep 驗證 |

---

## 重要文件位置

| 文件 | 路徑 |
|---|---|
| 規格書 | `docs/spec.md` |
| 決策紀錄 | `docs/DECISIONS.md` |
| 驗收標準 | `docs/spec.md` Section 11 |
| 測試計畫 | `docs/spec.md` Section 12 |
