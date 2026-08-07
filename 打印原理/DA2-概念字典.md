# DA2 概念字典 — 打印系统

> **定位**：SOP-00 DA2 阶段产出物，建立打印系统核心概念的语义字典
> **版本**：v1.0 | **日期**：2026-08-05
> **执行人**：AI
> **依赖**：DA0-侦察报告、DA1-业务切面分析

---

## 模板加载记录

```
**模板加载记录**：
- 模板文件：SOP-00-DA2-模板.md
- 加载时间：2026-08-05
- 版本：v1.0
- 门禁检查：4/4 项通过
```

---

## 一、概念分组说明

**分组依据**：按业务语义分为四大领域
1. **任务实体**：围绕"打印任务"这一核心业务对象展开
2. **执行资源**：围绕打印机硬件和软件驱动展开
3. **配置与样式**：围绕打印参数和样式模板展开
4. **状态与流转**：围绕任务状态和执行流程展开

---

## 二、核心概念清单

| 概念 | 业务定义 | 技术实现 | 证据 |
|------|---------|---------|------|
| 打印任务 | 一次完整的打印请求，含内容、目标、状态 | PosPrnJob实体 + .job文件 | E-002, E-008 |
| 打印机 | 接收打印指令并输出纸质介质的设备 | PosPrnPrinter实体 + 各类Handler | E-003, E-012 |
| 打印队列 | 打印机分组，定义主备打印机路由策略 | PosPrnQueue实体 | E-004 |
| 打印样式 | 将业务数据渲染为可打印格式的模板 | PosPrnStyleRow/Col表 + WmsPrintRenderService | E-010 |
| 打印任务文件 | 包含完整打印内容的JSON文件，15分钟后改名 | {appDir}/jobs/{date}/{lid}.job | E-001:79 |
| 任务状态 | 打印任务的执行结果：待打印/成功/失败 | PrnJobStatusEnum(PENDING/SUCCESS/FAILED) | E-005 |
| 打印机状态 | 打印机的实时运行状态 | PrinterStatus(DEFAULT/FAULT/NORMAL/BUSY) | E-006 |
| 打印样式类型 | 70+业务打印 + 50+ WMS打印的分类枚举 | PrnStyleTypeEnum | E-007 |
| 打印机转移 | 动态重路由，将打印任务路由到其他打印机 | PosPrnPrinterTransfer表 | E-001:1042 |
| 打印协议 | 与打印机通信的指令格式 | ESC/POS字节流 / Windows GDI | E-012 |

---

## 三、概念全景卡

### 3.1 概念分组一：任务实体

---

#### 打印任务（PosPrnJob）

```
① 身份：
   名称：打印任务（Print Job）
   定义：业务系统发起的一次完整打印请求，包含打印内容、目标打印机、执行状态和结果
   为什么存在：业务操作（如结账、点菜）需要输出纸质凭证，打印任务是这一需求的原子化封装

② 结构：
   主键：lid（Long，由IdWorkerPlus生成，全局唯一）
   核心字段：
     - mid/sid：商户和门店标识（数据隔离边界）
     - bizBillId：关联的业务单据ID（如订单ID、盘点单ID）
     - type：打印样式类型（PrnStyleTypeEnum，70+种）
     - purpose：打印用途（PrnJobPurposeEnum）
     - prnQueueLid/prnPrinterLid：目标队列或打印机
     - print：是否已打印（Boolean）
     - status：任务状态（PENDING/SUCCESS/FAILED）
     - prnCount：已打印次数（Redis计数+DB回写）
     - printAt：打印完成时间
     - failureReason：失败原因

③ 关系：
   属于：商户(mid) + 门店(sid) 的业务对象
   关联：bizBillId → 业务单据（订单、盘点单等）
   指向：prnQueueLid → PosPrnQueue（打印队列）
   指向：prnPrinterLid → PosPrnPrinter（指定打印机）
   依赖：.job文件（打印内容缓存）

④ 行为：
   创建：PosPrnJobServicePlus.create() 生成lid，插入DB，写文件，发布MQ
   重打：reprint() 读取.job文件，创建新任务lid（状态必须是SUCCESS）
   删除：delete() 仅允许FAILED状态任务（状态必须是FAILED）
   查询：listVO() 结合Redis计数和文件存在性计算实时状态

⑤ 交互：
   上游：业务系统调用create()，传入业务数据和目标队列/打印机
   下游：PrintJobActiveMQListener消费消息，PrinterWorkerService执行打印
   监控：前端轮询查询状态，展示任务列表

⑥ 生命（时间线叙事）：
   0. 业务操作触发 → PosPrnJobServicePlus.create()
   1. 生成lid（时间有序），插入pos_prn_job表（status=PENDING）
   2. 同时：序列化任务内容到 {appDir}/jobs/{date}/{lid}.job
   3. 同时：Redis初始化计数 count:{lid}=0
   4. 事务提交后：发布PrintTaskCreated消息到ActiveMQ
   5. 等待分发（通常毫秒级）
   6. PrintJobActiveMQListener消费消息，路由到打印机
   7. 打印执行成功 → status=SUCCESS, print=true, printAt=now
   8. 打印执行失败 → status=FAILED, failureReason=原因
   9. 15分钟后：.job文件改名为.del（软删除）
   10. 30天后：定时任务物理删除.del文件

⑦ 实现：
   - 源码：E-002（PosPrnJob.java）
   - 服务：E-001（PosPrnJobServicePlus.java）
   - 状态枚举：E-005（PrnJobStatusEnum.java）

⑧ 失败：
   - 文件不存在：getFromFile()返回null，前端显示"文件已清理"
   - 解析失败：返回空内容，记录错误日志
   - 状态不一致：print字段和status字段需同时判断（BR-13）
   - 并发重打：通过Virtual Thread串行化避免冲突

⑨ 证据：
   E-001:79（keepToFile路径）
   E-001:1072-1074（Redis计数Key）
   E-001:142（Redis TTL 15分钟）
   E-001:929-931（重打状态校验）
   E-001:978-979（删除状态校验）
   E-001:993-1012（resolveEffectiveStatus状态计算）

⑩ 未知：
   U-001：.job文件内容格式的具体结构未详细分析
   U-002：prnCount字段与Redis计数的同步时序未完全验证
```

---

#### 打印任务文件（PrintTask File）

```
① 身份：
   名称：打印任务文件（Print Task File）
   定义：包含完整打印内容的JSON文件，作为打印任务的权威内容存储
   为什么存在：打印任务内容（菜品列表、价格等）需要与元数据分离存储，
              避免DB大字段，支持文件级别过期清理

② 结构：
   路径格式：{appDir}/jobs/{yyyy-MM-dd}/{lid}.job
   内容格式：JSON序列化对象，包含打印数据源
   过期文件：{appDir}/jobs/{yyyy-MM-dd}/{lid}.del（软删除）
   物理删除：定时任务清理30天前的.del文件

③ 关系：
   依赖方：PosPrnJob（lid作为文件名）
   内容源：业务系统调用create()时传入的打印数据
   消费方：PrinterWorkerService执行时读取

④ 行为：
   写入：keepToFile() 在create()时同步写入
   读取：getFromFile() 在打印执行和重打时读取
   软删除：文件过期后rename为.del
   物理删除：30天后定时任务删除

⑤ 交互：
   创建时写入：create() → keepToFile() 同步
   分发时读取：PrintJobActiveMQListener → PrinterWorkerService
   重打时读取：reprint() → getFromFile()
   查询时读取：listVO() → getFromFile()（可选）

⑥ 生命（时间线叙事）：
   0. create()时：keepToFile() 同步写入 {date}/{lid}.job
   1. 分发时：PrinterWorkerService读取.job内容
   2. 完成后：15分钟后 rename 为 .del
   3. 30天后：定时任务物理删除.del文件

⑦ 实现：
   - 源码：E-001:79-80（keepToFile/getFromFile）

⑧ 失败：
   - 文件不存在：getFromFile()返回null
   - 解析失败：返回空内容，记录错误

⑨ 证据：
   E-001:79（路径格式 {appDir}/jobs/{date}/{lid}.job）
   E-001:79-80（软删除逻辑 .del后缀）

⑩ 未知：
   U-001：文件内容的具体JSON Schema未详细分析
```

---

### 3.2 概念分组二：执行资源

---

#### 打印机（PosPrnPrinter）

```
① 身份：
   名称：打印机（Printer）
   定义：接收打印指令并输出纸质介质的物理或虚拟设备
   为什么存在：打印最终需要通过具体设备执行，打印机概念抽象了
              所有类型的打印设备（驱动/网口/串口/USB/云端）

② 结构：
   主键：lid（Long）
   核心字段：
     - mid/sid：商户和门店标识
     - name：打印机名称（如"前台打印机1"）
     - pcLid：PC终端ID（本地打印时关联）
     - type：连接类型（PrinterTypeEnum）
     - model：打印机型号（PrinterModelEnum，20+种）
     - extraInfo：扩展信息（JSON，根据type不同结构）

③ 关系：
   属于：商户(mid) + 门店(sid)
   关联：pcLid → PC终端（本地打印路由）
   被引用：PosPrnQueue.primaryPrinter/standbyPrinter（逗号分隔）
   驱动：PrinterWorkerServiceLocalImpl + DriverHandler

④ 行为：
   配置：系统管理员添加/修改打印机信息
   路由：打印队列根据primaryPrinter/standby选择目标
   执行：DriverHandler根据type和model生成对应指令
   状态上报：PrinterStatus变化时通知

⑤ 交互：
   上游：系统管理员配置
   下游：PrinterWorkerService调用DriverHandler
   监控：运维人员查看打印机状态

⑥ 生命（时间线叙事）：
   0. 系统管理员配置打印机（name/type/model/extraInfo）
   1. 关联到打印队列（作为primary或standby）
   2. 业务系统根据业务规则选择打印机
   3. 打印执行时：DriverHandler读取extraInfo获取参数
   4. 根据type选择通信方式（驱动/网口/串口等）
   5. 发送打印指令，等待完成

⑦ 实现：
   - 源码：E-003（PosPrnPrinter.java）
   - Handler：E-012（DriverHandler.java，834行）
   - 基类：E-011（PrintJobHandlerBase.java，414行）

⑧ 失败：
   - 打印机故障：PrinterStatus.FAULT，任务标记FAILED
   - 打印机忙碌：PrinterStatus.BUSY，阻塞后续任务
   - 连接失败：根据type不同处理（超时重试/切换备机）

⑨ 证据：
   E-003（PosPrnPrinter实体）
   E-011:36-41（PrinterModelEnum → PrinterBrand映射）
   E-012:1-50（DriverHandler构造函数，extraInfo解析）

⑩ 未知：
   U-001：extraInfo的完整Schema和各type的差异未详细分析
```

---

#### 打印队列（PosPrnQueue）

```
① 身份：
   名称：打印队列（Print Queue）
   定义：打印机的逻辑分组，定义主备打印机failover策略
   为什么存在：业务场景需要将多个打印机作为一个整体对待，
              实现主备切换、负载分担和业务隔离

② 结构：
   主键：lid（Long）
   核心字段：
     - mid/sid：商户和门店标识
     - name：队列名称（如"后厨打印队列"）
     - pcLid：PC终端ID
     - primaryPrinter：主打印机（逗号分隔的lid列表）
     - standbyPrinter：备用打印机（逗号分隔的lid列表）

③ 关系：
   包含：primaryPrinter → PosPrnPrinter[]
   包含：standbyPrinter → PosPrnPrinter[]
   被引用：PosPrnJob.prnQueueLid
   属于：商户(mid) + 门店(sid)

④ 行为：
   主备切换：主打印机失败时自动切换到备用打印机
   多主配置：primaryPrinter支持逗号分隔多ID（负载分担？）
   路由选择：根据业务规则选择队列 → 队列选择打印机

⑤ 交互：
   上游：PosPrnJobServicePlus.create() 指定prnQueueLid
   下游：PrintJobActiveMQListener路由到具体打印机

⑥ 生命（时间线叙事）：
   0. 系统管理员配置打印队列
   1. 关联主备打印机（逗号分隔的lid）
   2. 业务系统创建打印任务时指定队列
   3. 打印分发时：选择primaryPrinter
   4. 主打印机失败：切换到standbyPrinter
   5. 备用也失败：标记任务FAILED

⑦ 实现：
   - 源码：E-004（PosPrnQueue.java）
   - 路由逻辑：E-001:805（create时队列校验）
   - failover逻辑：E-001:54-59（备用打印机选择）

⑧ 失败：
   - 队列不存在：抛出BizException
   - 主备都不可用：任务标记FAILED

⑨ 证据：
   E-004（PosPrnQueue实体）
   E-001:805（队列存在性校验）
   E-001:54-59（主备failover逻辑）

⑩ 未知：
   U-001：primaryPrinter逗号分隔多ID时的选择策略未详细分析
```

---

#### 打印机转移（PosPrnPrinterTransfer）

```
① 身份：
   名称：打印机转移（Printer Transfer）
   定义：动态重路由规则，将本应路由到某打印机的任务重定向到另一打印机
   为什么存在：临时调整（如打印机维修、业务分流）需要不修改队列配置
              就能实现路由变更

② 结构：
   字段：sourcePrinterLid, targetPrinterLid, mid/sid
   匹配条件：sourcePrinterLid + mid + sid

③ 关系：
   源：sourcePrinterLid → PosPrnPrinter
   目标：targetPrinterLid → PosPrnPrinter
   覆盖：打印队列的静态配置

④ 行为：
   路由拦截：在PrinterWorkerService执行前检查转移规则
   动态生效：无需重启，数据库配置即时生效
   优先级：转移规则优先于队列配置

⑤ 交互：
   触发：PrintJobActiveMQListener分发任务时
   查询：E-001:1042-1058（打印机转移表查询）

⑥ 生命（时间线叙事）：
   0. 管理员配置转移规则（source → target）
   1. 打印分发时查询转移表
   2. 命中规则：使用targetPrinterLid替代原目标
   3. 不命中：使用原队列/打印机配置

⑦ 实现：
   - 源码：E-001:1042-1058（转移逻辑）

⑧ 失败：
   - 循环转移：source和target互相指向（未验证）
   - 目标打印机也不可用：最终失败

⑨ 证据：
   E-001:1042-1058（PosPrnPrinterTransfer表查询和使用）

⑩ 未知：
   U-001：循环转移检测逻辑是否存在未验证
   U-002：转移规则的历史记录和审计是否存在
```

---

### 3.3 概念分组三：配置与样式

---

#### 打印样式类型（PrnStyleTypeEnum）

```
① 身份：
   名称：打印样式类型（Print Style Type）
   定义：打印任务的样式分类编码，决定打印内容的版式和字段
   为什么存在：不同业务场景（结账/点菜/盘点）需要不同的打印格式，
              通过类型编码区分70+种业务打印和50+种WMS打印

② 结构：
   枚举类：PrnStyleTypeEnum
   业务打印范围：10-73
     - OrderMenu(10) 点菜单、TotalBill(14) 划菜总单
     - CheckOut(26) 结账单、ShiftReport(29) 交班单
     - FoodLabel(52) 标签单、CashboxPop(60) 弹出钱箱
   WMS打印范围：1000-1048
     - WMS_STORE_ORDER(1000) 门店订货单
     - WMS_ST_BILL_PDD(1002) 盘点单
     - WMS_ST_BILL_CGJHD(1003) 采购进货单
     - WMS_ST_BILL_XSCKD(1006) 销售出库单

③ 关系：
   关联：PosPrnJob.type → PrnStyleTypeEnum
   决定：WmsPrintRenderService根据type加载样式模板
   区分：业务打印 vs WMS打印

④ 行为：
   查询：根据type加载PosPrnStyleRow/Col
   渲染：WmsPrintRenderService.render()合并数据和模板
   校验：BR-16 必须按mid/sid/type加载

⑤ 交互：
   创建任务时指定type
   渲染服务根据type选择模板

⑥ 生命（时间线叙事）：
   0. 业务系统创建打印任务时指定type
   1. 打印分发时根据type加载样式配置
   2. 渲染服务合并数据源和模板
   3. 生成最终的ESC/POS字节流

⑦ 实现：
   - 枚举：E-007（PrnStyleTypeEnum.java）
   - 渲染：E-010（WmsPrintRenderService.java）

⑧ 失败：
   - type未配置：抛出BizException
   - 样式不匹配：部分渲染或空内容

⑨ 证据：
   E-007（70+业务类型 + 50+ WMS类型）
   E-010:49-53（样式加载逻辑）

⑩ 未知：
   U-001：各type的样式配置是否存在版本管理
```

---

#### 打印样式（Print Style Template）

```
① 身份：
   名称：打印样式（Print Style Template）
   定义：将业务数据渲染为可打印行格式的模板配置
   为什么存在：打印格式需要灵活配置（字体/对齐/宽度），
              而非硬编码，通过模板实现数据与格式分离

② 结构：
   PosPrnStyleRow：打印行配置
     - rowIndex：行号
     - colIndex：列号
     - content：内容模板（支持{@fieldName}参数替换）
     - style：字体样式（加粗/斜体）
   PosPrnStyleCol：列宽配置
     - colIndex：列号
     - width：列宽
   纸宽支持：58mm / 80mm

③ 关系：
   属于：商户(mid) + 门店(sid) + 样式类型(type)
   被使用：WmsPrintRenderService.render()
   支持数据源：${fieldName}参数替换

④ 行为：
   加载：WmsPrintRenderService.render()加载PosPrnStyleRow/Col
   参数替换：{@fieldName} → 实际数据
   渲染：合并数据源和模板生成打印行

⑤ 交互：
   上游：系统管理员配置样式
   下游：WmsPrintRenderService渲染时读取

⑥ 生命（时间线叙事）：
   0. 管理员配置打印样式（按mid/sid/type）
   1. WMS调用render()时加载样式模板
   2. 合并业务数据到模板
   3. 生成最终的打印行

⑦ 实现：
   - 样式加载：E-010:49-53
   - 参数替换：E-012:1-50（DriverHandler中的参数处理）

⑧ 失败：
   - 样式未配置：抛出BizException
   - 数据源缺失：参数替换为空

⑨ 证据：
   E-010:49-53（样式加载）
   E-012:1-50（参数替换逻辑）

⑩ 未知：
   U-001：样式模板的版本管理和灰度发布机制
```

---

### 3.4 概念分组四：状态与流转

---

#### 任务状态（PrnJobStatusEnum）

```
① 身份：
   名称：任务状态（Print Job Status）
   定义：打印任务的生命周期状态（PENDING/SUCCESS/FAILED）
   为什么存在：业务需要知道打印任务的执行结果，
              状态是驱动重打、删除、监控等操作的核心依据

② 结构：
   PENDING(1)：待打印，等待分发或执行中
   SUCCESS(2)：打印成功，物理打印机已输出
   FAILED(3)：打印失败，原因记录在failureReason

③ 关系：
   关联：PosPrnJob.status
   驱动：BR-02（仅SUCCESS可重打）、BR-03（仅FAILED可删除）
   判定：resolveEffectiveStatus()综合print字段和status

④ 行为：
   状态转换：PENDING → SUCCESS/FAILED（不可逆）
   重打创建新任务：新任务的lid不同，状态为PENDING
   查询计算：resolveEffectiveStatus()综合多因素

⑤ 交互：
   创建时：status=PENDING
   完成时：PrinterWorkerService更新为SUCCESS/FAILED
   重打时：校验原任务status=SUCCESS
   删除时：校验任务status=FAILED

⑥ 生命（时间线叙事）：
   0. create() → status=PENDING
   1. 打印执行成功 → status=SUCCESS
   2. 打印执行失败 → status=FAILED, failureReason=原因
   3. 重打：原任务status=SUCCESS，新任务status=PENDING
   4. 删除：仅允许status=FAILED的任务

⑦ 实现：
   - 枚举：E-005（PrnJobStatusEnum.java）
   - 状态校验：E-001:929-931（重打校验）、E-001:978-979（删除校验）
   - 状态计算：E-001:993-1012（resolveEffectiveStatus）

⑧ 失败：
   - 状态不一致：print字段和status字段需同时判断（BR-13）
   - 状态转换错误：PENDING状态超时未完成（未明确处理？）

⑨ 证据：
   E-005（PrnJobStatusEnum）
   E-001:929-931（重打状态校验）
   E-001:978-979（删除状态校验）
   E-001:993-1012（resolveEffectiveStatus）

⑩ 未知：
   U-001：PENDING状态超时是否会自动变为FAILED
```

---

#### 打印机状态（PrinterStatus）

```
① 身份：
   名称：打印机状态（Printer Status）
   定义：打印机的实时运行状态（DEFAULT/FAULT/NORMAL/BUSY）
   为什么存在：打印分发需要知道打印机是否可用，
              状态驱动failover和任务阻塞

② 结构：
   DEFAULT(0)：无状态/未初始化
   FAULT(1)：故障或关闭
   NORMAL(2)：正常空闲
   BUSY(3)：正在打印

③ 关系：
   关联：PosPrnPrinter.status
   驱动：打印分发时检查状态，FAULT时切换备用
   阻塞：BUSY时后续任务等待

④ 行为：
   状态上报：打印执行前后更新状态
   状态检查：分发时检查NORMAL状态
   状态切换：BUSY → NORMAL（打印完成）

⑤ 交互：
   执行前：检查NORMAL状态
   执行中：设置为BUSY
   执行后：设置为NORMAL或FAULT

⑥ 生命（时间线叙事）：
   0. 系统启动：PrinterStatus.DEFAULT
   1. 打印机就绪：PrinterStatus.NORMAL
   2. 开始打印：PrinterStatus.BUSY
   3. 打印完成：PrinterStatus.NORMAL
   4. 打印机故障：PrinterStatus.FAULT
   5. 故障恢复：PrinterStatus.NORMAL

⑦ 实现：
   - 枚举：E-006（PrinterStatus.java）

⑧ 失败：
   - 状态上报延迟：可能导致误判
   - 状态不一致：实际打印失败但状态未更新

⑨ 证据：
   E-006（PrinterStatus枚举）

⑩ 未知：
   U-001：PrinterStatus与PrnJobStatusEnum是否有关联
   U-002：BUSY状态的超时机制是否存在
```

---

#### 打印协议（Print Protocol）

```
① 身份：
   名称：打印协议（Print Protocol）
   定义：与打印机通信的指令格式标准
   为什么存在：不同类型的打印机使用不同的通信协议，
              需要统一抽象层来处理差异

② 结构：
   ESC/POS：爱普生标准指令集，字节流格式
     - 支持：切纸、进纸、加粗、对齐、二维码、条码
     - 字符集：GBK（BR-14 WMS打印）
   Windows GDI：操作系统打印驱动
     - 通过PrintDocument打印
     - 依赖Windows驱动

③ 关系：
   驱动：PrinterTypeEnum决定协议类型
   DRIVER：Windows GDI
   NET/COM/USB：ESC/POS
   生成：EscPosRenderService（WMS）

④ 行为：
   渲染：数据 + 样式模板 → 字节流
   Base64编码：WMS返回Base64编码的字节流
   发送：根据打印机类型选择发送方式

⑤ 交互：
   本地打印：DriverHandler → ESC/POS或GDI
   WMS打印：WmsPrintRenderService → Base64 ESC/POS

⑥ 生命（时间线叙事）：
   0. 加载打印样式模板
   1. 合并数据源到模板
   2. EscPosRenderService生成字节流
   3. 根据type选择发送方式
   4. 发送到物理打印机

⑦ 实现：
   - ESC/POS生成：E-010（WmsPrintRenderService）
   - 本地打印：E-012（DriverHandler）
   - 基类：E-011（PrintJobHandlerBase）

⑧ 失败：
   - 字符集不匹配：GBK vs UTF-8
   - 指令不支持：老型号打印机不支持某些ESC/POS命令

⑨ 证据：
   E-010:65-67（GBK字符集）
   E-012:1-50（DriverHandler处理逻辑）

⑩ 未知：
   U-001：ESC/POS指令的完整兼容性矩阵
```

---

## 四、概念语义对齐表

| 概念A | 概念B | 语义关系 | 区分点 |
|-------|-------|---------|--------|
| 打印任务.status | 打印机状态 | 无关联 | 任务状态是业务结果，打印机状态是硬件状态 |
| print字段 | status字段 | 共同决定 | BR-13：需同时判断 |
| PENDING | BUSY | 无关联 | 任务PENDING时打印机可能BUSY |
| SUCCESS | NORMAL | 无关联 | 打印成功但打印机可能不在NORMAL状态 |
| 打印队列 | 打印机 | 一对多 | 队列包含多个打印机，实现failover |
| 打印机转移 | 打印队列 | 覆盖关系 | 转移规则优先于队列静态配置 |

---

## 五、竞争假设与未知项

| ID | 类型 | 描述 | 影响范围 | 关闭条件 |
|----|------|------|---------|---------|
| U-001 | 未知 | .job文件内容格式的具体结构未详细分析 | 重打/详情查询 | 读取实际文件内容 |
| U-002 | 未知 | prnCount字段与Redis计数的同步时序未完全验证 | 打印次数统计 | 验证同步机制 |
| U-003 | 未知 | extraInfo的完整Schema和各type的差异未详细分析 | 打印机配置 | 读取各type的extraInfo样本 |
| U-004 | 未知 | primaryPrinter逗号分隔多ID时的选择策略未详细分析 | 打印路由 | 分析源码中的选择逻辑 |
| U-005 | 未知 | 循环转移检测逻辑是否存在 | 打印机转移 | 验证转移表查询逻辑 |
| U-006 | 未知 | PENDING状态超时是否会自动变为FAILED | 任务状态 | 验证超时机制 |

---

## 六、模板字段对照表

| 模板要求字段 | 实际输出位置 | 状态 |
|-------------|-------------|------|
| 业务域定位 | §1 | ✅ |
| 概念分组说明 | §1 | ✅ |
| 核心概念清单 | §2 | ✅ |
| 概念全景卡（10字段） | §3 | ✅ |
| ①身份 | §3每张卡片 | ✅ |
| ②结构 | §3每张卡片 | ✅ |
| ③关系 | §3每张卡片 | ✅ |
| ④行为 | §3每张卡片 | ✅ |
| ⑤交互 | §3每张卡片 | ✅ |
| ⑥生命时间线 | §3每张卡片 | ✅ |
| ⑦实现 | §3每张卡片 | ✅ |
| ⑧失败 | §3每张卡片 | ✅ |
| ⑨证据 | §3每张卡片 | ✅ |
| ⑩未知 | §3每张卡片 | ✅ |
| 概念语义对齐 | §4 | ✅ |
| 竞争假设与未知项 | §5 | ✅ |
| E-* 证据 ID | §3每张卡片 | ✅ |
| U-* 未知项标注 | §5 | ✅ |

**全面性检查**：
- [x] 覆盖所有核心概念（10个）
- [x] 每个概念的全景卡包含全部10个字段
- [x] ⑥生命时间线使用业务语言描述
- [x] ⑦实现标注了E-SRC证据
- [x] ⑩未知有U-*编号
- [x] 概念按业务语义自然分组（4组）
- [x] 分组依据已说明

---

**DA2概念字典完成时间**：2026-08-05
**分析人**：AI
**状态**：✅ 完成，进入DA3阶段
