# 上下文一致性稽核清單

## 功能範圍一致性

- [ ] Agent 對「要做什麼」的理解，是否符合 `spec.md` 的目標與非目標？
- [ ] 是否有 agent 正在實作但 spec.md 明確排除的功能？
- [ ] 是否有 spec.md 要求的功能，agent 沒有提到？

## 當前狀態一致性

- [ ] Agent 認為的當前階段，是否與 Git branch／working tree、Issue、PR、CI 與規格證據一致？
- [ ] Agent 認為「已完成」的事項，是否有對應 GitHub／Git 證據？
- [ ] 已知阻塞是否有可驗證的外部證據？

## 下一步一致性

- [ ] Agent 計畫的下一步，是否與 `NEXT_ACTION.md` 一致？
- [ ] 是否有 `NEXT_ACTION.md` 列出的行動，agent 沒有計畫執行？

## 決策一致性

- [ ] Agent 使用的技術棧，是否與 `DECISIONS.md` 或 `PROJECT_BRIEF.md` 一致？
- [ ] 是否有使用者明確要求同步的重大決策，但 `DECISIONS.md` 沒有唯一權威連結？
- [ ] 是否有 `DECISIONS.md` 中的決策，agent 似乎不知道？

## 文件存在性

- [ ] `spec.md` 是否存在且非空？
- [ ] `NEXT_ACTION.md` 是否存在且非空？
