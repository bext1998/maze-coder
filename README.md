# maze-coder

<p align="center">
  <img src="./assets/maze-coder-logo.svg" alt="maze-coder animated workflow logo" width="720">
</p>

**Portable Harness Engineering Skills Pack** — 讓 Claude Code、Codex、Cursor、opencode 共用需求、GitHub、QA 與狀態同步工作流。

## 12 Skills

| Skill | 用途 |
|---|---|
| `maze-idea-to-spec` | 模糊想法 → spec |
| `maze-spec-hardening` | 補強工程契約與驗收條件 |
| `maze-project-init` | 初始化專案文件與 GitHub 設定 |
| `maze-spec-to-issues` | spec → GitHub Issues Dry Run／同步 |
| `maze-session-closeout` | 同步 Git、GitHub、STATUS 與 NEXT_ACTION |
| `maze-github-safe-ops` | 安全 Git／PR／Issue 關聯 |
| `maze-design-review` | 前端設計審查 |
| `maze-qa-verification` | 規格驗收與 QA 報告 |
| `maze-repo-map` | Repo 結構地圖 |
| `maze-context-audit` | 上下文一致性稽核 |
| `maze-bug-reproduction` | Bug 最小重現文件 |
| `maze-handoff-summary` | 跨工具／人員交接 |

## Workflow

```text
idea-to-spec → spec-hardening → project-init → spec-to-issues
→ coding／QA → github-safe-ops → Review／CI／Merge → session-closeout
```

`skills/` 是 source of truth。Adapter 使用精簡 Router，只在觸發後載入對應技能與按需資源。

## Install

```bash
# Claude Code
cp -r adapters/claude-code/.claude /your-project/

# Codex
cp adapters/codex/AGENTS.md /your-project/
cp -r adapters/codex/.maze-coder /your-project/

# Cursor
cp -r adapters/cursor/.cursor /your-project/

# opencode
cp adapters/opencode/AGENTS.md /your-project/
cp -r adapters/opencode/.maze-coder /your-project/
```

## Sync and Validate

```bash
bash scripts/sync-adapters.sh
bash scripts/validate-skillpack.sh
bash scripts/validate-skills-functional.sh
```

同步腳本只更新受管理的 Adapter／根模板；連續執行兩次時，第二次應輸出 `no changes`。

## Structure

```text
assets/     品牌與視覺資產
core/       共用契約與工作流
skills/     12 個來源技能及按需資源
adapters/   四種工具的 Router 與資源包
templates/  由技能模板同步的使用者文件
scripts/    同步與驗證
docs/       maze-coder 自身規格與狀態
```

## Contributing

1. 只修改 `skills/`、`core/` 或同步腳本的 source of truth。
2. 執行同步、結構驗證與功能驗證。
3. 確認第二次同步無差異後再提交 PR。

[MIT License](LICENSE)
