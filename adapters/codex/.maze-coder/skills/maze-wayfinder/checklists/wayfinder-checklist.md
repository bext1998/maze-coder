# Wayfinder 品質檢查清單

## 建圖完成時自查

- [ ] Destination 是一到兩句話，具體且可判斷是否抵達
- [ ] 至少有 2 個 Frontier 問題（GitHub 載體：sub-issue；Local Markdown 載體：Questions section）（否則不需要建圖）
- [ ] `Not Yet Specified` 的內容確實無法精確描述為問題
- [ ] 每個問題都有正確的類型標記（GitHub 載體：`wayfinder:<type>` 標籤；Local Markdown 載體：Questions section 的 `type` 欄位）
- [ ] 問題之間的阻塞關係已正確設定（GitHub 載體：native blocking；Local Markdown 載體：Questions section 的 `blocked-by` 欄位）

## 每次推進完成時自查

- [ ] 被解決的問題已標記為已關閉並記錄答案（GitHub 載體：關閉 issue；Local Markdown 載體：該 Questions section 的 `status` 改為 `resolved` 或 `out-of-scope`，並填入 `answer` 欄位）
- [ ] `Decisions` 區塊已更新
- [ ] 檢查過是否有迷霧可以畢業
- [ ] 檢查過是否有問題因此變得不相關
- [ ] 每個 session 只解決了一個問題（GitHub 載體：一個 sub-issue；Local Markdown 載體：一個 Questions section）
- [ ]（Local Markdown 載體）寫入前已比對 hash 確認檔案未被外部修改；如有落差已停止並警告使用者，未覆寫
