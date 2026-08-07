# G0-B 问题基线

> **契约 ID**: SYS-ANALYSIS-CONTRACT-v2.6-打印系统
> **版本**: v1.0
> **建立日期**: 2026-08-02
> **类型**: 认知重建型问题基线

---

## 一、分析前提假设

### 1.1 关于打印系统的基础假设

| 假设编号 | 假设内容 | 验证方式 |
|----------|----------|----------|
| AS-01 | 打印系统在 POS 中是独立模块（pos10printer） | DA0 侦察验证 |
| AS-02 | 打印任务通过队列异步执行 | 读 PrinterWorker |
| AS-03 | 支持多种打印机类型（标签、热敏、网络、串口等） | 读 PrinterWorker 构造 |
| AS-04 | 打印任务在结账时触发 | 读 pos2plugin 业务代码 |
| AS-05 | 打印样式可配置（纸张大小、字体、布局） | 查 PosPrnStyle 相关 |

### 1.2 预期的业务问题

| 预期问题 | 说明 | 来源依据 |
|----------|------|----------|
| P-01 | 打印机连接失败时如何处理？ | 通用经验 |
| P-02 | 打印队列积压时如何调度？ | 通用经验 |
| P-03 | 不同打印机协议的差异如何屏蔽？ | 架构设计 |
| P-04 | 打印任务的完整生命周期是什么？ | 认知需求 |
| P-05 | 打印失败后是否有重试机制？ | 通用经验 |

---

## 二、侦察要回答的核心问题

### 2.1 DA0 侦察必须回答的问题

| 问题 ID | 问题描述 | 预期答案形式 |
|---------|----------|--------------|
| Q-01 | 打印系统涉及哪些核心实体（打印机、打印任务、打印样式）？ | 实体清单 + 关键字段 |
| Q-02 | 打印任务的触发入口在哪里？ | Controller/Service 名 |
| Q-03 | 打印任务的生命周期状态有哪些？ | 状态枚举 + 流转图 |
| Q-04 | 支持哪几种打印机类型？ | 类型枚举 + Handler 映射 |
| Q-05 | 打印协议层如何区分不同打印机？ | Handler Factory 模式说明 |
| Q-06 | 打印队列的调度策略是什么？ | 虚拟线程、阻塞队列说明 |
| Q-07 | 标签打印机使用什么协议？ | TSPL 协议说明 |
| Q-08 | 热敏打印机使用什么协议？ | OPOS SDK 说明 |
| Q-09 | 打印样式配置的数据结构是什么？ | PosPrnStyle 相关表/类 |
| Q-10 | 打印异常如何处理和重试？ | 异常处理机制说明 |

### 2.2 侦察输出物

- [ ] 核心实体清单（Printer, Job, Queue, Style）
- [ ] 打印机类型枚举
- [ ] 打印 Handler 映射表
- [ ] 打印任务状态流转图
- [ ] 打印触发入口清单
- [ ] 打印协议差异对比表
- [ ] 异常处理机制说明

---

## 三、已知信息（侦察前）

### 3.1 从项目结构已知

```
nms4pos/
├── nms4cloud-pos10printer/    # 打印服务模块（协议层）
│   └── print/
│       ├── PrinterWorker.java          # 工作线程（虚拟线程）
│       ├── HanYinPrinter.java           # 韩印/浩宇热敏打印机
│       ├── JBTagPrinter.java            # 佳博标签打印机
│       ├── PortHandler.java             # 串口/网络打印机基类
│       ├── GraphicsHandler.java         # 图形驱动打印机
│       └── ...
├── nms4cloud-pos2plugin/      # 收银插件（业务层）
│   └── service/print/
│       └── PosPrnJobService.java        # 打印任务生成
```

### 3.2 从 CLAUDE.md 已知

- 打印机使用虚拟线程调度（`Thread.ofVirtual()`）
- 标签打印机使用 TSPL 协议
- 热敏打印机使用 OPOS SDK
- 7 种打印机处理器类型

### 3.3 从上下文摘要已知

**PrinterWorker.java 处理器选择逻辑**：

```java
switch (printer.getType()) {
  case DRIVER -> handler = new GraphicsHandler();
  case DRIVER_CMD -> handler = new PortHandlerWithDriver();
  case NET, COM, USB, LPT -> {
    PrinterModelEnum printerModel = printer.getModel();
    if (Objects.equals(printerModel, PrinterModelEnum.GP_3150TFN)) {
      handler = new JBTagPrinter();      // 佳博标签打印机
    } else if (Objects.equals(printerModel, PrinterModelEnum.XP_T202UA)) {
      handler = new XpCloudPrinter();    // 芯烨云打印
    } else if (Objects.equals(printerModel, PrinterModelEnum.HY58) || Objects.equals(printerModel, PrinterModelEnum.HY80)) {
      handler = new HanYinPrinter();     // 韩印/浩宇热敏
    } else {
      handler = new PortHandler();       // 通用串口
    }
  }
  case XY_CLOUD -> handler = new XpCloudPrinter();
  case JB_CLOUD -> handler = new JBCloudPrinter();
}
```

**HanYinPrinter.java**：
- 使用 OPOS SDK via JNA
- 支持 OPOS_NET, OPOS_USB, COM 接口
- 关键方法：`openPrinter()`, `closePrinterForce()`, `printStr()`, `handleQRCodeBar()`, `handleBarCodeBar()`

**JBTagPrinter.java**：
- 使用 TSPL 协议
- 支持多种纸张尺寸
- 关键命令：`SIZE`, `GAP`, `CLS`, `CODEPAGE`, `TEXT`, `BARCODE`, `QRCODE`

---

## 四、侦察计划

### 4.1 侦察阶段（DA0-B）

| 步骤 | 动作 | 目标 |
|------|------|------|
| 1 | 搜索所有打印相关 Java 文件 | 建立文件清单 |
| 2 | 读取 PrinterWorker.java | 理解 Handler 选择逻辑 |
| 3 | 读取各 Handler 实现 | 理解协议差异 |
| 4 | 读取 PosPrnJobService | 理解任务生成 |
| 5 | 读取 PosPrnJob/PosPrnQueue 实体 | 理解数据模型 |
| 6 | 搜索打印触发入口 | 理解业务触发点 |
| 7 | 读取 nms4pos-ui 打印页面 | 理解前端交互 |
| 8 | 读取 nms4cloud 打印 API | 理解接口定义 |

### 4.2 侦察优先级

**P0（必须）**：
- PrinterWorker.java（调度核心）
- 各 Handler 实现（协议层）
- PosPrnJobService（任务生成）
- PosPrnJob/PosPrnQueue 实体

**P1（重要）**：
- 打印触发入口（结账流程）
- PosPrnStyle 样式配置
- 前端打印页面

**P2（补充）**：
- nms4cloud 打印 API
- nms4cloud-biz-ui 打印管理

---

## 五、问题基线状态

| 状态 | 说明 |
|------|------|
| 🟡 预填 | 部分假设来自上下文摘要，需要 DA0 侦察验证 |
| 🟢 已验证 | 无 |
| 🔴 待澄清 | 无 |

---

## 六、风险与不确定性

| 风险 ID | 风险描述 | 影响 | 缓解措施 |
|---------|----------|------|----------|
| R-01 | 云打印机（XY_CLOUD, JB_CLOUD）实现未知 | 可能缺失云打印分析 | 侦察时补充读取 |
| R-02 | 打印队列主备切换机制未知 | 可能缺失高可用分析 | 侦察时补充读取 |
| R-03 | 前端打印配置页面可能路径不熟悉 | 可能遗漏前端细节 | 先用 grep 定位文件 |

---

**最后更新**: 2026-08-02
