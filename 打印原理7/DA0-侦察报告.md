# DA0 侦察报告 — 打印子系统

## 版本信息

| 属性 | 值 |
|------|-----|
| 侦察范围 | nms4pos/nms4cloud/nms4cloud-biz-ui/nms4pos-ui 四个仓库的打印相关模块 |
| 版本基线 | 当前最新代码（未指定提交） |
| 侦察时间 | 2026-08-04 |

## 一、入口痕迹清单

### 1.1 Controller 入口（nms4cloud）

| 入口 | 路径 | 方法 | 证据 |
|------|------|------|------|
| PosPrinterForBizController | `/merchant/pos_printer/*` | 打印机 CRUD/激活/导出 | E-SRC: nms4cloud-pos-biz/controller/biz/PosPrinterForBizController.java |
| PosPrnJobController | `/pos_prn_job/*` | 打印任务管理 | E-SRC: nms4cloud-pos-biz/controller/admin/PosPrnJobController.java |
| PosPrnStyleController | `/pos_prn_style/*` | 打印样式管理 | E-SRC: nms4cloud-pos-biz/controller/admin/PosPrnStyleController.java |
| PosPrnStyleItemController | `/pos_prn_style_item/*` | 样式项管理 | E-SRC: nms4cloud-pos-biz/controller/admin/PosPrnStyleItemController.java |
| DeviceNotificationAPI | `/device/Gprinter` | 云打印机回调 | E-SRC: nms4cloud-pos-biz/controller/biz/DeviceNotificationAPI.java |

### 1.2 Controller 入口（nms4pos - pos2plugin）

| 入口 | 路径 | 方法 | 证据 |
|------|------|------|------|
| PosPrnPrinterController | `/admin/pos_prn_printer/*` | 打印机管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosPrnPrinterController.java |
| PosPrnJobController | `/admin/pos_prn_job/*` | 打印任务管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosPrnJobController.java |
| PosPrnQueueController | `/admin/pos_prn_queue/*` | 打印队列管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosPrnQueueController.java |
| PosPrnStyleColController | `/admin/pos_prn_style_col/*` | 样式列管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosPrnStyleColController.java |
| PosPrnStyleRowController | `/admin/pos_prn_style_row/*` | 样式行管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosPrnStyleRowController.java |
| PrintJobTypeSwitchController | `/admin/print_job_type_switch/*` | 打印开关管理 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PrintJobTypeSwitchController.java |
| PosDishToPrnDeptController | `/admin/pos_dish_to_prn_dept/*` | 菜品出品部门映射 | E-SRC: nms4pos-pos2plugin-biz/controller/admin/PosDishToPrnDeptController.java |
| PosPrnPrinterForBizController | `/merchant/pos_prn_printer/*` | 商户端打印机管理 | E-SRC: nms4pos-pos2plugin-biz/controller/biz/PosPrnPrinterForBizController.java |
| PosPrnQueueForBizController | `/merchant/pos_prn_queue/*` | 商户端队列管理 | E-SRC: nms4pos-pos2plugin-biz/controller/biz/PosPrnQueueForBizController.java |
| DwdBillOpsForBizController | `/merchant/dwd_bill_ops/*` | 账单操作（含打印触发） | E-SRC: nms4pos-pos2plugin-biz/controller/biz/DwdBillOpsForBizController.java |

### 1.3 Controller 入口（nms4pos - pos10printer）

| 入口 | 路径 | 方法 | 证据 |
|------|------|------|------|
| PrinterController | 打印服务管理接口 | 打印任务调度 | E-SRC: nms4pos-pos10printer-app/controllers/PrinterController.java |
| NettyDevController | Netty 设备通信 | 设备连接管理 | E-SRC: nms4pos-pos10printer-app/controllers/NettyDevController.java |

### 1.4 MQ/事件监听入口

| 入口 | 主题/队列 | 处理器 | 证据 |
|------|----------|--------|------|
| QueueOptPrintConsumer | `QUEUE_OPT_PRINT` | 排队打印消费 | E-SRC: nms4cloud-product-app/task/QueueOptPrintConsumer.java |
| PrintJobActiveMQListener | ActiveMQ（打印任务初始化） | 异步初始化打印任务 | E-SRC: nms4pos-pos3boot-biz/listeners/PrintJobActiveMQListener.java |
| PrintJobKafkaListener | Kafka（打印任务分发） | 线上模式打印任务分发 | E-SRC: nms4pos-pos4cloud-biz/listeners/PrintJobKafkaListener.java |
| CRM_NETTY_MSG_SEND_QUEUE | RocketMQ | 打印小票任务（Netty 推送） | E-SRC: nms4cloud-starter/RocketMqTopicConstants.java |

### 1.5 定时任务入口

| 任务名 | 周期 | 执行逻辑 | 证据 |
|--------|------|---------|------|
| ClientJobsCleanupTask | 定时清理 | 清理已完成的打印任务文件 | E-SRC: nms4pos-pos10printer-app/tasks/ClientJobsCleanupTask.java |

### 1.6 数据痕迹（核心表）

| 表名 | 核心字段 | 用途 | 证据 |
|------|---------|------|------|
| pos_prn_printer | lid, mid, sid, name, type, model, printerStatus | 打印机设备 | E-SRC: PosPrnPrinter Entity |
| pos_prn_queue | lid, mid, sid, name, primaryPrinter, standbyPrinter, pcLid | 打印队列 | E-SRC: PosPrnQueue Entity |
| pos_prn_job | lid, mid, sid, bill_id, printer, type_, purpose, prnQueueLid, print, finish_time | 打印任务 | E-SRC: PosPrnJob Entity |
| pos_prn_style | lid, mid, sid, type_, extra_info | 打印样式 | E-SRC: PosPrnStyle Entity |
| pos_prn_style_col | lid, mid, sid, style, idx, type_, condition_, content, align, width, bold, font_size | 样式列 | E-SRC: PosPrnStyleCol Entity |
| pos_prn_style_row | lid, mid, sid, style, idx, dsId, cols, conditionOperator, conditionDsId, conditionValue | 样式行 | E-SRC: PosPrnStyleRow Entity |
| pos_prn_style_item | lid, mid, sid, style, idx, type_, condition_, content, align, width, bold | 样式项（nms4cloud 版） | E-SRC: PosPrnStyleItem Entity |
| pos_dish_to_prn_dept | lid, mid, sid, dishLid, prnDeptLid | 菜品出品部门映射 | E-SRC: PosDishToPrnDept Entity |
| print_job_type_switch | lid, mid, sid, type_, disabledCustomer, disabledKitchen, disabledWaiter, numOfCustomer, numOfKitchen, numOfWaiter | 打印开关 | E-SRC: PrintJobTypeSwitch Entity |
| pos_customer_bill_setting | lid, mid, sid, prnQueue, forCheckout, tableLid, areaLid, tableTypeLid, pcLid | 顾客联设置 | E-SRC: PosCustomerBillSetting Entity |
| pos_waiter_bill_setting | lid, mid, sid, prnQueue, prnDept | 传菜联设置 | E-SRC: PosWaiterBillSetting Entity |
| pos_prn_printer_transfer | lid, mid, sid, printerLid, targetLid, status | 打印机转移 | E-SRC: PosPrnPrinterTransfer Entity |

### 1.7 配置痕迹

| 配置项 | 值/用途 | 证据 |
|--------|--------|------|
| `g_queuePrintPeople` | 排队打印人数 | E-SRC: ShopConfigKeys |
| `g_cfdy` | 厨房打印开关 | E-SRC: ShopConfigKeys |
| `g_dycfd` | 打印厨房单开关 | E-SRC: ShopConfigKeys |
| `g_jzddyfs` | 结账单打印方式 | E-SRC: ShopConfigKeys |
| `g_defPrintPageWidth` | 默认打印页宽 | E-SRC: ShopConfigKeys |
| `g_defPrintPageHeight` | 默认打印页高 | E-SRC: ShopConfigKeys |
| `g_defPrintPageRow` | 默认打印行数 | E-SRC: ShopConfigKeys |
| 打印任务重试超时 | 45 分钟（代码常量） | E-SRC: PosPrnQueueServicePlus |

## 二、候选事实清单

| 候选事实 | 痕迹位置 | 推断链 | 置信度 | 验证状态 |
|---------|---------|--------|-------|---------|
| 打印任务通过 `.job` 文件持久化，worker 进程独立读取 | E-SRC: PosPrnJobServicePlus.keepToFile/getFromFile/removeFromFile | 代码显示写文件、读文件、改后缀逻辑 | 直接事实 | 已验证 |
| 打印任务初始化使用模板+DataSource 渲染最终内容 | E-SRC: PrintJobInitUtil.convert | 代码显示 convert 后 rows 变为最终行，dataSourceList 置空 | 直接事实 | 已验证 |
| 打印队列使用主备打印机策略，随机负载均衡 | E-SRC: PosPrnQueueServicePlus.dispatchJob | 代码显示主打印机列表随机选，全故障时切备机 | 直接事实 | 已验证 |
| 打印条件使用三元组（operator/dsId/value）控制行可见性 | E-SRC: ConditionUtil.isRowVisible | 代码显示条件判断逻辑 | 直接事实 | 已验证 |
| 打印开关按门店+打印类型配置是否启用和张数 | E-SRC: PrintJobTypeSwitch + PrintJobGenerator.getNumOfXxx | 代码显示读取开关配置并判断 | 直接事实 | 已验证 |
| 顾客联队列选择有优先级：桌台>区域>桌型>PC | E-SRC: PrintJobGenerator.generateCustomerJob | 代码显示四层匹配逻辑 | 直接事实 | 已验证 |
| 厨房联按菜品出品部门分发到对应队列 | E-SRC: PrintJobGenerator.generateKitchenJob | 代码显示按 dept 分组分发 | 直接事实 | 已验证 |
| 传菜联按传菜间设置分发，传菜间关联出品部门 | E-SRC: PrintJobGenerator.generateWaiterJob | 代码显示按 waiter setting 遍历 | 直接事实 | 已验证 |
| 线下模式使用 Pos3boot 的 PrinterWorkerServiceOfflineImpl | E-SRC: PrinterWorkerServiceOfflineImpl | 独立文件 | 直接事实 | 已验证 |
| 线上模式使用 Pos4cloud 的 PrinterWorkerServiceOnlineImpl | E-SRC: PrinterWorkerServiceOnlineImpl | 独立文件 | 直接事实 | 已验证 |
| 独立打印服务使用 Pos10printer 的 PrinterWorkerServiceLocalImpl | E-SRC: PrinterWorkerServiceLocalImpl | 独立文件 | 直接事实 | 已验证 |
| 打印任务超时 45 分钟不再重试 | E-SRC: PosPrnQueueServicePlus.dispatchJob | 代码常量 | 直接事实 | 已验证 |

## 三、未知项

| 编号 | 描述 | 影响 |
|------|------|------|
| U-01 | 三种部署模式（线下/线上/独立服务）的实际部署拓扑和切换条件 | 无法确定具体门店使用哪种模式 |
| U-02 | 打印任务重试间隔（2 秒）是否为固定值，是否有配置入口 | 仅看到 2000L 常量，未知是否可配置 |
| U-03 | 打印机状态（PrinterStatus）的更新机制：谁在何时检测并更新 | 影响故障切换的可靠性评估 |
| U-04 | `.job` 文件的清理策略：保留多久、磁盘空间管理 | 长期运行可能产生大量历史文件 |
| U-05 | 打印任务监控的 WebSocket 消息类型和推送机制 | 影响实时性评估 |
| U-06 | 云打印机（芯烨/佳博）的实际通信协议细节和回调处理 | 影响第三方集成评估 |

## 四、当前停止条件

- 继续侦察的预期信息增益：低（核心入口已覆盖）
- 下一轮最小取证动作：进入 DA1 业务切面分析