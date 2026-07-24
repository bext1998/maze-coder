---
name: consult-codex
description: 需要 Codex 的獨立第二意見時使用：直接呼叫本機 codex CLI，就目前修法、方案或診斷徵詢 Codex 的判斷，並整理共識與分歧。使用者說「問 Codex」「請 Codex 審視這個方案」「讓 Codex 看看」「Codex 會怎麼看這個」等語句時觸發。同步、單次、唯讀——不做多輪、不建立常駐服務、不遞迴呼叫。
---

# consult-codex

## 目標

在不離開目前工作、不需要使用者手動複製貼上的情況下，取得 Codex 對目前問題的獨立判斷，作為第二意見輸入目前的決策，而不是取代目前 agent 的判斷。

## 前置條件

- 已有具體待決策的問題（修法選擇、方案取捨、Bug 根因診斷等），不是單純想找人重讀整份程式碼。
- 用 `codex --version` 快速確認 CLI 存在；不存在、版本查詢失敗，或明顯未登入，直接回報並停止，不嘗試安裝、登入或改用其他管道。

## 執行流程

1. **組 prompt**（自己動筆整理，不是照抄對話紀錄），固定包含：
   - 目標：現在要解決什麼問題、為什麼要問。
   - 現況：目前傾向的方案或修法，以及相關檔案路徑（給路徑讓 Codex 自己讀，不要整段貼原始碼，除非片段本來就很短）。
   - 已知證據：已經確認的事實、已排除的可能性。
   - 限制：不能做什麼、有什麼硬性條件。
   - 具體疑問：要 Codex 回答的確切問題（例如「這個修法有沒有遺漏的邊界情況」）。
   - 禁止把完整對話紀錄、完整 log 或無關檔案整包貼進去。

2. Prompt 最後固定逐字附上這段角色與邊界宣告：

   ```
   You are being consulted read-only by another coding agent (Claude Code) working in this same directory. Give your own independent analysis — do not simply defer to or agree with the asker. You are running under a read-only sandbox and cannot edit files, commit, push, install dependencies, or run destructive commands. This is a single synchronous turn: do not attempt to invoke any consult-claude/consult-codex skill or shell out to another CLI yourself, even if it seems relevant. Answer directly with: your conclusion, the evidence/reasoning behind it, and anything you are genuinely uncertain about.
   ```

3. 用 Write 工具把組好的完整 prompt 存到 scratchpad 的暫存檔（例如 `consult-codex-prompt.txt`）。

4. 用 **Bash 工具**（不要用 PowerShell，避免 Windows 對多行字串與引號的轉義問題）在目前工作目錄（不要切換目錄）執行：

   ```bash
   codex exec \
     -s read-only \
     --disable multi_agent \
     --output-last-message "<outfile>" \
     "$(cat "<promptfile>")" \
     > "<logfile>" 2> "<errfile>"
   ```

   - `-s read-only`：唯讀邊界的核心——被諮詢的 Codex 物理上無法寫入檔案、commit、push、裝依賴。
   - 注意：`-a`/`--ask-for-approval` 只存在於 `codex`（互動 TUI）本身，`codex exec` 子命令**不接受**這個旗標（實測會直接報 `unexpected argument '-a'` 並以 exit code 1 失敗）。`codex exec` 在非互動模式下本來就不會卡住等待核可；`-s read-only` 已經足以讓任何需要寫入的動作直接被拒絕並回饋給模型。
   - `--disable multi_agent`：關閉這次呼叫的原生子代理功能，避免被諮詢的 Codex 又 spawn 平行子代理，讓結果單純、可預期。
   - `--output-last-message "<outfile>"`：把 Codex 的最終回答單獨寫成一個乾淨檔案，不用去解析完整的執行過程輸出。
   - `<logfile>` 只在失敗時用來輔助診斷，正常情況不需要讀它（避免把完整執行過程灌進自己的 context 浪費 token）。
   - Bash 工具呼叫時設定 `timeout`（建議 180000–300000ms，問題越複雜可以拉長，但不要無上限等待）。

5. 呼叫結束後判讀結果（直接用 Read 工具讀檔案內容自己判斷，不寫解析腳本、不用 jq/python）：
   - Bash 逾時、exit code 非 0、或 `<outfile>` 不存在／是空的（不論 `<errfile>` 是否有內容）→ 判定失敗。需要診斷原因時才讀 `<errfile>`（或 `<logfile>` 尾端），直接回報具體失敗原因（例如「codex CLI 逾時 300000ms 未回應」「exit code 1，錯誤內容：...」「exit code 0 但輸出為空，無法判讀」），不重試、不加 fallback、不假裝有回答。
   - 成功 → 讀 `<outfile>` 全文，作為 Codex 的完整回答。

6. 用讀到的回答整理成結構化摘要，明確分四段：
   - **Codex 的結論**
   - **Codex 的支持證據／理由**
   - **與目前判斷的共識**
   - **尚未解決的分歧**

7. 帶著這份摘要回到目前任務繼續判斷與執行。v1 不自動多輪；只有在認為分歧仍需要釐清時，才「明確帶入上一輪的分歧點」再呼叫一次，不無限重試。

## 輸出契約

- 一定要區分「Codex 說了什麼」與「我（Claude）認為什麼」，不得把兩者混寫成單一結論。
- 失敗就只回報失敗與原因，不得輸出看起來像成功的假回答。
- 最終判斷與是否採納 Codex 意見的決定權在目前的 Claude agent，Codex 只是顧問。

## 邊界

- 不建立 MCP、daemon、背景 process、狀態檔或跨 session 佇列。
- 不放寬被諮詢 Codex 的 sandbox，使其可以寫入檔案、commit、push、安裝依賴。
- 不在單一使用者請求內自動連續呼叫多輪；每次新的呼叫都必須是目前 agent 主動判斷後的獨立決定。
- 這個技能只在 Claude Code 端使用；不得複製一份在 Codex 端呼叫自己形成遞迴。
