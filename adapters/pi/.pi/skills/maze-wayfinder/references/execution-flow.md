# 執行流程細節

## Mode 1：建圖（Chart the Map）

使用者帶著模糊想法進來時觸發。

**Step 1 — 定位目的地**

委派 `maze-grill` 對使用者進行一輪 grilling，目標是把「我有個想法」收斂成一句明確的 Destination。

提問策略（依序嘗試，不必全問）：
- 「如果這件事做完了，你的生活／工作會有什麼具體改變？」
- 「你能描述一個你會用到它的具體場景嗎？」
- 「你現在是怎麼處理這件事的？哪裡讓你不滿意？」
- 「如果只能做一件事，你最想解決的是什麼？」
- 「有沒有你看過的現有工具或產品，跟你想像的方向類似？」

**提前終止條件：** 如果這輪 grilling 發現使用者的需求足夠清晰，不需要建圖，立即告知：「這個方向已經夠清楚了，不需要開地圖。要直接跑 `maze-idea-to-spec` 嗎？」

**Step 2 — 廣度掃描**

再委派 `maze-grill` 進行一輪 grilling，這次目標是**廣度優先**——橫向展開所有可能涉及的面向，而不是深入任何一個。目的是勾勒出迷霧的輪廓：哪些區域已知、哪些模糊、哪些完全未知。

**Step 3 — 建立地圖**

根據 Step 1-2 的對話內容：
1. 撰寫 Destination（一到兩句話）
2. 撰寫 Notes（領域背景、偏好）
3. 把能精確描述的問題開成 issues（Frontier），依 `issue-types.md` 標記類型（GitHub 載體：開 sub-issue 並設定 `wayfinder:<type>` 標籤；Local Markdown 載體：在 `## Questions` 下新增一個 `### Q-ID` section，填入 type、`status: open`、blocked-by、question）
4. 把無法精確描述的方向寫入 `Not Yet Specified`（Fog）
5. 如有明確排除的方向，寫入 `Out of Scope`

**Step 4 — 停止**

建圖是一個 session 的工作。建完地圖後**不要**開始解決 issues。回報前先過 `../checklists/wayfinder-checklist.md` 的「建圖完成時自查」。告知使用者地圖已建好，並說明 Frontier 上有哪些問題可以開始處理。

## Mode 2：推進地圖（Work Through the Map）

使用者帶著已存在的地圖回來時觸發。

**Step 1 — 載入地圖**

讀取地圖的低解析度全貌（Destination、Decisions、open issues 清單）。不要一次載入所有 issue 內容——按需展開。

**Step 2 — 選擇 Issue**

- 使用者指定了 → 用那個
- 使用者沒指定 → 從 Frontier（open + unblocked）中選第一個

**Step 3 — 解決 Issue**

根據 issue 類型委派對應的技能（見 `issue-types.md`）：
- Grilling → 委派 `maze-grill` 或 `maze-grill-with-docs`，向使用者提問，一次一個問題，收斂到答案
- Research → Agent 獨立調研，產出摘要（如涉及領域建模，委派 `maze-domain-modeling`（Pi 路徑：`../../../maze-coder/internal-skills/maze-domain-modeling/SKILL.md`））
- Prototype → 委派 `maze-gui-prototyping`（如適用），或產出粗糙原型供使用者反應
- Task → 列出使用者需要完成的步驟，或 agent 獨立完成

**Step 4 — 記錄與更新**

1. 在 issue 上記錄答案（Local Markdown 載體：寫回該 Questions section 的 `answer` 欄位）
2. 關閉 issue（Local Markdown 載體：該 section 的 `status` 改為 `resolved` 或 `out-of-scope`）
3. 更新地圖的 `Decisions` 區塊（加一行摘要 + 連結）
4. 檢查：這個答案是否讓某些迷霧變得可以精確描述了？
   - 是 → 從 `Not Yet Specified` 畢業，開成新 issue
   - 這個答案是否讓某些問題變得不相關了？
   - 是 → 關閉或移入 `Out of Scope`

**每個 session 只解決一個 issue。** 解決完畢後，過 `../checklists/wayfinder-checklist.md` 的「每次推進完成時自查」，報告當前地圖狀態並停止。

## 寫作與行為規則

- **一次一個問題。** 不要同時丟出五個問題讓使用者選。
- **具體勝過抽象。** 問「你想讓它跑在 Windows 還是跨平台？」而不是「你對平台有什麼想法？」
- **先廣後深。** Mode 1 建圖時橫向展開；Mode 2 推進時才縱向深入。
- **不替使用者決定。** Agent 可以提供選項和各自的 trade-off，但最終選擇權在使用者。
- **不問可以合理假設的問題。** 如果答案有 90% 的機率是 X，直接假設並標注 `[假設]`，讓使用者反駁。
- **地圖是索引，不是倉庫。** 決策細節只存在 issue 裡，地圖只放一行摘要 + 連結。
- **用名稱指涉，不用編號。** 寫「API 選型決策」而不是「#7」。人讀地圖時，名稱比編號有意義。
- **迷霧只向前推。** 已畢業的迷霧不退回；已關閉的 issue 不重開（除非 Destination 改變）。
- **Out of Scope 是有意識的排除，不是垃圾桶。** 每個 out-of-scope 項目需簡述排除理由。

## 跨 Session 狀態管理

狀態完全外化在載體上（GitHub Issues 或 Markdown 檔案），天然支援跨 session 操作。

**Session 開始時：** 確認地圖載體位置 → 載入地圖低解析度視圖 → 確認 Destination 是否仍然正確（使用者可能在 session 之間改變想法）。

**並發安全（GitHub Issues 載體）：** 開始處理 issue 前先 assign 給自己（claim）；open + unassigned = 可認領；open + assigned = 已被其他 session 認領，跳過。

**並發安全（Local Markdown 載體）：** 單 session 操作，不考慮並發；載入地圖時記錄檔案內容的 hash，每次寫回前重新計算並比對——不一致代表檔案在 session 期間被外部修改，警告使用者並暫停，不覆寫。
