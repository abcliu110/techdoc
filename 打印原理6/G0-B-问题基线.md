# G0-B 问题基线

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | 打印相关模块 |
| 任务模式 | 认知重建 |
| 基线时间 | 2026-08-04 |

---

## 一、已知信息盘点

### 1.1 核心实体（全量）

| 实体 | 说明 | 仓库 |
|---|---|---|
| `PosPrnPrinter` | 打印机配置（类型/品牌/型号/连接参数） | pos2plugin |
| `PosPrnQueue` | 打印队列（主打印机+备用打印机+打印样式） | pos2plugin |
| `PosPrnJob` | 打印任务（任务详情、打印次数、关联单据） | pos2plugin |
| `PosPrnPrinterTransfer` | 打印机转发规则（源→目标） | pos2plugin |

### 1.2 枚举定义（全量）

**PrinterType（打印机类型）**
| 枚举值 | 说明 |
|---|---|
| `OPOS_NET` | 网口打印机（OPOS协议） |
| `Com` | 串口打印机 |
| `OPOS_LPT` | 并口打印机 |
| `OPOS_USB` | USB打印机（OPOS协议） |
| `Driver` | Windows驱动打印机（图形模式） |
| `Driver_CMD` | Windows驱动打印机（指令模式） |
| `Cloud` | 云打印机（XY_CLOUD/JB_CLOUD） |

**PrinterStatus（打印机状态）**
| 枚举值 | code | 说明 |
|---|---|---|
| `DEFAULT` | 0 | 无状态/离线 |
| `FAULT` | 1 | 关闭/故障 |
| `NORMAL` | 2 | 正常就绪 |
| `BUSY` | 3 | 正在打印 |

**PrinterModelEnum（打印机型号）**
| 枚举值 | 说明 |
|---|---|
| `GP_R320C` | GP热敏打印机 |
| `EPSON_TM_220B/T_T81/TM_88IV/T_T58` | 爱普生系列 |
| `BTP_98NP` | 北洋打印机 |
| `STAR_TSP700/SP700/TCP400` | 之星系列 |
| `XP_80X/76X/58X` | 芯燚系列 |
| `HS_80` | 浩顺打印机 |
| `GP_3150TFN` | GP标签打印机 |
| `XP_T202UA` | 芯燚标签打印机 |
| `HY58/HY80` | 汉印系列 |

**PrinterBrand（打印机品牌）**（deprecated/废弃）
> 代码中同时存在 `PrinterBrand` 和 `PrinterModelEnum`，存在概念冗余。

### 1.3 核心服务（全量）

| 服务 | 职责 | 仓库 |
|---|---|---|
| `PrinterWorker` | 打印机线程：轮询状态、处理任务、故障重发 | pos3boot |
| `PrinterWorkerService` | 打印机线程管理接口 | pos2plugin |
| `PosPrnPrinterTransferServicePlus` | 打印机转发规则管理（源→目标映射） | pos2plugin |
| `PrintUtil` | 打印任务分发工具 | pos2plugin |
| `PosPrnQueueServicePlus` | 打印队列管理 | pos2plugin |
| `PosPrnJobServicePlus` | 打印任务管理（持久化/归档） | pos2plugin |

### 1.4 打印处理器（全量）

| 处理器 | 支持类型 | 说明 |
|---|---|---|
| `GraphicsHandler` | Driver | Windows图形打印 |
| `PortHandlerWithDriver` | Driver_CMD | 驱动指令打印 |
| `PortHandler` | NET/COM/USB/LPT | 通用串口/网口打印 |
| `XpCloudPrinter` | XY_CLOUD | 芯燚云打印 |
| `JBCloudPrinter` | JB_CLOUD | 精打云打印 |
| `JBTagPrinter` | GP_3150TFN | 标签打印 |
| `XYTagPrinter` | XP_T202UA | 标签打印 |
| `HanYinPrinter` | HY58/HY80 | 汉印打印机 |

### 1.5 数据关系

```
PosPrnQueue（打印队列）
  ├── primaryPrinter: 主打印机LID列表（逗号分隔）
  ├── standbyPrinter: 备用打印机LID列表（逗号分隔）
  └── prnStyleLid: 打印样式LID

PosPrnPrinter（打印机配置）
  ├── type: PrinterType
  ├── model: PrinterModelEnum
  ├── brand: PrinterBrand（废弃）
  └── extraInfo: 连接参数（IP/端口/串口配置等）

PosPrnPrinterTransfer（转发规则）
  ├── sourcePrinterLid → targetPrinterLid
  └── 触发时机：源打印机故障时，pending任务重分发到目标打印机

PosPrnJob（打印任务）
  ├── prnQueueLid: 所属队列
  ├── type: PrnStyleTypeEnum（票据类型）
  ├── rows: 打印行配置
  └── prnCount: 已打印次数（补打标识）
```

---

## 二、待探索问题清单

### 2.1 架构问题
- [ ] 云打印（XY_CLOUD/JB_CLOUD）与本地打印的技术边界是什么？
- [ ] `PrinterBrand` 与 `PrinterModelEnum` 是否存在概念重叠需要合并？
- [ ] pos10printer（桌面应用）与pos3boot（服务）的关系是什么？

### 2.2 流程问题
- [ ] 打印任务的完整生命周期是什么？（提交→排队→分发→打印→归档）
- [ ] 打印机故障时的重试/重发机制是如何工作的？
- [ ] 补打任务的处理逻辑是什么？

### 2.3 前端问题
- [ ] 前端打印组件如何与后端交互？
- [ ] 打印样式（PosPrnStyle）是如何定义和管理的？
- [ ] 标签打印与票据打印的流程差异是什么？

---

## 三、基线结论

**已识别实体：4个**（Printer/Queue/Job/Transfer）
**已识别枚举：4组**（Type/Status/Model/Brand）
**已识别服务：6个**
**已识别处理器：8个**

**架构特征：**
- 打印模块分布在 pos2plugin（插件层）和 pos3boot（服务层）
- 核心架构：PrinterWorker线程模型 + PrintJobHandler策略模式
- 可靠性机制：主备打印机 + 转发规则 + 任务重发

---

## G0-B 门禁结论：通过

问题基线已建立，待探索问题清单已明确，可进入 DA1 业务切面分析。
