# React 生产级组件规范与交付 SOP

本目录把两类责任彻底分开：

- **组件规范定义“正确组件必须是什么”**：公开 API、状态机、主路径、异常恢复、无障碍、视觉、性能、安全、兼容和验收 oracle。
- **生产 SOP 定义“如何把组件做到并证明正确”**：登记、评审、RED/GREEN、风险加固、发布、观察和回滚。

统一规范与类别规范是单组件规范必须继承的结果约束，不是开发步骤。旧的 309 份混合 SOP 已归档，仅可用于追踪来源和缺陷，不能驱动实现。

## 当前成熟度

- Catalog 范围：13 类、309 个组件。
- `ReviewReady`：5 个金标准候选，公开 API 仍为 `proposed`，存在未决项并等待角色审批。
- `Backlog`：304 个，只登记身份和阻塞项，没有可执行组件规范。
- `ImplementationReady`：0 个。
- `implementationAllowed`：0 个。

因此，当前目录**不能授权 AI 开始任何 React 组件实现**。只有组件索引和规范同时满足以下条件才可进入 SOP 的 RED：

```text
specificationStatus = ImplementationReady
implementationAllowed = true
publicApi.status = frozen
openDecisions = []
approval.status = approved
每个规定角色的批准记录绑定当前 specificationVersion
作者不在当前规范版本的批准人中
```

## 目录职责

```text
生产级组件SOP/
├─ 00-统一生产规范/        # 所有组件共同的结果底线
├─ 01-类别规范/            # 13 类组件的专属正确性约束
├─ 02-组件规范/            # 经人工编写和评审的单组件结果契约
├─ 03-生产SOP/             # 唯一的生产交付过程
├─ 04-机器索引与Schema/    # 309 项成熟度索引与规范 Schema
├─ 05-证据规范/            # 规范、实现、产物和审批证据要求
├─ 06-维护工具/            # 非破坏式索引与严格校验工具
└─ 07-历史迁移记录/        # 旧混合 SOP 与已确认缺陷
```

## 使用顺序

1. 从[机器索引](04-机器索引与Schema/component-spec-index.json)确认组件成熟度。
2. 读取[统一生产规范](00-统一生产规范/README.md)和对应类别规范。
3. 只有索引给出 `ImplementationReady` 时，才读取对应单组件规范并核对审批记录。
4. 通过准入后按[唯一生产 SOP](03-生产SOP/React组件生产交付SOP.md)从 RED 开始实施。
5. 按[证据规范](05-证据规范/README.md)保存与规范、源码和不可变产物绑定的证据。

`Backlog` 表示缺少规范，`Draft` 表示规范尚不完整，`ReviewReady` 表示可以评审；这三个状态都禁止编码。AI 不得自行补猜公开 API、业务不变量或审批结果后继续。

## 维护与验证

机器索引只读取已有规范并登记成熟度，不生成或覆盖规范：

```powershell
node .\生产级组件SOP\06-维护工具\build-component-spec-index.mjs
```

严格验证：

```powershell
node .\生产级组件SOP\06-维护工具\validate-component-specifications.test.mjs
node .\生产级组件SOP\06-维护工具\validate-component-specifications.mjs
node .\生产级组件SOP\06-维护工具\verify-specification-sop-separation.mjs
```

历史审计见[迁移记录](07-历史迁移记录/README.md)。旧生成器已随旧文档归档，不是维护入口。
