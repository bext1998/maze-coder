# maze-coder 規格書（補強版 v1.5）

> **補強版說明**：本文件在原始 spec v1.0 基礎上，依照 Harness Engineering 原則加入防護層。
> 原始架構決策、功能範圍、命名慣例均保持不動。補強內容以 `<!-- HARDENED -->` 區塊標示。
>
> **v1.2 變更**：OQ-1、OQ-2、OQ-5 決策落地
> **v1.3 變更**：OQ-3、OQ-4、OQ-6 決策落地，所有 Open Questions 已全數確認
> **v1.4 變更**：技能 `maze-` 前綴、`maze-project-init` 既有文件處理行為、spec 路徑改由 `MAZE_PROJECT.md` 管理
> **v1.5 變更**：新增 `maze-writing-skills`、`maze-update`；擴充 `maze-bug-reproduction`（4-phase 除錯）、`maze-qa-verification`（完成前確認）、`maze-session-closeout`（任務粒度原則）；新增 `update-skillpack.sh`

---

## 1. 專案概述

專案名稱：`maze-coder`

`maze-coder` 是一套可攜式 Harness Engineering 技能包，用於輔助 coding agent 工作流程。

它提供可重複使用的技能、模板、檢查清單與 harness 轉接檔案，協助使用者指揮 Claude Code、Codex、Cursor、opencode，以及其他類似的 coding agent harness。

本專案主要面向個人使用與小型專案使用情境。它應保持輕量、檔案導向、Markdown 優先、容易複製、容易遷移，並能在不同 coding agent 工具之間重複使用。

<!-- HARDENED: FROZEN 定義 -->
> **[FROZEN — v1.x 期間不得修改]**
> 以下是本專案的核心定位約束，AI 代理不得為了實作便利而偏離：
> - 本專案**不是**程式碼程式庫，不含任何可執行邏輯（scripts 除外）
> - 本專案**不是**framework，不提供 runtime 或 plugin 機制
> - 所有交付物以 `.md` 為主，`.sh` 為輔
> - 「可攜式」的操作定義：使用者可直接複製整個目錄到任何機器，無需安裝任何依賴即可使用
<!-- /HARDENED -->

---

## 2. 核心問題

使用者在多個 coding agent 工具之間切換時，常會遇到專案連續性中斷的問題。

常見問題包括：

- 使用者的模糊想法沒有被轉換成可執行的規格書
- 規格書缺少工程細節、測試策略、邊界條件與限制
- 專案經過數個 coding session 後容易失去方向
- agent 忘記目前狀態、下一步與過去的決策
- Git 操作可能過早 commit 或 push，導致風險
- 前端輸出可能出現低品質 AI 生成感，也就是 AI slop
- QA 驗證經常只有模糊描述，缺少可追蹤證據
- 在 Claude Code、Codex、Cursor、opencode 之間遷移時，需要反覆重寫指令

`maze-coder` 透過可重複使用的技能包與文件工作流來解決上述問題。

---

## 3. 專案目標

`maze-coder` 必須提供：

1. 可攜式技能包結構
2. 可重複使用的 Harness Engineering 原則
3. 將模糊想法轉換成 `spec.md` 的技能
4. 補強既有 `spec.md` 草稿的技能
5. 初始化專案指揮文件的技能
6. coding session 結束後更新專案狀態的技能
7. GitHub / Git 安全操作技能
8. 前端設計審查技能，用於降低 AI slop
9. QA 驗證技能
10. Claude Code、Codex、Cursor、opencode 的轉接檔案
11. 常用專案文件模板
12. spec、QA、設計審查、Git 安全與交接用檢查清單
13. 一個最小可用的驗證腳本，用於檢查必要檔案是否存在

---

## 4. 非目標

本專案不得實作以下內容：

- Web 應用程式
- SaaS 產品
- GUI 圖形介面
- 大型 CLI 框架
- 套件管理器
- 自訂 agent runtime
- Claude Code、Codex、Cursor、opencode 的完整替代品
- GitHub bot
- 完整自動化 CI/CD 平台

本專案應保持為 Markdown 優先、檔案導向、可攜式的技能包。

---

## 5. 目標 Harness

第一版必須支援下列工具的轉接格式：

- Claude Code
- Codex
- Cursor
- opencode

每個 adapter 應將相同的核心工作流轉換成該工具偏好的指令格式。

<!-- HARDENED: FROZEN — Adapter 範圍定義 -->
> **[FROZEN — Adapter 實作邊界]**
> Adapter 的職責定義如下，AI 代理不得超出：
> - **只做格式翻譯**：將 `skills/` 下的 SKILL.md 內容轉換成目標工具的指令格式
> - **不修改技能邏輯**：SKILL.md 的工作流、檢查清單、模板內容在 adapter 中必須保持語意等價
> - **不新增功能**：adapter 不得包含 skills/ 目錄中沒有對應技能的新行為
> - **全部 11 個技能必須出現在所有 adapter 中**：不得選擇性省略任何技能
>
> Adapter 與 Core Skills 的對應關係：
>
> | Adapter | 對應格式 | 核心指令檔 |
> |---|---|---|
> | claude-code | `.claude/skills/*/SKILL.md`（共 11 個） | SKILL.md（Claude 原生格式） |
> | codex | `AGENTS.md` | 統一整合進單一文件 |
> | cursor | `.cursor/rules/*.mdc` | MDC rule 格式 |
> | opencode | `AGENTS.md` | 統一整合進單一文件 |
<!-- /HARDENED -->

---

## 6. 預期 Repository 結構

```text
maze-coder/
  README.md
  LICENSE
  docs/
    spec.md                  ← maze-coder 自身規格書（本文件）
    PROJECT_BRIEF.md         ← maze-coder 自身專案說明
    STATUS.md                ← maze-coder 自身目前狀態
    NEXT_ACTION.md           ← maze-coder 自身下一步
    DECISIONS.md             ← maze-coder 自身決策紀錄
    HANDOFF.md               ← maze-coder 自身交接文件

  core/
    HARNESS_ENGINEERING.md
    PRINCIPLES.md
    WORKFLOW_MODEL.md
    DOCUMENT_MODEL.md

  skills/
    maze-idea-to-spec/
      SKILL.md
      templates/
        spec.template.md
      examples/
        spec.example.md

    maze-spec-hardening/
      SKILL.md
      checklists/
        product-checklist.md
        engineering-checklist.md
        testing-checklist.md

    maze-project-init/
      SKILL.md
      templates/
        AGENTS.template.md
        PROJECT_BRIEF.template.md
        STATUS.template.md
        NEXT_ACTION.template.md
        DECISIONS.template.md
        MAZE_PROJECT.template.md  ← 記錄本專案的 spec 路徑與關鍵文件位置

    maze-session-closeout/
      SKILL.md                  ← v1.5：執行流程新增步驟「確認下一個 task 是否符合 2-5 分鐘粒度原則」
      templates/
        status-update.template.md

    maze-github-safe-ops/
      SKILL.md
      checklists/
        pre-commit-checklist.md
        pre-push-checklist.md
        conflict-checklist.md

    maze-design-review/
      SKILL.md
      checklists/
        anti-ai-slop-checklist.md
        frontend-ux-checklist.md
        visual-quality-checklist.md
      templates/
        DESIGN_REVIEW.template.md

    maze-qa-verification/
      SKILL.md                  ← v1.5：執行流程新增 Phase 0「完成宣告前確認」（≤5 條輕量 checklist）
      checklists/
        code-quality-checklist.md
        test-plan-checklist.md
        regression-checklist.md
        pre-completion-checklist.md  ← v1.5 新增
      templates/
        QA_REPORT.template.md

    maze-repo-map/
      SKILL.md
      templates/
        REPO_MAP.template.md

    maze-context-audit/
      SKILL.md
      checklists/
        context-consistency-checklist.md

    maze-bug-reproduction/
      SKILL.md                  ← v1.5：整合 4-phase 除錯流程（Reproduce→Isolate→Root Cause→Fix+Verify）
      checklists/
        debug-4phase-checklist.md  ← v1.5 新增
      templates/
        BUG_REPRODUCTION.template.md

    maze-handoff-summary/
      SKILL.md
      templates/
        HANDOFF.template.md

    maze-writing-skills/         ← v1.5 新增：協助使用者建立新的 maze-coder 技能
      SKILL.md
      templates/
        skill-scaffold.template.md

    maze-update/                 ← v1.5 新增：檢查遠端版本並輸出更新摘要（不寫入檔案）
      SKILL.md

  templates/                 ← 供使用者複製到自己專案的可攜式範本（非 maze-coder 自身文件）
    spec.md
    AGENTS.md
    PROJECT_BRIEF.md
    STATUS.md
    NEXT_ACTION.md
    DECISIONS.md
    QA_REPORT.md
    DESIGN_REVIEW.md
    REPO_MAP.md
    HANDOFF.md
    TASK_PLAN.md              ← v1.5：嵌入任務粒度原則（2-5 分鐘、具體檔案路徑、驗證步驟）

  adapters/
    claude-code/
      README.md
      .claude/
        skills/
          maze-idea-to-spec/
            SKILL.md
          maze-spec-hardening/
            SKILL.md
          maze-project-init/
            SKILL.md
          maze-session-closeout/
            SKILL.md
          maze-github-safe-ops/
            SKILL.md
          maze-design-review/
            SKILL.md
          maze-qa-verification/
            SKILL.md
          maze-repo-map/
            SKILL.md
          maze-context-audit/
            SKILL.md
          maze-bug-reproduction/
            SKILL.md
          maze-handoff-summary/
            SKILL.md
          maze-writing-skills/
            SKILL.md
          maze-update/
            SKILL.md

    codex/
      README.md
      AGENTS.md

    cursor/
      README.md
      .cursor/
        rules/
          maze-coder-core.mdc
          maze-coder-qa.mdc
          maze-coder-git.mdc
          maze-coder-design-review.mdc

    opencode/
      README.md
      AGENTS.md

  scripts/
    validate-skillpack.sh
    sync-adapters.sh
    update-skillpack.sh       ← v1.5 新增：從遠端拉取最新版本並寫入本機，衝突時逐一詢問
```

<!-- HARDENED: FROZEN — Repository 結構 -->
> **[FROZEN — 目錄結構 v1.x 期間不得重命名或移動]**
> 以下路徑是被 `validate-skillpack.sh` 直接引用的錨點，變更需同步更新腳本並遞增 spec 版本：
> - `skills/maze-*/SKILL.md`（所有 13 個技能入口，**必須帶 `maze-` 前綴**）
> - `adapters/claude-code/.claude/skills/`（含所有 13 個 `maze-*` 技能子目錄）
> - `adapters/cursor/.cursor/rules/`
> - `adapters/codex/AGENTS.md`
> - `adapters/opencode/AGENTS.md`
> - `scripts/validate-skillpack.sh`
> - `scripts/update-skillpack.sh`（需要 `git` 或 `curl`；與其他純 bash 腳本的依賴需求不同，README 需標注）
>
> **`docs/` vs `templates/` 定位（已確認，不得混用）**：
> - `docs/`：maze-coder **自身**的專案文件，記錄此 repo 的狀態與決策
> - `templates/`：供**使用者複製到自己專案**的可攜式範本，不含任何 maze-coder 專屬內容
>
> **`MAZE_PROJECT.template.md` 用途**：
> - 由 `maze-project-init` 技能在使用者專案中生成為 `MAZE_PROJECT.md`
> - 記錄該專案的 spec 文件實際路徑、關鍵文件位置，作為 agent 的定位錨點
> - 不得與 spec 文件本身合併或省略
<!-- /HARDENED -->

---

<!-- HARDENED: SKILL.md 標準結構 -->
## 7. SKILL.md 標準結構

> **[FROZEN — 所有 SKILL.md 必須符合以下結構，AI 代理不得自行決定欄位]**

每個 `skills/maze-*/SKILL.md` 必須包含以下 section，缺一不可：

```markdown
---
name: maze-[技能名稱]   ← 必須帶 maze- 前綴，與目錄名完全一致
description: |
  [技能用途，一到三句話]
  [觸發時機描述]
---

# [技能標題]

## 技能目標
[2-4 句說明本技能解決什麼問題]

## 前置條件（Preconditions）
[呼叫此技能前，使用者 / agent 必須提供什麼]

## 執行流程
[分步驟描述，Phase 0 → Phase N]

## 輸出（Output Contract）
[本技能產出什麼，格式是什麼，存放在哪]

## 技能邊界（本技能不做的事）
[至少三條明確的排除項]
```

**判斷合規**：`validate-skillpack.sh` 應驗證：
1. 每個技能目錄名稱以 `maze-` 開頭
2. 每個 SKILL.md 的 `name:` front matter 值與目錄名完全一致
3. 每個 SKILL.md 至少包含上述 5 個 section 標題

<!-- /HARDENED -->

---

<!-- HARDENED: 介面契約 -->
## 8. 介面契約（Contract）

> **[FROZEN — 以下契約定義技能之間、技能與 adapter 之間的輸入輸出邊界]**

### 8.1 使用者 → 技能 的契約

| 技能 | 輸入要求 | 輸出承諾 | 失敗行為 |
|---|---|---|---|
| `maze-idea-to-spec` | 使用者的文字描述（任意格式） | 一份符合 `spec.template.md` 結構的規格文件，路徑記錄至 `MAZE_PROJECT.md` | 若描述不足，停止並列出缺漏問題，不得自行填充假設 |
| `maze-spec-hardening` | 一份現有規格文件（路徑可來自 `MAZE_PROJECT.md` 或使用者直接指定） | 補強後的 spec，包含 Contract / Invariants / Edge Cases / AC / Test Plan | 若輸入 spec 不完整，標注 `[缺漏]` 後繼續補強可補的部分 |
| `maze-project-init` | 專案名稱 + 目標工具（至少一個）+ 規格文件實際路徑 | 填寫完成的專案文件集（PROJECT_BRIEF / STATUS / NEXT_ACTION）+ `MAZE_PROJECT.md`；**若任何目標文件已存在，停止並逐一詢問使用者：合併、覆蓋或跳過** | 缺少專案名稱或規格路徑時停止並詢問，不得使用 "untitled" 或自行命名 |
| `maze-session-closeout` | 本次 session 的摘要（使用者提供） | 更新後的 STATUS.md + NEXT_ACTION.md；不產出 summary 檔案 | 若摘要為空，列出需要填寫的問題，不得留空白模板 |
| `maze-github-safe-ops` | 使用者的 Git 操作意圖 | 對應的安全操作步驟 + 檢查清單確認 | 遇到 force push / rebase main 等高風險操作，必須停止並警告 |
| `maze-design-review` | 前端截圖或程式碼 | DESIGN_REVIEW.md 報告 + 評分 | 若無法取得視覺輸出，標注「無法驗證視覺品質」並繼續審查程式碼結構 |
| `maze-qa-verification` | 功能描述 + 測試目標 | Phase 0 完成前確認（≤5 條）+ QA_REPORT.md + 測試清單 | 若測試環境未就緒，列出缺漏環境條件，不得假設環境已就緒 |
| `maze-writing-skills` | 使用者想建立的新技能名稱與用途描述 | 符合 Section 7 標準結構的 SKILL.md 草稿，存放於 `skills/maze-[name]/` | 若名稱未帶 `maze-` 前綴，自動補上並告知使用者 |
| `maze-update` | 無（自動讀取 `MAZE_PROJECT.md` 取得安裝路徑）| 更新摘要：目前版本、遠端最新版本、有差異的檔案清單；**不寫入任何檔案** | 若無法連線至遠端 repo，輸出明確錯誤並提示使用者手動執行 `update-skillpack.sh` |

### 8.2 Core Skills → Adapter 的契約

**前置條件**：
- `skills/*/SKILL.md` 必須已存在且符合標準結構（Section 7）
- `sync-adapters.sh` 被呼叫前，`skills/` 目錄必須完整

**後置條件**：
- 每個 adapter 輸出的指令在語意上與對應的 `skills/*/SKILL.md` 等價
- Adapter 不得引入 skills/ 中不存在的新技能或行為
- 若 adapter 格式有長度限制（如 `.mdc`），必須截斷而非省略關鍵步驟

**錯誤無副作用原則**：
- `sync-adapters.sh` 若執行失敗，不得留下部分更新的 adapter 檔案（原子性寫入或先寫暫存再替換）

<!-- /HARDENED -->

---

<!-- HARDENED: 系統不變式 -->
## 9. 系統不變式（Invariants）

> 以下條件在任何時間點、任何檔案狀態下都必須成立。
> 若 AI 代理的實作有任何可能違反這些條件，必須先取得 spec revision。

| # | 不變式 | 對應範圍 | 違反時的症狀 |
|---|---|---|---|
| INV-1 | 每個 `skills/maze-*/` 目錄有且只有一個 `SKILL.md`；目前共 13 個技能 | `skills/` 全體 | validate 腳本找到 0 或 2+ 個 SKILL.md，或技能總數不為 13 |
| INV-2 | `adapters/` 下四個 adapter 目錄名稱固定為 `claude-code`、`codex`、`cursor`、`opencode` | `adapters/` | 新增或重命名 adapter 目錄 |
| INV-3 | `validate-skillpack.sh` 的必要檔案清單必須與本 spec Section 6 的結構一致（含 13 個技能） | `scripts/` | 腳本通過但實際缺少必要檔案，或腳本失敗但檔案其實存在 |
| INV-4 | `docs/` 只存放 maze-coder 自身的專案文件；`templates/` 只存放供使用者複製的空白範本，不得交叉存放 | `docs/`、`templates/` | `docs/` 出現空白範本，或 `templates/` 出現 maze-coder 的實際狀態資料 |
| INV-5 | Adapter 中的技能指令在語意上不得比 `skills/` 中的原始 SKILL.md 更嚴格或更寬鬆 | `adapters/` | 切換工具後，相同技能產生不同結果 |
| INV-6 | `sync-adapters.sh` 只讀取 `skills/`，只寫入 `adapters/`，不修改其他目錄 | `scripts/` | sync 腳本修改了 core/ 或 templates/ |
| INV-7 | 技能目錄名稱必須以 `maze-` 開頭，且與 SKILL.md 的 front matter `name:` 欄位完全一致 | `skills/` | adapter 無法用目錄名定位對應的 SKILL.md；技能在工具列表中顯示無前綴名稱 |
| INV-8 | 根目錄 `templates/` 下的模板是從 `skills/maze-*/templates/` 同步而來，不得手動直接編輯根目錄版本 | `templates/`、`skills/maze-*/templates/` | 根目錄模板與 skills 下模板出現內容分歧 |
| INV-9 | 每個使用 `maze-project-init` 初始化的專案必須含有 `MAZE_PROJECT.md`，其中記錄 spec 文件的實際路徑；agent 讀取 spec 前必須先查此文件 | 使用者專案目錄 | agent 自行猜測 spec 路徑，或在多個含 "spec" 字眼的文件中隨機選擇 |
| INV-10 | `update-skillpack.sh` 是唯一允許依賴 `git` 或 `curl` 的腳本；`validate-skillpack.sh` 和 `sync-adapters.sh` 必須只依賴 `bash` 和 `find` | `scripts/` | 其他腳本引入網路依賴，導致在離線環境失效 |

<!-- /HARDENED -->

---

<!-- HARDENED: FROZEN — core/ 目錄定位 -->
> **[FROZEN — `core/` 目錄內容定位，v1.x 期間不得互換]**
>
> | 檔案 | 受眾 | 內容類型 |
> |---|---|---|
> | `HARNESS_ENGINEERING.md` | AI agent | 可執行規則，條列式，agent 可直接引用為行為指引 |
> | `PRINCIPLES.md` | 人類維護者 | 設計哲學與取捨脈絡，說明「為什麼這樣設計」 |
> | `WORKFLOW_MODEL.md` | AI agent + 人類 | 標準工作流圖，描述技能之間的執行順序 |
> | `DOCUMENT_MODEL.md` | AI agent + 人類 | 文件系統模型，說明各類文件的生命週期 |
>
> AI agent 在實作或引用 `core/` 文件時，若需要行為規則請讀 `HARNESS_ENGINEERING.md`，不得以 `PRINCIPLES.md` 的設計說明文字作為行為依據。
<!-- /HARDENED -->
## 10. 邊界情況（Edge Cases）

> AI 代理實作時必須明確處理以下情況，不得依靠隱含假設。

### 10.1 `validate-skillpack.sh` 邊界情況

| 情況 | 輸入條件 | 預期行為 | 禁止行為 |
|---|---|---|---|
| 在非 maze-coder 根目錄執行 | 當前目錄缺少 `skills/` | 輸出明確錯誤訊息並以 exit code 1 結束 | 假設在正確目錄並繼續執行 |
| `skills/` 存在但某技能目錄缺少 SKILL.md | `skills/qa-verification/` 目錄存在但為空 | 列出缺漏的 SKILL.md 路徑，以 exit code 1 結束 | 跳過空目錄並靜默通過 |
| 部分 adapter 存在、部分不存在 | `adapters/claude-code/` 存在，`adapters/codex/` 不存在 | 列出缺漏的 adapter，以 exit code 1 結束 | 只驗證存在的 adapter |
| 腳本在 Windows 環境執行 | 使用 `\r\n` 換行的檔案 | 腳本應能正確解析（使用 `#!/usr/bin/env bash`，不依賴 `/bin/bash`） | 因換行符號崩潰或靜默錯誤 |

### 10.2 `sync-adapters.sh` 邊界情況

> **[已確認 — OQ-2]** `sync-adapters.sh` 採**冪等覆蓋策略**：每次執行都完整覆寫 adapter 檔案，無論目標是否已存在。多次執行結果相同。

| 情況 | 輸入條件 | 預期行為 | 禁止行為 |
|---|---|---|---|
| `skills/` 下有新增技能但 adapter 尚未支援 | 新增 `skills/new-skill/` 但 adapter 無對應位置 | 輸出警告：「以下技能尚未同步到所有 adapter：[名稱]」，不中斷執行 | 靜默跳過或自動建立 adapter 格式（應由人工決定格式） |
| `sync-adapters.sh` 中途被中斷（Ctrl+C） | 部分 adapter 已更新 | 下次執行時完整覆寫所有 adapter，不留殘留的暫存檔 | 留下 `.tmp` 或不完整的 adapter 檔案 |
| SKILL.md 包含非 ASCII 字元（中文） | `SKILL.md` 以 UTF-8 撰寫 | 正確複製，不損壞字元 | 用 ASCII 模式處理導致亂碼 |
| adapter 目標檔案已存在且內容完全相同 | 重複執行 sync | 覆寫並輸出「synced（no changes）」，exit 0 | 跳過比對、或因「無變更」而 exit 1 |

### 10.3 SKILL.md 撰寫邊界情況

| 情況 | 輸入條件 | 預期行為 | 禁止行為 |
|---|---|---|---|
| 技能被呼叫但使用者未提供必要輸入 | 使用者呼叫 `idea-to-spec` 但未提供任何描述 | 停止並列出缺漏的輸入項目，附上引導問題 | 用預設值填充並繼續執行 |
| 同一 session 內連續呼叫同一技能 | 使用者在 spec 完成後又呼叫 `idea-to-spec` | 詢問：「是否要建立新 spec 或修改現有 spec？」 | 直接覆蓋現有 spec |
| 使用者輸入的語言與 SKILL.md 語言不同 | SKILL.md 以中文撰寫，使用者用英文呼叫 | 以使用者語言回應，但保持技能邏輯不變 | 拒絕執行或切換到不同的技能流程 |

### 10.4 `maze-update` 與 `update-skillpack.sh` 邊界情況

> `maze-update`（技能）：唯讀，只輸出更新摘要，不寫入任何檔案。
> `update-skillpack.sh`（腳本）：有副作用，實際執行檔案更新，衝突時逐一詢問。

| 情況 | 輸入條件 | 預期行為 | 禁止行為 |
|---|---|---|---|
| 無法連線至遠端 repo | 離線環境或 GitHub 不可用 | `maze-update` 輸出明確錯誤並提示手動方式；`update-skillpack.sh` exit 1 | 靜默失敗、假設本機已是最新版、或部分更新後崩潰 |
| 使用者修改了本機 SKILL.md | 本機與遠端版本不同且非 fast-forward | `update-skillpack.sh` 停止並顯示 diff，詢問「此檔案在本機有修改，是否覆蓋？(y/N)」 | 靜默覆蓋使用者的自訂內容 |
| 本機版本與遠端完全相同 | 無任何差異 | `maze-update` 輸出「目前已是最新版本」；`update-skillpack.sh` 輸出「No changes」並 exit 0 | 輸出空白或 exit 1 |
| `MAZE_PROJECT.md` 不存在 | 使用者手動複製 repo 未執行 `maze-project-init` | `maze-update` 仍可執行（讀取 maze-coder repo 自身路徑）；輸出提醒「建議執行 maze-project-init 初始化專案」 | 因找不到 MAZE_PROJECT.md 而崩潰或拒絕執行 |
| 遠端新增了未知技能 | 遠端有 `skills/maze-new-skill/`，本機無 | `maze-update` 摘要中標注「新增技能：maze-new-skill」；`update-skillpack.sh` 詢問是否安裝 | 靜默新增或靜默跳過 |

<!-- /HARDENED -->

---

<!-- HARDENED: 驗收標準 -->
## 11. 驗收標準（Acceptance Criteria）

> 以下標準必須全部通過，才算 Phase 1 完成。
> 所有條件必須可在手動驗證中確認，不接受「看起來完整」等模糊描述。

| # | 驗收項目 | 測量方式 | 通過門檻 | 可自動化 |
|---|---|---|---|---|
| AC-1 | `validate-skillpack.sh` 在完整 repo 上執行 | 執行腳本，觀察 exit code | exit 0，輸出「All checks passed」 | 是 |
| AC-2 | `validate-skillpack.sh` 在缺少任意必要檔案時失敗 | 刪除任一 SKILL.md 後執行腳本 | exit 1，輸出缺漏的檔案路徑 | 是 |
| AC-3 | `validate-skillpack.sh` 驗證每個 SKILL.md 包含所有必要 section 標題 | 執行腳本，觀察輸出 | 對所有 13 個 SKILL.md 以 grep 確認「技能目標」「前置條件」「執行流程」「輸出」「技能邊界」五個標題存在；缺少任一則 exit 1 並列出路徑 | 是（grep） |
| AC-4 | 四個 adapter 各包含其 README.md 與主要指令檔 | 人工檢查目錄結構 | 與 Section 6 的結構完全吻合 | 是（由 AC-1 涵蓋） |
| AC-5 | `maze-idea-to-spec` 技能能將口語描述轉換成有效的規格文件 | 提供範例描述，檢查輸出 | 輸出包含 spec.template.md 所有必要 section | 否（手動） |
| AC-6 | `maze-spec-hardening` 技能輸出包含所有 8 個補強區塊 | 提供一份範例 spec，檢查輸出 | 輸出含 Contract / Invariants / Edge Cases / AC / Test Plan / FROZEN / Drift Risk / OQ | 否（手動） |
| AC-7 | `maze-github-safe-ops` 技能在使用者要求 force push main 時發出警告 | 提供「我要 force push main」，檢查輸出 | 輸出明確警告，不提供指令 | 否（手動） |
| AC-8 | `sync-adapters.sh` 執行後，adapter 內容與 skills/ 語意一致 | 執行腳本，比對 adapter 與 skill | 不存在 skills/ 中沒有的技能指令 | 否（手動比對） |
| AC-9 | 整個 repo 可在不安裝任何依賴的情況下使用（`update-skillpack.sh` 除外） | 在乾淨的 macOS / Linux 環境複製 repo 後直接閱讀 | 所有 .md 可閱讀；`validate-skillpack.sh` 和 `sync-adapters.sh` 只依賴 bash 和 find | 是 |
| AC-10 | `templates/` 下的模板不含任何佔位符需要人工替換（除 `[...]` 格式的欄位） | 人工檢查所有 template 檔案 | 無 `TODO`、`FIXME`、`your-project-name` 等未完成標記 | 部分（grep） |
| AC-11 | `maze-update` 技能在離線環境執行時輸出明確錯誤，不崩潰 | 斷網後呼叫 `maze-update` | 輸出「無法連線至遠端 repo」並提示手動執行 `update-skillpack.sh` | 否（手動） |
| AC-12 | `update-skillpack.sh` 在偵測到使用者修改的 SKILL.md 時停止並詢問 | 修改任一 SKILL.md 後執行腳本 | 輸出差異並等待使用者確認，不靜默覆蓋 | 否（手動） |
| AC-13 | `maze-writing-skills` 技能輸出的 SKILL.md 草稿符合 Section 7 標準結構 | 提供技能名稱與描述，檢查輸出 | 輸出包含所有 5 個必要 section，且 `name:` front matter 帶 `maze-` 前綴 | 否（手動） |

<!-- /HARDENED -->

---

<!-- HARDENED: 測試計畫 -->
## 12. 測試計畫（Test Plan）

> **[FROZEN — 以下測試案例對應 Must-have 驗收標準，不得跳過或以 workaround 通過]**

### 測試層次

| 層次 | 覆蓋範圍 | 工具 | 必要性 |
|---|---|---|---|
| 結構驗證 | 必要檔案是否存在、SKILL.md 是否有必要 section | `validate-skillpack.sh` + `grep` | 必要 |
| 技能功能測試 | 每個 SKILL.md 的工作流是否產生正確輸出 | 手動（with Claude Code） | 必要 |
| Adapter 一致性測試 | Adapter 指令是否與 skills/ 語意等價 | 手動比對 | 必要 |
| 可攜性測試 | 在不同 OS 上複製 repo 後能否正常使用 | 手動（macOS + Linux） | 必要 |
| 迴歸測試 | 修改任何 SKILL.md 後，validate 腳本仍通過 | `validate-skillpack.sh` | 必要 |

### 關鍵測試案例

| 測試 ID | 描述 | 層次 | [FROZEN] |
|---|---|---|---|
| T-001 | `validate-skillpack.sh` 在完整 repo 上 exit 0 | 結構驗證 | 是 |
| T-002 | `validate-skillpack.sh` 在刪除任意 SKILL.md 後 exit 1 | 結構驗證 | 是 |
| T-003 | `validate-skillpack.sh` 在缺少任意 adapter 主檔後 exit 1 | 結構驗證 | 是 |
| T-004 | 呼叫 `idea-to-spec` 並提供「我想做一個任務管理 CLI」，輸出包含所有 spec 必要 section | 技能功能 | 否 |
| T-005 | 呼叫 `spec-hardening` 並提供 T-004 的輸出，輸出包含 8 個補強區塊 | 技能功能 | 否 |
| T-006 | 呼叫 `github-safe-ops` 並輸入「force push main」，輸出含警告且不含 git push --force 指令 | 技能功能 | 是 |
| T-007 | 執行 `sync-adapters.sh` 後，`adapters/codex/AGENTS.md` 包含所有 11 個核心技能的指令 | Adapter 一致性 | 否 |
| T-008 | 在 Ubuntu 22.04 上複製 repo，執行 `validate-skillpack.sh` exit 0 | 可攜性 | 否 |
| T-009 | 修改 `skills/qa-verification/SKILL.md` 後，`validate-skillpack.sh` 仍 exit 0 | 迴歸 | 否 |
| T-010 | 建立一個缺少「技能邊界」section 的 SKILL.md，`validate-skillpack.sh` exit 1 並列出該檔案路徑 | 結構驗證 | 是 |
| T-011 | 執行 `sync-adapters.sh` 兩次，第二次輸出含「no changes」並 exit 0 | 冪等性 | 否 |
| T-012 | `docs/` 目錄下不存在任何 `[...]` 佔位符格式的空白模板 | 結構驗證 | 否 |

### 10.3 `maze-project-init` 既有文件邊界情況

> **[已確認]** `maze-project-init` 在執行前必須掃描目標目錄，發現既有文件時**停止並逐一詢問**，不得靜默覆蓋。

| 情況 | 輸入條件 | 預期行為 | 禁止行為 |
|---|---|---|---|
| 目標目錄完全乾淨 | 無任何既有文件 | 正常建立所有文件，輸出建立清單 | — |
| 部分文件已存在 | `STATUS.md` 已存在，`PROJECT_BRIEF.md` 不存在 | 對每個已存在的文件逐一詢問：「[檔名] 已存在，請選擇：(1) 跳過 (2) 覆蓋 (3) 查看後決定」；未存在的文件正常建立 | 靜默跳過或靜默覆蓋任何一個已存在的文件 |
| 所有文件均已存在 | 目標目錄是舊有專案 | 逐一詢問每個文件（同上），若使用者全部選擇跳過，輸出「所有文件均已保留，未做任何修改」 | 假設「都選跳過」而不詢問 |
| `MAZE_PROJECT.md` 已存在且記錄了不同的 spec 路徑 | 舊有 MAZE_PROJECT.md 指向 `old-spec.md` | 停止並提示：「已偵測到現有的 spec 路徑設定，是否要更新為新路徑？」，等待確認後才修改 | 直接覆蓋 MAZE_PROJECT.md |

- 不得修改 [FROZEN] 測試的預期輸出使其通過（應修復實作）
- 不得在 `validate-skillpack.sh` 中用 `|| true` 忽略失敗的檢查
- 不得建立只在特定環境有效的絕對路徑（必須使用相對路徑）

<!-- /HARDENED -->

---

<!-- HARDENED: 契約飄移風險 -->
## 13. 契約飄移風險分析（Drift Risk Analysis）

> 以下是本 spec 中容易讓 AI 代理產生錯誤詮釋的位置。

| 風險 ID | 模糊點位置 | 可能的錯誤詮釋 | 緩解措施 | 已解決 |
|---|---|---|---|---|
| DR-1 | Section 1：「可攜式」 | AI 代理可能實作成跨平台的 shell 腳本框架，或加入 npm/pip 依賴 | Section 7 已明確定義「可攜式 = 複製目錄即可用，無需安裝依賴」 | 是 |
| DR-2 | Section 5：「每個 adapter 應將相同的核心工作流轉換成該工具偏好的指令格式」 | AI 代理可能理解成「adapter 可以新增額外功能」或「可以簡化核心工作流」 | Section 5 FROZEN 區塊已明確：只做格式翻譯，不修改邏輯，不新增功能 | 是 |
| DR-3 | Section 3 目標 13：「最小可用的驗證腳本」 | 「最小」可能被理解成「只檢查根目錄是否存在」，或「完整的 CI 腳本」 | AC-1 到 AC-3 明確列出腳本必須驗證的項目；Test Plan T-001 到 T-003 定義通過條件 | 是 |
| DR-4 | Section 6：`templates/` 與 `skills/*/templates/` 同時存在 | AI 代理可能認為兩者是同一份文件，只建立一個位置；或建立兩份但內容不同步 | **已確認（OQ-4）**：`skills/*/templates/` 是 source of truth，根目錄 `templates/` 由同步腳本產生。INV-8 強制此方向 | 是 |
| DR-5 | Section 3 目標 10：「轉接檔案」 | 可能被理解成需要實作程式碼橋接層（bridge code）或 API 包裝器 | Section 5 FROZEN 區塊明確說明 adapter 只是 Markdown / MDC 格式的翻譯文件 | 是 |
| DR-6 | `sync-adapters.sh` 的職責邊界 | AI 代理可能實作成「同步時自動生成新的 adapter 格式決策」 | INV-6 明確：sync 只讀 skills/，只寫 adapters/，不做決策；Edge Case 10.2 說明新技能的處理方式 | 是 |
| DR-7 | Claude Code adapter 的 skills 數量（7 個）少於核心技能數量（11 個） | AI 代理可能補齊所有 11 個，也可能認為 7 個是錯誤 | **已確認（OQ-1）**：確認為遺漏，已補齊至 11 個。Claude Code adapter 結構已更新 | 是 |
| DR-8 | `skills/maze-*/` 的 `maze-` 前綴 | AI 代理可能在 adapter 裡省略前綴（寫成 `idea-to-spec` 而非 `maze-idea-to-spec`），或只在 front matter 加前綴而目錄名不加 | INV-7 明確：目錄名與 front matter `name:` 必須一致且都帶 `maze-` 前綴；Section 7 的 SKILL.md 標準結構已加注 | 是 |
| DR-9 | `maze-spec-hardening` 的輸入「現有規格文件」路徑來源不明確 | AI 代理可能搜尋所有含 "spec" 字眼的文件，隨機選一份；或預設讀取 `spec.md` 而忽略使用者的實際命名 | INV-9 明確：agent 必須先查 `MAZE_PROJECT.md` 取得 spec 實際路徑；Contract 表已更新 `maze-spec-hardening` 的輸入要求 | 是 |

<!-- /HARDENED -->

---

<!-- HARDENED: 未確認事項 -->
## 14. 未確認事項（Open Questions）

> ✅ = 已確認，決策已落地至 spec。所有 OQ 已全數確認。

| # | 問題 | 狀態 | 決策結果 | 影響範圍 |
|---|---|---|---|---|
| OQ-1 | Claude Code adapter 只包含 7 個技能，是有意設計還是遺漏？ | ✅ | **遺漏，補齊至 11 個**。`adapters/claude-code/.claude/skills/` 必須包含所有 11 個技能子目錄 | Section 6 repo 結構、Section 5 FROZEN、INV-2、T-003 |
| OQ-2 | `sync-adapters.sh` 是否應為冪等腳本？ | ✅ | **冪等覆蓋**：每次執行完整覆寫所有 adapter 檔案 | Section 10.2 edge cases、INV-6、T-011 |
| OQ-3 | `validate-skillpack.sh` 是否應驗證 SKILL.md 的內容結構？ | ✅ | **驗證 section 標題**：用 grep 確認五個必要標題存在，缺一 exit 1 | AC-3、Section 7 SKILL.md 標準結構、T-010 |
| OQ-4 | `templates/` 根目錄的模板與 `skills/*/templates/` 的關係是什麼？ | ✅ | **`skills/*/templates/` 是 source of truth**，根目錄 `templates/` 為同步輸出，不得手動編輯根目錄版本 | INV-8、DR-4、`sync-adapters.sh` 職責擴充 |
| OQ-5 | `docs/` 下的文件是此 repo 自身的，還是供使用者複製的範例？ | ✅ | **分離**：`docs/` 只放 maze-coder 自身文件；`templates/` 才是使用者可複製的範本。兩者不得混用 | Section 6 repo 結構、FROZEN 區塊、INV-4 |
| OQ-6 | `core/HARNESS_ENGINEERING.md` 與 `core/PRINCIPLES.md` 的內容區分是什麼？ | ✅ | **受眾切分**：`HARNESS_ENGINEERING.md` 給 AI agent 看（可執行規則）；`PRINCIPLES.md` 給人類看（設計哲學與取捨脈絡） | `core/` 目錄、Section 7 SKILL.md 標準結構的前置條件 |

<!-- /HARDENED -->

---

## 補強摘要

| 補強任務 | 狀態 | 新增內容位置 |
|---|---|---|
| Task 1：Contract | ✅ 完成 | Section 8 |
| Task 2：Invariants | ✅ 完成 | Section 9（INV-1 到 INV-9） |
| Task 3：Edge Cases | ✅ 完成 | Section 10（含 10.3 既有文件處理） |
| Task 4：Acceptance Criteria | ✅ 完成 | Section 11 |
| Task 5：Test Plan | ✅ 完成 | Section 12（T-001 到 T-012） |
| Task 6：[FROZEN] 標記 | ✅ 完成 | Section 1、5、6、7、9（core/）、12 |
| Task 7：Drift Risk Analysis | ✅ 完成 | Section 13（DR-1 到 DR-9） |
| Task 8：Open Questions | ✅ 完成 | Section 14（全數確認） |

**全部 OQ 決策落地狀態：**

| OQ | 決策摘要 | 主要落地位置 |
|---|---|---|
| OQ-1 | Claude Code adapter 補齊至 11 個技能 | Section 6、Section 5 FROZEN |
| OQ-2 | sync-adapters.sh 採冪等覆蓋 | Section 10.2、INV-6 |
| OQ-3 | validate 腳本驗證 section 標題（grep）+ 目錄名前綴 | AC-3、Section 7、T-010 |
| OQ-4 | skills/maze-\*/templates/ 是 source of truth，根目錄由同步產生 | INV-8、DR-4 |
| OQ-5 | docs/ 是自身文件，templates/ 是使用者範本 | Section 6、INV-4 |
| OQ-6 | HARNESS_ENGINEERING.md 給 agent；PRINCIPLES.md 給人類 | Section 9 FROZEN（core/） |

**v1.5 新增技能與功能擴充：**

| 項目 | 類型 | 說明 | 主要落地位置 |
|---|---|---|---|
| `maze-writing-skills` | 新增技能 | 協助使用者建立新技能，輸出符合 Section 7 的 SKILL.md 草稿 | Section 6 結構、Contract 表、AC-13 |
| `maze-update` | 新增技能 | 檢查遠端版本並輸出更新摘要（唯讀，不寫入） | Section 6 結構、Contract 表、AC-11、Section 10.4 |
| `update-skillpack.sh` | 新增腳本 | 實際執行檔案更新，衝突時逐一詢問（需 git 或 curl） | Section 6 結構、INV-10、AC-12、Section 10.4 |
| `maze-bug-reproduction` 擴充 | 技能強化 | 整合 4-phase 除錯流程（Reproduce→Isolate→Root Cause→Fix+Verify）+ 新增 debug-4phase-checklist | Section 6 結構 |
| `maze-qa-verification` 擴充 | 技能強化 | 新增 Phase 0「完成宣告前確認」（≤5 條輕量 checklist）+ pre-completion-checklist | Section 6、Contract 表 |
| `maze-session-closeout` 擴充 | 技能強化 | 新增步驟「確認下一個 task 是否符合 2-5 分鐘粒度原則」 | Section 6 |
| `TASK_PLAN.md` 更新 | 模板強化 | 嵌入任務粒度原則（2-5 分鐘、具體檔案路徑、驗證步驟） | Section 6 |

---

*maze-coder spec v1.5 — 補強版*
*v1.0 原始 → v1.1 補強 → v1.2 OQ 落地（1、2、5）→ v1.3 OQ 落地（3、4、6）→ v1.4 架構決策落地 → v1.5 功能擴充*
*最後更新：2026-05-23*
