# DA3 - 关系分析：打印功能实体关系

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 核心实体关系图

### 1.1 实体关系概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              业务层（Business）                               │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    generates    ┌──────────────────┐                     │
│  │   DwdBill    │ ────────────→ │ PrintJobGenerator │                     │
│  │   (账单)     │   调用生成      │                  │                     │
│  └──────────────┘               └────────┬─────────┘                     │
│                                          │                                 │
│  ┌──────────────┐                        │ creates                         │
│  │   DwdFood    │ ──────────────────────┤                                 │
│  │   (菜品明细)  │                        │                                 │
│  └──────────────┘                        ▼                                 │
│                               ┌──────────────────┐     persists      ┌─────┐│
│  ┌──────────────┐   使用模板   │ PosPrnJobService │ ──────────────→ │.job ││
│  │PosPrnStyleRow│ ──────────→ │     Plus        │                 │file ││
│  │  (样式行)    │             └────────┬─────────┘                 └─────┘│
│  └──────────────┘                      │                                 │
│                               ┌────────┴────────┐                         │
│                               ▼                 ▼                         │
│                    ┌─────────────────┐  ┌─────────────────┐              │
│                    │PosPrnQueueService│  │ PrintJobInitUtil │              │
│                    │     Plus        │  │   (内容初始化)    │              │
│                    └────────┬────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ dispatch
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              队列层（Queue）                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                               ┌───────────────┐                            │
│                               │  PosPrnQueue  │                            │
│                               │   (打印队列)   │                            │
│                               └───────┬───────┘                            │
│                          uses         │ uses                               │
│                    ┌─────────────────┐ │ ┌─────────────────┐              │
│                    │PosCustomerBill │ │ │PosWaiterBill    │              │
│                    │  Setting       │ │ │  Setting        │              │
│                    │ (顾客联设置)    │ │ │ (传菜联设置)    │              │
│                    └─────────────────┘ │ └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ selects
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              打印机层（Printer）                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                    ┌───────────────────────┐                                │
│                    │   PosPrnPrinter      │                                │
│                    │     (打印机)         │                                │
│                    └─────────┬───────────┘                                │
│                              │                                             │
│              ┌───────────────┼───────────────┐                            │
│              │               │               │                            │
│              ▼               ▼               ▼                            │
│        ┌──────────┐   ┌──────────┐   ┌──────────┐                        │
│        │PrinterWorker│ │PrinterWorker│ │PrinterWorker│                     │
│        │ (Worker1) │   │ (Worker2) │   │ (Worker3) │                      │
│        └──────────┘   └──────────┘   └──────────┘                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 实体关系详解

### 2.1 业务实体 ↔ 打印任务

```
DwdBill ─────────────────────────────────────────────────────────
  │                                                          │
  ├─ lid (账单lid) ──────────→ bizBillId (打印任务关联单号)  │
  │                                                          │
  ├─ DwdFood[] ────────────────→ 打印内容（菜品明细）         │
  │                                                          │
  └─ DwdPay[] ─────────────────→ 打印内容（支付信息）         │
                                                           
点菜/加菜 ──────────→ generateKitchenJob ────→ 厨房联打印    │
结账 ──────────────→ generateCustomerJob ────→ 顾客联打印    │
划菜 ──────────────→ generateWaiterJob ──────→ 传菜联打印    │
```

**关联规则**：
- 一个账单可生成多张打印任务（顾客联+厨房联+传菜联）
- 打印任务通过 `bizBillId` 关联业务单据
- 菜品明细按出品部门分发到不同队列

### 2.2 打印样式 ↔ 打印任务

```
PosPrnStyleRow (样式行)
       │
       ├─ dsId ──────────────→ 数据源标识
       │
       ├─ styleType ─────────→ 打印类型（决定用途）
       │
       ├─ displayCondition ──→ 显示内容（列配置）
       │
       ├─ showIndex ─────────→ 显示顺序
       │
       └─ conditionXxx ───────→ 显示条件
                                    │
                                    ▼
                          PosPrnJob.rows (任务包含的样式行)
```

**关系说明**：
- 一个打印类型（styleType）对应多行样式行
- 样式行按 `showIndex` 排序
- 运行时通过 `PrintJobInitUtil.convert` 渲染内容

### 2.3 打印队列 ↔ 打印机

```
PosPrnQueue (打印队列)
     │
     ├─ primaryPrinter ───────→ PosPrnPrinter[] (主打印机列表)
     │                                │
     │                                ├─ type (打印机类型)
     │                                ├─ model (打印机型号)
     │                                └─ extraInfo (连接参数)
     │
     └─ standbyPrinter ────────→ PosPrnPrinter[] (备打印机列表)
                                        │
                                        └─ PrinterStatus (健康状态)
```

**分发策略**：
- 负载均衡：主/备打印机列表内随机选择
- 故障转移：主全故障时切换到备
- 延迟重试：故障时2秒后重试
- 超时放弃：45分钟无响应标记失败

### 2.4 顾客联配置关系

```
┌─────────────────────────────────────────────────────────────┐
│                    PosCustomerBillSetting                    │
├─────────────────────────────────────────────────────────────┤
│  匹配维度（按优先级）:                                        │
│                                                              │
│  1. tableLid ──────────→ DwdBill.tableLid (桌台)           │
│  2. areaLid ────────────→ PtTblArea.lid (区域)             │
│  3. tableTypeLid ───────→ PtTblType.lid (桌型)            │
│  4. pcLid ──────────────→ PosDev.lid (下单设备)           │
│                                                              │
│  输出: prnQueue ─────────→ PosPrnQueue.lid (目标队列)       │
└─────────────────────────────────────────────────────────────┘
```

### 2.5 厨房联配置关系

```
┌─────────────────────────────────────────────────────────────┐
│                         菜品分发                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  DwdFood ─────────────→ prnDeptLid ──→ PosDept.lid        │
│                                          │                  │
│                                          ├─ prnQueue ──────→│
│                                          │   PosPrnQueue   │
│                                          │                  │
│                                          └─ name ──────────→
│                                              (出品部门名称)   │
└─────────────────────────────────────────────────────────────┘

特殊处理:
├─ floorSplitOrder ──→ 自助点餐楼面分单
└─ byQuantityOrder ──→ 按数量出单
```

### 2.6 传菜联配置关系

```
┌─────────────────────────────────────────────────────────────┐
│                   PosWaiterBillSetting                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  prnDept ─────────────────→ 出品部门集合                     │
│       │                                                         │
│       ├─ 部门1 ───────────┐                                  │
│       ├─ 部门2 ───────────┼──→ 匹配的菜品加入打印             │
│       └─ 部门3 ───────────┘                                  │
│                                                              │
│  prnQueue ───────────────→ PosPrnQueue.lid                   │
│                                                              │
│  金额汇总: 该传菜间对应菜品的金额小计 → operate.subtotal     │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 跨模块调用关系

### 3.1 点餐流程中的打印调用

```
DwdBillOpsForBizController.addFood()
    │
    ▼
DwdBillOpsService.addFood()
    │
    ▼
DwdFoodOpsService.addFood()
    │
    ├─ ▼
    │  PrintJobGenerator.generateKitchenJob()
    │      │
    │      ├─ PosPrnStyleRowServicePlus.get(mid, sid, type)
    │      │       │
    │      │       └─ PosPrnStyleRow (模板行)
    │      │
    │      └─ PosPrnJobServicePlus.create()
    │              │
    │              └─ .job 文件 + pos_prn_job 记录
    │
    └─ ▼ (可选)
       PrintJobGenerator.generateWaiterJob()  [划菜时]
```

### 3.2 结账流程中的打印调用

```
CheckOutController.normalCheckOut()
    │
    ▼
CheckOutService.normalCheckOut()
    │
    ├─ CalcOrderService.calc()
    │
    ├─ DwdPayMapper.insert()  [支付记录]
    │
    ├─ DwdBillMapper.update() [订单状态]
    │
    ├─ ▼
    │  PrintJobGenerator.generateCustomerJob(..., CheckOut, ...)
    │      │
    │      ├─ PosCustomerBillSetting (获取队列)
    │      │
    │      └─ PosPrnJobServicePlus.create()
    │
    ├─ ▼ (可选)
    │  PrintJobGenerator.generateJob(..., CashboxPop, ...)
    │
    └─ ▼ (可选)
       PrintJobGenerator.generateKitchenJob()  [需要厨房联时]
```

### 3.3 划菜流程中的打印调用

```
DwdFoodMakingController.finished()
    │
    ▼
DwdFoodMakingServicePlus.finished()
    │
    ▼
PrintJobGenerator.generateWaiterJob()
    │
    ├─ PosWaiterBillSetting (获取传菜间配置)
    │
    └─ PosPrnJobServicePlus.create()
```

---

## 4. 数据流向

### 4.1 打印任务生命周期数据流

```
业务数据 ──→ 模板配置 ──→ 数据源 ──→ 渲染 ──→ 打印指令 ──→ 物理打印机
   │           │           │         │         │            │
   ▼           ▼           ▼         ▼         ▼            ▼
DwdBill    PosPrnStyleRow  DataSource  rows   PrinterWorker  纸张输出
DwdFood                  List      convert   发送ESC/POS
DwdPay                                             │
                                                   ▼
                                              .job.del
```

### 4.2 关键转换点

| 转换阶段 | 输入 | 输出 | 转换类 |
|----------|------|------|--------|
| 模板加载 | mid/sid/type | List\<PosPrnStyleRow\> | PosPrnStyleRowServicePlus |
| 数据源准备 | 业务实体 | List\<PrnDataSourceDTO\> | PrintJobGenerator |
| 内容渲染 | rows + dataSources | List\<PosPrnStyleRowVO\> | PrintJobInitUtil |
| 指令生成 | rows | ESC/POS bytes | EscPosRenderService |
| 物理打印 | bytes | 纸张 | PrinterWorker |

---

## 5. 缓存关系

### 5.1 JetCache 缓存

| 缓存Key | 缓存内容 | 失效策略 |
|---------|----------|----------|
| `pos_prn_queue:{mid}:{lid}` | PosPrnQueueVO | 按需刷新 |
| `pos_prn_style_row:{mid}:{sid}:{type}` | List\<PosPrnStyleRowVO\> | 按需刷新 |
| `pos_printer:{mid}:{lid}` | PosPrnPrinterVO | 按需刷新 |

### 5.2 Redis 状态

| Key Pattern | 存储内容 | 说明 |
|-------------|----------|------|
| `pos_prn_job:count:{lid}` | Integer | 打印次数 |
| `pos_printer:status:{lid}` | String | HEALTHY/FAULT |

---

*文档版本：v1.0 | 生成时间：2026-08-03*
