# SOP-图谱驱动业务分析（快速执行版）

> **用途**：直接执行，不用读长文档  
> **前置**：图数据库已构建 + MCP 已配置

---

## 执行流程

```
1. 查询图库事实
     ↓
2. 阅读代码验证
     ↓
3. 生成文档
```

---

## 查询命令速查

### Q1: 查看项目概览
```bash
code-graph status
```
**输出**：节点数、边数、文件数、语言

---

### Q2: 查看所有类
```bash
code-graph query --pattern file_summary --target {文件路径}
```
或 SQL：
```sql
SELECT name, kind FROM nodes WHERE kind = 'Class';
```

---

### Q3: 查看类字段
```bash
code-graph search --query "Order" --kind Class
```
然后查看字段节点：
```sql
SELECT name, return_type, extra FROM nodes 
WHERE kind = 'Field' AND parent_name LIKE '%Order%';
```

---

### Q4: 查看枚举值
```sql
-- 查看订单状态枚举
SELECT name, extra FROM nodes 
WHERE kind = 'EnumValue' AND parent_name LIKE '%Status%';
```

---

### Q5: 查看 API 端点
```sql
SELECT name, extra FROM nodes WHERE kind = 'Endpoint';
```

---

### Q6: 查看调用关系
```bash
code-graph query --pattern callers_of --target {类.方法}
```

---

### Q7: 查看增强数据
```sql
-- 状态字段
SELECT name, parent_name FROM nodes 
WHERE kind = 'Field' AND extra LIKE '%status%';

-- 时间字段
SELECT name, parent_name FROM nodes 
WHERE kind = 'Field' AND extra LIKE '%time%';

-- 注解
SELECT e.source, e.target FROM edges WHERE kind = 'HAS_ANNOTATION';
```

---

## 文档生成模板

```markdown
# {模块} 业务分析报告

## 版本
| 属性 | 值 |
|---|---|
| 图谱 | {snapshot_id} |
| SOP | v1.0 |

## 一、对象模型
### 1.1 实体类
### 1.2 字段分析

## 二、行为模型
### 2.1 CRUD 操作
### 2.2 状态转换

## 三、集成点
### 3.1 API
### 3.2 MQ

## 四、置信度
| 维度 | 覆盖 | 置信 |
|---|---|---|
| 对象 | {n} 类 | L{n} |
| 行为 | {n} 个 | L{n} |

## 五、未知项
| U-* | 描述 |
|---|---|
| U-1 | {待确认} |
```

---

## 证据引用

```
E-GPH: nodes:{节点名}
E-SRC: {文件}:{行号}
```

---

## 门禁

- [ ] 每个结论有证据
- [ ] 置信度有依据
- [ ] 未知项已登记
