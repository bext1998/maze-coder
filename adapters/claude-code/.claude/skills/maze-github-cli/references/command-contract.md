# GitHub CLI 命令契約

## 前置檢查

- 使用 `gh auth status` 確認登入，再用 `gh repo view --json nameWithOwner,defaultBranchRef` 確認 repo。
- 用 `git remote -v`、目前 branch 與資源 URL／number 交叉確認目標；不以資料夾名稱猜測。

## 操作分級

- Read：可直接執行，使用 `--json`／`--jq`，不可解析表格輸出。
- Create／Update：先列出 repository、resource、欄位、預期效果與命令，再取得明確確認，只執行一次。
- Destructive：關閉、merge、刪除、`--admin` 或繞過 protection 一律逐項確認；契約禁止時拒絕。

## 失敗處理

重新查詢資源狀態與遠端 ref；只重試未完成步驟，不因輸出不明重複建立資源。
