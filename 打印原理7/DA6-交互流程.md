# DA6 交互流程 — 打印子系统

## 核心交互场景

### 场景一：厨房联打印（点菜触发）

```
参与者: 服务员、POS 前端、POS 后端、打印队列、打印机
前置条件: 服务员已开台，已选择菜品
后置条件: 厨房打印机输出小票

流程:
┌──────┐    ┌──────────┐    ┌───────────┐    ┌────────┐    ┌─────────┐
│服务员│    │POS前端   │    │POS后端    │    │打印队列│    │打印机   │
└──┬───┘    └────┬─────┘    └─────┬─────┘    └───┬────┘    └────┬────┘
   │             │                │              │              │
   │ 提交点菜    │                │              │              │
   │────────────▶│                │              │              │
   │             │ POST /addFood  │              │              │
   │             │───────────────▶│              │              │
   │             │                │              │              │
   │             │                │ 1. 保存菜品到数据库          │
   │             │                │ 2. 调用 PrintJobGenerator   │
   │             │                │    .generateKitchenJob()    │
   │             │                │              │              │
   │             │                │ 3. 按出品部门分组           │
   │             │                │ 4. 每个部门→队列            │
   │             │                │    → PosPrnJobServicePlus   │
   │             │                │    .create()                │
   │             │                │              │              │
   │             │                │ 5. 写pos_prn_job表          │
   │             │                │ 6. 写.job文件               │
   │             │                │ 7. PrintUtil.initJob()      │
   │             │                │─────────────▶               │
   │             │                │              │              │
   │             │                │              │ 8. initJob   │
   │             │                │              │    -加载模板  │
   │             │                │              │    -填充数据源│
   │             │                │              │    -条件过滤  │
   │             │                │              │              │
   │             │                │              │ 9. dispatchJob│
   │             │                │              │    -选打印机  │
   │             │                │              │─────────────▶│
   │             │                │              │              │
   │             │                │              │              │ 10. 读取.job
   │             │                │              │              │ 11. 执行打印
   │             │                │              │              │ 12. 标记完成
   │             │                │              │              │
   │ 返回成功    │                │              │              │
   │◀────────────│◁──────────────│              │              │
   │             │                │              │              │
```

### 场景二：结账顾客联打印

```
参与者: 收银员、POS 前端、POS 后端、打印队列、打印机
前置条件: 顾客已就餐完毕，账单已生成
后置条件: 顾客小票打印完成，钱箱弹出

流程:
┌──────┐    ┌──────────┐    ┌───────────┐    ┌────────┐    ┌─────────┐
│收银员│    │POS前端   │    │POS后端    │    │打印队列│    │打印机   │
└──┬───┘    └────┬─────┘    └─────┬─────┘    └───┬────┘    └────┬────┘
   │             │                │              │              │
   │ 发起结账    │                │              │              │
   │────────────▶│                │              │              │
   │             │ POST /checkOut │              │              │
   │             │───────────────▶│              │              │
   │             │                │              │              │
   │             │                │ 1. 处理支付                │
   │             │                │ 2. 调用 PrintJobGenerator  │
   │             │                │    .generateCustomerJob()  │
   │             │                │              │              │
   │             │                │ 3. 匹配顾客联设置          │
   │             │                │    - 优先级: 桌台>区域>    │
   │             │                │      桌型>PC               │
   │             │                │ 4. 获取队列ID              │
   │             │                │ 5. 创建打印任务            │
   │             │                │    (CheckOut类型)          │
   │             │                │              │              │
   │             │                │ 6. 生成钱箱弹出任务        │
   │             │                │    (CashboxPop类型)        │
   │             │                │─────────────▶               │
   │             │                │              │              │
   │             │                │              │ 7. 初始化+分发│
   │             │                │              │─────────────▶│
   │             │                │              │              │
   │             │                │              │              │ 8. 打印顾客联
   │             │                │              │              │ 9. 弹出钱箱
   │             │                │              │              │
   │ 返回结账成功│                │              │              │
   │◀────────────│◁──────────────│              │              │
   │             │                │              │              │
```

### 场景三：打印任务监控与重打

```
参与者: 收银员、POS 前端、POS 后端
前置条件: 存在历史打印任务
后置条件: 重打任务进入打印队列

流程:
┌──────────┐    ┌───────────┐    ┌──────────┐
│POS前端   │    │POS后端    │    │打印队列  │
└────┬─────┘    └─────┬─────┘    └────┬─────┘
     │                │              │
     │ 打开打印任务监控               │
     │───────────────────────────────│
     │                │              │
     │ 请求任务列表   │              │
     │───────────────▶│              │
     │                │ 查询         │
     │◀───────────────│ pos_prn_job  │
     │                │              │
     │ 展示任务列表   │              │
     │ (实时WebSocket │              │
     │  更新)         │              │
     │                │              │
     │ 点击重打       │              │
     │───────────────▶│              │
     │                │ 重新创建     │
     │                │ 打印任务     │
     │                │─────────────▶│
     │                │              │ 重新分发
     │                │              │
     │ 重打成功提示   │              │
     │◀───────────────│              │
     │                │              │
```

## API 清单

### 打印机管理 API

| 方法 | 路径 | 请求 | 响应 | 证据 |
|------|------|------|------|------|
| POST | `/merchant/pos_printer/add` | PosPrinterCreateDTO | 通用响应 | E-SRC: PosPrinterForBizController |
| POST | `/merchant/pos_printer/update` | PosPrinterUpdateDTO | 通用响应 | E-SRC: PosPrinterForBizController |
| POST | `/merchant/pos_printer/list` | 查询参数 | 打印机列表 | E-SRC: PosPrinterForBizController |
| POST | `/admin/pos_prn_printer/add` | PosPrnPrinterCreateDTO | 通用响应 | E-SRC: PosPrnPrinterController |
| POST | `/admin/pos_prn_printer/update` | PosPrnPrinterUpdateDTO | 通用响应 | E-SRC: PosPrnPrinterController |
| POST | `/admin/pos_prn_printer/list` | PosPrnPrinterQueryDTO | 打印机列表 | E-SRC: PosPrnPrinterController |

### 打印队列管理 API

| 方法 | 路径 | 请求 | 响应 | 证据 |
|------|------|------|------|------|
| POST | `/admin/pos_prn_queue/add` | PosPrnQueueCreateDTO | 通用响应 | E-SRC: PosPrnQueueController |
| POST | `/admin/pos_prn_queue/update` | PosPrnQueueUpdateDTO | 通用响应 | E-SRC: PosPrnQueueController |
| POST | `/admin/pos_prn_queue/list` | PosPrnQueueQueryDTO | 队列列表 | E-SRC: PosPrnQueueController |

### 打印任务管理 API

| 方法 | 路径 | 请求 | 响应 | 证据 |
|------|------|------|------|------|
| POST | `/admin/pos_prn_job/add` | PosPrnJobCreateDTO | 通用响应 | E-SRC: PosPrnJobController |
| POST | `/admin/pos_prn_job/list` | PosPrnJobQueryDTO | 任务列表 | E-SRC: PosPrnJobController |
| POST | `/admin/pos_prn_job/reprint` | PosPrnJobReprintDTO | 通用响应 | E-SRC: PosPrnJobController |

### 打印样式管理 API

| 方法 | 路径 | 请求 | 响应 | 证据 |
|------|------|------|------|------|
| POST | `/admin/pos_prn_style_row/add` | PosPrnStyleRowCreateDTO | 通用响应 | E-SRC: PosPrnStyleRowController |
| POST | `/admin/pos_prn_style_row/update` | PosPrnStyleRowUpdateDTO | 通用响应 | E-SRC: PosPrnStyleRowController |
| POST | `/admin/pos_prn_style_row/list` | PosPrnStyleRowQueryDTO | 样式行列表 | E-SRC: PosPrnStyleRowController |
| POST | `/admin/pos_prn_style_col/add` | PosPrnStyleColCreateDTO | 通用响应 | E-SRC: PosPrnStyleColController |
| POST | `/admin/pos_prn_style_col/update` | PosPrnStyleColUpdateDTO | 通用响应 | E-SRC: PosPrnStyleColController |

### 打印开关管理 API

| 方法 | 路径 | 请求 | 响应 | 证据 |
|------|------|------|------|------|
| POST | `/admin/print_job_type_switch/add` | PrintJobTypeSwitchCreateDTO | 通用响应 | E-SRC: PrintJobTypeSwitchController |
| POST | `/admin/print_job_type_switch/update` | PrintJobTypeSwitchUpdateDTO | 通用响应 | E-SRC: PrintJobTypeSwitchController |
| POST | `/admin/print_job_type_switch/list` | PrintJobTypeSwitchQueryDTO | 开关列表 | E-SRC: PrintJobTypeSwitchController |

## 未知项

| 编号 | 描述 | 影响 |
|------|------|------|
| U-05 | 打印任务监控的 WebSocket 消息类型和推送机制 | 影响实时性评估 |
| U-06 | 云打印机（芯烨/佳博）的实际通信协议细节和回调处理 | 影响第三方集成评估 |