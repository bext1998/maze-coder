---
name: maze-project-init
description: 初始化專案的指揮文件與 GitHub 工作流設定。當使用者要求建立專案文件或設定 coding agent 指令時使用。
---

# project-init

## 目標

依模板建立 `MAZE_PROJECT.md`、`PROJECT_BRIEF.md`、`STATUS.md`、`NEXT_ACTION.md`、`DECISIONS.md` 與目標工具指令。

## 前置條件

- 取得專案名稱、目標目錄、至少一個工具、技術棧及規格實際路徑。
- 先掃描目標文件；已存在時逐一提供跳過、覆蓋或查看後決定，不得靜默處理。

## 執行流程

1. 記錄專案摘要、技術棧、文件路徑與工具。
2. 詢問是否使用 GitHub Issues、Repository URL、spec-to-issues、標籤慣例、預設 Assignee 策略及是否允許新增標籤。
3. 依 `templates/` 建立文件；不得把 token、密碼或憑證寫入設定。
4. 列出建立、覆蓋、跳過與未建立的文件。

## 輸出契約

- 文件位於使用者指定的專案根目錄，內容符合對應模板。
- `MAZE_PROJECT.md` 必須記錄規格實際路徑與 GitHub 設定；至少同時產出 Project Brief、Status、Next Action。

## 邊界

- 不初始化 Git、不撰寫程式碼、不修改規格內容、不替使用者選擇技術棧或自動建立 GitHub 資源。
