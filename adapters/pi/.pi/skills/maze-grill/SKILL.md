---
name: maze-grill
description: 逐題壓力測試，不產生文件。
disable-model-invocation: true
---

# maze-grill

## 目標
取得可推進單輪目標的決策。
## 觸發
使用者呼叫 `maze-grill`。
## 必要輸入
待檢內容與本輪決策目標。
## 核心行為
載入 `../../maze-coder/internal-skills/maze-grilling/SKILL.md` 並遵守其契約。
## 確認點
取得必要決策。
## 輸出契約
進行中只輸出問題、推薦答案及理由；結束時摘要；不建立文件。
## 完成條件
共用技能判定可推進或已到上限並摘要。
## 邊界
不載入 domain modeling、不進入實作。
