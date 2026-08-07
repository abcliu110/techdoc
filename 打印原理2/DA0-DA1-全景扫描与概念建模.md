# 打印功能 DA0-DA1：全景扫描与概念建模

> **分析范围**：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui  
> **分析时间**：2026-08-03  
> **SOP 依据**：SOP-00 业务系统分析 v2.9

---

## 1. 概念模型总览

### 1.1 核心概念定义

| 概念 | 英文名 | 说明 | 源码位置 |
|------|--------|------|----------|
| 打印机 | Printer | 物理打印设备，按连接方式分为驱动、网口、串口、USB、云端等类型 | `PosPrnPrinter.java` |
| 打印队列 | PrintQueue | 打印任务的逻辑分发通道，映射到一组主/备打印机 | `PosPrnQueue.java` |
| 打印任务 | PrintJob | 一次打印操作的抽象，包含打印内容、目标队列、状态追踪 | `PosPrnJob.java` |
| 打印样式 | PrintStyle | 打印单据的视觉模板，分为行样式和列样式 | `PosPrnStyleRow.java`、`PosPrnStyleCol.java` |
| 打印样式类型 | StyleType | 打印单据的业务分类，如点菜单、结账单、厨房联等 | `PrnStyleTypeEnum.java` |
| 打印用途 | JobPurpose | 打印联次的分类：厨房联、划菜联、楼面联 | `PrnJobPurposeEnum.java` |
| 打印任务开关 | PrintJobTypeSwitch | 按单据类型控制是否打印及打印张数 | `PrintJobTypeSwitch.java` |

### 1.2 概念关系矩阵（静态关系）

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              静态关系（配置时建立）                                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   商户(mid) ──────────────────────────────────────────────────────────┐             │
│       │                                                                │             │
│       ├─ 门店(sid) ──────────────────────────────────────────────────┐ │             │
│       │        │                                                      │ │             │
│       │        ├─ 打印机(PosPrnPrinter) ──────────────────────────┐  │ │             │
│       │        │        │                                          │  │ │             │
│       │        │        └─ 设备类型(PrinterTypeEnum)               │  │ │             │
│       │        │        └─ 设备型号(PrinterModelEnum)              │  │ │             │
│       │        │        └─ 扩展配置(extra_info, JSON)              │  │ │             │
│       │        │                                                    │  │             │
│       │        ├─ 打印队列(PosPrnQueue) ──────────────────────────┐  │ │             │
│       │        │        │                                          │  │ │             │
│       │        │        ├─ 主打印机(primaryPrinter, 逗号分隔lid)    │  │ │             │
│       │        │        └─ 备打印机(standbyPrinter, 逗号分隔lid)    │  │ │             │
│       │        │                                                    │  │             │
│       │        ├─ 打印样式行(PosPrnStyleRow) ─────────────────────┐  │ │             │
│       │        │        │                                          │  │ │             │
│       │        │        ├─ 样式类型(styleType)                      │  │ │             │
│       │        │        ├─ 数据源ID(dsId)                           │  │ │             │
│       │        │        ├─ 显示条件(displayCondition)               │  │ │             │
│       │        │        ├─ 汇总标识(summarize)                      │  │ │             │
│       │        │        └─ 条件算子(conditionOperator)              │  │ │             │
│       │        │                                                    │  │             │
│       │        ├─ 打印样式列(PosPrnStyleCol) ─────────────────────┐  │ │             │
│       │        │        │                                          │  │ │             │
│       │        │        ├─ 所属行(rowLid)                          │  │ │             │
│       │        │        ├─ 列类型(type): 条码/二维码/文本/图片/换行等│  │ │             │
│       │        │        ├─ 对齐方式(align): 居中/左/右              │  │ │             │
│       │        │        ├─ 字体大小(fontSize)                       │  │ │             │
│       │        │        ├─ 加粗(bold)                               │  │ │             │
│       │        │        └─ 宽度(width80/width76/width58)            │  │ │             │
│       │        │                                                    │  │             │
│       │        └─ 打印任务开关(PrintJobTypeSwitch) ───────────────┐  │ │             │
│       │                 │                                          │  │             │
│       │                 ├─ 样式类型(type)                           │  │             │
│       │                 ├─ 厨房联开关(numOfKitchen/disabledKitchen) │  │             │
│       │                 ├─ 传菜联开关(numOfWaiter/disabledWaiter)   │  │             │
│       │                 └─ 顾客联开关(numOfCustomer/disabledCustomer)│  │             │
│       │                                                               │ │             │
│       └─ 顾客联配置(PosCustomerBillSetting) ───────────────────────┐ │             │
│       │        │                                                      │ │             │
│       │        ├─ 桌台级/区域级/桌型级/PC级配置优先级                  │ │             │
│       │        └─ 打印队列(prnQueue, 逗号分隔lid)                     │ │             │
│       │                                                               │ │             │
│       └─ 传菜联配置(PosWaiterBillSetting) ──────────────────────────┐             │
│                │                                                              │             │
│                ├─ 传菜间(prnDept, 出品部门lid)                             │             │
│                └─ 打印队列(prnQueue, 逗号分隔lid)                            │             │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 概念关系矩阵（动态关系）

| 关系 | 英文名 | 说明 | 建立时机 | 源码位置 |
|------|--------|------|----------|----------|
| 业务单据 → 打印任务 | Bill→Job | 点餐、结账等业务操作触发打印任务创建 | 运行时（业务事务中） | `PrintJobGenerator.java` |
| 打印任务 → 打印队列 | Job→Queue | 任务创建时指定目标队列lid | 运行时（任务创建时） | `PosPrnJobServicePlus.create()` |
| 打印队列 → 打印机 | Queue→Printer | 队列配置维护主/备打印机映射 | 配置时（静态） | `PosPrnQueueServicePlus.dispatchJob()` |
| 打印样式 → 打印内容 | Style→Content | 模板行+数据源渲染为实际打印内容 | 运行时（任务初始化时） | `PrintJobInitUtil.convert()` |
| 菜品 → 出品部门 | Food→Dept | 菜品关联出品部门，决定厨房联分发 | 配置时或运行时 | `PrintJobGenerator.generateKitchenJob()` |

---

## 2. 枚举值全集

### 2.1 打印机类型（PrinterTypeEnum）

| code | 枚举常量 | 中文说明 | 含义 |
|------|----------|----------|------|
| 1 | DRIVER | 驱动打印机 | 通过系统驱动打印 |
| 2 | NET | 网口指令打印机 | 通过TCP/IP发送ESC/POS指令 |
| 3 | COM | 串口指令打印机 | 通过串口发送ESC/POS指令 |
| 4 | USB | U口指令打印机 | 通过USB发送ESC/POS指令 |
| 5 | LPT | 并口指令打印机 | 通过并口发送ESC/POS指令 |
| 6 | XY_CLOUD | 芯烨云打印机 | 芯烨云平台云打印机 |
| 7 | JB_CLOUD | 佳博云打印机 | 佳博云平台云打印机 |
| 8 | DRIVER_CMD | 驱动指令打印机 | 混合模式 |

### 2.2 打印机型号（PrinterModelEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1 | GP_R320C | GP-R320C |
| 2 | EPSON_TM_220B | EPSON-TM-220B |
| 3 | EPSON_T_T81 | EPSON-T-T81 |
| 4 | BTP_98NP | BTP-98NP |
| 5 | STAR_TSP700 | STAR-TSP700 |
| 6 | STAR_SP700 | STAR-SP700 |
| 7 | STAR_TCP400 | STAR-TCP400 |
| 8 | XP_80X | XP-80X |
| 9 | XP_76X | XP-76X |
| 10 | XP_58X | XP-58X |
| 11 | EPSON_TM_88IV | EPSON-TM-88IV |
| 12 | EPSON_T_T58 | EPSON-T-T58 |
| 13 | HS_80 | HS-80 |
| 14 | GP_3150TFN | GP_3150TFN(标签打印机) |
| 15 | XP_T202UA | XP-T202UA(标签打印机) |
| 16 | HY58 | 汉印58 |
| 17 | HY80 | 汉印80 |

### 2.3 打印样式类型（PrnStyleTypeEnum）

#### 餐饮业务类（code 10-60）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 10 | OrderMenu | 点菜单 |
| 11 | OrderMenuEx | 点菜单（多食） |
| 12 | OldOrderMenu | 重打点菜单 |
| 13 | OldOrderMenuEx | 重打点菜单（多食） |
| 14 | TotalBill | 划菜总单 |
| 15 | TotalBillLocal | 点菜总单 |
| 16 | ReplaceItem | 换品单 |
| 17 | TransferTable | 转台单 |
| 18 | TransferMenu | 菜品转台单 |
| 19 | HurryMenu | 催菜单 |
| 20 | BackMenu | 退菜单 |
| 21 | RespiteMenu | 叫起单 |
| 22 | UpMenu | 起菜单 |
| 23 | ChangeMenuAmout | 数量变更单 |
| 24 | Nodiscount | 结算单 |
| 25 | Discount | 撤销结算单 |
| 26 | CheckOut | 结账单 |
| 27 | CheckOutFull | 结账单(不含明细) |
| 28 | GQBill | 菜品沽清单 |
| 29 | ShiftReport | 交班单 |
| 30 | ReturnDetailsReport | 退菜明细报表 |
| 32 | DateSalesReport | 每日销售报表 |
| 34 | YingYeReport | 营业报表 |
| 35 | BuMenReport | 部门销售报表 |
| 36 | HourSalesReport | 分时销售报表 |
| 37 | CaiSalesReport | 菜品销售报表 |
| 38 | BookSum | 菜品预订汇总 |
| 39 | MemberSavingBill | 会员卡充值 |
| 40 | TuiKaDan | 会员卡退卡 |
| 41 | OrderBill | 预定单 |
| 42 | QueueBill | 排队单 |
| 43 | ReturnBill | 挂账回款单 |
| 44 | XfdInfoBill | 消费单信息 |
| 45 | XfcpInfoBill | 消费菜品信息 |
| 46 | HYXFMX | 会员消费明细 |
| 47 | HYFPMX | 会员发票明细 |
| 48 | MemberFaKaMingXi | 会员发卡明细 |
| 49 | MemberTuiKaMingXi | 会员退卡明细 |
| 50 | MemberBirthday | 会员生日查询 |
| 51 | MemberGift | 会员礼品兑换 |
| 52 | FoodLabel | 标签单 |
| 53 | JFDHCZ | 积分换储值 |
| 54 | CunJiuDan | 存酒单 |
| 55 | MultiCunJiuDan | 多菜品存酒单 |
| 56 | MultiBackWineDan | 多菜品存酒单 |
| 57 | QuJiuDan | 取酒单 |
| 58 | MultiQuJiuDan | 多菜品取酒单 |
| 59 | OrderBillManagement | 预定管理单 |
| 60 | CashboxPop | 弹出钱箱 |

#### 短信类（code 61-73）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 61 | SMS_CRM_REG | 会员登记成功短信 |
| 62 | SMS_CRM_CONSUME | 消费短信 |
| 63 | SMS_POS_RECHECK_OUT | 反结账短信 |
| 64 | SMS_CRM_POINT_CHANGE | 积分兑换短信 |
| 65 | SMS_BOOK_SUCCESS | 预定成功短信 |
| 66 | SMS_BOOK_CANCEL | 预定取消短信 |
| 67 | SMS_BOOK_OVERTIME | 预定过期短信 |
| 68 | SMS_QUEUE | 排队叫号短信 |
| 69 | SMS_SAVE_WINE_OVERTIME | 存酒到期短信 |
| 70 | SMS_SAVE_WINE | 存酒短信 |
| 71 | SMS_PICK_WINE | 取酒短信 |
| 72 | SMS_CRM_RECHARGE | 充值成功短信 |
| 73 | SMS_CREDIT_WINE | 挂账回款短信 |

#### WMS类（code 1000-1048）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1000 | WMS_STORE_ORDER | WMS-门店订货单 |
| 1001 | WMS_ST_BILL_QCPD | WMS-期初盘点 |
| 1002 | WMS_ST_BILL_PDD | WMS-盘点单 |
| 1003 | WMS_ST_BILL_CGJHD | WMS-采购进货单 |
| ... | ... | ... |
| 1048 | WMS_ST_CONVERT_BILL | WMS-转货单 |

### 2.4 打印任务用途（PrnJobPurposeEnum）

| code | 枚举常量 | 中文说明 | 使用场景 |
|------|----------|----------|----------|
| 1 | FOR_KITCHEN | 厨房联 | 厨房联/后厨打印 |
| 2 | FOR_DISH_DELIVERER | 划菜联 | 传菜联/划菜打印 |
| 3 | FOR_CUSTOMER | 楼面联 | 顾客联/结账单打印 |

### 2.5 打印任务状态（PrnJobStatusEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1 | PENDING | pending | 待打印 |
| 2 | SUCCESS | success | 打印成功 |
| 3 | FAILED | failed | 打印失败 |

### 2.6 打印样式列类型（PrnStyleColTypeEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1 | BAR_CODE | 条码 |
| 2 | QR_CODE | 二维码 |
| 3 | TEXT | 文本 |
| 4 | IMG | 图片 |
| 5 | BR | 换行 |
| 6 | CUT | 切纸 |
| 7 | CASH_BOX | 弹钱箱 |
| 8 | LINE | 画直线 |
| 9 | COMMENT | 注释 |
| 10 | SQL_QUERY | sql查询 |

### 2.7 对齐方式（PrnStypeAlignEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1 | CENTER | 居中 |
| 2 | RIGHT | 右对齐 |
| 3 | LEFT | 左对齐 |

### 2.8 字体大小（PrnStyleFontSizeEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 1 | STANDARD | 标准(11号字体) |
| 2 | DOUBLE_WIDTH | 倍宽(13号字体) |
| 3 | DOUBLE_HEIGHT | 倍高(15号字体) |
| 4 | DOUBLE_WIDTH_AND_HEIGHT | 双倍(21号字体) |
| 5 | NINE | 9号字体 |
| 6 | FOUR_TIMES | 四倍(32号字体) |

### 2.9 条件算子（ConditionOperatorEnum）

| code | 枚举常量 | 中文说明 |
|------|----------|----------|
| 11 | EQ | 等于 |
| 12 | GE | 大于或等于 |
| 13 | GT | 大于 |
| 14 | LE | 小于或等于 |
| 15 | LT | 小于 |
| 16 | NE | 不等于 |
| 17 | IS_NULL | 为空 |
| 18 | IS_NOT_NULL | 不为空 |
| 19 | LIKE | 像 |
| 20 | NOT_LIKE | 不像 |
| 21 | IN | 在 |
| 22 | NOT_IN | 不在 |

---

## 3. 模块职责全景图

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  打印子系统模块全景图                                           │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                           nms4cloud-pos2plugin（核心业务插件）                           │  │
│  │  ┌──────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                              pos2plugin-api（接口定义层）                          │  │  │
│  │  │  ├─ 枚举定义：PrinterTypeEnum, PrinterModelEnum, PrnStyleTypeEnum,              │  │  │
│  │  │  │          PrnJobPurposeEnum, PrnJobStatusEnum, PrnStyleColTypeEnum,           │  │  │
│  │  │  │          PrnStypeAlignEnum, PrnStyleFontSizeEnum, ConditionOperatorEnum      │  │  │
│  │  │  ├─ 实体定义：PosPrnPrinter, PosPrnQueue, PosPrnJob, PosPrnStyleRow,            │  │  │
│  │  │  │            PosPrnStyleCol, PrintJobTypeSwitch                                 │  │  │
│  │  │  └─ DTO/VO：PosPrnJobCreateDTO, PosPrnJobQueryDTO, PosPrnQueueVO 等              │  │  │
│  │  └──────────────────────────────────────────────────────────────────────────────────┘  │  │
│  │  ┌──────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                              pos2plugin-dal（数据访问层）                          │  │  │
│  │  │  ├─ Mapper：PosPrnPrinterMapper, PosPrnQueueMapper, PosPrnJobMapper,            │  │  │
│  │  │  │          PosPrnStyleRowMapper, PosPrnStyleColMapper, PrintJobTypeSwitchMapper│  │  │
│  │  │  └─ Entity：见上方 pos2plugin-api                                                │  │  │
│  │  └──────────────────────────────────────────────────────────────────────────────────┘  │  │
│  │  ┌──────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                              pos2plugin-biz（业务逻辑层）                          │  │  │
│  │  │  ├─ PrintJobGenerator：打印任务生成器（核心编排逻辑）                              │  │  │
│  │  │  ├─ PosPrnJobServicePlus：打印任务服务（创建、持久化）                             │  │  │
│  │  │  ├─ PosPrnQueueServicePlus：打印队列服务（初始化、分发）                           │  │  │
│  │  │  ├─ PosPrnPrinterServicePlus：打印机管理服务                                      │  │  │
│  │  │  ├─ PosPrnStyleRowServicePlus：打印样式行服务                                     │  │  │
│  │  │  ├─ PosPrnStyleColServicePlus：打印样式列服务                                     │  │  │
│  │  │  ├─ PrintJobTypeSwitchServicePlus：打印开关服务                                   │  │  │
│  │  │  ├─ PrintJobInitUtil：内容初始化工具（模板+数据源→打印内容）                       │  │  │
│  │  │  └─ PrintUtil：打印调度统一入口                                                   │  │  │
│  │  └──────────────────────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              nms4cloud-pos3boot（本地收银服务）                         │  │
│  │  ├─ PrintJobActiveMQListener：打印任务消息监听                                        │  │
│  │  ├─ PrintInitMpScHandler：打印初始化处理器（CloseMpScHandler）                        │  │
│  │  ├─ PrintDispatchMpScHandler：打印分发处理器                                          │  │
│  │  └─ PrinterWorkerServiceOfflineImpl：离线打印服务实现（本地打印机管理）                 │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                            nms4cloud-pos4cloud（云端服务）                              │  │
│  │  └─ WmsPrintRenderService：WMS打印渲染服务                                            │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                           nms4cloud-pos10printer（独立打印服务）                        │  │
│  │  ├─ PrinterWorkerServiceLocalImpl：本地打印服务实现                                    │  │
│  │  ├─ PrinterWorker：打印机工作线程                                                     │  │
│  │  ├─ HanYinPrinter：汉印打印机驱动                                                     │  │
│  │  ├─ JBCloudPrinter：佳博云打印机                                                      │  │
│  │  ├─ JBTagPrinter：佳博标签打印机                                                      │  │
│  │  ├─ XpCloudPrinter：芯孕云打印机                                                      │  │
│  │  ├─ XYTagPrinter：心云标签打印机                                                      │  │
│  │  └─ PrinterController：打印机管理API                                                  │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 关键配置入口（UI 配置关系）

### 4.1 配置入口路径

| 配置项 | 前端入口路径 | 后端服务 | 功能说明 |
|--------|-------------|----------|----------|
| 打印机管理 | `/admin/posdev` 或打印模块专属菜单 | `nms4cloud-pos` | 添加/编辑/删除打印机，配置连接方式、型号、IP地址等 |
| 打印队列 | 管理后台打印配置页 | `nms4cloud-pos2plugin` | 配置打印队列名称、主备打印机映射 |
| 打印样式 | 管理后台打印样式配置 | `nms4cloud-pos2plugin` | 配置单据模板（行/列）、字体、对齐方式 |
| 打印开关 | 管理后台打印开关配置 | `nms4cloud-pos2plugin` | 按单据类型配置是否打印、打印张数 |
| 顾客联配置 | 管理后台结账单配置 | `nms4cloud-pos2plugin` | 按桌台/区域/桌型/PC配置顾客联打印队列 |
| 传菜联配置 | 管理后台传菜配置 | `nms4cloud-pos2plugin` | 按传菜间/出品部门配置传菜联打印队列 |

### 4.2 配置数据结构

```
配置入口 → 表名/字段名/字段类型 → 配置写入链路 → 配置生效读取链路

打印机管理
├─ pos_prn_printer(pid, mid, sid, lid, name, type, model, extra_info, ...)
├─ PrinterTypeEnum.type: TINYINT(1,2,3,...)
├─ PrinterModelEnum.model: TINYINT(1,2,3,...)
├─ extra_info: JSON(连接参数，如IP、端口、驱动路径)
└─ pc_lid: BIGINT(可选，关联终端设备)

打印队列
├─ pos_prn_queue(pid, mid, sid, lid, name, pc_lid, primary_printer, standby_printer, ...)
├─ primaryPrinter: TEXT(逗号分隔的打印机lid列表)
└─ standbyPrinter: TEXT(逗号分隔的备用打印机lid列表)

打印样式行
├─ pos_prn_style_row(pid, mid, sid, lid, ds_id, style_type, show_index, display_condition, ...)
├─ style_type: PrnStyleTypeEnum
├─ ds_id: VARCHAR(数据源ID，如store_info, bill_info, food_info)
└─ display_condition: JSON(条件表达式)

打印样式列
├─ pos_prn_style_col(pid, mid, sid, lid, style_type, row_lid, type_, customized_content, ...)
├─ style_type: PrnStyleTypeEnum
├─ row_lid: BIGINT(关联样式行)
├─ type_: PrnStyleColTypeEnum
├─ customized_content: TEXT/BLOB(内容或表达式)
└─ fontSize/align/bold: PrnStyleFontSizeEnum/PrnStypeAlignEnum/BOOLEAN

打印开关
├─ print_job_type_switch(pid, mid, sid, lid, type, disabled_kitchen, disabled_waiter, ...)
├─ type: PrnStyleTypeEnum
├─ disabledKitchen/Customer/Waiter: BOOLEAN
└─ numOfKitchen/Customer/Waiter: INT(打印张数)
```

---

## 5. 调用链全景图

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                              打印任务完整调用链                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  【业务层】业务入口                                                                           │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  DwdBillOpsForBizController.addFood()         // 点菜入口                             │  │
│  │  DwdFoodOpsServiceImpl.addFood()              // 加菜服务                              │  │
│  │  CheckOutController.normalCheckOut()           // 结账入口                             │  │
│  │  DwdFoodMakingServicePlus.finished()           // 划菜入口                             │  │
│  └─────────────────────────────┬────────────────────────────────────────────────────────┘  │
│                                │                                                              │
│  【任务生成层】PrintJobGenerator                                                              │
│  ┌─────────────────────────────▼────────────────────────────────────────────────────────┐  │
│  │  generateKitchenJob()    → 生成厨房联打印任务                                          │  │
│  │  generateCustomerJob()   → 生成顾客联打印任务                                          │  │
│  │  generateWaiterJob()     → 生成传菜联打印任务                                          │  │
│  │                                                                                         │  │
│  │  关键判断：                                                                             │  │
│  │  ├─ getNumOfKitchen/Customer/Waiter()  → 读取打印开关                                  │  │
│  │  ├─ PosCustomerBillSetting               → 顾客联队列选择                              │  │
│  │  ├─ PosWaiterBillSetting                 → 传菜联队列选择                              │  │
│  │  └─ PosDept.prnQueue                     → 厨房联队列选择（按出品部门）                 │  │
│  └─────────────────────────────┬────────────────────────────────────────────────────────┘  │
│                                │                                                              │
│  【任务持久化层】PosPrnJobServicePlus                                                        │
│  ┌─────────────────────────────▼────────────────────────────────────────────────────────┐  │
│  │  create(PosPrnJobCreateDTO)                                                               │  │
│  │  ├─ 校验字段(mid/sid/type/purpose/prnQueueLid)                                          │  │
│  │  ├─ 写入 pos_prn_job 表                                                                 │  │
│  │  ├─ 写入 .job 文件({appDir}/jobs/{yyyy-MM-dd}/{lid}.job)                              │  │
│  │  └─ 触发初始化: PrintUtil.initJob(lid)                                                 │  │
│  └─────────────────────────────┬────────────────────────────────────────────────────────┘  │
│                                │                                                              │
│  【任务分发层】PosPrnQueueServicePlus                                                        │
│  ┌─────────────────────────────▼────────────────────────────────────────────────────────┐  │
│  │  initJob(jobLid)                                                                         │  │
│  │  ├─ 从 .job 文件加载任务数据                                                            │  │
│  │  ├─ 补全模板(posPrnStyleRowServicePlus.get())                                          │  │
│  │  ├─ 内容初始化(PrintJobInitUtil.convert)                                               │  │
│  │  └─ dispatchJob(dispatchJobDTO)                                                         │  │
│  │                                                                                         │  │
│  │  dispatchJob(dispatchJobDTO)                                                            │  │
│  │  ├─ 查询队列配置(PosPrnQueueVO)                                                         │  │
│  │  ├─ 解析主/备打印机ID集合                                                               │  │
│  │  ├─ 过滤故障打印机(selectHealthyPrinters)                                               │  │
│  │  ├─ 负载均衡选择(distributePrnJob → RandomLoadBalanceUtil)                             │  │
│  │  └─ 发送至打印机: PrintUtil.handle(dispatchJobDTO)                                      │  │
│  └─────────────────────────────┬────────────────────────────────────────────────────────┘  │
│                                │                                                              │
│  【打印机执行层】PrinterWorkerService                                                        │
│  ┌─────────────────────────────▼────────────────────────────────────────────────────────┐  │
│  │  线下模式(PrinterWorkerServiceOfflineImpl)：                                           │  │
│  │  ├─ PrinterWorkerServiceOfflineImpl.handlePrnJob()                                    │  │
│  │  ├─ PrinterWorker.run() → 从队列获取任务                                               │  │
│  │  ├─ 读取 .job 文件                                                                    │  │
│  │  ├─ 渲染打印指令                                                                      │  │
│  │  ├─ 调用打印机驱动                                                                   │  │
│  │  └─ removeFromFile() → 标记完成                                                        │  │
│  │                                                                                         │  │
│  │  独立服务模式(PrinterWorkerServiceLocalImpl)：                                          │  │
│  │  ├─ PrinterWorkerServiceLocalImpl.handlePrnJob()                                      │  │
│  │  ├─ 扫描 client_jobs 目录                                                              │  │
│  │  └─ 驱动实现(XpCloudPrinter/JBCloudPrinter/HanYinPrinter 等)                           │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. 异步与事务边界

| 阶段 | 事务类型 | 异步/同步 | 说明 |
|------|----------|-----------|------|
| `PrintJobGenerator.generateXxxJob()` | 继承业务事务 | 同步 | 在业务 Service 的 `@Transactional` 方法中被调用 |
| `PosPrnJobServicePlus.create()` | `@Transactional(REQUIRED)` | 同步 | 插入数据库 + 写 .job 文件一体化 |
| `PrintUtil.initJob()` | 无 | 异步 | 通过 `JobTaskHandle` + `AbstractMpScHandler` 异步处理 |
| `PosPrnQueueServicePlus.dispatchJob()` | 无 | 异步 | 线程池执行 |
| `PrinterWorker.run()` | 无 | 异步 | 完全与请求线程解耦 |

---

## 7. 概念完整性验证

- [x] 所有枚举值与源码一致（PrnStyleTypeEnum, PrinterTypeEnum 等）
- [x] 所有实体字段与源码一致（PosPrnPrinter, PosPrnQueue, PosPrnJob 等）
- [x] 调用链与文档一致（docs/print/打印系统总览.md）
- [x] 模块职责划分正确（pos2plugin 核心、pos3boot 本地、pos10printer 独立服务）
- [x] 静态关系与动态关系分类正确
- [x] UI 配置关系有源码证据

---

## 8. 待深入分析项

| 序号 | 分析项 | 对应 DA | 说明 |
|------|--------|---------|------|
| 1 | 打印内容初始化与模板数据源 | DA6 | `PrintJobInitUtil.convert()` 详细逻辑 |
| 2 | 打印条件与行过滤 | DA6 | `ConditionUtil.isRowVisible()` 与行级条件 |
| 3 | 核心业务流程分析 | DA3-DA4 | 点餐、结账、划菜的完整流程 |
| 4 | 数据模型详细分析 | DA5 | 所有表的字段、索引、外键关系 |
| 5 | WMS 打印对接 | 待定 | WMS 打印单据类型与 POS 打印的关联 |

---

**文档状态**：DA0-DA1 完成  
**下一步**：DA3-DA4 核心业务流程分析
