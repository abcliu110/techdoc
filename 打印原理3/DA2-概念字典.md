# DA2 - 概念字典：打印功能核心概念

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 核心实体概念

### 1.1 打印机（PosPrnPrinter）

| 字段 | 类型 | 说明 |
|------|------|------|
| pid | Long | 物理编号，自增主键 |
| mid | Long | 商户ID，多商户隔离 |
| sid | Long | 门店ID，门店数据隔离 |
| lid | Long | 逻辑编号，雪花算法唯一 |
| name | String | 打印机名称 |
| pcLid | Long | 关联PC设备ID（可选） |
| type | PrinterTypeEnum | 打印机类型 |
| model | PrinterModelEnum | 打印机型号 |
| extraInfo | String | 扩展信息（JSON） |
| revision | Integer | 乐观锁版本号 |

**扩展信息结构（按类型）**：

```typescript
// 网络打印机
interface NetPrinterExtraInfo {
  ip: string;        // IP地址
  port: number;     // 端口号
}

// 串口打印机
interface ComPrinterExtraInfo {
  port: string;     // 串口名，如 COM1
  baudRate: number;  // 波特率
}

// USB打印机
interface UsbPrinterExtraInfo {
  vendorId: string;
  productId: string;
}

// 云打印机
interface XyCloudExtraInfo {
  sn: string;       // 设备SN号
  key: string;      // 密钥
}

interface JbCloudExtraInfo {
  machineCode: string;
  msign: string;
}
```

### 1.2 打印队列（PosPrnQueue）

| 字段 | 类型 | 说明 |
|------|------|------|
| pid | Long | 物理编号 |
| mid | Long | 商户ID |
| sid | Long | 门店ID |
| lid | Long | 逻辑编号 |
| name | String | 队列名称 |
| primaryPrinter | String | 主打印机ID列表（逗号分隔） |
| standbyPrinter | String | 备打印机ID列表（逗号分隔） |
| pcLid | Long | 关联PC（可选） |

**分发逻辑**：
- 优先使用主打印机列表
- 主打印机全故障时使用备打印机
- 支持多台打印机负载均衡

### 1.3 打印样式行（PosPrnStyleRow）

| 字段 | 类型 | 说明 |
|------|------|------|
| pid | Long | 物理编号 |
| mid | Long | 商户ID |
| sid | Long | 门店ID |
| lid | Long | 逻辑编号 |
| dsId | String | 数据源ID |
| styleType | PrnStyleTypeEnum | 样式类型 |
| showIndex | Integer | 显示顺序 |
| displayCondition | String | 显示条件JSON |
| conditionDsId | String | 条件数据源ID |
| conditionOperator | ConditionOperatorEnum | 条件运算符 |
| conditionValue | String | 条件值 |
| summarize | Boolean | 是否汇总 |
| summarizeColName | String | 汇总列名 |

**displayCondition 结构**：

```json
{
  "columns": [
    {
      "dsId": "billInfo",
      "fieldId": "tableName",
      "customizedContent": "桌号：${tableName}",
      "align": "LEFT",
      "bold": true,
      "fontSize": 12,
      "width": 32
    }
  ]
}
```

### 1.4 出品部门（PosDept / DeptTypeEnum）

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | Long | 逻辑编号 |
| name | String | 部门名称 |
| prnQueue | String | 关联打印队列ID列表 |
| type | DeptTypeEnum | 部门类型 |
| mid/sid | Long | 商户/门店 |

**部门类型枚举（DeptTypeEnum）**：

| 枚举值 | code | 说明 | 对应票据 |
|--------|------|------|----------|
| DEFAULT | 1 | 默认部门 | - |
| FOR_PROFIT | 2 | 利润部门 | 报表类 |
| FOR_PRN | 3 | 出品部门 | 一菜一单 |
| FOR_KITCHEN | 4 | 厨房部门 | 厨房联 |
| FOR_PREPARATION | 5 | 配菜部门 | KDS配菜 |
| FOR_COOK | 6 | 划菜部门 | 传菜联 |
| FOR_SERVE | 7 | 传菜部门 | TotalBill |

### 1.4 打印任务（PosPrnJob）

| 字段 | 类型 | 说明 |
|------|------|------|
| pid | Long | 物理编号 |
| mid | Long | 商户ID |
| sid | Long | 门店ID |
| lid | Long | 逻辑编号（任务ID） |
| bizBillId | String | 业务单号（订单号） |
| type | PrnStyleTypeEnum | 打印类型 |
| purpose | PrnJobPurposeEnum | 打印用途 |
| prnCount | Integer | 打印次数 |
| prnQueueLid | Long | 目标队列ID |
| prnPrinterLid | Long | 目标打印机ID |
| printAt | LocalDateTime | 打印时间 |
| status | PrnJobStatusEnum | 任务状态 |

**任务状态**：
- PENDING：等待中
- PRINTING：打印中
- SUCCESS：成功
- FAILED：失败

**用途枚举**：
- FOR_CUSTOMER：顾客联
- FOR_KITCHEN：厨房联
- FOR_WAITER：传菜联
- FOR_DEVICE：设备指令

---

## 2. 枚举概念

### 2.1 打印机类型（PrinterTypeEnum）

| 枚举值 | 说明 | 通信方式 |
|--------|------|----------|
| DRIVER | Windows驱动打印 | Windows API |
| DRIVER_CMD | 驱动命令打印 | ESC/POS via Driver |
| NET | 网络打印机 | TCP/IP |
| COM | 串口打印机 | RS232 |
| USB | USB打印机 | USB |
| LPT | 并口打印机 | 并口 |
| XY_CLOUD | 芯烨云打印 | HTTP API |
| JB_CLOUD | 佳博云打印 | HTTP API |

### 2.2 打印样式类型（PrnStyleTypeEnum）

见 DA0 侦察报告中的完整列表。

### 2.3 条件运算符（ConditionOperatorEnum）

| 枚举值 | 说明 | 示例 |
|--------|------|------|
| EQ | 等于 | status EQ 'COOK' |
| NE | 不等于 | status NE 'CANCEL' |
| GT | 大于 | amount GT 100 |
| GTE | 大于等于 | amount GTE 100 |
| LT | 小于 | amount LT 50 |
| LTE | 小于等于 | amount LTE 50 |
| IN | 包含 | status IN ('COOK','SERVE') |
| NOT_IN | 不包含 | status NOT_IN ('CANCEL') |
| LIKE | 模糊匹配 | name LIKE '%鱼%' |
| NOT_LIKE | 不匹配 | name NOT_LIKE '%特价%' |

---

## 3. 数据源概念

### 3.1 标准数据源

| dsId | 数据内容 | 典型字段 |
|------|----------|----------|
| storeInfo | 门店信息 | name, address, tel |
| billInfo | 账单信息 | orderNo, tableName, amount |
| foodInfo | 菜品明细 | name, price, number, remark |
| payInfo | 支付信息 | payType, amount, time |
| operate | 操作信息 | operator, time, subtotal |
| memberInfo | 会员信息 | cardNo, name, balance |

### 3.2 数据源格式

```json
{
  "dataSourceList": [
    {
      "dsId": "storeInfo",
      "data": { "name": "门店名称", "tel": "400-xxx" }
    },
    {
      "dsId": "billInfo",
      "data": { "orderNo": "B20260803001", "amount": 168.00 }
    },
    {
      "dsId": "foodInfo",
      "list": [
        { "name": "红烧肉", "price": 58, "number": 1 },
        { "name": "清蒸鱼", "price": 88, "number": 1 }
      ]
    }
  ]
}
```

---

## 4. 配置实体概念

### 4.1 顾客联队列设置（PosCustomerBillSetting）

| 字段 | 说明 |
|------|------|
| mid/sid | 商户/门店 |
| forCheckout | 是否结账场景 |
| source | 来源（顾客端/服务员端） |
| tableLid/areaLid/tableTypeLid/pcLid | 关联维度 |
| prnQueue | 目标队列ID列表 |

### 4.2 传菜联队列设置（PosWaiterBillSetting）

| 字段 | 说明 |
|------|------|
| mid/sid | 商户/门店 |
| prnDept | 出品部门列表 |
| prnQueue | 目标队列ID列表 |

### 4.3 打印开关（PrintJobTypeSwitch）

| 字段 | 说明 |
|------|------|
| disabledCustomer/disabledKitchen/disabledWaiter | 是否禁用 |
| numOfCustomer/numOfKitchen/numOfWaiter | 张数配置 |

---

## 5. 文件概念

### 5.1 .job 文件

- **位置**：`{appDir}/jobs/{yyyy-MM-dd}/{lid}.job`
- **内容**：`PosPrnJobCreateDTO` 的JSON序列化
- **生命周期**：
  - 创建：`PosPrnJobServicePlus.keepToFile`
  - 完成：重命名为 `.del` 后删除

### 5.2 .del 文件

- **含义**：任务已完成标记
- **来源**：`.job` 文件打印成功后重命名

---

## 6. Redis 键概念

### 6.1 打印计数

```
Key: pos_service:pos_prn_job:count:{lid}
Value: 打印次数
TTL: 永久
```

### 6.2 打印机状态

```
Key: pos_printer:status:{printerLid}
Value: PrinterStatus (HEALTHY/FAULT)
TTL: 动态更新
```

---

*文档版本：v1.0 | 生成时间：2026-08-03*
