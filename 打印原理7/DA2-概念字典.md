# DA2 概念字典 — 打印子系统

## 核心概念清单

| 概念 | 业务定义 | 技术实现 | 证据 |
|------|---------|---------|------|
| 打印机 (Printer) | 连接至 POS 系统的物理打印设备 | `PosPrnPrinter` + `PrinterTypeEnum` + `PrinterModelEnum` | E-SRC: PosPrnPrinter.java |
| 打印队列 (Queue) | 将打印样式与打印机关联的配置单元 | `PosPrnQueue` + `PosPrnQueueVO` | E-SRC: PosPrnQueue.java |
| 打印任务 (Job) | 一次打印操作，包含样式、数据源和状态 | `PosPrnJob` + `.job` 文件 | E-SRC: PosPrnJob.java |
| 打印样式 (Style) | 定义票据打印内容的模板 | `PosPrnStyleRow` + `PosPrnStyleCol` | E-SRC: PosPrnStyleRow.java |
| 打印条件 (Condition) | 控制行或记录是否打印的规则 | `ConditionUtil` + 三元组字段 | E-SRC: ConditionUtil.java |
| 数据源 (DataSource) | 打印内容的数据来源 | `PrnDataSourceDTO` | E-SRC: PrnDataSourceDTO.java |
| 打印开关 (Switch) | 控制某种打印类型是否启用和张数 | `PrintJobTypeSwitch` | E-SRC: PrintJobTypeSwitch.java |
| 出品部门 (Dept) | 菜品制作部门，决定厨房联打印去向 | `PosDept` | E-SRC: PosDept.java |
| 顾客联设置 (CustomerBillSetting) | 配置顾客联打印的队列和优先级 | `PosCustomerBillSetting` | E-SRC: PosCustomerBillSetting.java |
| 传菜联设置 (WaiterBillSetting) | 配置传菜联打印的队列和出品部门 | `PosWaiterBillSetting` | E-SRC: PosWaiterBillSetting.java |

## 概念全景卡

### ① 打印机 (Printer)

**业务定义**：打印机是 POS 系统中连接物理打印设备的抽象，每个打印机归属于特定门店，可以是 USB/串口/网口/云打印机。

**关系**：
- 归属于门店（mid, sid）
- 被打印队列引用为主/备打印机（`PosPrnQueue.primaryPrinter/standbyPrinter`）
- 每个打印机对应一个 `PrinterWorker` 工作线程

**行为**：
- 接收打印任务并执行打印指令
- 维护状态（正常/故障/繁忙）
- 支持打印机转移（故障时重定向到其他打印机）

**失败**：打印机离线 → 状态变为 FAULT → 不接收任务 → 自动切换到备打印机

**证据**：E-SRC: PosPrnPrinter.java, PrinterTypeEnum.java, PrinterStatus.java, PrinterWorker.java

---

### ② 打印队列 (Queue)

**业务定义**：打印队列是连接"业务场景"与"打印机"的配置单元，包含一组主/备打印机，决定打印任务发到哪台机器。

**关系**：
- 归属于门店（mid, sid）
- 引用主打印机列表和备用打印机列表
- 被出品部门/顾客联设置/传菜联设置引用
- 被打印任务引用（`PosPrnJob.prnQueueLid`）

**行为**：
- 初始化打印任务（`initJob`）：加载模板、填充数据源、过滤条件
- 分发打印任务（`dispatchJob`）：选择健康打印机、随机负载均衡分发

**失败**：队列未配置打印机 → 任务分发失败 → 日志记录

**证据**：E-SRC: PosPrnQueue.java, PosPrnQueueServicePlus.java

---

### ③ 打印任务 (Job)

**业务定义**：打印任务是一次打印操作的完整记录，包含从业务触发到打印完成的全部信息。

**关系**：
- 归属于门店（mid, sid）
- 引用打印队列（`prnQueueLid`）
- 关联业务单据（`bill_id`）
- 标识打印用途（厨房联/传菜联/顾客联）

**行为**：
- 创建：写入数据库 + 写本地 `.job` 文件
- 初始化：加载模板 + 填充数据源
- 分发：发送到打印机 worker
- 完成：标记已打印，`.job` → `.del`

**失败**：打印机故障 → 自动重试（2秒间隔，最多45分钟）→ 超时后放弃

**证据**：E-SRC: PosPrnJob.java, PosPrnJobServicePlus.java, PrintJobGenerator.java

---

### ④ 打印样式 (Style)

**业务定义**：打印样式定义了一种票据的打印模板，由多行组成，每行包含多列（文本/图片/条码/切割等）。

**关系**：
- 归属于门店（mid, sid）
- 按打印类型区分（`PrnStyleTypeEnum` 50+ 种）
- 被打印任务引用（`PosPrnJob.type_`）

**行为**：
- 配置：后台管理页面编辑行/列
- 加载：`posPrnStyleRowServicePlus.get(mid, sid, type)`
- 渲染：`PrintJobInitUtil.convert(rows, dataSourceList)` → 最终可打印行

**失败**：样式不存在 → 日志"模板不存在" → 任务失败

**证据**：E-SRC: PosPrnStyleRow.java, PosPrnStyleCol.java, PrintJobInitUtil.java

---

### ⑤ 打印条件 (Condition)

**业务定义**：打印条件是控制打印行或数据记录是否可见的规则，由"操作符 + 数据源字段 + 比较值"三元组定义。

**结构**：
- `conditionOperator`：EQ/NE/GT/GE/LT/LE/LIKE/NOT_LIKE/IN/NOT_IN/IS_NULL/IS_NOT_NULL
- `conditionDsId`：格式 `"数据源ID,字段名"`，如 `"bill_info,orderStatus"`
- `conditionValue`：比较值，如 `"CLOSED"`, `"0"`, `"true"`

**行为**：在渲染阶段判断行/记录是否可见，不满足条件的被过滤

**失败**：条件配置错误 → 容错返回 true（显示行）→ 日志记录

**证据**：E-SRC: ConditionUtil.java, 打印条件与行过滤.md
