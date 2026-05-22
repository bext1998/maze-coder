# DESIGN_REVIEW.md

**目標：** `assets/maze-coder-logo.svg`  
**審查日期：** 2026-05-22  
**審查者：** maze-design-review skill (Claude Code)

---

## 評分總覽

| 維度 | 審查前 | 審查後 |
|------|--------|--------|
| Anti-AI-Slop | 6/10 | 8/10 |
| UX（互動 / 狀態還原） | 5/10 | 9/10 |
| 視覺品質（間距 / 密度 / 識別度） | 6/10 | 9/10 |

---

## 問題清單與修正記錄

### [高] Logo 設計不直觀 — 已修正

**問題：** MD 文件＋打勾圖示無法傳達 coding agent 工具定位；checkBlink 動畫語義模糊。  
**修正：** 以終端機 `>_` 提示符（深色背景 + 青綠色文字）取代。移除 `.doc`、`.doc-fold`、`.doc-line`、`.doc-mark`、`.check`、`@keyframes checkBlink`。

---

### [高] 神秘圓形圖案 — 已修正

**問題：** `translate(812 38)` 群組的 `r=54` 圓形（"11 maze-* skills" 計數徽章）圓心在 (867, 93)，與四個 adapter 矩形（x=790–908）重疊，形成視覺干擾。  
**修正：** 移除整個計數圓圈群組及 `.count`、`.count-label`、`.panel` CSS。

---

### [高] Dark mode adapter 動畫無法還原 — 已修正

**問題：** `@keyframes adapterGlow` 在 0%/30%/100% 強制 `fill: #ffffff`，覆蓋 dark mode `fill: #172033`。adapter 在 dark mode 下永遠白底，淺色文字（`#e5e7eb`）對比度不足，且動畫結束後不還原。  
**修正：** keyframes 改為 stroke-only 動畫，fill 完全由 class + dark mode media query 控制。

```css
/* 修正後 */
@keyframes adapterGlow {
  0%, 30%, 100% { stroke: #64748b; stroke-width: 2; }
  12% { stroke: #0891b2; stroke-width: 3; }
}
```

---

### [中] 標題與迷宮間距過擠 — 已修正

**問題：** tagline y=101，最近 maze node y=121，間距僅 20px，畫面壓迫感強。  
**修正：** SVG viewBox 高度 260→300，frame height 244→284，所有迷宮元素 y 座標整體下移 40px。現在 tagline 到最近節點間距為 60px。

---

### [低] node-label 小字視覺雜訊 — 已移除

**問題：** 11 個 9px 技能名稱標籤（idea, harden, init…）在 720px 寬度下難以辨識，且與 tagline 語義重複。  
**修正：** 移除全部 `<text class="node-label">` 元素及 `.node-label` CSS。

---

## 驗證結果

- Light mode：`>_` 終端機圖示（深底青字）清晰顯示，右上角無圓形殘影
- Dark mode：adapter 矩形保持深色背景，白色文字正常顯示，動畫結束後正確還原
- 標題文字（y=101）與迷宮最近節點（y=161）間距 60px，視覺呼吸感充足
- 迷宮節點無文字標籤，路徑動畫流暢
