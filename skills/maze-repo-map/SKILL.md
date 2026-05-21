---
name: maze-repo-map
description: |
  產生 repo 的結構地圖文件（REPO_MAP.md），幫助 agent 快速理解專案佈局。
  當使用者說「幫我建立 repo map」、「讓 agent 了解這個專案」、「進入新 repo」時觸發。
---

# repo-map：Repo 結構地圖

## 技能目標

進入陌生 repo 或長期未工作後，coding agent 需要時間重建對專案結構的理解。本技能產出一份結構地圖，讓 agent 在下一個 session 開始時快速定位關鍵檔案。

## 前置條件（Preconditions）

- 需要能讀取目標 repo 的目錄結構
- 若 repo 太大（超過 100 個目錄），先聚焦在使用者指定的範圍

## 執行流程

### Phase 1：掃描目錄結構

列出 repo 的頂層目錄和關鍵檔案，識別：
- 進入點（`main.py`、`index.ts`、`app.js` 等）
- 設定檔（`.env.example`、`package.json`、`pyproject.toml` 等）
- 文件目錄
- 測試目錄

### Phase 2：識別關鍵路徑

標注以下類型的檔案：
- **核心邏輯**：主要業務邏輯所在
- **介面定義**：API 端點、型別定義
- **設定**：環境設定、部署設定
- **測試**：測試檔案位置

### Phase 3：產出 REPO_MAP.md

填寫 `REPO_MAP.template.md`，包含：
- 樹狀目錄結構（2-3 層深）
- 關鍵檔案說明
- 技術棧摘要

## 輸出（Output Contract）

- **位置**：`REPO_MAP.md`（使用者指定目錄）
- **格式**：符合 `REPO_MAP.template.md` 的 Markdown 文件
- **更新**：每次 repo 結構有重大變更後需重新產出

## 技能邊界（本技能不做的事）

- 不分析程式碼邏輯或業務流程
- 不評估程式碼品質
- 不產出程式碼文件（docstring 等）
- 不做依賴分析（只記錄目錄結構）
- 不修改任何 repo 內的檔案
