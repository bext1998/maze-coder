# ADR-0004：validate-skillpack.sh 對 SKILL.md 做結構驗證，而非只檢查檔案存在

## 狀態

Accepted

## 背景

canonical skill 數量會持續成長，若驗證只確認 `skills/<name>/SKILL.md` 檔案存在，無法防止技能缺少可執行的工作流（例如漏寫執行流程或輸出契約），這類缺陷只有真人審查或實際使用時才會被發現。

## 決策

`scripts/validate-skillpack.sh` 的 `validate_skill()` 對每個 SKILL.md 做結構驗證：frontmatter 必須是合法的 `---` 區塊、`name` 需與目錄一致、`description` 不得為空、`invocation` 必須是 `user`／`model`／`both`／`internal` 其中之一；內文必須有非空的「目標」「輸出契約」「邊界」，以及「前置條件」或「必要輸入」其中之一、「執行流程」或「核心行為」其中之一；同時掃描 `TODO`／`FIXME` 標記與 `references`／`templates`／`checklists` 資源連結是否實際存在。缺一即 `exit 1`。

## 替代方案

- 只檢查檔案存在：最輕量，但無法攔截缺漏執行流程或輸出契約的技能。
- 用 JSON Schema／專用工具驗證 frontmatter 與內文結構：更嚴謹，但需要引入額外執行環境，違反「只依賴 Bash、find、grep 等既有工具」的可攜性契約。
- 人工審查：不可規模化，且無法在 CI 或本機快速重跑。

## 後果

- 新增技能時，SKILL.md 必須包含全部必要區段與合法 frontmatter，否則驗證失敗、無法宣告完成。
- 允許章節標題有限度的同義詞（例如「執行流程」或「核心行為」），讓不同技能可依內容選字，但仍受檢查覆蓋。
- 驗證邏輯本身用 `awk`／`grep` 實作，維持跨平台可攜性（macOS、Linux、Windows Git Bash），不引入額外相依。
