---
name: maze-skill-authoring
description: 評估該新增 maze-* 技能或擴充既有技能的 checklist／reference／template，並給出符合新架構的撰寫與驗證流程。當使用者要求新增技能、拆出新技能或把能力加入技能包時使用。
---

# skill-authoring

## 目標

在新增能力進入技能包前，先判斷是否真的需要獨立的 SKILL.md，避免技能數量無節制成長；決定要新增時，確保新技能符合既有結構與 source of truth 慣例。

## 前置條件

- 已有明確、會重複出現的能力缺口；單次性、一次性任務不適用。
- 已檢視 README.md 的技能表與相關技能的 checklists／references／templates，確認缺口無法靠擴充既有技能解決。

## 執行流程

1. 優先判斷可否用「擴充既有技能」解決：加一條 checklist 項目、一份 reference、一份 template，或調整既有 SKILL.md 的執行流程／邊界。可以就不開新技能，在既有技能檔案內修改即可，流程到此結束。
2. 確認必須獨立成技能後，決定 `name`（`maze-<動詞或名詞短語>`）、`description`（含「何時使用」觸發語句，供模型判斷是否載入），以及是否加 `disable-model-invocation: true`：只有使用者明示觸發的技能才加，模型可主動載入時不加。
3. 撰寫單一 `SKILL.md`，維持既有結構：前置條件、執行流程、輸出契約、邊界（不做的事）。預設只寫單一檔案；只有內容量大到必須拆分時才加 `checklists`、`templates`、`references` 或 `examples` 子目錄，且子目錄內容只能按需讀取，不得在 SKILL.md 主體展開全文。
4. 高風險技能（邊界依賴「已證明」「根因」等判斷性措辭，錯誤解讀代價高）另讀 `references/adversarial-resilience-check.md`，用對抗式壓力情境驗證措辭是否經得起時間壓力、沉沒成本或看似合理的豁免理由；低風險技能跳過此步。
5. 更新 source of truth：`skills/<name>/` 是唯一來源，同時更新 `README.md` 的技能表；跨技能引用一律寫成安裝佈局下可解析的相對路徑，並在引用端寫明需要同時安裝哪個技能。會被其他技能跨技能載入的 reference，內部相對路徑一律以所屬技能根目錄為基準，並在檔案內寫明基準。
6. 執行 `bash scripts/validate-skillpack.sh` 與 `bash scripts/validate-skills-functional.sh` 確認通過。

## 輸出契約

- 回報「為何需要新技能／為何改用擴充既有技能」的判斷依據、修改或新增的檔案清單、兩支驗證腳本的結果；執行過對抗式壓力驗證時一併回報測過的情境與結果。

## 邊界

- 不得為單次性、不會重複出現的需求開新技能。
- 不得把新技能寫成需要預設全文載入的長文件；輔助素材一律按需讀取。
- 不修改使用者 host 目錄下已安裝的技能副本；一律改 `skills/` 後重新安裝。
