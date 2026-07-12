# ADR-0001：採用自適應技能包架構

## 狀態

Accepted

## 背景

固定階段、重複通用指令與所有技能常駐 Context 會限制強代理模型，也增加 token、詢問與無人閱讀的產物；完全移除技能約束則會遺失專案風險與輸出契約。

## 決策

以核心不變量、能力式 Guidance Profiles、輕量 Model Overlays、Host Adapters、canonical skills 與按需 references 組成技能包。模型可調整階段與工具，但不得省略安全、範圍、輸出、完成與真實驗證契約；只有觀察到具體失敗才加強 Profile。

## 替代方案

- 維持單一標準流程：一致但持續限制強模型並膨脹 Context。
- 完全交給模型、不提供技能契約：最輕量，但跨 Host 的安全與完成語意容易漂移。
- 為每種模型複製技能：可細調，但維護與同步成本高且快速過時。

## 後果

四套 Adapter 必須同步 skills、core、profiles 與 overlays；驗證需區分公開與 internal invocation。動態效益仍須以真實模型 trace 持續量測，若退化只補回有證據的最小規則。
