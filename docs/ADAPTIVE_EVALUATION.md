# 自適應架構評估

## 基準

- Tag：`pre-adaptive-refactor`（`57459a1`）
- 14 個 SKILL.md：9,174 Unicode 字元，粗估約 9,174 個中英混合 token 上限。
- 結構與功能驗證：通過；Ubuntu 原生執行：未驗證。

## 靜態代表性情境（已移除）

原 `tests/adaptive-scenarios.tsv` 與 `scripts/validate-adaptive-scenarios.sh` 只比較人工填寫的估計值，不是真實模型 trace，行為退化時不會失敗，已於 #51 移除。需要評估自適應效果時，改以真實任務的 trace 為證據。

## 精簡比較

- 完整 canonical SKILL.md：22 份約 15,240 字元；每技能平均約 692.7 字元，低於 16,500 字元上限。
- 中英混合 Markdown 粗估 token 約 15.2k；真正每任務成本由按需路由決定，不會載入完整集合。

## 行為退化與補丁

- 尚未觀察到靜態契約退化；唯一補丁是將 Claude canonical invocation 轉成 Host 原生 metadata，避免 user-only 或 internal skills 被錯誤自動觸發。
- 尚未執行外部 GPT-5.6 或較弱本地模型的重複實跑，因此對話輪次、工具數與返工率仍是待實測風險，不得把靜態估計描述為實測結果。
