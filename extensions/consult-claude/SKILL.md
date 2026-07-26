---
name: consult-claude
description: 需要 Claude 的獨立第二意見時使用：直接呼叫本機 claude CLI，就目前修法、方案或診斷徵詢 Claude 的判斷，並整理共識與分歧。使用者說「問 Claude」「讓 Claude 看看」「跟 Claude 對一下」「Claude 會怎麼看這個」等語句時觸發。同步、單次、唯讀——不做多輪、不建立常駐服務、不遞迴呼叫。
---

# consult-claude

## 目標

在不離開目前工作、不需要使用者手動複製貼上的情況下，取得 Claude 對目前問題的獨立判斷，作為第二意見輸入目前的決策，而不是取代目前 agent 的判斷。

## 前置條件

- 已有具體待決策的問題（修法選擇、方案取捨、Bug 根因診斷等），不是單純想找人重讀整份程式碼。
- 用 `claude --version` 快速確認 CLI 存在；不存在、版本查詢失敗，或明顯未登入，直接回報並停止，不嘗試安裝、登入或改用其他管道。

## 執行流程

1. **組 prompt**（自己動筆整理，不是照抄對話紀錄），固定包含：
   - 目標：現在要解決什麼問題、為什麼要問。
   - 現況：目前傾向的方案或修法，以及相關檔案路徑（給路徑讓 Claude 自己讀，不要整段貼原始碼，除非片段本來就很短）。
   - 已知證據：已經確認的事實、已排除的可能性。
   - 限制：不能做什麼、有什麼硬性條件。
   - 具體疑問：要 Claude 回答的確切問題（例如「這個修法有沒有遺漏的邊界情況」）。
   - 禁止把完整對話紀錄、完整 log 或無關檔案整包貼進去。

2. Prompt 最後固定逐字附上這段角色與邊界宣告：

   ```
   You are being consulted read-only by another coding agent (Codex) working in this same directory. Give your own independent analysis — do not simply defer to or agree with the asker. You may only read files (Read/Grep/Glob tools); you cannot edit files, commit, push, install dependencies, or run other commands. This is a single synchronous turn: do not attempt to invoke any consult-claude/consult-codex skill or shell out to another CLI yourself, even if it seems relevant. Answer directly with: your conclusion, the evidence/reasoning behind it, and anything you are genuinely uncertain about.
   ```

3. 用 Write 工具把組好的完整 prompt 存到 scratchpad 底下**這次呼叫獨有**的暫存檔（例如帶入時間戳記或亂數的檔名，而不是每次都固定用 `consult-claude-prompt.txt`）；下面的 `<outfile>`／`<errfile>` 也一律採同一原則。就算是 shell `>` 重導向會截斷檔案，兩次並行的 consult-claude 呼叫如果共用同一組固定檔名，寫入時序仍可能交錯或互相覆蓋，所以唯一檔名不是可省略的細節。

4. 用 **Bash 工具**（不要用 PowerShell，避免 Windows 對多行字串與引號的轉義問題）在目前工作目錄（不要 `cd` 到別處）執行：

   ```bash
   claude -p "$(cat "<promptfile>")" \
     --tools "Read,Grep,Glob" \
     --permission-mode bypassPermissions \
     --disable-slash-commands \
     --output-format text \
     > "<outfile>" 2> "<errfile>"
   ```

   - `--tools "Read,Grep,Glob"`：寫入邊界的核心——被諮詢的 Claude 沒有 Edit/Write/Bash/NotebookEdit，技術上無法修改檔案、commit、push、裝套件、跑破壞性指令，也沒有 Bash 工具可以 shell out 到其他 CLI（這一端的遞迴呼叫因此是真的被工具層級擋住，不只是 prompt 約束）。但這只保證「不會寫入」，不保證「不會讀到不該讀的東西」：Read/Grep/Glob 沒有限制可讀路徑範圍，高敏感情境應改用只含必要檔案的隔離目錄／容器，而不是只靠工具白名單。
   - `--permission-mode bypassPermissions`：在已經被鎖死成唯讀工具的前提下，避免它在非互動模式卡在權限詢問上（沒有人可以回應）；副作用是連「讀取工作目錄以外檔案」原本會跳出的授權詢問也一併跳過，等於放寬了讀取範圍的把關，不只是省略無害的確認框。
   - `--disable-slash-commands`：關閉所有技能觸發（Skill 工具本身也不在上面的 `--tools` 白名單內），與工具白名單疊加，雙重防止被諮詢的 Claude 又觸發 `consult-codex` 造成遞迴。
   - Bash 工具呼叫時設定 `timeout`（建議 180000–300000ms，問題越複雜可以拉長，但不要無上限等待）。

5. 呼叫結束後判讀結果（直接用 Read 工具讀檔案內容自己判斷，不寫解析腳本、不用 jq/python）：
   - Bash 逾時、exit code 非 0、或 `<outfile>` 是空的（不論 `<errfile>` 是否有內容）→ 判定失敗。直接回報具體失敗原因（例如「claude CLI 逾時 300000ms 未回應」「exit code 1，錯誤內容：...」「exit code 0 但輸出為空，無法判讀」），不重試、不加 fallback、不假裝有回答。
   - `<outfile>` 非空不等於「有效回答」：內容 trim 後若仍是空白、明顯是錯誤訊息（例如需要登入、rate limit、模型不可用）、或看起來被截斷／只回報無法讀取檔案而沒有實際結論，一樣視為失敗並如實描述，不當成有效的第二意見。
   - 成功 → 讀 `<outfile>` 全文，作為 Claude 的完整回答。
   - 注意：`<errfile>` 在成功時常會有一行類似 `Warning: no stdin data received in 3s, proceeding without it.` 的訊息（因為 prompt 是用參數傳入，不是用 stdin）；這是良性警告，不代表失敗，判斷失敗只看 exit code 與 `<outfile>` 是否為空。

6. 用讀到的回答整理成結構化摘要，明確分四段：
   - **Claude 的結論**
   - **Claude 的支持證據／理由**
   - **與目前判斷的共識**
   - **尚未解決的分歧**

7. 帶著這份摘要回到目前任務繼續判斷與執行。這裡的「單次」指失敗不重試、不建立多輪對話；如果分歧仍需要釐清，允許在同一個使用者請求內明確帶入上一輪的分歧點再呼叫一次（最多再一次，不是無限重試），並在回報時標註這是第幾次呼叫。

## 輸出契約

- 一定要區分「Claude 說了什麼」與「我（Codex）認為什麼」，不得把兩者混寫成單一結論。
- 失敗就只回報失敗與原因，不得輸出看起來像成功的假回答。
- 最終判斷與是否採納 Claude 意見的決定權在目前的 Codex agent，Claude 只是顧問。

## 邊界

- 不建立 MCP、daemon、背景 process、狀態檔或跨 session 佇列。
- 不放寬被諮詢 Claude 的工具或權限，使其可以寫入檔案、commit、push、安裝依賴；工具白名單不限制可讀路徑範圍，不代表機密性保證。
- 不自動連續呼叫多輪；同一個使用者請求內最多允許一次額外的釐清呼叫（見執行流程步驟 7），不得無限重試或自動循環。
- 這個技能只在 Codex 端使用；不得複製一份在 Claude Code 端呼叫自己形成遞迴。
