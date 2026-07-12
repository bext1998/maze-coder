# maze-coder — 下一步行動

> 最後同步：2026-07-12

## 下一個 Session 目標

PR #11、PR #12 皆已合併，`v0.1.1` 已透過 Release workflow 成功發布（新增 `maze-skill-authoring` 技能、PRINCIPLES.md 防呆原則、對抗式壓力驗證方法論；技能總數 18→19）。目前沒有 open PR 或 Issue。

## 優先行動

1. 把 `maze-github-safe-ops` 的兩個功能性擴充補上（code review 結構化 checklist、worktree／subagent 派發操作指引）——已決定不開新技能、併入既有技能，但尚未動手。
2. 清理已合併分支：worktree `.worktrees/maze-2026-07-12-49314a`、遠端分支 `maze/2026-07-12-49314a` 與 `maze/2026-07-12-6f2a1c`（先前已暫停，待使用者指示再繼續）。
3. （可選）比照這次對 GPT-5.6／Claude 的驗證方式，補 Gemini／較弱本地模型的真實動態驗證；Ubuntu 原生執行仍未驗證。
4. 新增 `.github/workflows/auto-tag-release.yml`：PR 合併時若帶有 `release:major`／`release:minor`／`release:patch` label，會自動驗證、算下一個版號、打 tag（tag 訊息含 PR 標題與描述），再由既有 `release.yml` 接手打包發布。label 需在 PR merge 當下就存在才會觸發；GitHub 上還沒建立這三個 label，需要先建立才能用。仍保留手動 push `vX.Y.Z` tag 的舊路徑。

## 阻塞與待決策

- 無實作阻塞。Gemini／本地弱模型與 Ubuntu 原生執行仍是已知未驗證風險（範圍縮小：GPT-5.6／Claude 已對 risk-driven-tdd 做過真實驗證）。

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
