# maze-coder — 當前狀態

> 最後更新：2026-05-20 — Phase 1 完成，T-001 ~ T-012 全部通過，`maze-` 前綴落地，完全符合 spec v1.4

---

## 當前階段

Phase 1 完成，進入迴歸驗證與後續維護。

---

## 已完成

- 規格書補強（v1.4，所有 OQ 確認，INV-7 `maze-` 前綴落地）
- `core/` 下 4 個基礎文件
- 11 個 `skills/maze-*/SKILL.md` + 附屬 templates / checklists（**含 `maze-` 前綴**）
- `scripts/validate-skills-functional.sh`（T-004 ~ T-008 通過）
- T-009 迴歸測試通過（修改 SKILL.md 後 validate-skillpack.sh 仍 exit 0）
- T-010 通過：缺少「技能邊界」時 validate exit 1，列出檔案路徑
- T-011 通過：sync-adapters.sh 第二次執行輸出「no changes」，exit 0
- T-012 通過：`docs/` 目錄下無空白模板佔位符
- 清理根目錄舊版 `maze-coder-spec-hardened.md`（`docs/spec.md` v1.4 為 source of truth）
- `scripts/sync-adapters.sh`（冪等覆蓋，SKILLS array 含 `maze-` 前綴）
- `scripts/validate-skillpack.sh`（SKILLS array 含 `maze-` 前綴）
- `adapters/claude-code/`（11 個 `maze-*` 技能 SKILL.md）
- `adapters/codex/AGENTS.md`
- `adapters/cursor/.cursor/rules/`（4 個 .mdc）
- `adapters/opencode/AGENTS.md`
- `templates/`（11 個使用者範本，由 sync-adapters.sh 同步）
- `docs/`（自身專案文件）
- `README.md`、`LICENSE`

---

## 進行中

無

---

## 待完成（後續 Sprint）

無。Phase 1 已全數完成，完全符合 spec v1.4。

---

## 已決策（本次 Session）

- **不建立 git repo**（保持純檔案系統，無版本控制依賴）

---

## 已知問題

無

---

## 阻塞項目

無
