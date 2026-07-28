# Issue 建模規則

## 工作抽取

- 辨識功能、非功能、安全、相容性、測試、文件、遷移、部署、缺陷、技術債、研究、待決策與延後工作。
- 正式 Issue 必須有單一目標、可觀察成果、範圍／非範圍、依賴與可驗收條件，原則上可在一個乾淨 Context Window 內由主要 PR 完成。
- 優先拆成端到端可獨立驗證的垂直切片，不預設按資料庫、API、UI 等水平層拆分。大範圍機械式重構可採 expand–migrate–contract。
- 每個 Issue 記錄阻塞與被阻塞關係；只有所有阻塞均解除的 Issue 屬於可執行前線。
- 過大工作建立 Parent 與 Child Issues；Child 連回 Parent，Parent 僅在所有子項完成後關閉。

## 識別碼與 revision

- 優先使用 spec 明示 Task ID；否則以「spec 相對路徑＋章節錨點＋章節內序號」產生 deterministic ID，不使用 Issue 標題。
- `spec-revision` 優先使用包含該 spec 的 Git commit；檔案未提交時使用 SHA-256。
- 每個 Issue 加入：

```html
<!-- maze-coder
source: docs/spec.md
section: 4.2
spec-revision: abc1234
task-id: authentication-login
-->
```

## 優先級

- 正式 Issue 必須且只能使用一個 P0–P4 或語意相同的既有標籤。
- P0：資料／安全重大風險、核心完全不可用或阻塞所有主要工作。
- P1：核心工作流、近期發布或多個後續任務受阻。
- P2：一般主要功能、Bug、測試或必要整合；為通常基準但仍需理由。
- P3：可延後 UX、效能、重構或技術債。
- P4：小型清理、次要文件、命名或視覺維護。
- P0/P1 無充分證據時詢問，不得自行升級。
- 候選任務使用 `候選任務` 或既有同義標籤，且不得同時有 P0–P4。

## 類別與標籤

- 每個 Issue 至少一個類別：feature、bug、security、documentation、testing、refactor、performance、ui、ux、infrastructure、ci、dependencies、research、breaking-change，或 repo 既有同義標籤。
- 比對名稱、描述、前綴、大小寫與 repo 慣例；例如 enhancement 可取代 feature，`type: bug` 可取代 bug。
- 新標籤必須在 Dry Run 列出名稱、用途與建議顏色，取得確認才建立。缺少建立權限時繼續建立可用標籤的 Issue。

## GitHub 關聯

- Parent/Sub-issue 使用 GitHub 原生關係；可用 `gh issue edit PARENT --add-sub-issue CHILD`。關聯失敗時保留 Issues、回報待重試，不建立副本。
- PR 完整完成 Issue 使用 `Closes #N`；部分完成使用 `Related to #N`。多 Issue 逐一列出，多 PR 只由最後完成全部 AC 的 PR 關閉 Issue。
