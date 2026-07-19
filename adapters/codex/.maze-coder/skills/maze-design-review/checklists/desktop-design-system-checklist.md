# Desktop GUI 與 Design System 檢查清單

## Desktop GUI

- [ ] 已在 Brief 指定的視窗尺寸、scale 與 theme 實際 render。
- [ ] 視窗縮放時沒有裁切、重疊、錯誤捲動或主要操作消失。
- [ ] 標題列、側欄、工具列與內容密度符合桌面操作情境。
- [ ] SVG 在目標 scale 下清晰，viewBox、比例與線寬沒有失真。
- [ ] Loading、empty、error、disabled 與 focus 等必要狀態可辨識。

## Design System Conformance（有正式系統時）

- [ ] 色彩、字型、間距、形狀與動態使用正式語意 tokens。
- [ ] 沒有無證據的新 token、重複元件或任意硬編值。
- [ ] 元件 variants、互動狀態及圖示語言符合 `DESIGN_SYSTEM.md`。
- [ ] 必要偏離已附原因、影響與回收方式，而非默默建立第二套規則。
