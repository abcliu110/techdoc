# DA7 - 实现映射分析

> **SOP-00 §DA7 执行记录**
> 将代码实现与业务模型对应，解答 DA0 问题基线

---

## 一、核心实现组件

### 1.1 nms4pos 打印引擎实现

#### PosPrnJobServicePlus 实现分析

```java
// 文件位置: nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/PosPrnJobServicePlus.java

@Service
public class PosPrnJobServicePlus {
    // 1132 行核心实现

    /**
     * 创建打印任务
     * Q-01: 如何保证可靠性？
     */
    public void create(PrintJobDTO job) {
        // 1. 生成任务ID (雪花算法)
        long lid = idGenerator.nextId();

        // 2. 构建任务实体
        PrintJobEntity entity = buildEntity(job, lid);

        // 3. 文件存储 (可靠性保障)
        //    - 先写文件，持久化打印数据
        //    - 文件路径: /print_jobs/{mid}/{sid}/{lid}.json
        keepToFile(entity);

        // 4. Redis 计数 (性能优化)
        //    - Key: prn:count:{queueLid}
        //    - TTL: 15分钟
        //    - 原子递增
        String redisKey = "prn:count:" + job.getQueueLid();
        Long count = redisTemplate.opsForValue().increment(redisKey);
        if (count == 1) {
            // 首次设置 TTL
            redisTemplate.expire(redisKey, 15, TimeUnit.MINUTES);
        }

        // 5. 发布事件 (状态同步)
        //    - PrintTaskCreated
        //    - 供前台监控消费
        applicationEventPublisher.publishEvent(
            new PrintTaskCreatedEvent(this, entity)
        );
    }

    /**
     * 文件存储实现
     * Q-01: 文件存储与Redis计数一致性？
     */
    private void keepToFile(PrintJobEntity entity) {
        // 目录结构: /print_jobs/{mid}/{sid}/
        // 文件名: {lid}.json
        // 编码: UTF-8
        Path path = Paths.get(baseDir, entity.getMid(), entity.getSid(), entity.getLid() + ".json");
        Files.write(path, JsonUtil.toJson(entity).getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 获取任务 (从文件恢复)
     */
    private PrintJobEntity getFromFile(long lid) {
        Path path = findFileByLid(lid);
        if (path != null) {
            String json = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            return JsonUtil.parse(json, PrintJobEntity.class);
        }
        return null;
    }

    /**
     * 标记失败
     * Q-01: 重试机制参数？
     */
    public void markFailed(long lid, String errorMsg) {
        PrintJobEntity entity = getFromFile(lid);
        entity.setJobStatus(JobStatus.FAILED);
        entity.setErrorMsg(errorMsg);
        entity.setRetryCount(entity.getRetryCount() + 1);

        // 检查是否超过最大重试次数 (默认3次)
        if (entity.getRetryCount() < entity.getMaxRetries()) {
            // 触发重试调度
            // 指数退避: 1min, 2min, 4min
            scheduleRetry(entity, calculateBackoff(entity.getRetryCount()));
        } else {
            // 超过最大重试次数，等待归档
            entity.setJobStatus(JobStatus.FAILED);
        }

        keepToFile(entity);
    }

    /**
     * 归档失败任务
     */
    public void archiveFailed() {
        // 定期清理 24 小时前的失败任务
        // 移动到归档目录
    }
}
```

#### PrintHandlerFactory 实现分析

```java
// 文件位置: nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/handler/PrintHandlerFactory.java

public class PrintHandlerFactory {

    /**
     * 获取 Handler 实例
     * Q-03: 样式模板如何实现跨协议兼容？
     */
    public static PrinterHandler getHandler(PrinterModelEnum model) {
        return switch (model) {
            case TSPL_TSC -> new TsplPrinterHandler();
            case ZPL_HIPPO -> new ZplPrinterHandler();
            case ESC -> new EscPrinterHandler();
            case OPOS_HIOPOS -> new OposPrinterHandler();
            case HP_PCL -> new PclPrinterHandler();
            case PDF -> new PdfPrinterHandler();
            default -> new DefaultPrinterHandler();
        };
    }
}
```

#### Handler 接口定义

```java
public interface PrinterHandler {
    /**
     * 执行打印
     * @param data 渲染后的打印数据
     * @param printer 打印机信息
     */
    void execute(String data, Printer printer) throws PrintException;
}
```

#### 7 种 Handler 实现

| Handler | 协议 | 关键实现 |
|---------|------|----------|
| `TsplPrinterHandler` | TSPL | `SIZE`, `GAP`, `TEXT`, `BARCODE`, `QRCODE` 命令 |
| `ZplPrinterHandler` | ZPL | `^XA`, `^FO`, `^A0`, `^BQN`, `^XZ` 命令 |
| `EscPrinterHandler` | ESC/POS | 字节流: `ESC @`, `ESC !`, `GS v 0` |
| `OposPrinterHandler` | OPOS | `POSPrinter` COM 对象, JNA 调用 |
| `PclPrinterHandler` | PCL | HP PCL 5 命令 |
| `PdfPrinterHandler` | PDF | 生成 PDF 文件 |
| `DefaultPrinterHandler` | ESC/POS | 通用 ESC/POS fallback |

#### Virtual Thread 调度器实现

```java
// 文件位置: nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/scheduler/PrintScheduler.java

public class PrintScheduler {
    // Java 21 Virtual Thread

    private final ExecutorService virtualThreadPool =
        Executors.newVirtualThreadPerTaskExecutor();

    /**
     * 提交打印任务
     * Q-04: 打印性能瓶颈在哪里？
     */
    public void submit(PrintJobEntity job) {
        virtualThreadPool.submit(() -> {
            try {
                // 每个任务一个虚拟线程
                // 阻塞 I/O 不占用平台线程
                executeJob(job);
            } catch (Exception e) {
                // 异常处理
                markFailed(job.getLid(), e.getMessage());
            }
        });
    }

    /**
     * 执行打印任务
     */
    private void executeJob(PrintJobEntity job) {
        // 1. 获取打印机
        Printer printer = printerService.getByLid(job.getPrinterLid());

        // 2. 获取 Handler
        PrinterHandler handler = PrintHandlerFactory.getHandler(printer.getModel());

        // 3. 获取样式
        PrintStyle style = styleService.getByLid(job.getPrnStyleLid());

        // 4. 渲染模板
        String data = styleEngine.render(style, job.getPrintData());

        // 5. 执行打印
        handler.execute(data, printer);
    }
}
```

---

## 二、nms4cloud 打印 API 实现

### 2.1 PosPrnJobController

```java
// 文件位置: nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/controller/admin/PosPrnJobController.java

@RestController
@RequestMapping("/pos_prn_job")
public class PosPrnJobController {

    @Autowired
    private PosPrnJobServicePlus service;

    /**
     * 查询打印任务列表
     * Q-06: 打印日志与审计如何实现？
     */
    @PostMapping("/list")
    public R<PageResult<PrintJobVO>> list(@RequestBody PrintJobQueryDTO query) {
        return service.list(query);
    }

    /**
     * 重打任务
     */
    @PostMapping("/reprint/{lid}")
    public R<Void> reprint(@PathVariable Long lid) {
        service.reprint(lid);
        return R.ok();
    }
}
```

### 2.2 PosPrnStyleController

```java
// 文件位置: nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-biz/src/main/java/com/nms4cloud/pos/controller/admin/PosPrnStyleController.java

@RestController
@RequestMapping("/pos_prn_style")
public class PosPrnStyleController {

    @Autowired
    private PosPrnStyleServicePlus service;

    /**
     * 保存样式
     * Q-09: 票据类型扩展机制？
     */
    @PostMapping("/save")
    public R<Void> save(@RequestBody PrintStyleDTO dto) {
        service.saveOrUpdate(dto);
        return R.ok();
    }
}
```

---

## 三、nms4pos-ui 前台实现

### 3.1 PrintTaskMonitor

```jsx
// 文件位置: nms4pos-ui/app/pos4desktop/src/pages/FunctionPanel/pages/PrintTaskMonitor/

// 打印任务监控看板
// 功能:
// 1. 展示当前队列任务
// 2. 实时状态更新
// 3. 重打/取消操作
```

### 3.2 PosPrnStyleRowPage

```jsx
// 文件位置: nms4pos-ui/app/pos4desktop/src/pages/PosPrnStyleRowPage/

// 打印样式行编辑器
// 功能:
// 1. 样式项列表展示
// 2. 拖拽排序
// 3. 样式项编辑
// 4. 预览功能
```

---

## 四、nms4cloud-biz-ui 后台实现

### 4.1 PrintMgr 主页面

```tsx
// 文件位置: nms4cloud-biz-ui/src/pages/PrintMgr/index.tsx

// 打印管理中心
// 布局:
// - 左侧: 设备管理 (计算机/打印机/打印开关/打印队列)
// - 右侧: 样式配置 (6大类票据)
// - Modal: 各子模块详情
```

### 4.2 样式分组定义

```tsx
// PrintMgr 中的样式分类
const STYLE_GROUPS = [
  {
    key: 'cashier',
    title: '收银票据',
    types: ['Nodiscount', 'Discount', 'CheckOut', 'CheckOutFull', 'CashboxPop'],
  },
  {
    key: 'kitchen',
    title: '后厨票据',
    types: ['OrderMenu', 'OrderMenuEx', 'TotalBill', 'HurryMenu', ...],
  },
  {
    key: 'report',
    title: '报表票据',
    types: ['ShiftReport', 'DateSalesReport', 'BuMenReport', ...],
  },
  {
    key: 'member',
    title: '会员与短信',
    types: ['MemberSavingBill', 'SMS_CRM_REG', ...],
  },
  {
    key: 'other',
    title: '其他票据',
    types: ['OrderBill', 'QueueBill', 'FoodLabel', ...],
  },
  {
    key: 'wms',
    title: 'WMS票据样式',
    types: ['WMS_STORE_ORDER', 'WMS_ST_CHECK_BILL', ...], // 50+ 种
  },
];
```

---

## 五、问题基线解答

### Q-01: 打印任务如何保证可靠性？

| 机制 | 实现 | 说明 |
|------|------|------|
| 文件持久化 | `keepToFile()` | JSON 文件存储，断电不丢失 |
| Redis 计数 | 15min TTL | 高性能计数缓存 |
| 重试机制 | `markFailed()` + 指数退避 | 1min, 2min, 4min 间隔 |
| 最大重试 | `maxRetries` (默认3) | 防止无限重试 |
| 失败归档 | `archiveFailed()` | 24小时后清理 |

### Q-02: 多打印机如何负载均衡？

**当前实现**：队列可绑定多打印机，但未发现复杂负载均衡逻辑。
**实际场景**：通常一队列对应一打印机，简化路由。

### Q-03: 样式模板如何实现跨协议兼容？

| 方案 | 说明 |
|------|------|
| Handler 模式 | 7种Handler各自实现协议转换 |
| 模板引擎 | `PrintStyleEngine.render()` 统一渲染 |
| 样式配置 | 与协议无关，协议差异由 Handler 处理 |

**结论**：样式模板存储结构相同，由 Handler 负责协议转换，实现跨协议兼容。

### Q-04: 打印性能瓶颈在哪里？

| 瓶颈点 | 优化方案 |
|--------|----------|
| 网络打印机延迟 | Virtual Thread，非阻塞I/O |
| 文件I/O | 批量写入，异步化 |
| 串口通信 | 超时设置，避免阻塞 |
| 样式渲染 | 缓存已加载样式 |

### Q-05: 门店离线场景如何处理？

| 场景 | 处理方式 |
|------|----------|
| nms4cloud 离线 | nms4pos 独立运行，使用本地配置 |
| nms4pos 离线 | 无法打印，云端任务堆积 |
| 网络中断 | 任务本地暂存，恢复后重试 |

**结论**：两套系统职责分离，nms4pos 负责实际打印，nms4cloud 负责配置管理。

### Q-06: 打印日志与审计如何实现？

| 维度 | 实现 |
|------|------|
| 任务日志 | 文件存储包含完整任务数据 |
| 状态变更 | 消息事件发布 (`PrintTaskUpdated`) |
| 重打记录 | `reprint()` 方法记录重打次数 |
| 导出能力 | `GET /pos_prn_job/export` 导出Excel |

### Q-07: 样式编辑器的实现机制？

| 组件 | 实现 |
|------|------|
| 行编辑器 | `PosPrnStyleRowPage` React组件 |
| 样式项存储 | `prn_style_items` 表 + `style_content` JSON |
| 序列化 | `PrintStyleItem` → JSON |
| 预览 | 调用后端预览接口，返回渲染结果 |

### Q-08: 打印开关的粒度控制？

| 维度 | 实现组件 |
|------|----------|
| 门店级别 | 样式关联门店 |
| 打印机级别 | 打印机状态 |
| 队列级别 | `PrintQueue.isEnabled` |
| 类型级别 | `PrintJobTypeSwitchPage` |

### Q-09: 票据类型扩展机制？

| 扩展方式 | 操作 |
|----------|------|
| 新增票据类型 | `PrnStyleTypeEnum` 添加枚举值 |
| 前端展示 | PrintMgr `STYLE_GROUPS` 添加 |
| 样式模板 | 创建新样式记录 |

### Q-10: 厨打与客单的打印时序？

| 场景 | 时序 |
|------|------|
| 结账完成 | 1. 打印客单 2. 打印厨打（并行或串行） |
| 厨打分发 | 按部门分组，每部门一个任务 |
| 优先级 | 催菜(`HurryMenu`)优先处理 |

---

## 六、实现与模型映射

| 业务模型 | 代码实现 | 仓库 |
|----------|----------|------|
| 打印任务创建 | `PosPrnJobServicePlus.create()` | nms4pos |
| 打印任务查询 | `PosPrnJobController.list()` | nms4cloud |
| 打印样式管理 | `PosPrnStyleController` | nms4cloud |
| Handler工厂 | `PrintHandlerFactory` | nms4pos |
| 虚拟线程调度 | `PrintScheduler` | nms4pos |
| 前台监控 | `PrintTaskMonitor` | nms4pos-ui |
| 后台管理 | `PrintMgr` | nms4cloud-biz-ui |
