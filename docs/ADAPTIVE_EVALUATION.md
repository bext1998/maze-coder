# 自適應架構評估

## 基準

- Tag：`pre-adaptive-refactor`（`57459a1`）
- 14 個 SKILL.md：9,174 Unicode 字元，粗估約 9,174 個中英混合 token 上限。
- 結構與功能驗證：通過；Ubuntu 原生執行：未驗證。

## 靜態代表性情境

`tests/adaptive-scenarios.tsv` 固定 10 組輸入的 Profile、入口技能、允許資源、不可遺失契約、驗收條件，以及載入數、提問、工具與文件的前後估計。`scripts/validate-adaptive-scenarios.sh` 驗證情境完整、資源存在且新架構估計不退化。

靜態估計合計：技能／資源載入 33 → 21、使用者提問 27 → 15、工具呼叫 68 → 57、產生文件 8 → 5。這些是路由契約估計，不宣稱為真實模型 trace。

## 精簡比較

- 完整 canonical SKILL.md：14 份 9,174 字元 → 18 份 10,966 字元（新增四技能後 +19.5%）。
- 平均每技能：655.3 → 609.2 字元（-7.0%）。
- 同口徑原 14 技能現為 9,410 字元（+2.6%，增加的是 invocation metadata）。
- 中英混合 Markdown 粗估 token 約 9.2k → 11.0k；真正每任務成本由按需路由決定，不會載入完整集合。

## 行為退化與補丁

- 尚未觀察到靜態契約退化；唯一補丁是將 Claude canonical invocation 轉成 Host 原生 metadata，避免 user-only 或 internal skills 被錯誤自動觸發。
- 尚未執行外部 GPT-5.6 或較弱本地模型的重複實跑，因此對話輪次、工具數與返工率仍是待實測風險，不得把靜態估計描述為實測結果。
