# maze-coder — 下一步行動

> 最後同步：2026-07-12

## 下一個 Session 目標

PR #8、PR #9 皆已合併，`v0.1.0` 已透過 Release workflow 成功發布；目前沒有 open PR 或 Issue，工作區與遠端 master 同步。

## 優先行動

1. （可選）在 Ubuntu 與真實 GPT-5.6／較弱本地模型補做動態情境量測。
2. `model-overlays`（`gpt-5.6`／`gemini`／`local-small-model`）目前是設計時猜測寫成，尚未用真實 subagent 針對各模型跑過動態驗證；這是已知的、範圍較大、尚未排入本次工作的後續項目。
3. 之後要發新版本時，直接 push 對應的 `vX.Y.Z` tag 即可觸發 `.github/workflows/release.yml` 自動打包發布。

## 阻塞與待決策

- 無實作阻塞；Ubuntu 與真實模型 trace 為已知未驗證風險（延續自上一輪）。

## 參考

- Issue #5（已關閉）：https://github.com/bext1998/maze-coder/issues/5
- PR #8（已合併）：https://github.com/bext1998/maze-coder/pull/8
- PR #9（已合併）：https://github.com/bext1998/maze-coder/pull/9
- Release v0.1.0：https://github.com/bext1998/maze-coder/releases/tag/v0.1.0
- 規格：docs/spec.md
- 測試結果：docs/TEST_REPORT.md
