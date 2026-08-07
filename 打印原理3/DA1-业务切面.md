# DA1 - 业务切面：打印功能业务域分析

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 业务域概述

打印功能是餐饮POS系统的核心辅助功能，负责将业务数据（订单、账单、菜品信息）输出到物理打印机，生成顾客联、厨房联、传菜联等各类票据。

### 1.1 核心价值

- **顾客服务**：提供结账单、预结单等顾客凭证
- **后厨协同**：传递菜品制作信息给厨房
- **传菜协调**：协调前台与传菜间的菜品传递
- **运营记录**：生成交班报表、日报表等运营文档

---

## 2. 业务票据分类

### 2.1 收银票据域

| 票据类型 | PrnStyleTypeEnum | 触发场景 | 打印份数 |
|----------|------------------|----------|----------|
| 结账单 | CheckOut(26) | 结账完成 | 1-2份 |
| 预结单 | PreCheck(20) | 预结账操作 | 1份 |
| 弹钱箱 | CashboxPop(60) | 结账后/收银操作 | 1次 |

**业务规则**：
- 结账单可配置打印份数（通常1-2份）
- 预结单不触发钱箱弹出
- 弹钱箱为纯设备指令，无需模板

### 2.2 后厨票据域

| 票据类型 | PrnStyleTypeEnum | 触发场景 | 分发规则 |
|----------|------------------|----------|----------|
| 点菜单 | OrderMenu(10) | 点菜/加菜 | 按菜品出品部门分发 |
| 点菜单(多做法) | OrderMenuEx(11) | 菜品多做法 | 同上 |
| 厨房联 | KitchenBill(12) | 点菜/加菜 | 按菜品出品部门分发 |
| 厨房联(多做法) | KitchenBillEx(13) | 菜品多做法 | 同上 |
| 退菜单 | CancelBill(30) | 退菜操作 | 按菜品出品部门 |
| 催菜单 | UrgeBill(31) | 催菜操作 | 按菜品出品部门 |

**业务规则**：
- 厨房联按菜品出品部门（PosDept）分发到不同队列
- 支持楼面分单（floorSplitOrder）特殊处理
- 支持按数量出单（byQuantityOrder）
- 退菜、催菜触发对应票据重打印

### 2.3 传菜票据域

| 票据类型 | PrnStyleTypeEnum | 触发场景 | 分发规则 |
|----------|------------------|----------|----------|
| 传菜联 | WaiterBill(14) | 划菜完成 | 按传菜间/出品部门 |

**业务规则**：
- 传菜联按传菜间设置（PosWaiterBillSetting）分发
- 统计该传菜间菜品的金额小计

### 2.4 报表票据域

| 票据类型 | PrnStyleTypeEnum | 触发场景 |
|----------|------------------|----------|
| 交班报表 | ShiftReport(40) | 交班操作 |
| 日报表 | DayReport(41) | 日结操作 |

### 2.5 会员票据域

| 票据类型 | PrnStyleTypeEnum | 触发场景 |
|----------|------------------|----------|
| 会员卡充值 | MemberCardRecharge(50) | 会员充值 |

### 2.6 WMS票据域（仓储）

| 票据类型 | PrnStyleTypeEnum | 业务场景 |
|----------|------------------|----------|
| 门店订货单 | WMS_STORE_ORDER(1000) | WMS采购订货 |
| 门店入库单 | WMS_STORE_INBOUND(1010) | WMS入库操作 |
| 门店出库单 | WMS_STORE_OUTBOUND(1020) | WMS出库操作 |

---

## 3. 打印流程业务切面

### 3.1 业务入口矩阵

| 业务场景 | 调用方法 | 票据类型 | 分发策略 |
|----------|----------|----------|----------|
| 点菜 | `generateKitchenJob` | 厨房联 | 按出品部门 |
| 加菜 | `generateKitchenJob` | 厨房联 | 按出品部门 |
| 结账 | `generateCustomerJob` | 结账单 | 按桌台/区域/PC |
| 预结 | `generateCustomerJob` | 预结单 | 按桌台/区域/PC |
| 划菜 | `generateWaiterJob` | 传菜联 | 按传菜间 |
| 退菜 | `generateKitchenJob` | 退菜单 | 按出品部门 |
| 催菜 | `generateKitchenJob` | 催菜单 | 按出品部门 |
| 充值 | `generateCustomerJob` | 充值小票 | 指定队列 |

### 3.2 打印开关控制

通过 `PrintJobTypeSwitch` 配置控制：

| 配置项 | 类型 | 说明 |
|--------|------|------|
| disabledCustomer | boolean | 禁用顾客联 |
| disabledKitchen | boolean | 禁用厨房联 |
| disabledWaiter | boolean | 禁用传菜联 |
| numOfCustomer | int | 顾客联张数 |
| numOfKitchen | int | 厨房联张数 |
| numOfWaiter | int | 传菜联张数 |

**默认行为**：无配置时各类型默认1张

### 3.3 队列分配策略

#### 顾客联队列分配（PosCustomerBillSetting）

优先级顺序：
1. 桌台级配置
2. 区域级配置
3. 桌型级配置
4. PC级配置

匹配条件：
- `forCheckOut`：是否结账场景
- `source`：来源（顾客端/服务员端）
- 关联字段：`tableLid`/`areaLid`/`tableTypeLid`/`pcLid`

#### 厨房联队列分配（PosDept）

- 菜品关联 `prnDeptLid`
- 部门配置 `prnQueue` 队列ID列表
- 支持自助点餐队列替换

#### 传菜联队列分配（PosWaiterBillSetting）

- 按传菜间 `prnDept` 出品部门匹配
- 关联 `prnQueue` 队列

---

## 4. 故障转移机制

### 4.1 打印机故障检测

- 状态枚举：`PrinterStatus`（HEALTHY/FAULT）
- 通过 `PrinterWorkerService.addPrinterStatus` 更新状态

### 4.2 故障转移策略

```
主打印机列表 → 备打印机列表 → 延迟重试(2秒) → 超时放弃(45分钟)
```

**超时机制**：
- 首次失败后延迟2秒重试
- 持续失败超过45分钟，标记任务失败

---

## 5. 业务约束

### 5.1 事务边界

- `PrintJobGenerator` 在业务Service的 `@Transactional` 方法中被调用
- `PosPrnJobServicePlus.create` 自身使用 `@Transactional(REQUIRED)`
- 打印任务创建与业务事务强绑定

### 5.2 异步特性

- 从 `PrintUtil.initJob` 开始异步执行
- 不阻塞核心业务流程
- 支持进程重启后任务恢复

### 5.3 打印内容约束

- 模板字段通过 `dsId,fieldId` 格式引用数据源
- 支持行级显示条件（`conditionDsId/conditionOperator/conditionValue`）
- 支持数据源过滤和汇总

---

## 6. 运营配置项

| 配置实体 | 说明 | 管理入口 |
|----------|------|----------|
| PosPrnPrinter | 打印机设备 | DevMgr/PosPrnPrinter |
| PosPrnQueue | 打印队列 | PrintMgr/PrintQueuePage |
| PosPrnStyleRow | 打印样式模板 | PrintMgr/PosPrnStyleRowPage |
| PosCustomerBillSetting | 顾客联队列设置 | PrintMgr |
| PosWaiterBillSetting | 传菜联队列设置 | PrintMgr |
| PrintJobTypeSwitch | 打印开关 | PrintMgr |

---

*文档版本：v1.0 | 生成时间：2026-08-03*
