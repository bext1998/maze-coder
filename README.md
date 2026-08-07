# maze-coder

<p align="center">
  <img src="./assets/maze-coder-logo.png" alt="maze-coder pixel wordmark logo" width="480">
</p>

**Adaptive Harness Engineering Skills Pack** — 共用安全與完成契約，同時保留前沿模型的原生代理能力。

## 29 Canonical Skills

| Skill | 用途 |
|---|---|
| `maze-wayfinder` | 需求太模糊、連想要什麼都不確定時的探路與建圖 |
| `maze-idea-to-spec` | 模糊想法 → spec |
| `maze-spec-hardening` | 補強工程契約與驗收條件 |
| `maze-project-init` | 初始化專案文件與 GitHub 設定 |
| `maze-spec-to-issues` | spec → GitHub Issues Dry Run／同步 |
| `maze-spec-review` | 規格完整審查與 `--verify` 複審 |
| `maze-pr-review` | GitHub PR 高訊號唯讀審查 |
| `maze-adversarial-review` | 實作前對抗性方案審查與證偽 |
| `maze-threat-modeling` | 實作前威脅模型與濫用分析 |
| `maze-root-cause-diagnosis` | 以區辨實驗與反證收斂 Bug 根因 |
| `maze-session-closeout` | 以 Git、GitHub 證據重建短期 NEXT_ACTION |
| `maze-github-safe-ops` | 安全 Git／PR／Issue 關聯 |
| `maze-design-review` | 前端設計審查 |
| `maze-qa-verification` | 規格驗收與 QA 報告 |
| `maze-design-system` | 建立／演進設計語言、Design Tokens 與指定元件 |
| `maze-gui-prototyping` | 桌面 GUI 與 HTML/CSS/SVG 原型執導 |
| `maze-repo-map` | Repo 結構地圖 |
| `maze-context-audit` | 上下文一致性稽核 |
| `maze-bug-reproduction` | Bug 最小重現文件 |
| `maze-handoff-summary` | 跨工具／人員交接 |
| `maze-token-efficiency-review` | 執行 trace 與 token 效率稽核 |
| `maze-explain-for-dumbass` | 把技術性回覆重講成白話版本，保留檔名／指令／錯誤碼等具體資訊 |
| `maze-risk-driven-tdd` | 低上下文、風險導向的行為驗證與實作 |
| `maze-skill-authoring` | 評估是否新增或擴充技能 |
| `maze-grill` | 逐題壓力測試，不產生文件 |
| `maze-grill-with-docs` | 壓力測試並同步必要領域文件 |
| `maze-grilling` | Grill 共用邏輯（internal） |
| `maze-domain-modeling` | 領域模型與重大決策同步（internal） |
| `maze-github-cli` | GitHub CLI 安全操作契約（internal） |

## Extension Skills

選用、不隨 `sync-adapters.sh` 同步、不保證跨 adapter 可攜；每個技能只服務特定工具組合的使用者。安裝方式是直接複製到該工具自己的使用者層技能目錄，不經過本 repo 的同步／驗證管線。

| Skill | 用途 | 安裝位置 |
|---|---|---|
| `consult-claude` | Codex 端：呼叫本機 `claude` CLI 取得第二意見 | `~/.codex/skills/consult-claude/` |
| `consult-codex` | Claude Code 端：呼叫本機 `codex` CLI 取得第二意見 | `~/.claude/skills/consult-codex/` |

```bash
cp -r extensions/consult-claude ~/.codex/skills/
cp -r extensions/consult-codex ~/.claude/skills/
```

## Adaptive Model

```text
core invariants + Guidance Profile + optional Model Overlay
→ one relevant skill → on-demand references → evidence-based completion
```

`skills/` 是 source of truth。Adapter 使用精簡 Router；依能力選擇 `minimal`、`standard` 或 `scaffolded`，只有具體失敗才加強 Guidance。

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

# Pi
cp adapters/pi/AGENTS.md /your-project/
cp -r adapters/pi/.pi /your-project/
```

## Sync and Validate

```bash
bash scripts/sync-adapters.sh
bash scripts/validate-skillpack.sh
bash scripts/validate-skills-functional.sh
bash scripts/validate-pi-adapter.sh
```

同步腳本只更新受管理的 Adapter／根模板；連續執行兩次時，第二次應輸出 `no changes`。

## Structure

```text
assets/     品牌與視覺資產
core/       不變量與自適應工作模型
profiles/   三級 Guidance Profile
model-overlays/ 輕量模型偏差修正
skills/     28 個來源技能及按需資源
adapters/   五種工具的 Router 與資源包
extensions/ 選用、不可攜、不經同步管線的單一工具專屬技能
templates/  由技能模板同步的使用者文件
scripts/    同步與驗證
docs/       maze-coder 自身規格與狀態
```

## Contributing

1. 只修改 `skills/`、`core/` 或同步腳本的 source of truth。
2. 執行同步、結構驗證與功能驗證。
3. 確認第二次同步無差異後再提交 PR。
4. `extensions/` 底下的技能不經同步／驗證管線，修改後不需要跑上述步驟；但仍需確認技能本身內容自洽。

[MIT License](LICENSE)
