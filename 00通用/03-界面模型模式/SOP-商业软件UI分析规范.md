# 商业软件 UI 分析 SOP（深度版）

> 让 AI 能够**深度拆解**任意商业软件的界面设计，解释"为什么这样设计"、"这样设计的优点和缺点"、"在什么条件下会失效"，并在发现问题时生成改进后的 HTML 展示。
>
> **知识库**：`D:\mywork\techdoc\00通用\界面模型模式\` 目录
>
> **证据约束（最高优先级）**：本 SOP 中的模式框架用于提出问题方向，不自动构成产品事实。任何角色、频率、时间压力、问题严重度、评分、收益、业务规则和改版内容都必须绑定证据；证据不足时必须标注为"（推断）"或"（未知）"，不得用"典型 SaaS"经验补全未经证实的结论。

---

## 0. 核心分析框架速查

### 0.1 状态四问（任何带状态的对象页必问）

| 问题 | 含义 | 如果页面没回答 |
|---|---|---|
| **是什么** | 当前状态是什么 | 用户无法判断对象当前情况 |
| **为什么** | 为什么是这个状态（来源、时间、前置条件） | 用户无法理解状态成因 |
| **接下来会怎样** | 等待什么、超时时间、下一步节点 | 用户不知道还能做什么 |
| **怎么办** | 用户能做什么（主操作、受控的次操作） | 用户找不到行动入口 |

### 0.2 信息三层优先级

| 层级 | 内容 | 典型位置 |
|---|---|---|
| **第一层** | 对象身份、主状态、核心数值、主操作 | 页面头部、操作列 |
| **第二层** | 状态来源、关联对象、历史变化 | 详情分区、关联列表、Timeline |
| **第三层** | 完整字段、技术细节、审计日志 | 折叠区、更多按钮、日志页 |

### 0.3 操作风险三层

| 层级 | 特征 | 控制要求 |
|---|---|---|
| **高风险**（不可逆、影响金额/库存/权限） | 取消、退款、删除、批量导入、改价 | 硬约束 + 影响预览 + 确认 + 审计 |
| **中风险**（影响状态流转） | 发货、审核通过/驳回、启用/停用 | 主操作突出 + 影响说明 + 状态及时更新 |
| **低风险**（局部影响） | 打印、复制、导出、备注 | 次操作收敛到更多菜单 |

### 0.4 Timeline 三层事件

| 事件类型 | 触发来源 | 必须记录 | 用户关注度 |
|---|---|---|---|
| **系统自动事件** | 支付回调、定时任务、同步 | 事件名、时间、结果 | 需要看到 |
| **人工操作事件** | 客服审核、运营修改 | 操作人、时间、前后值、原因 | 高风险或需交接时重点看到 |
| **业务状态事件** | 状态机流转 | 前状态 → 后状态、触发条件 | 核心关注 |

### 0.5 表单七问

| 问题 | 含义 | 如果没回答 |
|---|---|---|
| 用户来填什么 | 业务对象是什么，表单用途是什么 | 字段无法解释自身价值 |
| 需要填多少 | 字段数量和复杂度 | 用户被吓退或轻视 |
| 填的顺序是什么 | 字段分组和排序依据 | 用户无法判断从哪开始 |
| 哪些字段是必填 | 必填 vs 选填是否明确 | 用户反复提交失败 |
| 互斥字段怎么处理 | 选了 A 就不能填 B 的场景 | 用户填了但无效 |
| 填错了怎么办 | 校验时机和错误提示 | 用户不知道错在哪 |
| 填完会怎样 | 提交后的反馈和状态变化 | 用户不知道操作是否成功 |

### 0.6 Drill-down 四层结构

| 层级 | 内容 | 用户目标 |
|---|---|---|
| **第一层** | 汇总指标（大数字 + 趋势） | 看整体，判断是否有问题 |
| **第二层** | 按维度拆解（时间/类目/门店/人员） | 定位问题范围 |
| **第三层** | 明细记录（具体订单/流水/操作） | 找到具体对象 |
| **第四层** | 业务对象详情（订单详情/人员资料） | 采取行动 |

### 0.7 异常中心五要素

| 要素 | 含义 | 如果缺失 |
|---|---|---|
| **异常分类** | 按类型聚合（支付失败/库存不足/同步超时） | 大量零散告警 |
| **第一层** | 异常对象的身份信息 | 用户无法定位异常 |
| **提供处理动作** | 给出"重新发起"/"调整"/"忽略" | 只能看不能处理 |
| **处理过程留痕** | 谁处理了、什么时候、结果如何 | 处理完没有记录 |
| **重复异常聚合** | 同一接口大量失败聚合为一条 | 大量重复告警造成疲劳 |

### 0.8 AI 内置知识补充

以下内容来自 AI 内置知识，不在本地知识库目录中。分析时优先查本地知识库，如果本地没有覆盖，再调用本节内容。

#### 0.8.1 设计体系来源速查

| 体系 | 核心贡献 | 典型模式 |
|---|---|---|
| SAP Fiori | 企业级 ERP 页面范式最完整 | List Report、Object Page、Overview Page |
| Microsoft Fluent UI | 命令栏、Master-Detail | 操作区设计、数据密集表 |
| Salesforce Lightning | Record Page、Related Lists、Path | CRM 类页面参考 |
| Ant Design | ProTable、QueryForm、ProLayout | 国内中后台实现直接参考 |
| Nielsen Norman Group | 可用性原则、认知负荷 | 优缺点评价底层理论 |

#### 0.8.2 认知模式与决策类型

| 认知模式 | 用户特征 | 适合的 UI 策略 |
|---|---|---|
| **技能型**（下意识） | 熟练用户，高频操作 | 快捷键、批量操作、默认值 |
| **规则型**（条件反射） | 知道规则，按流程操作 | 向导、分步表单、状态引导 |
| **知识型**（主动思考） | 需要理解数据再做决策 | 指标解释、钻取、对比视图 |

#### 0.8.3 任务闭环度

| 闭环类型 | 特征 |
|---|---|
| **完整闭环** | 用户从头到尾在同一系统/页面完成 |
| **基本闭环** | 需要切换系统但有明确跳转入口 |
| **断裂闭环** | 异常在 A 系统，处理在 B 系统，无跳转 |

#### 0.8.4 设计合理性五级判断

| 等级 | 判断标准 |
|---|---|
| **合理** | 模式与任务匹配，信息分层清晰，操作风险分层合理 |
| **勉强合理** | 大方向正确，但有局部优化空间 |
| **不合理** | 模式选错或信息/操作分层混乱 |
| **过度设计** | 用了过于复杂的模型处理简单任务 |
| **设计不足** | 简单模型承载了过于复杂的任务 |

#### 0.8.5 错误处理规范

| 场景 | 好的设计 | 差的设计 |
|---|---|---|
| 表单校验 | 实时校验、字段级错误提示 | 提交后全量报错 |
| 操作失败 | 说明原因、提供重试和替代方案 | 只显示"操作失败" |
| 网络错误 | 自动重试、离线缓存、断点续传 | 无感知、丢失数据 |
| 状态冲突 | 显示冲突内容、提供合并或覆盖选项 | 直接覆盖无提示 |

### 0.9 证据体系（最高优先级，必须遵守）

#### 0.9.1 证据类型与编号规范

| ID 前缀 | 证据类型 | 可支撑的结论 | 示例 |
|---|---|---|---|
| `OBS-` | 可复现的实机操作观察 | 当前版本、当前环境中的界面和行为 | `OBS-007`：点击页面类型"单据"后只保留单据卡片 |
| `SCREEN-` | 带时间和页面路径的截图/描述 | 布局、视觉层级、可见状态 | `SCREEN-004`：领用申请新增态首屏 |
| `DOC-` | 官方文档、产品说明、帮助材料 | 官方声明的能力与规则 | `DOC-003`：字段布局面板官方说明 |
| `INTERVIEW-` | 有对象与日期的访谈记录 | 角色、任务、痛点、认知与期望 | `INTERVIEW-002`：仓管访谈 2026-07-01 |
| `LOG-` | 使用日志、埋点、性能或错误数据 | 频率、耗时、成功率、规模和损失 | `LOG-005`：最近 30 天筛选操作分布 |
| `TEST-` | 可复现实验、可用性测试、A/B 测试 | 效率、错误率、理解率和方案效果 | `TEST-003`：5 名目标用户任务测试 |
| `INFER-` | 从多个证据推出的推断 | 带推理链的暂定判断 | `INFER-006`：由 `OBS-` + `DOC-` 推断资产复用关系 |

每条证据必须记录：ID、日期、环境/版本、角色或账号类型、入口路径、操作步骤、观察结果、截图路径（如有）、局限性。

#### 0.9.2 确定性标签

全文只使用以下四个标签，禁止把低等级内容升级表述：

| 标签 | 含义 | 可用于 |
|---|---|---|
| `（直接事实）` | 可复现实机观察、日志、测试或官方文档直接支持 | 页面存在/字段可见/按钮可用/操作行为 |
| `（推断）` | 由多个证据推出，必须给出推理链 | 根因分析/影响链/模式合理性 |
| `（假设）` | 用于安排下一步验证，不得进入评分、严重度、优先级或改版业务规则 | 原因假设/待验证项 |
| `（未知）` | 当前证据无法回答 | 所有无法确认的字段 |

#### 0.9.3 禁止伪量化

没有 `LOG-`、`TEST-` 或明确样本方法时，禁止输出以下内容：

```
- 每天/每月操作次数、节省分钟或小时
- 成功率、错误率、转化率、效率提升百分比
- 用户规模、损失金额、影响人数
- 没有判据的星级、分数或精确优先级收益
```

证据不足时只能写：影响方向、待测指标、建议的验证方法。例如："预计减少重复点击；需通过任务测试测量完成时长与误触率"。

#### 0.9.4 结论门槛

| 结论类型 | 最低证据门槛 | 未满足时的处理 |
|---|---|---|
| 页面存在/字段可见/按钮可用 | 1 条 `OBS-` 或 `SCREEN-` | 标为"（未知）" |
| 角色、任务、频率、时间压力 | `INTERVIEW-`、`LOG-`、权限配置或官方角色文档 | 只能写"候选角色/待验证" |
| 根本原因 | 至少 2 条独立证据，或 1 条直接机制证据 | 降级为"（假设）" |
| 严重度 P0/P1 | 阻断复现、错误后果、日志规模或目标用户测试 | 只能写"风险信号"，不得排期 |
| 评分 | 有明确量表且每项绑定证据 | 不评分，只做描述性判断 |
| 量化收益 | 基线日志/测试 + 样本与计算方法 | 写待测指标，不写数字 |
| 系统级评价 | 满足 1.2 的覆盖门槛 | 自动降级为"抽样观察" |
| 改版业务规则 | 官方规则、现行配置或用户确认 | 只能用中性占位并标注"示意" |

---

## 1. 分析前置：建立上下文

### 1.1 必须确认的信息

```
【系统基本信息】
- 系统类型：ERP / CRM / WMS / POS / SaaS / ...
- 模块：订单 / 商品 / 库存 / 会员 / 财务 / ...
- 页面名称：
- 入口路径：

【用户与任务】
- 主要用户角色：有 INTERVIEW-/LOG-/DOC- 时填写；否则写“候选角色/待验证”
- 每个角色的主要任务：有任务证据时填写；否则写“（未知）”
- 任务频率：有 LOG-/INTERVIEW- 时按实际样本填写；否则写“（未知）”
- 时间压力：有 INTERVIEW-/LOG- 时填写；否则写“（未知）”

【分析粒度】
- 粒度：单页面 / 单流程 / 模块级 / 系统级
- 覆盖说明：（列出已观察的状态和未覆盖的缺口）
```

### 1.2 分析粒度与覆盖门槛

| 粒度 | 最低覆盖要求 | 允许的结论范围 |
|---|---|---|
| **单页面** | 主状态 + 至少 1 个异常/空/权限状态；关键操作入口和结果 | 该页面当前已观察状态的结论 |
| **单流程** | 入口、主要步骤、成功出口、至少 1 个中断/失败路径 | 该流程闭环结论 |
| **模块级** | 关键角色、核心对象、列表/详情/表单/异常代表页面、至少 1 条端到端流程 | 模块级模式与一致性结论 |

未满足门槛时，结论标题必须降级为"抽样观察"。

---

## 2. 分析-改进四步流程

### 第一步：建立证据台账 + 观察记录

**目标**：将所有观察和推断分层记录，为后续结论提供依据。

#### 证据与确定性规范

本步骤直接使用 **0.9.1 的七类证据 ID** 和 **0.9.2 的四个确定性标签**，不得另建简化版本。角色、任务、频率与时间压力优先补充 `INTERVIEW-`、`LOG-` 或官方角色资料；效率和方案效果优先补充 `TEST-`。没有相应证据时写“（未知）”或“候选项/待验证”。

#### 观察记录模板

```text
【证据台账】

| ID | 类型 | 日期与环境 | 入口/步骤 | 观察内容 | 局限 |
|---|---|---|---|---|---|
| OBS-001 | 实机观察 | 版本/账号/日期 | 逐步记录 | 页面首次加载时表格默认按主键排序 | 未测试其他账号权限 |
| SCREEN-001 | 截图 | 版本/路径/日期 | - | 筛选区显示 12 个字段，无折叠 | 仅覆盖此分辨率 |
| INTERVIEW-001 | 访谈 | 对象/角色/日期 | 访谈提纲 | 目标角色描述的主要任务 | 单一样本，不代表全部角色 |
| LOG-001 | 使用日志 | 时间窗/样本范围 | 统计方法 | 排序切换或筛选使用分布 | 仅覆盖指定时间窗 |
| TEST-001 | 任务测试 | 版本/样本/日期 | 测试脚本 | 任务完成结果与错误 | 样本范围有限 |
| INFER-001 | 推断 | - | - | 由 OBS-/DOC-/INTERVIEW- 等证据推出 | 待独立验证 |
```

### 第二步：模式识别 + 设计要素拆解

**目标**：识别页面使用的经典模式，并从深层逻辑解释"为什么这样设计"。

#### 2.1 模式识别

对照知识库（00总览.md），判断页面属于哪种经典模式：

**强制交付要求**：每个已观察页面都必须进入“逐页 UI 模式与模式优点矩阵”。不得只在正文中零散提及，也不得因角色、日志或任务证据不足而省略。证据不足只影响合理性和效果判断：模式无法唯一识别时写“候选模式/待验证”；模式优点必须区分“结构性优点”和“已验证效果”。

**强制输出格式**：正式交付使用 HTML，不以 Markdown 作为主产物。HTML 中每个已观察页面必须同时包含：原始截图、同一原图的标注版、页面整体模式、各可见区域的中文 UI 模式名称、模式特点、模式优点、证据与边界。标注层只能覆盖原图实际可见区域，不得重绘或补造界面；无法识别的区域标“候选模式/待验证”。

```text
| 页面 | UI 模式 | 模式特征 | 这种模式的优点 | 证据 ID | 成立条件 / 边界 |
|---|---|---|---|---|---|
| [已观察页面] | [模式或候选模式] | [页面上可见的模式构成] | [结构性优点；有 TEST-/LOG- 才写效果] | [OBS-/SCREEN-] | [未知项与待验证条件] |
```

规则：

- 覆盖矩阵中的每个“已观察页面”必须在本矩阵中恰好有一行；组合模式写在同一行。
- “这种模式的优点”是必填项；至少说明它在信息组织、对象查找、操作聚合、流程引导或状态理解方面的结构性价值。
- 没有 `TEST-`、`LOG-` 或访谈证据时，不得把结构性优点写成“效率已提升、错误已减少、用户更容易”等已验证效果。
- 无法识别模式时不得留空，写“候选模式/待验证”，并说明缺少的页面状态或任务证据。

```
【识别模式】：List Report / Object Page / Worklist / Dashboard / Sectioned Form / Wizard / ...
【深层逻辑】：这个模式解决什么问题？
  → 该模式的核心价值是"查找业务对象并执行操作"（List Report）
  → 该模式的核心价值是"理解一个对象的完整上下文"（Object Page）
【边界条件】：这个模式在什么条件下不适用？
  → List Report 不适合：对象数量少、状态复杂需要解释的场景
  → Object Page 不适合：需要连续处理多个对象的场景（改用 Worklist）
```

#### 2.2 设计要素拆解

逐区域拆解：

```
【筛选区】→ 对应知识库的 筛选区规范
【表格区】→ 对应知识库的 表格设计规范
【操作区】→ 对应知识库的 操作分层规范
【详情区】→ 对应知识库的 Object Page 规范
```

每个区域按状态四问检查：

```
当前区域是否回答了：
  □ 是什么（对象/字段的身份和当前值）
  □ 为什么（状态的来源或成因）
  □ 接下来会怎样（下一步状态或等待条件）
  □ 怎么办（用户能做什么操作）
```

### 第三步：优缺点分析 + 反模式检查

**目标**：给出有依据的优缺点评价，识别反模式。

#### 3.1 优点分析

```text
【优点1】：XXX
  深层原因：（推断）这个设计解决了什么问题？
  成立条件：（假设）在什么条件下成立？
  证据：OBS-XXX / SCREEN-XXX
  边界条件：（假设）⚠️ 在什么条件下会失效？
```

#### 3.2 缺点分析

```text
【缺点1】：XXX
  证据：OBS-XXX
  影响链：这个问题 → 导致后果 A → 导致后果 B
  严重度：满足 4.1 后写高 / 中 / 低；否则写“待定/风险信号”
  原因：（推断 / 假设）为什么会出现这个问题？
```

#### 3.3 反模式检查

对照以下清单，检查是否存在反模式：

| 反模式 | 典型表现 | 严重度 |
|---|---|---|
| **一张表一个页面** | 字段按数据库结构排列，用户任务不清 | 严重 |
| **首页堆图表** | 图表多但没有行动入口，指标无法钻取 | 严重 |
| **巨型表单** | 40+ 字段无分组，互斥字段同时显示 | 严重 |
| **详情页没有历史** | 只有当前状态，没有 Timeline 或日志 | 中等 |
| **报表不能钻取** | Dashboard 数字只能看，无法进入明细 | 中等 |
| **异常只在日志** | 技术异常业务人员看不到，无法闭环 | 阻断 |
| **状态同一组按钮** | 所有状态显示相同操作，后端才拒绝 | 中等 |
| **巨型下拉** | 50+ 选项无搜索，只能滚动 | 中等 |
| **隐藏字段仍校验** | 切换模式后隐藏字段仍报必填 | 中等 |
| **表格按钮过多** | 每行超过 3 个操作按钮，高低风险混在一起 | 中等 |

发现反模式时：

```text
【反模式】：XXX
【位置】：XXX
【表现】：OBS-XXX / SCREEN-XXX
【深层根源】：（推断）为什么会出现这个反模式？
【影响链】：XXX → 后果 A → 后果 B
```

### 第四步：改进方案 + HTML 生成

**目标**：给出改进建议，并在发现问题时生成改进后的 HTML 展示。

#### 4.1 改进优先级判定

| 优先级 | 判断标准 | 含义 |
|---|---|---|
| **高** | 核心任务阻断已复现，或错误后果已复现并有 `LOG-`/`TEST-`/多份 `INTERVIEW-` 证明影响显著 | 进入优先排期评估 |
| **中** | 问题已复现，且有任务证据证明会造成稳定的理解、效率或恢复成本，但不阻断核心任务 | 进入近期排期评估 |
| **低** | 问题已复现，任务影响有证据但范围和代价较低 | 进入后续排期评估 |
| **待定/风险信号** | 只有界面观察、截图、推断或假设，尚无任务影响与后果证据 | 先验证，不得排期 |

#### 4.2 改进建议模板

```text
【优先级待定 / 风险信号】XXX 问题
  问题事实：OBS-XXX / SCREEN-XXX
  现状：（直接事实）当前设计是什么
  影响：（未知）尚无 LOG-/TEST-/INTERVIEW- 证明
  建议方向：（推断）可验证的 UI 方向，不写未知业务规则
  业务规则：使用 DOC-/配置/用户确认；缺失时用中性占位并标“示意”
  验证方式：需要补充的 LOG-/TEST-/INTERVIEW-
  实现成本：（未知）取得技术评估前不定级
```

#### 4.3 改进方案生成规则

- **每个被判定为“高”或“中”的问题必须满足 0.9.4 和 4.1 的证据门槛，并有对应改进方案**
- **不能转化为 HTML 元素的问题仍可形成流程、权限、内容或验证建议，不得为了生成 HTML 改写问题性质**
- **改进方案不能超出当前分析的粒度**（单页面分析不给模块级改进建议）

---

## 3. HTML 设计展示生成规范

### 3.1 生成前提

**HTML 是改进建议的载体，不是分析报告的必然附件。** 只有当改进建议本身有足够证据支撑时，才能生成 HTML。

#### 生成前提条件（必须同时满足）

```
□ 改进建议至少有 1 个"（推断）"级以上结论
□ 改进方案能映射到具体 UI 元素（字段/分组/操作/布局）
□ 改进方案的业务上下文可从证据台账推导
□ 分析粒度与改进方案范围匹配（单页面分析不给模块级改进建议）
□ 当前版的关键元素可追溯到 SCREEN-/OBS-，不使用重绘界面冒充实机事实
□ 改进版不含未经 DOC-/配置/用户确认支持的业务规则；未知内容使用中性占位并标注“概念方案/示意”
```

#### 生成决策

| 条件 | 是否生成 HTML | 说明 |
|---|---|---|
| 推断级改进建议满足全部生成前提 | 可生成 improved.html | 标注“概念方案”，只展示有证据边界的 UI 方向 |
| 反模式和改进方向均有证据，且满足全部生成前提 | 可生成 comparison.html | 当前版须来自可追溯截图/观察；改进版标注“概念方案” |
| 改进建议仅有"（假设）"级 | **不生成 HTML** | 改进方向未经验证，生成 HTML 会传播不可靠结论 |
| 只有直接事实级发现，无推断级改进 | **不生成 HTML** | 发现问题但尚无改进方案，改用文字描述改进方向 |
| 分析仅基于截图，无任何推断级结论 | **不生成 HTML** | 只能描述观察结果，不足以生成改进方案 |

#### 不生成 HTML 时的替代输出

```markdown
## HTML 生成结论

**结论**：本次分析不生成 HTML 展示。

**原因**：（推断/假设）...
**后续验证建议**：
  - [ ] 验证方式 1
  - [ ] 验证方式 2
**何时可生成**：当验证完成后，按以下路径生成...
```

### 3.2 文件结构规范

```
cases/[章节名]/[序号]-[页面名]-[类型].html

类型：
  - improved.html       （改进后版本，分析结论的展示载体）
  - comparison.html     （当前 vs 改进并排对比）
  - annotated.html      （标注版，带分析说明）
```

### 3.3 HTML 页面结构

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[页面名] - 改进方案展示</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 1400px; margin: 0 auto; padding: 20px; }
    .report-header { background: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
    .verdict { font-size: 18px; font-weight: bold; color: #d32f2f; }
    .verdict.improved { color: #2e7d32; }
    .findings { margin-bottom: 20px; }
    .improvement-item { background: #e8f5e9; border-left: 4px solid #2e7d32; padding: 12px; margin-bottom: 12px; }
    .problem-area { border: 2px dashed #d32f2f; padding: 4px; position: relative; }
    .improved-area { border: 2px solid #2e7d32; padding: 4px; position: relative; }
    .annotation { background: #fff3cd; padding: 4px 8px; border-radius: 4px; font-size: 13px; margin-top: 4px; }
    .comparison-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .comparison-col { border: 1px solid #ddd; border-radius: 8px; padding: 16px; }
    .comparison-col.current { background: #fff5f5; }
    .comparison-col.improved { background: #f5fff5; }
    .col-label { font-weight: bold; margin-bottom: 12px; padding: 8px; border-radius: 4px; text-align: center; }
    .col-label.current { background: #d32f2f; color: white; }
    .col-label.improved { background: #2e7d32; color: white; }
  </style>
</head>
<body>
  <!-- 分析结论头注 -->
  <div class="report-header">
    <h1>[系统名] - [页面名] 改进方案展示</h1>
    <div class="verdict">分析结论：[合理 / 勉强合理 / 不合理 / 过度设计 / 设计不足]</div>
    <div>识别模式：[List Report / Object Page / ...]</div>
    <div>发现问题：X 个（已定级 X 个、待定/风险信号 X 个）</div>
    <div>生成日期：2026-XX-XX</div>
  </div>

  <!-- 核心发现 -->
  <div class="findings">
    <h2>核心发现</h2>
    <div class="improvement-item">
      <strong>【高】</strong> [问题描述]
      <div class="annotation">改进：XXX</div>
    </div>
    <div class="improvement-item">
      <strong>【中】</strong> [问题描述]
      <div class="annotation">改进：XXX</div>
    </div>
  </div>

  <!-- 界面展示区 -->
  <div class="ui-display">
    <h2>界面展示</h2>
    <!-- 具体 HTML 内容见下方模板 -->
  </div>

  <!-- 改进点编号列表 -->
  <div class="improvements">
    <h2>改进点说明</h2>
    <ol>
      <li><strong>改进点 1</strong>：[对应分析报告中的哪个缺点]</li>
      <li><strong>改进点 2</strong>：[对应分析报告中的哪个缺点]</li>
    </ol>
  </div>
</body>
</html>
```

### 3.4 典型模式 HTML 模板

#### List Report（列表页）模板

```html
<!-- 筛选区 -->
<div class="filter-bar" style="background:#f5f5f5;padding:16px;border-radius:8px;margin-bottom:16px;">
  <div style="display:flex;gap:12px;flex-wrap:wrap;">
    <div>
      <label style="font-size:13px;color:#666;">[字段A]</label><br>
      <select style="padding:6px 12px;border:1px solid #ddd;border-radius:4px;min-width:120px;">
        <option>全部</option>
        <option>[状态A]</option>
        <option>[状态B]</option>
        <option>[状态C]</option>
      </select>
    </div>
    <div>
      <label style="font-size:13px;color:#666;">[字段B]</label><br>
      <input type="date" style="padding:6px 12px;border:1px solid #ddd;border-radius:4px;">
    </div>
    <div>
      <label style="font-size:13px;color:#666;">[关键词]</label><br>
      <input type="text" placeholder="[搜索占位文本]" style="padding:6px 12px;border:1px solid #ddd;border-radius:4px;width:160px;">
    </div>
    <div style="align-self:flex-end;">
      <button style="padding:6px 16px;background:#1976d2;color:white;border:none;border-radius:4px;cursor:pointer;">[查询]</button>
    </div>
  </div>
</div>

<!-- 数据表格 -->
<div style="border:1px solid #ddd;border-radius:8px;overflow:hidden;">
  <table style="width:100%;border-collapse:collapse;font-size:14px;">
    <thead style="background:#fafafa;">
      <tr>
        <th style="padding:12px 8px;text-align:left;border-bottom:1px solid #eee;">[列A]</th>
        <th style="padding:12px 8px;text-align:left;border-bottom:1px solid #eee;">[列B]</th>
        <th style="padding:12px 8px;text-align:left;border-bottom:1px solid #eee;">[列C]</th>
        <th style="padding:12px 8px;text-align:left;border-bottom:1px solid #eee;">[列D]</th>
        <th style="padding:12px 8px;text-align:left;border-bottom:1px solid #eee;">[列E]</th>
        <th style="padding:12px 8px;text-align:center;border-bottom:1px solid #eee;">操作</th>
      </tr>
    </thead>
    <tbody>
      <tr style="border-bottom:1px solid #f0f0f0;">
        <td style="padding:10px 8px;">[数据A]</td>
        <td style="padding:10px 8px;">[数据B]</td>
        <td style="padding:10px 8px;">[数据C]</td>
        <td style="padding:10px 8px;"><span style="background:#e3f2fd;color:#1565c0;padding:2px 8px;border-radius:12px;font-size:12px;">[状态]</span></td>
        <td style="padding:10px 8px;">[时间]</td>
        <td style="padding:10px 8px;text-align:center;">
          <button style="padding:4px 12px;background:#4caf50;color:white;border:none;border-radius:4px;cursor:pointer;font-size:12px;">[主操作]</button>
          <button style="padding:4px 8px;background:none;border:1px solid #ddd;border-radius:4px;cursor:pointer;font-size:12px;margin-left:4px;">[次操作]</button>
        </td>
      </tr>
    </tbody>
  </table>
</div>

<!-- 分页 -->
<div style="display:flex;justify-content:space-between;align-items:center;margin-top:16px;font-size:13px;color:#666;">
  <span>共 [N] 条</span>
  <div style="display:flex;gap:4px;">
    <button style="padding:4px 10px;border:1px solid #ddd;background:white;border-radius:4px;cursor:pointer;">上一页</button>
    <button style="padding:4px 10px;border:1px solid #1976d2;background:#1976d2;color:white;border-radius:4px;cursor:pointer;">1</button>
    <button style="padding:4px 10px;border:1px solid #ddd;background:white;border-radius:4px;cursor:pointer;">2</button>
    <button style="padding:4px 10px;border:1px solid #ddd;background:white;border-radius:4px;cursor:pointer;">下一页</button>
  </div>
</div>
```

#### Object Page（详情页）模板

```html
<!-- 对象头部 -->
<div style="background:#fff;padding:24px;border:1px solid #e0e0e0;border-radius:8px;margin-bottom:16px;">
  <div style="display:flex;justify-content:space-between;align-items:flex-start;">
    <div>
      <h2 style="margin:0 0 8px 0;">[对象ID/编号]</h2>
      <span style="background:#e3f2fd;color:#1565c0;padding:4px 12px;border-radius:16px;font-size:13px;">[状态]</span>
    </div>
    <div style="display:flex;gap:8px;">
      <button style="padding:8px 20px;background:#4caf50;color:white;border:none;border-radius:6px;cursor:pointer;font-weight:500;">[主操作]</button>
      <button style="padding:8px 16px;background:white;color:#666;border:1px solid #ddd;border-radius:6px;cursor:pointer;">[次操作]</button>
    </div>
  </div>
  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-top:20px;">
    <div><div style="font-size:12px;color:#999;margin-bottom:4px;">[字段A标签]</div><div style="font-weight:500;">[字段A值]</div></div>
    <div><div style="font-size:12px;color:#999;margin-bottom:4px;">[字段B标签]</div><div style="font-weight:500;">[字段B值]</div></div>
    <div><div style="font-size:12px;color:#999;margin-bottom:4px;">[字段C标签]</div><div style="font-weight:500;">[字段C值]</div></div>
    <div><div style="font-size:12px;color:#999;margin-bottom:4px;">[字段D标签]</div><div style="font-weight:500;">[字段D值]</div></div>
  </div>
</div>

<!-- 状态说明 -->
<div style="background:#fff8e1;border-left:4px solid #ffc107;padding:12px 16px;margin-bottom:16px;border-radius:0 8px 8px 0;">
  <div style="font-weight:500;margin-bottom:4px;">⏳ [为什么是"当前状态"]？</div>
  <div style="font-size:14px;color:#555;">[状态来源说明]</div>
</div>

<!-- 分区内容 -->
<div style="display:grid;grid-template-columns:2fr 1fr;gap:16px;">
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <h3 style="margin:0 0 16px 0;font-size:15px;">[分区A标题]</h3>
    <!-- 分区A内容 -->
  </div>
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <h3 style="margin:0 0 16px 0;font-size:15px;">[分区B标题]</h3>
    <!-- 分区B内容 -->
  </div>
</div>

<!-- 时间线 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;margin-top:16px;">
  <h3 style="margin:0 0 16px 0;font-size:15px;">操作时间线</h3>
  <div style="border-left:2px solid #e0e0e0;padding-left:20px;margin-left:8px;">
    <div style="position:relative;padding-bottom:16px;">
      <div style="position:absolute;left:-25px;width:10px;height:10px;border-radius:50%;background:#4caf50;"></div>
      <div style="font-size:13px;color:#999;">[时间戳]</div>
      <div style="font-weight:500;">[事件A]</div>
      <div style="font-size:13px;color:#666;">[事件A说明]</div>
    </div>
    <div style="position:relative;">
      <div style="position:absolute;left:-25px;width:10px;height:10px;border-radius:50%;background:#1976d2;"></div>
      <div style="font-size:13px;color:#999;">[时间戳]</div>
      <div style="font-weight:500;">[事件B]</div>
    </div>
  </div>
</div>
```

### 3.5 生成流程

```
1. 完成三步分析（证据台账 → 模式识别 → 优缺点分析）
2. 判断是否需要生成 HTML（见 3.1 生成条件）
3. 选择 HTML 类型：
   - 只有改进方案 → 生成 improved.html
   - 有问题需要对比 → 生成 comparison.html
   - 需要解释设计决策 → 生成 annotated.html
4. 选择 HTML 模板（List Report / Object Page / Dashboard）
5. 填充内容：将分析报告的结论转化为 HTML 元素
6. 添加标注：用 .annotation 或 .problem-area / .improved-area 说明设计决策
7. 验证：确保双击可在浏览器打开
```

### 3.6 生成示例

**分析结论**：
- 模式：List Report（当前结构已观察；任务匹配待验证）
- 风险信号 1：确认 Dialog 当前只显示对象摘要（OBS-002）；业务后果未知
- 风险信号 2：筛选区显示 12 个字段且无折叠（SCREEN-001）；使用频率与任务影响未知

**生成判定**：不生成 HTML。

**原因与下一步**：
- 当前证据只能支撑界面事实，不能支撑优先级、具体业务字段或改版效果
- 先补充 DOC-/配置确认业务规则，使用 LOG-/INTERVIEW-/TEST- 验证任务影响
- 满足 3.1 全部前提后，才可生成标注“概念方案”的 HTML；未知业务内容必须使用中性占位

---

## 4. 分析报告模板（实用版）

> 实际报告不需要填满所有字段。没有证据的字段写"（未知）"，不要捏造。

### 4.1 单页面分析报告

```markdown
# [系统名] - [页面名] UI 分析报告

> 日期：YYYY-MM-DD | 粒度：单页面 | 模式：[填入识别到的模式]
> 分析人：AI Agent

## 证据台账

| ID | 类型 | 日期与环境 | 入口/步骤 | 观察内容 | 局限 |
|---|---|---|---|---|---|
| OBS-001 | 实机观察 | 版本/账号/日期 | 逐步记录 | 只写可见事实 | 未覆盖状态 |
| SCREEN-001 | 截图 | 版本/路径/日期 | - | 布局和可见内容 | 仅覆盖此分辨率 |
| INFER-001 | 推断 | - | - | 由 OBS-001 + OBS-002 推出 | 待独立验证 |

## 基本信息

| 项目 | 内容 |
|---|---|
| 系统类型 | ERP / CRM / WMS / POS / SaaS / ... |
| 模块 | 订单 / 商品 / 库存 / 会员 / 财务 / ... |
| 页面名称 | [页面名] |
| 入口路径 | [路径] |
| 主要用户角色 | [有 INTERVIEW-/LOG-/DOC-：直接事实；否则：候选角色/待验证] |
| 主要任务 | [有 INTERVIEW-/LOG-/DOC-：直接事实；否则：（未知）] |
| 时间压力 | [有 INTERVIEW-/LOG-：直接事实；否则：（未知）] |

## 模式识别

- **识别模式**：（直接事实/推断）使用了 [模式名]
- **深层逻辑**：（推断）该模式适合"..."
- **边界条件**：（假设）⚠️ 当...时，该模式不适用

## 设计合理性评价

**结论**：[合理 / 勉强合理 / 不合理 / 过度设计 / 设计不足]

| 评价维度 | 判断 | 证据 |
|---|---|---|
| 模式-任务匹配 | [判断] | [证据 ID] |
| 信息分层 | [判断] | [证据 ID] |
| 操作风险分层 | [判断] | [证据 ID] |
| 状态四问覆盖 | [判断] | [证据 ID] |

## 优点

1. **优点 1**（推断/假设）深层原因：...；成立条件：...；证据：OBS-XXX
2. ...

## 缺点与改进

| 优先级 | 缺点 | 证据 | 影响方向 | 改进建议 |
|---|---|---|---|---|
| **待定/风险信号** | [界面问题事实] | OBS-/SCREEN- | [影响未知或待验证] | [验证方式/建议方向] |
| **高/中/低** | [满足 4.1 后填写] | OBS-/SCREEN- + LOG-/TEST-/INTERVIEW- | [有证据的任务影响] | [改进建议] |

> 单条 `OBS-`、`SCREEN-` 或 `INFER-` 不足以定优先级。未满足 4.1 时统一写“待定/风险信号”，并列验证方式。

## 反模式检查

| 反模式 | 是否存在 | 证据 | 严重度 |
|---|---|---|---|
| 一张表一个页面 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| 首页堆图表 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| 巨型表单 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| 详情页没有历史 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| 报表不能钻取 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| 异常只在日志 | 是 / 否 / 未知 | [证据 ID] | 待定；满足 4.1 后定级 |
| ... | ... | ... | ... |

## HTML 生成结论

**[生成 / 不生成] HTML 展示**

- 原因：（推断/假设）...
- 对应问题：已定级 X 个，待定/风险信号 X 个
- 生成文件：[路径]improved.html 或 comparison.html

**后续验证建议**（当不生成 HTML 时）：
- [ ] 验证方式 1
- [ ] 验证方式 2

## 结论

[本次分析的覆盖范围说明 + 模式选择合理性评价 + 核心改进方向。注意：不得在此处写入未经证实的量化收益或业务规则。]
```

### 4.2 模块级分析报告

```markdown
# [系统名] - [模块名] 模块分析报告

> 日期：YYYY-MM-DD | 粒度：模块级 | 覆盖：X 个页面 / Y 个角色
> 分析人：AI Agent

## 证据台账

| ID | 类型 | 日期与环境 | 入口/步骤 | 观察内容 | 局限 |
|---|---|---|---|---|---|
| OBS-001 | 实机观察 | 版本/账号/日期 | 逐步记录 | 只写可见事实 | 未覆盖状态 |
| SCREEN-001 | 截图 | 版本/路径/日期 | - | 布局和可见内容 | 仅覆盖此分辨率 |

## 模块基本信息

| 项目 | 内容 |
|---|---|
| 模块名称 | [模块名] |
| 包含页面 | [页面1] / [页面2] / ... |
| 主要用户角色 | [角色1] / [角色2] |
| 核心业务对象 | [对象名] |

## 模式地图

| 页面 | UI 模式 | 模式特征 | 这种模式的优点 | 合理性 | 证据 | 成立条件 / 边界 |
|---|---|---|---|---|---|---|
| [页面1] | [模式或候选模式] | [可见构成] | [结构性优点] | [判断/待验证] | [证据 ID] | [边界] |
| [页面2] | [模式或候选模式] | [可见构成] | [结构性优点] | [判断/待验证] | [证据 ID] | [边界] |

## 模块级问题

| 优先级 | 问题 | 影响范围 | 改进建议 |
|---|---|---|---|
| **高** | [问题描述] | [影响范围] | [改进建议] |
| **中** | [问题描述] | [影响范围] | [改进建议] |

## HTML 生成结论

**[生成 / 不生成] HTML 展示**

- 原因：（推断/假设）...
- 生成文件：[路径]

**后续验证建议**：
- [ ] 验证方式 1

## 结论

[模块级模式一致性评价 + 端到端流程闭环评价。注意：不得写入未经证实的量化收益或业务规则。]
```

---

## 5. 检查清单

### 5.1 分析前检查

| 检查项 | 状态 | 证据 ID | 缺口 / 下一步 |
|---|---|---|---|
| 系统类型和模块 | 通过 / 未通过 / 不适用 | DOC-/OBS- | 未通过时补官方资料或入口观察 |
| 主要用户角色 | 通过 / 未通过 / 未知 | INTERVIEW-/LOG-/DOC- | 未知时列候选角色并安排验证 |
| 分析粒度 | 通过 / 未通过 | - | 明确单页面 / 单流程 / 模块级 |
| 已覆盖和未覆盖状态/角色 | 通过 / 未通过 | OBS-/SCREEN- | 补覆盖矩阵和未覆盖项 |
| 截图或实机观察 | 通过 / 未通过 | SCREEN-/OBS- | 缺失时不得输出页面事实 |

### 5.2 分析中检查

| 检查项 | 状态 | 证据 ID | 缺口 / 下一步 |
|---|---|---|---|
| 结论使用四个确定性标签 | 通过 / 未通过 | 相关证据 | 修正未标注结论 |
| 每个已观察页面均输出 UI 模式与模式优点 | 通过 / 未通过 | 覆盖矩阵 + OBS-/SCREEN- | 补齐逐页矩阵；无法识别时写候选模式/待验证 |
| 每个页面均有原始截图和中文模式标注图 | 通过 / 未通过 | SCREEN- | 缺图、漏标或标注无法追溯时禁止交付 |
| 每个推断包含推理链 | 通过 / 未通过 | INFER- | 补前提、推导与边界 |
| 高/中/低优先级满足 4.1 | 通过 / 未通过 / 不适用 | LOG-/TEST-/INTERVIEW- 等 | 不满足时降级为待定/风险信号 |
| 反模式逐项检查 | 通过 / 未通过 | OBS-/SCREEN- | 未覆盖项写未知，不得猜测 |
| 非 HTML 问题得到保留 | 通过 / 未通过 / 不适用 | - | 转为流程、权限、内容或验证建议 |

### 5.3 分析后检查

| 检查项 | 状态 | 证据 ID | 缺口 / 下一步 |
|---|---|---|---|
| 结论粒度匹配覆盖门槛 | 通过 / 未通过 | 覆盖矩阵 | 不满足时降级为抽样观察 |
| 证据台账被完整引用 | 通过 / 未通过 | 全部证据 ID | 补孤立证据或无来源结论 |
| HTML 满足全部生成前提 | 通过 / 未通过 / 不生成 | SCREEN-/OBS-/DOC- 等 | 当前版须可追溯；概念版不得虚构规则 |
| 未用“典型 SaaS”补全结论 | 通过 / 未通过 | - | 删除经验替代证据的内容 |

任何必检项为“未通过”且未按“缺口 / 下一步”完成降级处理时，禁止交付为正式分析报告。

---

## 6. 附录

### 6.1 术语对照表

| 术语 | 含义 |
|---|---|
| List Report | 查询列表 + 高级筛选 + 表格操作，适合查找业务对象 |
| Object Page | 对象详情页，展示一个对象的完整上下文 |
| Worklist | 只显示待处理的列表，适合连续处理任务 |
| Dashboard | 指标概览 + 图表，适合查看经营状态 |
| Sectioned Form | 分区表单，适合 10+ 字段的复杂配置 |
| Wizard | 向导/步骤表单，适合多步骤强顺序的流程 |
| Master-Detail | 主从布局，左侧选对象右侧看详情 |
| Timeline | 时间线，展示状态流转和操作历史 |
| Related Lists | 关联列表，展示主对象的关联集合 |
| Drill-down | 钻取，从汇总指标逐层深入到明细 |

### 6.2 快速分析决策树

```
用户来这个页面是为了？
├── 查找对象 → 是 List Report 吗？
│   ├── 是 → 筛选区是否按角色分组？表格操作是否分层？
│   └── 否 → 可能用了卡片/看板，需要检查是否过度设计
├── 理解对象 → 是 Object Page 吗？
│   ├── 是 → 状态四问是否回答？Timeline 是否存在？
│   └── 否 → 可能缺少详情页，需要检查是否设计不足
├── 执行流程 → 是 Wizard/Sectioned Form 吗？
│   ├── 是 → 步骤是否按业务逻辑排序？互斥字段是否处理？
│   └── 否 → 可能表单过长或流程断裂
├── 查看状态 → 是 Dashboard 吗？
│   ├── 是 → 指标是否可钻取？异常是否有专门入口？
│   └── 否 → 可能图表堆砌，需要检查是否合理
└── 处理异常 → 是 Exception Center 吗？
    ├── 是 → 异常是否分类？是否提供处理动作？
    └── 否 → 异常可能在日志里，需要标记为断裂闭环
```

---

## 7. 典型场景分析指南

### 7.1 ERP 订单模块

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 订单列表 | 筛选维度、状态覆盖、批量操作 | 订单状态机是否完整？待处理订单是否突出？ |
| 订单详情 | 状态四问、Timeline、关联对象 | 为什么是这个状态？等待什么？可做哪些操作？ |
| 订单编辑/退款 | 表单校验、影响预览、权限控制 | 退款是否可逆？是否影响库存？操作是否可审计？ |
| 退货退款 | 退款路径、库存回滚、金额计算 | 退货和退款是否关联？库存回滚是否自动？ |

**常见反模式**：
- 订单详情只有当前状态，没有 Timeline（无法解释状态来源）
- 发货/退款按钮没有影响预览（高风险操作无保护）
- 订单列表按数据库字段排列，没有按用户任务重组

### 7.2 ERP 商品/库存模块

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 商品列表 | 类目导航、SKU 区分、价格展示 | 多规格商品如何展示？搜索是否支持模糊匹配？ |
| 商品编辑 | 字段分组、规格管理、渠道差异 | 规格和属性是否区分？渠道价格是否独立管理？ |
| 库存台账 | 维度拆分（仓库/批次/状态）、可用量 vs 在途量 | 在途量如何计算？冻结量和可用量是否分开？ |
| 库存预警 | 预警规则、阈值配置、通知机制 | 预警规则是否可配置？谁会收到通知？ |

**常见反模式**：
- 商品编辑用巨型表单（40+ 字段无分组）
- 库存数据只有总量，没有按维度拆分
- 预警规则写在代码里，不可配置

### 7.3 ERP 财务模块

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 应收/应付 | 核销逻辑、账期管理、逾期提醒 | 预收款和应收款是否区分？逾期账龄如何计算？ |
| 凭证录入 | 借贷平衡、辅助核算、凭证模板 | 借贷不平衡时是否阻止提交？辅助核算是否必填？ |
| 财务报表 | 指标口径、钻取路径、对账入口 | 报表数字能否追溯到凭证？同一指标不同报表口径是否一致？ |
| 对账单 | 双方数据对齐、差异标注、确认机制 | 差异如何标注？确认后是否锁定？ |

**常见反模式**：
- 凭证录入没有借贷平衡校验
- 报表数字不能钻取到凭证层
- 应收和预收没有自动核销机制

### 7.4 CRM 模块

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 客户列表 | 分类管理、搜索能力、跟进状态 | 公海/私海是否区分？失商机户是否自动回收？ |
| 客户详情 | 360 度画像、跟进时间线、关联对象 | 客户最近一次跟进是什么时候？关联订单/商机是否完整？ |
| 商机管理 | 阶段流转、预测管理、输单原因 | 商机阶段是否有强制性？输单是否必须填写原因？ |
| 外勤拜访 | 定位签到、拜访记录、路线规划 | 定位是否真实？拜访记录是否能追溯？ |

**常见反模式**：
- 客户详情没有跟进 Timeline（跟进历史丢失）
- 商机阶段流转没有强制性和校验
- 客户数据没有分层（没有公海机制）

### 7.5 SaaS 工作台

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 角色工作台 | 待办聚合、指标卡、快捷入口 | 不同角色看到的是否一样？待办是否按紧急程度排序？ |
| 门店/网点看板 | 实时指标、趋势对比、异常告警 | 指标多久刷新一次？异常是否有点击可进入处理？ |
| 运营概览 | 数据范围、时间维度、同比环比 | 数据范围是否说明？时间维度是否可切换？ |
| 异常中心 | 异常分类、处理动作、重复聚合 | 异常是否分类？大量同类异常是否聚合？ |

**常见反模式**：
- 首页堆砌大量图表，没有待办和异常入口
- Dashboard 数字只能看，无法钻取到明细
- 指标没有口径说明（用户不知道数据怎么算的）

### 7.6 WMS 仓储模块

| 页面 | 重点分析维度 | 必问问题 |
|---|---|---|
| 入库作业 | 任务分配、波次策略、扫码联动 | 入库任务如何分配？扫码后是否自动更新状态？ |
| 出库作业 | 拣货路径、复核机制、库存扣减时机 | 拣货顺序是否最优？复核未通过如何处理？ |
| 库存查询 | 多维度筛选、批次追溯、在库时长 | 批次如何追溯？在库时长是否计算？冻结库存如何展示？ |
| 盘点 | 盲盘支持、差异处理、账实核对 | 是否支持盲盘？盘点差异是否自动处理？ |

**常见反模式**：
- 入库/出库作业没有 PDA 端配合，纯 PC 端无法支撑扫码场景
- 库存数量没有冻结量和可用量区分
- 盘点没有盲盘支持（账存数量可见导致作弊）

---

## 8. HTML 模板完整库

### 8.1 Dashboard（仪表盘）模板

```html
<!-- 指标卡片行 -->
<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:20px;">
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <div style="font-size:13px;color:#999;margin-bottom:8px;">[指标A名称]</div>
    <div style="font-size:28px;font-weight:bold;color:#333;">[数值A]</div>
    <div style="font-size:12px;color:#4caf50;margin-top:8px;">↑ [趋势A]%</div>
  </div>
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <div style="font-size:13px;color:#999;margin-bottom:8px;">[指标B名称]</div>
    <div style="font-size:28px;font-weight:bold;color:#333;">[数值B]</div>
    <div style="font-size:12px;color:#f44336;margin-top:8px;">↓ [趋势B]%</div>
  </div>
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <div style="font-size:13px;color:#999;margin-bottom:8px;">[指标C名称]</div>
    <div style="font-size:28px;font-weight:bold;color:#333;">[数值C]</div>
    <div style="font-size:12px;color:#999;margin-top:8px;">[对比周期]</div>
  </div>
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <div style="font-size:13px;color:#999;margin-bottom:8px;">[指标D名称]</div>
    <div style="font-size:28px;font-weight:bold;color:#333;">[数值D]</div>
    <div style="font-size:12px;color:#999;margin-top:8px;">[数据口径]</div>
  </div>
</div>

<!-- 图表区 + 待办区 -->
<div style="display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:16px;">
  <!-- 趋势图 -->
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
      <h3 style="margin:0;font-size:15px;">[图表标题]</h3>
      <div style="display:flex;gap:8px;">
        <button style="padding:4px 12px;border:1px solid #ddd;background:white;border-radius:4px;font-size:12px;cursor:pointer;">[日]</button>
        <button style="padding:4px 12px;border:1px solid #1976d2;background:#1976d2;color:white;border-radius:4px;font-size:12px;cursor:pointer;">[周]</button>
        <button style="padding:4px 12px;border:1px solid #ddd;background:white;border-radius:4px;font-size:12px;cursor:pointer;">[月]</button>
      </div>
    </div>
    <!-- 图表占位 -->
    <div style="height:200px;background:#fafafa;border-radius:4px;display:flex;align-items:center;justify-content:center;color:#ccc;">
      [趋势图区域 - 可点击钻取到明细]
    </div>
  </div>
  <!-- 待办列表 -->
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;">
    <h3 style="margin:0 0 16px 0;font-size:15px;">[待办标题]</h3>
    <div style="margin-bottom:12px;padding:12px;background:#fff3e0;border-radius:6px;cursor:pointer;">
      <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
        <span style="font-weight:500;font-size:14px;">[待办A标题]</span>
        <span style="background:#f44336;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">[数量A]</span>
      </div>
      <div style="font-size:12px;color:#999;">[待办A说明]</div>
    </div>
    <div style="margin-bottom:12px;padding:12px;background:#fff3e0;border-radius:6px;cursor:pointer;">
      <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
        <span style="font-weight:500;font-size:14px;">[待办B标题]</span>
        <span style="background:#ff9800;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">[数量B]</span>
      </div>
      <div style="font-size:12px;color:#999;">[待办B说明]</div>
    </div>
    <div style="padding:12px;background:#e3f2fd;border-radius:6px;cursor:pointer;">
      <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
        <span style="font-weight:500;font-size:14px;">[待办C标题]</span>
        <span style="background:#1976d2;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">[数量C]</span>
      </div>
      <div style="font-size:12px;color:#999;">[待办C说明]</div>
    </div>
  </div>
</div>

<!-- 异常提示区 -->
<div style="background:#ffebee;border-left:4px solid #f44336;padding:16px;border-radius:0 8px 8px 0;margin-bottom:16px;">
  <div style="font-weight:500;margin-bottom:8px;color:#c62828;">⚠️ [异常类型]：[数量] 条待处理</div>
  <div style="display:flex;gap:12px;flex-wrap:wrap;">
    <button style="padding:6px 16px;background:#f44336;color:white;border:none;border-radius:4px;cursor:pointer;font-size:13px;">[处理入口]</button>
    <span style="color:#666;font-size:13px;align-self:center;">[最近异常时间]</span>
  </div>
</div>
```

### 8.2 Sectioned Form（分区表单）模板

```html
<!-- 表单头部 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:24px;margin-bottom:16px;">
  <h2 style="margin:0 0 4px 0;font-size:18px;">[表单标题]</h2>
  <div style="font-size:13px;color:#999;">[表单说明或帮助入口]</div>
</div>

<!-- 分区1 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;margin-bottom:16px;">
  <div style="display:flex;align-items:center;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid #eee;">
    <div style="width:24px;height:24px;background:#1976d2;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:bold;margin-right:10px;">1</div>
    <h3 style="margin:0;font-size:15px;">[分区A标题]</h3>
    <span style="margin-left:auto;font-size:12px;color:#999;">* 必填</span>
  </div>
  <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:16px;">
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段A标签] <span style="color:#f44336;">*</span></label>
      <input type="text" placeholder="[占位文本]" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box;">
    </div>
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段B标签]</label>
      <select style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;">
        <option>[选项A]</option>
        <option>[选项B]</option>
      </select>
    </div>
    <div style="grid-column:1/-1;">
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段C标签]</label>
      <textarea rows="3" placeholder="[占位文本]" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;resize:vertical;box-sizing:border-box;"></textarea>
    </div>
  </div>
</div>

<!-- 分区2 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;margin-bottom:16px;">
  <div style="display:flex;align-items:center;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid #eee;">
    <div style="width:24px;height:24px;background:#1976d2;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:bold;margin-right:10px;">2</div>
    <h3 style="margin:0;font-size:15px;">[分区B标题]</h3>
  </div>
  <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:16px;">
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段D标签]</label>
      <input type="number" placeholder="[占位文本]" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box;">
    </div>
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段E标签]</label>
      <input type="date" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box;">
    </div>
  </div>
  <!-- 互斥字段组 -->
  <div style="margin-top:16px;padding:16px;background:#fafafa;border-radius:6px;">
    <div style="font-size:13px;font-weight:500;margin-bottom:12px;">[互斥字段组标题]</div>
    <div style="display:flex;gap:16px;margin-bottom:12px;">
      <label style="display:flex;align-items:center;gap:6px;cursor:pointer;">
        <input type="radio" name="mode" value="A" checked style="cursor:pointer;"> <span>[模式A标签]</span>
      </label>
      <label style="display:flex;align-items:center;gap:6px;cursor:pointer;">
        <input type="radio" name="mode" value="B" style="cursor:pointer;"> <span>[模式B标签]</span>
      </label>
    </div>
    <div id="fieldA" style="display:block;">
      <input type="text" placeholder="[模式A专属字段]" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box;">
    </div>
  </div>
</div>

<!-- 提交区 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:20px;display:flex;justify-content:flex-end;gap:12px;">
  <button style="padding:10px 24px;background:white;color:#666;border:1px solid #ddd;border-radius:6px;cursor:pointer;font-size:14px;">[取消]</button>
  <button style="padding:10px 24px;background:#4caf50;color:white;border:none;border-radius:6px;cursor:pointer;font-size:14px;font-weight:500;">[保存草稿]</button>
  <button style="padding:10px 24px;background:#1976d2;color:white;border:none;border-radius:6px;cursor:pointer;font-size:14px;font-weight:500;">[提交]</button>
</div>
```

### 8.3 Wizard（向导）模板

```html
<!-- 步骤指示器 -->
<div style="background:#fff;padding:24px;border:1px solid #e0e0e0;border-radius:8px;margin-bottom:16px;">
  <div style="display:flex;justify-content:space-between;position:relative;padding:0 40px;">
    <!-- 连接线 -->
    <div style="position:absolute;top:18px;left:60px;right:60px;height:2px;background:#e0e0e0;"></div>
    <!-- 步骤1 - 完成 -->
    <div style="text-align:center;position:relative;z-index:1;">
      <div style="width:36px;height:36px;background:#4caf50;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1);">✓</div>
      <div style="font-size:13px;color:#4caf50;font-weight:500;">[步骤1]</div>
      <div style="font-size:11px;color:#999;">已完成</div>
    </div>
    <!-- 步骤2 - 当前 -->
    <div style="text-align:center;position:relative;z-index:1;">
      <div style="width:36px;height:36px;background:#1976d2;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1);">2</div>
      <div style="font-size:13px;color:#1976d2;font-weight:500;">[步骤2]</div>
      <div style="font-size:11px;color:#1976d2;">当前</div>
    </div>
    <!-- 步骤3 - 待填 -->
    <div style="text-align:center;position:relative;z-index:1;">
      <div style="width:36px;height:36px;background:#e0e0e0;color:#999;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:14px;">3</div>
      <div style="font-size:13px;color:#999;">[步骤3]</div>
      <div style="font-size:11px;color:#999;">待填写</div>
    </div>
    <!-- 步骤4 - 待填 -->
    <div style="text-align:center;position:relative;z-index:1;">
      <div style="width:36px;height:36px;background:#e0e0e0;color:#999;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:14px;">4</div>
      <div style="font-size:13px;color:#999;">[步骤4]</div>
      <div style="font-size:11px;color:#999;">待填写</div>
    </div>
  </div>
</div>

<!-- 步骤内容 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:24px;margin-bottom:16px;">
  <h3 style="margin:0 0 20px 0;font-size:17px;">[当前步骤标题]</h3>
  <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:16px;">
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段A标签] <span style="color:#f44336;">*</span></label>
      <input type="text" value="[当前值]" style="width:100%;padding:8px 12px;border:1px solid #4caf50;border-radius:4px;box-sizing:border-box;background:#f1f8e9;">
    </div>
    <div>
      <label style="display:block;font-size:13px;color:#333;margin-bottom:6px;">[字段B标签]</label>
      <input type="text" placeholder="[占位文本]" style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box;">
    </div>
  </div>
  <!-- 校验提示 -->
  <div style="margin-top:12px;padding:10px 12px;background:#e3f2fd;border-radius:4px;font-size:13px;color:#1565c0;">
    💡 [步骤校验说明]
  </div>
</div>

<!-- 导航按钮 -->
<div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:16px 24px;display:flex;justify-content:space-between;">
  <button style="padding:10px 24px;background:white;color:#666;border:1px solid #ddd;border-radius:6px;cursor:pointer;font-size:14px;">← [上一步]</button>
  <div style="display:flex;gap:12px;">
    <span style="color:#999;font-size:13px;align-self:center;">步骤 2/4</span>
    <button style="padding:10px 24px;background:white;color:#666;border:1px solid #ddd;border-radius:6px;cursor:pointer;font-size:14px;">[保存草稿]</button>
    <button style="padding:10px 24px;background:#1976d2;color:white;border:none;border-radius:6px;cursor:pointer;font-size:14px;font-weight:500;">[下一步] →</button>
  </div>
</div>
```

### 8.4 Worklist（待办列表）模板

```html
<!-- 待办统计条 -->
<div style="display:flex;gap:16px;margin-bottom:16px;">
  <div style="background:#f44336;color:white;padding:12px 20px;border-radius:8px;text-align:center;flex:1;">
    <div style="font-size:11px;opacity:0.9;">[待办类型A]</div>
    <div style="font-size:24px;font-weight:bold;">[数量A]</div>
  </div>
  <div style="background:#ff9800;color:white;padding:12px 20px;border-radius:8px;text-align:center;flex:1;">
    <div style="font-size:11px;opacity:0.9;">[待办类型B]</div>
    <div style="font-size:24px;font-weight:bold;">[数量B]</div>
  </div>
  <div style="background:#fbc02d;color:#333;padding:12px 20px;border-radius:8px;text-align:center;flex:1;">
    <div style="font-size:11px;opacity:0.9;">[待办类型C]</div>
    <div style="font-size:24px;font-weight:bold;">[数量C]</div>
  </div>
  <div style="background:#4caf50;color:white;padding:12px 20px;border-radius:8px;text-align:center;flex:1;">
    <div style="font-size:11px;opacity:0.9;">今日已完成</div>
    <div style="font-size:24px;font-weight:bold;">[已完成数量]</div>
  </div>
</div>

<!-- 待办卡片列表 -->
<div style="display:flex;flex-direction:column;gap:12px;">
  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:16px;cursor:pointer;transition:box-shadow 0.2s;border-left:4px solid #f44336;">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px;">
      <div>
        <span style="background:#f44336;color:white;padding:2px 8px;border-radius:4px;font-size:11px;margin-right:8px;">[待办类型A]</span>
        <span style="font-size:12px;color:#999;">[紧迫度标签]</span>
      </div>
      <span style="font-size:12px;color:#999;">[等待时长]</span>
    </div>
    <div style="font-weight:500;font-size:15px;margin-bottom:6px;">[待办对象标题]</div>
    <div style="font-size:13px;color:#666;margin-bottom:12px;">[待办描述/摘要]</div>
    <div style="display:flex;justify-content:space-between;align-items:center;">
      <div style="font-size:12px;color:#999;">[关联信息] · [创建时间]</div>
      <div style="display:flex;gap:8px;">
        <button style="padding:6px 16px;background:#4caf50;color:white;border:none;border-radius:4px;cursor:pointer;font-size:13px;">[主操作]</button>
        <button style="padding:6px 12px;background:white;color:#666;border:1px solid #ddd;border-radius:4px;cursor:pointer;font-size:13px;">[次操作]</button>
      </div>
    </div>
  </div>

  <div style="background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:16px;cursor:pointer;transition:box-shadow 0.2s;border-left:4px solid #ff9800;">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px;">
      <div>
        <span style="background:#ff9800;color:white;padding:2px 8px;border-radius:4px;font-size:11px;margin-right:8px;">[待办类型B]</span>
      </div>
      <span style="font-size:12px;color:#999;">[等待时长]</span>
    </div>
    <div style="font-weight:500;font-size:15px;margin-bottom:6px;">[待办对象标题]</div>
    <div style="font-size:13px;color:#666;margin-bottom:12px;">[待办描述/摘要]</div>
    <div style="display:flex;justify-content:space-between;align-items:center;">
      <div style="font-size:12px;color:#999;">[关联信息] · [创建时间]</div>
      <div style="display:flex;gap:8px;">
        <button style="padding:6px 16px;background:#4caf50;color:white;border:none;border-radius:4px;cursor:pointer;font-size:13px;">[主操作]</button>
        <button style="padding:6px 12px;background:white;color:#666;border:1px solid #ddd;border-radius:4px;cursor:pointer;font-size:13px;">[次操作]</button>
      </div>
    </div>
  </div>
</div>
```

### 8.5 Kanban（看板）模板

```html
<!-- 看板列 -->
<div style="display:flex;gap:16px;overflow-x:auto;padding-bottom:16px;">
  <!-- 列1 -->
  <div style="min-width:280px;max-width:300px;">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:12px;background:#f5f5f5;border-radius:8px 8px 0 0;margin-bottom:0;">
      <span style="font-weight:500;font-size:14px;">[阶段A名称]</span>
      <span style="background:#e0e0e0;color:#666;padding:2px 8px;border-radius:10px;font-size:12px;">[数量]</span>
    </div>
    <div style="background:#fafafa;border-radius:0 0 8px 8px;padding:12px;min-height:400px;display:flex;flex-direction:column;gap:10px;">
      <div style="background:#fff;border:1px solid #e0e0e0;border-radius:6px;padding:12px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,0.05);">
        <div style="font-size:12px;color:#999;margin-bottom:4px;">[对象类型]</div>
        <div style="font-weight:500;font-size:14px;margin-bottom:6px;">[卡片标题]</div>
        <div style="font-size:12px;color:#666;margin-bottom:8px;">[卡片摘要]</div>
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <span style="font-size:11px;color:#999;">[时间/人员]</span>
          <span style="font-size:11px;color:#999;">[优先级]</span>
        </div>
      </div>
      <div style="background:#fff;border:1px solid #e0e0e0;border-radius:6px;padding:12px;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,0.05);">
        <div style="font-size:12px;color:#999;margin-bottom:4px;">[对象类型]</div>
        <div style="font-weight:500;font-size:14px;margin-bottom:6px;">[卡片标题]</div>
        <div style="font-size:12px;color:#666;margin-bottom:8px;">[卡片摘要]</div>
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <span style="font-size:11px;color:#999;">[时间/人员]</span>
        </div>
      </div>
    </div>
  </div>
  <!-- 列2 -->
  <div style="min-width:280px;max-width:300px;">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:12px;background:#e3f2fd;border-radius:8px 8px 0 0;margin-bottom:0;">
      <span style="font-weight:500;font-size:14px;">[阶段B名称]</span>
      <span style="background:#1976d2;color:white;padding:2px 8px;border-radius:10px;font-size:12px;">[数量]</span>
    </div>
    <div style="background:#f5f9ff;border-radius:0 0 8px 8px;padding:12px;min-height:400px;display:flex;flex-direction:column;gap:10px;">
      <!-- 卡片同列1结构 -->
    </div>
  </div>
  <!-- 列3 -->
  <div style="min-width:280px;max-width:300px;">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:12px;background:#e8f5e9;border-radius:8px 8px 0 0;margin-bottom:0;">
      <span style="font-weight:500;font-size:14px;">[阶段C名称]</span>
      <span style="background:#4caf50;color:white;padding:2px 8px;border-radius:10px;font-size:12px;">[数量]</span>
    </div>
    <div style="background:#f9fff9;border-radius:0 0 8px 8px;padding:12px;min-height:400px;display:flex;flex-direction:column;gap:10px;">
    </div>
  </div>
</div>
```

---

## 9. 完整演示案例：单页面分析走查

### 9.1 案例背景

**场景**：某零售 SaaS 的订单列表页
**分析粒度**：单页面
**目标**：演示 SOP 全流程如何跑下来

### 9.2 第一步：建立证据台账

```
【证据台账】

| ID | 类型 | 日期与环境 | 入口/步骤 | 观察内容 | 局限 |
|---|---|---|---|---|---|
| OBS-001 | 实机观察 | v2.3.1 / 账号A / 2026-07-10 | 菜单 → 订单 → 订单列表 | 页面首次加载默认显示"全部"状态订单 | 仅测试了一个账号 |
| OBS-002 | 实机观察 | 同上 | 点击"待发货"筛选 | 列表刷新后显示结果，无加载指示 | 无性能测量工具，无法记录耗时 |
| OBS-003 | 实机观察 | 同上 | 点击任意行的"发货"按钮 | 按钮点击后直接弹出确认 Dialog | 未测试高风险场景下的点击行为 |
| OBS-004 | 实机观察 | 同上 | 表格列标题点击 | 支持按[字段A]和[字段B]排序 | 未测试全部列 |
| SCREEN-001 | 截图 | 同上 | 首屏布局 | 筛选区 8 个字段，表格 10 列，首屏可见状态列 | 仅覆盖标准分辨率 1920×1080 |
| INFER-001 | 推断 | — | — | 由 OBS-001 + OBS-002 推断：当前默认筛选可能不匹配部分任务 | 缺少角色、任务与使用日志 |
```

### 9.3 第二步：模式识别

```
【识别模式】：List Report（查询列表）
【深层逻辑】：List Report 的核心价值是"帮助用户从大量业务对象中找到目标并执行操作"
【边界条件】：（假设）当主要任务不是从对象集合中查找目标时，List Report 是否适配需要另行验证
```

**设计要素拆解**：

| 区域 | 状态四问覆盖情况 | 证据 |
|---|---|---|
| 筛选区 | ✓ 是什么（状态/时间筛选）✓ 怎么办（查询按钮）| OBS-001 |
| 表格区 | ✓ 是什么（对象身份）✓ 怎么办（操作按钮）| OBS-001 |
| 操作区 | 确认 Dialog 当前只显示订单摘要；实际业务后果未知 | OBS-003 |

### 9.4 第三步：优缺点分析

```
【优点1】：筛选区按状态和时间组织字段
  深层原因：（假设）这种分组是否匹配目标用户的判断顺序需通过访谈或任务测试验证
  证据：SCREEN-001
  边界条件：（未知）缺少筛选使用日志

【风险信号1】：发货确认 Dialog 的后果信息不完整
  证据：OBS-003
  直接事实：当前 Dialog 仅显示订单摘要
  业务后果：（未知）尚未确认该动作是否影响库存、金额、优惠、状态或关联单据
  严重度：待定；未取得业务规则、错误后果、日志或目标用户测试
  下一步：读取发货规则 DOC-/配置，复现操作结果，并用 INTERVIEW-/TEST- 验证用户是否需要更多后果信息
```

**反模式检查**：

| 反模式 | 是否存在 | 证据 | 严重度 |
|---|---|---|---|
| 表格按钮过多 | 否 | OBS-003：每行仅 2 个操作 | — |
| 详情页没有历史 | 不适用 | 本页为列表页，非详情页 | — |
| 一张表一个页面 | 否 | 列表页承担查询任务，详情页承接理解任务 | — |

### 9.5 第四步：改进方案

```
【优先级待定 / 风险信号】验证发货确认所需的后果信息
  问题事实：OBS-003
  现状：（直接事实）当前点击发货后直接弹出确认 Dialog，仅显示订单摘要
  建议方向：（推断）若规则与用户测试证明需要，可增加“本次操作将影响”分区
  示意内容：影响对象、结果与恢复方式均使用中性占位，不预设库存、优惠或关联单据规则
  验证方式：DOC-/配置确认业务后果；TEST-验证理解正确率；技术人员评估数据来源后再估算成本
  实现成本：（未知）
```

### 9.6 HTML 生成判定

| 条件 | 状态 |
|---|---|
| 有推断级改进方向 | ✓ 是 |
| 业务规则已由 DOC-/配置/用户确认 | ✗ 否 |
| 当前方案是否含未知业务后果 | ✓ 是，影响对象与结果尚未知 |
| 生成结论 | **不生成 HTML**；先完成规则取证和目标用户测试 |

### 9.7 最终报告（完整版）

```markdown
# [系统名] - 订单列表页 UI 分析报告

> 日期：2026-07-10 | 粒度：单页面 | 模式：List Report
> 分析人：AI Agent

## 证据台账

（表格见 9.2）

## 基本信息

| 项目 | 内容 |
|---|---|
| 系统类型 | SaaS / ERP |
| 模块 | 订单管理 |
| 页面名称 | 订单列表 |
| 入口路径 | 菜单 → 订单 → 订单列表 |
| 主要用户角色 | 候选角色/待验证；当前账号类型未知 |
| 主要任务 | （未知）需通过 INTERVIEW-/LOG-/DOC- 确认 |
| 时间压力 | （未知）需通过 INTERVIEW-/LOG- 确认 |

## 模式识别

- **识别模式**：（直接事实）使用了 List Report 模式
- **深层逻辑**：（推断）页面结构支持从对象集合中查找目标并进入后续操作
- **边界条件**：（未知）目标角色、数据规模与主要任务尚未确认

## 设计合理性评价

**结论**：抽样观察；整体合理性待角色与任务证据确认

| 评价维度 | 判断 | 证据 |
|---|---|---|
| 模式-任务匹配 | 待验证 | 缺少 INTERVIEW-/LOG-/DOC- |
| 信息分层 | 状态和时间筛选可见；是否合理待验证 | SCREEN-001 |
| 操作风险分层 | Dialog 仅显示订单摘要，业务后果未知 | OBS-003 |
| 状态四问覆盖 | 当前列表未见状态原因；是否需要在列表呈现未知 | OBS-001 |

## 优点

1. **筛选字段分组可见**（直接事实）：页面把状态和时间字段组织在筛选区；是否符合目标用户判断顺序需验证；证据：SCREEN-001

## 缺点与改进

| 优先级 | 缺点 | 证据 | 影响方向 | 改进建议 |
|---|---|---|---|---|
| **待定/风险信号** | 发货 Dialog 仅显示订单摘要 | OBS-003 | 业务后果和用户理解均未知 | 先确认规则并测试；必要时增加中性影响说明 |
| **待定/风险信号** | 列表未见状态来源说明 | OBS-001 | 是否影响目标任务未知 | 访谈并测试状态理解；再决定是否增加上下文提示 |
| **待定/风险信号** | 筛选区无折叠 | SCREEN-001 | 字段使用频率和首屏影响未知 | 统计筛选使用分布并进行任务测试 |

## 反模式检查

| 反模式 | 是否存在 | 证据 | 严重度 |
|---|---|---|---|
| 表格按钮过多 | 否 | OBS-003 | — |
| 一张表一个页面 | 否 | OBS-001 | — |
| 详情页没有历史 | 不适用 | 列表页 | — |

## HTML 生成结论

**不生成** HTML 展示

- 原因：当前只有界面事实和建议方向，发货动作的业务后果、目标角色与任务影响均未确认
- 后续验证：补充 DOC-/配置、INTERVIEW- 和 TEST-；确认具体信息需求后再生成标注“概念方案”的 HTML

## 结论

本次抽样观察覆盖了订单列表页的筛选和发货入口。已确认筛选区结构、表格结构以及发货确认 Dialog 当前可见内容；目标角色、主要任务、业务后果和实际影响均未知。因此只记录风险信号，不给高/中/低优先级，也不生成 HTML。下一步应先确认发货规则并开展目标用户任务测试；结论仅限于当前账号、版本和已观察状态。
```
