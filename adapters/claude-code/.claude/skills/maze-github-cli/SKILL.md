---
name: maze-github-cli
description: 供其他技能組合使用的安全 GitHub CLI 操作契約；集中結構化輸出、預覽與授權邊界。
user-invocable: false
disable-model-invocation: true
---

# github-cli

## 目標

讓 GitHub 操作可驗證、非互動且不超出外層技能授權。

## 前置條件

- 用 `gh auth status` 確認 `gh` 可用且已登入，唯一確認 repository、remote、branch、資源與外層授權。
- 依 `references/command-contract.md` 與 `checklists/write-preview-checklist.md` 工作。

## 執行流程

1. 操作分級為 Read、Create／Update、Destructive；Read 可直接執行，優先使用 `--json`／`--jq`；Create／Update 先展示完整寫入預覽並取得明確確認。
2. Destructive 逐項確認；拒絕 `--admin`、force、強制合併與保護規則繞過。
3. 失敗後重新查詢遠端狀態，只重試未完成步驟，避免重複建立資源。

## 輸出契約

回報確認的目標、結構化結果、部分成功項目與未完成原因。

## 邊界

只接受外層技能明示的授權；不自行擴張權限、不提供隱性 prompt、不取代使用者確認。
