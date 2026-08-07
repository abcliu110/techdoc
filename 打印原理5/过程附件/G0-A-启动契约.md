# G0-A - 启动契约

> 阶段：G0 门禁 · 启动契约
> 目标系统：打印系统
> 分析深度：标准级（16 文件）
> 日期：2026-08-04
> 状态：✅ 已启动

---

## 1. 分析目标与范围

### 1.1 分析对象

**打印系统**（Print System）

负责餐饮 POS 场景下各类票据、单据的生成与打印，核心功能包括：
- 收银小票打印（顾客联）
- 厨房票据打印（厨房联）
- 划菜单打印（传菜联）
- 各类报表打印（交班单、营业报表等）
- 标签打印（菜品标签、条码）
- 会员短信凭证打印
- WMS 仓储单据打印

### 1.2 分析边界

**纳入范围：**
- 打印任务生命周期管理（生成→队列→打印→状态追踪）
- 打印样式系统（样式配置、内容渲染）
- 打印机设备管理（连接方式、状态监控）
- 打印队列与打印机关联（主备机机制）
- 前端打印监控与告警

**不纳入范围：**
- 打印机硬件驱动底层协议（ESC/POS 字节协议细节）
- 第三方云打印 API 具体实现
- POS 订单业务逻辑（仅关注打印触发点）

---

## 2. 证据基线

### 2.1 核心证据来源

| 证据类别 | 来源 | 说明 |
|---------|------|------|
| **E-SRC 源码** | `nms4pos/`、`nms4cloud/`、`nms4cloud-biz-ui/`、`nms4pos-ui/` | 4 个仓库的打印相关代码 |
| **E-DAT 数据结构** | `pos_prn_job`、`pos_prn_printer`、`pos_prn_queue`、`pos_prn_style_row` 等表 | 数据库表结构与字段定义 |
| **E-ENU 枚举定义** | `PrnJobStatusEnum`、`PrinterTypeEnum`、`PrnJobPurposeEnum`、`PrnStyleTypeEnum` | 打印相关业务枚举 |

### 2.2 核心代码文件清单

**后端核心（nms4pos）：**

| 文件 | 行数 | 职责 |
|------|------|------|
| `PrintJobGenerator.java` | 1127 | 打印任务生成（按联分类：小票/厨房/传菜） |
| `PosPrnJobServicePlus.java` | 1132 | 打印任务服务（CRUD、文件缓存、重打） |
| `PrinterWorker.java` | 100 | 打印机线程（阻塞队列、任务分发） |
| `PrintJobHandlerBase.java` | 413 | 打印处理器基类（条件判断、参数替换） |
| `DriverHandler.java` | 834 | Windows 驱动打印（图形渲染） |
| `PortHandler.java` | ~400 | 串口/USB/并口打印（ESC/POS 指令） |
| `JBCloudPrinter.java` | ~300 | 佳博云打印机 |
| `XpCloudPrinter.java` | ~300 | 芯烨云打印机 |
| `HanYinPrinter.java` | ~250 | 汉印打印机 |
| `XYTagPrinter.java` | ~200 | 迅享标签打印机 |
| `JBTagPrinter.java` | ~200 | 佳博标签打印机 |

**前端核心（nms4cloud-biz-ui）：**

| 页面 | 路径 | 职责 |
|------|------|------|
| 打印任务监控 | `src/pages/PrintMgr/` | 打印任务列表、状态监控 |
| 打印告警弹窗 | `PrinterAlertBubble` | 打印机故障告警 |

### 2.3 核心实体与枚举

**打印任务（PosPrnJob）：**
```
lid, bizBillId, type_(PrnStyleTypeEnum), purpose(PrnJobPurposeEnum),
prnCount, prnQueueLid, prnPrinterLid, status(PrnJobStatusEnum),
print, printAt, failureReason, deleted
```

**打印机（PosPrnPrinter）：**
```
lid, name, pcLid, type(PrinterTypeEnum), model(PrinterModelEnum),
extraInfo(连接参数)
```

**打印队列（PosPrnQueue）：**
```
lid, name, pcLid, primaryPrinter(主打印机 LID), standbyPrinter(备用打印机 LID)
```

**打印样式行（PosPrnStyleRow）：**
```
dsId, styleType, showIndex, displayCondition, conditionDsId,
conditionOperator, conditionValue, summarize, summarizeColName
```

---

## 3. 分析流程规划

### 3.1 执行链

```
G0-A（启动契约）→ G0-B（问题基线）→ DA0（侦察报告）
    → DA1（业务切面）→ DA2（概念字典）→ DA3（关系分析）
    → DA4（规则分析）→ DA5（数据模型）→ DA6（交互流程）
    → DA7（实现映射）→ DA8（收敛分析）
    → 理解层文档（5个）
    → G5（验收）
```

### 3.2 文档产出清单

| 序号 | 文件 | 阶段 | 状态 |
|------|------|------|------|
| 1 | G0-A-启动契约.md | G0 | ⬅️ 当前 |
| 2 | G0-B-问题基线.md | G0 | 待生成 |
| 3 | DA0-侦察报告.md | DA0 | 待生成 |
| 4 | DA1-业务切面分析.md | DA1 | 待生成 |
| 5 | DA2-概念字典.md | DA2 | 待生成 |
| 6 | DA3-关系分析.md | DA3 | 待生成 |
| 7 | DA4-规则分析.md | DA4 | 待生成 |
| 8 | DA5-数据模型.md | DA5 | 待生成 |
| 9 | DA6-交互流程.md | DA6 | 待生成 |
| 10 | DA7-实现映射.md | DA7 | 待生成 |
| 11 | DA8-收敛分析.md | DA8 | 待生成 |
| 12 | 00-十分钟读懂.md | 理解层 | 待生成 |
| 13 | 01-业务全景.md | 理解层 | 待生成 |
| 14 | 02-典型故事.md | 理解层 | 待生成 |
| 15 | 03-失败恢复.md | 理解层 | 待生成 |
| 16 | 04-设计与实现.md | 理解层 | 待生成 |
| 17 | 05-证据与未知.md | 理解层 | 待生成 |

---

## 4. 分析方法约定

### 4.1 稳定 ID 体系

使用 SOP-00 定义的稳定 ID 前缀：

| 前缀 | 含义 | 示例 |
|------|------|------|
| `DQ-*` | 数据质量问题 | `DQ-001` 打印任务状态丢失 |
| `SC-*` | 切片/场景 | `SC-001` 厨房联打印流程 |
| `BC-*` | 业务概念 | `BC-001` 打印任务 |
| `REL-*` | 关系 | `REL-001` 队列-打印机 |
| `BR-*` | 业务规则 | `BR-001` 主备打印机切换规则 |
| `INV-*` | 不变量 | `INV-001` 任务状态流转 |
| `SM-*` | 风格/样式 | `SM-001` 样式条件渲染 |
| `IX-*` | 索引/性能 | `IX-001` 队列查询索引 |
| `MAP-*` | 映射 | `MAP-001` 枚举映射 |

### 4.2 证据协议

| 证据类型 | 要求 |
|---------|------|
| E-SRC | 标注文件名与行号范围 |
| E-DAT | 标注表名与字段名 |
| E-ENU | 标注枚举类全限定名 |
| E-RUN | 标注运行时行为（服务名、接口路径） |
| E-CON | 标注配置项（配置键、YAML 路径） |
| E-DOC | 标注参考文档 |

---

## 5. 团队与职责

| 角色 | 职责 | 当前负责人 |
|------|------|-----------|
| 分析组长 | 整体协调、质量把控 | Claude Code |
| DA0 侦察 | 证据收集、基线建立 | Claude Code |
| DA1-DA8 | 各阶段深度分析 | Claude Code |
| 理解层撰写 | 主文档撰写 | Claude Code |

---

## 6. 启动条件确认

- [x] 分析目标已明确
- [x] 证据来源已识别（4 个仓库）
- [x] 核心代码已读取（PrintJobGenerator、PosPrnJobServicePlus、PrinterWorker 等）
- [x] 核心枚举已读取（PrnJobStatusEnum、PrinterTypeEnum 等）
- [x] 文档结构已规划（17 个文件）
- [x] 输出目录已创建

**启动时间：2026-08-04**
**预计完成：待评估后补充**

---

## 7. 风险与假设

### 7.1 已识别风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| 云打印机 API 细节不透明 | DA7 实现映射可能不完整 | 以云打印 Handler 源码为准 |
| 样式系统前端配置逻辑未深入 | SM-* 切片可能不完整 | 补充前端代码阅读 |

### 7.2 关键假设

| 假设 | 说明 |
|------|------|
| 打印任务文件缓存用于离线场景 | 门店 POS 离线时任务持久化 |
| 主备打印机切换在 PrinterWorker 层 | 待 DA6 确认 |

---

**启动契约已签署，分析正式启动。**
