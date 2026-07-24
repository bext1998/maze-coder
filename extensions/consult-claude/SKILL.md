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

3. 用 Write 工具把組好的完整 prompt 存到 scratchpad 的暫存檔（例如 `consult-claude-prompt.txt`）。

4. 用 **Bash 工具**（不要用 PowerShell，避免 Windows 對多行字串與引號的轉義問題）在目前工作目錄（不要 `cd` 到別處）執行：

   ```bash
   claude -p "$(cat "<promptfile>")" \
     --tools "Read,Grep,Glob" \
     --permission-mode bypassPermissions \
     --disable-slash-commands \
     --output-format text \
     > "<outfile>" 2> "<errfile>"
   ```

   - `--tools "Read,Grep,Glob"`：唯讀邊界的核心——被諮詢的 Claude 沒有 Edit/Write/Bash/NotebookEdit，物理上無法修改檔案、commit、push、裝套件或跑破壞性指令。
   - `--permission-mode bypassPermissions`：只在上面已經被鎖死成唯讀工具的前提下，避免它在非互動模式卡在權限詢問上（沒有人可以回應）。
   - `--disable-slash-commands`：關閉所有技能觸發，防止被諮詢的 Claude 又觸發 `consult-codex` 造成遞迴。
   - Bash 工具呼叫時設定 `timeout`（建議 180000–300000ms，問題越複雜可以拉長，但不要無上限等待）。

5. 呼叫結束後判讀結果（直接用 Read 工具讀檔案內容自己判斷，不寫解析腳本、不用 jq/python）：
   - Bash 逾時、exit code 非 0、或 `<outfile>` 是空的（不論 `<errfile>` 是否有內容）→ 判定失敗。直接回報具體失敗原因（例如「claude CLI 逾時 300000ms 未回應」「exit code 1，錯誤內容：...」「exit code 0 但輸出為空，無法判讀」），不重試、不加 fallback、不假裝有回答。
   - 成功 → 讀 `<outfile>` 全文，作為 Claude 的完整回答。
   - 注意：`<errfile>` 在成功時常會有一行類似 `Warning: no stdin data received in 3s, proceeding without it.` 的訊息（因為 prompt 是用參數傳入，不是用 stdin）；這是良性警告，不代表失敗，判斷失敗只看 exit code 與 `<outfile>` 是否為空。

6. 用讀到的回答整理成結構化摘要，明確分四段：
   - **Claude 的結論**
   - **Claude 的支持證據／理由**
   - **與目前判斷的共識**
   - **尚未解決的分歧**

7. 帶著這份摘要回到目前任務繼續判斷與執行。v1 不自動多輪；只有在認為分歧仍需要釐清時，才「明確帶入上一輪的分歧點」再呼叫一次，不無限重試。

## 輸出契約

- 一定要區分「Claude 說了什麼」與「我（Codex）認為什麼」，不得把兩者混寫成單一結論。
- 失敗就只回報失敗與原因，不得輸出看起來像成功的假回答。
- 最終判斷與是否採納 Claude 意見的決定權在目前的 Codex agent，Claude 只是顧問。

## 邊界

- 不建立 MCP、daemon、背景 process、狀態檔或跨 session 佇列。
- 不放寬被諮詢 Claude 的工具或權限，使其可以寫入檔案、commit、push、安裝依賴。
- 不在單一使用者請求內自動連續呼叫多輪；每次新的呼叫都必須是目前 agent 主動判斷後的獨立決定。
- 這個技能只在 Codex 端使用；不得複製一份在 Claude Code 端呼叫自己形成遞迴。
