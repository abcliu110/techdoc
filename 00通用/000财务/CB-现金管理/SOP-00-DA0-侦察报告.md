# DA0 侦察报告 — K3Cloud CB现金管理

## 版本信息
| 属性 | 值 |
|---|---|
| 侦察范围 | FIN.CB.App.Report + FIN.ServiceHelper (CN模块) |
| 版本基线 | K3Cloud财务系统 v1.0 |
| 侦察时间 | 2026-08-06 |

## 一、入口痕迹清单

### 1.1 报表入口
| 报表 | 文件 | 取数逻辑 | 证据 |
|---|---|---|---|
| 现金日记账 | CashJournal | 现金账户+收付款流水 | E-DOC-001 §5.1 |
| 银行日记账 | BankJournal | 银行账户 | E-DOC-001 §5.1 |
| 现金流水账 | CashDetailReport | 逐笔收付流水 | E-DOC-001 §5.1 |
| 银行流水账 | BankDetailReport | 逐笔收付流水 | E-DOC-001 §5.1 |
| 现金日报 | CashDailyReport | 日汇总INSERT临时表 | E-DOC-001 §5.1 |
| 银行日报 | BankDailyReport | 日汇总INSERT临时表 | E-DOC-001 §5.1 |
| 期末对账 | FinalReconReport | 账面vs银行对账单 | E-DOC-001 §5.2 |
| 余额调节表 | BalAdjustmentReport | 未达账项计算 | E-DOC-001 §5.2 |
| 资金头寸表 | FundPositionReport | 未来收支预测 | E-DOC-001 §5.2 |

### 1.2 服务层入口
| 服务 | 职责 | 证据 |
|---|---|---|
| CNOpenServiceHelper | 期初余额查询 | E-DOC-001 §5.5 |
| WBOpenServiceHelper | 银企互联 | E-DOC-001 §5.4 |
| GlVoucherForCNServiceHelper | 出纳凭证关联 | E-DOC-001 §6.1 |
| RecordBillVchInfoServiceHelper | 凭证信息回写 | E-DOC-001 §6.1 |

### 1.3 数据痕迹
| 表名 | 核心字段 | 用途 | 证据 |
|---|---|---|---|
| CB_CASHACCOUNT | 现金账户 | 现金日记账取数 | E-DOC-001 §5.1 |
| CB_BANKACCOUNT | 银行账户 | 银行日记账取数 | E-DOC-001 §5.1 |
| CB_RECEIVEFLOW | 收款流水 | 收付款流水 | E-DOC-001 §5.1 |
| CB_PAYFLOW | 付款流水 | 收付款流水 | E-DOC-001 §5.1 |
| CB_RECONCILIATION | 对账记录 | 银行对账 | E-DOC-001 §5.2 |
| CB_BALANCEADJUSTMENT | 余额调节 | 未达账项 | E-DOC-001 §5.2 |

## 二、候选事实清单

| 候选事实 | 痕迹位置 | 推断链 | 置信度 | 验证状态 |
|---|---|---|---|---|
| CF-01: CB模块与CN模块共享源码 | E-DOC-001 §5 | CN.App.Report包含现金银行功能 | 直接事实 | 已验证 |
| CF-02: 日记账按账户类型分类 | E-DOC-001 §5.1 | CashJournal/BankJournal分离 | 直接事实 | 已验证 |
| CF-03: 日报使用临时表汇总 | E-DOC-001 §5.1 | DailyDataHelper INSERT临时表 | 直接事实 | 已验证 |
| CF-04: 银行对账计算未达账项 | E-DOC-001 §5.2 | CalculateAdjustAmount | 直接事实 | 已验证 |
| CF-05: 资金头寸预测未来收支 | E-DOC-001 §5.2 | FundPositionReport INSERT临时表 | 直接事实 | 已验证 |
| CF-06: 银企互联支持网银付款 | E-DOC-001 §5.4 | WBOpenServiceHelper | 直接事实 | 已验证 |
| CF-07: 期初余额集中查询 | E-DOC-001 §5.5 | CNOpenServiceHelper | 直接事实 | 已验证 |
| CF-08: 出纳凭证与GL关联 | E-DOC-001 §6.1 | GlVoucherForCNServiceHelper | 直接事实 | 已验证 |
| CF-09: 银行余额调节三列差异 | E-DOC-001 §5.2 | FCNAMOUNT/FGLAMOUNT/FBALAMOUNT | 直接事实 | 已验证 |
| CF-10: 银企互联支持余额查询和流水下载 | E-DOC-001 §5.4 | QueryBalanceForBankAcct, DownLoadCashFlow | 直接事实 | 已验证 |

## 三、未知项（U-*）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-CB-01 | CB_CASHACCOUNT/CB_BANKACCOUNT具体表结构 | 字段定义不完整 |
| U-CB-02 | 收付款单据与CB流水的关联字段 | 核销关系不明 |
| U-CB-03 | 银行对账单导入机制 | 数据来源不清 |
| U-CB-04 | 资金头寸预测的时间范围 | 预测周期不明 |
| U-CB-05 | 银企互联支持的银行列表 | 兼容性不明 |

## 四、当前停止条件

- 继续侦察的预期信息增益：中（文档分析充分，源码细节待补充）
- 下一轮最小取证动作：获取CB模块源码文件，补充表结构和API细节
