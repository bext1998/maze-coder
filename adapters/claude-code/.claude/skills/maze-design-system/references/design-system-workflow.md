# Design System Workflow

## Evidence first

先查找現有 CSS variables、theme 設定、元件 variants、圖示、字型、品牌資產、畫面截圖與設計文件。將每項規則標為 existing、proposed 或 unresolved；未查證內容不得包裝成既有慣例。

## Direction gate

產品已有明確方向時直接沿用。方向不明時，以同一組代表內容製作最多三個 style tiles；差異至少涵蓋字型層級、色彩角色、形狀、密度或動態中的兩項。先 render，再由使用者選定；agent 只排除對比不足、狀態不可辨等客觀缺陷。

## Token model

- 基礎值：palette、font family／size、space、radius、shadow、duration。
- 語意角色：surface、text、border、accent、success、warning、danger、focus 等用途。
- 元件 alias：只有多個元件或狀態會共同依賴、且需獨立演進時才新增。

元件不得直接散落任意色碼或尺寸。既有專案維持現行命名與輸出格式；全新 WebView 專案以 `:root` CSS custom properties 起步。需要 dark theme 或多品牌時才增加對應 token set，不預留未要求的 theme。

## Component opt-in

先列出使用者指定的元件與必要狀態，再建構最小集合。元件使用目前框架、樣式方案與測試慣例；公開 props／events 應表達用途，不暴露底層 token 名稱。驗證適用的 default、hover、focus-visible、disabled、loading、empty、error、鍵盤與縮放狀態。

## Handoff

`DESIGN_SYSTEM.md` 記錄設計理由與使用規則；token source 保存可執行值；render 證據證明規則可用。三者互相連結，但不要在文件複製完整 token 表。GUI 原型可在後續獨立 session 消費這些產物。
