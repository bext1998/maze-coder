# 文件系統模型

> **受眾：AI agent + 人類維護者**
> 本文件說明 maze-coder 中各類文件的用途、生命週期與維護責任。

---

## 文件類型總覽

| 文件 | 位置 | 生產者 | 消費者 | 生命週期 |
|---|---|---|---|---|
| `spec.md` | `docs/` 或使用者專案根目錄 | `idea-to-spec` → `spec-hardening` | 所有技能、使用者 | 專案期間持續更新 |
| `PROJECT_BRIEF.md` | `docs/` 或使用者專案根目錄 | `project-init` | 人類、agent | 專案初期建立，偶爾更新 |
| `STATUS.md` | `docs/` 或使用者專案根目錄 | `session-closeout` | 下一個 session | 每個 session 更新 |
| `NEXT_ACTION.md` | `docs/` 或使用者專案根目錄 | `session-closeout` | 下一個 session | 每個 session 更新 |
| `DECISIONS.md` | `docs/` 或使用者專案根目錄 | `project-init`、使用者 | 人類、agent | 每次重大決策後追加 |
| `HANDOFF.md` | `docs/` 或使用者專案根目錄 | `handoff-summary` | 接手的人或工具 | 交接時產生 |
| `QA_REPORT.md` | 使用者專案 | `qa-verification` | 使用者、PR reviewer | 每個功能完成後產生 |
| `DESIGN_REVIEW.md` | 使用者專案 | `design-review` | 使用者、設計師 | 每個前端功能完成後產生 |
| `REPO_MAP.md` | 使用者專案 | `repo-map` | agent、新成員 | 需要時產生，過時時重新產生 |

---

## `docs/` 目錄（maze-coder 自身文件）

`docs/` 下的文件記錄 maze-coder **專案本身**的狀態與決策，帶有特定時間點的語境。

**不可放入 `docs/` 的內容**：空白模板、供使用者複製的起始文件。

```
docs/
  spec.md          ← maze-coder 自身的規格書（本文）
  PROJECT_BRIEF.md ← maze-coder 的專案說明
  STATUS.md        ← maze-coder 目前的開發狀態
  NEXT_ACTION.md   ← maze-coder 的下一步行動
  DECISIONS.md     ← maze-coder 的歷史決策紀錄
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
  STATUS.md        ← 空白狀態模板
  NEXT_ACTION.md   ← 空白下一步模板
  DECISIONS.md     ← 空白決策紀錄模板
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
| `STATUS.md` | `session-closeout` 技能 | 每個 coding session 結束 |
| `NEXT_ACTION.md` | `session-closeout` 技能 | 每個 coding session 結束 |
| `DECISIONS.md` | 使用者 / `project-init` 技能 | 每次重大決策 |
| `HANDOFF.md` | `handoff-summary` 技能 | 交接前 |
| `templates/` 根目錄 | `sync-adapters.sh` 腳本 | `skills/*/templates/` 變更後 |

---

## 佔位符規範

所有模板中的佔位符一律使用 `[...]` 格式，例如：

- `[專案名稱]`
- `[功能描述]`
- `[日期]`

**禁止使用**：`TODO`、`FIXME`、`your-project-name`、`<placeholder>`、`{variable}` 等格式。
