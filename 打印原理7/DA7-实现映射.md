# DA7 实现映射 — 打印子系统

## 核心类映射

### 打印机管理

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 打印机实体 | `PosPrnPrinter` | nms4pos-pos2plugin-dal | — | E-SRC: PosPrnPrinter.java |
| 打印机服务 | `PosPrnPrinterServicePlus` | nms4pos-pos2plugin-biz | add/update/get/list | E-SRC: PosPrnPrinterServicePlus.java |
| 打印机Controller | `PosPrnPrinterController` | nms4pos-pos2plugin-biz | add/update/list/delete | E-SRC: PosPrnPrinterController.java |
| 打印机Controller(商户) | `PosPrinterForBizController` | nms4cloud-pos-biz | add/update/list/activate | E-SRC: PosPrinterForBizController.java |
| 打印机状态 | `PrinterStatus` | nms4pos-pos2plugin-api | 枚举: DEFAULT/FAULT/NORMAL/BUSY | E-SRC: PrinterStatus.java |
| 打印机类型 | `PrinterTypeEnum` | nms4pos-pos2plugin-api | 8种连接类型 | E-SRC: PrinterTypeEnum.java |
| 打印机型号 | `PrinterModelEnum` | nms4pos-pos2plugin-api | 18+种型号 | E-SRC: PrinterModelEnum.java |
| 打印机转换器 | `PosPrnPrinterConvert` | nms4pos-pos2plugin-dal | DTO/Entity/VO互转 | E-SRC: PosPrnPrinterConvert.java |
| 打印机Mapper | `PosPrnPrinterMapper` | nms4pos-pos2plugin-dal | 数据库操作 | E-SRC: PosPrnPrinterMapper.java |

### 打印队列管理

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 队列实体 | `PosPrnQueue` | nms4pos-pos2plugin-dal | — | E-SRC: PosPrnQueue.java |
| 队列服务 | `PosPrnQueueServicePlus` | nms4pos-pos2plugin-biz | add/update/get/list, initJob, dispatchJob | E-SRC: PosPrnQueueServicePlus.java |
| 队列VO | `PosPrnQueueVO` | nms4pos-pos2plugin-api | parsePrimaryPrinters, parseStandbyPrinters | E-SRC: PosPrnQueueVO.java |
| 队列Controller | `PosPrnQueueController` | nms4pos-pos2plugin-biz | add/update/list/delete | E-SRC: PosPrnQueueController.java |

### 打印任务管理

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 任务实体 | `PosPrnJob` | nms4pos-pos2plugin-dal | — | E-SRC: PosPrnJob.java |
| 任务服务 | `PosPrnJobServicePlus` | nms4pos-pos2plugin-biz | create, keepToFile, getFromFile, removeFromFile | E-SRC: PosPrnJobServicePlus.java |
| 任务生成器 | `PrintJobGenerator` | nms4pos-pos2plugin-biz | generateCustomerJob, generateKitchenJob, generateWaiterJob, generateJob | E-SRC: PrintJobGenerator.java |
| 任务用途枚举 | `PrnJobPurposeEnum` | nms4pos-pos2plugin-api | FOR_KITCHEN, FOR_DISH_DELIVERER, FOR_CUSTOMER | E-SRC: PrnJobPurposeEnum.java |
| 任务Controller | `PosPrnJobController` | nms4pos-pos2plugin-biz | add/list/reprint | E-SRC: PosPrnJobController.java |

### 打印样式管理

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 样式行实体 | `PosPrnStyleRow` | nms4pos-pos2plugin-dal | — | E-SRC: PosPrnStyleRow.java |
| 样式列实体 | `PosPrnStyleCol` | nms4pos-pos2plugin-dal | — | E-SRC: PosPrnStyleCol.java |
| 样式行服务 | `PosPrnStyleRowServicePlus` | nms4pos-pos2plugin-biz | get, add, update, list | E-SRC: PosPrnStyleRowServicePlus.java |
| 样式列服务 | `PosPrnStyleColServicePlus` | nms4pos-pos2plugin-biz | get, add, update, list | E-SRC: PosPrnStyleColServicePlus.java |
| 样式类型枚举 | `PrnStyleTypeEnum` | nms4pos-pos2plugin-api | 50+种单据类型 | E-SRC: PrnStyleTypeEnum.java |
| 样式列类型枚举 | `PrnStyleColTypeEnum` | nms4pos-pos2plugin-api | TEXT/IMG/BAR_CODE/QR_CODE等 | E-SRC: PrnStyleColTypeEnum.java |

### 打印内容渲染

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 内容初始化 | `PrintJobInitUtil` | nms4pos-pos2plugin-biz | convert, convertRow, convertLineRow, convertTableRow | E-SRC: PrintJobInitUtil.java |
| 条件判断 | `ConditionUtil` | nms4pos-pos2plugin-biz | isRowVisible | E-SRC: ConditionUtil.java |
| 数据源DTO | `PrnDataSourceDTO` | nms4pos-pos2plugin-api | id, type, data/dataList | E-SRC: PrnDataSourceDTO.java |
| 打印内容VO | `PrnContentVO` | nms4cloud-starter-parent | items: List<PrnContentItemVO> | E-SRC: PrnContentVO.java |
| 打印内容项VO | `PrnContentItemVO` | nms4cloud-starter-parent | prnType, text, width, fontSize, bold, align | E-SRC: PrnContentItemVO.java |

### 打印工作线程

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 线下模式 | `PrinterWorkerServiceOfflineImpl` | nms4pos-pos3boot-biz | handlePrnJob, addPrinterWorkerAndGet | E-SRC: PrinterWorkerServiceOfflineImpl.java |
| 线上模式 | `PrinterWorkerServiceOnlineImpl` | nms4pos-pos4cloud-biz | handlePrnJob | E-SRC: PrinterWorkerServiceOnlineImpl.java |
| 独立服务模式 | `PrinterWorkerServiceLocalImpl` | nms4pos-pos10printer-app | handlePrnJob, init | E-SRC: PrinterWorkerServiceLocalImpl.java |
| 打印机Worker | `PrinterWorker` | nms4pos-pos10printer-app | 任务队列管理, 执行打印 | E-SRC: PrinterWorker.java |
| 打印工具 | `PrintUtil` | nms4pos-pos2plugin-biz | initJob, dispatchJob, handle, getStatus | E-SRC: PrintUtil.java |

### 打印处理器（打印机驱动层）

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 驱动打印 | `DriverHandler` | nms4pos-pos2plugin-biz | 通过Windows驱动打印 | E-SRC: DriverHandler.java |
| 图形打印 | `GraphicsHandler` | nms4pos-pos2plugin-biz | 图形方式打印 | E-SRC: GraphicsHandler.java |
| 端口打印 | `PortHandler` | nms4pos-pos2plugin-biz | 串口/网口指令打印 | E-SRC: PortHandler.java |
| USB/LPT打印 | `UsbLptHandler` | nms4pos-pos2plugin-biz | USB/并口指令打印 | E-SRC: UsbLptHandler.java |
| 芯烨云打印 | `XpCloudPrinter` | nms4pos-pos2plugin-biz | 芯烨云HTTP API | E-SRC: XpCloudPrinter.java |
| 佳博云打印 | `JBCloudPrinter` | nms4pos-pos2plugin-biz | 佳博云HTTP API | E-SRC: JBCloudPrinter.java |
| 佳博标签打印 | `JBTagPrinter` | nms4pos-pos2plugin-biz | 佳博标签打印机 | E-SRC: JBTagPrinter.java |
| 芯烨标签打印 | `XYTagPrinter` | nms4pos-pos2plugin-biz | 芯烨标签打印机 | E-SRC: XYTagPrinter.java |
| 汉印打印 | `HanYinPrinter` | nms4pos-pos2plugin-biz | 汉印打印机 | E-SRC: HanYinPrinter.java |

### 打印配置管理

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 打印开关服务 | `PrintJobTypeSwitchServicePlus` | nms4pos-pos2plugin-biz | get, add, update, list | E-SRC: PrintJobTypeSwitchServicePlus.java |
| 顾客联设置服务 | `PosCustomerBillSettingServicePlus` | nms4pos-pos2plugin-biz | listAll, get | E-SRC: PosCustomerBillSettingServicePlus.java |
| 传菜联设置服务 | `PosWaiterBillSettingServicePlus` | nms4pos-pos2plugin-biz | listAll, get | E-SRC: PosWaiterBillSettingServicePlus.java |
| 出品部门服务 | `PosDeptServicePlus` | nms4pos-pos2plugin-biz | listAll, get | E-SRC: PosDeptServicePlus.java |
| 菜品出品部门映射 | `PosDishToPrnDeptServicePlus` | nms4pos-pos2plugin-biz | get, list | E-SRC: PosDishToPrnDeptServicePlus.java |

### 前端页面（nms4cloud-biz-ui）

| 业务概念 | 页面/组件 | 关键文件 | 证据 |
|---------|----------|---------|------|
| 打印设置主页 | PrintMgr | `src/pages/PrintMgr/index.tsx` | E-SRC: PrintMgr |
| 打印机管理 | PosPrnPrinterPage | `src/components/antd/src/pages/PosPrnPrinterPage/` | E-SRC: PosPrnPrinterPage |
| 打印队列管理 | PosPrnQueuePage | `src/components/antd/src/pages/PosPrnQueuePage/` | E-SRC: PosPrnQueuePage |
| 样式列编辑 | PosPrnStyleColPage | `src/pages/PosPrnStyleColPage/` | E-SRC: PosPrnStyleColPage |
| 样式行编辑 | PosPrnStyleRowPage | `src/pages/PosPrnStyleRowPage/` | E-SRC: PosPrnStyleRowPage |
| 打印开关管理 | PrintJobTypeSwitchPage | `src/components/antd/src/pages/PrintJobTypeSwitchPage/` | E-SRC: PrintJobTypeSwitchPage |
| 菜品出品部门映射 | PosDishToPrnDeptPage | `src/components/antd/src/pages/PosDishToPrnDeptPage/` | E-SRC: PosDishToPrnDeptPage |
| 顾客联设置 | PosCustomerBillSettingPage | `src/components/antd/src/pages/PosCustomerBillSettingPage/` | E-SRC: PosCustomerBillSettingPage |
| 传菜联设置 | PosWaiterBillSettingPage | `src/components/antd/src/pages/PosWaiterBillSettingPage/` | E-SRC: PosWaiterBillSettingPage |

### 前端页面（nms4pos-ui）

| 业务概念 | 页面/组件 | 关键文件 | 证据 |
|---------|----------|---------|------|
| 打印任务监控 | PrintTaskMonitor | `src/pages/FunctionPanel/pages/PrintTaskMonitor/` | E-SRC: PrintTaskMonitor |
| 打印机状态提示 | PrintInfoModal | `src/pages/Home/component/Mode/Saas/components/PrintInfoModal/` | E-SRC: PrintInfoModal |
| 重打菜品 | ReprintDishModal | `src/pages/FunctionPanel/components/BillDetailComponent/components/ReprintDishModal/` | E-SRC: ReprintDishModal |

## 配置映射

| 配置项 | 位置 | 默认值 | 说明 | 证据 |
|--------|------|--------|------|------|
| 打印任务重试超时 | PosPrnQueueServicePlus | 45分钟 | 超过后不再重试 | E-SRC: 代码常量 |
| 打印任务重试间隔 | PosPrnQueueServicePlus | 2秒 | 延迟重试间隔 | E-SRC: 2000L |
| 队列缓存 | JetCache | 无 | 缓存前缀 `POS_SERVICE:pos_prn_queue:` | E-SRC: PosPrnQueueServicePlus |
| 打印次数计数 | Redis | 无 | Key `POS_SERVICE:pos_prn_job:count:{lid}` | E-SRC: PosPrnJobServicePlus |
| 打印机SDK DLL | 资源文件 | 无 | printer.sdk.x64.dll / x86.dll | E-SRC: nms4pos-pos10printer |

## 设计决策记录

### DEC-001：使用 `.job` 文件作为打印任务本地持久化载体

| 字段 | 内容 |
|------|------|
| 决策点 | 打印任务为什么需要本地 `.job` 文件，而不只依赖数据库？ |
| 当时约束 | 打印 worker 进程需要独立读取任务，不能依赖数据库连接；进程重启后需要恢复未打印任务 |
| 可选方案 | 1. 纯数据库 + 轮询；2. 数据库 + 本地文件双写；3. 纯消息队列 |
| 选择与理由 | 选择方案2（数据库 + 本地文件）。理由：数据库用于管理和查询，本地文件用于 worker 独立读取和重启恢复；消息队列作为异步触发通道 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 — 双保险设计，数据库和文件互备 |
| 当前合理性 | 仍合理 — 支持线下模式（无数据库连接）和进程重启恢复 |
| 影响面 | 只伤未来 — 需要管理 `.job` 文件的磁盘空间 |

### DEC-002：打印条件配置错误时默认显示行（容错策略）

| 字段 | 内容 |
|------|------|
| 决策点 | 打印条件配置错误时应该隐藏行还是显示行？ |
| 当时约束 | 门店管理员可能配置错误的条件，如果隐藏行可能导致票据内容缺失，影响业务 |
| 可选方案 | 1. 隐藏行（安全模式）；2. 显示行（容错模式）；3. 抛出异常 |
| 选择与理由 | 选择方案2（容错模式）。理由：打印内容缺失的业务后果比多显示一行更严重；日志记录错误供排查 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 — 业务优先：宁可多打不可少打 |
| 当前合理性 | 仍合理 — 符合餐饮行业"内容完整比精确更重要"的实际需求 |
| 影响面 | 只伤未来 |

### DEC-003：打印任务异步执行，不阻塞核心业务

| 字段 | 内容 |
|------|------|
| 决策点 | 打印应该同步还是异步执行？ |
| 当时约束 | 打印机可能故障、离线、慢速，同步打印会阻塞收银/点菜等核心业务 |
| 可选方案 | 1. 同步打印；2. 异步打印（创建任务后立即返回）；3. 半同步（等待超时） |
| 选择与理由 | 选择方案2（异步打印）。理由：打印失败不应影响核心业务；打印机响应慢不拖慢收银速度 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 — 异步解耦是正确设计 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来 |

### DEC-004：三种部署模式（线下/线上/独立服务）

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么需要三种打印部署模式？ |
| 当时约束 | 不同门店场景不同：小型门店本地收银（线下）、大型连锁云端收银（线上）、需要独立打印服务进程 |
| 可选方案 | 1. 统一线上模式；2. 统一线下模式；3. 三种模式共存 |
| 选择与理由 | 选择方案3（三种模式共存）。理由：适应不同门店规模和部署需求；线下模式不依赖网络，线上模式集中管理，独立服务可扩展 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 — 灵活适配多种场景 |
| 当前合理性 | 仍合理 — 三种模式各有适用场景 |
| 影响面 | 只伤未来 — 维护三种实现成本较高 |