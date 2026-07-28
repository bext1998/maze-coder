---
name: maze-github-safe-ops
description: 提供安全的 Git／GitHub 操作檢查與 Issue 關聯規則。當使用者要 commit、push、merge、rebase 或建立 PR 時使用。
---

# github-safe-ops

## 目標

在不遺失資料、洩漏敏感資訊或錯誤關閉 Issue 的前提下指引 Git／GitHub 操作。

## 前置條件

- 取得操作意圖、branch、remote 與對應 Issue；無法判斷 Issue 時先詢問。
- 依需要讀取 `checklists/` 的 commit、push 或 conflict 清單。

## 執行流程

1. 檢查 status、staged diff、目標 branch、敏感檔案與未同步變更。
2. Commit message 依專案慣例引用 Issue；建立 PR 前確認 Issue、QA 與適用的 CI。
3. 完整完成使用 `Closes #N`；部分完成只用 `Related to #N`。多 Issue 必須逐一確認，多 PR 只讓最後一個完整 PR 關閉 Issue。
4. GitHub 遠端寫入只在使用者明確請求、完整預覽與確認後，委派 internal `maze-github-cli`；本技能不自行發起寫入。
5. 合併後確認 Issue 已關閉且 AC、QA、CI、文件均完成；否則回報 `merged-awaiting-close`。
6. Rebase、reset hard 或 force push 必須先確認；Force push 到 main / master 可能覆蓋其他人的工作，應停止並改用 `git revert` 等替代方案。

## 輸出契約

- 提供風險、前置檢查、可執行步驟及 PR 關聯文字；禁止情境只提供警告與替代方案。

## 邊界

- 不自行執行 Git、建立 commit／PR、合併、批准 review，亦不提供 force push 到 main／master 的指令。
