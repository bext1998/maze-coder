# maze-coder — 下一步行動

> 最後同步：2026-07-12

## 下一個 Session 目標

PR #10 已合併。本地新增 `maze-skill-authoring` 技能（判斷何時該新增 vs. 擴充既有技能）與 `core/PRINCIPLES.md` 第 8 節防呆原則，技能總數由 18 增至 19（17 公開＋2 internal）；目的是避免技能包在參考 superpowers 等其他技能包時無節制膨脹。已跑過 `sync-adapters.sh`（二次執行 no changes）、`validate-skillpack.sh`、`validate-skills-functional.sh`、`validate-adaptive-scenarios.sh`，全部通過，尚未提交或建立 PR。

## 優先行動

1. 確認本次新增內容後提交並開 PR（`maze-skill-authoring` 技能＋ PRINCIPLES.md 防呆原則）。
2. （可選）在 Ubuntu 與真實 GPT-5.6／較弱本地模型補做動態情境量測。
3. `model-overlays`（`gpt-5.6`／`gemini`／`local-small-model`）目前是設計時猜測寫成，尚未用真實 subagent 針對各模型跑過動態驗證；這是已知的、範圍較大、尚未排入本次工作的後續項目。
4. 之後要發新版本時，直接 push 對應的 `vX.Y.Z` tag 即可觸發 `.github/workflows/release.yml` 自動打包發布。

## 阻塞與待決策

- 無實作阻塞；Ubuntu 與真實模型 trace 為已知未驗證風險（延續自上一輪）。

## 參考

- Issue #5（已關閉）：https://github.com/bext1998/maze-coder/issues/5
- PR #8（已合併）：https://github.com/bext1998/maze-coder/pull/8
- PR #9（已合併）：https://github.com/bext1998/maze-coder/pull/9
- PR #10（已合併）：https://github.com/bext1998/maze-coder/pull/10
- Release v0.1.0：https://github.com/bext1998/maze-coder/releases/tag/v0.1.0
- 規格：docs/spec.md
- 測試結果：docs/TEST_REPORT.md
