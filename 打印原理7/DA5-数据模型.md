# DA5 数据模型 — 打印子系统

## 核心表结构

### pos_prn_printer（打印机）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 打印机唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| name | varchar(100) | 打印机名称 | 管理员自定义名称 | NOT NULL |
| type | int | 打印机类型 | 1=驱动,2=网口,3=串口,4=USB,5=并口,6=芯烨云,7=佳博云,8=驱动指令 | FK→PrinterTypeEnum |
| model | int | 打印机型号 | 如 GP-R320C, EPSON-TM-220B 等 | FK→PrinterModelEnum |
| printerStatus | int | 打印机状态 | 0=无状态,1=故障,2=正常,3=正在打印 | FK→PrinterStatus |
| extraInfo | text | 扩展信息 | 按类型存储连接参数（JSON） | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_prn_queue（打印队列）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 队列唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| name | varchar(100) | 队列名称 | 管理员自定义名称 | NOT NULL |
| primaryPrinter | varchar(500) | 主打印机ID列表 | 逗号分隔的打印机 lid | — |
| standbyPrinter | varchar(500) | 备打印机ID列表 | 逗号分隔的打印机 lid | — |
| pcLid | bigint | 关联PC | 可选，关联特定终端 | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_prn_job（打印任务）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 任务唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| bill_id | varchar(100) | 业务单据ID | 关联的业务单据号 | — |
| printer | varchar(500) | 打印机信息 | 目标打印机 | — |
| type_ | int | 打印样式类型 | 50+ 种单据类型 | FK→PrnStyleTypeEnum |
| purpose | int | 打印用途 | 1=厨房联,2=传菜联,3=顾客联 | FK→PrnJobPurposeEnum |
| prnQueueLid | bigint | 打印队列ID | 所属队列 | NOT NULL |
| content | text | 打印内容 | 打印内容（可能已弃用，改用 .job 文件） | — |
| print | tinyint(1) | 是否已打印 | 0=未打印,1=已打印 | DEFAULT 0 |
| finish_time | datetime | 完成时间 | 打印完成时间 | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_prn_style（打印样式）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 样式唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| type_ | int | 样式类型 | 对应 PrnStyleTypeEnum | NOT NULL |
| extra_info | text | 扩展信息 | 额外配置（JSON） | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_prn_style_row（样式行）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 行唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| style | bigint | 所属样式ID | 关联 PosPrnStyle.lid | FK |
| idx | int | 排序索引 | 行顺序 | — |
| dsId | varchar(100) | 数据源ID | 绑定的数据源，如 "store_info" | — |
| cols | text | 列定义JSON | 包含列配置的 JSON 数组 | — |
| conditionOperator | varchar(20) | 条件操作符 | EQ/NE/GT/GE/LT/LE/LIKE/NOT_LIKE/IN/NOT_IN/IS_NULL/IS_NOT_NULL | — |
| conditionDsId | varchar(100) | 条件数据源字段 | 格式 "dsId,fieldId" | — |
| conditionValue | varchar(200) | 条件比较值 | 比较的右值 | — |
| summarize | tinyint(1) | 是否汇总行 | 是否生成合计行 | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_prn_style_col（样式列）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 列唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| style | bigint | 所属样式ID | 关联 PosPrnStyle.lid | FK |
| row | bigint | 所属行ID | 关联 PosPrnStyleRow.lid | FK |
| idx | int | 排序索引 | 列顺序 | — |
| type_ | int | 列类型 | TEXT/IMG/BAR_CODE/QR_CODE/LINE/CUT/CASH_BOX/COMMENT | FK→PrnStyleColTypeEnum |
| condition_ | varchar(500) | 列条件 | 列级打印条件 | — |
| content | text | 内容 | 列内容（可能已弃用，改用 customizedContent） | — |
| align | int | 对齐方式 | 1=居中,2=右对齐,3=左对齐 | FK→PrnStypeAlignEnum |
| width | int | 宽度（旧） | 旧版宽度字段 | — |
| width80 | int | 宽度百分比 | 0-100 百分比宽度 | — |
| bold | tinyint(1) | 是否加粗 | 0=否,1=是 | — |
| w_size | int | 字体宽度倍数 | 字体放大倍数 | — |
| h_size | int | 字体高度倍数 | 字体放大倍数 | — |
| reverse | tinyint(1) | 是否反白 | 0=否,1=是 | — |
| underline | tinyint(1) | 是否下划线 | 0=否,1=是 | — |
| customizedContent | text | 自定义内容模板 | JSON 数组，常量/数据占位符 | — |
| revision | int | 版本号 | 乐观锁 | — |

### print_job_type_switch（打印开关）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 开关唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| type_ | int | 打印样式类型 | 对应 PrnStyleTypeEnum | NOT NULL |
| disabledCustomer | tinyint(1) | 禁用顾客联 | 顾客联是否禁用 | — |
| disabledKitchen | tinyint(1) | 禁用厨房联 | 厨房联是否禁用 | — |
| disabledWaiter | tinyint(1) | 禁用传菜联 | 传菜联是否禁用 | — |
| numOfCustomer | int | 顾客联张数 | 顾客联打印份数 | — |
| numOfKitchen | int | 厨房联张数 | 厨房联打印份数 | — |
| numOfWaiter | int | 传菜联张数 | 传菜联打印份数 | — |
| revision | int | 版本号 | 乐观锁 | — |

### pos_customer_bill_setting（顾客联设置）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 设置唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| prnQueue | varchar(500) | 打印队列ID列表 | 逗号分隔的队列 lid | NOT NULL |
| forCheckout | tinyint(1) | 是否结账场景 | 0=点菜,1=结账 | — |
| tableLid | bigint | 桌台ID | 关联的桌台 | — |
| areaLid | bigint | 区域ID | 关联的区域 | — |
| tableTypeLid | bigint | 桌型ID | 关联的桌型 | — |
| pcLid | bigint | PC设备ID | 关联的收银机 | — |

### pos_waiter_bill_setting（传菜联设置）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 设置唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| prnQueue | varchar(500) | 打印队列ID列表 | 逗号分隔的队列 lid | NOT NULL |
| prnDept | varchar(500) | 出品部门ID列表 | 逗号分隔的部门 lid | — |

### pos_dish_to_prn_dept（菜品出品部门映射）

| 字段 | 类型 | 说明 | 业务含义 | 约束 |
|------|------|------|---------|------|
| lid | bigint | 主键 | 映射唯一标识 | PK |
| mid | bigint | 商户ID | 所属商户 | NOT NULL |
| sid | bigint | 门店ID | 所属门店 | NOT NULL |
| dishLid | bigint | 菜品ID | 关联的菜品 | FK |
| prnDeptLid | bigint | 出品部门ID | 关联的出品部门 | FK |

## 数据关系

```
pos_prn_printer ←── pos_prn_queue (primaryPrinter/standbyPrinter → lid)
                        │
pos_prn_printer ←── pos_prn_printer_transfer (printerLid → lid)
                        │
pos_prn_queue    ←── pos_prn_job (prnQueueLid → lid)
                        │
pos_prn_queue    ←── pos_customer_bill_setting (prnQueue → lid)
                        │
pos_prn_queue    ←── pos_waiter_bill_setting (prnQueue → lid)
                        │
pos_prn_queue    ←── pos_dept (prnQueue → lid)
                        │
pos_prn_style    ←── pos_prn_style_row (style → lid)
                        │
pos_prn_style_row ←── pos_prn_style_col (row → lid)
                        │
pos_dish_to_prn_dept (dishLid → pt_dish.lid, prnDeptLid → pos_dept.lid)
                        │
print_job_type_switch (type_ → PrnStyleTypeEnum.code)
```
