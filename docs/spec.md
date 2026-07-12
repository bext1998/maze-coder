# maze-coder 規格 v3.0 — 自適應技能包

## 1. 目標

maze-coder 提供 18 個跨 Host canonical skills。技能只補充專案知識、風險邊界、輸出契約與完成條件；模型自行選擇探索、規劃、工具、平行與 Subagent 方式。

核心原則：階段可調整，契約不可省略；只有觀察到具體失敗才增加最小必要 Guidance。

## 2. 架構契約

- `core/invariants.md` 保存不可省略的授權、範圍、外部寫入與真實驗證規則。
- `core/workflow-model.md` 定義能力式 Profile 選擇與 `minimal → standard → scaffolded` 加強訊號。
- `profiles/` 提供三級 Guidance，不依模型國別分類。
- `model-overlays/` 只修正已知偏差，不複製技能或 Profile。
- `skills/` 是技能與按需 references 的唯一 source of truth。
- Adapter 只翻譯路徑、路由與 Host 包裝，不改變技能行為。

## 3. 技能與觸發

14 個既有技能全面加入 `invocation` metadata。新增公開入口 `maze-grill`、`maze-grill-with-docs`，以及 internal 共用技能 `maze-grilling`、`maze-domain-modeling`，共 18 個技能、16 個公開或可由模型觸發的技能、2 個 internal skills。

`invocation` 只允許 `user`、`model`、`both`、`internal`。Router 不公開 internal skills；只有入口技能明示組合時載入。

## 4. Grill 契約

- 每次只提出一個會改變設計方向的問題，附推薦答案與理由。
- 可從程式碼、文件或 Git 查證的事實先自行查證。
- 關鍵分支釐清前不進入實作。
- `maze-grill` 不建立文件。
- with-docs 只在有實質內容時更新 Context、Glossary、Decision 或 ADR。
- ADR 必須同時滿足難以逆轉、缺背景無法理解、存在有意義替代方案與取捨。

## 5. Spec → Issues 與 Closeout

- Issue 原則上可在單一乾淨 Context Window 完成，優先採可獨立驗證的垂直切片；機械式大重構可採 expand–migrate–contract。
- 每個 Issue 記錄阻塞關係，只有阻塞解除者屬可執行前線。
- 預設 Dry Run；寫入 GitHub 與新標籤前確認，建立前確認 Assignee 策略。
- 正式任務只用一個 P0–P4；候選不得同時帶 P0–P4。完整完成用 `Closes`，部分完成用 `Related to`。
- Closeout 只同步 `STATUS.md` 與 `NEXT_ACTION.md`，狀態取自 Git、Issue、PR、CI、QA 與專案文件證據；跨工具交接才使用 handoff。

## 6. 驗收條件

- [ ] 18 個來源技能具有完整 frontmatter、合法 invocation、必要行為與輸出契約。
- [ ] 三個 Profiles、四個 Overlays、核心不變量與自適應工作模型存在。
- [ ] GPT-5.6 Overlay 保持精簡，不重教一般代理能力。
- [ ] 四種 Adapter 與 canonical resources 一致，Router 只公開 16 個非 internal 技能。
- [ ] README、Adapter 文件、同步及驗證腳本的技能數量一致。
- [ ] 無空白必要章節、未完成佔位、失效資源引用或強制 Session Report。
- [ ] 同步第二次無差異，Shell syntax、結構、功能與情境驗證通過。
- [ ] 比較基準與新版的載入數、字元／Token、輪次、詢問、工具、文件、驗收、偏移、錯誤完成與返工。
- [ ] 未經授權不 Push、不建立或修改遠端 Issue／PR／Branch。

## 7. 非目標

- 不建立固定重型 Phase、強制 Todo、進度報告或每次 Session 永久摘要。
- 不為每種模型複製完整技能，不依國別分類模型。
- 不為字數最少而移除安全、範圍、輸出、確認或驗證契約。

## 8. 基準

`pre-adaptive-refactor` 指向本機 commit `57459a1`：14 個技能共 9,174 字元；結構與功能驗證通過，Ubuntu 原生執行未驗證。
