# [專案名稱] — Coding Agent 指令

> 本文件供 Codex、opencode 等 coding agent 在每個 session 開始時閱讀。

---

## 專案概述

[專案名稱] 是 [一句話說明]。

技術棧：[語言] + [框架] + [資料存儲]

---

## 工作原則

1. 只實作任務要求的功能，不添加額外功能或重構
2. 優先編輯現有檔案，只在嚴格必要時建立新檔案
3. GitHub Issue／PR 與 Git 是工作狀態權威；只有明確 closeout 才重建 NEXT_ACTION.md
4. Git 操作前確認 pre-commit-checklist.md

---

## 下一步

閱讀 `NEXT_ACTION.md` 了解這個 session 的目標。

---

## 重要文件

| 文件 | 用途 |
|---|---|
| `spec.md` | 功能規格與驗收標準 |
| `NEXT_ACTION.md` | 下一步行動 |
| `DECISIONS.md` | 有效重大決策索引 |

---

## 禁止行為

- 不得 force push 到 main / master
- 不得在使用者未確認前 commit 或 push
- 不得修改 `spec.md` 的功能範圍（除非使用者明確要求）
