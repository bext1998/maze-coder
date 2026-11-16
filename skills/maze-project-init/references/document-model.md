# 文件系統模型

> **受眾：AI agent + 人類維護者**
> 本文件說明專案中各類文件的用途、生命週期與維護責任；由 `maze-project-init` 在建立專案文件時引用。

---

## 文件類型總覽

| 文件 | 位置 | 生產者 | 消費者 | 生命週期 |
|---|---|---|---|---|
| `spec.md` | `docs/` 或專案根目錄 | `idea-to-spec` → `spec-hardening` | 所有技能、使用者 | 專案期間持續更新 |
| `PROJECT_BRIEF.md` | `docs/` 或專案根目錄 | `project-init` | 人類、agent | 專案初期建立，偶爾更新 |
| `NEXT_ACTION.md` | `docs/` 或專案根目錄 | 明確 closeout | 下一個 session | 短期快照，整體重建 |
| `DECISIONS.md` | `docs/` 或專案根目錄 | 明確 owner 能力 | 人類、agent | 有效決策索引，更新或移除 |
| `HANDOFF.md` | `docs/` 或專案根目錄 | `handoff-summary` | 接手的人或工具 | 交接時產生 |
| `QA_REPORT.md` | 使用者專案 | `qa-verification` | 使用者、PR reviewer | 每個功能完成後產生 |
| `DESIGN_REVIEW.md` | 使用者專案 | `design-review` | 使用者、設計師 | 每個前端功能完成後產生 |
| `REPO_MAP.md` | 使用者專案 | `repo-map` | agent、新成員 | 需要時產生，過時時重新產生 |
| Context／Glossary／ADR | 使用者專案既有慣例 | `grill-with-docs` | 未來維護者 | 有實質內容時才建立或更新 |

---

## 四類生命週期

| 類型 | 契約 |
|---|---|
| 短期快照 | `NEXT_ACTION.md` 只保留有效前線；明確 closeout 時整體重建，絕不追加。 |
| 有效索引 | `DECISIONS.md` 只指向唯一權威來源；取代或失效時更新或移除。 |
| 一次性報告 | `HANDOFF.md`、QA／設計報告只綁定單次交付，不跨 session 追加。 |
| 模板 | 只使用技能隨附的 `templates/`，不自行複製到專案根目錄另存一份。 |

**不可放入專案文件的內容**：空白模板、供他人複製的起始文件、agent 或 session 流水帳。工作狀態權威是 GitHub Issue／PR 與 Git，核心文件不重複其事實。

---

## 模板來源

各技能隨附自己的 `templates/`，安裝技能時一起取得，不另外複製到專案根目錄：

```text
skills/maze-bug-reproduction/templates/BUG_REPRODUCTION.template.md
skills/maze-design-review/templates/DESIGN_REVIEW.template.md
skills/maze-design-system/templates/DESIGN_SYSTEM.template.md
skills/maze-gui-prototyping/templates/PROTOTYPE_BRIEF.template.md
skills/maze-handoff-summary/templates/HANDOFF.template.md
skills/maze-idea-to-spec/templates/spec.template.md
skills/maze-project-init/templates/AGENTS.template.md
skills/maze-project-init/templates/DECISIONS.template.md
skills/maze-project-init/templates/MAZE_PROJECT.template.md
skills/maze-project-init/templates/NEXT_ACTION.template.md
skills/maze-project-init/templates/PROJECT_BRIEF.template.md
skills/maze-qa-verification/templates/QA_REPORT.template.md
skills/maze-repo-map/templates/REPO_MAP.template.md
skills/maze-spec-review/templates/SPEC_REVIEW.template.md
skills/maze-spec-to-issues/templates/issue.template.md
skills/maze-wayfinder/templates/WAYFINDER_MAP.template.md
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

---

## 佔位符規範

所有模板中的佔位符一律使用 `[...]` 格式，例如：

- `[專案名稱]`
- `[功能描述]`
- `[日期]`

**禁止使用**：`TODO`、`FIXME`、`your-project-name`、`<placeholder>`、`{variable}` 等格式。

`STATUS.md` 已退休：project-init 不建立、closeout 不讀寫、context-audit 忽略外部舊檔且不自動刪除。`NEXT_ACTION.md` 只能有一項下一階段成果、最多三項動作、阻塞／待決策與必要權威連結；禁止最近完成、完整 Issue／PR 副本與時間序列。`DECISIONS.md` 每項僅一行摘要、狀態與 ADR／Issue／PR 連結；普通、易逆轉選擇與實作經過不得寫入。ADR 只有在決策難以逆轉、缺乏背景將無法理解且存在有意義替代方案與取捨時建立。
