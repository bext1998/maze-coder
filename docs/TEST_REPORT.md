# maze-coder 測試報告

> 執行時間：2026-05-20
> 測試範圍：T-004 ~ T-008（技能功能驗證 + Adapter 完整性 + 可攜性）
> 執行者：opencode agent（自動化腳本 `validate-skills-functional.sh`）

---

## 測試摘要

| 測試 ID | 描述 | 結果 | 備註 |
|---|---|---|---|
| T-004 | `idea-to-spec` 技能功能驗證 | ✅ **通過** | Phase 0-3 完整，引用 7 個必要 section |
| T-005 | `spec-hardening` 技能功能驗證 | ✅ **通過** | Phase 0-8 完整，8 個補強區塊全部存在 |
| T-006 [FROZEN] | `github-safe-ops` force push 安全機制 | ✅ **通過** | 警告文字正確，Output Contract 無危險指令 |
| T-007 | Codex Adapter 技能完整性 | ✅ **通過** | AGENTS.md 包含全部 11 個技能區塊 |
| T-008 | Linux 環境可攜性測試 | ✅ **通過** | `validate-skillpack.sh` exit 0，輸出「All checks passed」 |

**整體結果：5/5 通過，0 失敗**

---

## 詳細結果

### T-004：idea-to-spec 功能驗證

驗證項目：
- ✅ Phase 0：評估輸入
- ✅ Phase 1：釐清核心問題
- ✅ Phase 2：產出 spec.md
- ✅ Phase 3：確認
- ✅ 引用 spec.template.md 7 個必要 section（專案概述、核心問題、目標、非目標、功能清單、技術考量、成功指標）
- ✅ Output Contract 明確要求「所有必要 section」

檢查檔案：`skills/idea-to-spec/SKILL.md`

---

### T-005：spec-hardening 功能驗證

驗證項目：
- ✅ Phase 0-8 全部存在（讀取原始 spec → Contract → Invariants → Edge Cases → AC → Test Plan → FROZEN → Drift Risk → OQ）
- ✅ 8 個補強區塊名稱全部出現（Contract、Invariants、Edge Cases、Acceptance Criteria、Test Plan、FROZEN、Drift Risk、Open Questions）
- ✅ Output Contract 明確要求「8 個補強區塊」且「缺一不可」

檢查檔案：`skills/spec-hardening/SKILL.md`

---

### T-006 [FROZEN]：github-safe-ops 安全機制

驗證項目：
- ✅ 風險等級表正確標記 `git push --force` 為「極高」/「禁止」
- ✅ 包含嚴格匹配警告文字：「Force push 到 main / master 可能覆蓋其他人的工作」
- ✅ **Output Contract 區段內無 `git push --force` 指令**（區段級負向驗證）
- ✅ 提供替代方案（`git revert`）

檢查檔案：`skills/github-safe-ops/SKILL.md`

---

### T-007：Codex Adapter 完整性

驗證項目：
- ✅ `adapters/codex/AGENTS.md` 包含全部 11 個技能區塊
- 技能清單：`idea-to-spec`、`spec-hardening`、`project-init`、`session-closeout`、`github-safe-ops`、`design-review`、`qa-verification`、`repo-map`、`context-audit`、`bug-reproduction`、`handoff-summary`

檢查檔案：`adapters/codex/AGENTS.md`

---

### T-008：Linux 可攜性測試

驗證項目：
- ✅ 執行環境為 Linux（`uname -s` = Linux）
- ✅ `validate-skillpack.sh` 執行後 exit 0
- ✅ 輸出包含「All checks passed」

執行指令：`bash scripts/validate-skillpack.sh`

---

## 測試腳本資訊

- **腳本名稱**：`scripts/validate-skills-functional.sh`
- **建立時間**：2026-05-20
- **對應規格**：`docs/spec.md` Section 12（Test Plan）
- **驗證方式**：嚴格字串匹配 + 區段級負向驗證（T-006）
- **冪等性**：是（每次執行獨立驗證，不依賴前次狀態）

---

## T-010：驗證缺少 section 時 exit 1（2026-05-20）

**目標**：建立缺少「技能邊界」section 的 SKILL.md，`validate-skillpack.sh` exit 1 並列出檔案路徑。

**執行步驟**：
1. 複製 `skills/maze-idea-to-spec/SKILL.md` 並移除「技能邊界」section
2. 執行 `bash scripts/validate-skillpack.sh`
3. 確認 exit code = 1 且輸出含 `[FAIL] skills/maze-idea-to-spec/SKILL.md 缺少必要標題：「技能邊界」`
4. 還原原始 SKILL.md

**結果**：
- ✅ exit code = 1
- ✅ 輸出列出 `skills/maze-idea-to-spec/SKILL.md` 缺少「技能邊界」
- ✅ 還原後 validate-skillpack.sh exit 0

---

## T-011：sync-adapters.sh 冪等性（2026-05-20）

**目標**：執行兩次 sync-adapters.sh，第二次輸出含「no changes」並 exit 0。

**執行步驟**：
1. 第一次執行 `bash scripts/sync-adapters.sh`
2. 第二次執行 `bash scripts/sync-adapters.sh`
3. 確認第二次輸出含「synced（no changes）」且 exit 0

**結果**：
- ✅ 第一次同步：codex AGENTS.md、opencode AGENTS.md、4 個 cursor .mdc（因 `maze-` 前綴更新）
- ✅ 第二次輸出：`=== synced（no changes）===`
- ✅ exit 0

---

## T-012：docs/ 無空白模板佔位符（2026-05-20）

**目標**：`docs/` 目錄下不存在任何 `[...]` 佔位符格式的空白模板。

**執行步驟**：
1. `grep -rn "^\[.*\]$\|: \[.*\]$" docs/STATUS.md docs/NEXT_ACTION.md docs/DECISIONS.md docs/HANDOFF.md docs/PROJECT_BRIEF.md docs/TEST_REPORT.md`
2. 確認無輸出

**結果**：
- ✅ `docs/` 下所有文件均為已填寫的專案文件，無空白模板
- ✅ `spec.md` 中的 `[...]` 均為說明文字（技能邊界說明、AC 描述），非實際佔位欄位

---

## 測試總結（Phase 1 完成）

| 測試 ID | 描述 | 狀態 |
|---|---|---|
| T-001 ~ T-003 | 結構驗證（FROZEN） | ✅ 通過 |
| T-004 ~ T-009 | 技能功能 / Adapter 一致性 / 迴歸 | ✅ 通過 |
| T-010 | 缺少 section 時 validate exit 1 | ✅ 通過 |
| T-011 | sync-adapters.sh 冪等性 | ✅ 通過 |
| T-012 | `docs/` 無空白模板佔位符 | ✅ 通過 |

---

## 補充測試（2026-05-20 同一 Session）

### T-009：迴歸測試

**目標**：修改 `skills/qa-verification/SKILL.md` 後，`validate-skillpack.sh` 仍 exit 0。

**執行步驟**：
1. 在 `skills/qa-verification/SKILL.md` 末尾新增無害註釋
2. 執行 `bash scripts/validate-skillpack.sh`
3. 確認 exit 0 且輸出「All checks passed」
4. 回復修改

**結果**：
- ✅ `skills/qa-verification/SKILL.md` 修改後結構仍完整
- ✅ `validate-skillpack.sh` exit 0
- ✅ 輸出包含「All checks passed」
- ✅ 修改已回復，repo 保持乾淨

**結論**：驗證腳本僅檢查結構（section 標題存在性），不檢查內容細節，符合設計預期。**T-009 通過**。

---

### 清理行動

**項目**：刪除根目錄舊版 `maze-coder-spec-hardened.md`

**原因**：`docs/spec.md` v1.3 已是 source of truth，根目錄舊版造成混淆。

**結果**：✅ 檔案已刪除，專案結構清理完成。

---

## 附錄：測試執行原始輸出

```
=== T-004: idea-to-spec functional validation ===
  [OK]   Contains Phase 0
  [OK]   Contains Phase 1
  [OK]   Contains Phase 2
  [OK]   Contains Phase 3
  [OK]   References spec section: 專案概述
  [OK]   References spec section: 核心問題
  [OK]   References spec section: 目標
  [OK]   References spec section: 非目標
  [OK]   References spec section: 功能清單
  [OK]   References spec section: 技術考量
  [OK]   References spec section: 成功指標
  [OK]   Output Contract references spec.template.md
  [OK]   Output Contract requires all necessary sections

=== T-005: spec-hardening functional validation ===
  [OK]   Contains Phase 0
  [OK]   Contains Phase 1
  [OK]   Contains Phase 2
  [OK]   Contains Phase 3
  [OK]   Contains Phase 4
  [OK]   Contains Phase 5
  [OK]   Contains Phase 6
  [OK]   Contains Phase 7
  [OK]   Contains Phase 8
  [OK]   Contains hardening block: Contract
  [OK]   Contains hardening block: Invariants
  [OK]   Contains hardening block: Edge Cases
  [OK]   Contains hardening block: Acceptance Criteria
  [OK]   Contains hardening block: Test Plan
  [OK]   Contains hardening block: FROZEN
  [OK]   Contains hardening block: Drift Risk
  [OK]   Contains hardening block: Open Questions
  [OK]   Output Contract mentions 8 hardening blocks
  [OK]   Output Contract requires all 8 blocks (缺一不可)

=== T-006 [FROZEN]: github-safe-ops functional validation ===
  [OK]   Risk table correctly labels force push as high risk / forbidden
  [OK]   Contains explicit warning for force push to main/master
  [OK]   Output Contract does not contain 'git push --force' instruction
  [OK]   Contains alternative solution guidance

=== T-007: codex/AGENTS.md skill completeness ===
  [OK]   AGENTS.md contains skill: idea-to-spec
  [OK]   AGENTS.md contains skill: spec-hardening
  [OK]   AGENTS.md contains skill: project-init
  [OK]   AGENTS.md contains skill: session-closeout
  [OK]   AGENTS.md contains skill: github-safe-ops
  [OK]   AGENTS.md contains skill: design-review
  [OK]   AGENTS.md contains skill: qa-verification
  [OK]   AGENTS.md contains skill: repo-map
  [OK]   AGENTS.md contains skill: context-audit
  [OK]   AGENTS.md contains skill: bug-reproduction
  [OK]   AGENTS.md contains skill: handoff-summary

=== T-008: validate-skillpack.sh portability (Linux) ===
  [OK]   Running on Linux
  [OK]   validate-skillpack.sh exits 0
  [OK]   Output contains 'All checks passed'

=== All functional checks passed (T-004 ~ T-008) ===
```
