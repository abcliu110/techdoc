# React 组件统一生产规范

本目录回答“所有组件做成什么样才算正确”，不描述开发步骤。开发步骤见[唯一生产 SOP](../03-生产SOP/React组件生产交付SOP.md)。

## 1. 实现准入

AI 只有在机器索引中看到组件同时满足以下条件时才允许编码：

- `specificationStatus = ImplementationReady`
- `implementationAllowed = true`
- 组件规范 `publicApi.status = frozen`
- `openDecisions = []`
- `approval.status = approved`
- 每个 `approval.requiredRoles` 都有绑定当前 `specificationVersion` 的批准记录

`Backlog`、`Draft`、`ReviewReady` 均禁止实现。AI 必须先补齐并请求评审，不能自行猜测后继续。

审批角色使用固定 ID，禁止作者自行创造或缩减角色：`component-maintainer`（组件库维护者）、`ux-a11y-reviewer`（UX/无障碍评审人）、`test-reviewer`（测试评审人）、`domain-security-reviewer`（领域/安全评审人）。`approval.authors` 中的任何作者不得出现在同一规范版本的批准记录中。

## 2. 公开 API

- React + TypeScript 严格模式；公共类型不得泄漏内部实现类型。
- 每个组件规范必须明确导出名、包子路径、Props、事件、ref 能力、默认值及受控/非受控优先级。
- 默认值、事件时序、DOM 语义、键盘、焦点和令牌均属于兼容面。
- 事件描述事实，不传递可变内部对象，不要求消费方读取 DOM 推断状态。

## 3. 状态与错误

- 每个状态必须有进入条件、退出条件、可见表现和允许动作。
- 异步组件必须定义取消、乱序响应、卸载后返回、重试和重复触发语义。
- 错误必须说明原因、影响对象、被阻止的副作用和恢复动作。
- 恢复不得静默丢失输入、选择、草稿或焦点上下文。

## 4. 无障碍

- 目标为 WCAG 2.2 AA。
- 优先原生语义；自定义复合控件必须采用对应 WAI-ARIA pattern。
- 主路径、异常路径和恢复路径均可只用键盘完成。
- 组件规范必须逐键定义行为、焦点入口、焦点环、关闭后的焦点返回和动态播报。

## 5. 视觉与响应式

- 使用 `@company/tokens`，不得在组件规范外创造私有视觉体系。
- 每个规范必须定义稳定尺寸、溢出、长文本、空态、错误态、加载态、暗色、密度和减少动态效果行为。
- 至少覆盖 1440x900、1024x768、390x844 及相邻断点；组件规范可增加更严格矩阵。

## 6. 性能与包边界

- 直接交互到可见反馈 p95 不高于 100ms；连续交互不得持续产生超过 50ms 的组件长任务。
- 每个组件规范必须给出数据规模、设备档位、测量动作、运行次数和 gzip 增量预算。
- ESM、类型、CSS、SSR、子路径与 Tree Shaking 必须通过隔离消费验证。

## 7. 安全与服务端边界

- 前端隐藏、禁用和输入校验不构成权限、租户、幂等或领域安全保证。
- R3 规范必须写出服务端最终裁决、禁止副作用、幂等/并发条件和审计要求。
- 不受信 HTML、模板、SQL、URL、文件和富文本不得被组件执行。

风险最低等级由 `risk.signals` 的受控枚举计算。`data-integrity`、`async-state`、`persistent-business-state`、`large-data` 至少 R2；`permission`、`identity`、`multi-tenant`、`sensitive-data`、`money`、`inventory`、`order`、`payment`、`invoice`、`settlement`、`irreversible`、`cross-system` 强制 R3。自由文本 `triggers` 只解释升级场景，不能降低结构化信号得出的等级。

## 8. 验收 oracle

规范中的每条关键行为必须写成精确的 Given/When/Then，包含固定 fixture、公开操作、可观察输出、事件顺序和禁止副作用。只写“正确显示”“符合契约”“完成操作”不构成验收条件。
