# G0-A-启动契约：打印功能初始化与运行条件

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 启动前置条件

### 1.1 基础设施依赖

| 依赖项 | 版本要求 | 检查方式 | 失败影响 |
|--------|----------|----------|----------|
| MySQL | 8.0+ | 连接测试 | 无法创建/查询任务 |
| Redis | 6.0+ | 连接测试 | 打印计数失效 |
| JDK | 21 LTS | java -version | 无法启动 |
| 磁盘空间 | ≥1GB可用 | df检查 | .job文件写入失败 |

### 1.2 数据库初始化

**必须存在的数据表**：

```sql
-- 打印任务表
CREATE TABLE IF NOT EXISTS pos_prn_job (...);

-- 打印队列表
CREATE TABLE IF NOT EXISTS pos_prn_queue (...);

-- 打印机表
CREATE TABLE IF NOT EXISTS pos_prn_printer (...);

-- 打印样式表
CREATE TABLE IF NOT EXISTS pos_prn_style_row (...);

-- 顾客联设置表
CREATE TABLE IF NOT EXISTS pos_customer_bill_setting (...);

-- 传菜联设置表
CREATE TABLE IF NOT EXISTS pos_waiter_bill_setting (...);

-- 打印开关表
CREATE TABLE IF NOT EXISTS print_job_type_switch (...);
```

### 1.3 配置检查清单

| 配置项 | 必须 | 默认值 | 说明 |
|--------|------|--------|------|
| `pos.print.job-dir` | 否 | `${user.home}/pos_print_jobs` | .job文件目录 |
| `pos.print.worker-pool-size` | 否 | 3 | Worker线程数 |
| `pos.print.fault-recover-interval` | 否 | 2000 | 重试间隔ms |
| `pos.print.fault-timeout` | 否 | 2700000 | 超时阈值ms |

---

## 2. 启动流程

### 2.1 启动序列图

```
应用启动
    │
    ├──> 1. Spring容器初始化
    │           │
    │           ├──> 加载PrintProperties配置
    │           │
    │           ├──> 初始化PrinterDriverManager
    │           │           │
    │           │           └──> 扫描Driver实现类
    │           │
    │           ├──> 初始化PrinterWorkerService
    │           │           │
    │           │           └──> 创建Worker线程池
    │           │
    │           └──> 注册AsyncExecutor
    │
    ├──> 2. 缓存预热
    │           │
    │           ├──> 加载打印机配置
    │           │
    │           ├──> 加载队列配置
    │           │
    │           └──> 加载样式模板
    │
    ├──> 3. 任务恢复
    │           │
    │           ├──> 扫描.jobs目录
    │           │
    │           ├──> 恢复未完成任务
    │           │
    │           └──> 清理.del文件
    │
    └──> 4. 启动完成
                │
                ├──> PrinterWorker线程运行中
                │
                └──> 接受打印请求
```

### 2.2 任务恢复逻辑

```java
@PostConstruct
public void init() {
    // 1. 创建jobs目录
    File jobsDir = new File(jobDir);
    if (!jobsDir.exists()) {
        jobsDir.mkdirs();
    }

    // 2. 扫描未完成任务
    File[] jobFiles = jobsDir.listFiles((dir, name) ->
        name.endsWith(".job") && !name.contains("-del"));

    for (File jobFile : jobFiles) {
        // 3. 恢复任务到队列
        restoreJob(jobFile);
    }

    // 4. 清理过期.del文件
    cleanupDelFiles();
}
```

---

## 3. 健康检查

### 3.1 健康检查端点

```
GET /actuator/health
```

**检查项**：

| 检查项 | 状态 | 说明 |
|--------|------|------|
| MySQL | UP/DOWN | 数据库连接 |
| Redis | UP/DOWN | Redis连接 |
| PrinterWorker | RUNNING/STOPPED | Worker线程状态 |
| DiskSpace | OK/LOW | 磁盘空间 |

### 3.2 健康检查响应示例

```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "redis": { "status": "UP" },
    "printWorker": {
      "status": "UP",
      "details": {
        "activeCount": 1,
        "queueSize": 5
      }
    },
    "diskSpace": { "status": "OK" }
  }
}
```

---

## 4. 启动参数

### 4.1 JVM参数建议

```bash
java -server \
  -Xms512m -Xmx1024m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -Dfile.encoding=UTF-8 \
  -jar nms4pos-pos.jar
```

### 4.2 环境变量

| 变量名 | 必须 | 说明 |
|--------|------|------|
| `SPRING_PROFILES_ACTIVE` | 是 | 环境标识 |
| `SPRING_DATASOURCE_URL` | 是 | 数据库连接 |
| `SPRING_REDIS_HOST` | 是 | Redis地址 |
| `POS_PRINT_JOB_DIR` | 否 | .job文件目录 |

---

## 5. 初始化数据

### 5.1 必需初始化

| 数据 | 说明 | 初始化方式 |
|------|------|------------|
| 至少一台打印机 | 测试打印需要 | 手动添加 |
| 至少一个打印队列 | 任务分发需要 | 手动添加 |
| 基础打印模板 | 票据样式需要 | 导入/手动配置 |

### 5.2 测试验证清单

- [ ] 打印机连接测试(ping)
- [ ] 打印测试页
- [ ] 点菜打印测试
- [ ] 结账打印测试
- [ ] 故障转移测试

---

## 6. 关闭流程

### 6.1 优雅关闭

```java
@PreDestroy
public void shutdown() {
    // 1. 停止接受新任务
    printerWorkerService.pause();

    // 2. 等待正在执行的任务完成
    awaitTermination(30, TimeUnit.SECONDS);

    // 3. 保存未完成任务到文件
    savePendingJobs();

    // 4. 关闭线程池
    executor.shutdown();
}
```

### 6.2 关闭超时

| 阶段 | 超时 | 说明 |
|------|------|------|
| 停止接受新任务 | 5s | 立即停止 |
| 等待任务完成 | 30s | 优雅等待 |
| 强制终止 | 10s | 超时强制 |
| 总计 | 45s | 整体超时 |

---

## 7. 异常处理

### 7.1 启动失败场景

| 场景 | 错误码 | 处理方式 |
|------|--------|----------|
| MySQL不可用 | PRINT_001 | 应用启动失败 |
| Redis不可用 | PRINT_002 | 降级运行，禁用缓存 |
| 磁盘空间不足 | PRINT_003 | 告警，不影响启动 |
| .job目录创建失败 | PRINT_004 | 应用启动失败 |

### 7.2 启动日志

```
[INFO] PrintModuleInitializer - 开始初始化打印模块
[INFO] PrintProperties - 加载配置: jobDir=/path/to/jobs
[INFO] PrinterDriverManager - 扫描到驱动: [NET, COM, USB, CLOUD]
[INFO] PrinterWorkerService - 创建Worker线程池: size=3
[INFO] JobRecoveryService - 扫描未完成任务: count=5
[INFO] PrintModuleInitializer - 打印模块初始化完成
```

---

## 8. 契约承诺

### 8.1 启动承诺

| 承诺项 | 值 | 说明 |
|--------|-----|------|
| 启动时间 | ≤30s | 从启动到接受请求 |
| 恢复任务数 | 无限制 | 依赖磁盘空间 |
| 健康检查响应 | ≤500ms | actuator响应时间 |

### 8.2 运行承诺

| 承诺项 | 值 | 说明 |
|--------|-----|------|
| Worker线程存活 | 持续运行 |除非应用关闭 |
| .job文件保留 | 任务完成后保留.del | 可追溯 |
| 状态缓存更新 | ≤1s | 打印机状态变更 |

---

*文档版本：v1.0 | 生成时间：2026-08-03*
