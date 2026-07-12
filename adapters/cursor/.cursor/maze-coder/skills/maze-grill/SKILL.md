---
name: maze-grill
description: 逐題壓力測試需求、規格、架構或計畫，不產生文件。
invocation: user
---

# maze-grill

## 目標
釐清所有會改變設計方向的分支。
## 觸發
使用者呼叫 `maze-grill`。
## 必要輸入
待檢驗的需求、規格、架構或計畫。
## 核心行為
載入 `../maze-grilling/SKILL.md` 並遵守其契約。
## 確認點
由共用技能逐題取得產品或取捨決策。
## 輸出契約
只輸出當前問題、推薦答案及理由；不建立文件。
## 完成條件
共用技能判定關鍵分支已釐清。
## 邊界
不載入 domain modeling、不進入實作。
