# DA0-侦察报告：打印系统

> **定位**：SOP-00 DA0 阶段产出物，对打印系统进行侦察，识别入口、数据实体、配置和候选事实
> **版本**：v1.0 | **日期**：2026-08-05
> **执行人**：AI

---

## 模板加载记录

```
**模板加载记录**：
- 模板文件：SOP-00-DA0-模板.md
- 加载时间：2026-08-05
- 版本：v1.0
- 门禁检查：4/4 项通过
```

---

## 1. 侦察范围

| 字段 | 内容 |
|------|------|
| 侦察目标 | 打印系统（POS端本地打印 + 云端WMS打印） |
| 侦察深度 | 深度级（DA0-DA8 + V0-V7 + SOP-01~10） |
| 分析模块 | nms4pos / nms4cloud / nms4pos-ui / nms4cloud-biz-ui |
| 证据截止 | 2026-08-05 |

---

## 2. 系统边界识别

### 2.1 模块分布

| 模块 | 层级 | 职责 |
|------|------|------|
| nms4cloud-pos2plugin | 业务层 | 打印任务管理、队列路由、Worker调度 |
| nms4cloud-pos3boot | 消息层 | ActiveMQ消费、打印任务分发 |
| nms4cloud-pos4cloud | 云端层 | WMS打印渲染、ESC/POS生成 |
| nms4cloud-pos10printer | 引擎层 | 驱动打印、协议处理、图像渲染 |
| nms4pos-ui | 前端 | 打印监控界面、任务列表 |
| nms4cloud-biz-ui | 前端 | WMS打印配置界面 |

### 2.2 跨模块边界

```
[nms4pos-ui / nms4cloud-biz-ui]  →  API调用
    ↓
[nms4cloud-pos2plugin]  ←  业务层
    ↓  keepToFile() / PrintUtil.initJob()
[文件存储 + Redis计数]
    ↓
[ActiveMQ]  →  [nms4cloud-pos3boot]
    ↓
[PrinterWorkerService]  ←  多实现
    ↓
[nms4cloud-pos10printer]  ←  本地打印引擎
        OR
[nms4cloud-pos4cloud]  ←  云端WMS打印
```

---

## 3. 入口点识别

### 3.1 API 入口

| 入口 | 模块 | 路径 | 触发方式 |
|------|------|------|---------|
| 打印任务创建 | pos2plugin | PosPrnJobServicePlus.create() | 内部业务调用 |
| 打印任务重打 | pos2plugin | PosPrnJobServicePlus.reprint() | 用户操作 |
| 打印任务删除 | pos2plugin | PosPrnJobServicePlus.delete() | 用户操作 |
| WMS打印渲染 | pos4cloud | WmsPrintRenderService.render() | Feign远程调用 |
| 打印任务列表 | pos2plugin | PosPrnJobServicePlus.listVO() | 前端查询 |

### 3.2 消息入口

| 入口 | 模块 | 路径 | 触发方式 |
|------|------|------|---------|
| ActiveMQ监听 | pos3boot | PrintJobActiveMQListener | 消息队列触发 |
| Kafka监听 | pos4cloud | PrintJobKafkaListener | 消息队列触发 |

### 3.3 内部入口

| 入口 | 模块 | 路径 | 说明 |
|------|------|------|------|
| PrintUtil.initJob() | pos2plugin | PrintUtil.java:23 | 初始化打印任务 |
| PrintUtil.dispatchJob() | pos2plugin | PrintUtil.java:27 | 分发打印任务 |
| PrintUtil.handle() | pos2plugin | PrintUtil.java:35 | 执行打印处理 |

---

## 4. 数据实体识别

### 4.1 核心实体

| 实体 | 表名 | 模块 | 主键 | 说明 |
|------|------|------|------|------|
| PosPrnJob | pos_prn_job | pos2plugin-dal | lid | 打印任务 |
| PosPrnPrinter | pos_prn_printer | pos2plugin-dal | lid | 打印机 |
| PosPrnQueue | pos_prn_queue | pos2plugin-dal | lid | 打印队列 |
| PosPrnPrinterTransfer | pos_prn_printer_transfer | pos2plugin-dal | - | 打印机转移映射 |

### 4.2 PosPrnJob 实体字段

| 字段 | 类型 | 说明 | 来源 |
|------|------|------|------|
| lid | Long | 任务ID | IdWorkerPlus |
| mid | Long | 商户ID | 入参 |
| sid | Long | 门店ID | 入参 |
| name | String | 任务名称 | 入参 |
| prnDeptName | String | 打印部门 | 入参 |
| bizBillId | String | 关联业务单据ID | 入参 |
| type | PrnStyleTypeEnum | 打印样式类型 | 入参（70+种） |
| purpose | PrnJobPurposeEnum | 打印用途 | 入参 |
| prnCount | Integer | 已打印次数 | Redis计数 |
| prnQueueLid | Long | 打印队列ID | 入参 |
| prnPrinterLid | Long | 指定打印机ID | 入参/队列 |
| print | Boolean | 是否已打印 | 完成时更新 |
| printAt | LocalDateTime | 打印时间 | 完成时更新 |
| status | PrnJobStatusEnum | 任务状态 | PENDING/SUCCESS/FAILED |
| failureReason | String | 失败原因 | 失败时更新 |

### 4.3 PosPrnQueue 实体字段

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | Long | 队列ID |
| mid | Long | 商户ID |
| sid | Long | 门店ID |
| name | String | 队列名称 |
| pcLid | Long | PC终端ID |
| primaryPrinter | String | 主打印机（逗号分隔多ID） |
| standbyPrinter | String | 备用打印机（逗号分隔多ID） |

### 4.4 PosPrnPrinter 实体字段

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | Long | 打印机ID |
| mid | Long | 商户ID |
| sid | Long | 门店ID |
| name | String | 打印机名称 |
| pcLid | Long | PC终端ID |
| type | PrinterTypeEnum | 连接类型（DRIVER/NET/COM/USB/LPT/CLOUD） |
| model | PrinterModelEnum | 打印机型号（20+种） |
| extraInfo | String | 扩展信息（JSON） |

---

## 5. 核心枚举识别

### 5.1 PrnJobStatusEnum（任务状态）

| 枚举值 | Code | 说明 |
|--------|------|------|
| PENDING | 1 | 待打印 |
| SUCCESS | 2 | 打印成功 |
| FAILED | 3 | 打印失败 |

### 5.2 PrinterStatus（打印机状态）

| 枚举值 | Code | 说明 |
|--------|------|------|
| DEFAULT | 0 | 无状态 |
| FAULT | 1 | 关闭/故障 |
| NORMAL | 2 | 正常 |
| BUSY | 3 | 正在打印 |

### 5.3 PrinterTypeEnum（连接类型）

| 枚举值 | 说明 |
|--------|------|
| DRIVER | Windows驱动打印 |
| NET | 网口打印 |
| COM | 串口打印 |
| USB | USB打印 |
| LPT | 并口打印 |
| DRIVER_CMD | 驱动指令打印 |
| XY_CLOUD / JB_CLOUD | 云端打印 |

### 5.4 PrnStyleTypeEnum（打印样式类型）

**业务打印（10-73）**：
- OrderMenu(10) 点菜单、TotalBill(14) 划菜总单、CheckOut(26) 结账单
- ShiftReport(29) 交班单、YingYeReport(34) 营业报表
- FoodLabel(52) 标签单、CashboxPop(60) 弹出钱箱

**WMS打印（1000+）**：
- WMS_STORE_ORDER(1000) 门店订货单、WMS_ST_BILL_PDD(1002) 盘点单
- WMS_ST_BILL_CGJHD(1003) 采购进货单、WMS_ST_BILL_XSCKD(1006) 销售出库单
- 共计50+种WMS单据类型

---

## 6. 配置与参数

### 6.1 运行时配置

| 配置项 | 来源 | 说明 |
|--------|------|------|
| 打印任务文件路径 | SystemUtil.getAppDir() + /jobs/ | 按日期分目录 |
| 打印次数Redis Key | pos_service:pos_prn_job:count:{lid} | 15分钟过期 |
| 消息推送Key | pos_service:pos_prn_job:{mid}:{sid} | - |

### 6.2 打印机扩展信息

| 扩展信息 | 打印机类型 | 内容 |
|----------|-----------|------|
| extraInfoDriver | DRIVER | 驱动名称 |
| extraInfoCom | COM | 串口、BaudRate |
| extraInfoNet | NET | IP、端口、切纸声音 |
| extraInfo | 通用 | 进纸行数feedLines |

### 6.3 打印样式配置

| 配置项 | 说明 |
|--------|------|
| PosPrnStyleRow | 打印样式行配置 |
| PosPrnStyleCol | 打印样式列配置 |
| 宽度配置 | 支持58mm/80mm两种纸宽 |
| 字体配置 | 字体名称、字号、对齐、加粗、斜体 |

---

## 7. 候选事实与假设

### 7.1 核心业务假设

| ID | 假设 | 风险等级 |
|----|------|---------|
| F-001 | 打印任务lid由IdWorkerPlus生成，具有时间有序性 | 低 |
| F-002 | 打印任务文件按日期存储，30天后物理删除 | 低 |
| F-003 | 打印次数通过Redis计数，15分钟过期 | 中 |
| F-004 | 打印队列支持主备打印机failover | 低 |
| F-005 | 打印机转移表支持动态重路由 | 中 |
| F-006 | 打印任务状态由print字段和status字段共同决定 | 低 |
| F-007 | 云打印与本地打印互斥，同一任务只走一条路径 | 低 |

### 7.2 技术假设

| ID | 假设 | 风险等级 |
|----|------|---------|
| T-001 | PrinterWorkerService有三套实现（Local/Offline/Online） | 低 |
| T-002 | 打印任务创建后立即写入文件，异步分发 | 低 |
| T-003 | 打印样式模板存储在数据库中，运行时加载 | 低 |
| T-004 | ESC/POS指令由EscPosRenderService统一生成为Base64 | 中 |
| T-005 | 打印监控页面通过轮询或WebSocket获取状态 | 高 |

---

## 8. 架构切面

### 8.1 协议适配层

```
PrinterWorkerService（接口）
    ├── PrinterWorkerServiceLocalImpl  →  本地虚拟线程打印
    ├── PrinterWorkerServiceOfflineImpl  →  离线打印
    └── PrinterWorkerServiceOnlineImpl  →  云端打印（空实现）
```

### 8.2 打印样式层

```
PrnStyleTypeEnum（70+种样式）
    ├── 业务打印（10-73）
    └── WMS打印（1000-1048）
```

### 8.3 协议处理层

```
PrintJobHandlerBase（抽象基类）
    └── DriverHandler（Windows驱动打印）
            ↓
    PrintJobHandlerBase.getBrand()  →  PrinterBrand 枚举
    PrintJobHandlerBase.getType()  →  PrinterType 枚举
```

### 8.4 状态机

```
打印任务状态转换：
PENDING → SUCCESS（打印成功）
PENDING → FAILED（打印失败）
FAILED → PENDING（重打时创建新任务）
```

### 8.5 数据权威源

| 数据类型 | 权威源 | 说明 |
|----------|--------|------|
| 打印任务元数据 | pos_prn_job表 | mid/sid/type/purpose |
| 打印任务内容 | .job文件 | JSON格式，保存15分钟 |
| 打印次数 | Redis | KEY: count:{lid}，15分钟过期 |
| 打印机配置 | pos_prn_printer表 | 名称/类型/型号/扩展信息 |
| 队列配置 | pos_prn_queue表 | 主备打印机映射 |
| 打印样式 | pos_prn_style_row/col表 | 模板配置 |

---

## 9. 异常与边界场景

### 9.1 异常场景

| 场景 | 当前处理 | 风险 |
|------|---------|------|
| 打印任务文件不存在 | 返回null，前端显示"文件已清理" | 低 |
| 打印任务文件解析失败 | 记录错误，返回空内容 | 中 |
| 打印机故障 | PrinterStatus.FAULT，任务标记FAILED | 低 |
| Redis计数不存在 | 回退到DB中的prnCount字段 | 低 |
| 消息队列不可用 | 打印任务静默失败 | 高 |
| 打印样式未配置 | 抛出BizException | 中 |

### 9.2 边界场景

| 场景 | 处理 |
|------|------|
| 并发打印同一任务 | 通过Virtual Thread串行化 |
| 重复打印 | 每次重打印创建新任务lid |
| 打印机转移 | 通过pos_prn_printer_transfer表映射 |
| 历史任务查询 | 支持30天内任务查询 |
| 跨商户数据隔离 | 所有查询按mid/sid过滤 |

---

## 10. 证据索引

| 证据ID | 类型 | 定位 | 版本 |
|--------|------|------|------|
| E-001 | 源码 | pos2plugin-biz/PosPrnJobServicePlus.java | 活跃 |
| E-002 | 源码 | pos2plugin-dal/PosPrnJob.java | 活跃 |
| E-003 | 源码 | pos2plugin-dal/PosPrnPrinter.java | 活跃 |
| E-004 | 源码 | pos2plugin-dal/PosPrnQueue.java | 活跃 |
| E-005 | 枚举 | pos2plugin-api/PrnJobStatusEnum.java | 活跃 |
| E-006 | 枚举 | pos2plugin-api/PrinterStatus.java | 活跃 |
| E-007 | 枚举 | pos2plugin-api/PrnStyleTypeEnum.java | 活跃 |
| E-008 | 源码 | pos2plugin-biz/PrintUtil.java | 活跃 |
| E-009 | 源码 | pos3boot/PrintJobActiveMQListener.java | 活跃 |
| E-010 | 源码 | pos4cloud/WmsPrintRenderService.java | 活跃 |
| E-011 | 源码 | pos10printer/PrintJobHandlerBase.java | 活跃 |
| E-012 | 源码 | pos10printer/DriverHandler.java | 活跃 |
| E-013 | 源码 | pos2plugin-service-print/PrinterWorkerService.java | 活跃 |
| E-014 | 源码 | pos4cloud/PrinterWorkerServiceOnlineImpl.java | 活跃 |

---

## 11. 侦察结论

### 11.1 系统规模

| 指标 | 数量 |
|------|------|
| 核心实体 | 4个（Job/Printer/Queue/Transfer） |
| 打印样式类型 | 70+种业务 + 50+种WMS |
| 打印机类型 | 8种（DRIVER/NET/COM/USB/LPT/CLOUD） |
| 打印机型号 | 20+种 |
| 任务状态 | 3种（PENDING/SUCCESS/FAILED） |
| 打印协议 | ESC/POS、Windows驱动 |

### 11.2 架构特征

1. **多实现共存**：PrinterWorkerService有Local/Offline/Online三套实现
2. **本地优先**：打印任务优先本地执行，云打印作为fallback
3. **异步分发**：任务创建后通过消息队列异步分发
4. **样式驱动**：打印内容由数据库样式模板 + 运行时数据决定
5. **文件缓存**：任务内容缓存在文件系统，15分钟后清理

### 11.3 关键风险点

| 风险 | 说明 | 优先级 |
|------|------|--------|
| 消息队列单点 | 依赖ActiveMQ，失败则打印静默失败 | P1 |
| 文件清理时机 | 任务文件15分钟后清理，可能导致详情不可查 | P2 |
| 状态双重判定 | print字段和status字段需同时判断 | P2 |
| WMS打印空实现 | PrinterWorkerServiceOnlineImpl为空 | P1 |

---

## 12. 后续分析建议

### 12.1 DA1 切面分析重点

- 打印任务生命周期（创建→分发→执行→完成）
- 队列路由决策（主备打印机选择逻辑）
- 打印机状态上报机制

### 12.2 DA2 概念字典重点

- PrnJobStatusEnum vs PrinterStatus 的语义区分
- print字段与status字段的关系
- PrnStyleTypeEnum的分类体系

### 12.3 DA3 关系分析重点

- 打印任务与业务单据的关联（bizBillId）
- 打印队列与打印机的多对多关系
- 打印机转移的动态路由

---

**DA0侦察完成时间**：2026-08-05
**侦察人**：AI
**状态**：✅ 完成，进入DA1阶段
