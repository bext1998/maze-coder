# maze-coder — 下一步行動

> 僅保留當前有效前線；明確 closeout 時整體重建，不追加歷史。

## 下一個 Session 目標

Issue #59 的四段實作已完成並在 worktree 分支上通過驗證；下一個動作是把分支整理成一個 PR（`release:major`，`Closes #59`、`Related to #58`）。

## 行動（最多 3 項）

1. 依最後一段的審查結果決定是否補修，然後開 PR（`maze/2026-11-17-6ec31f0` → `master`）。
2. PR 合併後，依 README「從舊版遷移」把本機五個 agent 的全域安裝換到 `skills/` 來源，先裝新的再刪舊的。
3. 合併後確認 release 產物改為 `maze-coder-skills-<tag>.zip`（workflow 已改），舊的 adapter 壓縮檔不再產生。

## 阻塞與待決策

- 本機 Cursor 與 opencode 未安裝，這兩個 host 的實際載入行為只有官方文件依據，沒有實機驗證。
- Codex 不支援 `disable-model-invocation` 已列為已知限制；若之後 Codex 變成主要工具，再評估加 `agents/openai.yaml`。

## 參考

- Issue：https://github.com/bext1998/maze-coder/issues/59（#58 併入安裝部分）
- 規格：docs/spec.md
- 決策：docs/adr/0003-native-agent-skills.md
