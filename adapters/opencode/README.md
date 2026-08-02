# opencode Adapter

`AGENTS.md` 是精簡 Router；`.maze-coder/` 提供 28 個 canonical skills（25 個公開入口、3 個 internal）、Profiles、Overlays 與核心契約，兩者必須一起安裝。

```bash
cp AGENTS.md /your-project/
cp -r .maze-coder /your-project/
```

產物由 `scripts/sync-adapters.sh` 維護，請勿直接編輯。
