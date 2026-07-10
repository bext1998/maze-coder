# Pre-commit 檢查清單

在執行 `git commit` 前，確認以下項目：

## 內容確認

- [ ] `git status` — 確認已暫存的檔案清單正確
- [ ] `git diff --staged` — 閱讀所有變更內容
- [ ] 沒有遺忘暫存的相關檔案
- [ ] 沒有多餘的 debug 輸出（console.log、print 等）
- [ ] 沒有暫時性的 TODO/FIXME 應在此次 commit 解決

## 安全確認

- [ ] 沒有 `.env` 檔案或 API key 被暫存
- [ ] 沒有密碼或 token 被暫存
- [ ] 沒有個人資料（email、電話等）被意外暫存

## Commit Message

- [ ] 以動詞開頭（add / fix / update / remove / refactor）
- [ ] 說明「做了什麼」而非「修改了哪個檔案」
- [ ] 長度適中（50 字以內的標題）
- [ ] 若有相關 issue，附上編號

## 通過條件

全部打勾後才執行 `git commit`。
