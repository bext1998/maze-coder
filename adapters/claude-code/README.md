# Claude Code Adapter

安裝完整 `.claude/`；每個技能保留自己的 references、templates 與 checklists。`.claude/CLAUDE.md` 是 Router——Claude Code 啟動時會與專案根 `CLAUDE.md` 一起載入。

專案已有自己的 `CLAUDE.md` 或 `.claude/CLAUDE.md` 時，不要直接覆蓋：先複製 `.claude/maze-coder/` 與 `.claude/skills/`，再把 `.claude/CLAUDE.md` 的 Router 區塊併入既有檔案。

```bash
cp -r .claude/maze-coder /your-project/.claude/
cp -r .claude/skills /your-project/.claude/
```

共 29 個 canonical skills（26 個公開入口、3 個 internal）。內容由 `scripts/sync-adapters.sh` 產生，請修改根 source of truth，不要直接編輯此目錄。
