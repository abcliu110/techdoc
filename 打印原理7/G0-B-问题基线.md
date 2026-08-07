# G0-B: 问题基线 — 打印子系统

## 一、分析对象业务定位

打印子系统在 NMS4Cloud 生态中的定位：

```
业务层（餐饮 POS / 零售 POS）
  → 打印任务生成层（PrintJobGenerator）
    → 打印任务持久化层（PosPrnJobServicePlus）
      → 队列初始化与分发层（PosPrnQueueServicePlus）
        → 打印机工作层（PrinterWorkerService*Impl）
          → 物理打印机（USB/串口/网口/云打印机）
```

**业务位置**：支撑业务能力 — 打印子系统不直接产生营收，但直接支撑餐饮 POS 的核心业务闭环（点菜→厨房制作→传菜→结账→顾客小票），是门店运营不可缺失的支撑能力。

**系统拥有的事实**：打印任务、打印队列、打印样式、打印机状态、打印次数。
**系统不拥有的事实**：业务订单数据（账单、菜品、支付）— 这些由业务模块维护，打印系统通过 DataSource 读取。

## 二、业务结果族全景

| 业务结果族 | 触发事实 | 交付物/输出 | 接收角色 | 成功义务 | 失败后果 | 入口证据 |
|-----------|---------|------------|---------|---------|---------|---------|
| 厨房联打印 | 点菜/加菜/催菜/退菜等厨房操作 | 厨房小票 | 厨房厨师 | 菜品信息准确、数量正确、出品部门正确 | 厨房漏单、菜品错误 | E-SRC: PrintJobGenerator.generateKitchenJob |
| 传菜联打印 | 划菜完成/菜品制作完成 | 传菜小票 | 传菜员 | 菜品与桌台对应、传菜间正确 | 传菜错误、上错菜 | E-SRC: PrintJobGenerator.generateWaiterJob |
| 顾客联打印 | 结账/点菜/预结算 | 顾客小票/账单 | 顾客 | 金额准确、支付方式正确、优惠明细完整 | 顾客投诉、金额纠纷 | E-SRC: PrintJobGenerator.generateCustomerJob |
| 报表打印 | 交班/日结/查询 | 营业报表/交班单 | 收银员/店长 | 数据准确、统计口径正确 | 对账错误、经营决策偏差 | E-SRC: 各报表页面调用 |
| 标签打印 | 菜品标签/价格标签 | 标签单 | 后厨/库管 | 标签内容正确 | 标签错误导致混淆 | E-SRC: PrintJobGenerator + FoodLabelPrintJobCreator |
| 钱箱弹出 | 结账/开台 | 钱箱弹开信号 | 收银员 | 信号正确触发 | 钱箱无法打开 | E-SRC: CashboxPop 特殊任务 |

## 三、角色与责任

| 角色 | 操作 | 接触系统 | 业务责任 |
|------|------|---------|---------|
| 收银员/服务员 | 点菜、结账、交班、重打 | POS 前端（nms4pos-ui） | 触发打印任务，确认打印结果 |
| 厨师 | 查看厨房小票制作菜品 | 物理打印机 | 按小票内容制作菜品 |
| 传菜员 | 查看传菜小票传菜 | 物理打印机 | 按小票将菜品送至正确桌台 |
| 顾客 | 接收小票 | 物理打印机 | 核对消费金额 |
| 门店管理员 | 配置打印机、队列、样式 | SaaS 后台（nms4cloud-biz-ui） | 确保打印配置正确 |
| 系统运维 | 排查打印故障 | 各系统日志 | 确保打印系统可用 |

## 四、核心概念候选

| 概念 | 业务定义 | 源码体现 |
|------|---------|---------|
| 打印机 (Printer) | 连接至 POS 系统的物理打印设备，可以是 USB/串口/网口/云打印机 | `PosPrnPrinter` / `PrinterTypeEnum` / `PrinterModelEnum` |
| 打印队列 (Queue) | 将打印样式与打印机关联的配置单元，一组主/备打印机 | `PosPrnQueue` |
| 打印任务 (Job) | 一次打印操作，包含样式、数据源和状态信息 | `PosPrnJob` / `.job` 文件 |
| 打印样式 (Style) | 定义票据打印内容的模板，由多行组成 | `PosPrnStyleRow` / `PosPrnStyleCol` |
| 打印条件 (Condition) | 控制行或记录是否打印的规则 | `ConditionUtil` / `conditionOperator/conditionDsId/conditionValue` |
| 数据源 (DataSource) | 打印内容的数据来源，如门店信息、账单信息、菜品明细 | `PrnDataSourceDTO` |
| 打印开关 (Switch) | 控制某种打印类型是否启用、打印张数 | `PrintJobTypeSwitch` |
| 出品部门 (Dept) | 菜品制作部门，决定厨房联打印到哪个队列 | `PosDept` |
| 顾客联设置 (CustomerBillSetting) | 配置顾客联打印的队列、优先级规则 | `PosCustomerBillSetting` |
| 传菜联设置 (WaiterBillSetting) | 配置传菜联打印的队列、出品部门映射 | `PosWaiterBillSetting` |
| 打印机状态 (PrinterStatus) | 打印机的健康状态（正常/故障/繁忙/无状态） | `PrinterStatus` |
| 打印任务用途 (Purpose) | 区分厨房联、传菜联、顾客联三种用途 | `PrnJobPurposeEnum` |
| 打印样式类型 (Type) | 50+ 种单据类型，如点菜单、结账单、交班单 | `PrnStyleTypeEnum` |

## 五、候选 DQ

| DQ | 来源证据 | 为什么重要 | 状态 |
|----|---------|-----------|------|
| DQ-01: 打印任务从业务触发到物理打印的完整调用链是什么？ | E-DOC: 打印系统总览 + E-SRC 各层代码 | 理解系统核心流程 | 保留 |
| DQ-02: 打印样式模板如何定义，数据源如何填充？ | E-DOC: 打印内容初始化 + E-SRC: PrintJobInitUtil | 理解打印内容生成机制 | 保留 |
| DQ-03: 打印条件如何控制行和记录的可见性？ | E-DOC: 打印条件与行过滤 + E-SRC: ConditionUtil | 理解条件过滤机制 | 保留 |
| DQ-04: 打印队列如何分发到打印机？主备切换策略是什么？ | E-DOC: 打印任务创建 + E-SRC: PosPrnQueueServicePlus | 理解负载均衡和故障转移 | 保留 |
| DQ-05: 打印机的类型、状态管理和连接方式有哪些？ | E-SRC: PrinterTypeEnum/PrinterStatus/PrinterWorker | 理解设备管理 | 保留 |
| DQ-06: 线下模式与线上独立打印服务的区别是什么？ | E-SRC: PrinterWorkerServiceOfflineImpl vs LocalImpl | 理解两种部署架构 | 保留 |
| DQ-07: 打印任务的状态管理和重试机制是什么？ | E-SRC: PosPrnJobServicePlus/PrintUtil | 理解任务可靠性 | 保留 |
| DQ-08: 打印配置（开关、队列、样式、设备）如何在 SaaS 后台管理？ | E-SRC: nms4cloud-biz-ui 打印页面 + nms4cloud 后端 Controller | 理解配置管理入口 | 保留 |
| DQ-09: POS 前端的打印任务监控如何工作？ | E-SRC: nms4pos-ui PrintTaskMonitor | 理解监控能力 | 保留 |
| DQ-10: 打印失败如何排查？有哪些典型的故障场景？ | E-DOC: 打印问题排查指南 + E-SRC | 理解运维能力 | 保留 |

## 六、业务切片候选（含评分）

| 切片 | 业务描述 | 不可替代性 | 失败冲击 | 频率 | 跨边界耦合 | 总分 | 深度级别 |
|------|---------|-----------|---------|------|-----------|------|---------|
| SC-01: 厨房联打印 | 点菜/加菜后，系统按菜品出品部门分发到对应厨房打印机 | 5 | 5 | 3 | 3 | **16** | SC-P0 |
| SC-02: 结账顾客联打印 | 结账时打印顾客小票（含支付明细、优惠、会员信息） | 5 | 4 | 3 | 2 | **14** | SC-P0 |
| SC-03: 传菜联打印 | 划菜完成后打印传菜联，传菜员按单传菜 | 4 | 4 | 2 | 2 | **12** | SC-P1 |
| SC-04: 打印样式配置 | 门店管理员在后台配置打印模板（行、列、条件、数据源） | 3 | 2 | 1 | 3 | **9** | SC-P1 |
| SC-05: 打印任务监控与重试 | POS 端查看打印任务状态、重打、删除 | 3 | 3 | 2 | 1 | **9** | SC-P1 |
| SC-06: 打印机故障切换 | 主打印机故障时自动切换到备用打印机 | 3 | 5 | 1 | 2 | **11** | SC-P1 |
| SC-07: 报表打印 | 交班/日结时打印营业报表 | 2 | 2 | 2 | 1 | **7** | SC-P2 |

> 评分说明：不可替代性(1-5) + 失败冲击(1-5) + 频率(1-5) + 跨边界耦合(1-5)，满分20分，≥14分为P0，≥10分为P1，≥5分为P2。

## 七、候选业务规则

| 规则 | 说明 | 证据 |
|------|------|------|
| BR-01: 打印张数由 PrintJobTypeSwitch 配置控制 | 每种打印类型可配置是否启用和打印张数 | E-SRC: PrintJobGenerator.getNumOfXxx |
| BR-02: 顾客联队列优先级：桌台 > 区域 > 桌型 > PC | 结账和点菜时按此优先级选择队列 | E-SRC: PrintJobGenerator.generateCustomerJob |
| BR-03: 厨房联按菜品出品部门分发 | 每个菜品关联一个出品部门，部门关联打印队列 | E-SRC: PrintJobGenerator.generateKitchenJob |
| BR-04: 主打印机故障时切换到备打印机 | 随机负载均衡选择健康打印机 | E-SRC: PosPrnQueueServicePlus.dispatchJob |
| BR-05: 打印任务超时 45 分钟不再重试 | 超过 45 分钟仍无可用打印机时放弃任务 | E-SRC: PosPrnQueueServicePlus.overTaskTime 常量 |
| BR-06: 打印条件配置错误时默认显示行 | 容错策略：条件格式错误不隐藏行，只记日志 | E-SRC: ConditionUtil.isRowVisible |
| BR-07: 打印任务异步执行，不阻塞核心业务 | 创建任务后立即返回，初始化和分发异步进行 | E-SRC: PrintUtil.initJob → JobTaskHandle |
| BR-08: 打印机状态实时更新，故障打印机不参与分发 | PrinterStatus.FAULT 的打印机被过滤 | E-SRC: PosPrnQueueServicePlus.selectHealthyPrinters |
| BR-09: 云打印机通过 HTTP API 通信，支持回调通知 | 芯烨云和佳博云平台远程打印 | E-SRC: cn.poscom.cloud 包 + DeviceNotificationAPI |
| BR-10: 传菜联按传菜间设置分发 | 传菜设置关联出品部门列表，匹配菜品后发到对应队列 | E-SRC: PrintJobGenerator.generateWaiterJob |

## 八、G0-B 门禁结论

**结论：通过**

理由：
- 候选 DQ 覆盖了打印系统的主要方面
- 业务切片已分级（SC-P0 × 2, SC-P1 × 4, SC-P2 × 1），P0 切片完成深度八关分析即可停止
- 核心概念已识别，证据来源明确
- 候选业务规则已列出并标注证据编号
- 停止条件：P0 切片完成深度八关分析即可停止
