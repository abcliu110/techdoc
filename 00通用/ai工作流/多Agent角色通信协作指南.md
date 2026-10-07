# 多Agent角色通信协作指南

> 版本：v4.3.0
> 创建日期：2026-10-06
> 状态：兼容入口，强制执行规则见同目录规范

## 强制执行入口

本文件保留历史协作说明和检查清单，作为阅读入口。实际执行时，以下文件具有唯一权威性：

1. [00-AI研发执行协议.md](./00-AI研发执行协议.md)：角色、状态、checkpoint、证据和阻塞规则。
2. [01-AI软件架构设计规范.md](./01-AI软件架构设计规范.md)：需求、领域、后端、前端和非功能架构设计。
3. [02-AI软件测试与代码质量规范.md](./02-AI软件测试与代码质量规范.md)：测试、E2E、可视化、Clean Code 和评审。
4. [ai研发质量门.yaml](./ai研发质量门.yaml)：机器可读的质量门、角色、命令和证据约束。
5. [03-AI质量门控制器接口规范.md](./03-AI质量门控制器接口规范.md)：文件写入、命令执行和功能推进的拒绝默认控制器接口。

执行器必须先加载 `00-AI研发执行协议.md` 和 `ai研发质量门.yaml`，再按任务类型加载架构和测试规范。本文与上述文件冲突时，以版本号较新的规范文件和 YAML 质量门为准；Agent 不得使用本文旧版状态或质量要求绕过质量门。

启动硬门：必须先读取项目 `CLAUDE.md` 和上述 4 个权威文件，并通过 `workflow_bootstrap_verified`、`agent_runtime_verified`、`agent_assignments_verified`。规范读取失败、Agent 工具参数错误、子 Agent 创建失败或返回身份无法验证时，立即进入 `blocked`；不得由主 Agent 继续编码、测试或评审。每个 `feature_id` 都必须创建独立的 `feature_team`，不能只在项目层面分配几个角色。

本项目不提供 `strict/simple/single` 模式选择，唯一允许的执行模式是 `strict_multi_agent`。MVP、Token 成本或项目规模不能成为降低质量门的理由；模型不得向用户询问或提供降级选项。

新建项目或不参考现有文件不等于快速启动。仍必须完成规范启动、Agent 运行时验证、每个小功能的 `feature_team` 分配、完整设计与对抗评审、测试策略、自动化测试、E2E/视觉验证和最终验收。不得让用户选择“快速模式/严格模式”，也不得把“设计批准后创建 Agent → 编码”当作完整流程。

首轮必须输出 `WORKFLOW_PREFLIGHT`，只报告规范、Agent 运行时、功能小组和下一质量门状态；不得输出模式选择题、快速启动方案或直接创建项目文件。

---

## 核心原则（11条）

1. **消息协调，交付物证明，验收关闭任务**
2. **每个任务只有一个Task Owner**
3. **按依赖关系并行，无依赖可并行**
4. **契约先于实现，变化触发复核**
5. **实现者不能单独批准自己的产物**
6. **允许审查结论为"未发现问题"**
7. **任务关闭必须可复现**
8. **交互不明确时必须阻塞**
9. **交互任务必须真实操作页面**
10. **测试安装和服务器启动不等于测试通过，必须提交实际命令、退出码和报告证据**
11. **每个 checkpoint 必须执行 TDD：Red → Green → Refactor，不能先写完代码再补测试**
12. **每个 `feature_id` 必须独立验收，验收通过前不得开始下一个功能**

一个 `feature_id` 是一个独立验收周期，同一时间只能有一个功能处于开发中。当前功能必须完成 TDD、自动化测试、代码整洁检查、对抗评审和适用的真实 E2E 后，执行 `feature_acceptance_passed`：后端走真实 API/集成链路，前端和全栈走真实浏览器 E2E，Task Owner 与 Acceptance Challenger 独立确认同一版本。验收失败、证据缺失或存在高/阻断缺陷时保持 `blocked`，Feature Orchestrator 不得启动下一个功能。

---

## 角色与责任

| 角色 | 责任 | 必须交付 |
|------|------|----------|
| Task Owner | 明确目标、批准整体验收 | 任务契约、验收记录 |
| Task Orchestrator | 拆分任务、安排依赖 | 任务看板、状态记录 |
| 设计师 | 定义交互流程、状态反馈 | 交互契约、验收场景 |
| 架构师 | 定义Schema、接口契约 | 版本化Schema |
| 前端开发 | 实现页面交互 | 代码版本、运行地址 |
| 内容专家 | 创建学习内容 | 内容文件、校验结果 |
| 测试专家 | 执行测试 | 测试报告、缺陷记录 |
| 独立验证者 | 真实用户流程验证 | 操作记录、问题清单 |

**冲突矩阵**：设计/实现/验证分离，审查者不得是被审查产物的实现者。

---

## 任务契约模板

```yaml
task_id: MODULE-001
title: 任务标题
task_owner: xxx
dependencies:
  - task_id: DEP-001
    version: schema@1.0.0
outputs:
  - type: code
    path: src/xxx.ts
  - type: test
    path: tests/xxx.spec.ts
acceptance:
  - 验收条件1
  - 验收条件2
evidence_required:
  - test_command_and_result
  - screenshot_or_recording
status: ready
```

**规则**：
- task_id格式：`模块-序号`，全项目唯一
- 消息必须引用task_id和产物版本
- 重要结论必须写入持久化记录

---

## 状态机

```
draft → ready → in_progress → ready_for_review → review_accepted → integrated → closed
                         ↓               ↓
                  changes_requested    needs_revalidation
```

| 状态 | 说明 |
|------|------|
| `draft` | 任务已创建 |
| `ready` | 目标/依赖/验收已明确 |
| `in_progress` | 实现进行中 |
| `ready_for_review` | 产物已提交 |
| `review_accepted` | 审查通过 |
| `integrated` | 集成通过 |
| `blocked` | 挂起（原因消除后恢复原状态） |
| `needs_revalidation` | 需重新验证 |
| `closed` | **终态** |

本文的简化状态表不能覆盖功能级状态。实际执行必须使用权威状态机：当前 `feature_id` 必须依次通过 `feature_acceptance_passed`、`defect_registry_resolved`、`feature_evidence_frozen`、`feature_closed`，并在存在下一个功能时通过 `next_feature_authorized`；这些门未通过前不得创建或启动下一个功能。

---

## 交互契约

### 必须说明

- 用户目标和完成条件
- 可操作元素、触发方式
- 初始/操作中/成功/失败/重试状态
- 每次操作的视觉反馈

### AI处理顺序

1. 定义用户任务（不接受模糊描述）
2. 定义状态转换
3. 实现一个完整小场景
4. 真实浏览器操作验证
5. 失败后回归验证

### 状态机模板

```text
场景：选择分数条分块
初始 → 点击分块2 → 已选中
      ├─ 再次点击 → 初始
      ├─ 提交+正确 → 完成
      └─ 提交+错误 → 错误提示
```

### 元素标识（推荐）

```tsx
<article data-testid={`card-${id}`} data-kp-id={id}>
<div data-testid="interaction" data-type="split-circle">
<button data-testid="complete" aria-label="完成">
```

---

## Schema契约

架构师定义，前端必须按版本实现。

```typescript
const ApplesConfigSchema = z.object({
  totalApples: z.number().int().nonnegative(),
  highlightRange: z.tuple([z.number(), z.number()]),
});
```

**规则**：
- 数组区间必须明确闭/半开
- 变更必须升版本号
- 无效数据不得进入渲染/存储

---

## 测试分层

| 层级 | 工具 | 验证内容 |
|------|------|----------|
| 数据层 | Schema验证 | JSON格式、数据契约 |
| 组件层 | 单元测试 | 函数逻辑、组件渲染 |
| 交互层 | E2E测试 | 单功能用户操作 |
| 集成层 | 端到端测试 | 完整业务流 |

### E2E测试要求

```typescript
// ✅ 正确：真实点击+状态验证
await page.click('[data-testid="complete"]');
await expect(page.locator('.btn-primary')).toBeEnabled();

// ❌ 错误：只测试渲染
const btn = render(<Button />);
expect(btn).toBeTruthy();
```

**必须覆盖**：
1. 点击扇形 → 高亮变化
2. 正确操作 → 按钮启用
3. 点击完成 → 进入下一步
4. 完成所有 → 显示完成页

**命令**：`npm run test:e2e` 或 `npx playwright test`

---

## 质量门（三道）

| 门 | 内容 |
|----|------|
| 产物门 | 代码/Schema/测试产物齐全有版本 |
| 审查门 | 指定审查者给出结论 |
| 集成门 | 完整流程通过+Task Owner确认 |

---

## Run Gate（UI变更必须）

凡改动UI的任务，必须通过：

| 三件套 | 证据 |
|--------|------|
| 自动化UI测试 | 测试命令+通过日志 |
| E2E测试 | `npx playwright test`+通过日志 |
| 可视化验证 | 截图/录屏 |

**跑通判定**：
1. 干净环境能启动
2. 核心流程无中断
3. 无白屏/异常/死按钮
4. 数据真实流转

**禁止**：
- 只提交代码不运行
- 用单元测试代替跑通
- 跳过测试换绿色流水线

---

## 问题闭环

```markdown
问题编号：BUG-MOD-001
任务编号：MODULE-001
严重性：阻断/高/中/低
复现步骤：
1.
2.
实际结果：
期望结果：
证据：截图/日志
状态：open → fixing → verifying → closed
```

---

## 完成判定

同时满足：
- ✅ 交付物可定位到版本
- ✅ 所有验收条件有证据
- ✅ UI变更通过Run Gate
- ✅ 独立审查已完成
- ✅ 集成流程通过
- ✅ 高严重问题已关闭
- ✅ Task Owner批准关闭

---

## 检查清单

- [ ] 有唯一Task Owner和任务ID
- [ ] 有明确输入/输出/依赖/验收
- [ ] 交互契约已定义状态反馈
- [ ] Schema已版本化
- [ ] E2E覆盖核心场景
- [ ] UI变更三件套齐全
- [ ] 应用从干净环境启动成功
- [ ] 核心流程真实走通
- [ ] 测试结果已归档
- [ ] Task Owner最终验收

---

## 设计先行的代码质量原则

代码质量不能依靠编码 Agent 自己发挥，也不能等代码写完后才靠测试补救。必须先由架构师、产品/交互设计师和领域专家定义正确的方案，再让编码 Agent 按照已批准的设计实现。

任何 Agent 都不得以“代码看起来合理”替代经过设计评审的方案、可复现的测试证据和真实流程验证。

### 设计先行流程

```text
需求澄清
  → 产品/交互设计
  → 技术架构设计
  → Schema/API/状态契约
  → 设计评审
  → 编码 Agent 实现
  → 自动化测试
  → 独立代码评审
  → E2E/集成/可视化验证
```

设计评审未通过时，编码 Agent 不得开始实现。实现过程中如果需求、Schema、交互状态或模块边界发生变化，必须回到设计评审阶段，不能由编码 Agent 私自决定。

### 强制规则

1. **契约先于实现**：没有任务契约、接口契约、状态定义和验收条件，不得开始编码。
2. **范围先于速度**：任务必须声明允许修改的文件和禁止修改的区域。
3. **小步提交**：每个 checkpoint 只实现一个逻辑单元，不能把多个未验证功能混在一起。
4. **失败即阻塞**：测试、构建、启动、E2E 或视觉验证失败时，禁止进入下一个 checkpoint。
5. **实现者不能批准自己**：编码 Agent 可以解释实现，但不能批准自己的代码和测试。
6. **测试不能被削弱**：禁止为了通过测试删除断言、放宽条件、跳过用例或修改既有测试预期。
7. **证据必须可复现**：测试命令、环境、输入数据、日志和截图必须能够被其他 Agent 重新执行。
8. **变更必须可追溯**：每个问题、修复和验证都必须关联 task_id、checkpoint_id 和产物版本。
9. **不确定就阻塞**：需求冲突、契约缺失、基线失败或测试环境不可用时，状态必须为 `blocked`。

### 质量责任分离

| 阶段 | 负责 Agent | 主要职责 | 通过条件 |
|------|------------|----------|----------|
| 需求澄清 | Task Owner / 领域专家 | 明确用户目标、业务规则和完成条件 | 需求无歧义 |
| 交互设计 | 产品/交互设计师 | 定义页面、操作、状态和反馈 | 交互契约通过 |
| 技术设计 | 架构师 | 定义模块、Schema、API、数据流和边界 | 架构契约通过 |
| 实现 | 编码 Agent | 按批准的设计实现 | 代码和局部测试通过 |
| 整洁检查 | Clean Code Reviewer | 检查命名、结构、复杂度、重复和注释 | 整洁检查报告通过 |
| 自动化测试 | 测试 Agent | 验证行为、边界和回归 | 测试证据完整 |
| 独立评审 | Reviewer | 检查设计遵循、实现质量和风险 | 评审结论明确 |
| 真实验证 | 独立验证者 | 操作完整用户流程 | 集成和视觉验证通过 |

设计师、架构师、编码者和验证者不能由同一个 Agent 单独完成并批准全部工作。

### 禁止行为

- 未经批准的跨模块重构
- 无需求依据的依赖升级或配置修改
- 用假数据、硬编码返回值或静默降级掩盖真实错误
- 只修改实现、不补充回归测试
- 只运行单元测试就声称完整流程通过
- 只生成截图、不执行真实浏览器操作
- 删除失败测试、屏蔽日志或忽略控制台错误
- 将未验证的“应该可以”写成验收结论

---

## 任务类型路由

Task Orchestrator 必须先判断任务属于后端、前端或全栈，再选择 Agent 和质量门。不同类型不得共用一套最低验收标准。

```yaml
work_type: backend | frontend | fullstack
allowed_files:
  - src/xxx.ts
forbidden_changes:
  - 不得修改公共接口
  - 不得升级依赖
checkpoint_policy:
  max_files: 5
  one_behavior_per_checkpoint: true
required_agents: []
quality_gates: []
```

### 设计评审产物

每个任务在进入 `in_progress` 前必须至少提交：

```yaml
design_review:
  user_goal: 用户要完成什么
  acceptance_scenarios:
    - 正常流程
    - 失败流程
    - 重试流程
  domain_rules:
    - 业务规则1
  architecture_decisions:
    - 决策及原因
  contracts:
    - schema@1.0.0
    - api@v1
  state_model: docs/state.md
  testability_hooks:
    - data-testid 或 API fixture
  rejected_alternatives:
    - 被拒绝方案及原因
  approved_by:
    - task_owner
    - architect
    - designer
```

设计评审必须回答：

- 这个设计是否真正解决用户目标，而不是只增加代码
- 模块边界是否清晰，依赖方向是否可解释
- 正常、异常、空数据、权限和重试状态是否完整
- 数据、接口和状态是否能被测试观察
- 方案是否与现有架构和设计系统一致
- 是否明确了不做的内容和潜在风险

### 后端任务角色

```yaml
required_agents:
  - backend_architect
  - backend_implementer
  - backend_test
  - clean_code_reviewer
  - independent_reviewer
quality_gates:
  - schema_validation
  - typecheck_and_lint
  - unit_test
  - integration_test
  - api_contract_test
  - clean_code_review
```

### 前端任务角色

```yaml
required_agents:
  - interaction_architect
  - frontend_implementer
  - component_test
  - e2e_test
  - visual_verifier
  - clean_code_reviewer
  - independent_reviewer
quality_gates:
  - typecheck_and_lint
  - component_test
  - e2e_test
  - visual_verification
  - clean_code_review
```

### 全栈任务角色

全栈任务必须先完成并冻结后端接口契约，再进行前端实现。前端可以使用固定 fixture 并行开发，但接入真实 API 前必须通过接口契约测试和集成测试。

```text
接口/Schema契约
  → 后端实现与测试
  → 前端交互契约与测试抓手
  → 前端实现
  → E2E真实流程
  → 集成验收
```

---

## 架构设计阶段的强制产物

架构 Agent 不得只提供目录结构或泛泛的技术建议，必须提供可以被编码和测试 Agent 直接执行的设计产物。

### 通用架构产物

- 模块边界和依赖方向
- 输入、输出、错误和副作用
- 数据模型与版本号
- 状态转换图
- 不变量和边界条件
- 权限、超时、重试和幂等策略
- 日志、指标和错误可观测性
- 可测试性设计
- 不在本任务范围内的内容

### 后端架构要求

后端架构必须明确：

- API 路径、方法、请求和响应 Schema
- 成功、校验失败、未授权、资源不存在和服务异常的状态码
- 数据库事务边界和并发处理方式
- 重试是否安全，接口是否幂等
- 外部服务超时、降级和恢复策略
- 时间、随机数、ID 和文件系统等外部依赖如何注入
- 测试数据库、fixture 和数据清理方式
- 关键日志字段和敏感信息脱敏规则

```yaml
api_contract:
  version: v1
  endpoint: POST /api/answers
  request_schema: AnswerSubmit@1.0.0
  response_schema: AnswerResult@1.0.0
  errors:
    - code: INVALID_INPUT
      status: 400
    - code: NOT_FOUND
      status: 404
    - code: INTERNAL_ERROR
      status: 500
  idempotency: required
```

### 前端架构要求

前端架构必须明确：

- 页面、路由和组件边界
- 初始、加载、成功、空数据、失败和重试状态
- 状态由谁拥有，状态如何流动
- API 请求取消、重复提交和竞态处理
- 表单校验和错误展示
- 键盘、屏幕阅读器和焦点行为
- 真实用户可操作的测试抓手
- 测试数据重置、网络拦截和时间控制方式

```text
页面状态：initial → loading → success
                     ├→ empty
                     └→ error → retrying → loading
```

---

## 前端测试抓手设计

测试抓手必须在架构阶段设计，在实现阶段按契约交付。抓手应表达真实业务状态，不能为了测试创建假的业务分支。

### 元素定位

优先级如下：

1. 用户可感知的 `role` 和可访问名称
2. 稳定的可见文本
3. 语义明确的 `data-testid`
4. CSS 类名、DOM 层级和自动生成属性只能作为最后手段

```tsx
<article
  data-testid={`question-card-${question.id}`}
  data-state={state}
  data-question-id={question.id}
>
  <button
    data-testid="submit-answer"
    aria-label="提交答案"
    disabled={state !== 'ready'}
  >
    提交
  </button>
</article>
```

### 必须可观察的状态

- `data-state="initial|loading|success|error|empty"`
- 按钮的启用、禁用和加载状态
- 错误提示及其稳定标识
- 完成页或下一步的稳定标识
- 关键请求的成功、失败和重试结果

### 前端测试环境能力

- 固定测试账号和权限
- 可重置数据库或浏览器状态
- 可注入固定 fixture
- 可拦截成功、失败、超时和空数据响应
- 可控制时间、随机数和动画
- 可收集控制台错误、网络错误和页面异常
- 可从干净环境启动开发或测试服务器

---

## 增量实现、测试和评审循环

每个逻辑单元都必须独立经过以下循环：

```text
in_progress
  → checkpoint_submitted
  → automated_test
  → ready_for_review
  → review_accepted
  → in_progress
```

失败时：

```text
automated_test / ready_for_review
  → changes_requested
  → in_progress
  → 重新测试和评审
```

### Checkpoint 提交模板

```yaml
task_id: MODULE-001
checkpoint_id: MODULE-001-C02
purpose: 完成正确答案提交流程
changed_files:
  - src/components/AnswerCard.tsx
  - tests/answer-card.spec.tsx
out_of_scope:
  - 不修改路由
  - 不修改公共 API
tests:
  - npm run test -- answer-card
test_result: passed
runtime_evidence:
  - artifacts/checkpoint-C02.png
  - artifacts/checkpoint-C02.log
review_status: ready_for_review
```

### 评审 Agent 必须回答

- 实现是否满足任务契约
- 是否修改了允许范围之外的文件
- 是否引入无关重构
- 是否覆盖正常、异常和边界路径
- 测试是否验证行为而不是只验证实现细节
- 是否存在硬编码、假数据或静默失败
- 是否需要新增回归测试
- 是否可以复现测试结果

---

## 代码整洁之道和注释规范

代码功能通过后，必须由 `clean_code_reviewer` 执行一次独立的代码整洁检查。该检查关注可读性、可维护性和长期变更成本，不能只依赖格式化工具。

### 代码整洁检查项

- 命名表达业务含义，避免 `data`、`temp`、`handleThing` 等无意义名称
- 函数和组件只承担一个清晰职责
- 控制流不过深，复杂条件被拆成有名称的判断
- 重复逻辑被合理复用，但不为了消除少量重复而制造过度抽象
- 模块依赖方向清晰，没有循环依赖和跨层调用
- 错误处理明确，不吞异常、不返回假成功
- 输入校验和副作用边界清楚
- 公共接口、状态和数据模型保持一致
- 删除死代码、注释掉的旧代码和无效配置
- 没有无依据的魔法数字、硬编码路径和环境相关假设
- 格式化、lint、类型检查和构建结果干净
- 复杂度、函数长度和文件规模超过约定时有拆分理由

### 注释原则

代码首先应通过清晰的命名和结构表达“做什么”。注释主要解释代码本身无法直接表达的原因、约束和业务背景。

#### 必须写注释的场景

- 公共 API、导出函数、组件和复杂类型的参数、返回值、异常和使用限制
- 复杂算法、状态机、并发控制、缓存策略和事务边界
- 违反直觉但必须保留的实现，以及兼容性处理
- 外部系统、协议、法规或业务规则导致的特殊逻辑
- 临时方案、已知限制和后续处理计划

#### 注释写法要求

- 说明“为什么这样做”，不要重复“代码正在做什么”
- 注释必须和代码放在足够近的位置
- 说明业务规则时给出规则来源或契约版本
- `TODO`、`FIXME` 必须说明原因、后续动作和关联任务编号
- 注释中的示例、字段名和状态名必须与实际代码一致
- 修改逻辑时同步检查相关注释，禁止保留过时结论
- 禁止使用大段注释掩盖过长函数或不清晰设计
- 禁止保留整段被注释掉的旧代码，旧版本应由版本控制保存

```typescript
// 不能这样写：把答案提交给服务端。
await submitAnswer(answer);

// 正确：服务端要求幂等键，避免用户重复点击造成重复记录。
await submitAnswer(answer, { idempotencyKey: attemptId });
```

### 代码整洁检查报告

```yaml
checkpoint_id: MODULE-001-C02
reviewer: clean_code_reviewer
formatting: passed
lint: passed
typecheck: passed
complexity: acceptable
naming: acceptable
duplication: acceptable
error_handling: verified
comments:
  public_api_docs: complete
  complex_logic_explained: complete
  stale_comments: none
blocking_findings: []
status: accepted
```

发现结构性问题时，不能只补注释掩盖问题。应优先重命名、拆分函数、调整模块边界或补充设计说明，再重新执行测试和评审。

### 完成顺序

```text
编码完成
  → 格式化、lint、类型检查
  → 代码整洁检查
  → 自动化测试
  → 独立代码评审
  → 集成/E2E/可视化验证
```

---

## 后端自动化测试规范

后端测试 Agent 必须按层次执行，不能只运行单元测试。

| 层级 | 必测内容 | 证据 |
|------|----------|------|
| Schema | 合法、非法、缺失、边界数据 | 校验日志 |
| 单元 | 核心函数、分支、异常 | 测试报告 |
| 集成 | 数据库、队列、外部服务边界 | 集成日志 |
| 契约 | 请求、响应、状态码和错误码 | API报告 |
| 回归 | 受影响模块的已有行为 | 完整测试日志 |
| 安全 | 权限、越权、敏感数据 | 安全检查记录 |

后端测试必须覆盖：

- 空值、类型错误、边界数值和超长输入
- 重复请求、并发请求和重复提交
- 依赖超时、失败和部分成功
- 事务回滚和数据一致性
- 未认证、无权限和资源不存在
- 错误响应不能泄露敏感信息

---

## 前端组件、E2E和可视化测试规范

### 组件测试

组件测试验证状态和行为，包括：

- 初始状态
- 用户输入和点击
- 加载状态
- 成功状态
- 空数据状态
- 错误和重试
- 禁止重复提交
- 键盘和可访问性基本行为

### E2E 测试

E2E 必须执行真实浏览器操作，禁止只调用组件函数或直接修改内部状态。

每个核心流程至少覆盖：

1. 从真实入口打开页面
2. 用户点击、输入或选择
3. 验证界面状态发生变化
4. 验证请求和数据结果
5. 验证成功、失败和重试分支
6. 验证最终页面或下一步结果

```typescript
await page.goto('/practice');
await page.getByTestId('question-card-q1').click();
await page.getByRole('button', { name: '提交答案' }).click();
await expect(page.getByTestId('answer-result')).toHaveAttribute('data-state', 'success');
await expect(page.getByTestId('next-question')).toBeVisible();
```

### 可视化验证

UI 变更必须在至少一个桌面和一个移动视口执行截图或录屏验证。验证内容包括：

- 页面非白屏，主要内容真实出现
- 文字不溢出、不截断、不遮挡
- 按钮、输入框和错误提示可见且可操作
- 加载、成功、失败和空数据状态布局正常
- 弹窗、下拉框和键盘焦点没有脱离视口
- 不同视口没有重叠、横向滚动或布局塌陷
- 颜色、间距和层级没有破坏既有设计规范

动态时间、随机 ID 和光标等区域只能在记录原因后进行遮罩，不能用大面积遮罩掩盖布局问题。

### 前端 Run Gate

```text
类型检查和构建通过
  + 组件测试通过
  + Playwright E2E通过
  + 桌面截图验证通过
  + 移动截图验证通过
  + 控制台和网络无未解释错误
  = 前端 checkpoint 可以进入评审
```

---

## 测试证据和可复现性

每次测试必须记录：

- 执行 Agent 和时间
- 代码版本或 commit
- 操作系统、运行时和浏览器版本
- 启动命令和测试命令
- 测试数据或 fixture 版本
- 完整通过或失败日志
- 截图、视频和 trace 文件路径
- 失败时的复现步骤

测试报告不能只写“通过”，必须包含命令和结果摘要。

---

## 缺陷闭环和回归要求

每个缺陷都必须关联发现它的测试或验证步骤。

```markdown
问题编号：BUG-MOD-001
任务编号：MODULE-001
发现于：MODULE-001-C02
严重性：阻断/高/中/低
环境：浏览器、运行时、数据版本
复现步骤：
1.
2.
实际结果：
期望结果：
证据：日志/截图/视频/trace
根因：
修复文件：
回归测试：
状态：open → fixing → verifying → closed
```

缺陷关闭必须满足：

- 根因已解释，不接受只改表面现象
- 增加了能复现问题的回归测试
- 原失败用例通过
- 受影响模块回归测试通过
- 前端问题重新执行浏览器和可视化验证
- 独立验证者确认修复结果

---

## 容易遗漏的质量维度

代码整洁和测试通过仍然不能证明系统设计正确。以下内容必须根据任务风险选择，但涉及公共接口、用户数据、支付、权限、学习进度或持久化数据时不得省略。

### 需求和领域建模

设计开始前必须明确：

- 用户、系统和外部服务分别负责什么
- 领域对象、状态和状态转换的合法范围
- 业务不变量，例如“已完成的学习记录不能被重复计入”
- 权限边界和数据所有权
- 正常流程、异常流程、取消流程和重试流程
- 明确不支持的场景
- 验收示例和反例

每个重要规则至少有一个正例和一个反例，避免 Agent 根据自然语言自行补全业务含义。

```yaml
domain_rule:
  id: LEARNING-003
  statement: 同一练习尝试只能提交一次有效结果
  valid_examples:
    - 第一次提交成功，第二次返回重复提交
  invalid_examples:
    - 重复请求增加两条学习记录
  verification:
    - integration_test
    - e2e_duplicate_submit
```

### 架构决策记录（ADR）

重要技术选择必须记录决策、备选方案和代价，不能只留下最终代码。

```markdown
# ADR-001: 学习记录采用幂等提交

状态：accepted
背景：移动网络重试可能重复发送提交请求
决策：使用 attempt_id 作为幂等键
备选方案：客户端禁用按钮、消息队列去重
原因：服务端必须保证一致性，客户端限制不足以覆盖重试
影响：数据库增加唯一约束，接口返回重复提交状态
验证：API 契约测试、并发集成测试、E2E 重复点击测试
```

没有 ADR 的重大架构变化不得直接合入主分支。

### 安全和隐私

涉及账号、学习记录、文件或第三方服务时，架构 Agent 必须执行最小化威胁建模：

- 身份认证和授权是否分离
- 普通用户是否能访问其他用户数据
- 输入是否经过服务端校验
- 日志、截图和测试 fixture 是否泄露敏感信息
- 密钥、令牌和个人数据是否进入代码或仓库
- 文件上传、导出和外部链接是否有类型及权限限制
- 错误消息是否暴露内部实现和数据库信息
- 测试账号和生产账号是否完全隔离

安全问题不能以“后续再处理”关闭；高风险项必须阻塞发布。

### 性能和资源预算

架构设计必须给出可测量的性能目标，而不是只写“性能良好”。

```yaml
performance_budget:
  api_p95_ms: 300
  initial_page_load_ms: 2500
  largest_contentful_paint_ms: 2500
  max_bundle_size_kb: 500
  database_query_count_per_request: 10
```

超过预算时，必须记录原因、影响和后续计划。性能测试应覆盖典型数据量和接近上限的数据量。

### 可靠性和恢复

对外部服务、数据库、队列和文件系统必须定义：

- 超时、重试和退避策略
- 重试是否会造成重复副作用
- 部分失败时的状态
- 服务重启后的恢复行为
- 数据备份、恢复和清理方式
- 降级是否会产生错误数据
- 失败是否可观测和可告警

### 可观测性

每个关键用户流程和后端请求都应有可关联的观测信息：

- 请求或操作 ID
- 业务事件和状态变化
- 失败原因和错误码
- 延迟、重试次数和外部依赖结果
- 不包含敏感数据的结构化日志

测试 Agent 必须验证关键失败能够在日志中定位，而不是只验证页面显示错误。

### 兼容性和数据迁移

修改 Schema、API 或持久化结构时必须明确：

- 旧客户端是否仍可工作
- 新旧字段的兼容时间
- 迁移是否可重复执行
- 迁移失败如何回滚
- 数据是否需要回填和校验
- 发布顺序是先服务端还是先客户端

破坏性变更必须升版本，并提供迁移和回滚证据。

### 可访问性和国际化

前端任务除视觉验证外，还必须考虑：

- 键盘是否能完成核心操作
- 焦点是否可见且顺序合理
- 表单和错误提示是否有可访问名称
- 颜色是否不是唯一的信息表达方式
- 文本变长后是否仍能布局正常
- 日期、数字、复数和语言切换是否正确

## 测试质量增强

### 测试设计而不是测试数量

测试 Agent 必须给出需求到测试的映射，避免堆积大量低价值断言。

```yaml
traceability:
  - requirement: LEARNING-003
    scenarios:
      - tests/api/duplicate-submit.spec.ts
      - tests/e2e/duplicate-submit.spec.ts
    negative_cases:
      - repeated_request
      - concurrent_request
```

覆盖率只能作为参考，不能替代行为覆盖、边界覆盖和风险覆盖。

### 契约测试

生产者和消费者必须共享版本化契约。后端不能只验证自己的实现，前端也不能只用 mock 验证自己的组件。接口变化必须同时执行：

- Schema 校验
- 提供方测试
- 消费方测试
- 兼容性测试
- 真实集成测试

### 属性和边界测试

金额、分数、排序、分页、文本解析、日期和区间计算等规则适合增加属性测试或生成式边界测试。测试 Agent 应覆盖空集合、单元素、极值、重复值、非法顺序和超长输入。

### Flaky Test 管理

不稳定测试不能用无限重试掩盖。每次重试必须记录：

- 首次失败日志
- 重试次数
- 是否与时间、网络或共享状态有关
- 缺陷编号和修复计划

同一测试连续不稳定时，应标记为 `quarantined`，但任务不能因此声称通过。

### 测试隔离和清理

测试必须能独立运行、重复运行和任意顺序运行。禁止依赖上一个测试留下的数据、浏览器状态或服务进程。测试结束后必须清理临时文件、数据库记录和后台进程。

## 发布、回滚和运行验证

完成开发不等于可以发布。发布前必须经过：

```text
干净构建
  → 测试环境部署
  → 数据迁移演练
  → 核心流程冒烟测试
  → 监控和日志确认
  → 分阶段发布
  → 发布后验证
```

每个有数据或接口影响的任务必须提供：

- 发布步骤
- 配置和环境变量清单
- 数据迁移步骤
- 回滚步骤
- 回滚后的数据一致性检查
- 发布后观察指标
- 失败时的负责人和停止条件

没有可执行回滚方案的高风险变更不能进入发布阶段。

## AI专属协作约束

为了让编码 Agent 真正按照架构实现，Task Orchestrator 必须向它提供完整的上下文包：

- 已批准的需求和验收场景
- 架构图和 ADR
- Schema/API/交互契约
- 允许修改的模块
- 现有代码的相关入口和依赖
- 测试命令、fixture 和运行方式
- 已知风险和禁止假设

编码 Agent 必须在开始前复述：

1. 它理解的目标和不变量
2. 将修改的文件和原因
3. 不会修改的范围
4. 准备增加的测试
5. 尚未确定的问题

如果复述与设计契约不一致，必须退回设计评审。Agent 不得自行发明接口、业务规则、状态或数据字段。

## 质量度量

Task Owner 应持续记录以下指标，用于判断流程是否真的改善质量：

- 设计评审发现的问题数量
- 每个 checkpoint 的返工次数
- 缺陷逃逸到集成或发布阶段的数量
- 高严重性缺陷的平均关闭时间
- 测试不稳定率
- E2E 和视觉验证失败率
- 代码评审发现的设计问题与实现问题比例
- 发布后回滚次数

不能只用代码行数、测试数量或覆盖率评价 Agent 产出。

---

## 质量门和停止条件

### 后端完成条件

- Schema 和 API 契约版本明确
- 类型检查和 lint 通过
- 单元、集成和契约测试通过
- 异常、权限和边界场景有测试
- 测试在干净环境可复现
- 独立评审通过

### 前端完成条件

- 交互状态和测试抓手完整
- 类型检查、构建和组件测试通过
- 核心用户流程通过 E2E
- 桌面和移动视口通过截图验证
- 无未解释的控制台和网络错误
- 独立评审和真实用户流程验证通过

### 必须停止的情况

- 需求、Schema 或交互状态存在冲突
- 基线测试失败但原因不明
- 测试数据无法重置
- 页面无法从干净环境启动
- E2E 依赖不稳定且没有替代方案
- 视觉差异无法解释
- Agent 提议扩大范围但没有新的任务契约

---

*版本历史*

| 版本 | 日期 | 修改 |
|------|------|------|
| 1.0.0 | 2026-10-06 | 初始版本 |
| 2.0.0 | 2026-10-06 | 重构协作协议 |
| 3.0.0 | 2026-10-06 | 精简重构，删除冗余 |
| 3.1.0 | 2026-10-06 | 增加架构设计、增量评审、后端测试、前端E2E和可视化验证规范 |
| 3.2.0 | 2026-10-06 | 强化设计先行、架构师/设计师职责和设计评审门 |
| 3.3.0 | 2026-10-06 | 增加代码整洁检查、注释规范和Clean Code评审代理 |
| 3.4.0 | 2026-10-06 | 增加领域建模、安全、性能、可靠性、可观测性、兼容性、发布回滚和AI协作约束 |
| 4.0.0 | 2026-10-06 | 拆分为执行协议、架构规范、测试与代码质量规范，并增加机器质量门入口 |
| 4.1.0 | 2026-10-07 | 增加规范加载、Agent 运行时、feature_team 和测试执行启动硬门，禁止工具失败后由主 Agent 接管 |
| 4.2.0 | 2026-10-07 | 增加每个 checkpoint 的 TDD Red-Green-Refactor 门和违规现场保留规则 |
