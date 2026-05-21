---
name: maze-github-safe-ops
description: |
  提供安全的 Git / GitHub 操作步驟與檢查清單，防止高風險操作導致的資料損失。
  當使用者要執行任何 Git 操作（commit、push、merge、rebase 等）時觸發。
---

# github-safe-ops：Git 安全操作

## 技能目標

不謹慎的 Git 操作容易造成無法恢復的資料損失。本技能為每個 Git 操作提供安全步驟和對應的確認清單，並對高風險操作發出明確警告。

## 前置條件（Preconditions）

- 使用者必須說明 Git 操作意圖（commit / push / merge / rebase / 其他）
- 本技能不需要讀取任何輸入文件，但需要知道操作目標（哪個分支 / 哪個 remote）

## 執行流程

### Phase 0：識別操作類型與風險等級

| 操作 | 風險等級 |
|---|---|
| `git add` / `git commit` | 低 |
| `git push`（非 force）| 中 |
| `git merge`（非 main）| 中 |
| `git rebase` | 高 |
| `git push --force` / `git push -f` | **極高** |
| `git reset --hard` | 高 |
| `git push --force` 到 `main` / `master` | **禁止** |

### Phase 1：高風險操作警告

若使用者要求 **force push 到 main / master**：
- 立即停止
- 輸出警告：「⚠️ Force push 到 main / master 可能覆蓋其他人的工作，並使已發布的 commit 歷史不一致。此操作不建議執行。」
- 不提供 `git push --force` 指令
- 提供替代方案說明（如：用 `git revert` 撤銷、與團隊溝通後使用 Protected Branch 例外流程）

### Phase 2：標準操作流程

#### Commit 前

1. 執行 `git status` 確認已暫存的檔案
2. 執行 `git diff --staged` 確認變更內容
3. 確認不包含敏感檔案（`.env`、API key 等）
4. 確認 commit message 清楚描述變更

#### Push 前

1. 執行 `git pull --rebase` 同步遠端最新狀態
2. 確認本地 commit 歷史正確
3. 確認目標分支正確（非直接 push 到 main）

#### Merge / Rebase

1. 確認在正確的分支上執行
2. 確認有備份（stash 或 branch）
3. Rebase 前確認是否有共享的 commit（若有，改用 merge）

### Phase 3：提供對應的指令與檢查清單

依操作類型，引導使用者閱讀對應的 checklist：
- Commit 前：`pre-commit-checklist.md`
- Push 前：`pre-push-checklist.md`
- Merge conflict：`conflict-checklist.md`

## 輸出（Output Contract）

- **格式**：步驟說明 + 對應的 git 指令（高風險操作除外）
- **高風險操作**：輸出警告文字 + 替代方案，不輸出危險指令

## 技能邊界（本技能不做的事）

- 不直接執行任何 git 指令
- 不在使用者未確認前建立 commit
- 不提供 `git push --force` 到保護分支的指令
- 不評估程式碼品質（那是 `qa-verification` 的工作）
- 不建立 Pull Request（引導使用者自行操作）
