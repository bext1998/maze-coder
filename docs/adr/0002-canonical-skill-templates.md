# ADR-0002：來源技能模板是根模板的唯一來源

## 狀態

Accepted

## 背景

專案同時提供技能內模板、根 `templates/` 與四套 Host Adapter。若各位置分別維護，技能工作流與實際交付模板可能分歧，且同步後無法判斷哪一份內容正確。

## 決策

以 `skills/*/templates/` 作為模板的 canonical source。根 `templates/` 與 Adapter 內模板一律由 `scripts/sync-adapters.sh` 產生；維護者不得直接修改生成版本，validator 必須比對同步結果。

## 替代方案

- 以根 `templates/` 為來源：集中但會把模板與使用它的技能契約拆開。
- 各位置獨立維護：可局部調整，但容易造成跨 Host 語意漂移。
- 執行時動態引用單一外部模板：減少複製，但破壞離線可攜與複製目錄即可使用的契約。

## 後果

模板修改必須先更新來源技能，再執行同步腳本；根模板與 Adapter 版本視為生成物。同步與 validator 需持續保持冪等及內容一致。
