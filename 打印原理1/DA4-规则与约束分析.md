# DA4 - 规则与约束分析

> **SOP-00 §DA4 执行记录**
> 分析打印系统的业务规则、技术约束和配置约束

---

## 一、业务规则

### 1.1 打印触发规则

| 规则编号 | 规则描述 | 约束级别 | 实现位置 |
|----------|----------|----------|----------|
| BR-01 | 客单打印必须在结账完成后立即触发 | MUST | CloseMpScHandler |
| BR-02 | 厨打票据按出品部门分组，每部门一个打印任务 | MUST | KitchenDisplayService |
| BR-03 | 催菜打印优先级高于普通厨打 | SHOULD | 任务调度器 |
| BR-04 | 交班报告打印需等待交班确认 | MUST | ReportService |
| BR-05 | 会员储值打印需验证储值成功 | MUST | MemberService |

### 1.2 重试规则

| 规则编号 | 规则描述 | 参数 | 说明 |
|----------|----------|------|------|
| RR-01 | 单任务最大重试次数 | 3 次 | 可配置 |
| RR-02 | 重试间隔策略 | 指数退避 | 1min, 2min, 4min |
| RR-03 | 重试超时时间 | 30 分钟 | 超时后标记失败（PrinterWorker.java:180） |
| RR-04 | 失败任务归档周期 | 31 天 | 启动时清理过期缓存（PrinterWorkerServiceOfflineImpl.java:91） |

### 1.3 样式规则

| 规则编号 | 规则描述 | 约束级别 |
|----------|----------|----------|
| SR-01 | 同一票据类型在同一门店只能有一个默认样式 | MUST |
| SR-02 | 样式修改不影响已创建的任务 | MUST |
| SR-03 | 样式删除前需解除关联任务 | MUST |
| SR-04 | 样式预览使用模拟数据 | SHOULD |

---

## 二、技术约束

### 2.1 性能约束

| 约束项 | 目标值 | 说明 |
|--------|--------|------|
| 单任务打印延迟 | < 500ms | 网络打印机 |
| 并发打印任务 | 100+ | 虚拟线程支持 |
| 任务创建 QPS | 50+ | 峰值场景 |
| 样式加载延迟 | < 100ms | 本地缓存 |

### 2.2 可靠性约束

| 约束项 | 策略 | 说明 |
|--------|------|------|
| 任务持久化 | 文件存储 | 断电不丢失 |
| 计数一致性 | Redis + 文件双写 | 最终一致 |
| 设备异常 | 异常隔离 | 单设备故障不影响其他 |
| 网络超时 | 5 分钟 | 驱动层超时阈值（PortHandlerWithDriver.java:33） |

### 2.3 兼容性约束

| 约束项 | 要求 |
|--------|------|
| Java 版本 | 21+ (Virtual Thread) |
| 打印机协议 | TSPL/ZPL/ESC/OPOS/PCL |
| 纸宽支持 | 58mm/80mm/76mm |
| 编码支持 | UTF-8 |

---

## 三、配置约束

### 3.1 打印机配置约束

```
打印机配置必须包含：
├── model: PrinterModelEnum (必填)
├── connectionType: String (网络/USB/串口/OPOS)
├── connectionInfo:
│   ├── 网络: { ip: String, port: Integer }
│   ├── USB: { path: String }
│   ├── 串口: { port: String, baudRate: Integer }
│   └── OPOS: { deviceName: String }
└── paperWidth: Integer (mm, 默认 80)
```

### 3.2 样式配置约束

```
样式配置必须包含：
├── styleType: PrnStyleTypeEnum (必填)
├── styleName: String (必填)
├── printerLid: Long (可选，默认关联)
├── copies: Integer (默认 1)
└── items: List<PrintStyleItem>
    └── 每个 item 必须包含：
        ├── itemType: PrnStyleItemTypeEnum
        ├── itemValue: String
        ├── fontSize: Integer (可选)
        ├── align: AlignEnum (可选)
        └── position: { left, top, width, height }
```

### 3.3 任务配置约束

```
任务创建参数：
├── queueLid: Long (必填)
├── printerLid: Long (必填)
├── prnStyleLid: Long (必填)
├── orderBillLid: Long (可选)
├── printData: JSON String (必填)
└── copies: Integer (可选，默认样式配置)
```

---

## 四、边界约束

### 4.1 打印能力边界

| 边界项 | 上限 | 超出处理 |
|--------|------|----------|
| 单任务数据大小 | 100KB | 分页打印 |
| 样式项数量 | 100 项 | 提示配置超限 |
| 重试总时间 | 10 分钟 | 标记失败 |
| 打印队列长度 | 无限制 | 按优先级调度 |

### 4.2 设备能力边界

| 设备类型 | 纸宽限制 | 彩色支持 | 切割支持 |
|----------|----------|----------|----------|
| 热敏票据机 | 58/76/80mm | 否 | 是(切刀) |
| 标签打印机 | 自定义 | 否 | 是(撕纸/切刀) |
| OPOS 票据机 | 58/76/80mm | 否 | 是 |
| HP 打印机 | A4/A5 | 是 | 否 |

---

## 五、异常处理规则

### 5.1 异常分类

| 异常类型 | 代码 | 处理策略 |
|----------|------|----------|
| 设备离线 | `PRINTER_OFFLINE` | 重试 + 告警 |
| 设备忙 | `PRINTER_BUSY` | 等待重试 |
| 纸张用尽 | `PAPER_EMPTY` | 告警 + 暂停 |
| 网络超时 | `NETWORK_TIMEOUT` | 重试 |
| 协议错误 | `PROTOCOL_ERROR` | 降级 + 记录 |
| 数据错误 | `DATA_ERROR` | 跳过 + 记录 |

### 5.2 降级策略

| 降级场景 | 降级策略 |
|----------|----------|
| 网络打印机不可达 | 切换到本地缓存任务 |
| 特定 Handler 异常 | 降级到 DEFAULT Handler |
| Redis 不可用 | 纯文件模式 |
| 样式不存在 | 使用系统默认样式 |
