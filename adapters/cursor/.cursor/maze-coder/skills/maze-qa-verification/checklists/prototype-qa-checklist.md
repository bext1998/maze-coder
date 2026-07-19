# GUI Prototype QA 檢查清單

- [ ] 記錄的單一啟動命令可在指定環境重現。
- [ ] 每個方向與選定方向可用記錄的 URL、參數或 switcher 重現。
- [ ] 主要互動、鍵盤、focus 與適用的 disabled／loading 狀態符合 Brief。
- [ ] 指定視窗尺寸與 resize 不會阻斷主要流程。
- [ ] HTML、CSS、SVG、字型與本地資產沒有載入失敗。
- [ ] mutation、原生 bridge、持久化與外部服務保持 stub，且結果可觀察。
- [ ] 若使用設計系統，token 引用可解析且沒有未記錄的硬編偏離。
- [ ] 報告區分原型可供決策與 production-ready；兩者不得混為一談。
