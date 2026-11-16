# maze-coder — 下一步行動

> 僅保留當前有效前線；明確 closeout 時整體重建，不追加歷史。

## 下一個 Session 目標

v3.0.0（PR #60，原生 Agent Skills 集合）已合併發佈，GitHub 沒有 open issue。本機全域安裝已遷移完成：`~/.claude/skills` 與 `~/.agents/skills` 的 `maze-*` 都是指向本 repo `skills/` 的連結，舊副本已移除。

## 行動（最多 3 項）

1. 在 Claude Code、Codex、Pi 各試一個代表性技能（例如 `maze-grill`），確認能正常載入。
2. 確認沒問題後，刪除遷移留下的備份目錄 `~/maze-coder-skills-backup.*`。

## 阻塞與待決策

- 本機沒有安裝 Cursor 與 opencode，這兩個 host 的實際載入行為只有官方文件依據，沒有實機驗證。
- Codex 不支援 `disable-model-invocation`，已列為已知限制。若之後 Codex 變成主要工具，再評估是否加 `agents/openai.yaml`。

## 參考

- 發佈：https://github.com/bext1998/maze-coder/releases/tag/v3.0.0
- 規格：docs/spec.md
- 決策：docs/adr/0003-native-agent-skills.md
