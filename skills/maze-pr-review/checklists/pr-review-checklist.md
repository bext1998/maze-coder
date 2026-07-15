# PR Review 清單

## 證據

- PR title／body、base／head、changed files、完整 diff、checks、review threads／comments。
- 關聯 Issue／規格、相關實作、型別、資料流、測試與 UI render／截圖（若適用）。
- 缺少 PR metadata、checks 或 comments 時列為限制，不假設通過。

## Findings

- 只回報可定位、可重現且值得修改的問題；純主觀風格偏好不是 finding。
- 等級：Blocker、Major、Minor、Nit；每項含檔案／行數（可取得時）、觸發條件、證據、影響與修正方向。
- 結論：Blocker／Major→`Request changes`；只有 Minor／Nit→`Comment`；完整證據且無 finding→`Approve`；證據不足或降級→`Insufficient evidence`。

## 覆蓋與邊界

- 列出已審查且未發現問題的區域、測試缺口、限制與建議合併條件。
- 不寫入 GitHub，不將 working-tree review 冒充 PR review。
