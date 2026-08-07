# Stock库存 — SOP-00-DA7-实现映射

## 版本信息
| 属性 | 值 |
|---|---|
| 模块 | K3Cloud SCM - Stock库存 |
| 分析时间 | 2026-08-07 |
| 文档目录 | D:\mywork\techdoc\00通用\000供应链\Stock库存\ |
| 前置文档 | SOP-00-DA0-DA6 |
| 状态 | DA7进行中 |

---

## 一、实现映射概述

Stock库存模块的实现映射将业务层（BO/REL/API）与代码层关联，识别10个报表类、4个核心服务类、6个DEC决策点。

---

## 二、报表类映射（10个）

### REP-01：库存台账（InventoryLedgerReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC库存台账查询 |
| 数据来源 | T_STK_INVENTORY |
| 核心字段 | 组织/仓库/物料/批号/现存量/锁定量/可用量 |
| 代码类 | InventoryReportBLL.GetInventoryLedger |
| 索引 | IDX_STK_INV_ORG_STOCK_MAT |

### REP-02：库存明细账（InventoryDetailReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC库存流水查询 |
| 数据来源 | T_STK_STOCKTRANS |
| 核心字段 | 单据号/日期/物料/数量/变动前/变动后 |
| 代码类 | StockTransReportBLL.GetDetailJournal |
| 账类同构 | GL日记账 / CB银行日记账 |

### REP-03：批次台账（BatchLedgerReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC批次追溯 |
| 数据来源 | T_STK_INVENTORY + T_BD_BATCH |
| 核心字段 | 批号/生产日期/有效期/数量/状态 |
| 代码类 | BatchReportBLL.GetBatchLedger |
| 索引 | IDX_STK_INV_BATCH |

### REP-04：有效期预警（ExpiryAlertReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC效期预警 |
| 数据来源 | T_STK_INVENTORY.FEXPIRYDATE |
| 核心逻辑 | 当前日期 > 有效期 或 剩余天数 < 预警阈值 |
| 代码类 | ExpiryAlertBLL.GetExpiryAlerts |

### REP-05：可用量分析（AvailQtyAnalysisReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC可用量分析 |
| 数据来源 | T_STK_INVENTORY（AvailQty = StockQty - LockQty - ReserveQty） |
| 核心逻辑 | 五量关系实时计算 |
| 代码类 | InventoryQueryBLL.QueryAvailQty |
| ⚠️ 风险 | U-02：五量是否在同一事务计算待验证 |

### REP-06：锁定期明细（StockLockDetailReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC锁定追溯 |
| 数据来源 | T_STK_STOCKLOCK |
| 核心字段 | 订单号/物料/批号/锁定量/状态/剩余时间 |
| 代码类 | StockLockBLL.QueryLock |
| 索引 | IDX_STK_LOCK_SOURCE |
| ⚠️ 风险 | 反证#2：订单关闭后FLOCKSTATUS未更新 |

### REP-07：负库存日志（NegativeStockLogReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC负库存追溯 |
| 数据来源 | StockCheckNegative日志 |
| 触发场景 | BR-ST-101被绕过 |
| 代码类 | StockCheckNegative.GetLog |
| ⚠️ 风险 | 反证#1：批次过期导致表面负库存 |

### REP-08：盘点差异报告（StockCheckDiffReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC账实核对 |
| 数据来源 | T_STK_STOCKCHECK + T_STK_STOCKADJUST |
| 核心字段 | 物料/账面数/实盘数/差异量/差异原因 |
| 代码类 | StockCheckReportBLL.GetDiffReport |
| ⚠️ 风险 | 反证#3：差异未追溯原账目变更 |

### REP-09：期末库存快照（PeriodEndSnapshotReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC期末关账 |
| 数据来源 | T_STK_INVENTORY（期末快照） |
| 核心字段 | 期间/组织/物料/期末数量 |
| 代码类 | StockPeriodCloseBLL.GetSnapshot |

### REP-10：库存账龄分析（StockAgingReport）
| 属性 | 内容 |
|---|---|
| 业务视图 | DA1-UC呆滞物料分析 |
| 数据来源 | T_STK_STOCKTRANS + T_STK_INVENTORY |
| 核心逻辑 | 按在库时长分组（0-30/31-60/61-90/>90天） |
| 代码类 | StockAgingBLL.GetAgingAnalysis |

---

## 三、服务类实现映射（4个）

### SVC-01：OperationController（过账引擎核心）

| 属性 | 内容 |
|---|---|
| 源码位置 | Kingdee.K3.SCM.Stock.App.Core.OperationController |
| 职责 | 库存过账的统一入口，策略模式协调 |
| 关键方法 | InstockPosting/OutstockPosting/AdjustPosting/TransferPosting/Merge |
| 策略子类 | 7个（对应7种单据类型） |
| 原子操作 | MERGE库存行（15维定位 + 五量更新） |
| GL联动 | 过账完成后调用GLVoucherService.GenerateVoucher |
| 异常处理 | BR-ST-101负库存校验、BR-ST-201可用量校验 |
| ⚠️ 关键未知 | U-01：MERGE与GL事务的差异 |

### SVC-02：InventoryBLL（库存台账）

| 属性 | 内容 |
|---|---|
| 源码位置 | Kingdee.K3.SCM.Stock.App.Core.InventoryBLL |
| 职责 | 库存行的读写、MERGE操作 |
| 关键方法 | Query/Merge/CheckNegative/CheckAvailQty |
| 核心逻辑 | 15维唯一定位 + 五量原子更新 |
| 约束校验 | BR-ST-101（现存量>=0）、BR-ST-201（AvailQty>=出库量） |

### SVC-03：StockLockBLL（锁定管理）

| 属性 | 内容 |
|---|---|
| 源码位置 | Kingdee.K3.SCM.Stock.App.Core.StockLockBLL |
| 职责 | SO/MO锁定的创建和释放 |
| 关键方法 | CreateLock/ReleaseLock/QueryLock/AutoReleaseOnClose |
| 触发时机 | CreateLock → SO/MO审核；ReleaseLock → 出库审核或订单关闭 |
| ⚠️ 风险 | AutoReleaseOnClose可能未执行（反证#2） |

### SVC-04：StockPeriodCloseBLL（期末关账）

| 属性 | 内容 |
|---|---|
| 源码位置 | Kingdee.K3.SCM.Stock.App.Core.StockPeriodCloseBLL |
| 职责 | 库存期末关账和反关账 |
| 关键方法 | ClosePeriod/ReverseClose/CheckPendingDocuments |
| 前置检查 | 未审核单据检查、负库存检查 |
| 后置动作 | 触发GL期末关账协同 |

---

## 四、DEC决策卡（6个）

### DEC-ST-01：五量模型是否在同一原子事务中更新？
| 属性 | 内容 |
|---|---|
| 决策问题 | 现存量/锁定量/可用量的变更是否在同一事务中完成？ |
| 选项A | 全在同一事务（强一致性） |
| 选项B | 分开事务（性能优化，但可能不一致） |
| **实际选择** | **待验证（U-02）** |
| 影响 | 可用量计算准确性、BR-ST-201校验可靠性 |

### DEC-ST-02：批次效期校验时机
| 属性 | 内容 |
|---|---|
| 决策问题 | 批次过期校验在何时触发？ |
| 选项A | 保存时强控（不允许保存过期批次） |
| 选项B | 审核时校验（允许保存但拒绝审核） |
| 选项C | 出库分配时（FEFO分配阶段） |
| **实际选择** | **B（审核时校验）** |
| 影响 | BR-ST-102执行时机 |

### DEC-ST-03：过账引擎MERGE策略
| 属性 | 内容 |
|---|---|
| 决策问题 | 多维度库存行的MERGE策略如何选择？ |
| 选项A | 按精确15维匹配（严格唯一） |
| 选项B | 按近似维度聚合（模糊匹配） |
| **实际选择** | **A（精确15维）** |
| 影响 | 库存粒度、查询性能 |

### DEC-ST-04：锁定释放触发时机
| 属性 | 内容 |
|---|---|
| 决策问题 | 锁定期何时释放？ |
| 选项A | 出库单审核时自动释放（按关联出库量） |
| 选项B | 订单关闭时自动释放（全部释放） |
| 选项C | 手动释放（人工决策） |
| **实际选择** | **A+B组合** |
| ⚠️ 风险 | 订单关闭事件未触发B路径（反证#2） |

### DEC-ST-05：盘点调整溯源策略
| 属性 | 内容 |
|---|---|
| 决策问题 | 盘点调整是否需要追溯原账目变更？ |
| 选项A | 生成完整溯源链（原单据→调整单→日记账） |
| 选项B | 仅记录调整，不追溯（简化实现） |
| **实际选择** | **B（部分实现）** |
| ⚠️ 风险 | 反证#3：账目历史不完整 |

### DEC-ST-06：GL凭证联动时机
| 属性 | 内容 |
|---|---|
| 决策问题 | 库存单据审核后，GL凭证何时生成？ |
| 选项A | 同步生成（同一事务中） |
| 选项B | 异步生成（后台队列） |
| 选项C | 批量生成（期末汇总） |
| **实际选择** | **A（同步生成）** |
| 账类同构 | 与CB收款单→GL凭证（BR-CB-205）同构 |

---

## 五、实现映射与源码规模

| 维度 | Stock库存 | GL总账 | CB现金管理 |
|---|---|---|---|
| 源码文件数 | 541个 | ~200个 | ~100个 |
| 代码行数 | 146,748行 | ~10万行 | ~5万行 |
| 报表类 | 10个 | 8个 | 10个 |
| 服务类 | 4个核心 | 5个核心 | 4个核心 |
| API数量 | 12个 | 15个 | 12个 |

**Stock是K3Cloud最大子域**：代码量超过GL+CB+AR+AP之和

---

## 六、DA7覆盖清单

- [x] 10个报表类映射（库存台账/明细账/批次/效期/可用量/锁定/负库存/盘点/快照/账龄）
- [x] 4个核心服务类（OperationController/InventoryBLL/StockLockBLL/PeriodCloseBLL）
- [x] 6个DEC决策卡（含3个反证风险关联）
- [x] 源码规模对比
- [ ] DA8收敛分析（10CF收敛/5U收敛/9R风险）
