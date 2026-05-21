# maze-coder — 決策紀錄

---

## 2026-05-20 — 技能包語言選擇中文

**決策**：SKILL.md 的主要語言使用繁體中文。

**原因**：主要使用者為繁體中文使用者，中文描述更精確且降低理解成本。SKILL.md 的 Section 10.3 明確定義：若使用者用英文呼叫，agent 以使用者語言回應但保持技能邏輯不變。

**影響範圍**：所有 `skills/*/SKILL.md`、adapter 同步輸出。

**狀態**：確認

---

## 2026-05-20 — sync-adapters.sh 採冪等覆蓋策略（OQ-2）

**決策**：每次執行 `sync-adapters.sh` 完整覆寫所有 adapter 檔案，不做差異比對。

**原因**：差異更新容易在技能內容修改後留下過期殘留，導致 INV-5 違反（adapter 與 skills/ 語意不一致）。冪等覆蓋確保 adapter 永遠是 skills/ 的完整映像。

**影響範圍**：`scripts/sync-adapters.sh`、`adapters/` 下所有檔案。

**狀態**：確認（OQ-2 決策）

---

## 2026-05-20 — validate-skillpack.sh 驗證 SKILL.md 結構（OQ-3）

**決策**：用 grep 確認 5 個必要標題（技能目標、前置條件、執行流程、輸出、技能邊界）存在，缺一則 exit 1。

**原因**：只驗證檔案存在不足以確保技能可用；結構驗證確保每個 SKILL.md 都有可執行的工作流。

**影響範圍**：`scripts/validate-skillpack.sh`（AC-3、T-010）。

**狀態**：確認（OQ-3 決策）

---

## 2026-05-20 — skills/*/templates/ 是 source of truth（OQ-4）

**決策**：根目錄 `templates/` 由 `sync-adapters.sh` 從 `skills/*/templates/` 同步，不得手動編輯根目錄版本。

**原因**：避免兩處維護導致內容分歧（INV-8）。技能的模板與技能的工作流應一起維護。

**影響範圍**：`templates/`、`skills/*/templates/`、`sync-adapters.sh`。

**狀態**：確認（OQ-4 決策）

---

## 2026-05-20 — Claude Code adapter 補齊至 11 個技能（OQ-1）

**決策**：`adapters/claude-code/.claude/skills/` 必須包含所有 11 個技能子目錄，原始 spec 只有 7 個為遺漏。

**原因**：所有 adapter 必須包含完整技能集（Section 5 FROZEN），選擇性省略違反 INV-2 的精神。

**影響範圍**：`adapters/claude-code/.claude/skills/`（11 個子目錄）。

**狀態**：確認（OQ-1 決策）
