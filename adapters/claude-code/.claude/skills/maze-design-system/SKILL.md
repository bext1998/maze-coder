---
name: maze-design-system
description: 建立或演進前端設計語言、Design Tokens 與明確指定的元件範圍。當使用者要求建立設計系統、整理視覺語言、定義 tokens 或擴充既有元件規則時使用。
disable-model-invocation: true
---

# design-system

## 目標

以產品與現有介面證據建立或增量演進可重用的設計語言；由人決定風格，agent 負責一致、可實作與可驗證的契約。

## 前置條件

- 取得產品定位、主要使用者與目標平台；先從 repo 查找品牌資產、現有 UI、元件庫、tokens 與前端慣例。
- 執行前讀取 `references/design-system-workflow.md`；產出文件時使用 `templates/DESIGN_SYSTEM.template.md`。

## 執行流程

1. 盤點證據與 source of truth；既有系統只做必要的增量演進，不以新偏好全面替換。
2. 方向尚未確立時，render 最多三個實質不同的 style tiles；由使用者選定方向後才定義 Design Tokens。
3. 沿用專案 token 格式；全新 WebView 專案預設以 CSS custom properties 為 source of truth，只有消費端需要時才輸出 JSON。
4. 定義基礎值、語意角色及確有共用價值的元件 alias，並記錄狀態、使用規則與反例。
5. 只有使用者明確要求並指定元件範圍時才建構元件；沿用現有框架並 render 驗證必要狀態。

## 輸出契約

- 產出 `DESIGN_SYSTEM.md`、專案採用的 token source，以及實際 render 證據；列出已驗證、未驗證與既有系統遷移風險。
- 若建構元件，逐項記錄公開介面、狀態、鍵盤行為與驗證結果。

## 邊界

- 不代替使用者決定品牌或視覺方向；不自動建立完整元件庫、不引入新框架、不做品牌研究或全面 UI 重寫。
- 不把 provisional 值宣稱為正式設計系統，也不以文件完成取代實際 render。
