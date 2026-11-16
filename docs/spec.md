# maze-coder 規格 v4.0 — 原生 Agent Skills 集合

> 狀態：決策完成（架構簡化，Issues #59／#58）
> 規格日期：2026-11-17
> Canonical source：本文件

## Problem Statement

v3.x 以自適應 Harness 為設計核心：共用契約檔、三級 Guidance Profile、Model Overlay、五套 Host Adapter，以及維持它們一致的同步腳本與驗證器。這套機制帶來三類成本：

- **重複儲存**：技能內容在來源目錄與各 Adapter 之間保存多份，任何修改都要靠同步腳本收斂。
- **技能耦合**：技能被要求先讀一份不是它自己的契約檔，個別技能無法獨立安裝與理解。
- **維護面擴散**：新增或移除技能要同步 Router、同步腳本、計數與驗證器；而 Profile／Overlay 的效益缺乏證據。

同時，Coding Agent 本身已原生支援 Agent Skills（`SKILL.md` / `description` / 按需資源），繼續自建探索與載入機制屬於重複抽象。

## Solution

把 maze-coder 收斂成一個純粹的 Agent Skills 集合：

- `skills/` 是唯一來源，直接安裝到各 host 原生的技能目錄。
- 沒有 Adapter、沒有 Guidance Profile、沒有 Model Overlay、沒有同步腳本，也沒有生成物。
- 每個技能自帶 `references/`、`templates/`、`checklists/`、`examples/`，按需載入。
- 安裝只剩「把目錄放到 host 會掃描的位置」；repo 提供一支 symlink 安裝腳本，也接受手動複製。

核心原則：**讓模型發揮能力，讓技能提供專長；只約束必要的結果與邊界，不干涉不必要的執行過程。**

## Architecture contract

### Source of truth

- `skills/<skill-name>/` 是技能的唯一來源，不存在任何由腳本產生的副本。
- 技能的輔助資源只放在自己的 `references/`、`templates/`、`checklists/`、`examples/`，不複製到 repo 根目錄。
- `docs/` 只記錄本 repo 自身的規格、專案說明與決策紀錄。

### Frontmatter

`SKILL.md` 的 frontmatter 只允許三個欄位：

| 欄位 | 必要性 | 說明 |
|---|---|---|
| `name` | 必要 | 必須等於目錄名 |
| `description` | 必要 | 說明「做什麼」與「何時使用」；觸發詞前置 |
| `disable-model-invocation` | 選用 | 值只接受 `true`；表示只能由使用者明示呼叫 |

技能的觸發類別只有兩種：

- **使用者觸發**：帶 `disable-model-invocation: true`，模型不得自行選用。
- **使用者＋模型**：不加該欄位，模型可依 description 自行載入。

不得再引入自訂的觸發類別欄位；host 不認得的欄位語意無法保證。

### 資源引用

- 技能內的相對路徑以**技能根目錄**為基準（`references/…`、`templates/…`）。
- 會被其他技能跨技能載入的 reference，內部相對路徑同樣以所屬技能根目錄為基準，並在檔案開頭寫明這個基準。
- 跨技能引用用 `../maze-X/…` 形式，且必須在引用端 SKILL.md 寫明「需要同時安裝 `maze-X`」。
- 任何 `../` 參照解析後都必須仍位於 `skills/` 之內。

### 安裝

- 安裝 = 讓技能目錄出現在 host 會掃描的技能路徑下；不改變技能內容。
- `scripts/install-skills.sh` 只建立 symlink，支援 `--host`（claude、codex、cursor、pi、opencode、agents）、`--scope`（user／project）與技能名稱清單；不提供覆蓋選項，也不提供複製模式。
- 位置參數只接受 `skills/` 直接子目錄的精確名稱；不得接受含 `/`、`.`、`..` 的值。
- 安裝目錄的實體路徑不得與 `skills/` 相同或互相包含（MINGW／MSYS／Cygwin 下比對前轉小寫）。
- **腳本永遠不刪除實體目錄或檔案**：目標已存在且不是 symlink（含空目錄）時，所有衝突在任何寫入前一次列出並停下，由使用者自行搬走或刪除。
- 目標是 symlink 時才替換，且必須先建暫存連結並驗證，成功後才換手；失敗時原本的連結不動。

### 驗證

只剩兩支腳本，都只依 `skills/`：

- `scripts/validate-skillpack.sh`：frontmatter 白名單、必要區段、資源路徑可解析、跨技能安裝宣告、引用不離開 `skills/`、跨技能長段落不重複。
- `scripts/validate-skills-functional.sh`：各技能的觸發條件、輸出契約與安全邊界沒有在重構中遺失。

兩支都不得寫死技能總數或單一技能的歷史預算；新增技能不應需要改驗證器（`MODEL_INVOCABLE_SKILLS` 的觸發類別清單除外）。

## Invariants

| Invariant | 違反時的可觀察症狀 |
|---|---|
| `skills/` 是唯一來源，且沒有生成物 | 出現第二份技能副本，或修改技能要跑同步腳本 |
| 使用者觸發的技能帶 `disable-model-invocation: true` | 模型在使用者沒要求時自行載入不該自動觸發的技能 |
| 跨技能引用在安裝佈局下可解析 | 只安裝單一技能時，被引用的 reference 讀不到 |
| 安裝失敗不破壞既有安裝 | 安裝後使用者原有的技能或 repo 內容消失；或失敗後原先的 symlink 不見 |
| 安全邊界與輸出契約不因簡化而放寬 | 驗證器的契約斷言被刪除或弱化 |

## 技能拓撲

技能分為幾個能力群，群內技能可自由組合；沒有強制階段順序。

| 能力群 | 技能 |
|---|---|
| 需求與規格 | `maze-wayfinder`、`maze-idea-to-spec`、`maze-spec-hardening`、`maze-spec-review`、`maze-spec-to-issues` |
| 實作前審查 | `maze-adversarial-review`、`maze-threat-modeling` |
| 實作與驗證 | `maze-risk-driven-tdd`、`maze-qa-verification`、`maze-root-cause-diagnosis`、`maze-bug-reproduction` |
| Git／GitHub | `maze-github-safe-ops`、`maze-pr-review` |
| 設計與原型 | `maze-design-system`、`maze-design-review`、`maze-gui-prototyping` |
| 專案與交接 | `maze-project-init`、`maze-repo-map`、`maze-context-audit`、`maze-session-closeout`、`maze-handoff-summary` |
| 溝通與維護 | `maze-explain-for-dumbass`、`maze-token-efficiency-review`、`maze-grill`、`maze-grill-with-docs`、`maze-skill-authoring` |

跨技能依賴只有三條，且都在引用端寫明需同時安裝：`maze-grill-with-docs` → `maze-grill`；`maze-pr-review` → `maze-github-safe-ops`；`maze-wayfinder` → 上表對應的六個技能。

## Edge Cases

- 只安裝部分技能時，被引用的 reference 不存在；技能必須在缺檔時停止並回報，不得假裝讀過。
- Codex 不支援 `disable-model-invocation`：使用者觸發的技能在 Codex 上可能被模型自動選用；這是已接受的限制，不以 host 專屬 sidecar 檔補償。
- Windows 未開開發人員模式時無法建立 symlink：安裝失敗且既有安裝不變。
- 目標目錄已有使用者自己的同名技能或舊版副本：不加任何參數也不會被刪，腳本一律停手並列出衝突。

## Testing Decisions

- 驗證外部契約（frontmatter、資源路徑、輸出契約、安全邊界），不鎖定段落措辭。
- 安裝腳本以「`HOME` 覆寫到臨時目錄 + 假 repo」測試，永不寫入真實使用者目錄。
- 驗證器本身要有變異測試：故意改壞輸入要看到失敗，而不是靜默通過或崩潰。
- 不新增需要網路授權的整合測試。

### Acceptance criteria（v4.0 架構）

- [x] 技能不再依賴任何共用 Harness 契約檔；單一技能目錄即可獨立安裝與載入。
- [x] `skills/` 是唯一來源，repo 內沒有技能副本或生成物。
- [x] 每個技能的 frontmatter 只有 `name`、`description` 與選用的 `disable-model-invocation`。
- [x] 跨技能引用在安裝佈局下可解析，且 SKILL.md 寫明需同時安裝的技能。
- [x] 安裝腳本只建 symlink，名稱未消毒、衝突、建立失敗時都不會刪除既有資料。
- [x] 兩支驗證腳本只依 `skills/`，不寫死技能總數。
- [x] README 與 `AGENTS.md` 描述新架構，沒有失效路徑。

## Out of Scope

- 不引入新的框架、技能註冊中心或管理層取代舊架構。
- 不為 Codex 維護 `agents/openai.yaml` sidecar（已知限制，寫在 README）。
- 不做 Markdown 連結與 fenced code block 的路徑驗證（目前技能沒有這種寫法）。
- 不提供複製模式的安裝腳本。
- 不改動 `extensions/` 的內容或整併方式。

## Further Notes

### 變更紀錄

- v3.x：自適應 Harness 架構（共用契約、三級 Guidance、Model Overlay、多 Adapter 與同步管線）。
- v4.0：移除上述機制，收斂為原生 Agent Skills 集合；internal 技能併入宿主技能的 references，技能之間只保留三條必要的跨技能引用。決策與代價見 `docs/adr/0003-native-agent-skills.md`。

### Drift Risk

- 技能的 `description` 是模型選用的唯一依據；改寫時要保持觸發詞，否則技能會變成「存在但不會被選到」。
- 若日後為某個 host 加上專屬中繼資料，必須確認其他 host 會忽略它，不能讓同一份技能在不同 host 行為分歧。
