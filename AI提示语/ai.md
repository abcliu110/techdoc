# Role
你是一名高级 Java 后端开发工程师，精通 MySQL 数据库设计和高并发场景下的时间处理。

# Goal
请基于 **“分钟数整数（Integer Minutes）”** 策略，实现一个“营业时段/可用时段”的管理功能。
目标是解决传统的 `TIME` 类型无法表示 `24:00` (全天结束) 以及 `23:59` 存在的一分钟缝隙问题。

# Technical Constraints & Requirements

## 1. 数据库设计 (MySQL)
- 不要使用 `TIME` 或 `DATETIME` 类型存储时段。
- 使用 `SMALLINT` 或 `INT` 存储 **“距离当天 00:00 的分钟数”**。
- 字段命名：`start_min` (开始分钟), `end_min` (结束分钟)。
- 范围说明：`0` 代表 `00:00`，`1440` 代表 `24:00`（这是关键，必须支持 1440）。

## 2. 核心转换逻辑 (Java Util)
请编写一个工具类 `TimeSlotUtils`，需满足以下特殊业务规则：
- **输入**：前端传入的是字符串格式（如 "08:30", "23:59", "00:00"）。
- **输出**：转换为整数分钟。
- **特殊规则（Critical）**：
  - 如果前端传入的 **结束时间** 是 `"23:59"`，必须将其转换为 **1440** (即 24:00)，而不是 1439。这是为了修补前端设计导致的“丢失的一分钟”缝隙。
  - 标准时间转换：`HH * 60 + mm`。

## 3. 查询逻辑 (SQL)
- 遵循 **“左闭右开” (Left-closed, Right-open)** 原则。
- 查询“当前时间是否在营业时段内”时，SQL 逻辑应为：
  `start_min <= current_time_min AND end_min > current_time_min`
- 注意：结束时间必须用 **大于 (>)**，不能用大于等于。

# Output Deliverables (代码产出)

请提供以下 4 部分代码：

1.  **SQL DDL**：建表语句（表名 `business_hours`）。
2.  **Java Entity**：实体类代码（使用 Lombok）。
3.  **Java Utility Class**：包含 `stringToMin` (含23:59特殊处理) 和 `minToString` 方法。
4.  **MyBatis Mapper XML**：编写一个 `countActiveSlots(int currentMin)` 方法，用于查询当前时间是否有效。

# Context Example
- 如果数据库存的是 `08:00 - 24:00` (480, 1440)。
- 当前时间是 `23:59` (1439)。
- SQL 查询 `480 <= 1439 AND 1440 > 1439` 应该返回 `true`（匹配成功）。

{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ceifrI0YjmPkHwc44uwZoY2PIQPgrdHMifodrPRzwK3NiU",  
    "ANTHROPIC_BASE_URL": "https://api.hzfood.top/v1", 
    "ANTHROPIC_TIMEOUT": 90000,    }
}