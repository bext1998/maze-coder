---
name: wmux-orchestrator
description: 在 wmux 多視窗終端機環境下，作為 orchestrator 對其他 pane 裡跑著不同 harness（Codex、Claude Code、Pi 等）的 agent 派工、追蹤進度、回收結果。使用者說「幫我把這個交給那幾個 pane 做」「盯著其他 pane 的進度」「協調一下其他 agent」等語句時觸發。建立在 `../wmux/SKILL.md` 已驗證的 primitive 之上，不重複其授權邊界與 send/read-screen 核對流程；內容以實測驗證為準。
---

# wmux-orchestrator

## 目標

在你（orchestrator）所在的 pane 裡，對 wmux 其他 pane 內正在互動運行的 agent 派工、以單行協議追蹤完成狀態、回收結果，並在卡住時正確升級（等待、重試或改為呼叫人類），而不是自己去實作任務或悄悄接手其他 pane 的工作。

## 前置條件

- 先完成 `../wmux/SKILL.md` 的「靜默環境偵測」，確認自己身處 wmux 並取得自己的 surface id。
- 已知或能透過 `tree`／`list-panes` 的 `customTitle` 找出至少一個目標 pane。
- 呼叫任何 wmux 指令前，一律套用 `../wmux/SKILL.md`「執行前的授權邊界：四類操作」的分級與確認要求——本文件不重複那份邊界，只在下面標注每個步驟屬於哪一類。

## Worker Registry（session 內、不落地）

Registry 只存在於目前這個 orchestrator session 的工作記憶／筆記裡，不寫入檔案、不建立跨 session 的狀態儲存（同 `../wmux/SKILL.md` 的邊界精神：不建立 daemon、背景 process 或狀態檔）。每次新 session 開始都要重新用 `tree`／`list-panes` 掃一次，不能假設沿用上一個 session 記下的內容仍然有效。

每個 worker 一筆，至少記錄：

| 欄位 | 說明 |
|---|---|
| `surfaceId` | 派工與追蹤的定位依據，來自 `tree`／`list-panes` |
| `customTitle` | 人類可讀標籤（如 `codex`、`pi`），只作辨識用，不保證等於實際 harness |
| `harness` | 實際觀察到的 harness（見下方「per-harness 適配層」），不確定時標記「未知」，不要用 `customTitle` 直接當作 harness 判斷依據 |
| `model` | 若畫面上看得到（狀態列、底部資訊列），記下觀察到的字串即可，不必精確解析 |
| `taskId` | 目前指派的任務 ID，`-` 表示閒置 |
| `status` | `idle`／`dispatched`／`busy`／`done`／`failed`／`blocked`／`unresponsive` 之一 |
| `pollCount` | 針對目前 `taskId` 已經 `read-screen` 輪詢的次數（沒有可靠時鐘來源，一律用輪詢次數而非時間戳記量測進度） |

## 單行任務封包協議

**派工格式**（`send` 一律單行，不內嵌換行——沿用 `../wmux/SKILL.md` 的既有限制）：

```
[TASK#<id>] <一句話任務指令>
```

- `<id>` 在目前 session 內必須唯一，建議用遞增序號（`1`、`2`、...）或「短序號＋pane 標籤」（如 `3-codex`）；不要重用已經指派過的 `<id>`，即使該任務已經結束。
- `<一句話任務指令>` 要能讓對方在不追問的情況下動手；需要更多背景時，把背景寫進同一行（例如檔案路徑、要看的 Issue 編號），而不是拆成多輪來回。

**完成標記**（要求 worker 在完成或卡住時，用下列格式之一回覆，作為輪詢時的判斷依據）：

```
DONE#<id>[: 一句話結果摘要]
FAILED#<id>: 一句話失敗原因
BLOCKED#<id>: 一句話說明卡在什麼決策或資訊上
```

- 派工訊息裡要明確要求對方使用這個格式（例如「完成後回覆 DONE#3，失敗回覆 FAILED#3: 原因」），不能只假設對方會自己遵守——本技能驗證過的兩種 harness 在被要求時都會照格式回覆一行文字（見下方 per-harness 記錄），但沒被要求就不會自發使用這個協議。
- `BLOCKED#<id>` 收到後不得自行替對方做決定並繼續派工；一律轉交人類（見「升級規則」）。

## 派工 → 核對 → 提交 → 輪詢 流程

以下每一步屬於 `../wmux/SKILL.md` 授權分級中的哪一類，標注在括號內：

1. **（唯讀）** `read-screen --surface <id> --lines 20` 確認目標 pane 目前是 `idle` 還是 `busy`（判斷方式見「per-harness 適配層」）。**忙碌就停止，不派工、不中斷、不用新指令蓋過去**——這是本技能最重要的邊界：目標 pane 忙碌時，正確行為是稍後再檢查，不是介入。
2. **（可逆寫入）** 確認 idle 後，`send --surface <id> "[TASK#<id>] ..."`。
3. **（唯讀）** 立刻再 `read-screen` 一次，確認任務封包完整、正確地出現在目標 pane 的輸入框裡（不同 harness 的輸入框視覺呈現不同，見下方記錄），而不是打到別的 pane 或被截斷。
4. **（可逆寫入）** 確認無誤後 `send-key enter --surface <id>`（注意旗標順序：`enter` 在前、`--surface` 在後）。
5. **（唯讀）** 輪詢 `read-screen`，在畫面中尋找 `DONE#<id>`／`FAILED#<id>`／`BLOCKED#<id>` 其中之一：
   - 找到 `DONE#<id>` → 更新 registry 為 `done`，回收結果摘要，任務結束。
   - 找到 `FAILED#<id>` → 更新為 `failed`，記錄原因，不自動重派同一個 `<id>`；要重試就開新的 `<id>`，並在派工訊息裡帶入前一次失敗的原因。
   - 找到 `BLOCKED#<id>` → 更新為 `blocked`，走「升級規則」的人類介入路徑。
   - 都沒找到 → 判斷目前是否仍顯示忙碌指標；忙碌就繼續等待再輪詢，不忙碌但也沒有標記就依「升級規則」處理。

## 升級規則

- **間歇性空讀**：`read-screen` 回傳 `{"text": "", "lines": 0}` 時，先照 `../wmux/SKILL.md` 的既有提醒重讀一次，不要第一時間就判定 pane 消失或任務卡住。
- **逾時／無標記**：連續多次輪詢（沒有可靠時鐘來源，一律用「連續 N 次讀不到忙碌指標也讀不到完成標記」而非經過幾秒鐘來判斷，N 依任務複雜度自行拿捏，簡單任務建議 3 次內就要有結果）都看不到忙碌指標、也看不到任何完成標記 → 標記該 worker 為 `unresponsive`，停止繼續空轉輪詢，改用 `notify` 告知使用者：目標 pane、`<id>`、已輪詢次數、最後一次畫面內容摘要。
- **忙碌**：只要能辨識出忙碌指標（見下方 per-harness 記錄；未知 harness 沒有已知忙碌指標時，改用「畫面內容是否較上次輪詢有變化」作為替代信號），就只是等待、不介入、不重送、不視為卡住。
- **目標 pane 消失**：`tree`／`list-panes` 找不到原本的 `surfaceId` → 不得假設任務結果、不得嘗試在別的 pane 上找同名任務繼續判斷，直接 `notify` 人類，交代原本派工內容與 `<id>`。
- **`BLOCKED#<id>`**：一律 `notify` 人類，附上對方回報的卡住原因；不得自行猜測答案後用同一個 `<id>` 或新 `<id>` 直接續派。

## Per-harness 適配層（實測記錄）

以下兩種 harness 已在本技能撰寫過程中，用上面的完整流程實際跑過一輪派工（`[TASK#SPIKE-*]` 請對方只回覆一行 `DONE#SPIKE-*`），兩次都成功；尚未觸發真實的 `FAILED`／`unresponsive`／pane 忙碌時搶送等失敗情境，這些情境目前是依 `../wmux/SKILL.md` 既有的通用提醒（`ok: true` 不保證真的發生、間歇性空讀）類推，不是本技能實測過的失敗案例。

| Harness | 忙碌指標 | Idle 指標 | 輸入框呈現 | 完成標記呈現 | 備註 |
|---|---|---|---|---|---|
| Codex（`codex exec`／互動 TUI） | 畫面出現 `─ Worked for <Xm Ys> ─` 進度列 | 灰底提示文字（如 `› Explain this codebase`）＋底部顯示目前 model／cwd | 送出文字前綴 `›` 顯示於輸入行 | 以 `• ` 開頭的一行（如 `• DONE#SPIKE-CODEX-1`），不是獨立的「結果框」 | 派工當下 pane 的可見分頁未必是終端機分頁（例如停在 diff 分頁），`--surface` 一樣能正確定位到終端機 surface 並送達，不受目前顯示哪個分頁影響 |
| Pi（`pi` CLI，互動模式） | 畫面出現字面文字 `Thinking...` | 無 `Thinking...`／忙碌字樣，底部狀態列顯示 token／cost／model（如 `... (auto)  moonshotai/kimi-...`） | 送出文字顯示在兩條 `───` 分隔線之間 | 直接以純文字一行呈現，內容與要求的格式完全一致，無額外裝飾 | 狀態列每輪都會更新（token 用量、cost），可作為「有沒有變化」的輔助信號，用於忙碌指標未知時的替代判斷 |

其他 harness（例如 opencode、其他 Claude Code pane）尚未實測，套用前比照上表方法：先用一次性測試任務觀察忙碌指標與完成標記的實際呈現，再正式納入派工流程；不要直接假設會跟上表兩種 harness 行為一致。

## 邊界

- 授權邊界、`send`/`read-screen` 核對流程、`--surface` 定位限制、`ok: true` 不代表成功等結論，一律引用 `../wmux/SKILL.md`，不在本文件複製或另立一份，避免兩份文件漂移。
- 不透過本技能建立任何跨 session 持久化的狀態檔、佇列或背景服務；worker registry 只存在於當次 orchestrator session。
- 不對忙碌中的 pane 送出新指令；忙碌與空閒的判斷依「per-harness 適配層」或「畫面內容是否變化」，不得單純假設對方一定閒置。
- 收到 `BLOCKED#<id>` 或判定 `unresponsive` 時，不得自行替對方做決策後继续派工，一律先 `notify` 人類。
- 不使用 `agent spawn` 去「附加」一個已經在互動運行的既有 pane（沿用 `../wmux/SKILL.md` 的既有結論）；worker 一律是已經存在、透過 `tree`／`list-panes` 找到的互動 pane。
