# SOP-图谱驱动业务分析执行手册

> **版本**: v1.0  
> **依据**: code-review-graph增强方案-完整版.md  
> **前置条件**: 图数据库已构建完成（含字段、注解、枚举、异常、规则等增强数据）  
> **适用**: 既有系统业务分析、文档生成

---

## 一、执行目标

根据图数据库中的事实数据，生成符合《更高维业务设计方法论》的完整业务分析文档。

**核心流程**：
```
1. 读取本 SOP 文档
     ↓
2. 查询图数据库获取事实
     ↓
3. 分析数据 + 阅读代码验证
     ↓
4. 生成结构化文档
```

---

## 二、前置条件检查

- [ ] 图数据库已构建完成
- [ ] 已安装 code-graph MCP 工具
- [ ] 目标项目已在图数据库中
- [ ] 已加载《更高维业务设计方法论.md》

---

## 三、执行步骤

### 第一阶段：对象识别（30分钟）

#### 步骤 1.1：查询实体类（@Entity）

**查询指令**：
```
使用 MCP 工具或 SQL 查询 HAS_ANNOTATION 边，筛选 @Entity 注解的类

或者：
graph query: 查找所有 HAS_ANNOTATION 边，target 包含 'Entity'
```

**预期数据**：
- 实体类清单（Class 节点 + @Entity 注解边）
- 表名映射（@Table 注解参数）

---

#### 步骤 1.2：查询类字段

**查询指令**：
```
查询 HAS_FIELD 边，获取每个类的字段信息：
- 字段名、类型（Field 节点）
- 字段注解（@Column、@ManyToOne 等）
- 字段修饰符（private、final 等）

筛选条件：
- is_status_field = true → 状态字段
- is_time_field = true → 时间字段
- is_resource_field = true → 资源字段
- is_id_field = true → ID 字段
```

**预期数据**：
| 字段名 | 类型 | 注解 | 分类 |
|---------|------|------|------|
| id | Long | @Id | ID |
| status | Integer | @Column | STATUS |
| createdTime | LocalDateTime | - | TIME |
| userId | Long | @ManyToOne | SUBJECT |

---

#### 步骤 1.3：查询枚举值

**查询指令**：
```
查询 HAS_ENUM_VALUE 边：
- 枚举类（EnumValue 节点）
- 枚举值列表

筛选条件：枚举名包含 Status、State、Type
```

**预期数据**：
| 枚举类 | 值 | 说明 |
|---------|---|------|
| OrderStatus | CREATED, PAID, SHIPPED, COMPLETED, CANCELLED | 订单状态 |
| PayStatus | UNPAID, PAID, REFUNDED | 支付状态 |

---

### 第二阶段：行为识别（30分钟）

#### 步骤 2.1：查询 CRUD 操作

**查询指令**：
```
查询 CRUD_OPERATION 边：
- SUPPORTS_CREATE → 创建操作
- SUPPORTS_READ → 读取操作
- SUPPORTS_UPDATE → 更新操作
- SUPPORTS_DELETE → 删除操作
```

**预期数据**：
| 操作类型 | 方法 | 所属类 |
|---------|------|--------|
| CREATE | addOrder, createOrder | OrderService |
| READ | getOrderById, listOrders | OrderService |
| UPDATE | updateOrder | OrderService |
| DELETE | deleteOrder | OrderService |

---

#### 步骤 2.2：查询状态转换

**查询指令**：
```
查询 STATE_TRANSITION 边：
- 触发方法
- 目标状态值
- 状态字段

查询 THROWS/CATCHES 边：
- 异常类型
- 补偿逻辑（has_compensation = true）
```

**预期数据**：
| 触发方法 | 状态字段 | 目标状态 |
|---------|----------|----------|
| pay() | status | PAID |
| cancel() | status | CANCELLED |
| refund() | status | REFUNDED |

---

### 第三阶段：主体识别（20分钟）

#### 步骤 3.1：查询主体字段

**查询指令**：
```
查询 HAS_SUBJECT 边：
- userId、creatorId、ownerId 等字段
- 关联的主体类型

查询示例：
HAS_SUBJECT edges where source contains 'Order'
```

**预期数据**：
| 字段名 | 关联主体 | 说明 |
|---------|---------|------|
| userId | User | 下单人 |
| creatorId | User | 创建者 |
| handlerId | User | 经办人 |

---

### 第四阶段：集成识别（20分钟）

#### 步骤 4.1：查询 API 端点

**查询指令**：
```
查询 HANDLES 边：
- HTTP 方法（@GetMapping、@PostMapping 等）
- 路径
- 处理器类

查询 CONSUMES_MESSAGE 边：
- MQ 消费者
- 主题/队列
```

**预期数据**：
| 端点 | 方法 | 路径 | 类型 |
|------|------|------|------|
| OrderController | POST | /order/add | HTTP |
| OrderListener | - | order.created | MQ |

---

### 第五阶段：规则识别（20分钟）

#### 步骤 5.1：查询业务规则

**查询指令**：
```
查询 HAS_RULE 边：
- 规则类型（VALIDATION、AUTHORIZATION 等）
- 规则条件
- 所属范围

查询 WORKFLOW_ACTION 边：
- 工作流动作
- 触发条件
```

**预期数据**：
| 规则类型 | 条件 | 动作 | 置信度 |
|---------|------|------|--------|
| VALIDATION | amount > 0 | throw | L3 |
| AUTHORIZATION | hasPermission | allow/deny | L2 |

---

## 四、置信度评估

| 等级 | 定义 | 来源要求 |
|------|------|----------|
| L5 | 三源一致 | 代码 + 数据库 + API 契约 |
| L4 | 两源印证 | 至少两类独立证据 |
| L3 | 单一事实 | 清晰可直接验证 |
| L2 | 推断 | 需要进一步验证 |
| L1 | 假设 | 待确认 |

**约束**：AI 不得提升置信度等级，不得创造证据。

---

## 五、输出要求

### 5.1 文档结构

```markdown
# {分析对象} 业务分析报告

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | {模块/系统} |
| 图谱版本 | {snapshot_id} |
| SOP 版本 | v1.0 |
| 生成时间 | {日期} |

## 一、对象模型
### 1.1 实体类清单
### 1.2 字段分析
### 1.3 枚举值

## 二、行为模型
### 2.1 CRUD 操作
### 2.2 状态转换

## 三、主体模型
### 3.1 主体识别
### 3.2 权限关系

## 四、集成模型
### 4.1 API 端点
### 4.2 MQ 消息

## 五、规则模型
### 5.1 业务规则
### 5.2 工作流

## 六、置信度汇总
| 维度 | 覆盖度 | 置信度 |
|------|--------|--------|
| 对象 | {n} 类 | L{n} |
| 行为 | {n} 个操作 | L{n} |
| ... | ... | ... |

## 七、未知项（U-*）
| 编号 | 描述 | 影响 |
|---|---|---|
| U-1 | {待确认项} | {影响分析} |
```

### 5.2 证据引用格式

所有事实必须标注来源：
```
E-SRC: {文件名}:{行号}
E-GPH: {节点类型}:{节点名}
```

---

## 六、MCP 工具参考

### 查询入口
```bash
# 查看图库统计
code-graph status

# 查看类字段
code-graph query --kind Field --class Order

# 搜索注解
code-graph search @Entity

# 查看调用链
code-graph query --pattern callers_of --target OrderService.pay
```

### SQL 直接查询
```sql
-- 查询实体类
SELECT n.name, n.kind FROM nodes n 
JOIN edges e ON e.source = n.name 
WHERE e.kind = 'HAS_ANNOTATION' AND e.target = 'Entity';

-- 查询字段
SELECT n.name, n.return_type FROM nodes n 
WHERE n.kind = 'Field' AND n.parent_name LIKE '%Order%';

-- 查询状态转换
SELECT e.source, e.target FROM edges e 
WHERE e.kind = 'STATE_TRANSITION';
```

---

## 七、门禁检查

生成文档前必须确认：

- [ ] 每个查询步骤都有执行记录
- [ ] 证据都标注了来源（E-SRC/E-GPH）
- [ ] 置信度评估有依据
- [ ] 未知项已登记 U-*
- [ ] 未覆盖维度已显式标记

---

## 八、模板字段对照表

| 模板要求字段 | 实际输出 | 状态 |
|-------------|----------|------|
| 对象模型 | 已输出 §1 | ✅ |
| 行为模型 | 已输出 §2 | ✅ |
| 主体模型 | 已输出 §3 | ✅ |
| 集成模型 | 已输出 §4 | ✅ |
| 规则模型 | 已输出 §5 | ✅ |
| 置信度汇总 | 已输出 §6 | ✅ |
| 未知项 | 已输出 §7 | ✅ |

---

## 附录：常用查询模板

### A.1 查询类及其字段
```sql
-- 类字段查询
SELECT n.name, n.return_type, n.extra
FROM nodes n
WHERE n.kind = 'Field' AND n.parent_name = '{类名}';
```

### A.2 查询带注解的字段
```sql
-- 注解字段查询
SELECT n.name, e.target as annotation
FROM nodes n
JOIN edges e ON e.source = n.name
WHERE n.kind = 'Field' AND e.kind = 'HAS_ANNOTATION';
```

### A.3 查询状态枚举
```sql
-- 枚举值查询
SELECT n.name, e.target as enum_value
FROM nodes n
JOIN edges e ON e.source = n.name
WHERE n.kind = 'EnumValue' AND n.parent_name LIKE '%Status%';
```

### A.4 查询方法调用链
```sql
-- 调用链查询
SELECT e.source, e.target
FROM edges e
WHERE e.kind = 'CALLS' AND e.source LIKE '%OrderService%';
```
