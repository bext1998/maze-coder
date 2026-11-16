# ADR-0003：回歸原生 Agent Skills

## 狀態

Accepted（取代 ADR-0001、ADR-0002）

## 背景

v3.x 以自適應 Harness 為核心：一份共用契約檔、三級 Guidance Profile、Model Overlay、五套 Host Adapter，以及讓它們保持一致的同步腳本與驗證器。這套機制的成本持續累積：

- 技能內容在來源目錄與各 Adapter 之間保存多份，修改要靠同步腳本收斂，還要同步 Router 表格、技能計數與驗證器。
- 技能被迫先讀一份不屬於自己的契約檔，個別技能無法獨立安裝與理解。
- Guidance Profile 與 Model Overlay 的效益沒有實證；模型本身已具備探索、規劃與工具選擇能力。
- 各 Coding Agent 已原生支援 Agent Skills（`SKILL.md` + `description` + 按需資源），自建探索與載入機制是重複抽象。

## 決策

1. `skills/` 成為唯一來源，直接安裝到 host 原生的技能目錄；不複製、不轉換內容。
2. 移除 Adapter、Guidance Profile、Model Overlay、共用 Harness 契約檔與同步管線；技能只保留自己需要的規則。
3. 觸發方式改用 host 原生欄位 `disable-model-invocation`；不再有自訂的 invocation 分類。
4. 三個 internal 技能（grilling 逐題契約、領域模型同步、GitHub CLI 契約）併入宿主技能的 `references/`；跨技能引用只保留必要者，並在引用端寫明需同時安裝哪個技能。
5. 安裝由一支只建 symlink 的 `scripts/install-skills.sh` 負責：它只建立或替換 symlink，**永遠不刪除實體目錄或檔案**；遇到實體副本就停下並要求使用者自行搬走（本專案曾有一個帶覆蓋選項的安裝腳本，連續三輪審查都找到能刪到來源或第三方資料的路徑，因此改成不具備刪除能力）。驗證只留結構與功能契約兩支腳本，不寫死技能總數。

## 替代方案

- **維持自適應架構**：可保留對弱模型的腳手架，但維護成本與重複儲存問題不變，且缺乏效益證據。
- **每 host 一份客製內容**：能針對各 host 最佳化，但回到多份副本與同步問題。
- **只留文件、不做任何安裝輔助**：最簡單，但使用者仍需自行判斷五個 host 的技能路徑。

## 後果

- **優點**：新增技能只需建立 `skills/<name>/SKILL.md`；不再有生成物、計數與 Router 同步；技能可獨立安裝與閱讀。
- **Codex 退化**：Codex CLI 不支援 `disable-model-invocation`（0.169.0 實測被忽略），使用者觸發的技能在該 host 可能被模型自動選用。補救方式是每個技能加一份 `agents/openai.yaml`，本專案刻意不維護這份重複資料，改列為 README 的已知限制。
- **internal 技能消失**：原本靠「實體搬家 + 路徑改寫」達成的不曝光，改成把內容降級為宿主技能的 references；技能數由 29 降為 26，代價是 `maze-grill` 與 `maze-grill-with-docs` 之間多一條檔案層依賴。
- **安裝方式改變**：使用者既有的全域安裝（複本或指向舊產物的連結）必須遷移；因為腳本不再刪除任何實體資料，遷移必須是「先備份 → 把舊實體安裝搬到備份 → 再安裝 → 確認後才刪備份」，步驟寫在 README。
- **失去的能力**：沒有 Guidance Profile 之後，弱模型不再有外部腳手架；若日後出現具體失敗，只能針對個別技能補規則，不重建通用層。
