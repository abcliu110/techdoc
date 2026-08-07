# DA7 - 实现映射：打印功能代码位置索引

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 核心服务类映射

### 1.1 打印任务生成层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PrintJobGenerator` | `com.nms4cloud.pos.print.service.PrintJobGenerator` | 打印任务生成入口，按业务场景分发 |
| `PrintJobGeneratorForWMS` | `com.nms4cloud.pos.print.service.PrintJobGeneratorForWMS` | WMS打印任务生成 |
| `DwdFoodOpsService` | `com.nms4cloud.pos.dwd.service.DwdFoodOpsService` | 菜品操作服务，触发厨房联打印 |
| `DwdFoodMakingServicePlus` | `com.nms4cloud.pos.dwd.service.DwdFoodMakingServicePlus` | 菜品制作服务，触发传菜联打印 |
| `CheckOutService` | `com.nms4cloud.pos.checkout.service.CheckOutService` | 结账服务，触发顾客联打印 |

### 1.2 打印任务持久化层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PosPrnJobServicePlus` | `com.nms4cloud.pos.print.service.PosPrnJobServicePlus` | 打印任务持久化(DB+.job文件) |
| `PosPrnJobMapper` | `com.nms4cloud.pos.print.dao.PosPrnJobMapper` | 打印任务数据库访问 |

### 1.3 打印队列管理层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PosPrnQueueServicePlus` | `com.nms4cloud.pos.print.service.PosPrnQueueServicePlus` | 打印队列服务：内容初始化、任务分发 |
| `PrintJobInitUtil` | `com.nms4cloud.pos.print.util.PrintJobInitUtil` | 打印内容初始化工具 |
| `PosPrnQueueMapper` | `com.nms4cloud.pos.print.dao.PosPrnQueueMapper` | 队列数据库访问 |

### 1.4 打印样式管理层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PosPrnStyleRowServicePlus` | `com.nms4cloud.pos.print.service.PosPrnStyleRowServicePlus` | 打印样式行服务 |
| `PosPrnStyleRowMapper` | `com.nms4cloud.pos.print.dao.PosPrnStyleRowMapper` | 样式行数据库访问 |

### 1.5 打印Worker执行层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PrinterWorkerService` | `com.nms4cloud.pos.print.service.PrinterWorkerService` | 打印机Worker管理 |
| `PrinterWorker` | `com.nms4cloud.pos.print.worker.PrinterWorker` | 单个打印机Worker实现 |
| `PrinterDriverManager` | `com.nms4cloud.pos.print.driver.PrinterDriverManager` | 打印机驱动管理器 |
| `EscPosRenderService` | `com.nms4cloud.pos.print.service.EscPosRenderService` | ESC/POS指令渲染 |

### 1.6 打印机管理层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PosPrnPrinterServicePlus` | `com.nms4cloud.pos.print.service.PosPrnPrinterServicePlus` | 打印机管理服务 |
| `PosPrnPrinterMapper` | `com.nms4cloud.pos.print.dao.PosPrnPrinterMapper` | 打印机数据库访问 |

### 1.7 配置服务层

| 类名 | 包路径 | 职责 |
|------|--------|------|
| `PosCustomerBillSettingServicePlus` | `com.nms4cloud.pos.print.service.PosCustomerBillSettingServicePlus` | 顾客联队列设置 |
| `PosWaiterBillSettingServicePlus` | `com.nms4cloud.pos.print.service.PosWaiterBillSettingServicePlus` | 传菜联队列设置 |
| `PrintJobTypeSwitchService` | `com.nms4cloud.pos.print.service.PrintJobTypeSwitchService` | 打印开关配置 |

---

## 2. 实体类映射

### 2.1 数据库实体

| 实体类 | 表名 | 所在模块 |
|--------|------|----------|
| `PosPrnPrinter` | `pos_prn_printer` | `nms4pos-pos` |
| `PosPrnQueue` | `pos_prn_queue` | `nms4pos-pos` |
| `PosPrnStyleRow` | `pos_prn_style_row` | `nms4pos-pos` |
| `PosPrnJob` | `pos_prn_job` | `nms4pos-pos` |
| `PosPrnPrinterTransfer` | `pos_prn_printer_transfer` | `nms4pos-pos` |
| `PosCustomerBillSetting` | `pos_customer_bill_setting` | `nms4pos-pos` |
| `PosWaiterBillSetting` | `pos_waiter_bill_setting` | `nms4pos-pos` |
| `PrintJobTypeSwitch` | `print_job_type_switch` | `nms4pos-pos` |

### 2.2 VO/DTO类

| 类名 | 类型 | 用途 |
|------|------|------|
| `PosPrnJobVO` | VO | 打印任务视图对象 |
| `PosPrnJobCreateDTO` | DTO | 打印任务创建DTO |
| `PosPrnJobListDTO` | DTO | 打印任务列表查询DTO |
| `PosPrnStyleRowVO` | VO | 打印样式行视图对象 |
| `PosPrnQueueVO` | VO | 打印队列视图对象 |
| `PosPrnPrinterVO` | VO | 打印机视图对象 |
| `PrnDataSourceDTO` | DTO | 打印数据源DTO |

---

## 3. 枚举类映射

### 3.1 打印相关枚举

| 枚举类 | 路径 | 说明 |
|--------|------|------|
| `PrinterTypeEnum` | `com.nms4cloud.pos.print.enums.PrinterTypeEnum` | 打印机类型 |
| `PrnStyleTypeEnum` | `com.nms4cloud.pos.print.enums.PrnStyleTypeEnum` | 打印样式类型 |
| `PrnJobStatusEnum` | `com.nms4cloud.pos.print.enums.PrnJobStatusEnum` | 打印任务状态 |
| `PrnJobPurposeEnum` | `com.nms4cloud.pos.print.enums.PrnJobPurposeEnum` | 打印用途 |
| `ConditionOperatorEnum` | `com.nms4cloud.pos.print.enums.ConditionOperatorEnum` | 条件运算符 |

---

## 4. Controller映射

### 4.1 打印管理Controller

| Controller | 包路径 | 职责 |
|------------|--------|------|
| `PosPrnPrinterController` | `com.nms4cloud.pos.print.controller` | 打印机CRUD |
| `PosPrnQueueController` | `com.nms4cloud.pos.print.controller` | 打印队列CRUD |
| `PosPrnStyleRowController` | `com.nms4cloud.pos.print.controller` | 打印样式CRUD |
| `PosCustomerBillSettingController` | `com.nms4cloud.pos.print.controller` | 顾客联设置CRUD |
| `PosWaiterBillSettingController` | `com.nms4cloud.pos.print.controller` | 传菜联设置CRUD |
| `PrintJobController` | `com.nms4cloud.pos.print.controller` | 打印任务操作(重打/取消) |

---

## 5. 配置文件映射

### 5.1 配置类

| 配置类 | 路径 | 说明 |
|--------|------|------|
| `PrintProperties` | `com.nms4cloud.pos.print.config.PrintProperties` | 打印模块配置属性 |
| `PrinterWorkerConfig` | `com.nms4cloud.pos.print.config.PrinterWorkerConfig` | Worker线程池配置 |
| `PrinterDriverAutoConfiguration` | `com.nms4cloud.pos.print.config.PrinterDriverAutoConfiguration` | 驱动自动配置 |

### 5.2 yml配置示例

```yaml
pos:
  print:
    # .job文件存储目录
    job-dir: ${user.home}/pos_print_jobs
    # Worker线程池大小
    worker-pool-size: 3
    # 故障恢复间隔(ms)
    fault-recover-interval: 2000
    # 故障超时阈值(ms)
    fault-timeout: 2700000
```

---

## 6. 文档映射

| 文档 | 路径 | 说明 |
|------|------|------|
| 打印系统总览 | `docs/print/打印系统总览.md` | 四层架构总览 |
| 打印任务创建与队列分发 | `docs/print/打印任务创建与队列分发.md` | 核心流程详解 |
| 打印问题排查指南 | `docs/print/打印问题排查指南.md` | 故障排查手册 |
| ESC/POS指令参考 | `docs/print/ESC_POS指令参考.md` | 打印指令文档 |

---

## 7. 缓存Key映射

### 7.1 JetCache

| Key Pattern | 缓存内容 | 超时 |
|-------------|----------|------|
| `pos_prn_queue:{mid}:{lid}` | PosPrnQueueVO | 按需刷新 |
| `pos_prn_style_row:{mid}:{sid}:{type}` | List\<PosPrnStyleRowVO\> | 按需刷新 |
| `pos_printer:{mid}:{lid}` | PosPrnPrinterVO | 按需刷新 |

### 7.2 Redis

| Key Pattern | 存储内容 | 说明 |
|-------------|----------|------|
| `pos_service:pos_prn_job:count:{lid}` | Integer | 打印次数 |
| `pos_printer:status:{printerLid}` | String | HEALTHY/FAULT |

---

## 8. 文件存储映射

### 8.1 .job文件

```
{appDir}/jobs/{yyyy-MM-dd}/{lid}.job
```

| 操作 | 方法 |
|------|------|
| 写入 | `PosPrnJobServicePlus.keepToFile()` |
| 读取 | `PrintJobInitUtil.loadFromFile()` |
| 删除 | 任务完成后重命名为 `.del` |

---

## 9. 定时任务映射

| 定时任务 | Cron | 职责 |
|----------|------|------|
| `PrintJobTimeoutTask` | ? | 超时任务处理 |
| `PrinterStatusCheckTask` | ? | 打印机状态巡检 |

---

## 10. 模块依赖关系

```
nms4pos-pos
├── pos-printer-driver-*        # 各类型打印机驱动
│   ├── pos-printer-driver-net  # 网络驱动
│   ├── pos-printer-driver-com  # 串口驱动
│   ├── pos-printer-driver-usb  # USB驱动
│   ├── pos-printer-driver-cloud # 云打印驱动
│   └── pos-printer-driver-driver # Windows驱动
└── pos-printer-cloud-*         # 云打印集成
    ├── pos-printer-cloud-xy    # 芯烨云
    └── pos-printer-cloud-jb    # 佳博云
```

---

*文档版本：v1.0 | 生成时间：2026-08-03*
