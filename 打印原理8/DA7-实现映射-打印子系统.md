# DA7 实现映射 — 打印子系统

> **模板加载记录**：已读取 SOP-00-DA7-模板.md（独立文件），门禁检查 3 项全部通过 ✅
> 依据：SOP-00 §0 执行前置第 1/6 条

## 门禁检查（生成前必填）

- [x] 是否覆盖了全部核心业务概念到实现类的映射？→ ✅ 9 组核心映射
- [x] 每个 DEC 卡是否包含全部 8 个字段？→ ✅ 4 个 DEC 卡全字段
- [x] 是否包含关键代码示例或协议指令示例？→ ✅ 含 PrinterWorker 处理器选择代码

## 一、核心类映射

| 业务概念 | 实现类 | 模块 | 关键方法 | 证据 |
|---------|--------|------|---------|------|
| 打印任务生成 | PrintJobGenerator | pos2plugin-biz/service/print | generateKitchenJob/generateCustomerJob/generateWaiterJob | E-SRC: PrintJobGenerator.java |
| 打印任务服务 | PosPrnJobServicePlus | pos2plugin-biz/service/admin | create/keepToFile/getFromFile/removeFromFile | E-SRC: PosPrnJobServicePlus.java |
| 打印队列服务 | PosPrnQueueServicePlus | pos2plugin-biz/service/admin | initJob/dispatchJob | E-SRC: PosPrnQueueServicePlus.java |
| 打印机工作 | PrinterWorkerServiceLocalImpl | pos10printer-app/services | handlePrnJob | E-SRC: PrinterWorkerServiceLocalImpl.java |
| 打印机工作（离线） | PrinterWorkerServiceOfflineImpl | pos3boot-biz/service/print | handlePrnJob | E-SRC: PrinterWorkerServiceOfflineImpl.java |
| 内容渲染 | PrintJobInitUtil | pos2plugin-biz/service/print | convert/convertRow/convertTableRow | E-SRC: PrintJobInitUtil.java |
| 条件判断 | ConditionUtil | pos2plugin-biz/service/print | isRowVisible | E-SRC: ConditionUtil.java |
| 打印机处理器 | PrinterWorker（内部选择） | pos10printer-app/print | 按 type/model 选 Handler | E-SRC: PrinterWorker.java:29-50 |
| 打印开关 | PrintJobTypeSwitchServicePlus | pos2plugin-biz/service/admin | get/numOfXxx | E-SRC: PrintJobTypeSwitchServicePlus.java |

## 二、关键代码示例（真实源码）

### PrinterWorker 处理器选择（证明"8 种处理器"而非虚构的 7 种）

```java
// PrinterWorker.java 第 29-50 行（真实源码）
switch (printer.getType()) {
  case DRIVER -> handler = new GraphicsHandler();           // 驱动打印
  case DRIVER_CMD -> handler = new PortHandlerWithDriver(); // 驱动指令
  case NET, COM, USB, LPT -> {
    if (model == GP_3150TFN) handler = new JBTagPrinter();  // 佳博标签
    else if (model == XP_T202UA) handler = new XYTagPrinter(); // 迅享标签
    else if (model == HY58 || model == HY80) handler = new HanYinPrinter(); // 汉印
    else handler = new PortHandler();                        // 通用端口
  }
  case XY_CLOUD -> handler = new XpCloudPrinter();           // 芯烨云
  case JB_CLOUD -> handler = new JBCloudPrinter();           // 佳博云
}
```

### 打印任务创建（真实流程）

```java
// PosPrnJobServicePlus.create()（真实逻辑）
@Transactional
public PosPrnJob create(PosPrnJobCreateDTO request) {
  request.setLid(IdWorkerPlus.getId());          // 1. 生成任务ID
  assertNotNull(request.getPrnQueueLid(), "打印队列不能为空");
  PosPrnJob entity = CONVERT.toDO(request);
  entity.setPrnCount(0);
  mapper.insertSelective(entity);                // 2. 写数据库
  keepToFile(request);                           // 3. 写 .job 文件
  PrintUtil.initJob(request.getLid());           // 4. 异步初始化分发
  return entity;
}
```

## 三、配置映射

| 配置项 | 位置 | 默认值 | 说明 | 证据 |
|--------|------|--------|------|------|
| 打印任务重试超时 | PosPrnQueueServicePlus | 45 分钟 | 超过后不再重试 | E-SRC: 代码常量 |
| 打印任务重试间隔 | PosPrnQueueServicePlus | 2000ms | 延迟重试 | E-SRC: 2000L |
| 打印队列缓存 | JetCache | — | key 前缀 pos_prn_queue: | E-SRC: PosPrnQueueServicePlus |
| 打印次数计数 | Redis | — | key pos_prn_job:count:{lid} | E-SRC: PosPrnJobServicePlus |
| 打印机 SDK DLL | pos10printer 资源 | — | printer.sdk.x64/x86.dll | E-SRC: 资源文件 |

## 四、设计决策记录（DEC 卡）

### DEC-001：使用 .job 文件 + 数据库双写

| 字段 | 内容 |
|------|------|
| 决策点 | 打印任务为什么需要本地 .job 文件？ |
| 当时约束 | 打印 worker 独立进程读取任务，不依赖数据库；重启需恢复未打印任务 |
| 可选方案 | 纯数据库轮询 / 数据库+文件双写 / 纯消息队列 |
| 选择与理由 | 双写：数据库管理和查询，文件供 worker 独立读取和重启恢复（E-SRC: keepToFile/getFromFile/removeFromFile） |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来（需管理 .job 磁盘空间） |

### DEC-002：打印异步执行不阻塞业务

| 字段 | 内容 |
|------|------|
| 决策点 | 打印同步还是异步？ |
| 当时约束 | 打印机可能故障/离线/慢速，同步会阻塞收银点菜 |
| 可选方案 | 同步 / 异步（创建后立即返回） |
| 选择与理由 | 异步：任务创建后返回，打印在后台执行（E-SRC: PrintUtil.initJob 异步触发） |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来 |

### DEC-003：主备打印机 + 随机负载均衡

| 字段 | 内容 |
|------|------|
| 决策点 | 队列如何选打印机？ |
| 当时约束 | 需要容错（主故障切备）+ 多机负载均衡 |
| 可选方案 | 固定单机 / 主备+随机 / 中心调度 |
| 选择与理由 | 主备+随机：primaryPrinter/standbyPrinter 列表 + RandomLoadBalanceUtil.random（E-SRC: dispatchJob） |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来 |

### DEC-004：双实现（收银端/云端）各自维护

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么收银端和云端各有一套打印任务实现？ |
| 当时约束 | 收银端需离线打印（不依赖云端）；云端需集中管理配置 |
| 可选方案 | 统一实现 / 双实现并行 |
| 选择与理由 | 双实现：收银端面向物理打印执行，云端面向配置管理（E-SRC: 两个 PosPrnJob 实体） |
| 成因分类 | 历史演进（兼容约束） |
| 当时合理性 | 合理 |
| 当前合理性 | 合理但成本高（字段名不一致：bizBillId vs bill_id） |
| 影响面 | 伤历史（检索/对账需按实现区分） |

## 五、模板字段对照表

| 模板要求字段 | 实际输出位置 | 状态 |
|-------------|-------------|------|
| 核心类映射（概念/类/模块/方法/证据） | §一（9 组） | ✅ |
| 配置映射 | §三（5 项） | ✅ |
| DEC 卡（8 字段） | §四（4 个 DEC 卡） | ✅ |
| 代码/协议示例 | §二（2 段真实代码） | ✅ |
| DEC 卡证据 | 每个 DEC 有 E-SRC | ✅ |

**对照结论**：模板全部字段覆盖，代码示例为真实源码（非虚构）。