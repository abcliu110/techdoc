# DA1 业务切面分析 — 打印子系统

## 一、业务域定位

### 1.1 系统位置

```
                      NMS4Cloud 生态
                            │
              ┌─────────────┼─────────────┐
              │             │             │
        餐饮 POS       零售 POS       SaaS 后台
         (nms4pos)    (nms4pos)   (nms4cloud-biz-ui)
              │             │             │
              └──────┬──────┘             │
                     │                    │
              ┌──────┴──────┐             │
              │  打印子系统  │◄────────────┘
              └──────┬──────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
     物理打印机   云打印机    打印服务
     (USB/LPT)   (芯烨/佳博)  (独立进程)
```

### 1.2 业务价值

| 价值维度 | 说明 |
|---------|------|
| 经营履约 | 厨房联确保厨师按单做菜，是餐饮 POS 的核心履约环节 |
| 顾客体验 | 顾客联提供消费凭证，是顾客信任的基础 |
| 运营效率 | 自动分发到不同打印机，减少人工传递 |
| 合规记录 | 报表打印提供经营数据凭证 |

## 二、核心角色

| 角色 | 操作 | 接触系统 |
|------|------|---------|
| 收银员/服务员 | 点菜、加菜、结账、交班 | POS 前端（nms4pos-ui） |
| 厨师 | 查看厨房小票 | 物理打印机（厨房） |
| 传菜员 | 查看传菜小票 | 物理打印机（传菜间） |
| 顾客 | 接收小票 | 物理打印机（前台） |
| 门店管理员 | 配置打印机、队列、样式 | SaaS 后台（nms4cloud-biz-ui） |
| 系统管理员 | 全局打印配置 | SaaS 后台（nms4cloud-biz-ui） |

## 三、业务分类

### 3.1 按打印用途分类

| 用途 | 说明 | 典型样式类型 |
|------|------|-------------|
| 厨房联 (FOR_KITCHEN) | 点菜/加菜/催菜/退菜时厨房打印，按出品部门分发 | OrderMenu, HurryMenu, BackMenu, ReplaceItem |
| 传菜联 (FOR_DISH_DELIVERER) | 划菜完成时传菜间打印，按传菜间分发 | TotalBill（划菜总单） |
| 顾客联 (FOR_CUSTOMER) | 结账/点菜时前台打印，按桌台/区域/桌型/PC 分发 | CheckOut, OrderMenu, QueueBill |

### 3.2 按打印时机分类

| 时机 | 说明 | 典型场景 |
|------|------|---------|
| 交易触发 | 点菜/加菜/结账时自动触发 | 厨房联、顾客联 |
| 操作触发 | 划菜/催菜/退菜时手动触发 | 传菜联、退菜单 |
| 定时触发 | 交班/日结时自动触发 | 交班单、营业报表 |
| 查询触发 | 查看报表时手动触发 | 部门销售报表、菜品销售报表 |

### 3.3 按打印机类型分类

| 打印机类型 | 说明 | 连接方式 |
|-----------|------|---------|
| 驱动打印机 (DRIVER) | 通过 Windows 驱动打印 | 操作系统驱动 |
| 网口指令打印机 (NET) | 通过网络直接发送指令 | TCP/IP |
| 串口指令打印机 (COM) | 通过串口发送指令 | RS-232 |
| USB 指令打印机 (USB) | 通过 USB 发送指令 | USB |
| 并口指令打印机 (LPT) | 通过并口发送指令 | LPT |
| 芯烨云打印机 (XY_CLOUD) | 芯烨云平台远程打印 | HTTP API |
| 佳博云打印机 (JB_CLOUD) | 佳博云平台远程打印 | HTTP API |
| 驱动指令打印机 (DRIVER_CMD) | 通过驱动发送指令 | 驱动 + 指令 |

## 四、核心用例（UC）

### UC-1：点菜触发厨房联打印

```
用例编号：UC-1
参与者：服务员
前置条件：服务员已开台，已登录 POS 系统
基本流程：
  1. 服务员在 POS 端选择菜品并提交
  2. 系统按菜品出品部门分组
  3. 每组对应一个打印队列
  4. 队列分发到健康的主打印机
  5. 厨房打印机输出小票
后置条件：厨房联打印完成
异常处理：
  - 无可用打印机：延迟重试（最多 45 分钟）
  - 队列未配置：记录错误日志
证据：E-SRC: PrintJobGenerator.generateKitchenJob
```

### UC-2：结账触发顾客联打印

```
用例编号：UC-2
参与者：收银员
前置条件：顾客已就餐完毕，账单已生成
基本流程：
  1. 收银员发起结账操作
  2. 系统完成支付处理
  3. 根据顾客联设置选择打印队列
  4. 按优先级：桌台 > 区域 > 桌型 > PC
  5. 分发到对应打印机
  6. 打印顾客小票（含支付明细、优惠信息）
后置条件：顾客联打印完成，钱箱弹出
异常处理：打印失败不影响结账完成（异步）
证据：E-SRC: PrintJobGenerator.generateCustomerJob
```

### UC-3：配置打印样式

```
用例编号：UC-3
参与者：门店管理员
前置条件：管理员已登录 SaaS 后台
基本流程：
  1. 进入打印设置页面
  2. 选择打印类型（如点菜单、结账单）
  3. 添加行，绑定数据源
  4. 添加列，配置宽度、对齐、字体
  5. 配置列内容（常量文本或数据占位符）
  6. 配置行级打印条件
  7. 保存样式
后置条件：样式生效，下次打印使用新样式
异常处理：条件配置错误时默认显示行（容错）
证据：E-SRC: PosPrnStyleRowServicePlus + PrintJobInitUtil
```

### UC-4：打印任务监控与重打

```
用例编号：UC-4
参与者：收银员/服务员
前置条件：存在打印任务
基本流程：
  1. 打开打印任务监控页面
  2. 查看打印任务列表（按时间、状态、打印机筛选）
  3. 查看任务详情（打印内容预览）
  4. 对失败任务执行重打
  5. 对不需要的任务执行删除
后置条件：重打任务重新进入打印队列
异常处理：重打超时提示
证据：E-SRC: nms4pos-ui PrintTaskMonitor + PosPrnJobController
```

## 五、业务规则汇总

| 规则编号 | 规则内容 | 约束级别 | 证据 |
|---------|---------|---------|------|
| BR-01 | 打印类型开关控制是否启用和打印张数 | MUST | E-SRC: PrintJobTypeSwitch + PrintJobGenerator.getNumOfXxx |
| BR-02 | 顾客联队列选择优先级：桌台 > 区域 > 桌型 > PC | MUST | E-SRC: PrintJobGenerator.generateCustomerJob |
| BR-03 | 厨房联按菜品出品部门分发到对应队列 | MUST | E-SRC: PrintJobGenerator.generateKitchenJob |
| BR-04 | 传菜联按传菜间设置分发，传菜间关联出品部门 | MUST | E-SRC: PrintJobGenerator.generateWaiterJob |
| BR-05 | 主打印机故障时切换到备用打印机（随机负载均衡） | MUST | E-SRC: PosPrnQueueServicePlus.dispatchJob |
| BR-06 | 打印任务超时 45 分钟不再重试 | MUST | E-SRC: PosPrnQueueServicePlus.overTaskTime 常量 |
| BR-07 | 打印条件配置错误时默认显示行（容错） | MUST | E-SRC: ConditionUtil.isRowVisible |
| BR-08 | 打印任务异步执行，不阻塞核心业务 | MUST | E-SRC: PrintUtil.initJob → JobTaskHandle |
| BR-09 | 打印机状态实时更新，故障打印机不参与分发 | MUST | E-SRC: PrinterWorkerService.addPrinterStatus |
| BR-10 | 云打印机通过 HTTP API 通信，支持回调通知 | MUST | E-SRC: cn.poscom.cloud 包 + DeviceNotificationAPI |

## 六、触发时机图

```
业务事件                       打印任务                    打印输出
─────────                    ────────                    ────────
点菜/加菜 ──→ PrintJobGenerator ──→ PosPrnJobServicePlus ──→ .job 文件
催菜/退菜 ──→ PrintJobGenerator ──→ PosPrnJobServicePlus ──→ .job 文件
换品/转台 ──→ PrintJobGenerator ──→ PosPrnJobServicePlus ──→ .job 文件
结账      ──→ PrintJobGenerator ──→ PosPrnJobServicePlus ──→ .job 文件
划菜完成  ──→ PrintJobGenerator ──→ PosPrnJobServicePlus ──→ .job 文件
交班/日结 ──→ 报表页面       ──→ PosPrnJobServicePlus ──→ .job 文件
                                      │
                                      ▼
                               PosPrnQueueServicePlus
                               initJob → dispatchJob
                                      │
                                      ▼
                               PrinterWorkerService
                               handlePrnJob → 物理打印
```
