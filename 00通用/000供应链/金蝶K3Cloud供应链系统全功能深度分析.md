# 金蝶 K3Cloud 供应链(SCM)系统 · 全功能深度分析

> **文档类型**：源码逆向·功能实证层（对齐《财务系统全功能深度分析》）
> **分析对象**：`Business/SCM/`（1,709 个 C# 文件，约 42.6 万行）＋相关 BOS 平台
> **配套**：抽象层《库存系统高维抽象理论.md》、业务机制层《供应链业务机制速览卡-反证后结论.md》（同目录）
> **版本**：v1.0 | 2026-08

---

## 目录

1. [模块全景与分层](#1-模块全景与分层)
2. [源码边界](#2-源码边界)
3. [业务流转图谱](#3-业务流转图谱)
4. [核心机制：过账引擎与库存账](#4-核心机制过账引擎与库存账)
5. [预留/锁库与可用量](#5-预留锁库与可用量)
6. [批次/序列号/仓储实体](#6-批次序列号仓储实体)
7. [核心服务与报表模式](#7-核心服务与报表模式)
8. [跨域集成](#8-跨域集成)
9. [风险与质量](#9-风险与质量)

---

## 1. 模块全景与分层

供应链(SCM)是这套源码里**最大的业务域**（42.6 万行，约占全库 1/4），工程按"职责分层、非按子域切项目"组织：

```
Business/SCM/
├─ Core/Kingdee.K3.SCM.App.Core          ← 服务契约实现层(50+服务),真正的业务运算
├─ BusinessPlugIn/<Sub>.Business.PlugIn  ← 各单据 Edit/List 界面插件
├─ ServicePlugIn/<Sub>.ServicePlugIn     ← 操作服务插件(保存/审核)+下推转换插件
├─ ReportPlugIn/<Sub>.Report.PlugIn      ← 报表插件
├─ App/<Sub>.ServicePlugIn               ← 应用服务插件(与 ServicePlugIn 大量重复)
└─ CP/                                    ← 电商商城核心(BBC)
```

### 1.1 子域规模（按业务子域）

| 子域 | 文件 | 行数 | 定位 |
|---|---|---|---|
| **Stock 库存** | 541 | 146,748 | 最核心：出入库/调拨/盘点/批次/序列号/即时库存 |
| **Sal 销售** | 472 | 114,436 | 报价→订单→发货→出库/退库全链 |
| **CP 电商商城(BBC)** | 378 | 73,666 | BBC订单/广告/客户平台/移动端（**不是**委外加工） |
| **Purchase 采购** | 159 | 58,863 | 价格/询比价评估/配额/采购订单 |
| **Credit 信用管理** | 110 | 14,649 | 信用模型/等级/指标/评分/占用 |
| **DRP 分销计划** | 66 | 11,430 | 需求计划/分配/下达 |
| **OP 商机(CRM)** | 24 | 7,168 | 商机→销售订单 |
| **RPM 补货 / SVM 供应商协同 / SPM 供应商门户** | 25/23/15 | 4.1k/3.0k/2.9k | 补货计划 / 采购申请→询→报→比价 / 主档协同 |

---

## 2. 源码边界

- ✅ **业务逻辑大部分可读**：编辑插件、下推链、库存过账、报表取数、服务门面均在源码内。
- ⚠️ **缺失**：①核心 ORM(`Kingdee.BOS.Orm`,含 `DynamicObject`)来自外部 DLL；②单据**元数据 XML/ConvertRule 配置**在数据库——所以"采购申请→订单→收料→入库"这条链**看不到转换代码**(标准流走配置)；③部分账务引擎(批次拣货 `AutoUnLock` 落点为空方法 `StockLockService.cs:1839`)。

---

## 3. 业务流转图谱

### 3.1 销售链 —— 代码化最完整（21 个下推转换插件，均在 `App.Sal.ServicePlugIn`）
```
CRM商机(OP)──CrmContractToSaleOrder──▶销售报价──SaleQuotationToSaleOrder──▶销售订单
  SaleOrderPur ◀────────────────────────────┐
  销售订单──SaleOrderToDeliverNotice──▶发货通知──DeliveryNoticeToSalOutStock──▶销售出库
  销售订单──SaleOrderToOutStock──────▶销售出库(可出量过滤+汇率/组织回填)
  销售出库──OutStockToSalReturnStock──▶销售退货 ──SaleOrderToSalReturnNotice──▶退货通知
```
- 典型过滤：`SaleOrderToOutStock.OnParseFilter`（`FBaseCanOutQty>0` 或发货需检验物料走检验路线）。
- 典型回填：`OnAfterFieldMapping` 多组织(货主/保管)与汇率(本币=结算币→汇率1)。

### 3.2 采购链 —— 代码化极少，配置驱动
- 唯一源码转换在 **SVM**：`PurReqToInquiryBill`(申请→询价)、`InquiryToQuoteBill`(询价→报价)、`InquiryBillToComparePrice`(报价→比价)。
- 申请→订单→收料→入库→发票 **零转换插件代码**——靠元数据 `ConvertRule`（采购链标准线性，故走配置而非代码）。

### 3.3 库存链 —— 账务级核心算法全在服务层
`StockInvService`(即时库存) / `LotService`(批次) / `SerialService`(序列号) / `StockLockService`(锁定) / `StockCloseService`(期末关账) / `StockCheck/Count/CycleCountService`(盘点)。

### 3.4 信用/分销/电商
- 信用：`CreditModelSave`→`CreditGrade`→`CreditIndex`→评分表→占用(Audit/ChangeReserveRelation)；客户档案变更联动 `CustArcToChangeService`。
- DRP：分销分配/下达；CP：BBC 订单+广告+移动端。

---

## 4. 核心机制：过账引擎与库存账（本模块最值钱的部分）

### 4.1 过账引擎（`Core/...AppBusinessService.UpdateStock/`）
- **按单据操作分策略**：`OperationController`(抽象)+`Save/Audit/Cancel/UnAudit/UnCancel/Delete/UnSupport` 七个子类。
- 抽象三参数：**过账点**(元数据配置，保存=1/审核=2)、**数量乘数**(入库+1/出库-1/对冲0)、**操作集合**。
- 过账三步（`UpdateStockByTmpSqlBuilder`）：分录→差异临时表(`T_STK_INVMINUSCHECK`)→一条 `MERGE INTO T_STK_INVENTORY` 原子合并(匹配置+增量/不匹配插入)+写流水(`T_STK_INVENTORYLOG`)。
- 并发安全：过账前锁行(`T_STK_INVUPLOCKIDTABLE`)、预占维度(`T_STK_PREINVDIMENSION`)。

### 4.2 库存行 = 15 维 + 三单位 + 多量（`T_STK_INVENTORY`）
- 15 维：组织/货主/保管者/仓库/仓位/物料/辅助属性/BOM/委托加工单/项目/状态/批次/生产日/效期 + `FCOMBINEID` 组合键。
- 三单位：`FBASE/FSEC/FQTY`(基本/辅助/库存)。
- 多量：`FBASELOCKQTY`(锁定,实时聚合自预留明细)、`FBASEAVBQTY`(可用=现存−锁定)、`FBASEAWAITQTY`(在途)。

### 4.3 表族（`T_STK_*` 分工）
```
T_STK_INVENTORY(即时)  ← MERGE ← T_STK_INVMINUSCHECK(差异表) ← 单据分录
T_STK_INVENTORYLOG(流水,可重算)      T_STK_INVBAL(账存,期间收付存)
T_PLN_RESERVELINK(ENTRY)(预留/占用)  T_STK_LOCKSTOCKLOG(锁库)
T_STK_STKCOUNTINPUT/GAIN/LOSS(盘点)  T_STK_CLOSEPROFILE(关账)
T_BD_MATERIALSTOCK/STOCK/LOTMASTER/UNIT(主数据)
```

### 4.4 期末关账流水线（`StockCloseService.InvAccountOff`）
清批次→记轨迹→校验(开账日期/期初状态/上期已关/期间单据/未审盘点)→`DoInvCloseOperate`→删轨迹；关账写账存(`T_STK_INVBAL` 期初/收/发/存)，即时库存与账存由关账动作对齐。

### 4.5 负库存校验（六条，`CheckInvMinusService`）
现存<锁定 / 基本-辅助一正一负 / 一零一非零 / 方向相反 / 扣锁后相反 / FALLOWMINUSQTY 允许。**"允许负"≠"允许任意负"**（锁量冲突/一正一负即使允许也硬拦）。

---

## 5. 预留/锁库与可用量

- **可用量 = 现存量 − 锁定量（实时聚合自 `T_PLN_RESERVELINKENTRY`），非独立计数器**——承诺变更即自动一致。
- 预留明细带 `FRESERVEDATE/DAYS/FRELEASEDATE`(生命周期)、`FRESERVETYPE`(3=强预留)、到期自动解锁(`UnLockStockByDateBGService`)。
- 手工锁库走 `T_STK_LOCKSTOCKLOG`，支持到期自动解。
- **自身订单出库可用量=现存+自身锁库**(占用不阻塞自身发货，只架空他人)。

---

## 6. 批次/序列号/仓储实体

- 批次：`LotService`(按编码规则生成批次主档 `GenerateLotMasterByCodeRule`、效期查询 `GetLotExpiryInfo`)；效期并入批次(`FISEXPPARTOFLOT`)时从 `T_BD_LOTMASTER` 取生产/失效日期。
- 序列号：`SerialService`(`CheckSnNumberExixts` 防重、`GetSerialTraceInfo` 追溯、批量导入解析)。
- 物料库存属性(`T_BD_MATERIALSTOCK`)：批次/序列号管理开关、负库存允许、效期并入批次、仓存单位。

---

## 7. 核心服务与报表模式

### 7.1 服务清单（`Core/App.Core`，50+）
- `SaleService`(历史价/可售/物流/销售控制)、`PurchaseService`(价格表/比价/配额)、`CommonService`(下推规则/客户物料对照/系统参数)、`StockCloseService`(关账)、`StockBillDataService`(单据数据备份还原)、`BillLotPicker`(批次拣货,3054行)。
- 对外用契约接口：`ServiceHelper.GetService<ISaleService>()` 等方式。

### 7.2 报表模式（`AbstractSysReportPlugIn`）
- 报表=取数插件+过滤插件；权限控制如 `StockDetailRpt.AfterBindData→IsCanViewAmount(...)` 无金额权则 `FormatCellValue` 隐藏列。

---

## 8. 跨域集成

- **SCM→FIN**：`SCMServiceForFIN` 以契约暴露（库存关账 `InvAccountOnOff`、期初 `InvInitOpenClose`、余额 `GetDateInvBalByOwner`、内部结算 `CreateSettle/CreateIOSInnerBill`、信用额度回写）——供应链与财务解耦于"凭证翻译器+结账日服务"两个契约。
- **SCM→MFG**：`SCMServiceForMFG`（物料/库存供给制造使用）。
- **电商/移动**：CP、MobileService(销售移动应用)。

---

## 9. 风险与质量

| 风险 | 证据 | 影响 |
|---|---|---|
| SQL 字符串拼接过滤 | `InStockEdit.cs:1232` 拼 ID 进 `T_BD_OPERATOR...` | 绕过平台多组织/权限，注入面 |
| 自建事务裸写 MERGE | `WriteBackCommon.cs:147` `KDTransactionScope`+`DBUtils.ExecuteBatch` | 与单据事务不同步 |
| 吞异常 | `PurchaseRequisitionEdit.cs:140` 空 `catch{}` | 失败静默 |
| 巨型类 | `SaleOrderEdit`5,095 / `PurchaseService`4,722 / `CommonService`3,082 行 | 维护成本高 |
| 整目录双份 | 销售转换插件 `App/` 与 `ServicePlugIn/` 各一份(48 含重复,唯一 27) | 改 A 忘 B 行为不一致 |
| 采购链黑盒 | 申请→订单→收料→入库无代码(配置驱动) | 无法从源码学习该链 |

---

## 配套

- 抽象理论：`../000供应链/库存系统高维抽象理论.md`
- 业务机制(含 9 条反证结论)：`../000供应链/供应链业务机制速览卡-反证后结论.md`
- 统一理论：`../账类系统统一理论——钱数配额通用模型.md`(§12 库存层)
- 方法工具：`../000财务/00-对抗性验证方法/13-方法卡-账类业务机制的对抗性验证.md`
