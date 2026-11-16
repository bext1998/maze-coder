---
name: maze-design-review
description: 審查前端視覺、UX 與 AI slop，產出設計報告。當使用者要求 UI 設計審查、前端 QA 或視覺品質評估時使用。
disable-model-invocation: true
---

# design-review

## 目標

以視覺證據找出高影響設計問題並產出可執行建議。

## 前置條件

- 取得截圖、前端程式碼或設計描述之一；無視覺輸出時標記限制。
- 規格存在時用於核對功能目標。

## 執行流程

1. 依 `checklists/anti-ai-slop-checklist.md`、`frontend-ux-checklist.md`、`visual-quality-checklist.md` 審查；桌面 GUI 或存在正式設計系統時再讀 `checklists/desktop-design-system-checklist.md`。
2. 對 Anti-AI-Slop、UX、視覺品質各給 0–10 分；有正式系統時另評 Design System Conformance，附 render 證據、扣分原因與改善方式。桌面尺寸以 Brief 為準，不強制套用行動版尺寸。
3. 依影響排序問題，最多突出 2–3 個優先修正項。
4. 填寫 `templates/DESIGN_REVIEW.template.md`。

## 輸出契約

- 產出 `DESIGN_REVIEW.md`，包含評分、分級問題、證據與具體建議。

## 邊界

- 不修改程式碼、不決定風格、不評估後端或做完整 a11y／使用者研究。
