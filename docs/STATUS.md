# maze-coder — 當前狀態

> 最後同步：2026-07-12
> Branch：maze/2026-07-12-49314a（worktree：`.worktrees/maze-2026-07-12-49314a`）
> Working tree：clean；已推送至 origin，對應 PR #11（待合併）

## 進行中 Issues

- 無

## 阻塞 Issues

- 無

## 等待 Review

- 無

## 等待 Merge

- PR #11：新增 `maze-skill-authoring` 技能與 PRINCIPLES.md 防呆原則（技能數 18→19）＋對抗式壓力驗證方法論；已對 `maze-risk-driven-tdd` 做 6 組壓力測試（3 組 Claude、3 組真實 Codex/gpt-5.6-luna）全數守住，`model-overlays/gpt-5.6.md` 首次有真實動態驗證紀錄。

## 已合併待關閉

- 無

## 最近完成

- PR #10：pre-push checklist 補上平行分支重疊檔案需開獨立 worktree 的提醒，並收緊 risk-driven-tdd 的根因分析要求；已合併（2026-07-12）。
- PR #9：新增 tag 觸發的 Release workflow（`.github/workflows/release.yml`）；push `v*` tag 時跑 `validate-skillpack.sh`／`validate-skills-functional.sh`／`validate-adaptive-scenarios.sh` 與 adapter 同步檢查，再打包 `adapters/`＋`README.md`＋`LICENSE` 成 zip 附到 GitHub Release。已合併並實測：`v0.1.0` tag 推送後 workflow 11 秒內成功產出 [Release v0.1.0](https://github.com/bext1998/maze-coder/releases/tag/v0.1.0)。
- PR #8：adaptive skillpack architecture 重構已合併至 master（2026-07-12）；18 個 canonical skills、3 個 Guidance Profiles、4 個 Model Overlays、4 套 Adapter 與 10 組代表性情境驗證併入 master。
- #5：Spec → GitHub Issues 工作流、Session Closeout 重構與 Token 效率優化；PR #6 已合併、Issue #5 已關閉（2026-07-10）。

## 未追蹤本機工作

- `maze-github-safe-ops` 的兩個功能性擴充（code review 結構化 checklist、worktree／subagent 派發操作指引）已決定做法但尚未動手，無對應 Issue。
- PR #8、PR #9、PR #10、PR #11 均無可確認的 Issue 關聯，未使用 `Closes` 或 `Related to`（延續先前 session 已記錄的判斷）。
- Gemini／較弱本地模型的真實動態驗證與 Ubuntu 原生執行尚未做（範圍縮小：GPT-5.6／Claude 已對 risk-driven-tdd 完成真實壓力測試）。
