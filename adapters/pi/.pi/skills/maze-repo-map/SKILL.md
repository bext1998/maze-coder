---
name: maze-repo-map
description: 產生 repo 結構地圖與關鍵路徑說明。當使用者要求建立 repo map、進入陌生 repo 或協助 agent 理解專案時使用。
disable-model-invocation: true
---

# repo-map

## 目標

建立能快速定位入口、核心邏輯、設定、介面與測試的 `REPO_MAP.md`。

## 前置條件

- 必須能讀取目標 repo；超過 100 個目錄時先要求或推定合理範圍並標明。

## 執行流程

1. 掃描頂層與 2–3 層關鍵路徑，辨識入口、設定、文件、測試與主要模組。
2. 標記核心邏輯、介面定義、設定及測試位置，不展開生成物或依賴目錄。
3. 填寫 `templates/REPO_MAP.template.md`，附技術棧摘要與未知項目。

## 輸出契約

- 產出 `REPO_MAP.md`，包含精簡樹狀結構、關鍵檔案用途及技術棧。

## 邊界

- 不修改 repo、不評估品質、不推測業務流程、不產生 docstring 或完整依賴分析。
