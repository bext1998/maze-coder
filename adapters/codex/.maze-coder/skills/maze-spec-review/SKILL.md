---
name: maze-spec-review
description: 在實作前或需要複審時，對規格做唯讀、證據導向的結構化審查。
invocation: user
---

# spec-review

## 目標

找出規格的缺漏、矛盾、邊界、可實作性與驗收風險，保留需求決策權。

## 前置條件

- 由 `MAZE_PROJECT.md` 取得規格路徑；未記錄時要求使用者指定。
- 讀完整規格，再查閱需求涉及的實作、測試、文件與設計證據；缺證據標示 `unverified`。
- 依 `checklists/spec-review-checklist.md`、`references/verify-rules.md` 與 `templates/SPEC_REVIEW.template.md` 工作。

## 執行流程

1. 完整模式檢查六面向，使用不隨排序改變的 `SR-xxx` finding ID、Blocker／Major／Minor／Suggestion 四級嚴重度與結論映射。
2. 產出 `SPEC_REVIEW.md`，記錄證據、未決策事項、驗收建議、修訂順序與限制。
3. `--verify`／「複審」只重查既有 Blocker／Major，保留 ID；來源 revision 或核心範圍大幅變更時停止。

## 輸出契約

報告必須區分事實、推論與未驗證限制，並列出 finding 數量、狀態與來源識別。

## 邊界

唯讀；不修改原規格、不替使用者決定產品方向、不開始實作、不寫入 GitHub。
