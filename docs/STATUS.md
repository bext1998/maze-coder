# maze-coder — 當前狀態

> 最後同步：2026-07-12
> Branch：master
> Working tree：clean；commit `65307de`（tag `v0.1.0`）已推送

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

- PR #9：新增 tag 觸發的 Release workflow（`.github/workflows/release.yml`）；push `v*` tag 時跑 `validate-skillpack.sh`／`validate-skills-functional.sh`／`validate-adaptive-scenarios.sh` 與 adapter 同步檢查，再打包 `adapters/`＋`README.md`＋`LICENSE` 成 zip 附到 GitHub Release。已合併並實測：`v0.1.0` tag 推送後 workflow 11 秒內成功產出 [Release v0.1.0](https://github.com/bext1998/maze-coder/releases/tag/v0.1.0)。
- PR #8：adaptive skillpack architecture 重構已合併至 master（2026-07-12）；18 個 canonical skills、3 個 Guidance Profiles、4 個 Model Overlays、4 套 Adapter 與 10 組代表性情境驗證併入 master。
- #5：Spec → GitHub Issues 工作流、Session Closeout 重構與 Token 效率優化；PR #6 已合併、Issue #5 已關閉（2026-07-10）。

## 未追蹤本機工作

- PR #8、PR #9 均無可確認的 Issue 關聯，未使用 `Closes` 或 `Related to`（延續先前 session 已記錄的判斷）。
- Ubuntu 原生執行與真實外部模型 trace 尚未驗證（延續自上一輪，本次未處理）。
