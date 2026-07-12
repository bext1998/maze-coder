# maze-coder — 當前狀態

> 最後同步：2026-07-12
> Branch：maze/2026-07-12-564d3b
> Working tree：dirty；commit `a50532a`（PR #10 已合併）之上有未提交的本機變更（`maze-skill-authoring` 技能＋ PRINCIPLES.md 防呆原則）

## 進行中 Issues

- 無

## 阻塞 Issues

- 無

## 等待 Review

- 無

## 等待 Merge

- 無

## 已合併待關閉

- 無

## 最近完成

- PR #10：pre-push checklist 補上平行分支重疊檔案需開獨立 worktree 的提醒，並收緊 risk-driven-tdd 的根因分析要求；已合併（2026-07-12）。
- PR #9：新增 tag 觸發的 Release workflow（`.github/workflows/release.yml`）；push `v*` tag 時跑 `validate-skillpack.sh`／`validate-skills-functional.sh`／`validate-adaptive-scenarios.sh` 與 adapter 同步檢查，再打包 `adapters/`＋`README.md`＋`LICENSE` 成 zip 附到 GitHub Release。已合併並實測：`v0.1.0` tag 推送後 workflow 11 秒內成功產出 [Release v0.1.0](https://github.com/bext1998/maze-coder/releases/tag/v0.1.0)。
- PR #8：adaptive skillpack architecture 重構已合併至 master（2026-07-12）；18 個 canonical skills、3 個 Guidance Profiles、4 個 Model Overlays、4 套 Adapter 與 10 組代表性情境驗證併入 master。
- #5：Spec → GitHub Issues 工作流、Session Closeout 重構與 Token 效率優化；PR #6 已合併、Issue #5 已關閉（2026-07-10）。

## 未追蹤本機工作

- 新增 `maze-skill-authoring` 技能與 `core/PRINCIPLES.md` 第 8 節防呆原則（技能總數 18→19），已通過 `sync-adapters.sh`（二次執行 no changes）、`validate-skillpack.sh`、`validate-skills-functional.sh`、`validate-adaptive-scenarios.sh`；尚未提交、無對應 Issue／PR。
- PR #8、PR #9、PR #10 均無可確認的 Issue 關聯，未使用 `Closes` 或 `Related to`（延續先前 session 已記錄的判斷）。
- Ubuntu 原生執行與真實外部模型 trace 尚未驗證（延續自上一輪，本次未處理）。
