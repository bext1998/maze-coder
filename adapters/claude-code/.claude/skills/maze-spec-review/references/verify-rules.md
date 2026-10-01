# 規格複審規則

- 報告綁定來源路徑與 revision；先讀既有 `SPEC_REVIEW.md`。revision 僅在來源已有 Git commit 時記錄 commit，不得為未提交規格產生 SHA-256。
- 只重查前次 Blocker、Major，保留原 `SR-xxx` ID，不新增 Minor、Suggestion 或無關範圍。
- 狀態只允許 `resolved`、`open`、`partial`、`unverifiable`。
- 來源規格、revision 或核心範圍大幅改變時停止 verify，要求重新完整審查；來源未提交且無法記錄 revision 時，複審視同來源變更，改走完整審查。
