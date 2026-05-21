# maze-coder 設計哲學

> **受眾：人類維護者**
> 本文件說明設計決策背後的「為什麼」。理解這些脈絡，才能在新需求出現時做出一致的決策。

---

## 1. 為什麼是 Markdown 優先

Coding agent 工具每隔幾個月就會改變 — Cursor 換規則格式、Claude Code 改 SKILL.md 規範、opencode 出現新慣例。

Markdown 是唯一在所有工具、所有時代都能閱讀的格式。當工具消失，你的技能包仍然可用，因為它就是純文字。

## 2. 為什麼不做 CLI 或 framework

打包成 npm 套件或 pip 模組意味著版本、依賴、安裝步驟。使用者換一台電腦就需要重新設定。

「複製整個目錄即可用」是唯一真正可攜式的定義。沒有 node_modules，沒有 venv，沒有 PATH 設定。

## 3. 為什麼要 adapter 而非單一格式

Claude Code 用 SKILL.md，Cursor 用 .mdc，Codex 和 opencode 用 AGENTS.md。這不是技術差異，是工具文化差異。

adapter 模式讓核心技能邏輯只需維護一次（在 `skills/`），格式翻譯則各自獨立。當 Cursor 改格式，只需更新 cursor adapter，不動其他任何東西。

## 4. 為什麼要 validate-skillpack.sh

文件型專案的最大風險是「看起來完整但實際上缺少關鍵檔案」。腳本提供客觀的完整性驗證，讓使用者在開始工作前就能確認技能包是否就緒。

只依賴 bash + find + grep 是刻意的：這確保腳本在任何有 bash 的環境都能執行，不需要安裝任何工具。

## 5. 為什麼 docs/ 和 templates/ 必須嚴格分離

`docs/` 記錄 maze-coder 自身的歷史決策和當前狀態，帶有特定時間點的語境。

`templates/` 是使用者要複製到自己專案的空白起點，不能帶有 maze-coder 的狀態資料。

混用的後果是：使用者複製了帶有 maze-coder 版本決策的文件，開始工作時發現文件內容無法理解，因為那些是另一個專案的紀錄。

## 6. 為什麼技能邊界（不做的事）是必要 section

Agent 最容易犯的錯誤是「越界補充」— 在完成技能目標後，順手做了不在技能範圍內的事，導致輸出不可預測。

明確列出「本技能不做的事」，是讓 agent 知道在哪裡停下來的唯一可靠方式。

## 7. 為什麼 sync-adapters.sh 是冪等覆蓋而非差異更新

差異更新在「技能內容改變但 adapter 舊版殘留」時容易產生語意不一致。冪等覆蓋確保 adapter 永遠是 `skills/` 的完整反映，不會有過期的殘留。

代價是每次 sync 都重新寫入全部 adapter 檔案，但對於 Markdown 文件這個代價可以接受。
