# DA0 - 侦察与问题基线

> **SOP-00 §DA0 执行记录**
> 输出：`D:\mywork\techdoc\打印原理\DA0-侦察与问题基线.md`
> 基准时间：2026-08-02
> 仓库基线：nms4pos(72e2b45ef)、nms4pos-ui(bd82c18a)、nms4cloud(cbe1399518)、nms4cloud-biz-ui(b281445a)

---

## 一、侦察范围

### 1.1 四仓库职责划分

| 仓库 | 技术栈 | 打印职责定位 |
|------|--------|------------|
| `nms4pos` | Java/Spring Cloud | **POS 打印核心引擎**：Handler 调度、协议转换、模板渲染、任务调度 |
| `nms4pos-ui` | React/Taro | **POS 前台打印交互**：打印监控看板、样式行编辑器、打印机状态卡片 |
| `nms4cloud` | Java/Spring Cloud | **SaaS 平台打印管理**：打印任务/样式 REST API、打印开关配置、云端存储 |
| `nms4cloud-biz-ui` | React/Antd Pro | **商户后台打印管理**：设备管理、队列监控、样式配置、门店/品牌切换 |

### 1.2 核心文件清单

#### nms4pos（打印引擎）

| 文件路径 | 行数 | 职责 |
|----------|------|------|
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/PosPrnJobServicePlus.java` | 1132 | 打印任务 CRUD、文件存储、Redis 计数 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/handler/PrintHandlerFactory.java` | — | 7 种 Handler 工厂 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/handler/PrinterHandler.java` | — | Handler 接口定义 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/handler/impl/` | — | 7 种 Handler 实现 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/template/` | — | 模板引擎与协议封装 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/scheduler/` | — | Virtual Thread 调度器 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/enums/PrinterModelEnum.java` | — | 打印机型号枚举 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/enums/PrnStyleTypeEnum.java` | — | 票据样式枚举 |
| `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/enums/PrnStyleItemTypeEnum.java` | — | 样式项类型枚举 |

#### nms4cloud（打印管理 API）

| 文件路径 | 职责 |
|----------|------|
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/controller/admin/PosPrnJobController.java` | 打印任务 REST API（/pos_prn_job） |
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/controller/admin/PosPrnStyleController.java` | 打印样式 REST API（/pos_prn_style） |
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/controller/admin/PosPrinterForBizController.java` | 打印机管理 API |
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/service/admin/PosPrnJobServicePlus.java` | 打印任务 Service |
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/service/admin/PosPrnStyleServicePlus.java` | 打印样式 Service |
| `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/service/admin/PosPrnStyleItemServicePlus.java` | 打印样式项 Service |

#### nms4pos-ui（POS 前台）

| 文件路径 | 职责 |
|----------|------|
| `app/pos4desktop/src/pages/FunctionPanel/pages/PrintTaskMonitor/` | 打印任务监控页面 |
| `app/pos4desktop/src/pages/PosPrnStyleRowPage/` | 打印样式行编辑页面 |
| `src/components/PrintInfoModal/` | 打印信息弹窗 |
| `src/components/PrinterTaskBoard/` | 打印机任务看板 |
| `src/components/PrinterTaskCard/` | 打印机任务卡片 |

#### nms4cloud-biz-ui（商户后台）

| 文件路径 | 职责 |
|----------|------|
| `src/pages/PrintMgr/index.tsx` | 打印管理中心主页（设备+样式+队列） |
| `src/components/antd/src/pages/PosPrnPrinterPage/` | 打印机管理组件 |
| `src/components/antd/src/pages/PosPrnQueuePage/` | 打印队列组件 |
| `src/components/antd/src/pages/PosPrnStyleRowPage/` | 打印样式行编辑组件 |
| `src/components/antd/src/pages/PrintJobTypeSwitchPage/` | 打印开关组件 |
| `src/components/antd/src/pages/PosDevPage/` | 设备管理组件 |

---

## 二、核心实体清单

### 2.1 打印机实体 (Printer)

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` / `lid` | Long | 主键/逻辑ID |
| `mid` / `sid` | Long | 商户/门店 |
| `devId` | String | 设备ID（关联 PosDev） |
| `printerType` | Enum | 打印机类型（票据/标签） |
| `printerModel` | Enum | 打印机型号 |
| `printerName` | String | 打印机名称 |
| `ipAddress` | String | 网络打印机IP |
| `port` | Integer | 端口 |
| `usbPath` | String | USB路径 |
| `serialPort` | String | 串口 |
| `baudRate` | Integer | 波特率 |
| `paperWidth` | Integer | 纸宽(mm) |
| `status` | Integer | 状态 |

**打印机型号枚举 (PrinterModelEnum)**：

| 枚举值 | 打印机品牌 | 协议 |
|--------|-----------|------|
| `TSPL_TSC` | 芯烨/TSC | TSPL |
| `ZPL_HIPPO` | 斑马/Zebra | ZPL |
| `ESC` | 佳博/网络/串口 | ESC/POS |
| `OPOS_HIOPOS` | 汉印/OPOS | OPOS SDK |
| `HP_PCL` | HP | PCL |
| `PDF` | PDF虚拟 | PDF |
| `DEFAULT` | 默认 | ESC/POS |

### 2.2 打印任务实体 (PrintJob)

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` / `lid` | Long | 主键/逻辑ID |
| `mid` / `sid` | Long | 商户/门店 |
| `prnStyleLid` | Long | 样式LID |
| `queueLid` | Long | 队列LID |
| `printerLid` | Long | 打印机LID |
| `orderBillLid` | Long | 关联订单LID |
| `jobStatus` | Enum | 任务状态 |
| `retryCount` | Integer | 重试次数 |
| `maxRetries` | Integer | 最大重试 |
| `errorMsg` | String | 错误信息 |
| `printData` | String | 打印数据(JSON) |
| `prnStyleType` | Enum | 样式类型 |
| `createdTime` | DateTime | 创建时间 |
| `printedTime` | DateTime | 打印时间 |
| `archivedTime` | DateTime | 归档时间 |

**任务状态枚举**：

| 状态 | 值 | 说明 |
|------|-----|------|
| `PENDING` | 0 | 待打印 |
| `PRINTING` | 1 | 打印中 |
| `COMPLETED` | 2 | 已完成 |
| `FAILED` | 3 | 失败 |
| `ARCHIVED` | 4 | 已归档 |

### 2.3 打印样式实体 (PrintStyle)

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` / `lid` | Long | 主键/逻辑ID |
| `mid` / `sid` | Long | 商户/门店 |
| `styleType` | Enum | 样式类型 |
| `styleName` | String | 样式名称 |
| `styleContent` | String | 样式内容(JSON) |
| `copies` | Integer | 份数 |
| `printerLid` | Long | 打印机LID |
| `isDefault` | Boolean | 是否默认 |
| `prnStyleItems` | List | 样式项列表 |

### 2.4 打印样式项实体 (PrintStyleItem)

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` / `lid` | Long | 主键/逻辑ID |
| `styleLid` | Long | 样式LID |
| `itemType` | Enum | 项类型 |
| `itemName` | String | 项名称 |
| `itemValue` | String | 项值 |
| `fontSize` | Integer | 字号 |
| `fontWeight` | Enum | 字重 |
| `align` | Enum | 对齐方式 |
| `left` | Integer | 左边距 |
| `top` | Integer | 上边距 |
| `width` | Integer | 宽度 |
| `height` | Integer | 高度 |
| `sortOrder` | Integer | 排序 |

---

## 三、打印样式类型全量清单

### 3.1 票据样式枚举 (PrnStyleTypeEnum)

#### 收银票据 (cashier)
| 枚举值 | 名称 | 触发场景 |
|--------|------|----------|
| `Nodiscount` | 不打折小票 | 无折扣结账 |
| `Discount` | 折扣小票 | 折扣结账 |
| `CheckOut` | 结账单 | 正常结账 |
| `CheckOutFull` | 整单结账小票 | 整单结账 |
| `CashboxPop` | 钱箱弹出 | 现金收款 |

#### 后厨票据 (kitchen)
| 枚举值 | 名称 | 触发场景 |
|--------|------|----------|
| `OrderMenu` | 点菜单 | 落单 |
| `OrderMenuEx` | 点菜单(扩展) | 落单扩展 |
| `OldOrderMenu` | 旧点菜单 | 历史落单 |
| `OldOrderMenuEx` | 旧点菜单(扩展) | 历史落单扩展 |
| `TotalBill` | 全部菜品 | 整单打印 |
| `TotalBillLocal` | 全部菜品(本地) | 本地整单 |
| `ReplaceItem` | 换品单 | 换菜 |
| `TransferTable` | 转台单 | 转台 |
| `TransferMenu` | 转移菜单 | 菜单转移 |
| `HurryMenu` | 催菜单 | 催菜 |
| `BackMenu` | 退菜单 | 退菜 |
| `RespiteMenu` | 暂缓菜单 | 挂起 |
| `UpMenu` | 起叫菜单 | 起叫 |
| `ChangeMenuAmout` | 改数量 | 改数量 |
| `GQBill` | 挂起单 | 挂起 |

#### 报表票据 (report)
| 枚举值 | 名称 |
|--------|------|
| `ShiftReport` | 交班报告 |
| `ReturnDetailsReport` | 退货明细报告 |
| `ShiftReport_SRY` | 收银员交班 |
| `DateSalesReport` | 日销售报告 |
| `DaiDingRenReport` | 待定人报告 |
| `YingYeReport` | 营业报告 |
| `BuMenReport` | 部门报告 |
| `HourSalesReport` | 分时销售报告 |
| `CaiSalesReport` | 菜品销售报告 |
| `BookSum` | 预订汇总 |

#### 会员与短信 (member)
| 枚举值 | 名称 |
|--------|------|
| `MemberSavingBill` | 储值小票 |
| `TuiKaDan` | 退卡单 |
| `HYXFMX` | 会员消费明细 |
| `HYFPMX` | 会员积分明细 |
| `MemberFaKaMingXi` | 发卡明细 |
| `MemberTuiKaMingXi` | 退卡明细 |
| `MemberBirthday` | 生日祝福 |
| `MemberGift` | 会员礼品 |
| `SMS_CRM_REG` | 注册短信 |
| `SMS_CRM_CONSUME` | 消费短信 |
| `SMS_POS_RECHECK_OUT` | 重结账短信 |
| `SMS_CRM_POINT_CHANGE` | 积分变动短信 |
| `SMS_BOOK_SUCCESS` | 预订成功短信 |
| `SMS_BOOK_CANCEL` | 预订取消短信 |
| `SMS_BOOK_OVERTIME` | 预订超时短信 |
| `SMS_QUEUE` | 排队短信 |
| `SMS_SAVE_WINE_OVERTIME` | 存酒超时短信 |
| `SMS_SAVE_WINE` | 存酒短信 |
| `SMS_PICK_WINE` | 取酒短信 |
| `SMS_CRM_RECHARGE` | 充值短信 |
| `SMS_CREDIT_WINE` | 赊酒短信 |

#### 其他票据 (other)
| 枚举值 | 名称 |
|--------|------|
| `OrderBill` | 订单票据 |
| `QueueBill` | 排队票据 |
| `ReturnBill` | 退货票据 |
| `XfdInfoBill` | 消费信息票据 |
| `XfcpInfoBill` | 消费菜品票据 |
| `FoodLabel` | 菜品标签 |
| `JFDHCZ` | 积分兑换充值 |
| `CunJiuDan` | 存酒单 |
| `MultiCunJiuDan` | 多联存酒单 |
| `MultiBackWineDan` | 多联退酒单 |
| `QuJiuDan` | 取酒单 |
| `MultiQuJiuDan` | 多联取酒单 |
| `OrderBillManagement` | 订单票据管理 |

#### WMS票据 (wms)
50+ 种仓储供应链相关票据，详见 PrintMgr 源码。

---

## 四、打印协议差异对比

| 协议 | 打印机 | 通信方式 | 命令集 | 模板语言 |
|------|--------|----------|--------|----------|
| **TSPL** | 芯烨、TSC | 网络/USB/串口 | TSPL | 文本+变量 |
| **ZPL** | 斑马、Zebra | 网络/USB | ZPL II | ^BA/^FO |
| **ESC/POS** | 佳博、爱普生 | 网络/串口 | ESC/POS | 字节流 |
| **OPOS** | 汉印 | OPOS SDK | OPOS | 托管接口 |
| **PCL** | HP | 网络 | PCL 5 | 页面描述 |
| **PDF** | 虚拟 | 文件 | PDF | 二进制 |

---

## 五、打印触发入口分析

### 5.1 结账流程打印触发

```
结账完成 (CloseMpScHandler)
    │
    ├─→ 打印客单 (CheckOut/CheckOutFull)
    │       └─→ PosPrnJobServicePlus.create()
    │               ├─→ 写入文件存储
    │               ├─→ Redis 计数
    │               └─→ 发布 PrintTaskCreated 消息
    │
    ├─→ 打印厨房票据 (根据出品部门)
    │       └─→ PosPrnJobServicePlus.create()
    │
    └─→ 弹出钱箱 (CashboxPop)
            └─→ 触发钱箱 Handler
```

### 5.2 打印触发方式

| 触发方式 | 说明 | 代码位置 |
|----------|------|----------|
| **同步打印** | 结账时立即打印 | CloseMpScHandler |
| **异步打印** | 任务入队，后台打印 | PosPrnJobServicePlus.create() |
| **手动补打** | 前台/后台触发重打 | reprint() |
| **定时打印** | 交班报告等定时任务 | 定时器调度 |

---

## 六、打印 Handler 映射

| Handler类型 | 协议 | 主要品牌 | 实现类 |
|-------------|------|----------|--------|
| TSPL | TSPL | 芯烨、TSC | `TsplPrinterHandler` |
| ZPL | ZPL | 斑马 | `ZplPrinterHandler` |
| ESC | ESC/POS | 佳博、爱普生 | `EscPrinterHandler` |
| OPOS | OPOS | 汉印 | `OposPrinterHandler` |
| PCL | PCL | HP | `PclPrinterHandler` |
| PDF | PDF | 虚拟 | `PdfPrinterHandler` |
| DEFAULT | ESC/POS | 通用 | `DefaultPrinterHandler` |

---

## 七、架构分层

```
┌─────────────────────────────────────────────────────────────┐
│  业务层 (Business)                                          │
│  CloseMpScHandler (结账编排) → 打印触发                      │
│  CloseBillService → 打印客单                                 │
│  KitchenDisplayService → 打印厨打                            │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  队列层 (Queue)                                             │
│  PosPrnJobServicePlus → 任务 CRUD、文件存储、Redis 计数       │
│  PosPrnQueueService → 队列管理                               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  协议层 (Protocol)                                          │
│  PrintHandlerFactory → Handler 分发                         │
│  7 种 Handler 实现 → 协议转换                                │
│  Virtual Thread Scheduler → 打印调度                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  模板层 (Template)                                          │
│  PrintStyleEngine → 样式解析                                │
│  TemplateRenderer → 模板渲染                                │
│  样式项类型：文本、图片、一维码、二维码、分割线、表格           │
└─────────────────────────────────────────────────────────────┘
```

---

## 八、异常处理机制

### 8.1 任务失败处理

| 阶段 | 策略 |
|------|------|
| 打印失败 | `markFailed()` → 重试 `retryCount < maxRetries` |
| 归档失败任务 | `archiveFailed()` → 定期清理 |
| 网络异常 | Handler 抛出 `PrintException` → 上层捕获重试 |
| 设备离线 | 状态更新 → 前台告警 |

### 8.2 消息事件

| 事件 | 说明 |
|------|------|
| `PrintTaskCreated` | 任务创建 |
| `PrintTaskUpdated` | 任务状态更新 |
| `PrintTaskDeleted` | 任务删除 |
| `PrintTaskReprinted` | 任务重打 |

---

## 九、问题基线（待 DA1-DA8 解答）

### Q-01: 打印任务如何保证可靠性？
- 重试机制参数？
- 失败任务如何恢复？
- 文件存储与 Redis 计数一致性？

### Q-02: 多打印机如何负载均衡？
- 同一队列多打印机配置？
- 任务分发策略？
- 打印优先级？

### Q-03: 样式模板如何实现跨协议兼容？
- TSPL/ZPL/ESC 三种协议样式是否共用同一模板？
- 协议差异如何抽象？

### Q-04: 打印性能瓶颈在哪里？
- Virtual Thread 调度策略？
- 文件 I/O 性能？
- 网络打印机延迟？

### Q-05: 门店离线场景如何处理？
- nms4pos vs nms4cloud 打印职责边界？
- 云端任务如何同步到本地？

### Q-06: 打印日志与审计如何实现？
- 打印记录是否持久化？
- 如何追溯重打？
- 如何统计打印量？

### Q-07: 样式编辑器的实现机制？
- 行编辑器组件职责？
- 样式项如何序列化？
- 预览功能如何实现？

### Q-08: 打印开关的粒度控制？
- 按门店/品牌/打印机/样式类型？
- 运行时动态开关？
- 默认值逻辑？

### Q-09: 票据类型扩展机制？
- 新增票据类型流程？
- 样式模板版本管理？
- 默认样式如何生成？

### Q-10: 厨打与客单的打印时序？
- 结账完成后厨打/客单的打印顺序？
- 是否支持并行打印？
- 如何避免票据乱序？

---

## 十、侦察结论

### 10.1 既有知识确认

| 假设 | 状态 | 说明 |
|------|------|------|
| AS-01: 7 种 Handler | ✅ 确认 | HandlerFactory + impl 目录 |
| AS-02: 文件存储 | ✅ 确认 | PosPrnJobServicePlus.keepToFile() |
| AS-03: Redis 计数 | ✅ 确认 | 15分钟过期 TTL |
| AS-04: Virtual Thread | ✅ 确认 | Thread.ofVirtual() |
| AS-05: 100+ 票据类型 | ✅ 确认 | 6大类，含 WMS 票据 |

### 10.2 新发现

1. **nms4cloud 打印管理**：`nms4cloud-pos` 模块提供完整的打印 REST API，与 `nms4pos` 打印引擎是并行实现
2. **PrintMgr 架构**：nms4cloud-biz-ui 采用主面板+模态框架构，左侧设备/队列，右侧样式管理
3. **样式同步能力**：支持门店间/品牌间样式复制（CopyStyleModal）
4. **打印开关细分**：支持按任务类型（PrintJobTypeSwitchPage）控制开关
5. **KDS 集成**：出品部门/传菜间/配菜间/制作间四类厨房区域配置

---

**DA0 侦察结论**：侦察范围已覆盖 4 仓库核心打印代码，核心实体、协议、样式类型已完整梳理。问题基线 10 个问题将指导后续 DA1-DA8 深度分析。
