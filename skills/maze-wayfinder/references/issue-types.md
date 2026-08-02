# 問題類型（Issue Types）

每個從迷霧中畢業的問題，開成 issue 時必須標記類型：

| 類型 | 標籤 | 互動方式 | 說明 |
|---|---|---|---|
| **Grilling** | `wayfinder:grilling` | HITL（人機協作） | 預設類型。Agent 提問，使用者回答，逐步收斂。 |
| **Research** | `wayfinder:research` | AFK（Agent 獨立） | 需要查閱文件、API、技術文獻才能回答的問題。Agent 獨立調研後產出摘要。 |
| **Prototype** | `wayfinder:prototype` | HITL | 用粗糙的原型（草稿、stub、mockup）來提高討論解析度。 |
| **Task** | `wayfinder:task` | HITL 或 AFK | 必須先完成某件事才能做決策（例：註冊帳號、取得 API key）。 |

**HITL 規則：** 標記為 HITL 的 issue，agent 不得替使用者回答問題。Agent 問，人答。違反此規則等同技能失效。

## 地圖本體標籤

地圖本體 = 一個 GitHub Issue，標籤 `wayfinder:map`。每個待釐清問題 = 地圖 issue 下的子 issue，標籤為上表對應類型。

Local Markdown 載體：地圖本體是單一 `WAYFINDER_MAP.md` 檔案；每個待釐清問題是 `## Questions` 下的一個獨立 section（`### Q-ID`），固定含 Q-ID、type、status、blocked-by、question、answer 六個欄位，`type` 填入上表類型（不含 `wayfinder:` 前綴），不需要 GitHub labels 或 issues。

## Blocking／Frontier 判斷

使用 GitHub 原生的 blocking／dependency 表達前置關係（比照 `../../maze-spec-to-issues/references/issue-model.md` 的既有慣例：每個 issue 記錄阻塞與被阻塞關係，只有所有阻塞均解除的 issue 屬於可執行前線）。Frontier = open + unblocked + unassigned 的子 issues。

Local Markdown 載體：每個 Questions section 的 `blocked-by` 欄位填入阻塞此題的 Q-ID（逗號分隔多個，無阻塞留空），語義相同；Frontier（可執行前線）不是獨立區塊，是由 Questions sections 計算出的集合＝ `status` 為 `open` 且 `blocked-by` 內所有 Q-ID 皆已 `resolved` 的 section。

## 迷霧 vs 待釐清的判斷標準

能不能把問題精確地寫成一句話？可以 → 開 issue。不行 → 留在迷霧區（`Not Yet Specified`）。
