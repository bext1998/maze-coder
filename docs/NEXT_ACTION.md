# maze-coder — 下一步行動

> 最後同步：2026-07-15

## 下一個 Session 目標

v3.1 Review／GitHub CLI 的 #16–#19 已完成本地實作與驗證。下一步是依使用者授權提交分支、建立 PR，等待 CI／Review 合併後再關閉四張 Issue。

## 優先行動

1. 依使用者授權提交目前分支並建立涵蓋 #16–#19 的 PR，保留逐一 `Closes #N` 關聯。
2. 等待 GitHub CI／Review；確認四張 Issue 的 AC、QA、文件與 PR 合併證據後逐一關閉。
3. 補上 `maze-github-safe-ops` 的 worktree／subagent 派發操作指引。
4. （可選）補 Gemini／較弱本地模型的真實動態驗證；Ubuntu 原生執行仍未驗證。
5. 建立 `release:major`／`release:minor`／`release:patch` labels；PR 合併時帶上對應 label 即可由 `.github/workflows/auto-tag-release.yml` 自動驗證、計算版號並打 tag，再由既有 `release.yml` 打包發布。

## 阻塞與待決策

- 尚未提交／建立 PR；需使用者授權外部 GitHub 發布後才能進入 Review／Merge。
- Gemini／本地弱模型與 Ubuntu 原生執行仍是已知未驗證風險。

## 參考

- Issue #5（已關閉）：https://github.com/bext1998/maze-coder/issues/5
- PR #8（已合併）：https://github.com/bext1998/maze-coder/pull/8
- PR #9（已合併）：https://github.com/bext1998/maze-coder/pull/9
- PR #10（已合併）：https://github.com/bext1998/maze-coder/pull/10
- PR #11（已合併）：https://github.com/bext1998/maze-coder/pull/11
- PR #12（已合併）：https://github.com/bext1998/maze-coder/pull/12
- Release v0.1.1：https://github.com/bext1998/maze-coder/releases/tag/v0.1.1
- Release v0.1.0：https://github.com/bext1998/maze-coder/releases/tag/v0.1.0
- 規格：docs/spec.md
- 測試結果：docs/TEST_REPORT.md
