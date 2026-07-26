---
name: wmux
description: 在 wmux（多視窗終端機）環境下操作其他 pane、跟另一個在互動運行的 agent 交接，或建立/清除 pane 與分頁時使用。使用者說「轉交給 codex/claude 那個 pane」「跟另一個 pane 說一聲」「切一個新的 pane」等語句、或畫面上出現多個 wmux pane 時觸發。內容以實測驗證為準，不是照抄 `wmux --help`。不涵蓋 `browser`／`markdown` 兩類指令——見使用者全域 CLAUDE.md 的 wmux 章節。
---

# wmux

## 目標

在 wmux 多視窗終端機環境下，安全、正確地操作其他 pane：讀取其他 pane 的畫面內容、把文字送進另一個正在互動運行的 agent pane（例如向另一個 coding CLI 交接審查或任務）、或視需要建立/清除 pane 與分頁——同時避開已經實際驗證過的幾個陷阱。

## 核心原則：`ok: true` 不代表指令真的做到了

這是整份技能最重要的一條通用警語。實測發現多個 wmux 指令會不管三七二十一回傳 `{"ok": true}`，但實際上什麼都沒做，或做在錯的目標上：

- `close-pane --surface <id>` 回傳 `ok: true`，但目標 pane 完全沒被關掉。
- `clear-notifications`（不帶參數或帶 `--surface`）回傳 `ok: true`，但通知清單完全沒變。
- `split`／`new-surface --pane <id>` 回傳成功，但實際建立的位置跟你指定的 `--pane`／`--surface` 無關。

**任何會改變狀態的呼叫，呼叫後都要用對應的唯讀指令（`read-screen`、`list-panes`、`tree`、`list-notifications`）重新查一次，確認真的發生了你以為發生的事，不要只看 `ok: true` 就當作成功。**

## 定位 pane／surface：`--surface`/`--pane` 不是通用旗標

這是第二重要的發現。`--surface`／`--pane` 這組看起來像是「泛用定位旗標」的參數，**只對三個指令真的有效**：`send`、`send-key`、`read-screen`。除此之外的指令，即使接受這個旗標也可能靜默忽略：

| 指令 | `--surface`/`--pane` 是否有效 | 正確定位方式 |
|---|---|---|
| `send`、`send-key`、`read-screen` | ✅ 有效，可靠 | 直接用 `--surface <id>` |
| `close-pane` | ❌ 無效（靜默忽略，`ok: true` 但沒關到） | 改用 verb form：`pane close <paneId>` |
| `close-surface` | 不適用（本來就吃位置參數） | `close-surface <surfaceId>` |
| `clear-notifications` | ❌ 無效 | 改用位置參數：`clear-notifications <notificationId>` |
| `split`、`new-surface --pane` | ❌ 無效，固定作用在 tree 裡第一個 leaf pane | 沒有已知的可靠定位方式；呼叫前後務必 `tree`/`list-panes` 核對，不要假設它會建在你想要的地方 |
| `zoom-pane` | 純渲染層 toggle，API 查不到效果 | 不建議用於自動化 |
| `focus-surface`／`focus-pane` | 效果無法驗證 | 不要依賴這兩個指令去改變任何後續指令的目標 |

**`send`／`send-key` 沒帶 `--surface` 時，會打到目前真正持有 OS 鍵盤焦點的 pane，不是任何邏輯上「選定」的 pane。** `--surface` 定位不需要目標 pane 曾經被使用者手動點過或呼叫過 `focus-surface`——對完全沒互動過的 pane 一樣可靠。

## 向另一個互動 agent pane 送出訊息（pane-to-pane 交接）

這是把文字可靠送進另一個正在互動運行的 CLI（例如另一個 Claude Code 或 Codex session）的完整流程：

1. `tree` 或 `list-panes` 找出目標 pane 的 `customTitle` 對應的 `surfaceId`。
2. `read-screen --surface <id> --lines 30` 確認目前畫面狀態（例如對方是否正忙碌中）。
3. `send --surface <id> "<訊息內容>"`——單行文字，避免內嵌換行（多行輸入在互動式 TUI 裡的行為未經驗證，換行可能被解讀成送出）。
4. **送出前務必再 `read-screen` 一次，確認文字正確出現在對方的輸入框裡，而不是打到別的 pane。** 這一步不可省略——本技能撰寫過程中就發生過文字誤打進呼叫者自己輸入框的真實案例。
5. 確認無誤後 `send-key enter --surface <id>` 送出。**注意旗標順序：`--surface` 要放在鍵名之後，`send-key --surface <id> enter` 會把 `--surface` 誤判成不合法的鍵名而報錯。**
6. 需要等待對方回覆時，重新 `read-screen` 輪詢；讀到 `{"text": "", "lines": 0}` 不要立刻當作對方畫面真的空白——先重讀一次，原因未明的間歇性空讀確實會發生。

## 建立／清除 pane 或分頁

- `split`／`new-surface` 目前實測固定建立在 tree 裡第一個 leaf pane 上，**沒有已知方法可以指定建在哪裡**。呼叫前先記錄 `tree`／`list-panes` 當基準，呼叫後立刻再查一次，確認新東西長在你預期或至少可接受的地方；如果蓋到別人正在看的 pane，立刻用 `close-surface <新 surface id>` 清掉。
- 關閉：pane 用 `pane close <paneId>`（verb form，可靠）；分頁用 `close-surface <surfaceId>`（可靠）。**不要用 `close-pane --surface <id>`**，實測無效。
- `zoom-pane` 不建議用於自動化流程——純視覺 toggle，無法驗證效果。
- `set-color-scheme`／`list-themes` 純粹是人類使用者的終端機外觀偏好，跟 agent 工作流程無關，不需要使用。

## Agent 指令家族（`agent spawn/status/list/kill`）：不是拿來跟既有 pane 對話的

`agent` 這組指令是用來啟動一個全新的、wmux 自己追蹤管理的 process（`spawn` 一定要帶 `--cmd`），**不能**用來「附加」或「登記」一個已經在互動運行的 pane——對一個既有的手動開啟的 pane 呼叫 `agent status <paneId>` 會回報 `Agent not found`。

- 如果目標是「跟一個已經在跑的互動式 agent session 交接訊息」（例如上面的 pane-to-pane 交接情境），**不要用 `agent` 這組指令**，用 `send`/`read-screen`。
- `agent spawn` 適合的情境是「啟動一個全新的背景任務」，不是溝通機制。預設落點問題跟 `split`/`new-surface` 一樣（見上），用完務必 `close-surface` 清理。
- `agent kill <agentId>` 實測可靠，會讓 `status` 變成 `exited` 並確實終止底層 process。
- `agent list` 是歷史紀錄，已結束的 agent 不會因為 process 死掉或 surface 被關閉就消失——判斷是否還活著要看每筆記錄的 `status` 欄位，不是看它出不出現在清單裡。

## 提醒人類 vs 跟另一個 agent 交換內容

`notify "<文字>"` 是「提醒人類去注意某個 pane」的機制，跟上面的 pane-to-pane `send` 交接是兩件事，可以搭配使用（先 `notify` 提醒、有需要再 `send` 實際內容）：

- `notify` 會自動掛在**呼叫者自己**的 surface 上（不像 `split`/`agent spawn` 那樣落到不確定的預設 pane），可以放心呼叫不用擔心定位問題。
- 有些通知是 wmux 系統自動產生的（例如背景指令執行完畢），不是只有手動 `notify` 才會有。
- `clear-notifications` 記得用位置參數帶通知 id（`clear-notifications <notificationId>`），`--surface` 對這個指令無效。
- `set-status`／`set-progress`／`log` 這組「Sidebar」指令的實際效果無法驗證——呼叫後 `read-screen` 看不到任何變化，推測是寫入畫面上另一塊 UI 區域，但沒有截圖能力可以確認。**不要把任何流程設計成依賴這三個指令的效果**，需要讓人類看到狀態時優先用 `notify`。

## 環境探測

進入 wmux 環境後，可以先呼叫這兩個唯讀指令確認自己身處的環境：

- `identify`：回傳 `{"name": "wmux", "version": ..., "platform": ...}`，確認自己確實在 wmux 底下執行。
- `capabilities`：回傳支援的 protocols／features，可用來事先判斷這個 wmux instance 是否支援你打算用的功能。
- `ping`（回傳 `pong`）、`list-windows`、`list-workspaces` 是簡單的健康檢查/查詢指令，不需要深入。

## 不建議使用／超出範圍

以下指令存在，但跟「pane 間定位/溝通」這個技能的目標無關，或風險/機密性考量超出範圍，**不建議 agent 主動呼叫**：

- `focus-window`／`new-window`：人類手動管理 OS 視窗的操作。
- `new-workspace`／`close-workspace`／`select-workspace`／`rename-workspace`：workspace 生命週期管理，`close-workspace` 可能關掉使用者目前所有工作。
- `ssh`／`bridge`／`token`：跨機器/跨網路操作 wmux 的進階功能；`token` 會印出這個 wmux instance 的有效驗證憑證，不要呼叫或把輸出貼到任何地方。
- `hook --event`：手動觸發使用者自訂的 hook，後果依使用者的設定而定、無法預期。
- `trigger-flash`：用途是推測（可能是吸引人類注意力的視覺提示），未經螢幕視覺驗證，不建議寫進關鍵流程。

## 邊界

- 建立/移除 pane、分頁、agent process 前後，一律用 `tree`/`list-panes`/`agent list` 核對實際狀態，不要只信呼叫的回傳值。
- 不透過 `agent spawn` 或任何其他機制去附加、控制一個已經在互動運行的既有 pane——那不是這組指令的設計用途。
- 不呼叫 `token`、不執行 `hook --event`、不呼叫 `ssh`/`bridge`——這些不在本技能範圍內。
- 對其他 pane 送出文字前，先 `read-screen` 確認狀態；送出後，在按 `send-key enter` 之前再 `read-screen` 一次確認內容正確落在目標 pane。
