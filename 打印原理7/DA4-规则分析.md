# DA4 规则分析 — 打印子系统

## 一、业务规则汇总

| 规则编号 | 规则内容 | 约束级别 | 证据 |
|---------|---------|---------|------|
| BR-01 | 打印类型开关控制是否启用和打印张数：每种打印类型可独立配置 disabledCustomer/disabledKitchen/disabledWaiter 和 numOfCustomer/numOfKitchen/numOfWaiter | MUST | E-SRC: PrintJobTypeSwitch + PrintJobGenerator.getNumOfXxx |
| BR-02 | 顾客联队列选择按优先级：桌台级 > 区域级 > 桌型级 > PC 级。顾客来源时按此顺序，非顾客来源时 PC 级优先 | MUST | E-SRC: PrintJobGenerator.generateCustomerJob |
| BR-03 | 厨房联按菜品出品部门分发：每个菜品关联一个出品部门（prnDeptLid），部门关联一个打印队列，同一部门的菜品合并打印 | MUST | E-SRC: PrintJobGenerator.generateKitchenJob |
| BR-04 | 传菜联按传菜间设置分发：传菜设置关联一组出品部门，只有出品部门匹配的菜品才进入该传菜间的小票 | MUST | E-SRC: PrintJobGenerator.generateWaiterJob |
| BR-05 | 主打印机故障时切换到备用打印机：随机负载均衡选择健康打印机，主打印机全挂时使用备打印机 | MUST | E-SRC: PosPrnQueueServicePlus.dispatchJob |
| BR-06 | 打印任务超时 45 分钟不再重试：从任务创建开始，超过 45 分钟仍无可用打印机则放弃 | MUST | E-SRC: PosPrnQueueServicePlus.overTaskTime 常量 |
| BR-07 | 打印条件配置错误时默认显示行：任何条件格式错误/数据源不存在/字段不存在都返回 true，不隐藏行 | MUST | E-SRC: ConditionUtil.isRowVisible |
| BR-08 | 打印任务异步执行，不阻塞核心业务：创建任务后立即返回，初始化和分发异步进行 | MUST | E-SRC: PrintUtil.initJob → JobTaskHandle |
| BR-09 | 打印机状态实时更新，故障打印机不参与分发：PrinterStatus.FAULT 的打印机被过滤 | MUST | E-SRC: PosPrnQueueServicePlus.selectHealthyPrinters |
| BR-10 | 打印张数小于 0 时按 1 处理：`getNumOfXxx` 返回负数时修正为 1 | SHOULD | E-SRC: PrintJobGenerator.getNumOfXxx |
| BR-11 | 打印开关未配置时默认返回 1 张：`PrintJobTypeSwitch` 不存在时默认打印 1 份 | SHOULD | E-SRC: PrintJobGenerator.getNumOfXxx |
| BR-12 | 列内容占位符格式为 `"dsId,fieldId"`：运行时从对应数据源取值填充 | MUST | E-SRC: PrintJobInitUtil.calculateColContent |
| BR-13 | 金额格式化：BigDecimal 保留两位小数，去掉尾部 `.00` | SHOULD | E-SRC: PrintJobInitUtil.formatContent |
| BR-14 | 日期格式化：Date→HH:mm:ss, LocalDateTime→yyyy-MM-dd HH:mm:ss，零点去掉时间部分 | SHOULD | E-SRC: PrintJobInitUtil.formatContent |
| BR-15 | 顾客联找不到任何设置时直接跳过，不打印顾客联 | MUST | E-SRC: PrintJobGenerator.generateCustomerJob |
| BR-16 | 表格行按汇总列分组：存在汇总列时按该列内容分组，每组输出分组标题+明细+小计+总合计 | MUST | E-SRC: PrintJobInitUtil.convertTableRow |
| BR-17 | 列宽超过 100% 时自动折行：`convertLineRow` 中宽度累加 > 100 时换行 | MUST | E-SRC: PrintJobInitUtil.convertLineRow |
| BR-18 | 钱箱弹出任务不需要样式模板：CashboxPop 类型直接设置空 rows | MUST | E-SRC: PosPrnQueueServicePlus.initJob |

## 二、重试/恢复规则

| 规则编号 | 规则内容 | 参数 | 证据 |
|---------|---------|------|------|
| RR-01 | 打印任务分发失败时延迟 2 秒重试 | delay=2000ms | E-SRC: PosPrnQueueServicePlus.dispatchJob |
| RR-02 | 打印任务最多重试 45 分钟 | timeout=45min | E-SRC: PosPrnQueueServicePlus.overTaskTime |
| RR-03 | 重打时重新创建打印任务，重新走完整流程 | — | E-SRC: PrintTaskMonitor 重打功能 |
| RR-04 | 线下模式启动时扫描未打印 `.job` 文件并重试 | — | E-SRC: PrinterWorkerServiceLocalImpl.init() |
| RR-05 | 打印机状态正常后自动参与下次分发 | — | E-SRC: PrinterWorkerService.addPrinterStatus |

## 三、异常与恢复矩阵

| 失败场景 | 检测方式 | 自动恢复 | 人工介入 | 升级路径 |
|---------|---------|---------|---------|---------|
| 打印机离线 | PrinterStatus.FAULT | 自动切换到备打印机 | 检查打印机连接 | 持续故障通知 |
| 打印机全部故障 | 分发日志"无可用打印机" | 延迟2秒重试(45分钟) | 修复打印机或重打 | 超时后放弃 |
| 队列未配置打印机 | 分发日志"未设置打印机" | 无 | 配置队列打印机 | — |
| 打印任务创建失败 | 事务回滚 | 自动回滚 | 查看日志定位原因 | — |
| 打印内容错误 | 用户反馈 | 无 | 调整样式配置 | 开发排查 |
| 样式不存在 | 初始化日志"模板不存在" | 无 | 配置打印样式 | — |
| 云打印机通信失败 | 回调超时 | 自动重试 | 检查云平台状态 | — |
| `.job` 文件损坏 | 反序列化失败 | 日志记录 | 从数据库恢复 | — |
