# 组件规范与实现证据

规范定义正确答案，SOP 定义执行过程，证据证明实现确实符合答案。

实际证据按版本存放：

```text
quality/evidence/<component-key>/<component-version>/
├─ manifest.json
├─ specification.json
├─ test-results/
├─ accessibility/
├─ visual/
├─ performance/
├─ package/
├─ approvals.json
└─ rollback.md
```

硬规则：

- `manifest.json` 绑定 `specificationVersion`、源码修订、候选产物哈希和 SOP 版本；规范版本变化后旧审批和实现证据失效。
- RED 原始输出必须保留，不能被 GREEN 覆盖。
- 每条 `acceptanceOracles[].id` 必须映射到自动测试或明确的人工复核记录。
- 截图不能替代事件、焦点、读屏、性能或错误恢复断言。
- R2 记录代表性消费项目完整验收；R3 记录领域/安全批准、受控灰度和回滚演练。
- 候选产物或冻结规范变化后，受影响证据失效。
