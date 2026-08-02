---
name: maze-wayfinder
description: 使用者連自己想要什麼都不確定時，透過結構化提問撥開迷霧，產出決策地圖。觸發：「我不知道要做什麼」「有個模糊的想法」「幫我想清楚」「先聊聊看」「開一張地圖」，或反覆改需求方向顯示缺乏確信。已知道要做什麼只需整理成規格時改用 maze-idea-to-spec。
invocation: both
---

# maze-wayfinder

## 目標
幫「不知道自己要什麼」的使用者透過結構化探索找到方向，產出決策地圖而非規格書。
## 前置條件
連核心問題都無法明確陳述；能陳述只是要整理時改用 `maze-idea-to-spec`，不建圖。選定載體：GitHub Issues（預設）或 `templates/WAYFINDER_MAP.template.md`。
## 核心行為
Mode 1 建圖（新想法，一個 session 只做這件事，不解決 issue）／Mode 2 推進（既有地圖，每次只解決一個 issue），完整流程、委派規則與 HITL 邊界見 `references/execution-flow.md`。issue 類型與標籤見 `references/issue-types.md`。每個 Mode 結束前過 `checklists/wayfinder-checklist.md` 自查。完成：Frontier 清空且無殘留迷霧、使用者宣告已想清楚，或剩餘問題已確認不影響 Destination（可提前收斂）；列 Decisions 全覽，建議下一步但不替使用者決定。
## 輸出契約
建圖回報地圖位置、Destination、Frontier 清單，不得同 session 解決 issue；推進回報解決的 issue 與地圖更新。一次只問一個問題，可合理假設的標注 `[假設]` 不問。
## 邊界
不寫規格書、不實作、不寫程式碼、不產 PR、不替使用者決策；不在建圖 session 解決 issue；已畢業迷霧不退回，已關閉 issue 不重開。GitHub Issues 操作委派 `maze-github-cli`。
