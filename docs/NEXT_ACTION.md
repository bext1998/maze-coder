# maze-coder — 下一步行動

> 最後同步：2026-07-12

## 下一個 Session 目標

PR #11 已開（`maze-skill-authoring` 技能＋ PRINCIPLES.md 第 8 節防呆原則，技能總數 18→19；另加對抗式壓力驗證方法論 `references/adversarial-resilience-check.md`），已推送兩個 commit，尚未合併。

用該驗證方法論對 `maze-risk-driven-tdd` 做了 6 組壓力測試（3 組 Claude subagent＋3 組真實 `codex exec -m gpt-5.6-luna`），涵蓋根因 vs 症狀修補、sleep 蒙混 vs condition-based waiting、機械重構豁免濫用；**6 組全數守住**（其中 Codex 那組 B 因本機 PowerShell runner 讀檔失敗、改依技能名稱與題目摘要作答，證據強度較弱，已如實記錄）。這是 `model-overlays/gpt-5.6.md` 第一次有真實 subagent 動態驗證紀錄，不再是純設計時猜測。

## 優先行動

1. PR #11 待 review／合併。
2. 把 `maze-github-safe-ops` 的兩個功能性擴充補上（code review 結構化 checklist、worktree／subagent 派發操作指引）——上一輪已決定不開新技能、併入既有技能，但尚未動手。
3. （可選）比照這次的 Codex 驗證方式，補 Gemini／較弱本地模型的真實動態驗證；Ubuntu 原生執行仍未驗證。
4. 之後要發新版本時，直接 push 對應的 `vX.Y.Z` tag 即可觸發 `.github/workflows/release.yml` 自動打包發布。

## 阻塞與待決策

- 無實作阻塞。Gemini／本地弱模型與 Ubuntu 原生執行仍是已知未驗證風險（範圍縮小：GPT-5.6／Claude 已對 risk-driven-tdd 做過真實驗證）。

## 參考

- Issue #5（已關閉）：https://github.com/bext1998/maze-coder/issues/5
- PR #8（已合併）：https://github.com/bext1998/maze-coder/pull/8
- PR #9（已合併）：https://github.com/bext1998/maze-coder/pull/9
- PR #10（已合併）：https://github.com/bext1998/maze-coder/pull/10
- PR #11（待合併）：https://github.com/bext1998/maze-coder/pull/11
- Release v0.1.0：https://github.com/bext1998/maze-coder/releases/tag/v0.1.0
- 規格：docs/spec.md
- 測試結果：docs/TEST_REPORT.md
