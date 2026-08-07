# DA1 侦察报告
# 打印系统模块结构全景扫描

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA1-PRINT-001 |
| 侦察时间 | 2026/08/03 |
| 状态 | 进行中 |
| 参考契约 | DA0-G0-A, DA0-G0-B |

---

## 1. 仓库扫描结果

### 1.1 仓库清单

| 序号 | 仓库名称 | 路径 | 打印模块 | 角色定位 |
|------|----------|------|----------|----------|
| 1 | nms4pos | D:\mywork\nms4pos | pos2plugin, pos10printer | 后端核心 |
| 2 | nms4cloud | D:\mywork\nms4cloud | pos2plugin | 后端API层 |
| 3 | nms4cloud-biz-ui | D:\mywork\nms4cloud-biz-ui | PrintMgr | 管理后台前端 |
| 4 | nms4pos-ui | D:\mywork\nms4pos-ui | PrintTaskMonitor | POS前端 |

### 1.2 pos2plugin 模块结构（核心模块）

```
nms4cloud-pos2plugin/
│
├── nms4cloud-pos2plugin-api/           # API定义层
│   └── src/main/java/com/nms4cloud/pos2plugin/api/
│       ├── admin/
│       │   ├── pos_prn_printer/        # 打印机管理API
│       │   │   ├── dto/
│       │   │   └── vo/
│       │   ├── pos_prn_queue/          # 打印队列API
│       │   │   ├── dto/
│       │   │   └── vo/
│       │   ├── pos_prn_style_row/      # 打印样式API
│       │   │   ├── dto/
│       │   │   └── vo/
│       │   ├── pos_dept/               # 出品部门API
│       │   │   ├── dto/
│       │   │   └── vo/
│       │   ├── pos_dept_dish/          # 部门菜品关联API
│       │   │   ├── dto/
│       │   │   └── vo/
│       │   └── print_job_type_switch/  # 打印开关API
│       │       ├── dto/
│       │       └── vo/
│       │
│       └── dto/
│           └── DispatchJobDTO.java     # 任务分发DTO
│
├── nms4cloud-pos2plugin-biz/           # 业务实现层
│   └── src/main/java/
│       │
│       ├── com/nms4cloud/pos2plugin/   # 业务服务
│       │   └── service/print/
│       │       ├── PrintJobGenerator.java      # ⭐ 核心：多联票生成
│       │       ├── PrintJobInitUtil.java       # 任务初始化工具
│       │       ├── PrinterWorkerService.java   # 打印机工作线程管理
│       │       ├── ConditionUtil.java          # 条件判断工具
│       │       ├── EscPosRenderService.java    # ESC/POS渲染服务
│       │       ├── CookwayPrintDeptPlanner.java # 做法出品部门规划
│       │       ├── CustomerBillSettingSelector.java # 客单设置选择器
│       │       ├── FoodLabelPrintJobCreator.java  # 标签打印任务创建
│       │       ├── SmsJobGenerator.java        # 短信任务生成
│       │       ├── XPYunService.java           # 芯烨云打印服务
│       │       └── JBTagService.java           # 佳博标签打印服务
│       │
│       └── com/lemontree/framework/     # 框架层
│           └── print/
│               ├── jobHandlers/         # ⭐ 打印处理器实现
│               │   ├── PrintJobHandlerBase.java      # 基类
│               │   ├── DriverHandler.java             # Windows驱动打印
│               │   ├── PortHandler.java               # 串口/并口打印
│               │   ├── PortHandlerWithDriver.java     # 驱动+指令混合
│               │   ├── UsbLptHandler.java             # USB打印
│               │   ├── XpCloudPrinter.java            # 芯烨云打印
│               │   ├── JBCloudPrinter.java            # 佳博云打印
│               │   ├── JBTagPrinter.java               # 佳博标签打印
│               │   ├── XYTagPrinter.java              # 芯烨标签打印
│               │   ├── HanYinPrinter.java              # 汉印打印机
│               │   ├── HanYinPrinterDll.java          # 汉印DLL封装
│               │   ├── HanYinConstants.java           # 汉印指令常量
│               │   ├── GraphicsHandler.java           # 图形渲染
│               │   ├── ReceiptImageRenderer.java       # 小票图像渲染
│               │   ├── EscPosImageEncoder.java        # ESC/POS图像编码
│               │   ├── PortImagePrintPlan.java        # 图像打印计划
│               │   ├── PortImagePrintSupport.java     # 图像打印支持
│               │   ├── InputStreamAdp.java            # 流适配器
│               │   ├── OtherPcHandler.java            # 远程PC打印
│               │   ├── UsbPrinterDiscovery.java       # USB打印机发现
│               │   ├── WindowsDeviceRefresher.java    # Windows设备刷新
│               │   └── PngJpgImagePerTest.java        # PNG/JPG测试
│               │
│               └── printers/               # 打印机抽象
│                   └── PrintJobMonitor.java  # 打印任务监控
│
└── pom.xml
```

### 1.3 前端模块结构

```
nms4cloud-biz-ui/
└── src/
    ├── api/pos2plugin/                    # pos2plugin API
    │   ├── enums/
    │   │   ├── PrinterModelEnum.ts        # 打印机型号枚举
    │   │   ├── PrinterTypeEnum.ts         # 连接方式枚举
    │   │   └── PrnStyleTypeEnum.ts        # 票据类型枚举
    │   ├── services/
    │   │   ├── PosPrnPrinterService.ts    # 打印机服务
    │   │   └── PrintJobTypeSwitchService.ts # 打印开关服务
    │   └── typings/
    │       ├── IPosPrnPrinter.ts          # 打印机接口
    │       └── IPrintJobTypeSwitch.ts      # 打印开关接口
    │
    ├── pages/
    │   └── PrintMgr/                      # ⭐ 打印管理主页面
    │       ├── index.tsx                   # 主页面
    │       ├── CopyStyleModal.tsx          # 样式复制弹窗
    │       ├── components/
    │       │   └── DishOverSet/            # 菜品超时设置
    │       └── icon/                       # 图标资源
    │
    └── components/antd/src/pages/
        ├── PosPrnPrinterPage.tsx          # 打印机管理组件
        ├── PosPrnQueuePage.tsx             # 打印队列组件
        ├── PosPrnStyleRowPage.tsx          # 打印样式编辑
        ├── PosDeptPage.tsx                 # 部门管理
        ├── PosDeptAndDishPage.tsx          # 部门菜品关联
        ├── PosCustomerBillSettingPage.tsx   # 客单设置
        ├── PosWaiterBillSettingPage.tsx     # 传菜间设置
        ├── PrintJobTypeSwitchPage.tsx      # 打印开关设置
        └── PosDevPage.tsx                  # 设备管理
```

---

## 2. 核心数据流扫描

### 2.1 打印任务数据流

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          打印任务数据流                                   │
└─────────────────────────────────────────────────────────────────────────┘

  业务事件触发
        │
        ▼
┌─────────────────┐
│ DwdBill/业务服务  │  ← 点菜、结账、退菜等业务事件
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ PrintJobGenerator│  ← ⭐ 核心：生成多种联票
├─────────────────┤
│ generateCustomerJob()
│ generateKitchenJob()
│ generateWaiterJob()
│ generateFoodLabelJob()
└────────┬────────┘
         │
         ├──────────────────────────────────┐
         │                                  │
         ▼                                  ▼
┌─────────────────┐              ┌─────────────────┐
│ 顾客联打印任务    │              │ 厨房联打印任务    │
│ Prn_PrintJob    │              │ Prn_PrintJob    │
│ type=CheckOut   │              │ type=OrderMenu  │
└────────┬────────┘              └────────┬────────┘
         │                                 │
         │                          ┌──────┴──────┐
         │                          ▼             ▼
         │                   ┌──────────┐  ┌──────────┐
         │                   │ 出品部门1 │  │ 出品部门2│
         │                   │ 队列A     │  │ 队列B    │
         │                   └─────┬────┘  └─────┬────┘
         │                         │             │
         ▼                         ▼             ▼
┌─────────────────┐         ┌─────────────────────────────┐
│ PosPrnQueue     │         │ PrinterWorkerService         │
│ 打印队列         │         │ 打印机工作线程               │
│ (路由分发中心)   │         ├─────────────────────────────┤
├─────────────────┤         │ worker1 → PrinterHandler1   │
│ queueId         │         │ worker2 → PrinterHandler2   │
│ printerLid      │         │ worker3 → PrinterHandler3   │
│ styleType       │         └──────────────┬──────────────┘
│ deptLid         │                        │
└────────┬────────┘                        ▼
         │                        ┌─────────────────┐
         │                        │ PrintJobHandler  │
         │                        │ (具体处理器)     │
         │                        ├─────────────────┤
         │                        │ DriverHandler   │  ← Windows驱动
         │                        │ PortHandler     │  ← 串口/并口
         │                        │ XpCloudPrinter  │  ← 芯烨云
         │                        │ JBCloudPrinter │  ← 佳博云
         │                        └────────┬────────┘
         │                                 │
         ▼                                 ▼
┌─────────────────┐              ┌─────────────────┐
│ Prn_StyleRow    │              │   物理打印机     │
│ 打印样式配置     │              │   EP-58C/汉印80 │
├─────────────────┤              └─────────────────┘
│ name: 结账单样式 │
│ type: CheckOut  │
│ contents: [...] │
└─────────────────┘
```

### 2.2 核心类依赖关系

```
PrintJobGenerator.java (1127行)
  │
  ├── 依赖输入
  │   ├── DwdBillContext       # 结账上下文
  │   ├── PosPrnQueue          # 打印队列
  │   ├── PosPrnPrinter        # 打印机
  │   ├── PosPrnStyleRow       # 打印样式
  │   ├── PosDept              # 出品部门
  │   └── PrintJobTypeSwitch   # 打印开关
  │
  ├── 核心方法
  │   ├── generateCustomerJob()    # 生成顾客联
  │   ├── generateKitchenJob()     # 生成厨房联
  │   ├── generateWaiterJob()      # 生成传菜联
  │   ├── generateFoodLabelJob()   # 生成标签单
  │   └── dispatchJob()            # 分发任务
  │
  └── 产出
      └── List<Prn_PrintJob>   # 打印任务列表


PrinterWorkerService.java (接口)
  │
  ├── addPrinterWorker(Long printerLid)      # 添加打印机
  ├── removePrinterWorker(Long printerLid)  # 移除打印机
  ├── handlePrnJob(DispatchJobDTO job)       # 处理任务
  ├── getStatus(Long printerLid)             # 获取状态
  └── restart()                              # 重启


PrintJobHandlerBase.java (基类)
  │
  ├── 参数处理
  │   ├── replaceStrWithParas()     # 参数替换
  │   ├── getStrValue()              # 值转字符串
  │   └── getParasInStr()           # 提取参数
  │
  ├── 条件判断
  │   └── isConditionOk()           # 条件是否满足
  │
  ├── 渲染方法（抽象）
  │   ├── handleText()              # 文本
  │   ├── handleSqlQuery()          # SQL查询
  │   ├── handleLine()              # 分割线
  │   ├── handleCutPaper()          # 切纸
  │   ├── handleBlankLine()         # 空白行
  │   └── handleImg()               # 图片
  │
  └── 打印机适配
      ├── getBrand()                # 获取品牌
      ├── getType()                 # 获取类型
      ├── getComName()              # 串口名
      ├── getBaudRate()             # 波特率
      └── getPhysicsName()          # 物理名
```

---

## 3. 枚举值全景图

### 3.1 PrnStyleTypeEnum（票据类型）- 73种

| 分类 | 票据类型 | 代码 | 说明 |
|------|----------|------|------|
| **后厨票据** | OrderMenu | 10 | 点菜单 |
| | OrderMenuEx | 11 | 点菜单(多食) |
| | OldOrderMenu | 12 | 重打点菜单 |
| | OldOrderMenuEx | 13 | 重打点菜单(多食) |
| | TotalBill | 14 | 划菜总单 |
| | TotalBillLocal | 15 | 点菜总单 |
| | ReplaceItem | 16 | 换品单 |
| | TransferTable | 17 | 转台单 |
| | TransferMenu | 18 | 菜品转台单 |
| | HurryMenu | 19 | 催菜单 |
| | BackMenu | 20 | 退菜单 |
| | RespiteMenu | 21 | 叫起单 |
| | UpMenu | 22 | 起菜单 |
| | ChangeMenuAmout | 23 | 数量变更单 |
| | GQBill | 28 | 菜品沽清单 |
| **收银票据** | Nodiscount | 24 | 结算单 |
| | Discount | 25 | 撤销结算单 |
| | CheckOut | 26 | 结账单 |
| | CheckOutFull | 27 | 结账单(不含明细) |
| | CashboxPop | 60 | 弹出钱箱 |
| **报表票据** | ShiftReport | 29 | 交班单 |
| | ReturnDetailsReport | 30 | 退菜明细报表 |
| | ShiftReport_SRY | 31 | 交班表(按收银人) |
| | DateSalesReport | 32 | 每日销售报表 |
| | DaiDingRenReport | 33 | 代订人统计报表 |
| | YingYeReport | 34 | 营业报表 |
| | BuMenReport | 35 | 部门销售报表 |
| | HourSalesReport | 36 | 分时销售报表 |
| | CaiSalesReport | 37 | 菜品销售报表 |
| | BookSum | 38 | 菜品预订汇总 |
| **会员与短信** | MemberSavingBill | 39 | 会员卡充值 |
| | TuiKaDan | 40 | 会员卡退卡 |
| | HYXFMX | 46 | 会员消费明细 |
| | HYFPMX | 47 | 会员发票明细 |
| | MemberFaKaMingXi | 48 | 会员发卡明细 |
| | MemberTuiKaMingXi | 49 | 会员退卡明细 |
| | MemberBirthday | 50 | 会员生日查询 |
| | MemberGift | 51 | 会员礼品兑换 |
| | SMS_CRM_REG | 61 | 会员登记成功短信 |
| | SMS_CRM_CONSUME | 62 | 消费短信 |
| | SMS_POS_RECHECK_OUT | 63 | 反结账短信 |
| | SMS_CRM_POINT_CHANGE | 64 | 积分兑换短信 |
| | SMS_BOOK_SUCCESS | 65 | 预定成功短信 |
| | SMS_BOOK_CANCEL | 66 | 预定取消短信 |
| | SMS_BOOK_OVERTIME | 67 | 预定过期短信 |
| | SMS_QUEUE | 68 | 排队叫号短信 |
| | SMS_SAVE_WINE_OVERTIME | 69 | 存酒到期短信 |
| | SMS_SAVE_WINE | 70 | 存酒短信 |
| | SMS_PICK_WINE | 71 | 取酒短信 |
| | SMS_CRM_RECHARGE | 72 | 充值成功短信 |
| | SMS_CREDIT_WINE | 73 | 挂账回款短信 |
| **其他票据** | OrderBill | 41 | 预定单 |
| | QueueBill | 42 | 排队单 |
| | ReturnBill | 43 | 挂账回款单 |
| | XfdInfoBill | 44 | 消费单信息 |
| | XfcpInfoBill | 45 | 消费菜品信息 |
| | FoodLabel | 52 | 菜品标签明细 |
| | JFDHCZ | 53 | 积分换储值 |
| | CunJiuDan | 54 | 存酒单 |
| | MultiCunJiuDan | 55 | 多菜品存酒单 |
| | MultiBackWineDan | 56 | 多菜品存酒单 |
| | QuJiuDan | 57 | 取酒单 |
| | MultiQuJiuDan | 58 | 多菜品取酒单 |
| | OrderBillManagement | 59 | 预定管理单 |
| **WMS票据** | WMS_STORE_ORDER | 1000 | 门店订货单 |
| | WMS_ST_BILL_* | 1001-1045 | 49种WMS票据 |
| | WMS_RDC_ORDER | 1046 | 配送中心订货单 |
| | WMS_ST_CHECK_BILL | 1047 | 盘点单据 |
| | WMS_ST_CONVERT_BILL | 1048 | 转货单 |

### 3.2 PrinterTypeEnum（连接方式）- 8种

| 代码 | 类型 | 说明 | 处理器 |
|------|------|------|--------|
| 1 | DRIVER | 驱动打印机 | DriverHandler |
| 2 | NET | 网口指令打印机 | PortHandler (OPOS_NET) |
| 3 | COM | 串口指令打印机 | PortHandler (OPOS_LPT) |
| 4 | USB | U口指令打印机 | UsbLptHandler |
| 5 | LPT | 并口指令打印机 | PortHandler (OPOS_LPT) |
| 6 | XY_CLOUD | 芯烨云打印机 | XpCloudPrinter |
| 7 | JB_CLOUD | 佳博云打印机 | JBCloudPrinter |
| 8 | DRIVER_CMD | 驱动指令打印机 | PortHandlerWithDriver |

### 3.3 PrinterModelEnum（打印机型号）- 17种

| 代码 | 型号 | 品牌 | 类型 |
|------|------|------|------|
| 1 | GP_R320C | GP | 热敏 |
| 2 | EPSON_TM_220B | EPSON | 热敏 |
| 3 | EPSON_T_T81 | EPSON | 热敏 |
| 4 | BTP_98NP | BTP | 针式 |
| 5 | STAR_TSP700 | STAR | 热敏 |
| 6 | STAR_SP700 | STAR | 热敏 |
| 7 | STAR_TCP400 | STAR | 热敏 |
| 8 | XP_80X | XP | 热敏 |
| 9 | XP_76X | XP | 热敏 |
| 10 | XP_58X | XP | 热敏 |
| 11 | EPSON_TM_88IV | EPSON | 热敏 |
| 12 | EPSON_T_T58 | EPSON | 热敏 |
| 13 | HS_80 | HS | 热敏 |
| 14 | GP_3150TFN | GP | 标签打印机 |
| 15 | XP_T202UA | XP | 标签打印机 |
| 16 | HY58 | 汉印 | 热敏 |
| 17 | HY80 | 汉印 | 热敏 |

---

## 4. 前端管理界面模块

### 4.1 PrintMgr 菜单结构

```
PrintMgr (打印管理)
│
├── 分组1: 基础配置
│   ├── 计算机 (PosDevPage, type=WINDOWS_PC)
│   │   └── 管理终端设备
│   ├── 打印机 (PosPrnPrinterPage)
│   │   └── 打印机型号、连接方式、IP配置
│   ├── 打印开关 (PrintJobTypeSwitchPage)
│   │   └── 控制各联票是否打印、打印份数
│   └── 打印队列 (PosPrnQueuePage)
│       └── 队列名称、关联打印机、出品部门
│
├── 分组3: 业务关联
│   ├── 出品部门 (PosDeptAndDishPage, type=FOR_PRN)
│   │   └── 一菜一单模式，关联打印机
│   ├── 传菜间 (PosWaiterBillSettingPage)
│   │   └── 多菜一单模式，传菜联配置
│   └── 客单设置 (PosCustomerBillSettingPage)
│       └── 顾客联样式设置
│
├── 分组4: KDS配合
│   ├── 利润部门 (PosDeptPage, type=FOR_PROFIT)
│   │   └── 利润中心
│   ├── 配菜间 (PosDeptAndDishPage, type=FOR_PREPARATION)
│   ├── 制作间 (PosDeptAndDishPage, type=FOR_COOK)
│   └── 菜品超时 (DishOverSet) [仅localhost]
│       └── KDS超时提醒设置
│
└── 票据样式设置（右侧面板）
    ├── 收银票据 (6种): 结算/结账/钱箱
    ├── 后厨票据 (17种): 点菜/催菜/退菜/转台
    ├── 报表票据 (10种): 交班/销售/分时
    ├── 会员与短信 (18种): 充值/退卡/短信
    ├── 其他票据 (16种): 预定/排队/存酒
    └── WMS票据 (49种): 采购/盘点/调拨
```

### 4.2 PrintMgr 样式分组配置

```typescript
const STYLE_GROUPS = [
  {
    key: 'cashier',
    title: '收银票据',
    subtitle: '顾客结账、客单与现金操作相关样式',
    types: ['Nodiscount', 'Discount', 'CheckOut', 'CheckOutFull', 'CashboxPop'],
  },
  {
    key: 'kitchen',
    title: '后厨票据',
    subtitle: '出品、传菜、换品、催退起叫等厨房流程样式',
    types: ['OrderMenu', 'OrderMenuEx', 'OldOrderMenu', 'OldOrderMenuEx',
            'TotalBill', 'TotalBillLocal', 'ReplaceItem', 'TransferTable',
            'TransferMenu', 'HurryMenu', 'BackMenu', 'RespiteMenu',
            'UpMenu', 'ChangeMenuAmout', 'GQBill'],
  },
  {
    key: 'report',
    title: '报表票据',
    subtitle: '交班、营业、部门、分时与销售分析输出',
    types: ['ShiftReport', 'ReturnDetailsReport', 'ShiftReport_SRY',
            'DateSalesReport', 'DaiDingRenReport', 'YingYeReport',
            'BuMenReport', 'HourSalesReport', 'CaiSalesReport', 'BookSum'],
  },
  {
    key: 'member',
    title: '会员与短信',
    subtitle: '会员交易、发退卡、生日及短信通知样式',
    types: ['MemberSavingBill', 'TuiKaDan', 'HYXFMX', 'HYFPMX',
            'MemberFaKaMingXi', 'MemberTuiKaMingXi', 'MemberBirthday',
            'MemberGift', 'SMS_*'],
  },
  {
    key: 'other',
    title: '其他票据',
    subtitle: '预定、排队、回款、标签及酒水相关样式',
    types: ['OrderBill', 'QueueBill', 'ReturnBill', 'XfdInfoBill',
            'XfcpInfoBill', 'FoodLabel', 'JFDHCZ', 'CunJiuDan',
            'MultiCunJiuDan', 'MultiBackWineDan', 'QuJiuDan',
            'MultiQuJiuDan', 'OrderBillManagement'],
  },
  {
    key: 'wms',
    title: 'WMS 票据样式',
    subtitle: '仓库、订货、盘点、转货等供应链票据统一分组',
    types: ['WMS_*'],  // 49种WMS票据
  },
];
```

---

## 5. 服务接口清单

### 5.1 后端API（pos2plugin-api）

| 服务类 | 主要方法 | 用途 |
|--------|----------|------|
| PosPrnPrinterService | CRUD | 打印机管理 |
| PosPrnQueueService | CRUD + bind/unbind | 打印队列管理 |
| PosPrnStyleRowService | CRUD + copy | 打印样式管理 |
| PosDeptService | CRUD | 出品部门管理 |
| PosDeptDishService | CRUD | 部门菜品关联 |
| PrintJobTypeSwitchService | CRUD + copy | 打印开关配置 |

### 5.2 后端服务（pos2plugin-biz）

| 服务类 | 主要方法 | 用途 |
|--------|----------|------|
| PrintJobGenerator | generateXxxJob(), dispatchJob() | 多联票生成 |
| PrinterWorkerService | handlePrnJob(), getStatus(), restart() | 打印执行 |
| ConditionUtil | evaluate() | 条件表达式求值 |
| EscPosRenderService | render() | ESC/POS渲染 |
| CookwayPrintDeptPlanner | plan() | 做法部门规划 |
| FoodLabelPrintJobCreator | create() | 标签打印创建 |
| SmsJobGenerator | generate() | 短信任务生成 |
| XPYunService | print() | 芯烨云打印 |
| JBTagService | print() | 佳博标签打印 |

---

## 6. 初步发现

### 6.1 架构亮点

1. **多联票解耦设计**：顾客联/厨房联/传菜联由独立方法生成，便于灵活配置
2. **打印机多态适配**：通过Handler模式支持17种型号、8种连接方式
3. **打印样式模板化**：73种票据类型独立配置，互不干扰
4. **出品部门路由**：按部门分发打印，实现厨房自动分单

### 6.2 待深入分析

1. **pos10printer状态**：需要确认是否已废弃
2. **任务状态机**：需要确认打印任务的生命周期状态
3. **异常恢复机制**：需要分析故障时的处理策略
4. **样式渲染引擎**：需要深入理解参数替换和条件判断逻辑

---

**DA1 状态：✅ 侦察完成，可进入DA2概念建模阶段**
