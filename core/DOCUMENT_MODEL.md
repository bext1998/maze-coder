# 文件系統模型

> **受眾：AI agent + 人類維護者**
> 本文件說明 maze-coder 中各類文件的用途、生命週期與維護責任。

---

## 文件類型總覽

| 文件 | 位置 | 生產者 | 消費者 | 生命週期 |
|---|---|---|---|---|
| `spec.md` | `docs/` 或使用者專案根目錄 | `idea-to-spec` → `spec-hardening` | 所有技能、使用者 | 專案期間持續更新 |
| `PROJECT_BRIEF.md` | `docs/` 或使用者專案根目錄 | `project-init` | 人類、agent | 專案初期建立，偶爾更新 |
| `NEXT_ACTION.md` | `docs/` 或使用者專案根目錄 | 明確 closeout | 下一個 session | 短期快照，整體重建 |
| `DECISIONS.md` | `docs/` 或使用者專案根目錄 | 明確 owner 能力 | 人類、agent | 有效決策索引，更新或移除 |
| `HANDOFF.md` | `docs/` 或使用者專案根目錄 | `handoff-summary` | 接手的人或工具 | 交接時產生 |
| `QA_REPORT.md` | 使用者專案 | `qa-verification` | 使用者、PR reviewer | 每個功能完成後產生 |
| `DESIGN_REVIEW.md` | 使用者專案 | `design-review` | 使用者、設計師 | 每個前端功能完成後產生 |
| `REPO_MAP.md` | 使用者專案 | `repo-map` | agent、新成員 | 需要時產生，過時時重新產生 |
| Context／Glossary／ADR | 使用者專案既有慣例 | `grill-with-docs` | 未來維護者 | 有實質內容時才建立或更新 |

---

## `docs/` 目錄（maze-coder 自身文件）

GitHub Issue／PR 與 Git 是工作狀態權威；核心文件不重複其事實，也不記錄 agent 或 session 流水帳。只有使用者明確要求對應 owner 能力時才可寫入。

## 四類生命週期

| 類型 | 契約 |
|---|---|
| 短期快照 | `NEXT_ACTION.md` 只保留有效前線；明確 closeout 時整體重建，絕不追加。 |
| 有效索引 | `DECISIONS.md` 只指向唯一權威來源；取代或失效時更新或移除。 |
| 一次性報告 | `HANDOFF.md`、QA／設計報告只綁定單次交付，不跨 session 追加。 |
| 模板／生成物 | 只修改 `skills/*/templates/` 等 canonical，然後以同步腳本生成。 |

**不可放入 `docs/` 的內容**：空白模板、供使用者複製的起始文件。

```
docs/
  spec.md          ← maze-coder 自身的規格書（本文）
  PROJECT_BRIEF.md ← maze-coder 的專案說明
  NEXT_ACTION.md   ← maze-coder 的下一步行動
  DECISIONS.md     ← maze-coder 的有效重大決策索引
  HANDOFF.md       ← maze-coder 的最新交接文件
```

---

## `templates/` 目錄（使用者可攜式範本）

`templates/` 下的文件是供使用者複製到自己專案的**空白起點**，不含 maze-coder 的任何狀態資料。

**重要**：這些檔案由 `sync-adapters.sh` 從 `skills/*/templates/` 同步產生，不得手動編輯根目錄版本。

```
templates/
  spec.md          ← 空白 spec 模板
  AGENTS.md        ← 空白 AGENTS 模板
  PROJECT_BRIEF.md ← 空白專案說明模板
  NEXT_ACTION.md   ← 空白下一步模板
  DECISIONS.md     ← 空白有效決策索引模板
  QA_REPORT.md     ← 空白 QA 報告模板
  DESIGN_REVIEW.md ← 空白設計審查模板
  REPO_MAP.md      ← 空白 Repo Map 模板
  HANDOFF.md       ← 空白交接文件模板
  TASK_PLAN.md     ← 空白任務計畫模板
```

---

## 文件更新責任

| 文件 | 誰負責更新 | 更新時機 |
|---|---|---|
| `spec.md` | `idea-to-spec` / `spec-hardening` 技能 | 需求變更、補強時 |
| `NEXT_ACTION.md` | `session-closeout` | 使用者明確要求 closeout 時整體重建 |
| `DECISIONS.md` | `project-init`／`spec-hardening`／`grill-with-docs` | 使用者明確要求對應能力，且決策仍有效 |
| `HANDOFF.md` | `handoff-summary` 技能 | 交接前 |
| Context／Glossary／ADR | `grill-with-docs` | 術語改變；ADR 三項門檻同時成立時 |
| `templates/` 根目錄 | `sync-adapters.sh` 腳本 | `skills/*/templates/` 變更後 |

---

## 佔位符規範

所有模板中的佔位符一律使用 `[...]` 格式，例如：

- `[專案名稱]`
- `[功能描述]`
- `[日期]`

**禁止使用**：`TODO`、`FIXME`、`your-project-name`、`<placeholder>`、`{variable}` 等格式。

`STATUS.md` 已退休：project-init 不建立、closeout 不讀寫、context-audit 忽略外部舊檔且不自動刪除。`NEXT_ACTION.md` 只能有一項下一階段成果、最多三項動作、阻塞／待決策與必要權威連結；禁止最近完成、完整 Issue／PR 副本與時間序列。`DECISIONS.md` 每項僅一行摘要、狀態與 ADR／Issue／PR 連結；普通、易逆轉選擇與實作經過不得寫入。ADR 只有在決策難以逆轉、缺乏背景將無法理解且存在有意義替代方案與取捨時建立。
