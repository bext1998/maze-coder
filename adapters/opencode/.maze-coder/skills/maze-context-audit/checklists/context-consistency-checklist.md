# 上下文一致性稽核清單

## 功能範圍一致性

- [ ] Agent 對「要做什麼」的理解，是否符合 `spec.md` 的目標與非目標？
- [ ] 是否有 agent 正在實作但 spec.md 明確排除的功能？
- [ ] 是否有 spec.md 要求的功能，agent 沒有提到？

## 當前狀態一致性

- [ ] Agent 認為的當前階段，是否與 `STATUS.md` 一致？
- [ ] Agent 認為「已完成」的事項，是否與 `STATUS.md` 的完成清單一致？
- [ ] `STATUS.md` 中的阻塞項目，agent 是否知情？

## 下一步一致性

- [ ] Agent 計畫的下一步，是否與 `NEXT_ACTION.md` 一致？
- [ ] 是否有 `NEXT_ACTION.md` 列出的行動，agent 沒有計畫執行？

## 決策一致性

- [ ] Agent 使用的技術棧，是否與 `DECISIONS.md` 或 `PROJECT_BRIEF.md` 一致？
- [ ] 是否有 agent 做的決策，但 `DECISIONS.md` 沒有記錄？
- [ ] 是否有 `DECISIONS.md` 中的決策，agent 似乎不知道？

## 文件存在性

- [ ] `spec.md` 是否存在且非空？
- [ ] `STATUS.md` 是否存在且非空？
- [ ] `NEXT_ACTION.md` 是否存在且非空？
