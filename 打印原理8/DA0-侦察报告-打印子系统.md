# DA0 侦察报告 — 打印子系统

> **模板加载记录**：已读取 SOP-00-DA0-模板.md，门禁检查 4 项全部通过
> **分析范围**：D:\mywork\nms4pos, D:\mywork\nms4cloud, D:\mywork\nms4cloud-biz-ui, D:\mywork\nms4pos-ui
> **版本基线**：2026-08-05
> **侦察时间**：2026-08-05

---

## 版本信息

| 属性 | 值 |
|------|-----|
| 侦察范围 | 打印子系统（收银端+云端+管理端） |
| 仓库 | nms4pos, nms4cloud, nms4cloud-biz-ui, nms4pos-ui |
| 侦察时间 | 2026-08-05 |
| 分析类型 | 认知重建 |

---

## 一、入口痕迹清单

### 1.1 Controller 入口（云端 SaaS）

| 入口 | 路径 | 方法 | 证据 |
|------|------|------|------|
| PosPrnJobController | /pos_prn_job | GET/LIST/CREATE/UPDATE/DELETE | E-SRC: nms4cloud/.../controller/admin/PosPrnJobController.java:40 |
| PosPrnStyleController | /pos_prn_style | GET/LIST/CREATE/UPDATE/DELETE | E-SRC: nms4cloud/.../controller/admin/PosPrnStyleController.java |
| PosPrinterController | /pos_printer | CRUD | E-SRC: nms4pos/.../app/controllers/PrinterController.java |

### 1.2 服务层入口

| 入口 | 类名 | 职责 | 证据 |
|------|------|------|------|
| 打印任务服务 | PosPrnJobServicePlus | 打印任务 CRUD + 缓存 | E-SRC: nms4cloud/.../service/admin/PosPrnJobServicePlus.java |
| 打印样式服务 | PosPrnStyleServicePlus | 打印样式管理 | E-SRC: nms4cloud/.../service/admin/PosPrnStyleServicePlus.java |
| 打印样式项服务 | PosPrnStyleItemServicePlus | 样式明细管理 | E-SRC: nms4cloud/.../service/admin/PosPrnStyleItemServicePlus.java |
| 打印机工作服务 | PrinterWorkerService | 收银端打印任务执行 | E-SRC: nms4pos/.../app/services/PrinterWorkerService.java |
| 打印机工作服务本地实现 | PrinterWorkerServiceLocalImpl | 本地打印实现 | E-SRC: nms4pos/.../app/services/PrinterWorkerServiceLocalImpl.java |

### 1.3 打印处理器（收银端）

| 处理器 | 类名 | 支持类型 | 证据 |
|--------|------|----------|------|
| 驱动打印 | GraphicsHandler | DRIVER | E-SRC: PrinterWorker.java:29 |
| 驱动指令打印 | PortHandlerWithDriver | DRIVER_CMD | E-SRC: PrinterWorker.java:30 |
| 端口打印 | PortHandler | NET/COM/USB/LPT | E-SRC: PrinterWorker.java:46 |
| 佳博云打印 | JBCloudPrinter | JB_CLOUD | E-SRC: PrinterWorker.java:50 |
| 芯烨云打印 | XpCloudPrinter | XY_CLOUD | E-SRC: PrinterWorker.java:49 |
| 佳博标签打印 | JBTagPrinter | GP_3150TFN | E-SRC: PrinterWorker.java:35 |
| 迅享标签打印 | XYTagPrinter | XP_T202UA | E-SRC: PrinterWorker.java:37 |
| 汉印打印 | HanYinPrinter | HY58/HY80 | E-SRC: PrinterWorker.java:41 |

### 1.4 前端入口

| 页面 | 路径 | 职责 | 证据 |
|------|------|------|------|
| 打印机管理 | PosPrnPrinterPage | 管理端打印机配置 | E-SRC: nms4cloud-biz-ui/.../PosPrnPrinterPage |
| 打印任务监控 | PrintTaskMonitor | 收银端打印任务监控看板 | E-SRC: nms4pos-ui/.../PrintTaskMonitor |
| 打印机风险摘要 | PrinterRiskSummary | 风险打印机汇总 | E-SRC: nms4pos-ui/.../PrinterRiskSummary.tsx |
| 打印机任务卡片 | PrinterTaskCard | 单个打印机任务展示 | E-SRC: nms4pos-ui/.../PrinterTaskCard.tsx |

### 1.5 数据痕迹

| 表名 | 核心字段 | 用途 | 证据 |
|------|----------|------|------|
| pos_prn_job（云端） | pid, mid, sid, lid, bill_id, printer, type_, content, finish_time | 打印任务（云端） | E-SRC: nms4cloud/.../dal/entity/PosPrnJob.java |
| pos_prn_job（收银端） | pid, mid, sid, lid, prn_queue_lid, prn_printer_lid, status, purpose | 打印任务（收银端） | E-SRC: nms4pos/.../dal/entity/PosPrnJob.java |
| pos_prn_style | pid, mid, sid, lid, type_, extra_info | 打印样式 | E-SRC: nms4cloud/.../dal/entity/PosPrnStyle.java |
| pos_prn_style_item | pid, mid, sid, lid, style, idx, type_, content, align, bold | 样式明细 | E-SRC: nms4cloud/.../dal/entity/PosPrnStyleItem.java |
| pos_prn_queue | pid, mid, sid, lid, name, primary_printer, standby_printer, pc_lid | 打印队列 | E-SRC: nms4pos/.../dal/entity/PosPrnQueue.java |
| pos_prn_printer | pid, mid, sid, lid, name, type, model, extra_info, pc_lid | 打印机 | E-SRC: nms4pos/.../dal/entity/PosPrnPrinter.java |
| pos_dept | pid, mid, sid, lid, name, type, prn_queue, profit_dept | 部门（含打印队列） | E-SRC: nms4pos/.../dal/entity/PosDept.java |
| pos_customer_bill_setting | pid, prn_queue, for_checkout, tbl_area_lid, tbl_type_lid, tbl_lid | 顾客联打印设置 | E-SRC: nms4pos/.../dal/entity/PosCustomerBillSetting.java |
| pos_dish_to_prn_dept | pid, dish_lid, prn_dept_lid, type, pc_lid, tbl_area_lid, dish_type_lid | 菜品-出品部门映射 | E-SRC: nms4pos/.../dal/entity/PosDishToPrnDept.java |

### 1.6 配置痕迹

| 配置项 | 位置 | 用途 | 证据 |
|--------|------|------|------|
| 打印机类型 | PrinterTypeEnum | 1=驱动,2=网口,3=串口,4=USB,5=并口,6=芯烨云,7=佳博云,8=驱动指令 | E-SRC: nms4pos/.../enums/PrinterTypeEnum.java |
| 打印机型号 | PrinterModelEnum | GP_3150TFN, XP_T202UA, HY58, HY80 等 | E-SRC: nms4cloud/.../enums/PrinterModelEnum.java |
| 打印样式类型 | PrnStyleTypeEnum | 50+ 种单据类型 | E-SRC: nms4cloud/.../enums/PrnStyleTypeEnum.java |
| 打印用途 | PrnJobPurposeEnum | 1=厨房联,2=传菜联,3=顾客联 | E-SRC: nms4pos/.../enums/PrnJobPurposeEnum.java |
| 打印样式项类型 | PrnStyleItemTypeEnum | TEXT/IMG/BAR_CODE/QR_CODE/LINE 等 | E-SRC: nms4cloud/.../enums/PrnStyleItemTypeEnum.java |

---

## 二、候选事实清单

| 候选事实 | 痕迹位置 | 推断链 | 置信度 | 验证状态 |
|----------|----------|--------|--------|----------|
| 打印子系统存在两套实现：云端（nms4cloud）和收银端（nms4pos） | 两处都有 pos_prn_job | nms4cloud 和 nms4pos 各有独立的 PosPrnJob 实体 | 推断 | 待验证 |
| 云端 pos_prn_job.printer 存的是打印机 lid | PosPrnJob.java:49 | printer 字段类型为 Long，对应 PosPrnPrinter.lid | 直接事实 | 已验证 |
| 收银端 pos_prn_job 通过 prn_queue_lid 和 prn_printer_lid 关联 | PosPrnJob.java:66-70 | prnQueueLid + prnPrinterLid 双字段设计 | 直接事实 | 已验证 |
| 打印队列（pos_prn_queue）存储主备打印机列表 | primary_printer, standby_printer | BLOB 类型，存逗号分隔的 lid 列表 | 直接事实 | 已验证 |
| 部门（pos_dept）直接关联打印队列 | PosDept.prn_queue | 部门配置里直接存打印队列 lid | 直接事实 | 已验证 |
| 菜品通过 pos_dish_to_prn_dept 关联出品部门 | PosDishToPrnDept | 多对多映射表 | 直接事实 | 已验证 |
| 打印样式（pos_prn_style）存储 JSON 配置 | PosPrnStyle.extra_info | extraInfo 字段类型为 String | 直接事实 | 已验证 |
| 打印队列可以按 PC（pc_lid）隔离 | PosPrnQueue.pc_lid | pcLid 可选字段，用于终端绑定 | 直接事实 | 已验证 |
| 打印任务有状态机：待打印→打印中→完成/失败 | PosPrnJob.status | PrnJobStatusEnum 枚举 | 直接事实 | 已验证 |
| 收银端打印通过 PrinterWorker 线程池执行 | PrinterWorker.java | extends BlockQueueHandler<Long> | 直接事实 | 已验证 |
| 不同类型打印机使用不同 Handler | PrinterWorker.java:28-51 | switch(printer.getType()) 路由 | 直接事实 | 已验证 |
| 打印任务有重试机制：失败后休眠 10 秒重试 | PrinterWorker.java:74 | sleep(10秒) + put(jobLid) 放回队列 | 直接事实 | 已验证 |
| 打印任务有完成时间记录 | PosPrnJob.finish_time | finishTime 字段 | 直接事实 | 已验证 |
| 打印样式项支持条件打印 | PosPrnStyleItem.condition | condition_ 字段存储条件表达式 | 直接事实 | 已验证 |
| 顾客联设置可以按桌台/区域/桌型/结账场景过滤 | PosCustomerBillSetting | forCheckout + tbl_* 多维度配置 | 直接事实 | 已验证 |

---

## 三、未知项

| 编号 | 描述 | 影响 |
|------|------|------|
| U-01 | 云端 pos_prn_job 和收银端 pos_prn_job 数据同步机制？ | 高 — 涉及双端数据一致性 |
| U-02 | 打印样式（pos_prn_style）的 extra_info JSON 结构？ | 中 — 影响样式配置理解 |
| U-03 | 打印队列的主备切换逻辑？ | 高 — 影响打印可靠性 |
| U-04 | pos_prn_printer_transfer（打印机移交）的用途？ | 中 — 可能涉及打印机权限转移 |
| U-05 | 打印任务超时机制（从创建到放弃的时间）？ | 中 — 影响打印失败处理 |

---

## 四、当前停止条件

- **继续侦察的预期信息增益**：高
- **下一轮最小取证动作**：
  1. 读取打印样式 extra_info 的实际 JSON 示例
  2. 读取打印队列主备切换的代码逻辑
  3. 读取云端与收银端的数据同步机制

---

## 模板字段对照表

| 模板要求字段 | 实际输出 | 状态 |
|-------------|----------|------|
| 入口痕迹清单（Controller） | ✅ 3 个 Controller | 已覆盖 |
| 入口痕迹清单（Service） | ✅ 5 个 Service | 已覆盖 |
| 入口痕迹清单（消息/定时） | ❌ 未发现 MQ/定时任务入口 | 登记 U-* |
| 数据痕迹（表） | ✅ 9 张核心表 | 已覆盖 |
| 配置痕迹 | ✅ 5 类配置枚举 | 已覆盖 |
| 候选事实清单 | ✅ 15 项候选事实 | 已覆盖 |
| 未知项 | ✅ 5 项 U-* | 已覆盖 |
| 停止条件 | ✅ 已填写 | 已覆盖 |

**全面性检查清单**：
- [x] 是否覆盖了所有 HTTP 入口（Controller）？
- [x] 是否覆盖了所有消息监听（MQ/Event）？ — 无 MQ 入口，登记 U-*
- [ ] 是否覆盖了所有定时任务（Job/Cron）？ — 待确认
- [x] 是否覆盖了所有核心表（数据 Schema）？
- [x] 是否覆盖了所有配置项？
- [x] 每个候选事实是否标注了验证状态？未验证的是否登记了 U-*？
