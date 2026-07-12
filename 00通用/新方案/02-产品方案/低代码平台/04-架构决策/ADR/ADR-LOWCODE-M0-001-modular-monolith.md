# ADR-LOWCODE-M0-001: M0 采用模块化单体

> 状态：accepted
> 日期：2026-07-05

## 背景

平台未来可能拆分设计态、运行态、插件、工作流等服务，但 M0 的主要风险在领域模型、动态 DDL、元数据缓存和工程门禁。过早微服务化会增加部署、事务、调试和测试复杂度。

## 决策

M0 采用一个 Spring Boot 应用启动的模块化单体：

```text
lowcode-common
lowcode-metamodel
lowcode-runtime
lowcode-designer
lowcode-expression
lowcode-plugin
lowcode-workflow
lowcode-app
```

模块边界用 Maven 模块、包结构和 ArchUnit 强制。

## 理由

- 先保证元模型内核正确。
- 降低本地开发和测试成本。
- 通过清晰模块边界为后续拆分保留路径。

## 否决方案

- 首版微服务：增加网络、部署、分布式事务和版本一致性复杂度。
- 单模块大应用：短期快，但边界会迅速腐化。

## 后果

- 所有模块在一个进程内运行。
- 禁止跨模块访问 `support` 包。
- 禁止 runtime 依赖 designer。
- 未来拆分服务前必须补 ADR。

## 验证

- T-001 ArchUnit 强制模块依赖。
- T-005 请求级 MetaGraph 版本固定，为未来多实例运行做准备。

