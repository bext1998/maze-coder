# ADR-0003：sync-adapters.sh 採冪等完整覆寫策略

## 狀態

Accepted

## 背景

四套 Host Adapter（Claude Code、Codex、Cursor、opencode）皆由 `skills/`、`core/`、`profiles/`、`model-overlays/` 同步而來。同步腳本可以選擇只更新有差異的檔案，或每次都完整覆寫目的目錄。

## 決策

`scripts/sync-adapters.sh` 的 `sync_dir()` 對每個目的目錄先 `rm -rf` 再完整複製來源，不做差異比對；每次執行都必須是冪等的——第一次同步後應無殘留變更，第二次執行必須回報 `no changes`。

## 替代方案

- 差異更新（只複製有變更的檔案）：I/O 較省，但技能內容刪除或重新命名後，adapter 端容易留下過期殘留檔案，導致 adapter 與 `skills/` 語意不一致。
- 手動維護各 adapter：完全客製化，但四份拷貝會快速分歧，且沒有機制偵測漂移。

## 後果

- 每次同步成本等同完整重建 adapter 目錄；以目前技能包規模（27 個技能、可攜 shell 腳本）此成本可接受。
- `validate-skillpack.sh`／`validate-skills-functional.sh` 與 AC-15 均以「第二次 sync 輸出 no changes」驗證冪等性；破壞此契約即視為回歸。
- 新增或移除技能、resource 檔案時不需要額外清理 adapter 端殘留檔案，因為每次同步都是完整覆寫。
