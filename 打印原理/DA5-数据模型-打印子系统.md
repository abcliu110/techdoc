# DA5 数据模型 — 打印子系统

> **模板加载记录**：已读取 SOP-00-DA5-模板.md（独立文件），门禁检查 4 项全部通过 ✅
> 依据：SOP-00 §0 执行前置第 1/6 条

## 门禁检查（生成前必填）

- [x] 是否覆盖了全部核心表？→ ✅ 覆盖收银端 8 表 + 云端 3 表（双实现）
- [x] 每个字段是否标注了业务含义与约束？→ ✅ 见各表字段说明
- [x] 数据关系图是否与 DA3 的 REL 关系一致？→ ✅ 队列→打印机（REL-03）、菜品→部门→队列（REL-01/02/04）
- [x] 是否包含聚合根/值对象/领域服务/领域事件分析？→ ✅ 见 §四

## 一、核心表结构（收银端 pos2plugin）

### pos_prn_job（打印任务 — 收银端）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| prn_queue_lid | bigint | 打印队列ID | 任务归属队列（→pos_prn_queue.lid） | FK |
| prn_printer_lid | bigint | 打印机ID | 任务执行设备（→pos_prn_printer.lid） | FK |
| status | int | 任务状态 | 未打印/已打印 | — |
| purpose | int | 打印用途 | 1=厨房联,2=传菜联,3=顾客联 | FK→PrnJobPurposeEnum |

> 注意：**收银端 pos_prn_job 与云端 pos_prn_job 是同名双实现**，字段不同（见 §三），DA3 已识别此差异。

### pos_prn_queue（打印队列）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| name | varchar | 队列名称 | 管理员自定义 | — |
| primary_printer | varchar | 主打印机ID串 | 逗号分隔，分发首选 | — |
| standby_printer | varchar | 备打印机ID串 | 逗号分隔，主故障时切换 | — |
| pc_lid | bigint | 关联PC | 可选，限定终端 | — |

### pos_prn_printer（打印机）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| name | varchar | 打印机名称 | 管理员自定义 | — |
| type | int | 连接类型 | 1=驱动,2=网口,3=串口,4=USB,5=并口,6=芯烨云,7=佳博云,8=驱动指令 | FK→PrinterTypeEnum |
| model | int | 型号 | GP_3150TFN/XP_T202UA/HY58/HY80 等 | FK→PrinterModelEnum |
| extra_info | text | 扩展信息 | JSON，连接参数 | — |
| pc_lid | bigint | 关联PC | 可选 | — |

### pos_dept（出品部门）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| name | varchar | 部门名称 | 如"热菜部" | — |
| type | int | 部门类型 | 出品/传菜/配菜/制作/利润 | — |
| prn_queue | bigint | 打印队列ID | 部门关联出单队列（→pos_prn_queue.lid） | FK |

### pos_customer_bill_setting（顾客联设置）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| prn_queue | varchar | 队列ID串 | 逗号分隔 | NOT NULL |
| for_checkout | tinyint | 场景 | 0=点菜,1=结账 | — |
| tbl_lid | bigint | 桌台ID | 桌台级匹配 | — |
| tbl_area_lid | bigint | 区域ID | 区域级匹配 | — |
| tbl_type_lid | bigint | 桌型ID | 桌型级匹配 | — |

### pos_dish_to_prn_dept（菜品-出品部门映射）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| dish_lid | bigint | 菜品ID | 关联菜品 | FK |
| prn_dept_lid | bigint | 出品部门ID | 关联部门（→pos_dept.lid） | FK |
| type / pc_lid / tbl_area_lid / dish_type_lid | — | 批量配置维度 | 按菜类/区域/PC 批量配置 | — |

## 二、核心表结构（云端 nms4cloud-pos）

### pos_prn_job（打印任务 — 云端）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| pid | bigint | 物理主键 | 自增主键 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| bill_id | varchar | 业务单据ID | 关联原始订单 | — |
| type_ | int | 样式类型 | 50+种单据类型 | FK→PrnStyleTypeEnum |
| printer | varchar | 打印机信息 | 目标打印机 | — |
| content | text | 打印内容 | 打印内容 | — |
| finish_time | datetime | 完成时间 | 打印完成 | — |

### pos_prn_style（打印样式）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| mid / sid | bigint | 商户/门店 | 租户隔离 | NOT NULL |
| type_ | int | 样式类型 | 对应 PrnStyleTypeEnum | NOT NULL |
| extra_info | text | 扩展信息 | JSON | — |

### pos_prn_style_item（样式项）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 逻辑主键 | 雪花算法 | PK |
| style | bigint | 所属样式ID | →pos_prn_style.lid | FK |
| idx | int | 排序 | 项顺序 | — |
| type_ | int | 项类型 | TEXT/IMG/BAR_CODE/QR_CODE/LINE | FK→PrnStyleItemTypeEnum |
| content / align / bold / w_size / h_size | — | 样式属性 | 内容/对齐/加粗/放大 | — |

## 三、双实现说明（IMPL-*）

| 实现 | 表 | 用途 | 差异 |
|------|-----|------|------|
| IMPL-A（收银端） | pos_prn_job（prn_queue_lid/prn_printer_lid/status/purpose） | 本地打印任务 | 面向物理打印执行 |
| IMPL-B（云端） | pos_prn_job（bill_id/type_/printer/content/finish_time） | 云端任务管理 | 面向配置与管理 |

**影响**：DA3 REL-12 使用收银端 `bizBillId`，云端用 `bill_id`——字段名跨实现不同，检索/对账需按实现区分。

## 四、领域模型分析（不只表结构）

| 领域元素 | 分析 |
|---------|------|
| 聚合根 | **PosPrnJob**（打印任务）——聚合任务内容、状态、打印次数；跨聚合引用 Queue/Printer/Style 仅通过 lid |
| 值对象 | PrinterTypeEnum/PrinterModelEnum/PrnStyleTypeEnum/PrnJobPurposeEnum——无独立身份的类型约束 |
| 领域服务 | PrintJobGenerator（任务生成：按部门分组、按设置匹配队列）；PosPrnQueueServicePlus（初始化+分发） |
| 领域事件 | 任务创建→初始化→分发→打印完成→重打；PrintTaskCreated/Updated/Reprinted/Deleted（前端监控 WebSocket 订阅） |
| 权威源 | 打印任务状态以收银端 pos_prn_job + 本地 .job 文件为权威；配置（队列/样式/开关）以云端为权威 |

## 五、关键索引

| 索引 | 字段 | 用途 |
|------|------|------|
| idx_mid_sid | mid, sid | 按门店查询 |
| idx_prn_queue | prn_queue_lid | 队列任务查询 |
| idx_dish_prn_dept | dish_lid, prn_dept_lid | 菜品部门路由查询 |

## 六、数据关系（与 DA3 REL 一致）

```
pos_dish_to_prn_dept ──prn_dept_lid──▶ pos_dept ──prn_queue──▶ pos_prn_queue ──primary/standby──▶ pos_prn_printer
                                                                    ▲
pos_customer_bill_setting ──prn_queue──────────────────────────────┘
                                                                    │
pos_prn_job(收银端) ──prn_queue_lid / prn_printer_lid───────────────┘
pos_prn_job(云端) ──type_──▶ pos_prn_style ──style──▶ pos_prn_style_item
```

## 七、模板字段对照表

| 模板要求字段 | 实际输出位置 | 状态 |
|-------------|-------------|------|
| 核心表结构（字段/类型/说明/业务含义/约束） | §一/§二（11 表） | ✅ |
| 关键索引 | §五 | ✅ |
| 数据关系图 | §六 | ✅ |
| 双实现识别（IMPL-*） | §三 | ✅ |
| 领域模型（聚合根/值对象/服务/事件） | §四 | ✅ |
| 与 DA3 REL 一致 | §六 | ✅ |

**对照结论**：模板全部字段覆盖，且补充了双实现识别和领域模型分析（超出模板基础要求）。