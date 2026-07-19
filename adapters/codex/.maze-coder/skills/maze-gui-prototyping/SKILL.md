---
name: maze-gui-prototyping
description: 執導 Electron、Tauri、Wails 等 WebView 桌面應用的可執行 GUI 原型。當使用者要求探索桌面介面方向、製作 HTML/CSS/SVG 原型或比較視窗 UI 方案時使用。
invocation: user
---

# gui-prototyping

## 目標

以可執行、可比較的低成本原型回答介面設計問題；人選方向，agent 以 render 與 QA 證據守住品質。

## 前置條件

- 取得設計問題、主要任務、必要狀態／互動與目標視窗尺寸；框架、設計系統與資料流先由 repo 查證。
- 執行前讀取 `references/prototype-workflow.md`；用 `templates/PROTOTYPE_BRIEF.template.md` 記錄契約。

## 執行流程

1. 既有 App 與頁面優先：保留目前資料取得、視窗限制與樣式系統，只替換待探索的呈現層。
2. 沒有合理宿主時，才建立無新依賴、單一命令可啟動的 HTML/CSS/SVG fallback。
3. 預設產生三個結構、資訊層級或主要操作不同的方向；只換顏色或文案不算不同方向。
4. 將寫入、原生 bridge 與外部副作用換成清楚標示的 stub，render 每個方向及 Brief 要求的狀態與尺寸。
5. 修正客觀阻擋問題後，由使用者選定方向；只對選定方向執行功能 QA 並記錄未驗證限制。

## 輸出契約

- 產出 `PROTOTYPE_BRIEF.md`、可重現的啟動命令、原型程式碼、各方向截圖、選擇結果與 QA 證據。
- 明確標示 throwaway 範圍；原型程式碼不得直接升格為 production 實作。

## 邊界

- 不實作真實後端、持久化或原生 bridge，不代替使用者決定審美，不因缺少設計系統而擴張成完整設計系統專案。
- 不把 build 通過當成視覺完成，也不保證原型具備 production 的錯誤處理、測試與相容性。
