# maze-coder — 當前狀態

> 最後同步：2026-07-15
> Branch：maze/2026-07-15-07eb5bs
> Working tree：clean；commit `86e245e` 已推送，draft PR #20 已建立

## 進行中 Issues

- #16、#17、#18、#19：由 draft PR #20 關聯，實作與適用 validator 已完成，尚待 Review、合併及關閉。

## 阻塞 Issues

- 無

## 等待 Review

- PR #20：draft，目標 `master`，尚待標記 ready、Review／CI。

## 等待 Merge

- 無

## 已合併待關閉

- 無

## 最近完成

- #16–#19：PR #20 已建立；新增 `maze-spec-review`、`maze-github-cli`、`maze-pr-review`，完成 safe-ops、Router、四種 Adapter、文件、templates、validators 與 11 組 adaptive scenarios；三支 validator 全數通過。
- Release `v0.1.1`：新增 `maze-skill-authoring` 技能與對抗式壓力驗證方法論後發布；push tag 後 workflow 12 秒內成功產出 [Release v0.1.1](https://github.com/bext1998/maze-coder/releases/tag/v0.1.1)。
- PR #12：補上 PR #11 合併時漏掉的兩個 commit——對抗式壓力驗證方法論（`references/adversarial-resilience-check.md`）與 `docs/NEXT_ACTION.md`／`docs/STATUS.md` 的壓力測試紀錄；已合併（2026-07-12）。
- PR #11：新增 `maze-skill-authoring` 技能（判斷何時該新增 vs. 擴充既有技能）與 `core/PRINCIPLES.md` 第 8 節防呆原則，技能總數 18→19（17 公開＋2 internal）；已合併（2026-07-12）。用對抗式壓力驗證方法論對 `maze-risk-driven-tdd` 做了 6 組壓力測試（3 組 Claude subagent、3 組真實 `codex exec -m gpt-5.6-luna`），涵蓋根因 vs 症狀修補、sleep vs condition-based waiting、機械重構豁免濫用，全數守住；`model-overlays/gpt-5.6.md` 首次有真實動態驗證紀錄。
- PR #10：pre-push checklist 補上平行分支重疊檔案需開獨立 worktree 的提醒，並收緊 risk-driven-tdd 的根因分析要求；已合併（2026-07-12）。
- PR #9：新增 tag 觸發的 Release workflow（`.github/workflows/release.yml`）；已合併並實測：`v0.1.0` tag 推送後 workflow 11 秒內成功產出 [Release v0.1.0](https://github.com/bext1998/maze-coder/releases/tag/v0.1.0)。

## 未追蹤本機工作

- `maze-github-safe-ops` 的 worktree／subagent 派發操作指引仍未完成；原 code review checklist 待辦已由 #18 取代。
- Gemini／較弱本地模型的真實動態驗證與 Ubuntu 原生執行尚未做（範圍縮小：GPT-5.6／Claude 已對 risk-driven-tdd 完成真實壓力測試）。
- 兩個已合併分支的清理尚未完成：worktree `.worktrees/maze-2026-07-12-49314a` 與遠端分支 `maze/2026-07-12-49314a`、`maze/2026-07-12-6f2a1c`（使用者已暫停，之後再處理）。
- PR #8、PR #9、PR #10、PR #11、PR #12 均無可確認的 Issue 關聯，未使用 `Closes` 或 `Related to`（延續先前 session 已記錄的判斷）。
