# Claude Code Adapter

安裝完整 `.claude/`；每個技能保留自己的 references、templates 與 checklists。`.claude/CLAUDE.md` 是 Router——Claude Code 啟動時會與專案根 `CLAUDE.md` 一起載入。

```bash
cp -r .claude /your-project/
```

專案已有自己的 `CLAUDE.md` 或 `.claude/CLAUDE.md` 時，不要覆蓋：把 `.claude/CLAUDE.md` 的 Router 區塊併入既有檔案即可。

共 29 個 canonical skills（26 個公開入口、3 個 internal）。內容由 `scripts/sync-adapters.sh` 產生，請修改根 source of truth，不要直接編輯此目錄。
