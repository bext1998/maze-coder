# maze-coder 規格 v3.3 — maze-wayfinder 探路技能

> 狀態：決策完成
> 規格日期：2026-08-02
> Canonical source：本文件

## Problem Statement

maze-coder 目前最上游的需求技能是 `maze-idea-to-spec`，但它的前置條件是使用者「至少能陳述一句需求」；使用者連核心問題都無法明確陳述、只有一種模糊感覺時，`maze-idea-to-spec` 會因為前置條件不足而停止，卻沒有下一步可用的技能——使用者只能回到一般對話，沒有固定的可重複流程幫他從迷霧中找到方向，也沒有跨 session 可恢復的狀態載體記錄哪些問題已解決、哪些還在迷霧中。

使用者需要在不修改既有 `maze-idea-to-spec`／`maze-grill` 契約、不新增 internal skill、一次只載入一個公開技能的前提下，取得可重複使用的探路能力：透過結構化提問撥開迷霧，產出一張可跨 session 恢復的決策地圖，迷霧清完後由使用者自行決定下一步。

## Solution

新增一個 `both` invocation 的公開技能 `maze-wayfinder`：委派既有的 `maze-grill`（核心提問引擎）與視需要委派 `maze-domain-modeling`（internal）、`maze-gui-prototyping`、`maze-grill-with-docs`，以兩種模式運作——Mode 1 建圖（一個 session 只做這件事，把模糊想法收斂成 Destination 並勾勒迷霧輪廓）、Mode 2 推進地圖（每個 session 只解決一個 issue，記錄答案並更新地圖）。地圖支援 GitHub Issues（預設）或本機 Markdown 兩種載體，語義相同。標記為 HITL 的問題 agent 不得替使用者回答；地圖是索引而非倉庫，決策細節只存在對應的 issue 裡。

技能本體遵循 `maze-skill-authoring` 既有的「內容量大時拆分到按需資源」規則：`SKILL.md` 只放目標、前置條件、Mode 1／Mode 2 摘要、輸出契約與邊界；完整流程細節、提問策略與跨 session 並發規則放進 `references/execution-flow.md`；問題類型、標籤與 blocking／frontier 判斷放進 `references/issue-types.md`；地圖檔案結構放進 `templates/WAYFINDER_MAP.template.md`；自查清單放進 `checklists/wayfinder-checklist.md`。

完成後 maze-coder 共有 28 個 canonical skills：25 個公開或可由模型觸發的技能、3 個 internal skills（較 v3.2 的 27／24／3 增加一個公開技能，internal 數量不變）。

### Success metrics

- AC-01 至 AC-10 全數成立，沒有 `unverifiable` 的完成宣告。
- 三支 validator、Shell syntax 與 `git diff --check` exit 0；第二次 sync 明確輸出 `no changes`。
- `maze-wayfinder/SKILL.md` 字元數低於 3,000 建議值；全部 SKILL.md 總字元低於 22,000 硬上限。
- `docs/spec.md` 不含任何前一版本遺留的技能數字串。

## User Stories

1. 身為對自己想做什麼還很模糊的使用者，我希望有人一個問題一個問題地問我，而不是要求我先講清楚需求才能開始。
2. 身為使用者，我希望探路過程留下一張可跨 session 恢復的地圖，下次回來時不必重新從頭講一遍。
3. 身為使用者，我希望能清楚分辨「已經想清楚的」「已經想到但還沒答案的」「連問題都還想不出來的」三種狀態，不被混在一起。
4. 身為使用者，我希望迷霧清完後由我自己決定下一步（跑 `maze-idea-to-spec`、直接實作或別的），而不是被技能推著走。
5. 身為維護者，我希望新技能沿用既有 `maze-grill` 的提問引擎與既有的按需資源慣例，不重新發明一套提問邏輯。

## Implementation Decisions

### Existing architecture contract

以下 v3.0–v3.2 契約維持 FROZEN，v3.3 只加入本規格明定的能力：

- `core/invariants.md` 保存授權、範圍、外部寫入與真實驗證等不可省略規則。
- `core/workflow-model.md` 依能力選擇 `minimal → standard → scaffolded` Guidance Profile，只有觀察到具體失敗才加強。
- `profiles/` 提供 Guidance；`model-overlays/` 只修正已知模型偏差，不複製技能或 Profile。
- `skills/` 是 canonical skills 與按需資源的唯一 source of truth；Adapter 只翻譯路徑、路由與 Host metadata。
- `invocation` 只允許 `user`、`model`、`both`、`internal`。Router 不公開 internal skills；入口技能只有在自身契約明示時才能組合 internal skill。
- 每次意圖只路由一個最相關公開技能；references、templates、checklists 與 internal skill 依需要載入。
- `maze-grill`、`maze-grill-with-docs`、`maze-grilling` 與 `maze-domain-modeling` 的逐題、查證、收斂、文件與 ADR 門檻不變；`maze-wayfinder` 只委派，不修改其契約。
- `maze-idea-to-spec` 的前置條件（至少一句需求描述）不變；`maze-wayfinder` 不吸收其職責，只補上更上游的情境。
- v3.2 新增的 `maze-adversarial-review`／`maze-threat-modeling`／`maze-root-cause-diagnosis` 契約與文件治理契約（規格 v3.2，已封存於 git 歷史）不變。
- 可攜性仍定義為複製目錄即可使用；同步與驗證只依賴 Bash、find、grep 等既有工具，支援 macOS、Linux 與 Windows Git Bash。
- `gh` 是 GitHub 操作時的可選外部工具；命令必須支援所用的 `--json`／`--jq` 旗標，否則停止並回報，不降級解析表格文字。

### Skill topology and routing

| Skill | Invocation | Router intent | Direct consumers |
|---|---|---|---|
| `maze-wayfinder` | `both` | 需求太模糊、連想要什麼都不確定 | 使用者 |

- 目前總數固定為 28：25 public／model-visible、3 internal（較 v3.2 的 27／24／3 增加一個公開技能，internal 數量不變，不新增 internal skill）。
- `maze-wayfinder` 不修改被委派技能（`maze-grill` 等）的契約，只按其既有輸出契約使用。

### `maze-wayfinder` contract

- 使用者需求模糊到連核心問題都無法明確陳述時才啟動；能陳述、只是需要整理時導向 `maze-idea-to-spec`，不建圖。
- Mode 1 建圖：委派 `maze-grill` 收斂 Destination，發現需求已足夠清晰時立即停止並詢問是否改跑 `maze-idea-to-spec`；再委派 `maze-grill` 做廣度優先提問；能精確陳述的問題開成 issue（Frontier，依 `references/issue-types.md` 標記類型），無法陳述的寫入 `Not Yet Specified`，明確排除的寫入 `Out of Scope`。一個 session 只建圖，不解決 issue。
- Mode 2 推進地圖：每個 session 只解決一個 issue；標記 HITL 的 issue，agent 不得替使用者回答；解決後更新 `Decisions`，檢查迷霧是否可畢業、issue 是否變得不相關。
- 地圖是索引，不是倉庫：決策細節只存在對應 issue 裡，地圖只放一行摘要＋連結。
- 不寫規格書、不做實作、不寫程式碼、不產出 PR、不替使用者做決策。

### Work items

| Task ID | 正式狀態 | Priority | 目標 | 依賴 |
|---|---|---|---|---|
| MCR-33-001 | 正式 | P1 | 建立 `maze-wayfinder` 技能（`SKILL.md` + `references/`／`templates/`／`checklists/`） | 無 |
| MCR-33-002 | 正式 | P1 | 整合 Router、canonical skill arrays、五個 Adapter、validators | MCR-33-001 |

### Contract

- `maze-wayfinder` 不得修改被委派技能（`maze-grill`、`maze-domain-modeling` 等）的契約。
- Mode 1 建圖 session 不得解決 issue；Mode 2 每個 session 只解決一個 issue。
- 標記 HITL 的 issue，agent 不得替使用者作答；違反視同技能失效。
- Adapter 必須完整包含 28 個 canonical skills，且 internal skill 不得出現在公開 Router。
- 未通過本規格 Acceptance Criteria 與適用驗證時，不得宣告 v3.3 完成。

### Invariants

| Invariant | 違反時的可觀察症狀 |
|---|---|
| Mode 1 建圖 session 不解決 issue | 建圖回報中出現「已解決」的 issue 或地圖 Decisions 被填入 |
| HITL 類型 issue 不得由 agent 代答 | Issue 被關閉，答案卻明顯是 agent 自行推測而非使用者提供 |
| 地圖是索引不是倉庫 | 地圖檔案或地圖 issue 本文出現決策的完整推導過程而非一行摘要＋連結 |
| `docs/spec.md` 與 README、Harness、validator 的技能數量一致 | 任一處技能數量與其他處不同 |
| `skills/`、`core/` 與同步腳本是 source of truth | Adapter 手動修改、第二次 sync 仍有變更或 tree 比對失敗 |

### Edge Cases

- 使用者一開始就能清楚陳述需求時，`maze-wayfinder` 在 Step 1 grilling 後立即停止並詢問是否改跑 `maze-idea-to-spec`，不勉強建圖。
- Frontier 上的 issue 已被其他 session assign 時，跳過不重複認領（GitHub Issues 載體）。
- Local Markdown 載體偵測到地圖檔案在 session 期間被外部修改時，警告使用者並暫停，不覆蓋。
- 使用者在推進過程中改變 Destination 時，已關閉的 issue 允許重開；其餘情況已關閉的 issue 不重開。
- 重複執行 sync 必須冪等；重複執行 GitHub Create 不得產生重複資源。

### FROZEN

- `maze-wayfinder` 唯讀邊界之外的實質工作（寫規格、實作、產出 PR）不得放寬進本技能。
- Mode 1／Mode 2 分離（建圖不解決 issue、推進每次只解決一個）不得放寬。
- HITL 類型 issue 不得由 agent 代答的規則不得放寬。
- 目前技能數固定為 28／25／3。
- 變更上述 FROZEN 決策時，必須同步更新本規格、Router、canonical skill arrays、五個 Adapter 文件與 validators，不能只修改單一技能。

## Testing Decisions

### Test philosophy and seams

- 測試外部契約、路由結果、產物結構與安全邊界，不鎖定段落措辭或 Agent 的內部推理順序。
- 最高接縫沿用既有 Shell：結構 validator、功能契約 validator；五個 Host Adapter 由 sync 後的 tree／metadata 比對覆蓋。
- 不新增 live GitHub fixture、測試 Issue／PR 或需要網路授權的整合測試。

### Structural validation

- `validate-skillpack.sh` 固定驗證 28 個 SKILL.md、25 public、3 internal。
- `docs/spec.md` 不得含有前一版本遺留的技能數字串（自我一致性檢查），且必須標示目前技能拓撲。
- 五個 Adapter 必須與 canonical resources 一致；Claude invocation metadata 必須正確轉譯。

### Functional contract validation

- `maze-wayfinder` 必須包含 Mode 1／Mode 2 的區分、HITL 邊界、地圖是索引不是倉庫的原則與委派對象。
- `references/execution-flow.md` 必須涵蓋完整 Mode 1／Mode 2 步驟；`references/issue-types.md` 必須涵蓋四種問題類型與 blocking／frontier 判斷。

### Test cases

| Test ID | 層次 | 驗證內容 | 自動化 | 通過門檻 | FROZEN |
|---|---|---|---|---|---|
| T-33-001 | 結構 | 28／25／3 計數、spec 自我一致性 | 是 | validator exit 0，無殘留舊計數字串 | 是 |
| T-33-002 | 功能契約 | `maze-wayfinder` Mode 1／Mode 2、HITL 邊界、地圖索引原則 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-33-003 | 整合 | 五種 Adapter 同步與第二次 sync 冪等 | 是 | 第一次完成同步，第二次輸出 `no changes` | 是 |
| T-33-004 | 可攜性 | Shell syntax、UTF-8 內容與跨平台既有契約 | 是；Ubuntu runtime 依環境 | syntax／validator exit 0；無環境時明列未驗證 | 否 |

- 禁止以 `|| true`、忽略退出碼、弱化 assertion、刪除失敗案例或修改測試迎合錯誤輸出的方式取得通過。
- 不以 live GitHub 寫入替代 Shell 契約測試；外部狀態沒有測試環境時必須維持未驗證標示。

### Adaptive scenarios and token budget

- `tests/adaptive-scenarios.tsv` 是固定 26 列的代表性情境樣本，本來就不是每個技能對應一列（v3.2 完成時已是 27 個技能對 26 個情境）；本版不新增列，維持 26 個。
- SKILL.md 總字元上限固定為 22,000；詳細內容使用按需資源，不記錄瞬時總字元數。
- 保留現有 adaptive 指標不得比 baseline 退化的檢查。

### Acceptance Criteria

- [x] AC-01：存在 `maze-wayfinder` 公開技能，`invocation: both`，委派 `maze-grill` 為核心提問引擎。
- [x] AC-02：`maze-wayfinder` 的 Mode 1 建圖 session 不解決 issue，Mode 2 每個 session 只解決一個 issue。
- [x] AC-03：標記 HITL 的 issue 契約明示 agent 不得替使用者作答。
- [x] AC-04：地圖是索引原則明示——決策細節只存在對應 issue，地圖只放一行摘要＋連結。
- [x] AC-05：`references/execution-flow.md`、`references/issue-types.md`、`templates/WAYFINDER_MAP.template.md`、`checklists/wayfinder-checklist.md` 皆存在且被 `SKILL.md` 引用。
- [x] AC-06：canonical／public／internal skills 數量分別為 28、25、3，Router 不公開 internal skills。
- [x] AC-07：`maze-wayfinder/SKILL.md` 字元數低於 3,000 建議值；全部 SKILL.md 總字元低於 22,000。
- [x] AC-08：第一次 `bash scripts/sync-adapters.sh` 產生所需更新，第二次輸出 `no changes`。
- [x] AC-09：三支 validator、Shell syntax 與 `git diff --check` 全數通過。
- [x] AC-10：`docs/spec.md` 不含任何前一版本遺留的技能數字串。

### AC automation mapping

- AC-01 至 AC-04 由 T-33-002 驗證。
- AC-05 至 AC-07 由 T-33-001／T-33-002 驗證。
- AC-08 至 AC-10 由 T-33-003／T-33-004 及 `git diff --check` 驗證。

## Out of Scope

- 不新增 internal skill；`maze-wayfinder` 為公開 `both` invocation。
- 不修改 `maze-grill`、`maze-idea-to-spec`、`maze-domain-modeling` 等被委派技能的既有契約。
- 不在 `tests/adaptive-scenarios.tsv` 新增 `maze-wayfinder` 專屬情境列（該檔案是固定 26 列的代表性樣本，非逐技能覆蓋）。
- 不為 GitHub Issues 載體預先建立 `wayfinder:*` label；label 由使用該技能的專案自行視需要建立。
- 不自動 commit、push、merge、release 或 deploy。

## Further Notes

### Dependencies and delivery order

- MCR-33-001 完成後才能開始 MCR-33-002 的整合與驗證。

### Drift Risk

- Router、validator、README、Harness 與 Adapter README 皆含技能數常數，遺漏任一處會造成跨 Host 語意漂移。
- `docs/spec.md` 若混雜歷史版本的計數與目前值，會讓後續 agent 誤判現況；每次版號變更都必須整份取代舊版內容，而非只置換數字。

### Existing baseline

- v3.2 基準：27／24／3 之前為 24／21／3，26 個 adaptive scenarios 之前為 13 個；細節見 git 歷史中的 v3.1／v3.2 版本 `docs/spec.md`。
- v3.3 不改變「階段可調整，契約不可省略」原則，也不因新技能限制模型的探索、工具、平行與 Subagent 能力。

### Open Questions

- 無。技能拓撲、輸入、輸出、副作用、降級行為、測試接縫、token 上限、發布方式與本版整合範圍均已決定。
