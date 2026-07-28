---
name: maze-domain-modeling
description: Grill with docs 共用的術語、Context 與重大決策同步邏輯。
disable-model-invocation: true
---

# maze-domain-modeling

## 目標
讓未來讀者理解本輪形成的領域語言與重大決策。
## 觸發
只由 `maze-grill-with-docs` 載入。
## 必要輸入
已確認決策、既有 Context／Glossary／Decision／ADR 慣例。
## 核心行為
優先更新既有文件；只有使用者明確要求文件同步且出現實質內容才建立或更新。普通、易逆轉選擇與實作經過不得進入決策索引；重大決策以一行摘要、狀態與唯一 ADR／Issue／PR 連結索引。ADR 必須同時滿足難以逆轉、缺背景將無法理解、存在有意義替代方案與取捨。
## 確認點
新增文件或改變既有決策語意前展示差異。
## 輸出契約
列出更新的術語、Context、Decision 或 ADR 及其證據。
## 完成條件
必要背景可由專案文件重建，且無空白文件。
## 邊界
不為普通、易逆轉或無替代方案的決策建立 ADR。
