# maze-coder 規格 v3.2 — Pre-Implementation 審查技能與文件治理

> 狀態：決策完成
> 規格日期：2026-07-24
> Canonical source：本文件

## Problem Statement

maze-coder 已能在實作後審查規格與 PR，但實作前仍缺少可重複使用的「證偽方案」「威脅與濫用面分析」「假設驅動根因診斷」流程；使用者若想在動工前挑戰方案、辨識信任邊界濫用途徑或收斂 bug 根因，仍需依賴一般對話而非固定的可驗收契約與輸出格式。

同時 `docs/STATUS.md` 與 `NEXT_ACTION.md`／`DECISIONS.md` 是追加式 session 流水帳：`STATUS.md` 重複記錄 GitHub Issue／PR 已有的狀態，`NEXT_ACTION.md` 每次 closeout 都疊加而非重建，`DECISIONS.md` 逐筆累積且理由與 ADR／Issue／PR 之間沒有強制連結。這些文件容易與 GitHub／Git 的實際狀態脫節，過期後反而誤導後續 session 的 agent（`maze-context-audit` 的核心風險）。

使用者需要在不新增 internal skill、不破壞既有 review 技能與一次只載入一個公開技能的前提下，取得可重複使用的實作前審查能力，並讓短期專案文件以 GitHub／Git 證據為權威、不再無限累積。

## Solution

新增三個 `user` invocation 的公開技能：`maze-adversarial-review`（實作前對方案、規格或架構決策做對抗性審查，結論限定為 `go`／`revise`／`stop`／`insufficient evidence`）、`maze-threat-modeling`（輕量威脅與濫用模型，找出跨信任邊界的濫用途徑並轉成可驗收的安全條件）、`maze-root-cause-diagnosis`（以候選假設、區辨實驗與反證收斂 bug 根因，禁止把症狀修補或單次相關性誤判為根因）。三者皆唯讀，不修改方案、不執行滲透測試或程式碼漏洞掃描、不直接修復程式碼。

同時退休 `STATUS.md`：`maze-project-init` 不再建立、`maze-session-closeout` 不再讀寫、`maze-context-audit` 忽略外部既有檔案但不自動刪除。`NEXT_ACTION.md` 改為短期快照，只有使用者明確要求 closeout 時才整體重建（一項下一階段成果、最多三項動作、阻塞／待決策與必要權威連結），不得追加歷史。`DECISIONS.md` 改為有效決策索引，每筆僅一行摘要、狀態與唯一權威來源（ADR、Issue 或 PR 連結），取代或失效時更新或移除，不追加。

完成後 maze-coder 共有 27 個 canonical skills：24 個公開或可由模型觸發的技能、3 個 internal skills（較 v3.1 的 24／21／3 增加三個公開技能，internal 數量不變）。

### Success metrics

- AC-01 至 AC-13 全數成立，沒有 `unverifiable` 的完成宣告。
- 三支 validator、Shell syntax 與 `git diff --check` exit 0；第二次 sync 明確輸出 `no changes`。
- 26 個 adaptive scenarios 全數通過且估計指標不比 baseline 退化。
- 全部 SKILL.md 總字元低於 22,000（不記錄瞬時總字元數，避免隨後續技能增減立即失準）。
- `docs/spec.md` 不含任何前一版本遺留的技能數、情境數或字元上限字串。

## User Stories

1. 身為方案作者，我希望在投入實作前有人以證偽為目標挑戰核心假設，而不是只確認方案「聽起來合理」。
2. 身為維護者，我希望對抗性審查揭露 reviewer 是否獨立於方案形成過程，以判斷結論的可信度。
3. 身為設計仍可調整的技術負責人，我希望在動工前找出跨信任邊界的濫用途徑，把它們轉成規格裡的驗收條件，而不是實作完成後才做安全稽核。
4. 身為除錯者，我希望有一個以假設與可反證區辨實驗收斂根因的流程，避免把「錯誤暫時消失」誤判為「已修好」。
5. 身為使用者，我希望 `NEXT_ACTION.md` 只反映目前真正要做的少量事項，而不是每次 closeout 都疊加成一份無法閱讀的歷史紀錄。
6. 身為稽核 agent context 的使用者，我希望 `maze-context-audit` 以 Git／GitHub 證據判斷現況，而不是信任可能過期的 `STATUS.md`。
7. 身為技能包維護者，我希望 `DECISIONS.md` 只保留仍有效、有唯一權威來源的決策，避免過期理由與目前程式碼行為脫鉤卻無人察覺。

## Implementation Decisions

### Existing architecture contract

以下 v3.0／v3.1 契約維持 FROZEN，v3.2 只加入本規格明定的能力：

- `core/invariants.md` 保存授權、範圍、外部寫入與真實驗證等不可省略規則。
- `core/workflow-model.md` 依能力選擇 `minimal → standard → scaffolded` Guidance Profile，只有觀察到具體失敗才加強。
- `profiles/` 提供 Guidance；`model-overlays/` 只修正已知模型偏差，不複製技能或 Profile。
- `skills/` 是 canonical skills 與按需資源的唯一 source of truth；Adapter 只翻譯路徑、路由與 Host metadata。
- `invocation` 只允許 `user`、`model`、`both`、`internal`。Router 不公開 internal skills；入口技能只有在自身契約明示時才能組合 internal skill。
- 每次意圖只路由一個最相關公開技能；references、templates、checklists 與 internal skill 依需要載入。
- `maze-grill`、`maze-grill-with-docs`、`maze-grilling` 與 `maze-domain-modeling` 的逐題、查證、收斂、文件與 ADR 門檻不變。
- `maze-spec-to-issues` 的 Dry Run、穩定 task-id、Parent／Sub-issue、優先級、Assignee 與寫入確認契約不變。
- `maze-spec-review`、`maze-pr-review`、`maze-github-cli` 的完整契約（規格 v3.1，已封存於 git 歷史）不變。
- v3.1 完成時 `maze-session-closeout` 只同步 `STATUS.md` 與 `NEXT_ACTION.md`；本版修改此契約，見下方「文件治理契約」。
- 可攜性仍定義為複製目錄即可使用；同步與驗證只依賴 Bash、find、grep 等既有工具，支援 macOS、Linux 與 Windows Git Bash。
- `gh` 是 GitHub 操作時的可選外部工具；命令必須支援所用的 `--json`／`--jq` 旗標，否則停止並回報，不降級解析表格文字。

### Skill topology and routing

| Skill | Invocation | Router intent | Direct consumers |
|---|---|---|---|
| `maze-adversarial-review` | `user` | 實作前挑戰方案／找反證 | 使用者 |
| `maze-threat-modeling` | `user` | 實作前威脅模型／濫用分析 | 使用者 |
| `maze-root-cause-diagnosis` | `user` | Bug 根因診斷 | 使用者 |

- 目前總數固定為 27：24 public／model-visible、3 internal（較 v3.1 的 24／21／3 增加三個公開技能，internal 數量不變，不新增 internal skill）。
- 三個新技能皆唯讀；不修改被審查的方案、規格或程式碼，也不自動開始實作或修復。

### `maze-adversarial-review` contract

- 取得待審方案、決策目標、已知證據與限制；缺少足以辨識核心主張的內容時停止並要求補充。
- 優先由未參與方案形成的獨立 agent 執行；降級為同一 agent 執行時，報告必須揭露 reviewer 不獨立及 framing bias 風險。
- 明列核心主張、隱藏假設、可推翻條件；針對高代價、難回復或證據最弱的主張設計反例與最小反證查核；公平提出至少一個有力替代方案，不存在時記錄搜尋範圍。
- 結論只能是 `go`、`revise`、`stop` 或 `insufficient evidence`；`go` 只代表在已列攻擊範圍內未找到阻止方案的證據，不代表方案已被證明正確。
- 唯讀；不修改原方案、不開始實作、不替使用者承擔產品決策。

### `maze-threat-modeling` contract

- 取得系統目的、資料流、外部整合、身分／權限模型及部署邊界；缺少內容標為未驗證，不自行假設安全。
- 盤點資產、信任邊界、入口與具權限操作；描述攻擊者能力與目標；沿資料流建立具體濫用途徑；依影響、可行性與現有控制排序威脅。
- 輸出範圍、資產與信任邊界、攻擊者、優先威脅與濫用途徑、緩解措施、未驗證假設與安全條件；證據不足時明列需要補充的資料，不宣稱系統安全。
- 不執行程式碼漏洞掃描、滲透測試或完整 security audit；不主動利用真實系統。

### `maze-root-cause-diagnosis` contract

- 取得已驗證的問題行為與最小重現；尚不能穩定重現時先使用 `maze-bug-reproduction`。
- 依證據列出候選假設與可觀察預測；選擇最能區分假設的最小區辨實驗，一次只改變可追蹤因素；記錄實驗與觀察結果，不以單次相關性升級結論。
- 只有操控該因素能穩定觸發或消除症狀，且排除至少一個有力替代假設時，才標示為已證實根因；證據不足時只稱候選根因並提供下一個最小區辨實驗。
- 不修復程式碼、不用大量隨機修改取代區辨實驗；實驗可能破壞資料或需要新權限時，停止並取得明確授權。

### Document governance contract

- `STATUS.md` 已退休：`maze-project-init` 不建立；`maze-session-closeout` 不讀寫；`maze-context-audit` 忽略外部既有檔案，但不自動刪除使用者專案中的舊檔。
- `maze-session-closeout` 以 GitHub／Git 為工作狀態權威；僅在使用者明確要求 closeout 時，才以目前證據整體重建 `NEXT_ACTION.md`（一項下一階段成果、最多三項動作、阻塞／待決策與必要權威連結），不得追加、不寫 `STATUS.md`、不複製完整 Issue／PR 狀態。
- `DECISIONS.md` 只保留仍有效、難以逆轉的決策；每筆僅一行摘要、狀態與唯一權威來源（ADR、Issue 或 PR 連結），取代或失效時更新或移除，不追加。
- 普通、易逆轉的實作選擇（例如可由測試保護、可直接改程式碼復原的決策）不得進入 `DECISIONS.md`；理由改放在 `core/PRINCIPLES.md`、測試名稱或程式註解，ADR 僅保留給難以逆轉、缺乏背景將無法理解且存在有意義替代方案與取捨的決策（門檻定義於 `core/DOCUMENT_MODEL.md`，三項須同時成立）。

### Work items

| Task ID | 正式狀態 | Priority | 目標 | 依賴 |
|---|---|---|---|---|
| MCR-32-001 | 正式 | P1 | 建立 `maze-adversarial-review` 唯讀證偽技能 | 無 |
| MCR-32-002 | 正式 | P1 | 建立 `maze-threat-modeling` 輕量威脅模型技能 | 無 |
| MCR-32-003 | 正式 | P1 | 建立 `maze-root-cause-diagnosis` 假設驅動根因診斷技能 | 無 |
| MCR-32-004 | 正式 | P1 | 退休 `STATUS.md`，改寫 `NEXT_ACTION.md`／`DECISIONS.md` 為證據驅動索引契約 | 無 |
| MCR-32-005 | 正式 | P1 | 整合 Router、canonical skill arrays、四個 Adapter、validators 與 adaptive scenarios | MCR-32-001、MCR-32-002、MCR-32-003、MCR-32-004 |

### Contract

- 三個新技能唯讀，不得修改被審查的方案、規格或程式碼。
- `maze-adversarial-review` 的結論只能是 `go`／`revise`／`stop`／`insufficient evidence`；`maze-threat-modeling` 不得宣稱系統安全；`maze-root-cause-diagnosis` 未達證實門檻時只能稱候選根因。
- `DECISIONS.md` 每筆的唯一權威來源必須是 ADR、Issue 或 PR 連結，不得指向會持續變動的一般文件（如整份 `spec.md`）。
- `NEXT_ACTION.md` 只在使用者明確要求 closeout 時整體重建，不得逐次追加。
- Adapter 必須完整包含 27 個 canonical skills，且 internal skill 不得出現在公開 Router。
- 未通過本規格 Acceptance Criteria 與適用驗證時，不得宣告 v3.2 完成。

### Invariants

| Invariant | 違反時的可觀察症狀 |
|---|---|
| 三個新技能不修改被審查來源、不開始實作 | 方案、規格或程式碼在審查後被技能本身變更 |
| `maze-adversarial-review` 結論限定四種狀態 | 報告出現「大致沒問題」等未定義結論 |
| `NEXT_ACTION.md` 只在明確 closeout 時整體重建 | 一般回報或籠統收尾語也觸發改寫 `NEXT_ACTION.md` |
| `DECISIONS.md` 僅索引 ADR／Issue／PR | 出現指向整份文件或無版本錨點的「權威來源」 |
| `docs/spec.md` 與 README、Harness、validator 的技能數量一致 | 任一處技能數量與其他處不同 |
| `skills/`、`core/` 與同步腳本是 source of truth | Adapter 手動修改、第二次 sync 仍有變更或 tree 比對失敗 |

### Edge Cases

- 待審方案證據不足以辨識核心主張時，`maze-adversarial-review` 停止並要求補充，不得虛構問題湊數。
- 威脅模型缺少資料流或權限模型時，`maze-threat-modeling` 標示未驗證，不假設系統安全。
- 只有相關性、尚未排除替代假設時，`maze-root-cause-diagnosis` 不得宣稱已找到根因，即使症狀修補後測試通過。
- 使用者說出籠統收尾語（例如「先到這裡」「更新一下狀態」）但未明確要求 closeout 時，`maze-session-closeout` 只回報現況，不改寫 `NEXT_ACTION.md`。
- `DECISIONS.md` 的決策失效或被取代時，更新或移除該列，不保留過期理由。
- 重複執行 sync 必須冪等；重複執行 GitHub Create 不得產生重複資源。

### FROZEN

- 本版新增技能拓撲固定為 3 public、0 internal；不得改成 internal skill 或併回既有技能。
- 三個新技能唯讀邊界（不修改來源、不開始實作、不修復程式碼）不得放寬。
- `STATUS.md` 不得由任何 canonical skill 或根模板重新建立。
- `NEXT_ACTION.md`／`DECISIONS.md` 的重建與索引門檻（僅明確 closeout 重建、僅 ADR／Issue／PR 索引）不得放寬為自動追加。
- 目前技能數固定為 27／24／3。
- 變更上述 FROZEN 決策時，必須同步更新本規格、`DECISIONS.md`、Router、canonical skill arrays、四個 Adapter 文件、validators 與 adaptive scenarios，不能只修改單一技能。

## Testing Decisions

### Test philosophy and seams

- 測試外部契約、路由結果、產物結構與安全邊界，不鎖定段落措辭或 Agent 的內部推理順序。
- 最高接縫沿用既有 Shell：結構 validator、功能契約 validator、adaptive scenarios；四個 Host Adapter 由 sync 後的 tree／metadata 比對覆蓋。
- 不新增 live GitHub fixture、測試 Issue／PR 或需要網路授權的整合測試。

### Structural validation

- `validate-skillpack.sh` 固定驗證 27 個 SKILL.md、24 public、3 internal；`STATUS.md` 不得出現在 `docs/`、`templates/` 或 `skills/maze-project-init/templates/`。
- `docs/spec.md` 不得含有前一版本遺留的技能數、情境數或字元上限字串（自我一致性檢查），且必須標示目前技能拓撲與 adaptive scenarios 數量。
- `docs/DECISIONS.md` 每一列的唯一權威來源必須是 `adr/` 相對連結或 GitHub Issue／PR 連結。
- 四個 Adapter 必須與 canonical resources 一致；Claude invocation metadata 必須正確轉譯。

### Functional contract validation

- `maze-adversarial-review` 必須包含核心主張／隱藏假設／可推翻條件、限定的四種結論、reviewer 獨立性揭露與唯讀邊界。
- `maze-threat-modeling` 必須包含資產／信任邊界／攻擊者／濫用途徑／緩解的核心分析面、輸出契約與不越界掃描的邊界。
- `maze-root-cause-diagnosis` 必須包含候選假設／預測／區辨實驗／觀察結果／替代假設的收斂流程、證實門檻與禁止症狀修補誤判。
- `maze-session-closeout` 必須明示僅在明確 closeout 時整體重建 `NEXT_ACTION.md`、不追加、不寫 `STATUS.md`。
- `maze-project-init` 必須明示不建立 `STATUS.md`；`maze-context-audit` 必須明示忽略外部既有 `STATUS.md`。

### Test cases

| Test ID | 層次 | 驗證內容 | 自動化 | 通過門檻 | FROZEN |
|---|---|---|---|---|---|
| T-32-001 | 結構 | 27／24／3 計數、STATUS.md 退休、spec 自我一致性 | 是 | validator exit 0，無殘留舊計數字串 | 是 |
| T-32-002 | 功能契約 | Adversarial review 核心主張、限定結論、獨立性揭露、唯讀邊界 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-32-003 | 功能契約 | Threat modeling 核心分析面、輸出、不越界掃描 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-32-004 | 功能契約 | Root cause diagnosis 收斂流程、證實門檻、禁止症狀修補誤判 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-32-005 | 文件治理 | closeout 明確授權整體重建、project-init／context-audit 的 STATUS 契約、DECISIONS 僅索引 ADR／Issue／PR | 是 | 所有必要契約 pattern 存在 | 是 |
| T-32-006 | 情境 | pre-implementation 與文件治理情境併入 adaptive scenarios，共 26 個 | 是 | scenario validator exit 0 且指標不退化 | 是 |
| T-32-007 | 整合 | 四種 Adapter 同步與第二次 sync 冪等 | 是 | 第一次完成同步，第二次輸出 `no changes` | 是 |
| T-32-008 | 可攜性 | Shell syntax、UTF-8 內容與跨平台既有契約 | 是；Ubuntu runtime 依環境 | syntax／validator exit 0；無環境時明列未驗證 | 否 |

- 禁止以 `|| true`、忽略退出碼、弱化 assertion、刪除失敗案例或修改測試迎合錯誤輸出的方式取得通過。
- 不以 live GitHub 寫入替代 Shell 契約測試；外部狀態沒有測試環境時必須維持未驗證標示。

### Adaptive scenarios and token budget

- 移除已被本版取代的 `session-closeout` 舊情境，新增 `adversarial-success`／`adversarial-insufficient`／`adversarial-time-pressure`、`threat-success`／`threat-insufficient`／`threat-time-pressure`、`diagnosis-success`／`diagnosis-insufficient`／`diagnosis-time-pressure`、`feature-complete-no-docs`、`explicit-closeout`、`legacy-status`、`decision-index`、`repeat-closeout`，總數為 26。
- SKILL.md 總字元上限固定為 22,000；詳細內容使用按需資源，不記錄瞬時總字元數。
- 保留現有 adaptive 指標不得比 baseline 退化的檢查。

### Acceptance Criteria

- [x] AC-01：存在 `maze-adversarial-review`、`maze-threat-modeling`、`maze-root-cause-diagnosis` 三個公開技能，皆為 `invocation: user` 且唯讀。
- [x] AC-02：`maze-adversarial-review` 結論只能是 `go`／`revise`／`stop`／`insufficient evidence`，且報告揭露 reviewer 獨立性。
- [x] AC-03：`maze-threat-modeling` 輸出資產、信任邊界、攻擊者、優先威脅、緩解與安全條件，且不執行程式碼掃描或滲透測試。
- [x] AC-04：`maze-root-cause-diagnosis` 只有排除至少一個有力替代假設且能穩定觸發／消除症狀時才宣稱根因；證據不足時只稱候選根因。
- [x] AC-05：`STATUS.md` 不再由 `maze-project-init` 建立、`maze-session-closeout` 不讀寫，且不出現於 `docs/`、`templates/` 或 `skills/maze-project-init/templates/`。
- [x] AC-06：`maze-session-closeout` 僅在使用者明確要求 closeout 時整體重建 `NEXT_ACTION.md`；不追加歷史、不寫 `STATUS.md`。
- [x] AC-07：`DECISIONS.md` 只保留仍有效決策，且每筆的唯一權威來源必須是 ADR、Issue 或 PR 連結。
- [x] AC-08：canonical／public／internal skills 數量分別為 27、24、3，Router 不公開 internal skills。
- [x] AC-09：adaptive scenarios 共 26 個，涵蓋 pre-implementation 與文件治理情境，且指標不比 baseline 退化。
- [x] AC-10：全部 SKILL.md 總字元低於 22,000。
- [x] AC-11：第一次 `bash scripts/sync-adapters.sh` 產生所需更新，第二次輸出 `no changes`。
- [x] AC-12：三支 validator、Shell syntax 與 `git diff --check` 全數通過。
- [x] AC-13：`docs/spec.md` 不含任何前一版本遺留的技能數、情境數或字元上限字串。

### AC automation mapping

- AC-01 至 AC-04 由 T-32-002／T-32-003／T-32-004 驗證。
- AC-05 至 AC-07 由 T-32-001／T-32-005 驗證。
- AC-08 至 AC-10 由 T-32-001／T-32-006 驗證。
- AC-11 至 AC-13 由 T-32-007／T-32-008 及 `git diff --check` 驗證。

## Out of Scope

- 不新增 internal skill；三個新技能均為公開 `user` invocation。
- 不讓三個新技能修改被審查的方案、規格或程式碼，也不自動開始實作或修復。
- 不為 `STATUS.md` 提供自動遷移或匯出工具；退休只影響 canonical 與根模板，使用者專案既有檔案不強制刪除。
- 不把 `DECISIONS.md` 的歷史決策詳情遷回文件本身；理由只透過 ADR、Issue、PR 或 `core/PRINCIPLES.md` 追溯，過期理由留在 git 歷史。
- 不執行完整安全稽核、滲透測試或程式碼漏洞掃描。
- 不新增主要依賴、框架或 package manager，不自動 commit、push、merge、release 或 deploy。

## Further Notes

### Dependencies and delivery order

- MCR-32-001 至 MCR-32-004 可獨立實作；MCR-32-005 最後整合並執行完整驗證。

### Drift Risk

- Router、validator、README、Harness 與 Adapter README 皆含技能數常數，遺漏任一處會造成跨 Host 語意漂移。
- `docs/spec.md` 若混雜歷史版本的計數與目前值，會讓後續 agent 誤判現況；每次版號變更都必須整份取代舊版內容，而非只置換數字。
- SKILL.md 總字元只設上限、不記錄瞬時總數，避免文件在下次技能異動後立即漂移。

### Existing baseline

- v3.1 基準：27／24／3 之前為 24／21／3，26 個 adaptive scenarios 之前為 13 個；細節見 git 歷史中的 v3.1 版本 `docs/spec.md`。
- v3.2 不改變「階段可調整，契約不可省略」原則，也不因新技能限制模型的探索、工具、平行與 Subagent 能力。

### Open Questions

- 無。技能拓撲、輸入、輸出、副作用、降級行為、測試接縫、token 上限、發布方式與本版整合範圍均已決定。
