# DA0-G0-A 启动契约
# 打印系统业务分析任务

## 任务基本信息

| 属性 | 值 |
|------|-----|
| 任务编号 | DA0-PRINT-001 |
| 任务名称 | 打印系统全面分析 |
| 启动时间 | 2026/08/03 |
| 分析对象 | 餐饮POS打印模块（pos2plugin + pos10printer） |
| 分析模式 | 认知重建（只读分析） |
| 交付目录 | D:\mywork\techdoc\打印原理 |

---

## G0-A 启动契约检查清单

### A1. 分析目标确认

**主目标：**
- 完整理解打印系统的业务架构和技术实现
- 建立打印系统的完整认知地图
- 识别两套并行打印方案（pos10printer旧 vs pos2plugin新）的关系与演进

**边界范围：**
- ✅ 后厨打印（厨房联/传菜联/标签单）
- ✅ 前台打印（顾客联/结账单/收银票据）
- ✅ 报表打印（交班单/销售报表/会员报表）
- ✅ 短信通知（CRM/排队/预定）
- ✅ WMS供应链票据
- ❌ 排除：第三方支付打印（独立模块）

### A2. 分析深度约定

| 层级 | 目标 | 验证要求 |
|------|------|----------|
| L1-结构 | 模块划分、包结构、依赖关系 | 完整的目录树/模块关系图 |
| L2-实体 | 核心数据模型、状态机、枚举定义 | ER图 + 状态转换图 |
| L3-流程 | 打印任务生成→分发→执行→完成全链路 | 时序图 + 关键决策点 |
| L4-规则 | 联票生成规则、打印机路由规则、条件判断 | 规则矩阵表 |
| L5-异常 | 故障恢复、重试机制、状态回滚 | 异常处理流程图 |

### A3. 业务切片优先级

| 优先级 | 切片ID | 切片名称 | 配额 | 核心里程碑 |
|--------|--------|----------|------|------------|
| P0 | SC-P0-001 | 打印任务从创建到完成的完整流程 | 35% | 理解Job→Queue→Worker三层架构 |
| P0 | SC-P0-002 | 多联票生成机制（顾客联/厨房联/传菜联） | 25% | 理解PrintJobGenerator核心逻辑 |
| P1 | SC-P1-001 | 打印机类型与品牌适配层 | 15% | 理解Driver/Net/Com/Cloud多态 |
| P1 | SC-P1-002 | 打印样式管理与渲染 | 15% | 理解PrnStyleRow与渲染引擎 |
| P2 | SC-P2-001 | 打印开关与任务分发控制 | 10% | 理解PrintJobTypeSwitch机制 |

### A4. 双向追溯通道

**正向追溯（语义链）：**
```
PosPrnPrinter(物理设备)
  ↓ 关联
PosPrnQueue(打印队列/路由)
  ↓ 包含
PrintJobTypeSwitch(任务开关)
  ↓ 触发
PrintJobGenerator(任务生成器)
  ↓ 产出
Prn_PrintJob(打印任务)
  ↓ 分发
PrinterWorkerService(打印机工作线程)
  ↓ 执行
PrintJobHandlerBase(任务处理器)
  ↓ 渲染
Prn_StyleRow(打印样式)
  ↓ 输出
物理打印机
```

**反向追溯（证据链）：**
```
物理打印机输出 ← Prn_StyleRow.contentType
Prn_StyleRow ← Prn_PrintJob.items
Prn_PrintJob ← PrintJobGenerator.generateXxxJob()
PrintJobGenerator ← 业务事件触发(DwdBill/SmsJob)
PrintJobTypeSwitch ← 每业务类型开关配置
```

### A5. 五类事实分离约定

| 类别 | 内容 | 证据来源 |
|------|------|----------|
| 业务认知 | 什么场景打印什么票据 | PrnStyleTypeEnum枚举值 + 注释 |
| 设计意图 | 为什么这样设计多联票 | PrintJobGenerator方法命名 + 参数注释 |
| 代码能力 | 系统能做什么 | Handler实现类 + Service方法签名 |
| 部署配置 | 打印机如何连接 | PrinterTypeEnum + extraInfo字段 |
| 运行事实 | 实际运行状态 | 暂无（生产环境数据） |

### A6. 交付物清单

| 编号 | 交付物 | 格式 | 对应SOP节点 |
|------|--------|------|-------------|
| D01 | DA0-G0-A 启动契约 | .md | G0-A |
| D02 | DA0-G0-B 问题基线 | .md | G0-B |
| D03 | DA1-侦察报告 | .md | DA1 |
| D04 | DA2-概念建模 | .md | DA2 |
| D05 | DA3-关系建模 | .md | DA3 |
| D06 | DA4-规则建模 | .md | DA4 |
| D07 | DA5-不变量建模 | .md | DA5 |
| D08 | DA6-状态机建模 | .md | DA6 |
| D09 | DA7-架构决策记录 | .md | DA7 |
| D10 | DA8-分析总结 | .md | DA8 |
| D11 | 00-04-理解层主文档 | .md | V-Master |
| D12 | V0-V7 验证报告 | .md | V0-V7 |

---

## G0-B 问题基线（初始假设，待验证）

### 核心假设

1. **两套方案关系**：
   - pos10printer 是旧方案，已基本废弃
   - pos2plugin 是新方案，承担所有打印职责
   - 两者共享部分API（如Prn_PrintJob）

2. **多联票生成逻辑**：
   - 一笔订单可生成顾客联 + 厨房联 + 传菜联
   - 通过PrintJobTypeSwitch控制各联是否打印
   - 通过出品部门(PosDept)决定厨房联路由

3. **打印机多态实现**：
   - 支持8种连接方式（DRIVER/NET/COM/USB/LPT/XY_CLOUD/JB_CLOUD/DRIVER_CMD）
   - 支持17种打印机型号（EPSON/STAR/BTP/XP/汉印等）
   - 通过PrinterBrand和PrinterType映射到具体Handler

4. **打印样式体系**：
   - PrnStyleTypeEnum定义了73种票据类型
   - 每种类型对应一个Prn_StyleRow样式配置
   - 支持条件显示（isConditionOk）

### 待验证问题

| # | 问题 | 优先级 | 验证方法 |
|---|------|--------|----------|
| Q1 | pos10printer是否仍在生产使用？ | P0 | grep代码调用链 |
| Q2 | PrintJobGenerator.generateCustomerJob vs generateKitchenJob的调用时机？ | P0 | 追踪业务触发点 |
| Q3 | 多联票如何避免重复打印同一菜品？ | P1 | 分析分单逻辑 |
| Q4 | 打印机故障时任务是否进入重试队列？ | P1 | 检查异常处理 |
| Q5 | 云打印机(XY_CLOUD/JB_CLOUD)与本地打印的优先级？ | P2 | 检查分发逻辑 |

---

## 分析资源索引

### 分析仓库清单

| 仓库 | 路径 | 打印相关模块 |
|------|------|-------------|
| nms4pos | D:\mywork\nms4pos | pos2plugin(新), pos10printer(旧) |
| nms4cloud | D:\mywork\nms4cloud | pos2plugin后端API |
| nms4cloud-biz-ui | D:\mywork\nms4cloud-biz-ui | PrintMgr管理页面 |
| nms4pos-ui | D:\mywork\nms4pos-ui | PrintTaskMonitor监控页面 |

### 关键源码文件

| 文件 | 用途 | LOC |
|------|------|-----|
| PrintJobGenerator.java | 多联票生成核心逻辑 | ~1127行 |
| PrinterWorkerService.java | 打印机线程管理 | ~30行(接口) |
| PrintJobHandlerBase.java | 打印处理器基类 | ~417行 |
| DriverHandler.java | Windows驱动打印 | ~? |
| PortHandler.java | 串口/并口打印 | ~? |
| JBCloudPrinter.java | 佳博云打印 | ~? |
| XpCloudPrinter.java | 芯烨云打印 | ~? |

### 前端关键文件

| 文件 | 用途 |
|------|------|
| PrnStyleTypeEnum.ts | 票据类型枚举(73种) |
| PrinterModelEnum.ts | 打印机型号枚举(17种) |
| PrinterTypeEnum.ts | 连接方式枚举(8种) |
| PrintJobTypeSwitchService.ts | 打印开关API |
| PrintMgr/index.tsx | 打印管理主页面 |
| PrintMgr/components/DishOverSet | KDS超时设置 |

---

## 准入检查

- [x] 分析目标已明确
- [x] 深度约定已确认
- [x] 业务切片已排序
- [x] 追溯通道已建立
- [x] 事实分类已约定
- [x] 交付物清单已锁定
- [x] 问题基线已初始化
- [x] 资源索引已建立

**G0-A 状态：✅ 通过，可进入DA1侦察阶段**
