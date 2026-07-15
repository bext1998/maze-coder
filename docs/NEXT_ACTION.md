# maze-coder — 下一步行動

> 最後同步：2026-07-15

## 下一個 Session 目標

v3.1 Review／GitHub CLI 規格已完成本地決策，canonical source 為 `docs/spec.md`。下一步是在取得遠端寫入確認後建立 `ready-for-agent` label 與單一規格 Issue，再依 MCR-31-001 至 MCR-31-004 實作。

## 優先行動

1. 預覽並確認 GitHub 寫入後，建立 `ready-for-agent` label 與「新增 spec review、PR review 與安全 GitHub CLI 能力」Issue；不設定 Assignee、不拆子 Issue。
2. 依規格實作 `maze-spec-review`、internal `maze-github-cli`、`maze-pr-review`，最後同步 Router、Adapter、文件與 validators。
3. 補上 `maze-github-safe-ops` 的 worktree／subagent 派發操作指引；原 code review checklist 待辦已由 `maze-pr-review` 取代。
4. 清理已合併分支：worktree `.worktrees/maze-2026-07-12-49314a`、遠端分支 `maze/2026-07-12-49314a` 與 `maze/2026-07-12-6f2a1c`（先前已暫停，待使用者指示再繼續）。
5. （可選）補 Gemini／較弱本地模型的真實動態驗證；Ubuntu 原生執行仍未驗證。

## 阻塞與待決策

- 遠端 Issue 尚待使用者確認寫入預覽；技能實作本身無其他阻塞。
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
