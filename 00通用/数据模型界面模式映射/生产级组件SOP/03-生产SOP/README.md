# 生产 SOP 分层与使用规则

本目录包含两层 SOP：

1. [React 组件生产交付总 SOP](React组件生产交付SOP.md)规定所有组件共同经过的准入、RED/GREEN、质量门禁、认证、发布和回滚过程。
2. `组件实施SOP/` 中的文件根据某个已批准组件规范，规定该组件特有的实现顺序、失败注入、组合验证、证据和停止条件。

两层必须同时执行。总 SOP 不能替代组件实施 SOP，组件实施 SOP 也不能降低总 SOP、统一规范、类别规范和单组件规范的要求。冲突时采用更严格要求，并停止执行直至冲突被修正规范化。

## 准入规则

组件实施 SOP 使用 `<category>-<id>.implementation-sop.md` 命名，且必须唯一映射 catalog 中的 `<category>:<id>`。

组件进入 `ImplementationReady` 前可以先编写和评审实施 SOP，但不得执行生产代码步骤。进入 RED 前必须同时满足：

```text
单组件规范.lifecycle = ImplementationReady
单组件规范.publicApi.status = frozen
单组件规范.openDecisions = []
单组件规范.approval.status = approved
机器索引.implementationAllowed = true
存在与 componentKey 对应的组件实施 SOP
总 SOP 和组件实施 SOP 的版本已写入执行清单
```

## 当前组件实施 SOP

- [DataGrid 组件实施 SOP](组件实施SOP/02-data-grid.implementation-sop.md)

`Backlog`、`Draft` 和 `ReviewReady` 组件只能编写、修订和评审规范及实施 SOP，不能开始 React 生产实现。
