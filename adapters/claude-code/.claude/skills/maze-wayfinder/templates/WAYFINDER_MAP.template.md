# Wayfinder Map: [地圖名稱]

<!-- Local Markdown 載體：每次寫入前，重新計算此檔目前內容的 hash，與 session 開始載入時記錄的 hash 比對；不一致代表檔案在外部被修改過，需警告使用者並暫停，不得覆寫。 -->

## Destination

[這次探路要抵達的終點——搞清楚什麼？一到兩句話。每次 session 開始前先讀這段定位方向。]

## Notes

[領域背景、每次 session 應參考的技能、這次探路的特殊偏好]

## Questions

<!-- 待釐清問題：每題一個獨立 section（### Q-ID），固定含 Q-ID、type、status、blocked-by、question、answer 六個欄位。
Mode 1 建圖時新增 section；Mode 2 推進時每個 session 只更新一個 section 的 status／answer。
type 必為 grilling｜research｜prototype｜task；status 必為 open｜resolved｜out-of-scope；
blocked-by 填阻塞此題的 Q-ID（逗號分隔多個），無阻塞留空。
Frontier（可執行前線）不是獨立區塊，是由這些 sections 計算出的集合＝ status 為 open 且 blocked-by 內所有 Q-ID 皆已 resolved 的 section。 -->

### Q1

- type: grilling
- status: open
- blocked-by:
- question: [問題內容]
- answer:

## Decisions

<!-- 索引——每個已解決的問題一行：摘要 + 連結，不重複展開。Local Markdown 載體：連結指向本檔對應的 Questions section（如 `#q1`）。 -->

- [已解決的問題標題](link) — 一句話摘要答案

## Not Yet Specified

<!-- 迷霧區：看得到輪廓但還無法精確提問的區域。隨著 frontier 推進，會逐漸畢業成正式 issue -->

## Out of Scope

<!-- 明確排除的方向：不是迷霧，而是有意識地決定「這次不管」 -->
