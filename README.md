# maze-coder

<p align="center">
  <img src="./assets/maze-coder-logo.svg" alt="maze-coder animated workflow logo" width="720">
</p>

**Portable Harness Engineering Skills Pack**
可攜式 AI Coding 工作流技能包，讓 Claude Code、Codex、Cursor、opencode 共用同一套工程規範。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blue)](adapters/claude-code)
[![Codex](https://img.shields.io/badge/Codex-compatible-green)](adapters/codex)
[![Cursor](https://img.shields.io/badge/Cursor-compatible-purple)](adapters/cursor)
[![opencode](https://img.shields.io/badge/opencode-compatible-orange)](adapters/opencode)

---

## What is this?

maze-coder is an **11-skill workflow framework** for AI coding agents. It gives your agent a consistent, repeatable process for turning vague ideas into shipped code — across any tool.

- 將模糊想法轉換成工程規格書
- 安全地執行 Git 操作，避免破壞性錯誤
- 降低 AI 產生的 UI slop
- 在 coding session 之間保持連續性與上下文
- 在不同 coding agent 工具之間無縫遷移

**Markdown-first. Zero dependencies.**

---

## Quick Start

### Claude Code

```bash
cp -r adapters/claude-code/.claude/ /your-project/
```

### Codex / opencode

```bash
cp adapters/codex/AGENTS.md /your-project/
# or
cp adapters/opencode/AGENTS.md /your-project/
```

### Cursor

```bash
cp -r adapters/cursor/.cursor/ /your-project/
```

---

## 11 Skills

| Skill | 用途 | 觸發時機 |
|---|---|---|
| `idea-to-spec` | 想法 → spec.md | 「我想做一個...」 |
| `spec-hardening` | 補強 spec.md 邊界條件 | 「幫我補強規格書」 |
| `project-init` | 初始化專案文件 | 「幫我建立專案文件」 |
| `session-closeout` | Session 結束，更新記憶與任務 | 「今天先到這裡」 |
| `github-safe-ops` | 安全 Git 操作清單 | 任何 git 操作前 |
| `design-review` | 前端設計審查，減少 slop | 「幫我審查 UI」 |
| `qa-verification` | 功能完成後的 QA 驗證 | 功能完成後 |
| `repo-map` | 產生 Repo 結構地圖 | 進入新 repo |
| `context-audit` | 上下文一致性稽核 | 懷疑 agent 搞錯了 |
| `bug-reproduction` | 結構化 Bug 重現文件 | 「幫我記錄這個 bug」 |
| `handoff-summary` | 工具或人員交接摘要 | 換工具或換人前 |

---

## Validate & Sync

驗證技能包完整性：

```bash
bash scripts/validate-skillpack.sh
# Expected: === All checks passed ===
```

修改 `skills/` 下的技能後，同步所有 adapter：

```bash
bash scripts/sync-adapters.sh
```

---

## Directory Structure

```
maze-coder/
  core/         ← Harness Engineering 原則與工作流模型
  skills/       ← 11 個技能（source of truth）
  adapters/     ← 四個工具的格式適配（Claude Code / Codex / Cursor / opencode）
  templates/    ← 使用者可複製的空白範本
  scripts/      ← validate + sync 腳本
  docs/         ← maze-coder 自身的專案文件
```

---

## Contributing

1. Fork this repo
2. Create a branch: `git checkout -b feat/your-skill-name`
3. Edit skills under `skills/` (the source of truth)
4. Run `bash scripts/validate-skillpack.sh` to verify
5. Run `bash scripts/sync-adapters.sh` to propagate changes to adapters
6. Open a Pull Request

---

## License

[MIT License](LICENSE) © 2026 maze-coder contributors
