# Claude Code Adapter

安裝完整 `.claude/`；每個技能保留自己的 references、templates 與 checklists。

```bash
cp -r .claude /your-project/
```

共 18 個 canonical skills（16 個公開入口、2 個 internal）。內容由 `scripts/sync-adapters.sh` 產生，請修改根 source of truth，不要直接編輯此目錄。
