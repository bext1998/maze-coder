# maze-coder 規格 v3.1 — Review 與 GitHub CLI 能力

> 狀態：決策完成
> 規格日期：2026-07-15
> Canonical source：本文件

## Problem Statement

maze-coder 已能建立與補強規格、驗收功能及安全處理 Git／GitHub 工作，但仍缺少三個可重複使用的明確能力：實作前的唯讀規格審查、以 GitHub PR 為單位的高訊號 code review，以及跨技能共用的安全 `gh` 操作契約。

目前 `maze-spec-hardening` 會修改規格，無法取代「先審查、由人決策後再修訂」的流程；`maze-github-safe-ops` 的既有待辦只規劃 code review checklist，無法涵蓋 PR metadata、diff、checks、comments、規格與測試的完整審查；各 GitHub-facing 工作若自行描述 `gh` 命令，也容易重複安全規則、解析人類可讀輸出或在未確認時改變遠端狀態。

使用者需要在不增加不必要公開入口、不破壞一次只載入一個公開技能、不讓審查技能擅自修改來源的前提下，取得一致、可追蹤且可驗證的 review 與 GitHub CLI 工作流。

## Solution

在既有技能包上新增兩個 `user` invocation 的公開技能 `maze-spec-review`、`maze-pr-review`，以及一個只供技能組合的 internal 技能 `maze-github-cli`；後續再加入三個公開 pre-implementation 技能。目前 maze-coder 共有 27 個 canonical skills：24 個公開或可由模型觸發的技能、3 個 internal skills。

`maze-spec-review` 以 `SPEC_REVIEW.md` 留下穩定 finding ID 與複審基準，不修改規格；`maze-pr-review` 以 GitHub PR 為主要審查單位，輸出本地 review 結果但不寫入遠端；`maze-github-cli` 集中管理 `gh` 的結構化輸出、非互動操作、前置檢查與寫入確認，首版只由 `maze-pr-review` 與 `maze-github-safe-ops` 使用。

主要使用者是撰寫規格與審查 PR 的開發者、維護 maze-coder 技能包的人，以及透過 Claude Code、Codex、Cursor 或 opencode 操作 GitHub 的使用者。

### Success metrics

- AC-01 至 AC-17 全數成立，沒有 `unverifiable` 的完成宣告。
- 三支 validator、Shell syntax 與 `git diff --check` exit 0；第二次 sync 明確輸出 `no changes`。
- 26 個 adaptive scenarios 全數通過且估計指標不比 baseline 退化。
- 27 個 SKILL.md 總字元低於 22,000，新增主檔各自符合上限。
- Router 只增加兩個公開 review 入口，任何 Adapter 都不公開 `maze-github-cli`。

## User Stories

1. 身為規格作者，我希望在實作開始前取得結構化的缺漏與矛盾報告，以免錯誤需求直接進入開發。
2. 身為維護者，我希望審查能引用相關 repo 證據，以判斷架構、migration、平台與設計系統衝突。
3. 身為使用者，我希望清楚區分阻擋實作、重大返工風險、次要問題與非必要建議，以安排修訂順序。
4. 身為規格作者，我希望每個 finding 有穩定 ID，以追蹤修訂前後的狀態。
5. 身為規格作者，我希望複審只重查前次 Blocker 與 Major，以避免規格審查無限擴張。
6. 身為需求決策者，我希望審查技能只提出建議、不擅自修改規格，以保留需求決策權。
7. 身為 PR reviewer，我希望從 PR 說明、base、diff、checks、comments、關聯規格與測試判斷變更是否可合併。
8. 身為 PR 作者，我希望 finding 可定位並包含觸發條件、影響與修正方向，以便直接採取行動。
9. 身為 reviewer，我希望報告列出已審查且未發現問題的區域，以確認實際覆蓋範圍。
10. 身為離線或權限受限的使用者，我希望仍可取得明確標示限制的本地 diff 審查，而不被誤導為完整 PR review。
11. 身為 GitHub 操作者，我希望 Agent 以 `--json`／`--jq` 取得結構化資料，避免脆弱的文字解析。
12. 身為 GitHub 操作者，我希望建立或更新遠端資源前看到完整寫入預覽，以防操作錯誤 repo 或資源。
13. 身為 repo 維護者，我希望破壞性操作、`--admin` 或繞過保護規則不會被隱性執行。
14. 身為技能包維護者，我希望 Router、Adapter、文件、技能數與 token 預算由既有 Shell 驗證一致，以防同步漂移。

## Implementation Decisions

### Existing architecture contract

以下 v3.0 契約維持 FROZEN，v3.1 只加入本規格明定的能力：

- `core/invariants.md` 保存授權、範圍、外部寫入與真實驗證等不可省略規則。
- `core/workflow-model.md` 依能力選擇 `minimal → standard → scaffolded` Guidance Profile，只有觀察到具體失敗才加強。
- `profiles/` 提供 Guidance；`model-overlays/` 只修正已知模型偏差，不複製技能或 Profile。
- `skills/` 是 canonical skills 與按需資源的唯一 source of truth；Adapter 只翻譯路徑、路由與 Host metadata。
- `invocation` 只允許 `user`、`model`、`both`、`internal`。Router 不公開 internal skills；入口技能只有在自身契約明示時才能組合 internal skill。
- 每次意圖只路由一個最相關公開技能；references、templates、checklists 與 internal skill 依需要載入。
- `maze-grill`、`maze-grill-with-docs`、`maze-grilling` 與 `maze-domain-modeling` 的逐題、查證、收斂、文件與 ADR 門檻不變。
- `maze-spec-to-issues` 的 Dry Run、穩定 task-id、Parent／Sub-issue、優先級、Assignee 與寫入確認契約不變。
- `maze-session-closeout` 以 GitHub／Git 為工作狀態權威；只有明確 closeout 才整體重建精簡 `NEXT_ACTION.md`，不寫 `STATUS.md`。
- 可攜性仍定義為複製目錄即可使用；同步與驗證只依賴 Bash、find、grep 等既有工具，支援 macOS、Linux 與 Windows Git Bash。
- `gh` 是 GitHub 操作時的可選外部工具；命令必須支援所用的 `--json`／`--jq` 旗標，否則停止並回報，不降級解析表格文字。

### Skill topology and routing

| Skill | Invocation | Router intent | Direct consumers |
|---|---|---|---|
| `maze-spec-review` | `user` | 規格審查／複審 | 使用者 |
| `maze-pr-review` | `user` | PR review／審查 PR | 使用者 |
| `maze-github-cli` | `internal` | 不進 Router | `maze-pr-review`、`maze-github-safe-ops` |

- 目前總數固定為 27：24 public／model-visible、3 internal。
- `maze-spec-preview` 是筆誤，不得成為名稱、別名或 Router 入口。
- 舊的「在 `maze-github-safe-ops` 加入 code review checklist」待辦由 `maze-pr-review` 取代；worktree／subagent 派發指引仍是獨立未完成工作。
- MCR-31-001 至 MCR-31-004 全部是 v3.1 Must-have；本版沒有 Nice-to-have 功能，未列入 Work items 的改善不得阻擋交付。

### `maze-spec-review` contract

**必要輸入與證據**

- 先從 `MAZE_PROJECT.md` 取得規格路徑；未記錄時由使用者明確指定，不猜測根目錄文件。
- 先讀完整規格，再只針對需求涉及範圍查閱相關實作、型別、測試、文件、資料流與設計元件。
- 缺少 repo、環境或設計系統證據時，將相應面向標示為 `unverified`；未經證據支持的推測不得升格為 finding。

**完整審查模式**

- 檢查需求完整性、邏輯一致性、邊界與失敗情境、可實作性、可驗收性、設計系統相容性。
- Finding 使用不隨排序重編的 `SR-xxx` ID，包含等級、類型、規格位置、問題、證據、影響、建議補充及是否必須在實作前解決。
- 等級定義：Blocker 表示核心行為無法安全實作或存在關鍵資料／安全風險；Major 表示可開始但極可能返工；Minor 表示不影響核心實作的缺漏；Suggestion 表示非必要品質改善。
- 結論映射：有 Blocker 為「阻擋實作」；無 Blocker 但有 Major 為「需修訂」；只有 Minor／Suggestion 為「可開始但有備註」；無 finding 為「可開始」。
- 固定產生 `SPEC_REVIEW.md`，包含結論與數量、Findings、未決策事項、建議驗收條件、建議修訂順序、未驗證限制及來源規格識別。

**複審模式**

- 使用 `--verify` 或自然語言「複審」觸發，讀取既有 `SPEC_REVIEW.md` 與同一來源規格。
- 只重查前次 Blocker、Major，保留原 ID，狀態只允許 `resolved`、`open`、`partial`、`unverifiable`。
- 不新增 Minor、Suggestion 或擴張至無關範圍；若規格來源、revision 或核心範圍大幅改變，停止 verify 並要求重新完整審查。

**交接與邊界**

- 不修改原規格、不替使用者決定產品方向、不自動開始實作。
- 使用者選定要採納的 findings 後，才交由 `maze-spec-hardening` 修改規格；`maze-qa-verification` 只在功能實作後依正式規格驗收。

### `maze-pr-review` contract

**輸入與資料取得**

- 優先接受 PR URL、PR number 或可由目前 repo／branch 唯一辨識的 PR；無法唯一辨識時停止並要求目標。
- 完整模式取得 PR 說明、base/head、changed files、diff、checks、review threads／comments、關聯 Issue／規格，並讀取相關實作與測試。
- `gh` 不可用、未登入或權限不足時，可在 base 可確認且 working tree 不會污染結果時降級為 `base…HEAD`；必須列出缺少的 CI、comments 與 metadata，結論不得為 Approve。

**審查與輸出**

- 檢查 PR 說明符合度、行為正確性、錯誤處理、回歸與相容性、狀態／生命週期／競態、資料遺失與安全風險、測試有效性、無關改動及重複實作。
- UI 變更只有在具備 render／截圖證據時評估可觀察結果；深度設計或安全稽核不足時明列限制並建議使用專用技能。
- Findings 使用 Blocker、Major、Minor、Nit，只回報可重現、可定位且值得修改的問題；純主觀風格偏好不得列為 finding。
- 每個 finding 包含檔案／行數（可取得時）、觸發條件、問題、證據、影響與建議修正。
- 結論映射：有 Blocker／Major 為 `Request changes`；只有 Minor／Nit 為 `Comment`；完整證據且無 finding 才為 `Approve`；資料降級或必要證據不足為 `Insufficient evidence`。
- 輸出包含結論、Findings、測試缺口、已審查且未發現問題的區域、限制與建議合併條件。可使用 Host 支援的本地 inline finding 格式，但不得提交 GitHub review。

**邊界**

- 不留言、不批准、不 request changes、不修改 PR／branch／Issue，也不修復程式碼。
- 不因目前 branch 有變更自動觸發；一般未開 PR 的 working-tree review 不屬於本技能。

### `maze-github-cli` contract

**前置檢查**

- 確認 `gh` 可用且已登入，並確認 repository、branch、remote、資源識別與外層技能授權。
- Repo、remote 或資源無法唯一確認時停止；不得依目前目錄名稱猜測遠端目標。

**操作分級**

- Read：`auth status`、repo／Issue／PR 檢視與搜尋、PR diff／checks／review metadata，可直接執行。
- Create／Update：建立或編輯 Issue／PR、checkout PR、留言或 review 等，只在外層技能允許且先展示完整目標、欄位與命令效果後執行一次。
- Destructive：關閉資源、merge 或其他難以回復的操作，必須逐項取得明確確認；未確認時只輸出預覽。
- 優先使用 `--json` 搭配 `--jq`，禁止互動式 editor、隱性 prompt 與解析為人類顯示而設計的表格文字。
- 不使用 `--admin`、強制合併或繞過 branch protection，除非使用者明確要求且 `core/invariants.md` 與外層技能同時允許；安全契約禁止時仍應拒絕。
- 失敗後重新查詢遠端狀態，只重試未完成步驟；不得因輸出不明而重複建立資源。

**組合邊界**

- `maze-pr-review` 只使用 Read 操作，不能藉由 internal skill 寫入 PR。
- `maze-github-safe-ops` 不得自行發起遠端操作；收到明確使用者請求並完成預覽／確認後，才可委派 `maze-github-cli` 執行 GitHub 操作。
- `maze-spec-to-issues`、`maze-session-closeout` 與其他 GitHub-facing skills 在 v3.1 維持現況，不改接此 internal skill。

### Document and adapter integration

- `SPEC_REVIEW.md` 加入文件模型；canonical template 位於 `maze-spec-review` 的按需資源，根 `templates/` 版本由同步腳本產生。
- 只有 `maze-spec-review` 與 `maze-pr-review` 加入 Router；`maze-github-cli` 只加入 canonical skill arrays 與 Adapter 資源。
- README、核心 Harness、四個 Adapter README、同步與驗證腳本的技能數量全部維持為 27／24／3。
- SKILL.md 保持精簡：詳細審查清單、報告格式與命令模式放入按需 checklists、templates 或 references。

### Work items

| Task ID | 正式狀態 | Priority | 目標 | 依賴 |
|---|---|---|---|---|
| MCR-31-001 | 正式 | P1 | 建立 `maze-spec-review`、審查清單與 `SPEC_REVIEW.md` template | 無 |
| MCR-31-002 | 正式 | P1 | 建立 internal `maze-github-cli` 安全操作契約 | 無 |
| MCR-31-003 | 正式 | P1 | 建立 `maze-pr-review` 與高訊號審查清單 | MCR-31-002 |
| MCR-31-004 | 正式 | P1 | 整合 safe-ops、Router、文件、Adapter 與 validators | MCR-31-001、MCR-31-002、MCR-31-003 |

### Contract

- Review 結果必須以證據區分已查證事實、推論與未驗證限制。
- Review 技能不得修改其審查來源或外部 GitHub 狀態。
- Internal CLI 不得擴張外層技能與使用者授權。
- Adapter 必須完整包含 27 個 canonical skills，且 internal skill 不得出現在公開 Router。
- 未通過本規格 Acceptance Criteria 與適用驗證時，不得宣告 v3.1 完成。

### Invariants

| Invariant | 違反時的可觀察症狀 |
|---|---|
| 一次只路由一個公開技能；入口明示時才載入 internal skill | Router 同時載入多個公開技能，或公開列出 `maze-github-cli` |
| 所有外部寫入先顯示目標與變更，再取得明確確認 | GitHub 資源在預覽或確認前被建立、更新或關閉 |
| `SPEC_REVIEW.md` 的 finding ID 在 verify 中保持穩定 | 同一問題在複審時換 ID，或新增原報告以外的 Minor／Suggestion |
| PR 降級審查不得呈現為完整審查或 `Approve` | 缺少 checks／comments／metadata 時仍建議 Approve |
| `skills/`、`core/` 與同步腳本是 source of truth | Adapter 手動修改、第二次 sync 仍有變更或 tree 比對失敗 |
| 不新增主要框架、package manager 或執行時依賴 | 安裝技能包時需要現有 Bash／可選 `gh` 以外的依賴 |

### Edge Cases

- 規格路徑不存在、來源改變、revision 不可識別或舊報告不屬於目前規格時，verify 停止並要求完整審查。
- 規格沒有相關 repo 或 UI 證據時，對應面向標示 `unverified`，不假設相容。
- 找到多個 PR、base branch 不明、shallow clone 缺少 base 或 working tree 會污染 diff 時，停止降級審查。
- PR checks 尚未完成時，記錄 pending 狀態，不視為通過或失敗。
- `gh` 未安裝、未登入、token scope 不足或 remote 與 repo 不一致時，不嘗試寫入。
- GitHub 寫入部分成功時，重新讀取狀態並逐項回報；不得整批重跑造成重複資源。
- 沒有 finding 時仍需列出審查範圍與證據，不得只輸出「LGTM」。
- 規格、PR 目標或必要輸入為空時停止並指出缺少欄位，不建立空報告或猜測目標。
- 在錯誤目錄執行、Git remote 不符或 repo 無法唯一辨識時停止，不依目錄名稱推定 GitHub repo。
- GitHub 操作中斷時先重新查詢資源狀態，再決定是否重試未完成步驟。
- Windows Git Bash、macOS 與 Linux 必須保留 UTF-8 中文、特殊符號與路徑；不得以平台專用文字解析作為必要流程。
- 重複執行 sync 必須冪等；重複執行 GitHub Create 不得產生重複資源。

### FROZEN

- 技能拓撲固定為 2 public＋1 internal；本規格實作不得改成三個公開入口或併回既有技能。
- `maze-spec-review` 唯讀且固定產生 `SPEC_REVIEW.md`；`maze-pr-review` 不產生持久文件且不寫遠端。
- `maze-github-cli` 首版只接 `maze-pr-review`、`maze-github-safe-ops`。
- 測試接縫固定為既有 Shell validators，不新增真實 GitHub 整合測試。
- 目前技能數固定為 27／24／3。
- 變更上述 FROZEN 決策時，必須同步更新本規格、`DECISIONS.md`、Router、canonical skill arrays、四個 Adapter 文件、validators 與 adaptive scenarios，不能只修改單一技能。

## Testing Decisions

### Test philosophy and seams

- 測試外部契約、路由結果、產物結構與安全邊界，不鎖定段落措辭或 Agent 的內部推理順序。
- 最高接縫沿用既有 Shell：結構 validator、功能契約 validator、adaptive scenarios；四個 Host Adapter 由 sync 後的 tree／metadata 比對覆蓋。
- 不新增 live GitHub fixture、測試 Issue／PR 或需要網路授權的整合測試。

### Structural validation

- `validate-skillpack.sh` 固定驗證 27 個 SKILL.md、24 public、3 internal；Router 必須包含公開技能且不得公開 `maze-github-cli`。
- 四個 Adapter 必須與 canonical resources 一致；Claude invocation metadata 必須正確轉譯。
- `SPEC_REVIEW.md` canonical template、根 template 與文件模型必須存在且同步。
- 所有 README、Harness、spec 與 validator 的技能數量必須一致。

### Functional contract validation

- `maze-spec-review` 必須包含六面向、穩定 ID、四級 finding、四種 verify 狀態、來源變更停止條件與禁止修改規格。
- `maze-pr-review` 必須包含 PR 證據來源、四級 finding、結論映射、降級限制、未發現問題區域與禁止遠端寫入。
- `maze-github-cli` 必須包含 auth／repo／remote 前置檢查、`--json`／`--jq`、非互動、Read／Create-Update／Destructive 分級、預覽確認與冪等失敗處理。
- `maze-github-safe-ops` 必須明示只有在使用者請求、預覽與確認後才委派 internal CLI。

### Test cases

| Test ID | 層次 | 驗證內容 | 自動化 | 通過門檻 | FROZEN |
|---|---|---|---|---|---|
| T-31-001 | 結構 | 27／24／3 計數、invocation、Router 與 Adapter tree | 是 | validator exit 0，internal 不出現在 Router | 是 |
| T-31-002 | 功能契約 | Spec review 六面向、finding、verify、唯讀邊界 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-31-003 | 功能契約 | PR review 證據、分級、降級、輸出與遠端唯讀 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-31-004 | 功能契約 | CLI 前置檢查、結構化輸出、操作分級、確認與冪等 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-31-005 | 文件／模板 | `SPEC_REVIEW.md` canonical／root template 與文件模型 | 是 | 檔案存在、必要章節存在且同步一致 | 是 |
| T-31-006 | 情境 | PR review、spec review 與 pre-implementation 情境共 26 scenarios | 是 | scenario validator exit 0 且指標不退化 | 是 |
| T-31-007 | 整合 | 四種 Adapter 同步與第二次 sync 冪等 | 是 | 第一次完成同步，第二次輸出 `no changes` | 是 |
| T-31-008 | 可攜性 | Shell syntax、UTF-8 內容與跨平台既有契約 | 是；Ubuntu runtime 依環境 | syntax／validator exit 0；無環境時明列未驗證 | 否 |

- 禁止以 `|| true`、忽略退出碼、弱化 assertion、刪除失敗案例或修改測試迎合錯誤輸出的方式取得通過。
- 不以 live GitHub 寫入替代 Shell 契約測試；外部狀態沒有測試環境時必須維持未驗證標示。

### Adaptive scenarios and token budget

- 將既有 `pr-review` scenario 的 entry skill 改為 `maze-pr-review`，allowed resources 包含 `maze-github-cli`，並保留「可定位 finding、不寫遠端、正確 Issue 關聯」契約。
- adaptive scenarios 目前共 26 個，涵蓋 review、pre-implementation、文件治理與既有代表性情境。
- SKILL.md 總字元上限固定為 22,000；詳細內容使用按需資源。
- 保留現有 adaptive 指標不得比 baseline 退化的檢查。

### Acceptance Criteria

- [x] AC-01：存在 `maze-spec-review` public skill，完整模式與 verify 模式符合本規格且不修改來源規格。
- [x] AC-02：`SPEC_REVIEW.md` template 包含結論、Findings、未決策事項、建議驗收條件、修訂順序、限制與來源識別。
- [x] AC-03：verify 保留 `SR-xxx` ID，只處理既有 Blocker／Major，來源或範圍大幅改變時停止。
- [x] AC-04：存在 `maze-pr-review` public skill，能取得完整 PR 證據或輸出明確受限的本地降級審查。
- [x] AC-05：PR review 的 finding、結論映射、測試缺口、未發現問題區域與限制符合本規格。
- [x] AC-06：PR review 不提交 review、不留言、不批准、不修改 PR／Issue／branch。
- [x] AC-07：存在 `maze-github-cli` internal skill，且只由 PR review 與 safe-ops 明示組合。
- [x] AC-08：唯讀 `gh` 可直接執行；Create／Update 與 Destructive 分別遵守預覽及確認契約。
- [x] AC-09：internal CLI 使用結構化、非互動輸出，並拒絕未允許的 `--admin`、強制合併與保護規則繞過。
- [x] AC-10：`maze-github-safe-ops` 的新委派契約不會自行發起 GitHub 寫入。
- [x] AC-11：canonical skills、public skills、internal skills 數量分別為 27、24、3，Router 不公開 internal skills。
- [x] AC-12：`SPEC_REVIEW.md` 納入文件模型與根 template 同步。
- [x] AC-13：adaptive scenarios 共 26 個，涵蓋 review、pre-implementation 與文件治理情境。
- [x] AC-14：三個新 SKILL.md 與全部 SKILL.md 總字元不超過指定上限。
- [x] AC-15：第一次 `bash scripts/sync-adapters.sh` 產生所需更新，第二次輸出 `no changes`。
- [x] AC-16：`validate-skillpack.sh`、`validate-skills-functional.sh`、`validate-adaptive-scenarios.sh`、Shell syntax 與 `git diff --check` 全數通過。
- [x] AC-17：README、Harness、Adapter README、spec、DECISIONS 與 NEXT_ACTION 不再保留衝突的技能數或 code-review checklist 待辦。

### AC automation mapping

- AC-01 至 AC-03 由 T-31-002／T-31-005 驗證；AC-04 至 AC-06 由 T-31-003／T-31-006 驗證。
- AC-07 至 AC-10 由 T-31-001／T-31-004 驗證；AC-11 至 AC-14 由 T-31-001／T-31-005／T-31-006 驗證。
- AC-15 至 AC-17 由 T-31-007／T-31-008 及 `git diff --check` 驗證。

## Out of Scope

- 本規格撰寫與發布階段不建立三個技能、不同步 Adapter、不發布新版本。
- 不讓 `maze-spec-review` 自動修改規格、決定產品方向、改架構或開始實作。
- 不讓 `maze-pr-review` 修復程式碼、寫入 GitHub review、留言、批准或 request changes。
- 不把一般未開 PR 的 working-tree code review 納入 `maze-pr-review`。
- 不執行完整安全稽核、滲透測試、完整 a11y、使用者研究或專用視覺設計審查。
- 不把 `maze-github-cli` 擴接至 `maze-spec-to-issues`、`maze-session-closeout` 或其他 GitHub-facing skills。
- 不建立完整 Git／GitHub 教學、不支援 Release／Project／Milestone 管理、不新增 live GitHub integration tests。
- 不新增主要依賴、框架或 package manager，不自動 commit、push、merge、release 或 deploy。

## Further Notes

### Dependencies and delivery order

- MCR-31-001 與 MCR-31-002 可獨立實作；MCR-31-003 依賴 internal CLI；MCR-31-004 最後整合並執行完整驗證。
- 規格發布為單一 `ready-for-agent` GitHub Issue；後續可由 `maze-spec-to-issues` 依上述 Task ID 拆分，但不在本規格發布階段建立子 Issues。

### Drift Risk

- Router、validator、README、Harness 與 Adapter README 皆含技能數常數，遺漏任一處會造成跨 Host 語意漂移。
- `maze-pr-review` 與 `maze-github-safe-ops` 都會引用 internal CLI；若各自重述命令安全規則，未來可能分歧，詳細命令模式應只存在 internal skill 的按需資源。
- verify 若未綁定來源規格與原 finding ID，容易演變成每次重跑都新增意見的無限審查。
- 目前 27 個 SKILL.md 共 20,028 字元；新增能力必須以按需資源控制常駐內容，總字元上限固定為 22,000。

### Existing baseline

- `pre-adaptive-refactor` 指向本機 commit `57459a1`：14 個技能共 9,174 字元；結構與功能驗證通過，Ubuntu 原生執行未驗證。
- v3.1 不改變「階段可調整，契約不可省略」原則，也不因新技能限制模型的探索、工具、平行與 Subagent 能力。

### Open Questions

- 無。技能拓撲、輸入、輸出、副作用、降級行為、測試接縫、token 上限、發布方式與首版整合範圍均已決定。
