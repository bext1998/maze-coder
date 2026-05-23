# maze-coder — opencode Agent 指令

> 本文件由 sync-adapters.sh 自動產生，請勿手動編輯。
> source of truth：skills/ 目錄下的各 SKILL.md

---

## 技能：maze-idea-to-spec

---
name: maze-idea-to-spec
description: |
  將使用者的模糊想法或口語描述轉換成結構化的 spec.md。
  當使用者說「我想做一個...」、「幫我寫一個規格書」、「我有一個想法」時觸發。
---

# idea-to-spec：想法轉規格書

## 技能目標

使用者的模糊想法無法直接指導 coding agent 工作。本技能透過引導式問答，將口語描述轉換成包含完整結構的 `spec.md`，讓 coding session 有明確的參照文件。

## 前置條件（Preconditions）

- 使用者必須提供至少一句話描述想做什麼
- 若描述不足（例如只說「我想做一個 app」），必須停止並提問，不得自行填充假設
- 若 session 中已存在 `spec.md`，必須詢問：「是要建立新 spec 還是修改現有的？」

## 執行流程

### Phase 0：評估輸入

- 閱讀使用者提供的描述
- 若描述不足，列出缺漏問題並停止，例如：
  - 「這是給誰用的？」
  - 「核心功能是什麼？」
  - 「有什麼不想做的？」

### Phase 1：釐清核心問題

收集以下資訊（不足時提問）：
- **專案名稱**：這個東西叫什麼？
- **核心問題**：它解決什麼問題？
- **目標使用者**：誰會用它？
- **核心功能**：最重要的 3-5 個功能
- **非目標**：明確不做什麼
- **技術限制**：語言、框架、平台的偏好或限制

### Phase 2：產出 spec.md

依照 `spec.template.md` 結構產出文件，包含：
- 專案概述
- 核心問題
- 目標
- 非目標
- 功能清單（依優先順序）
- 技術考量
- 成功指標

### Phase 3：確認

輸出後詢問使用者：「這份 spec 是否正確反映你的想法？需要調整哪個部分？」

### Phase 4：記錄 spec 路徑

使用者確認後：
- 若目錄下已有 `MAZE_PROJECT.md`，更新其中的「規格文件實際路徑」欄位為本次寫入的路徑
- 若無 `MAZE_PROJECT.md`，提示使用者：「可執行 `maze-project-init` 以建立 MAZE_PROJECT.md，讓未來的 agent 能快速定位此 spec」

## 輸出（Output Contract）

- **位置**：使用者指定路徑，預設為 `spec.md`
- **格式**：符合 `spec.template.md` 的完整 Markdown 文件
- **完整性**：所有必要 section 都必須填寫，不留空白佔位符
- **路徑記錄**：若 `MAZE_PROJECT.md` 存在，其中的 spec 路徑欄位必須更新

## 技能邊界（本技能不做的事）

- 不補強或驗證 spec（那是 `spec-hardening` 的工作）
- 不建立專案目錄結構（那是 `project-init` 的工作）
- 不撰寫程式碼
- 不做技術可行性分析（spec 只記錄需求，不做評估）
- 不在使用者未確認前自動寫入檔案

---

## 技能：maze-spec-hardening

---
name: maze-spec-hardening
description: |
  補強既有的 spec.md 草稿，加入工程防護層（Contract、Invariants、Edge Cases、AC、Test Plan）。
  當使用者說「幫我補強 spec」、「讓 spec 更完整」、「加入驗收標準」時觸發。
---

# spec-hardening：規格書補強

## 技能目標

草稿 spec.md 通常只描述「要做什麼」，缺少工程實作所需的邊界定義。本技能在不改變原始架構決策和功能範圍的前提下，加入 8 個防護層，讓 coding agent 能精確理解預期行為與限制。

## 前置條件（Preconditions）

- 必須提供一份現有的 `spec.md`（任何格式皆可）
- 若輸入 spec 不完整，標注 `[缺漏]` 後繼續補強可補的部分，不得停止
- 不修改原始規格的架構決策、功能範圍、命名慣例

## 執行流程

### Phase 0：閱讀原始 spec

完整閱讀輸入的 spec，識別：
- 已定義的功能與非目標
- 模糊或假設性的描述
- 缺少的工程細節

### Phase 1：加入 Contract（介面契約）

為每個核心功能或技能定義：
- 輸入要求（使用者必須提供什麼）
- 輸出承諾（產出什麼、格式是什麼）
- 失敗行為（輸入不足或錯誤時怎麼辦）

### Phase 2：加入 Invariants（系統不變式）

列出在任何時間點都必須成立的條件，例如：
- 目錄結構約束
- 命名規則
- 狀態一致性要求

### Phase 3：加入 Edge Cases（邊界情況）

對每個核心組件列出：
- 非預期輸入的處理方式
- 環境差異（OS、字元編碼等）
- 中途中斷的處理

### Phase 4：加入 Acceptance Criteria（驗收標準）

列出可手動或自動驗證的通過條件，每條標準包含：
- 測量方式
- 通過門檻
- 是否可自動化

### Phase 5：加入 Test Plan（測試計畫）

定義：
- 測試層次（單元 / 整合 / 手動 / 可攜性）
- 關鍵測試案例（含 ID 和 [FROZEN] 標記）
- 禁止的測試行為

### Phase 6：標記 [FROZEN] 決策

對不得在 v1.x 期間修改的決策加上 FROZEN 標記，說明：
- 被凍結的決策內容
- 變更時需同步更新的位置

### Phase 7：加入 Drift Risk Analysis（飄移風險）

識別容易被 AI 代理誤解的位置，對每個風險記錄：
- 模糊點位置
- 可能的錯誤詮釋
- 緩解措施

### Phase 8：更新 Open Questions

列出尚未確認的決策，標記狀態（待確認 / ✅ 已確認）。

## 輸出（Output Contract）

- **位置**：覆蓋原始 `spec.md`，或輸出為 `spec-hardened.md`
- **格式**：原始 spec + 8 個補強區塊，補強內容以 `<!-- HARDENED -->` 區塊標示
- **完整性**：必須包含全部 8 個補強區塊，缺一不可

## 技能邊界（本技能不做的事）

- 不改變原始 spec 的功能範圍或架構決策
- 不評估技術可行性
- 不實作功能或撰寫程式碼
- 不刪除原始 spec 的任何章節
- 不因 spec 不完整而停止執行（標注缺漏後繼續）

---

## 技能：maze-project-init

---
name: maze-project-init
description: |
  初始化專案的指揮文件集（PROJECT_BRIEF、STATUS、NEXT_ACTION、DECISIONS、AGENTS）。
  當使用者說「幫我建立專案文件」、「初始化這個專案」、「設定 coding agent 指令」時觸發。
---

# project-init：專案初始化

## 技能目標

新專案開始時，缺少清晰的文件讓 coding agent 容易失去方向。本技能產出一套完整的專案指揮文件，讓 agent 在每個 session 開始前都能快速定位當前狀態和下一步。

## 前置條件（Preconditions）

- **必須**提供專案名稱 — 缺少時停止並詢問，不得使用「untitled」或自行命名
- **必須**說明至少一個目標工具（Claude Code / Codex / Cursor / opencode）
- **必須**提供規格文件的實際路徑（若有 spec.md）— 缺少時停止並詢問，不得假設路徑為 `spec.md`
- 若三項以上未提供，一次性列出所有缺漏項目，不得逐一詢問

## 執行流程

### Phase 0：確認輸入

確認：
- 專案名稱（確切名稱，非描述）
- 目標工具（可多選）
- 技術棧（語言、框架）
- 規格文件實際路徑（若存在）

### Phase 0.5：掃描既有文件

掃描目標目錄，對每個已存在的目標文件逐一詢問：

> 「[檔名] 已存在，請選擇：(1) 跳過 (2) 覆蓋 (3) 查看後決定」

特殊處理：
- 若 `MAZE_PROJECT.md` 已存在且記錄了不同的 spec 路徑，**停止並提示**：「已偵測到現有的 spec 路徑設定，是否要更新為新路徑？」，等待確認後才修改
- 若使用者全部選擇跳過，輸出「所有文件均已保留，未做任何修改」並結束

### Phase 1：產出 PROJECT_BRIEF.md

填寫：
- 專案名稱與一句話說明
- 核心問題
- 目標技術棧
- 連結到 `spec.md`（若已存在）

### Phase 2：產出 STATUS.md

初始狀態：
- 當前階段：初始化
- 完成的事項：（空）
- 待完成事項：開始第一個 coding session

### Phase 3：產出 NEXT_ACTION.md

初始下一步：
- 閱讀 `spec.md`（若存在）
- 建立 repo 結構
- 設定開發環境

### Phase 4：產出 DECISIONS.md

初始決策紀錄：
- 選擇使用的工具與原因
- 技術棧決策

### Phase 5：產出 AGENTS.md（依目標工具）

依使用者指定的工具，填寫對應的 AGENTS.md 模板，包含：
- 專案說明
- 技術棧摘要
- 工作流指引
- 檢查清單引用

### Phase 6：產出 MAZE_PROJECT.md

建立 `MAZE_PROJECT.md`（若使用者未選擇跳過），填寫：
- 專案名稱
- 目標工具
- 規格文件的實際路徑（使用者提供的值，若無則標注「[尚未建立]」）
- 各關鍵文件的相對路徑

此文件作為 agent 定位錨點，讓任何工具在未來 session 都能找到正確的 spec 路徑。

## 輸出（Output Contract）

- **位置**：使用者指定的專案目錄根目錄
- **格式**：符合各 `*.template.md` 結構的 Markdown 文件集
- **完整性**：至少產出 PROJECT_BRIEF.md、STATUS.md、NEXT_ACTION.md、MAZE_PROJECT.md 四份文件

## 技能邊界（本技能不做的事）

- 不建立 git repo 或初始化版本控制
- 不撰寫程式碼或設定開發環境
- 不修改 `spec.md`（那是 `idea-to-spec` 和 `spec-hardening` 的工作）
- 不決定技術棧（只記錄使用者的決策）
- 不評估技術選擇的優劣
- 不在 MAZE_PROJECT.md 中記錄技術決策（那是 DECISIONS.md 的工作）

---

## 技能：maze-session-closeout

---
name: maze-session-closeout
description: |
  Coding session 結束後，更新 STATUS.md、NEXT_ACTION.md 並產出 session-summary。
  當使用者說「結束 session」、「更新狀態」、「今天先到這裡」時觸發。
---

# session-closeout：Session 結束更新

## 技能目標

Coding session 結束後，若不更新狀態文件，下一個 session 的 agent（或人類）需要花時間重建上下文。本技能確保每次 session 結束都留下清晰的狀態快照和明確的下一步。

## 前置條件（Preconditions）

- 使用者必須提供本次 session 的摘要（做了什麼、遇到什麼問題）
- 若摘要為空，列出需要填寫的問題，不得留空白模板：
  - 「本次 session 完成了哪些事？」
  - 「有沒有遇到問題或阻塞？」
  - 「下一步要做什麼？」
- 若存在 STATUS.md，讀取其當前內容後再更新

## 執行流程

### Phase 0：收集資訊

若使用者未提供，詢問：
1. 本次 session 完成的事項
2. 進行中但未完成的事項
3. 遇到的問題或阻塞
4. 下一步行動計畫

### Phase 1：更新 STATUS.md

- 移動「進行中」事項到「已完成」（若已完成）
- 更新「已知問題」
- 清除已解決的「阻塞項目」
- 更新最後更新時間

### Phase 2：更新 NEXT_ACTION.md

- 清除已完成的行動步驟
- 根據使用者提供的下一步更新「下一個 Session 的目標」
- 更新「需要決定的事項」

### Phase 3：產出 session-summary

建立本次 session 的快照文件（`session-summary-[日期].md`），包含：
- 完成事項
- 技術決策
- 未解決問題
- 下一步

## 輸出（Output Contract）

- **STATUS.md**：更新後的當前狀態，帶有新的最後更新時間
- **NEXT_ACTION.md**：更新後的下一步行動
- **session-summary**：本次 session 的不可變快照（可選，供未來參考）

## 技能邊界（本技能不做的事）

- 不做 git commit 或 push
- 不修改 `spec.md` 或 `DECISIONS.md`
- 不評估本次 session 的工作品質
- 不決定技術方向（只記錄使用者的決策）
- 不產出 QA 報告（那是 `qa-verification` 的工作）

---

## 技能：maze-github-safe-ops

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

---

## 技能：maze-design-review

---
name: maze-design-review
description: |
  審查前端輸出的設計品質，降低 AI slop（AI 生成感），產出 DESIGN_REVIEW.md 報告。
  當使用者說「幫我審查設計」、「這個 UI 看起來像 AI 做的」、「前端 QA」時觸發。
---

# design-review：前端設計審查

## 技能目標

AI 生成的前端常出現固定模式（過度使用漸層、千篇一律的卡片佈局、缺乏視覺層次），導致「AI slop」感。本技能透過多層檢查清單，識別並提出改善建議，讓前端輸出具有人工設計的品質感。

## 前置條件（Preconditions）

- 需要提供以下之一：
  - 前端截圖（UI 的視覺輸出）
  - 前端程式碼（HTML / CSS / JSX 等）
  - 設計稿描述
- 若無法取得視覺輸出：標注「無法驗證視覺品質」並繼續審查程式碼結構
- 不需要 `spec.md`，但若存在則參考功能目標進行審查

## 執行流程

### Phase 1：Anti-AI-Slop 審查

使用 `anti-ai-slop-checklist.md` 識別典型的 AI 生成模式：
- 過度的圓角 + 陰影 + 漸層
- 過多的白色空間導致內容密度過低
- 千篇一律的卡片佈局
- 缺乏視覺層次（所有元素大小相近）
- 過度使用 emoji 或圖示

### Phase 2：UX 審查

使用 `frontend-ux-checklist.md` 評估：
- 操作流程是否直覺
- 錯誤訊息是否清楚
- Loading 狀態是否處理
- 空狀態是否設計
- 表單驗證是否及時

### Phase 3：視覺品質審查

使用 `visual-quality-checklist.md` 評估：
- 字型層次（大小、粗細）是否清楚
- 顏色使用是否一致
- 間距系統是否一致
- 對齊是否整齊

### Phase 4：評分與建議

對每個審查維度給出 0-10 分，並說明：
- 扣分原因
- 具體改善建議
- 優先處理的問題（影響最大的 2-3 個）

### Phase 5：產出報告

填寫 `DESIGN_REVIEW.template.md`，記錄：
- 各維度評分
- 問題清單（高 / 中 / 低優先）
- 改善建議

## 輸出（Output Contract）

- **位置**：`DESIGN_REVIEW.md`（使用者指定目錄）
- **格式**：符合 `DESIGN_REVIEW.template.md` 的報告
- **必要內容**：評分、問題清單、具體改善建議

## 技能邊界（本技能不做的事）

- 不直接修改程式碼（只提供建議）
- 不評估後端邏輯或效能
- 不決定設計風格（只指出問題，由使用者決定修改方向）
- 不做無障礙（a11y）完整審查（那需要更專業的工具）
- 不測試實際使用者行為

---

## 技能：maze-qa-verification

---
name: maze-qa-verification
description: |
  驗證功能是否符合 spec.md 的驗收標準，產出 QA_REPORT.md。
  當使用者說「幫我做 QA」、「驗收功能」、「測試這個功能」時觸發。
---

# qa-verification：QA 驗證

## 技能目標

功能開發完成後，若缺乏系統性的 QA 流程，容易遺漏邊界情況和迴歸問題。本技能依照 spec.md 的驗收標準，建立可追蹤的 QA 報告。

## 前置條件（Preconditions）

- 必須提供：功能描述或 spec.md 中的對應功能說明
- 必須提供：測試目標（驗收哪些條件）
- 若測試環境未就緒，列出缺漏的環境條件，不得假設環境已就緒

## 執行流程

### Phase 0：確認測試範圍

- 閱讀 spec.md 中的 Acceptance Criteria（若存在）
- 確認測試環境狀態（本地 / staging / 其他）
- 識別不可測試的項目，標注原因

### Phase 1：功能測試（Happy Path）

對每個核心功能執行：
- 正常輸入 → 預期輸出
- 確認與 spec.md 驗收標準一致

### Phase 2：邊界情況測試

使用 `code-quality-checklist.md` 和 `test-plan-checklist.md`，測試：
- 空輸入 / 空狀態
- 最大值 / 最小值邊界
- 非預期格式輸入
- 中途中斷的情況

### Phase 3：迴歸測試

使用 `regression-checklist.md`，確認：
- 現有功能未受影響
- 以前的 bug 未重現

### Phase 4：產出報告

填寫 `QA_REPORT.template.md`，記錄：
- 測試結果（通過 / 失敗 / 無法測試）
- 發現的問題（嚴重度、重現步驟）
- 整體結論（是否可以 merge / release）

## 輸出（Output Contract）

- **位置**：`QA_REPORT.md`（使用者指定目錄）
- **格式**：符合 `QA_REPORT.template.md` 的報告
- **必要內容**：每個測試案例的結果、發現的問題清單、整體結論

## 技能邊界（本技能不做的事）

- 不修改程式碼（只報告問題，修復由使用者或其他技能負責）
- 不做效能壓力測試
- 不做安全滲透測試
- 不在測試環境未就緒時假設測試通過
- 不做視覺設計審查（那是 `design-review` 的工作）

---

## 技能：maze-repo-map

---
name: maze-repo-map
description: |
  產生 repo 的結構地圖文件（REPO_MAP.md），幫助 agent 快速理解專案佈局。
  當使用者說「幫我建立 repo map」、「讓 agent 了解這個專案」、「進入新 repo」時觸發。
---

# repo-map：Repo 結構地圖

## 技能目標

進入陌生 repo 或長期未工作後，coding agent 需要時間重建對專案結構的理解。本技能產出一份結構地圖，讓 agent 在下一個 session 開始時快速定位關鍵檔案。

## 前置條件（Preconditions）

- 需要能讀取目標 repo 的目錄結構
- 若 repo 太大（超過 100 個目錄），先聚焦在使用者指定的範圍

## 執行流程

### Phase 1：掃描目錄結構

列出 repo 的頂層目錄和關鍵檔案，識別：
- 進入點（`main.py`、`index.ts`、`app.js` 等）
- 設定檔（`.env.example`、`package.json`、`pyproject.toml` 等）
- 文件目錄
- 測試目錄

### Phase 2：識別關鍵路徑

標注以下類型的檔案：
- **核心邏輯**：主要業務邏輯所在
- **介面定義**：API 端點、型別定義
- **設定**：環境設定、部署設定
- **測試**：測試檔案位置

### Phase 3：產出 REPO_MAP.md

填寫 `REPO_MAP.template.md`，包含：
- 樹狀目錄結構（2-3 層深）
- 關鍵檔案說明
- 技術棧摘要

## 輸出（Output Contract）

- **位置**：`REPO_MAP.md`（使用者指定目錄）
- **格式**：符合 `REPO_MAP.template.md` 的 Markdown 文件
- **更新**：每次 repo 結構有重大變更後需重新產出

## 技能邊界（本技能不做的事）

- 不分析程式碼邏輯或業務流程
- 不評估程式碼品質
- 不產出程式碼文件（docstring 等）
- 不做依賴分析（只記錄目錄結構）
- 不修改任何 repo 內的檔案

---

## 技能：maze-context-audit

---
name: maze-context-audit
description: |
  稽核 coding agent 的當前上下文是否與專案文件一致，找出不一致或過期的假設。
  當使用者懷疑「agent 搞錯了什麼」、「好像在做錯的事」、「上下文可能有問題」時觸發。
---

# context-audit：上下文一致性稽核

## 技能目標

長時間的 coding session 後，agent 可能累積了過期的假設或不一致的狀態。本技能透過對比當前理解和專案文件，識別並修正不一致的上下文。

## 前置條件（Preconditions）

- 需要能讀取以下文件（若存在）：
  - `spec.md`
  - `STATUS.md`
  - `NEXT_ACTION.md`
  - `DECISIONS.md`
- 若文件不存在，標注「缺少 [文件名]，無法稽核對應項目」

## 執行流程

### Phase 1：收集當前理解

列出 agent 目前對以下問題的理解：
- 這個專案要做什麼？
- 當前的開發階段是什麼？
- 下一步要做什麼？
- 有哪些已確認的技術決策？

### Phase 2：對比文件

將 Phase 1 的理解與以下文件對比：
- `spec.md` — 功能範圍是否一致？
- `STATUS.md` — 當前階段是否正確？
- `NEXT_ACTION.md` — 下一步是否對應？
- `DECISIONS.md` — 技術決策是否已記錄？

### Phase 3：使用稽核清單

執行 `context-consistency-checklist.md` 的所有檢查項目。

### Phase 4：報告不一致

對每個不一致的地方：
- 說明「agent 目前的理解」vs「文件記載的實際狀態」
- 建議如何修正（更新文件 or 修正理解）

## 輸出（Output Contract）

- **格式**：不一致項目清單 + 修正建議
- **若一切一致**：輸出「上下文稽核通過，無不一致項目」

## 技能邊界（本技能不做的事）

- 不修改 spec.md 或其他文件（只報告不一致）
- 不做程式碼審查
- 不評估技術決策的優劣
- 不建立新的文件（只比對現有文件）
- 不假設哪邊是「正確的」，只報告不一致

---

## 技能：maze-bug-reproduction

---
name: maze-bug-reproduction
description: |
  產出結構化的 bug 重現文件（BUG_REPRODUCTION.md），方便他人或工具重現和修復 bug。
  當使用者說「幫我記錄這個 bug」、「這個問題要怎麼重現」、「建立 bug report」時觸發。
---

# bug-reproduction：Bug 重現文件

## 技能目標

未充分記錄的 bug 讓修復者需要花大量時間重現問題，有時甚至無法重現。本技能建立結構化的重現步驟文件，確保任何人都能在相同環境下穩定重現問題。

## 前置條件（Preconditions）

- 使用者必須描述：觀察到的問題行為
- 建議提供：預期的正確行為
- 若描述不足，詢問：
  - 「在什麼操作後出現這個問題？」
  - 「每次都會出現，還是偶發性的？」
  - 「在哪個環境（OS、瀏覽器、版本）出現？」

## 執行流程

### Phase 1：收集資訊

詢問（若未提供）：
- 問題的具體表現（錯誤訊息、截圖）
- 重現步驟（操作序列）
- 環境資訊（OS、語言版本、相關套件版本）
- 出現頻率（每次 / 偶發 / 特定條件）
- 影響範圍（只影響這個功能還是更廣）

### Phase 2：驗證重現步驟

若可以，協助使用者確認重現步驟的最小化：
- 哪些步驟可以省略？
- 觸發問題的最短路徑是什麼？

### Phase 3：產出文件

填寫 `BUG_REPRODUCTION.template.md`，包含：
- 問題摘要（一句話）
- 環境資訊
- 最小重現步驟
- 預期 vs 實際行為
- 影響範圍評估

## 輸出（Output Contract）

- **位置**：`BUG_REPRODUCTION.md`（使用者指定目錄）
- **格式**：符合 `BUG_REPRODUCTION.template.md` 的文件
- **必要內容**：重現步驟、環境資訊、預期 vs 實際行為

## 技能邊界（本技能不做的事）

- 不修復 bug（只記錄，修復由使用者或其他技能負責）
- 不評估 bug 的根本原因（只記錄表象）
- 不做 root cause analysis
- 不建立 GitHub Issue（引導使用者自行操作）
- 不對 bug 嚴重度評分（讓使用者決定優先級）

---

## 技能：maze-handoff-summary

---
name: maze-handoff-summary
description: |
  產出結構化的 HANDOFF.md，讓接手的人或工具能快速理解當前狀態並繼續工作。
  當使用者說「幫我建立交接文件」、「我要換工具」、「其他人要接手這個專案」時觸發。
---

# handoff-summary：交接摘要

## 技能目標

在工具切換或人員交接時，若沒有清晰的狀態摘要，接手者需要大量時間重建上下文。本技能產出一份完整的交接文件，讓接手者在 5 分鐘內理解當前狀態並知道下一步。

## 前置條件（Preconditions）

- 建議已完成 `session-closeout`，確保 STATUS.md 和 NEXT_ACTION.md 是最新的
- 需要能讀取（若存在）：
  - `spec.md`
  - `STATUS.md`
  - `NEXT_ACTION.md`
  - `DECISIONS.md`

## 執行流程

### Phase 1：收集當前狀態

閱讀所有可用的專案文件，整合：
- 專案概述（目標、技術棧）
- 當前開發階段
- 已完成的工作
- 進行中的工作
- 未解決的問題
- 重要的技術決策

### Phase 2：詢問補充資訊

若文件不完整，詢問：
- 「有什麼是文件裡沒有記錄的重要脈絡？」
- 「接手者需要特別注意什麼？」
- 「有什麼已知的地雷或陷阱？」

### Phase 3：產出 HANDOFF.md

填寫 `HANDOFF.template.md`，包含：
- 5 分鐘讀完的 TL;DR
- 當前狀態快照
- 下一步行動
- 技術決策摘要
- 注意事項（地雷、陷阱）

## 輸出（Output Contract）

- **位置**：`HANDOFF.md`（使用者指定目錄）
- **格式**：符合 `HANDOFF.template.md` 的文件
- **TL;DR**：必須在 5 句話內可讀完

## 技能邊界（本技能不做的事）

- 不評估工作品質
- 不做技術決策（只記錄已做的決策）
- 不更新 STATUS.md 或 NEXT_ACTION.md（先做 session-closeout）
- 不建立新的功能文件
- 不包含程式碼說明（只包含狀態和決策）

---

