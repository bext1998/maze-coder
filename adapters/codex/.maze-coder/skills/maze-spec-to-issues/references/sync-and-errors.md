# 同步、去重與失敗規則

## 去重順序

1. 精確比對 `task-id` marker。
2. 比對來源路徑、章節與既有 Issue／PR 關聯。
3. 檢查 Open/Closed Issues、Open/Merged PR、規格完成標記及 Git 歷史的等價成果；不以 `STATUS.md` 作為狀態證據。
4. 語意近似但無法證明相同時，標為候選並要求使用者決定。

- 相同 Open Issue：略過並回報，可建議更新。
- 相同 Closed Issue：內容一致視為完成；新增範圍建立新 Issue 並引用舊 Issue。
- Open PR：視為進行中，不建立副本。
- Merged PR 無 Issue：列為已實作但缺紀錄，不自動補建。

## 規格變更

- 新需求：建立新草稿。
- 尚未開始的修改：顯示 Issue 修改前後 diff，確認後更新。
- 進行中需求修改：標記 Scope Change，由使用者選擇更新原 Issue 或建立新 Issue，不覆蓋進行中範圍。
- 刪除未開始需求：建議以 `not planned` 關閉，取得確認後執行。
- 刪除已完成需求：保留歷史；需要移除時建立新 Issue。
- 與已合併實作衝突：建立修正 Issue，不改寫歷史 Issue。

## 完成條件

Issue 僅在實作、AC、QA、適用 CI、文件、PR 合併與 Issue 關閉全部完成時視為完成。任何一項缺少都維持最接近的未完成狀態。

## 部分失敗與重試

- 每項操作記錄成功、失敗、略過、重複、已存在、無權限、Assignee 失敗與標籤失敗。
- 單項失敗不回滾或重建成功 Issue；保留未成功草稿。
- Issue 已建立但標籤、Assignee 或 Sub-issue 關聯失敗時，只針對原 Issue 重試缺少操作。
- 重試前重新搜尋 marker；找到既有 Issue 後禁止再次建立。
