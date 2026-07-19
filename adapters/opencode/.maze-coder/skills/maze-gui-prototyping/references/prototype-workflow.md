# Desktop GUI Prototype Workflow

## Host selection

先定位現有視窗、route、前端 entrypoint、元件庫、theme、資料形狀與啟動命令。有合理宿主時在原位置加入清楚命名的 prototype switch；只有全新 top-level surface 或沒有 App 骨架時，才建立獨立 HTML/CSS/SVG。

## Variants

預設三個、最多五個。每個方向應在 layout、資訊層級、navigation 或 primary affordance 至少一項有實質差異。共用真實資料形狀與必要品牌資產，但不要抽出會限制方向差異的共用 layout。

使用 query parameter、開發用 switcher 或專案既有 story 機制切換；選擇方式需可重現。Switcher 必須明顯不屬於正式 UI，且 production build 不可顯示。

## Safety and state

原型預設 read-only。任何 mutation、檔案操作、付款、通知、原生 bridge 或遠端寫入都改用可觀察 stub，並在畫面顯示 resulting state。至少涵蓋 Brief 指定的 normal、loading、empty、error、disabled 或 success 狀態，不為未要求的流程補齊後端。

## Evidence gate

以實際桌面視窗或等尺寸 browser viewport render；記錄 OS／runtime、尺寸、scale、theme、方向與狀態。先修正裁切、重疊、不可辨識、無法操作、SVG 失真等客觀阻擋，再請使用者選擇。不得由 agent 的分數取代使用者偏好。

## QA and handoff

選定方向後才驗證啟動、主要互動、鍵盤／focus、resize、資產載入及 stub 邊界。記錄勝出方向與理由；prototype 保持 throwaway，正式實作需另依 production 契約重寫或安全折入。
