---
name: maze-project-init
description: 初始化專案的指揮文件與 GitHub 工作流設定。當使用者要求建立專案文件或設定 coding agent 指令時使用。
invocation: user
---

# project-init

## 目標

依模板建立 `MAZE_PROJECT.md`、`PROJECT_BRIEF.md`、`STATUS.md`、`NEXT_ACTION.md`、`DECISIONS.md` 與目標工具指令。

## 前置條件

- 必須取得專案名稱、目標目錄、至少一個工具、技術棧及規格實際路徑；不得用預設名稱或猜測 `spec.md`。
- 缺少三項以上資訊時一次列出所有缺漏，不逐項詢問。
- 先掃描目標文件；已存在時逐一提供跳過、覆蓋或查看後決定，不得靜默處理。
- 現有 `MAZE_PROJECT.md` 記錄不同 spec 路徑時停止，取得確認後才更新；全部跳過時回報未修改並結束。

## 執行流程

1. 記錄專案摘要、技術棧、文件實際路徑與目標工具。
2. 詢問是否使用 GitHub Issues、Repository URL、spec-to-issues、標籤慣例、預設 Assignee 策略及是否允許新增標籤。
3. 依 `templates/` 建立定位錨點與專案文件；不得把 token、密碼或憑證寫入設定。
4. 列出建立、覆蓋、跳過與未建立的文件。

## 輸出契約

- 文件位於使用者指定的專案根目錄，內容符合對應模板。
- `MAZE_PROJECT.md` 必須記錄專案、工具、規格與關鍵文件實際路徑及 GitHub 設定。
- 至少產出 MAZE_PROJECT、Project Brief、Status 與 Next Action；既有文件依使用者選擇保留。

## 邊界

- 不初始化 Git、不撰寫程式碼、不修改規格內容、不替使用者選擇技術棧、自動建立 GitHub 資源或把技術決策寫入 MAZE_PROJECT。
