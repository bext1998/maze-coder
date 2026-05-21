---
name: maze-project-init
description: |
  初始化專案的指揮文件集（PROJECT_BRIEF、STATUS、NEXT_ACTION、DECISIONS、AGENTS）。
  當使用者說「幫我建立專案文件」、「初始化這個專案」、「設定 coding agent 指令」時觸發。
---

# project-init：專案初始化

## 技能目標

新專案開始時，缺少清晰的文件讓 coding agent 容易失去方向。本技能產出一套完整的專案指揮文件，讓 agent 在每個 session 開始前都能快速定位當前狀態和下一步。

## 前置條件（Preconditions）

- **必須**提供專案名稱 — 缺少時停止並詢問，不得使用「untitled」或自行命名
- **必須**說明至少一個目標工具（Claude Code / Codex / Cursor / opencode）
- 建議先完成 `spec.md`，但非強制

## 執行流程

### Phase 0：確認輸入

確認：
- 專案名稱（確切名稱，非描述）
- 目標工具（可多選）
- 技術棧（語言、框架）
- 是否已有 `spec.md`

### Phase 1：產出 PROJECT_BRIEF.md

填寫：
- 專案名稱與一句話說明
- 核心問題
- 目標技術棧
- 連結到 `spec.md`（若已存在）

### Phase 2：產出 STATUS.md

初始狀態：
- 當前階段：初始化
- 完成的事項：（空）
- 待完成事項：開始第一個 coding session

### Phase 3：產出 NEXT_ACTION.md

初始下一步：
- 閱讀 `spec.md`（若存在）
- 建立 repo 結構
- 設定開發環境

### Phase 4：產出 DECISIONS.md

初始決策紀錄：
- 選擇使用的工具與原因
- 技術棧決策

### Phase 5：產出 AGENTS.md（依目標工具）

依使用者指定的工具，填寫對應的 AGENTS.md 模板，包含：
- 專案說明
- 技術棧摘要
- 工作流指引
- 檢查清單引用

## 輸出（Output Contract）

- **位置**：使用者指定的專案目錄根目錄
- **格式**：符合各 `*.template.md` 結構的 Markdown 文件集
- **完整性**：至少產出 PROJECT_BRIEF.md、STATUS.md、NEXT_ACTION.md 三份文件

## 技能邊界（本技能不做的事）

- 不建立 git repo 或初始化版本控制
- 不撰寫程式碼或設定開發環境
- 不修改 `spec.md`（那是 `idea-to-spec` 和 `spec-hardening` 的工作）
- 不決定技術棧（只記錄使用者的決策）
- 不評估技術選擇的優劣
