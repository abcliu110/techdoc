# 07 编辑器类生产级组件类别 SOP

> 组件数：20
>
> 关注域：文档模型、撤销历史、校验、版本和安全输出
>
> 风险初始分布：R1 0 / R2 18 / R3 2

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：文档模型、撤销历史、校验、版本和安全输出。
- 类别状态模型：文档值、选择区、撤销栈、脏状态、校验、预览、版本与协作修订。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 解析或校验失败无法定位
- 切换格式、预览或关闭时未保存内容丢失
- 协作冲突、危险内容或不受信执行

## 3. 强制验证

- 验证输入、序列化、反序列化和撤销/重做保持语义
- 验证解析失败、冲突合并、版本恢复和草稿保留
- 验证不受信 HTML、模板、SQL、脚本或 URL 不被组件执行

## 4. 性能与规模基线

以 1 MB 文档或 10,000 个结构节点为复杂编辑基准；键入反馈 p95 不高于 100ms，解析和预览长任务必须可取消或移出主线程。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若内容可执行、可发布、可修改生产 Schema/SQL/规则或包含敏感协作数据，升级为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [富文本编辑器](../02-组件SOP/07-编辑器类/07-rich-text-editor.md) | `07:rich-text-editor` | B | R2 | Draft / 未认证 |
| [Markdown 编辑器](../02-组件SOP/07-编辑器类/07-markdown-editor.md) | `07:markdown-editor` | B | R2 | Draft / 未认证 |
| [代码编辑器](../02-组件SOP/07-编辑器类/07-code-editor.md) | `07:code-editor` | B | R2 | Draft / 未认证 |
| [JSON 结构编辑器](../02-组件SOP/07-编辑器类/07-json-editor.md) | `07:json-editor` | B | R2 | Draft / 未认证 |
| [YAML 编辑器](../02-组件SOP/07-编辑器类/07-yaml-editor.md) | `07:yaml-editor` | B | R2 | Draft / 未认证 |
| [XML 编辑器](../02-组件SOP/07-编辑器类/07-xml-editor.md) | `07:xml-editor` | B | R2 | Draft / 未认证 |
| [公式编辑器](../02-组件SOP/07-编辑器类/07-formula-editor.md) | `07:formula-editor` | B | R2 | Draft / 未认证 |
| [表达式编辑器](../02-组件SOP/07-编辑器类/07-expression-editor.md) | `07:expression-editor` | B | R2 | Draft / 未认证 |
| [SQL 编辑器](../02-组件SOP/07-编辑器类/07-sql-editor.md) | `07:sql-editor` | B | R3 | Draft / 未认证 |
| [可视化查询编辑器](../02-组件SOP/07-编辑器类/07-visual-query-editor.md) | `07:visual-query-editor` | B | R2 | Draft / 未认证 |
| [模板编辑器](../02-组件SOP/07-编辑器类/07-template-editor.md) | `07:template-editor` | B | R2 | Draft / 未认证 |
| [邮件模板编辑器](../02-组件SOP/07-编辑器类/07-email-template-editor.md) | `07:email-template-editor` | B | R2 | Draft / 未认证 |
| [结构化文档编辑器](../02-组件SOP/07-编辑器类/07-document-editor.md) | `07:document-editor` | B | R2 | Draft / 未认证 |
| [电子表格编辑器](../02-组件SOP/07-编辑器类/07-spreadsheet-editor.md) | `07:spreadsheet-editor` | B | R2 | Draft / 未认证 |
| [差异对比编辑器](../02-组件SOP/07-编辑器类/07-diff-editor.md) | `07:diff-editor` | B | R2 | Draft / 未认证 |
| [版本比较编辑器](../02-组件SOP/07-编辑器类/07-version-editor.md) | `07:version-editor` | B | R2 | Draft / 未认证 |
| [协同编辑器](../02-组件SOP/07-编辑器类/07-collaborative-editor.md) | `07:collaborative-editor` | B | R2 | Draft / 未认证 |
| [图形编辑器](../02-组件SOP/07-编辑器类/07-diagram-editor.md) | `07:diagram-editor` | B | R2 | Draft / 未认证 |
| [图像标注编辑器](../02-组件SOP/07-编辑器类/07-image-annotation-editor.md) | `07:image-annotation-editor` | B | R2 | Draft / 未认证 |
| [Schema 编辑器](../02-组件SOP/07-编辑器类/07-schema-editor.md) | `07:schema-editor` | B | R3 | Draft / 未认证 |
