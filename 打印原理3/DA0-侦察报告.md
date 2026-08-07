# DA0 - 侦察报告：打印功能代码分布

> **分析范围**：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui
> **分析目标**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 项目结构与代码分布

### 1.1 后端项目（Java/Spring Boot）

| 项目 | 模块 | 职责定位 |
|------|------|----------|
| **nms4pos** | `pos2plugin` | 核心打印业务逻辑 |
| | `pos3boot` | 本地收银打印服务 |
| | `pos4cloud` | 云端打印服务 |
| | `pos10printer` | 独立打印服务 |

#### 核心代码文件分布

**打印任务生成层**
```
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/print/
├── PrintJobGenerator.java          # 任务生成器（顾客联/厨房联/传菜联）
├── EscPosRenderService.java        # ESC/POS指令渲染
├── FoodLabelPrintJobCreator.java   # 菜品标签打印
├── SmsJobGenerator.java            # 短信任务生成
└── PrintJobInitUtil.java           # 内容初始化工具
```

**打印任务持久化层**
```
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/
├── PosPrnJobServicePlus.java       # 打印任务持久化服务
└── PosPrnQueueServicePlus.java     # 打印队列管理服务
```

**打印样式配置层**
```
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/
├── PosPrnStyleRowServicePlus.java # 打印样式行服务
├── PosPrnPrinterServicePlus.java  # 打印机管理服务
└── PosPrnPrinterTransferServicePlus.java  # 打印机转移服务
```

**打印机执行层**
```
nms4pos/nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/print/
├── PrinterWorker.java              # 打印机工作线程
└── PrinterWorkerServiceOfflineImpl.java  # 线下模式实现

nms4pos/nms4cloud-pos10printer/nms4cloud-pos10printer-app/src/main/java/com/nms4cloud/pos10printer/app/print/
├── PrinterWorker.java              # 独立打印服务Worker
├── PortHandler.java                # 串口通信基类
├── PortHandlerWithDriver.java      # 驱动打印
├── XpCloudPrinter.java             # 芯烨云打印
├── JBCloudPrinter.java             # 佳博云打印
└── HanYinPrinter.java              # 汉印打印
```

**云端打印服务**
```
nms4pos/nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/src/main/java/com/nms4cloud/pos4cloud/
├── service/print/WmsPrintRenderService.java   # WMS打印渲染
└── service/pirnt/PrinterWorkerServiceOnlineImpl.java  # 云端Worker实现
```

**枚举与常量**
```
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/
├── enums/
│   ├── PrnStyleTypeEnum.java       # 打印样式类型（70+种）
│   ├── PrinterTypeEnum.java        # 打印机类型
│   ├── PrinterModelEnum.java       # 打印机型号
│   ├── PrinterStatus.java          # 打印机状态
│   ├── PrnJobPurposeEnum.java      # 打印任务用途
│   └── PrnJobStatusEnum.java       # 打印任务状态
└── admin/pos_prn_job/vo/PosPrnJobVO.java
```

**数据实体层**
```
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/
├── PosPrnPrinter.java              # 打印机实体
├── PosPrnStyleRow.java             # 打印样式行实体
├── PosPrnQueue.java                # 打印队列实体
└── PosPrnJob.java                  # 打印任务实体
```

### 1.2 前端项目（React/TypeScript）

| 项目 | 职责定位 |
|------|----------|
| **nms4pos-ui** | POS收银前端 |
| **nms4cloud-biz-ui** | SaaS后台打印管理 |

#### 前端代码文件分布

**SaaS后台打印管理（nms4cloud-biz-ui）**
```
nms4cloud-biz-ui/src/pages/PrintMgr/
├── index.tsx                       # 打印管理主页面
├── PrintTaskMonitor/               # 打印任务监控
│   ├── index.tsx
│   ├── PrintTaskMonitor.tsx
│   ├── PrintTaskMonitor.less
│   ├── PrintTaskMonitorModal.tsx
│   └── PrintTaskMonitorModal.less
├── PosPrnStyleRowPage/             # 打印样式配置
│   ├── index.tsx
│   ├── PosPrnStyleRowPage.tsx
│   ├── PosPrnStyleRowPage.less
│   ├── PrintTemplateModal.tsx
│   └── PrintTemplateModal.less
└── PrintQueuePage/                 # 打印队列配置
    ├── index.tsx
    └── PrintQueuePage.tsx

nms4cloud-biz-ui/src/pages/DevMgr/
└── components/PosPrnPrinter/       # 打印机管理
    ├── index.tsx
    ├── PosPrnPrinter.tsx
    └── PosPrnPrinter.less
```

**POS收银前端（nms4pos-ui）**
```
nms4pos-ui/app/pos4desktop/src/pages/
├── FunctionPanel/pages/BillDetail/  # 小票打印预览
└── SecondScreen/                    # 副屏展示
```

**共享类型定义**
```
nms4cloud-biz-ui/src/pos/interfaces/
├── IPosPrnPrinter.ts               # 打印机接口
├── IPosPrnQueue.ts                 # 打印队列接口
├── IPosPrnStyleRow.ts              # 打印样式行接口
└── IPosPrnJob.ts                   # 打印任务接口
```

---

## 2. 打印类型分布（PrnStyleTypeEnum）

### 2.1 POS业务票据（10-73）

| 类型码 | 枚举名 | 说明 |
|--------|--------|------|
| 10 | OrderMenu | 点菜单 |
| 11 | OrderMenuEx | 点菜单（多做法） |
| 12 | KitchenBill | 厨房联 |
| 13 | KitchenBillEx | 厨房联（多做法） |
| 14 | WaiterBill | 传菜联 |
| 20 | PreCheck | 预结单 |
| 26 | CheckOut | 结账单 |
| 30 | CancelBill | 退菜单 |
| 31 | UrgeBill | 催菜单 |
| 40 | ShiftReport | 交班报表 |
| 41 | DayReport | 日报表 |
| 50 | MemberCardRecharge | 会员卡充值小票 |
| 60 | CashboxPop | 弹钱箱 |
| 70 | FoodLabel | 菜品标签 |

### 2.2 WMS业务票据（1000-1048）

| 类型码 | 枚举名 | 说明 |
|--------|--------|------|
| 1000 | WMS_STORE_ORDER | WMS-门店订货单 |
| 1010 | WMS_STORE_INBOUND | WMS-门店入库单 |
| 1020 | WMS_STORE_OUTBOUND | WMS-门店出库单 |

---

## 3. 打印机类型分布（PrinterTypeEnum）

| 类型 | 枚举名 | 说明 |
|------|--------|------|
| DRIVER | 驱动打印 | Windows驱动方式 |
| DRIVER_CMD | 驱动命令 | 通过驱动发送ESC/POS命令 |
| NET | 网络打印 | TCP/IP网络打印机 |
| COM | 串口打印 | RS232串口通信 |
| USB | USB打印 | USB接口打印机 |
| LPT | 并口打印 | 并口打印机 |
| XY_CLOUD | 芯烨云 | 芯烨云打印服务 |
| JB_CLOUD | 佳博云 | 佳博云打印服务 |

---

## 4. 核心技术架构

### 4.1 打印流程四层架构

```
┌─────────────────────────────────────────────────────────────────┐
│  业务层（Business Layer）                                         │
│  DwdBillOpsService / CheckOutService / DwdFoodMakingService     │
│  调用 PrintJobGenerator 生成打印任务                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  任务层（Job Layer）                                             │
│  PosPrnJobServicePlus                                           │
│  持久化到 pos_prn_job 表 + 本地 .job 文件                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  队列层（Queue Layer）                                           │
│  PosPrnQueueServicePlus                                         │
│  模板初始化 + 队列分发到打印机                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  执行层（Worker Layer）                                           │
│  PrinterWorker / PrinterWorkerServiceOfflineImpl                 │
│  读取 .job 文件，执行实际打印                                     │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 离线/云端双模式

| 模式 | 实现类 | 服务位置 |
|------|--------|----------|
| 线下本地 | `PrinterWorkerServiceOfflineImpl` | pos3boot |
| 云端 | `PrinterWorkerServiceOnlineImpl` | pos4cloud |
| 独立打印 | `PrinterWorkerServiceLocalImpl` | pos10printer |

---

## 5. 关键配置文件

### 5.1 后端配置

| 配置类 | 位置 | 说明 |
|--------|------|------|
| PrintOfflineConfiguration | pos3boot | 线下打印配置 |
| PrintOnlineConfiguration | pos4cloud | 云端打印配置 |

### 5.2 前端路由

| 路径 | 组件 | 说明 |
|------|------|------|
| `/admin/prnmrg` | PrintMgr | 打印管理主页面 |
| `/admin/operationalinfomrg/posdev` | DevMgr/PosPrnPrinter | 打印机管理 |

---

## 6. 文档资源

| 文档 | 位置 | 说明 |
|------|------|------|
| 打印系统总览 | nms4pos/docs/print/ | 研发版架构说明 |
| 打印任务创建与队列分发 | nms4pos/docs/print/ | 详细调用链 |
| 打印问题排查指南 | nms4pos/docs/print/ | 操作性排查清单 |
| 打印模板JSON字段说明 | nms4pos/docs/print/ | 模板格式定义 |
| 前端打印预览组件设计 | nms4pos/docs/print/ | 前端组件设计 |

---

## 7. 依赖关系

### 7.1 后端依赖

```
pos2plugin-api          # 基础枚举和接口
    ↓
pos2plugin-biz          # 核心打印逻辑
    ↓
pos3boot-biz            # 线下打印Worker
pos4cloud-biz            # 云端打印Worker
pos10printer-app        # 独立打印服务
```

### 7.2 前端依赖

```
@nms/share              # 共享类型定义
    ↓
nms4cloud-biz-ui        # SaaS后台打印管理
nms4pos-ui              # POS收银前端
```

---

*文档版本：v1.0 | 生成时间：2026-08-03*
