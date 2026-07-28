# Pre-push 檢查清單

在執行 `git push` 前，確認以下項目：

## 分支確認

- [ ] `git branch` — 確認目前在正確的分支
- [ ] 不是直接 push 到 `main` / `master`（應透過 PR）
- [ ] 分支名稱清楚描述功能（`feature/xxx` 或 `fix/xxx`）
- [ ] 若此變更會與其他進行中分支平行修改重疊檔案，先用 git worktree add 建立獨立工作區，避免共用 working tree 互相覆蓋

## 本地狀態確認

- [ ] `git log --oneline -5` — 確認 commit 歷史正確
- [ ] 沒有 WIP（work in progress）的 commit 混入
- [ ] `git pull --rebase origin main` — 確認已同步最新遠端狀態
- [ ] 若有 conflict，已解決所有 conflict

## CI / 測試確認

- [ ] 本地測試通過
- [ ] Lint 無錯誤
- [ ] Build 無錯誤（若適用）

## 禁止行為

- 不得使用 `--force` / `-f` push 到 `main` / `master`
- 不得 push 包含敏感資料的 commit（需先用 `git rebase -i` 清理）

## 通過條件

全部打勾後才執行 `git push`。
