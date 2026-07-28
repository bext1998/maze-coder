---
name: maze-grill-with-docs
description: 逐題壓力測試並同步必要的專案術語與決策文件。
disable-model-invocation: true
---

# maze-grill-with-docs

## 目標
釐清設計分支並留下必要的領域背景。
## 觸發
使用者呼叫 `maze-grill-with-docs`。
## 必要輸入
待檢驗內容及現有專案文件位置。
## 核心行為
依序載入 `../maze-grilling/SKILL.md` 與 `../maze-domain-modeling/SKILL.md`；只同步本輪形成的實質內容。
## 確認點
逐題取得決策；覆寫既有文件或建立 ADR 前展示變更。
## 輸出契約
輸出當前問題與必要文件變更摘要。
## 完成條件
關鍵分支釐清，術語與符合門檻的決策已同步。
## 邊界
不為普通決策建立 ADR，不建立空文件。
