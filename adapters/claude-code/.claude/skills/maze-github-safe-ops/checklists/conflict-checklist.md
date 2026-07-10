# Merge Conflict 處理清單

遇到 merge conflict 時，依序執行以下步驟：

## 評估階段

- [ ] `git status` — 確認哪些檔案有 conflict
- [ ] 閱讀每個 conflict 區塊（`<<<<<<<`、`=======`、`>>>>>>>`）
- [ ] 理解兩邊變更的意圖，再決定如何合併

## 解決階段

- [ ] 每個 conflict 都手動解決（不要隨意選「接受全部」）
- [ ] 確認解決後的程式碼邏輯正確
- [ ] 移除 conflict 標記（`<<<<<<<`、`=======`、`>>>>>>>`）
- [ ] 若不確定哪邊正確，詢問原作者或查閱 git log

## 驗證階段

- [ ] `git diff` — 確認解決後的變更正確
- [ ] 執行測試確認功能正常
- [ ] `git add` 解決後的檔案
- [ ] `git commit` 完成 merge（使用預設的 merge commit message）

## 禁止行為

- 不得用 `git checkout --ours` 或 `--theirs` 直接丟棄對方所有變更，除非你確定不需要對方的修改
- 不得在未測試的情況下 push 解決後的 conflict
