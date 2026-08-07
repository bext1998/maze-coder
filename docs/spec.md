# maze-coder 規格 v3.4 — maze-explain-for-dumbass 講人話技能

> 狀態：決策完成（v1 範圍）
> 規格日期：2026-08-08
> Canonical source：本文件

## Problem Statement

AI agent（不分模型）在 RL 訓練後有「說人話」能力退化的傾向：明明是件簡單的事，卻用一堆抽象術語、被動語態、流程敘述包裝，導致使用者要花時間反推 agent 到底做了什麼、有沒有出錯、接下來要做什麼。maze-coder 目前沒有任何技能處理這個問題——既有技能都聚焦在產出正確的技術結果，沒有一個處理「結果正確但講法讓人聽不懂」的情境。

使用者需要在不重跑任務、不改變原始技術結論的前提下，取得一個可重複觸發的重寫能力：把已經講完的技術性回覆，重新表達成連外行都聽得懂的版本，同時保留所有不可簡化的具體資訊（檔案路徑、指令、版本號、錯誤碼、API／函式名、環境變數）。

## Solution

新增一個 `both` invocation 的公開技能 `maze-explain-for-dumbass`：不委派任何既有技能，單一 `SKILL.md` 檔案，內容量小、不需要 `references/`／`templates/`／`checklists/` 子目錄。觸發時只重寫最近一則回覆的措辭，不重新執行任務、不產生新結論，避免第二次答案跟第一次結論不一致。

語言無關，正體中文／英文／日文皆適用；不依賴任何受控語言字彙表（例如 ASD-STE100，該規範本質上綁定英語詞彙表，對非拉丁語系使用者不友善）。

完成後 maze-coder 共有 29 個 canonical skills：26 個公開或可由模型觸發的技能、3 個 internal skills（較 v3.3 的 28／25／3 增加一個公開技能，internal 數量不變）。

### Success metrics

- AC-01 至 AC-06 全數成立，沒有 `unverifiable` 的完成宣告。
- 三支 validator、Shell syntax 與 `git diff --check` exit 0；第二次 sync 明確輸出 `no changes`。
- `maze-explain-for-dumbass/SKILL.md` 字元數低於 3,000 建議值；全部 SKILL.md 總字元低於 22,000 硬上限。
- `docs/spec.md` 不含任何前一版本遺留的技能數字串。

## User Stories

1. 身為使用者，我看到 agent 回覆一段用術語包裝的技術敘述時，我希望說一句「講人話」就能得到重講版本，而不用重新問一次問題。
2. 身為使用者，我希望重講版本裡的檔案路徑、指令、錯誤碼跟原文一字不差，這樣我還是能照著操作，不會因為簡化而漏掉關鍵資訊。
3. 身為使用者，我希望重講版本第一句話就是結論，不用先看完一段過程敘述才知道 agent 做了什麼。
4. 身為維護者，我希望這個技能只在使用者明確發出訊號後才觸發，不常駐監控每一則回覆，避免簡短回覆也被套模板變囉唆。

## Implementation Decisions

### Existing architecture contract

以下 v3.0–v3.3 契約維持 FROZEN，v3.4 只加入本規格明定的能力：

- `core/invariants.md` 保存授權、範圍、外部寫入與真實驗證等不可省略規則。
- `core/workflow-model.md` 依能力選擇 `minimal → standard → scaffolded` Guidance Profile，只有觀察到具體失敗才加強。
- `profiles/` 提供 Guidance；`model-overlays/` 只修正已知模型偏差，不複製技能或 Profile。
- `skills/` 是 canonical skills 與按需資源的唯一 source of truth；Adapter 只翻譯路徑、路由與 Host metadata。
- `invocation` 只允許 `user`、`model`、`both`、`internal`。Router 不公開 internal skills；入口技能只有在自身契約明示時才能組合 internal skill。
- 每次意圖只路由一個最相關公開技能；references、templates、checklists 與 internal skill 依需要載入。
- v3.3 新增的 `maze-wayfinder` 契約（規格 v3.3，已封存於 git 歷史）不變。
- 可攜性仍定義為複製目錄即可使用；同步與驗證只依賴 Bash、find、grep 等既有工具，支援 macOS、Linux 與 Windows Git Bash。

### Skill topology and routing

| Skill | Invocation | Router intent | Direct consumers |
|---|---|---|---|
| `maze-explain-for-dumbass` | `both` | 對方聽不懂、要求講人話 | 使用者 |

- 目前總數固定為 29：26 public／model-visible、3 internal（較 v3.3 的 28／25／3 增加一個公開技能，internal 數量不變，不新增 internal skill）。
- `maze-explain-for-dumbass` 不委派其他技能，單一檔案運作，不依賴其他技能的輸出契約。

### `maze-explain-for-dumbass` contract

- 使用者說「講人話」「所以呢」「蛤」「聽不懂」或明確表達聽不懂剛才的技術敘述時才觸發；沒有明確前一則可簡化的技術性回覆時不適用。
- 只重寫最近一則回覆的措辭，不重新執行任務、不產生新結論；新舊版本結論必須一致。
- 檔案路徑、指令、版本號、錯誤碼、API／函式名、環境變數一律原樣保留，不得意譯或省略。
- 輸出結構固定：一句話結論（含具體對象）→ 2-4 句白話說明 →（需要行動時）「你現在要做的」區塊 → `<details>` 摺疊保留技術細節原文。
- 不用於 spec.md、ADR 等需要精確措辭的正式文件產出；不做情緒安撫或客套話；不為口語化犧牲技術正確性。

### Work items

| Task ID | 正式狀態 | Priority | 目標 | 依賴 |
|---|---|---|---|---|
| MCR-34-001 | 正式 | P2 | 建立 `maze-explain-for-dumbass` 技能（單一 `SKILL.md`） | 無 |
| MCR-34-002 | 正式 | P2 | 整合 Router、canonical skill arrays、五個 Adapter、validators | MCR-34-001 |

### Contract

- `maze-explain-for-dumbass` 不得修改原回覆的技術結論，只能重新表達。
- 原始回覆中出現的檔名／指令／錯誤碼，須 100% 原樣出現在簡化版裡。
- Adapter 必須完整包含 29 個 canonical skills，且 internal skill 不得出現在公開 Router。
- 未通過本規格 Acceptance Criteria 與適用驗證時，不得宣告 v3.4 完成。

### Invariants

| Invariant | 違反時的可觀察症狀 |
|---|---|
| 不重新執行任務、不產生新結論 | 簡化版結論與原回覆不一致，或觸發後出現原回覆沒有的新技術動作 |
| 不可簡化清單一律保留 | 原回覆中的檔名／指令／錯誤碼在簡化版中消失或被意譯 |
| `docs/spec.md` 與 README、Harness、validator 的技能數量一致 | 任一處技能數量與其他處不同 |
| `skills/`、`core/` 與同步腳本是 source of truth | Adapter 手動修改、第二次 sync 仍有變更或 tree 比對失敗 |

### Edge Cases

- 沒有明確的前一則技術性回覆可簡化時（例如對話剛開始），技能不觸發，如實告知沒有可簡化的內容。
- 使用者要求簡化的是 spec.md／ADR 等正式文件產出時，技能拒絕並說明這類文件需要精確措辭。
- 原回覆本身已經很短、很白話時，重寫後可能與原文差異很小；不強制為了輸出結構而灌水。

### FROZEN

- 不重做任務、不改變原本技術結論的邊界不得放寬。
- 不可簡化清單（檔案路徑、指令、版本號、錯誤碼、API／函式名、環境變數）不得放寬省略。
- 目前技能數固定為 29／26／3。
- 變更上述 FROZEN 決策時，必須同步更新本規格、Router、canonical skill arrays、五個 Adapter 文件與 validators，不能只修改單一技能。

## Testing Decisions

### Test philosophy and seams

- 測試外部契約、路由結果、產物結構與安全邊界，不鎖定段落措辭或 Agent 的內部推理順序。
- 最高接縫沿用既有 Shell：結構 validator、功能契約 validator；五個 Host Adapter 由 sync 後的 tree／metadata 比對覆蓋。
- 不新增 live GitHub fixture、測試 Issue／PR 或需要網路授權的整合測試。

### Structural validation

- `validate-skillpack.sh` 固定驗證 29 個 SKILL.md、26 public、3 internal。
- `docs/spec.md` 不得含有前一版本遺留的技能數字串（自我一致性檢查），且必須標示目前技能拓撲。
- 五個 Adapter 必須與 canonical resources 一致；Claude invocation metadata 必須正確轉譯。

### Functional contract validation

- `maze-explain-for-dumbass` 必須包含不可簡化清單、輸出結構與「不重做任務」邊界。

### Test cases

| Test ID | 層次 | 驗證內容 | 自動化 | 通過門檻 | FROZEN |
|---|---|---|---|---|---|
| T-34-001 | 結構 | 29／26／3 計數、spec 自我一致性 | 是 | validator exit 0，無殘留舊計數字串 | 是 |
| T-34-002 | 功能契約 | `maze-explain-for-dumbass` 不可簡化清單、輸出結構、不重做任務邊界 | 是 | 所有必要契約 pattern 存在 | 是 |
| T-34-003 | 整合 | 五種 Adapter 同步與第二次 sync 冪等 | 是 | 第一次完成同步，第二次輸出 `no changes` | 是 |

- 禁止以 `|| true`、忽略退出碼、弱化 assertion、刪除失敗案例或修改測試迎合錯誤輸出的方式取得通過。

### Adaptive scenarios and token budget

- `tests/adaptive-scenarios.tsv` 是固定 26 列的代表性情境樣本，本來就不是每個技能對應一列；本版不新增列，維持 26 個。
- SKILL.md 總字元上限固定為 22,000；詳細內容使用按需資源，不記錄瞬時總字元數。

### Acceptance Criteria

- [x] AC-01：存在 `maze-explain-for-dumbass` 公開技能，`invocation: both`。
- [x] AC-02：不可簡化清單（檔案路徑、指令、版本號、錯誤碼、API／函式名、環境變數）明示保留，不得意譯或省略。
- [x] AC-03：輸出結構明示——一句話結論、白話說明、視需要的行動區塊、摺疊保留的技術細節原文。
- [x] AC-04：canonical／public／internal skills 數量分別為 29、26、3，Router 不公開 internal skills。
- [x] AC-05：第一次 `bash scripts/sync-adapters.sh` 產生所需更新，第二次輸出 `no changes`。
- [x] AC-06：三支 validator、Shell syntax 與 `git diff --check` 全數通過。

### AC automation mapping

- AC-01 至 AC-03 由 T-34-002 驗證。
- AC-04 至 AC-06 由 T-34-001／T-34-003 及 `git diff --check` 驗證。

## Out of Scope

- 不新增 internal skill；`maze-explain-for-dumbass` 為公開 `both` invocation。
- 不做常駐監控模式，只在使用者明確訊號後事後觸發。
- 不做懂度分級（L1 完全外行／L2 懂程式但不熟此領域／L3 熟手速掃）；v1 只有單一簡化版本。
- 不接專案術語表（比照 JRA glossary 模式）。
- 不做理解力驗證機制（讀後三題測驗）。
- 上述四項留待後續版本依實際使用回饋決定，本版不預先假設答案。
- 不自動 commit、push、merge、release 或 deploy。

## Further Notes

### Dependencies and delivery order

- MCR-34-001 完成後才能開始 MCR-34-002 的整合與驗證。

### Drift Risk

- Router、validator、README、Harness 與 Adapter README 皆含技能數常數，遺漏任一處會造成跨 Host 語意漂移。
- `docs/spec.md` 若混雜歷史版本的計數與目前值，會讓後續 agent 誤判現況；每次版號變更都必須整份取代舊版內容，而非只置換數字。

### Existing baseline

- v3.3 基準：28／25／3，之前為 27／24／3；26 個 adaptive scenarios 維持不變；細節見 git 歷史中的 v3.3 版本 `docs/spec.md`。
- v3.4 不改變「階段可調整，契約不可省略」原則，也不因新技能限制模型的探索、工具、平行與 Subagent 能力。

### Open Questions

- 常駐模式 vs 事後觸發：已決定為事後觸發，見 Out of Scope。
- 懂度分級、術語表整合、理解力驗證機制三項：v1 明確排除，非本版待決事項，需要時另開後續規格。
