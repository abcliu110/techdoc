# DA0-G0-B 问题基线
# 打印系统分析初始假设与待验证问题

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA0-PRINT-002 |
| 基准时间 | 2026/08/03 |
| 状态 | 初稿（待验证） |

---

## 1. 架构层面的核心假设

### 1.1 两套打印方案的关系

```
┌─────────────────────────────────────────────────────────────────┐
│                     打印系统架构（假设）                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  pos10printer（旧方案）          pos2plugin（新方案）            │
│  ┌─────────────────┐            ┌─────────────────────────┐     │
│  │ Prn_PrintJob    │◄───────────│ Prn_PrintJob            │     │
│  │ (共享API)       │  共享      │ (增强版)                │     │
│  └─────────────────┘            └─────────────────────────┘     │
│         │                              │                         │
│         ▼                              ▼                         │
│  ┌─────────────────┐            ┌─────────────────────────┐     │
│  │ 简单任务处理器   │            │ PrintJobGenerator       │     │
│  │ (已废弃?)       │            │ (多联票生成)            │     │
│  └─────────────────┘            └─────────────────────────┘     │
│                                         │                        │
│                                         ▼                        │
│                               ┌─────────────────────────┐       │
│                               │ PrinterWorkerService    │       │
│                               │ (线程池管理)            │       │
│                               └─────────────────────────┘       │
│                                         │                        │
│                    ┌────────────────────┼────────────────────┐  │
│                    ▼                    ▼                    ▼  │
│             ┌───────────┐        ┌───────────┐        ┌──────┐ │
│             │本地打印    │        │云打印      │        │远程打印│ │
│             │Driver/Net │        │XY/JB Cloud│        │COM/USB│ │
│             └───────────┘        └───────────┘        └──────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**假设A1.1：** pos10printer 是旧方案，代码可能已废弃
**假设A1.2：** pos2plugin 是当前主力方案
**假设A1.3：** 两者共享 `Prn_PrintJob` API

**待验证：**
- [ ] pos10printer 模块是否有新提交？
- [ ] 是否有业务代码仍调用 pos10printer？
- [ ] Prn_PrintJob 两个版本的差异是什么？

---

### 1.2 打印任务分层架构

**假设A2：Job → Queue → Worker 三层分离**

```
Prn_PrintJob（任务）
    │
    ├── type: 票据类型 (PrnStyleTypeEnum)
    ├── items: 打印项列表
    ├── pID: 物理打印机ID
    └── qID: 所属队列ID

         │
         ▼ 路由分发

PosPrnQueue（队列）
    │
    ├── name: 队列名称
    ├── pID: 绑定打印机
    ├── styleType: 队列专属票据类型
    └── deptLid: 关联出品部门

         │
         ▼ 线程执行

PrinterWorkerService（工作线程）
    │
    ├── handlePrnJob(): 处理打印任务
    ├── getStatus(): 获取打印机状态
    └── restart(): 重启打印机线程

         │
         ▼ 渲染输出

PrintJobHandlerBase（处理器）
    │
    ├── DriverHandler: Windows驱动
    ├── PortHandler: 串口/并口
    ├── JBCloudPrinter: 佳博云
    └── XpCloudPrinter: 芯烨云
```

**待验证：**
- [ ] Queue 和 Worker 的关系是一对一还是一对多？
- [ ] 多个 Queue 可以绑定同一台打印机吗？
- [ ] Worker 线程池的大小如何配置？

---

## 2. 多联票生成假设

### 2.1 联票类型定义

| 联票类型 | 生成方法 | 接收方 | 内容特点 |
|----------|----------|--------|----------|
| 顾客联 | generateCustomerJob | 顾客 | 完整账单、价格明细 |
| 厨房联 | generateKitchenJob | 厨房 | 菜品做法、备注 |
| 传菜联 | generateWaiterJob | 传菜员 | 菜品汇总、分台信息 |
| 标签单 | FoodLabelPrintJobCreator | 厨房 | 条码、桌号、菜品名 |

### 2.2 联票生成决策树

```
业务事件触发（点菜/结账/退菜...）
         │
         ▼
┌────────────────────────────────────────┐
│ 检查 PrintJobTypeSwitch                │
├────────────────────────────────────────┤
│ disabledCustomer = false? ──Yes──► 生成顾客联 │
│ disabledKitchen = false? ──Yes──► 生成厨房联 │
│ disabledWaiter = false? ──Yes──► 生成传菜联 │
└────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ 按出品部门(PosDept)路由厨房联           │
├────────────────────────────────────────┤
│ 菜品A → 出品部门1 → 队列A → 打印机1     │
│ 菜品B → 出品部门2 → 队列B → 打印机2     │
└────────────────────────────────────────┘
```

**假设B1：** 厨房联按菜品出品部门分开打印（一菜一单或多菜一单）
**假设B2：** 传菜联是所有菜品的汇总单
**假设B3：** 打印份数由 numOfKitchen/numOfWaiter/numOfCustomer 控制

**待验证：**
- [ ] generateKitchenJob 是否真的按出品部门拆分？
- [ ] 一道菜能否同时属于多个出品部门？
- [ ] 传菜联和厨房联的内容有何具体差异？

---

### 2.3 打印开关控制矩阵

**假设B4：PrintJobTypeSwitch 是按业务类型配置的**

```
PrintJobTypeSwitch 表结构：
┌─────────┬─────────┬─────────┬────────────────┬────────────────┐
│   LID   │  TYPE   │disabledX│   numOfX       │  适用范围      │
├─────────┼─────────┼─────────┼────────────────┼────────────────┤
│ 账单类型 │ Nodiscount│ false  │ numOfCustomer=1│ 整单结算       │
│ 账单类型 │ CheckOut │ false  │ numOfCustomer=2│ 结账（留底）   │
│ 点菜     │ OrderMenu│ false  │ numOfKitchen=1 │ 新增菜品       │
│ 点菜     │ OrderMenu│ false  │ numOfWaiter=1  │ 传菜           │
└─────────┴─────────┴─────────┴────────────────┴────────────────┘
```

**待验证：**
- [ ] PrintJobTypeSwitch 的粒度是账单级别还是菜品级别？
- [ ] 外卖/自提/堂食的打印配置是否不同？
- [ ] 临时关闭某联打印后，历史任务会受影响吗？

---

## 3. 打印机适配层假设

### 3.1 连接方式与处理器映射

| 连接方式 | 代码 | 处理器 | 配置文件 |
|----------|------|--------|----------|
| DRIVER | 1 | DriverHandler | 打印机名称 |
| NET | 2 | PortHandler (OPOS_NET) | IP:Port |
| COM | 3 | PortHandler (OPOS_LPT) | COM口+波特率 |
| USB | 4 | UsbLptHandler | USB设备ID |
| LPT | 5 | PortHandler (OPOS_LPT) | 并口地址 |
| XY_CLOUD | 6 | XpCloudPrinter | 设备号+密钥 |
| JB_CLOUD | 7 | JBCloudPrinter | 设备号+密钥 |
| DRIVER_CMD | 8 | PortHandlerWithDriver | 驱动+指令 |

### 3.2 打印机型号与品牌映射

**假设C1：型号决定指令集，连接方式决定通信协议**

```
PrinterModelEnum → PrinterBrand（指令集）
PrinterTypeEnum → PrinterType（通信方式）

示例：
EPSON_TM_88IV + NET → ESC/POS指令 + TCP/IP协议
XP_58X + XY_CLOUD → 芯烨指令 + HTTP云API
GP_3150TFN + DRIVER → 驱动渲染 + GDI调用
```

**假设C2：汉印打印机使用专用DLL**

```java
HanYinPrinterDll.java  // 汉印58/80系列专用
HanYinPrinter.java     // 汉印封装
HanYinConstants.java   // 指令常量
```

**待验证：**
- [ ] 同一型号打印机，DRIVER和NET方式的打印效果是否一致？
- [ ] 云打印是否支持所有票据类型？
- [ ] 新增打印机型号需要修改哪些文件？

---

## 4. 打印样式体系假设

### 4.1 样式渲染流程

```
Prn_StyleRow（样式配置）
    │
    ├── name: 样式名称
    ├── type: 票据类型
    └── contents: Prn_StyleContent[]

         │
         ▼

Prn_StyleContent（打印项）
    │
    ├── contentType: TEXT/SQL/LINE/IMG/CUT/BLANK
    ├── printContent: 文本内容/图片路径
    ├── condition: 显示条件
    └── {width, align, fontSize, bold...}

         │
         ▼

渲染引擎（按contentType分发）
    │
    ├── handleText(): 处理文本，支持{$var}参数替换
    ├── handleSqlQuery(): 执行SQL并渲染结果
    ├── handleLine(): 绘制分割线
    ├── handleImg(): 打印图片/条码/二维码
    ├── handleCutPaper(): 切纸
    └── handleBlankLine(): 空白行
```

**假设D1：样式支持动态参数替换**

```java
// 参数格式：{$varName} 或 @{sql:SELECT ...}
// 示例：
// "桌号：{$tableNo}"
// "金额：{$totalAmt}"
```

**假设D2：样式支持条件显示**

```java
// 条件格式：paramName operator value
// 示例：
// "isVip = true"  // VIP会员显示特殊标记
// "amt > 1000"    // 大额订单显示审核提示
```

**待验证：**
- [ ] SQL查询是在渲染时实时执行还是预计算？
- [ ] 参数优先级：tmpParas vs allParas？
- [ ] 条件判断失败时是跳过该项还是打印空值？

---

## 5. 异常处理假设

### 5.1 打印机故障处理流程

**假设E1：打印机故障不阻塞任务队列**

```
打印任务提交
      │
      ▼
┌───────────────────┐
│ 检查打印机状态     │──── FAULT ──→ 记录日志 + 标记故障
│ getStatus()       │
└───────────────────┘
      │ NORMAL
      ▼
┌───────────────────┐
│ 执行打印           │──── FAIL ──→ 重试N次 → 失败
│ handlePrnJob()    │
└───────────────────┘
      │ SUCCESS
      ▼
  更新任务状态
  触发下一任务
```

**假设E2：PrinterWorkerService 维护故障计数器**

```java
// PrinterWorkerService.java
public interface PrinterWorkerService {
    PrinterStatus getStatus(Long printerLid);  // NORMAL/FAULT/BUSY
    long getFault();  // 获取故障打印机数量
    void restart();   // 重启故障打印机
}
```

**待验证：**
- [ ] 重试次数和间隔是多少？
- [ ] 连续失败多少次后标记为FAULT？
- [ ] 故障打印机如何通知管理员？

---

## 6. 前端管理界面假设

### 6.1 PrintMgr 功能模块

```
PrintMgr/
├── 分组1: 基础配置
│   ├── 计算机 (PosDevPage)        // 终端设备管理
│   ├── 打印机 (PosPrnPrinterPage)  // 打印机配置
│   ├── 打印开关 (PrintJobTypeSwitchPage) // 任务开关
│   └── 打印队列 (PosPrnQueuePage)   // 队列管理
│
├── 分组3: 业务关联
│   ├── 出品部门 (PosDeptAndDishPage, FOR_PRN) // 一菜一单
│   ├── 传菜间 (PosWaiterBillSettingPage)      // 多菜一单
│   └── 客单设置 (PosCustomerBillSettingPage)  // 顾客小票
│
├── 分组4: KDS配合
│   ├── 利润部门 (PosDeptPage, FOR_PROFIT)
│   ├── 配菜间 (PosDeptAndDishPage, FOR_PREPARATION)
│   ├── 制作间 (PosDeptAndDishPage, FOR_COOK)
│   └── 菜品超时 (DishOverSet)  // 仅localhost可见
│
└── 票据样式设置
    ├── 收银票据 (6种)
    ├── 后厨票据 (17种)
    ├── 报表票据 (10种)
    ├── 会员与短信 (18种)
    ├── 其他票据 (16种)
    └── WMS票据 (49种)
```

**假设F1：DishOverSet 仅在本地开发环境可见**

```tsx
// PrintMgr/index.tsx
...(isLocalhost ? [{ lid: '35', component: <DishOverSet /> }] : [])
```

**待验证：**
- [ ] 打印队列页面显示哪些实时状态？
- [ ] 能否在管理界面手动重打历史票据？
- [ ] 样式复制功能的实现逻辑？

---

## 7. 待验证问题汇总

### 优先级P0（必须验证）

| ID | 问题 | 验证方法 | 预期结论 |
|----|------|----------|----------|
| Q01 | pos10printer是否仍在使用 | git log + grep调用链 | 已废弃/仍在使用 |
| Q02 | 厨房联是否按出品部分单 | 阅读CookwayPrintDeptPlanner | 是/否 |
| Q03 | 打印任务状态机定义 | 查找枚举/状态常量 | 有/无完整状态机 |
| Q04 | 多联票生成的触发时机 | 追踪DwdBill等业务事件 | 结账时/点菜时/均可 |

### 优先级P1（重要）

| ID | 问题 | 验证方法 | 预期结论 |
|----|------|----------|----------|
| Q11 | 云打印与本地打印的差异 | 对比Handler实现 | 指令差异/无差异 |
| Q12 | 打印机故障恢复机制 | 检查restart逻辑 | 自动/手动 |
| Q13 | 样式参数作用域 | 追踪tmpParas使用 | 正确/需修复 |
| Q14 | 外卖场景的打印特殊性 | 检查PrintJobGenerator | 有/无特殊处理 |

### 优先级P2（补充）

| ID | 问题 | 验证方法 | 预期结论 |
|----|------|----------|----------|
| Q21 | 新增打印机型号的最小改动 | 分析枚举与Handler | 枚举即可/需新增Handler |
| Q22 | 打印任务是否支持撤销 | 检查队列操作API | 支持/不支持 |
| Q23 | 历史打印记录保留策略 | 数据库表设计 | 有/无TTL |

---

## 8. 分析路线图

```
DA0 侦察阶段（当前）
  ├─ G0-A 启动契约 ✅
  ├─ G0-B 问题基线 ✅ ← 当前
  └─ 资源索引建立 ✅

DA1 侦察报告
  └─ 完整模块结构扫描

DA2 概念建模
  └─ 核心实体与枚举定义

DA3 关系建模
  └─ 模块间依赖与调用关系

DA4 规则建模
  └─ 打印开关与分发规则

DA5 不变量建模
  └─ 不可违反的业务约束

DA6 状态机建模
  └─ 打印任务生命周期

DA7 架构决策记录
  └─ 关键设计决策与权衡

DA8 分析总结
  └─ 完整认知地图

V0-V7 验证
  └─ 证据链回溯验证
```

---

**G0-B 状态：✅ 问题基线已建立，待进入DA1侦察阶段**
