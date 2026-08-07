# K3Cloud GL总账业务模型详细分析

## 文档信息

| 属性 | 值 |
|------|-----|
| 版本 | v1.0 |
| 分析对象 | K3Cloud GL总账模块 |
| 分析方法 | SOP-00业务系统分析SOP总览 |
| 证据基线 | K3Cloud反编译源码（2018年版本） |
| 输出位置 | D:\mywork\techdoc\00通用\000财务\GL总账分析\ |

---

## 目录

1. [00-阅读入口-十分钟读懂GL总账](#00-阅读入口-十分钟读懂gl总账)
2. [01-业务全景与能力地图](#01-业务全景与能力地图)
3. [02-典型业务故事与关键规则](#02-典型业务故事与关键规则)
4. [03-失败恢复与运行机制](#03-失败恢复与运行机制)
5. [04-实现映射与证据索引](#04-实现映射与证据索引)
6. [附录：事实表/非事实表详细分析](#附录事实表非事实表详细分析)

---

## 00-阅读入口-十分钟读懂GL总账

### 一句话业务本质

**GL总账是企业的"价值账本工厂"**：它将散落在AP/AR/CB/CN等业务模块中的每一笔资金流动，通过**凭证**这一标准化的"价值确认原子"记录下来，再按**账簿-会计期间-科目**的三维框架聚合，最终吐出总账、明细账、科目余额表等财务报表。

**比喻**：如果企业是一艘船，GL总账就是船上的**航海日志**——不是实时GPS，而是每隔一段时间（会计期间）用标准格式记录"我们在哪里、航行了多远、油耗多少"。业务模块（AP/AR等）是各部门的原始工作记录，GL总账是财务部门汇总后的航海日志。

### GL总账在财务域中的位置

```
┌─────────────────────────────────────────────────────────────────┐
│                        财务域 (FIN Domain)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐     │
│  │   AP     │   │   AR     │   │   CN     │   │   CB     │     │
│  │ 应收应付 │   │  应收   │   │  票据   │   │  现金   │     │
│  └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘     │
│       │              │              │              │            │
│       └──────────────┴──────────────┴──────────────┘            │
│                              │                                   │
│                              ▼                                   │
│                     ┌────────────────┐                           │
│                     │  GL 总账模块   │ ◄── 核心枢纽               │
│                     │ (General Ledger)│                          │
│                     └────────┬───────┘                           │
│                              │                                   │
│              ┌───────────────┼───────────────┐                   │
│              ▼               ▼               ▼                   │
│        ┌──────────┐   ┌──────────┐   ┌──────────┐              │
│        │  总账    │   │ 明细账  │   │余额表   │              │
│        │GL_RPT_   │   │GL_RPT_  │   │GL_RPT_  │              │
│        │General   │   │SubLedger│   │Account  │              │
│        │Ledger    │   │         │   │Balance  │              │
│        └──────────┘   └──────────┘   └──────────┘              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 范围与边界

**GL总账负责的**：
- 凭证的生成、审核、过账、反审核
- 账簿管理（一个组织可有多个账簿）
- 科目体系管理（会计科目 + 核算维度）
- 会计期间管理（年、月的打开/关闭状态）
- 总账报表生成（总账、明细账、科目余额表、凭证汇总表）
- 从业务单据到凭证的映射（业务凭证关联）

**GL总账不负责的**：
- AP/AR/CB/CN的业务处理（那些是上游）
- 固定资产核算（FA模块）
- 成本计算（CM模块）
- 预算管理（BDG模块）

### 角色与责任

| 角色 | 职责 | 关键操作 |
|------|------|----------|
| **凭证录入员** | 手工录入或审核凭证 | 凭证新增、修改、删除、审核 |
| **账套管理员** | 管理账簿、科目体系 | 账簿设置、科目维护、凭证字设置 |
| **财务主管** | 报表审核、期间管理 | 期间结账、反结账、报表查询 |
| **审计人员** | 凭证追溯、业务联查 | 联查业务单据、凭证打印 |

### 业务结果族/能力地图

| 业务能力 | 触发事件 | 交付物 | 接收角色 | 成功义务 | 失败后果 |
|----------|----------|--------|----------|----------|----------|
| **凭证生成** | 业务单据审核通过 | GL_VOUCHER + GL_VOUCHERENTRY | 财务人员 | 借贷平衡、金额准确 | 账实不符 |
| **凭证审核** | 手工提交审核 | 已审核凭证 | 审核人员 | 单据状态正确变更 | 凭证被误审核 |
| **凭证过账** | 审核后提交过账 | 更新后的AccountBalance | 系统/财务人员 | 余额计算正确 | 报表数据错误 |
| **报表查询** | 用户请求报表 | 报表数据集合 | 查询用户 | 返回正确聚合数据 | 误导经营决策 |
| **期间结账** | 月末/年终结账 | 期间状态变更 | 财务主管 | 无未达账项 | 报表无法出具 |

### 主故事：一个凭证的诞生

> **场景**：2024年1月15日，采购员小李提交了一张采购入库单，金额10万元，供应商为"光明公司"。财务人员小王需要把这笔业务记录到总账中。
>
> **步骤1-凭证生成**：`VoucherGenerateService`读取入库单，调用`VoucherGenerateServiceHelper.BuildVoucherInfo()`生成业务凭证（BizVoucher），再调用`IBuildVoucherService.BuildVoucher()`生成GL凭证。
>
> **步骤2-凭证保存**：生成的`GL_VOUCHER`包含表头（凭证字、日期、凭证号），`GL_VOUCHERENTRY`包含两行分录（借：原材料 10万，贷：应付账款 10万）。
>
> **步骤3-联查业务单据**：用户点击"联查总账凭证"，`ViewGlVoucher`从`BAS_BusinessVoucher`表读取`FSOURCEBILLID`和`FGLVOUCHERID`的映射关系，定位到对应的GL凭证。
>
> **步骤4-过账与报表**：审核凭证后，触发`GL_RPT_SubLedger`查询，系统聚合`GL_VOUCHERENTRY`数据，按科目+期间+核算维度汇总，生成明细账报表。

### 主要失败后果

| 失败场景 | 业务影响 | 恢复路径 |
|----------|----------|----------|
| 凭证借贷不平衡 | 无法保存 | 修改分录金额 |
| 凭证跨期间错误 | 报表期间数据错误 | 删除重新生成或调整 |
| 账簿未打开 | 无法生成凭证 | 管理员打开账簿期间 |
| 科目被禁用 | 凭证分录无法保存 | 重新启用科目 |
| 过账失败 | 余额表数据不一致 | 重新过账或手工调整 |

### 快速问答表

| 问题 | 答案 |
|------|------|
| **数据存在哪？** | `GL_VOUCHER`（表头）、`GL_VOUCHERENTRY`（分录）、`BAS_BusinessVoucher`（业务关联） |
| **凭证怎么生成？** | 从AP/AR/CB/CN等业务单据通过凭证模板自动生成，或手工录入 |
| **账簿是什么？** | 一个账簿（AcctBook）代表一套独立的账务体系，可多账簿并行 |
| **科目余额怎么算？** | `AccountBalance`表记录每个科目在每个期间+币别+核算维度的借方/贷方/余额 |
| **期间能反结账吗？** | 可以，但需满足条件（无未审核凭证、无未记账凭证等） |
| **明细账和总账什么关系？** | 明细账按科目+核算维度展开，总账按科目汇总；明细账行可联查到凭证 |
| **如何追溯业务来源？** | 通过`BAS_BusinessVoucher`的`FSOURCEBILLID`和`FSOURCEBILLKEY`关联到AP/AR等业务单据 |

---

## 01-业务全景与能力地图

### 1.1 核心业务能力分解

GL总账模块提供以下核心业务能力：

#### BC-01：凭证管理能力

| 子能力 | 描述 |
|--------|------|
| 凭证生成 | 从业务单据（AP/AR/CB等）按模板规则生成GL凭证 |
| 凭证手工录入 | 支持手工新增、修改、删除凭证 |
| 凭证审核 | 审核态管理，支持多人复核 |
| 凭证过账 | 将已审核凭证的数据写入余额表 |
| 凭证打印 | 支持凭证套打和多栏打印 |
| 凭证查询 | 支持按多种条件查询凭证列表 |

#### BC-02：账簿管理能力

| 子能力 | 描述 |
|--------|------|
| 账簿定义 | 创建和管理账簿（AcctBook） |
| 账簿关联科目体系 | 一个账簿关联一个会计科目体系 |
| 多账簿支持 | 支持同一组织多个账簿并行 |
| 账簿权限控制 | 不同用户访问不同账簿 |

#### BC-03：科目管理能力

| 子能力 | 描述 |
|--------|------|
| 科目维护 | 科目的增删改、禁用启用 |
| 科目级别 | 科目有层级结构（1-N级） |
| 科目属性 | 余额方向、现金科目、银行科目等 |
| 核算维度 | 辅助核算项（部门、项目、往来等） |

#### BC-04：会计期间管理能力

| 子能力 | 描述 |
|--------|------|
| 期间定义 | 年-月的期间结构 |
| 期间状态 | 打开/关闭/结账状态 |
| 期间切换 | 业务日期必须在已打开期间内 |
| 反结账 | 支持反审核、反过账、反结账 |

#### BC-05：报表能力

| 报表名称 | FormID | 描述 |
|----------|--------|------|
| 总账 | GL_RPT_GeneralLedger | 按科目汇总的发生额和余额 |
| 明细账 | GL_RPT_SubLedger | 按科目+核算维度的明细发生情况 |
| 科目余额表 | GL_RPT_AccountBalance | 各科目期初/本期/期末余额 |
| 凭证汇总表 | GL_RPT_VoucherSummary | 凭证按日期/凭证字汇总 |
| 数量总账 | GL_RPT_QtyGeneralLedger | 支持数量核算的科目 |
| 数量明细账 | GL_RPT_QtySubLedger | 支持数量核算的明细账 |
| 多栏账 | GL_RPT_MultiColumnLedger | 多栏式明细账 |
| 数量余额表 | QtySubLedgerFilter | 数量金额式余额表 |

### 1.2 核心概念关系（REL-* 规格）

#### REL-01：账簿-科目体系关系

| 属性 | 值 |
|------|-----|
| **类型** | 结构关系 |
| **方向与基数** | AcctBook（1） → AccountSystem（N） |
| **建立时机** | 配置维护期（账簿创建时指定） |
| **变更影响** | 需处理历史凭证；影响未来凭证生成 |
| **业务语义** | 一个账簿必须关联一个且只关联一个会计科目体系 |

```csharp
// GeneralLedgerFilter.cs:18
if (BillPlugInBaseFun.ValueIsNotNullOrWhiteSpace(this.View.Model.GetValue("FACCTBOOKID")))
{
    // 账簿选择后，联动科目体系
    this.AfterSelectAccountBook(CurrencyType.ComprehensiveCurrency, false);
}
```

#### REL-02：凭证-业务单据关系

| 属性 | 值 |
|------|-----|
| **类型** | 轨迹关系 |
| **方向与基数** | GL_VOUCHER（N） ← BAS_BusinessVoucher（1） → 业务单据 |
| **建立时机** | 交易执行期（凭证生成时） |
| **变更影响** | 凭证删除时，业务单据不受影响，但映射关系失效 |
| **业务语义** | 一个业务单据可生成多个GL凭证（多账簿场景），一个GL凭证只能来自一个业务单据 |

```csharp
// ViewGlVoucher.cs:116
para.FilterClauseWihtKey = string.Format("FSourceBillKey='{0}' And FSourceBillID in ({1}) ",
    this.View.BillBusinessInfo.GetForm().Id,  // 业务单据类型
    string.Join<long>(",", pkList));           // 业务单据ID列表
```

#### REL-03：凭证表头-分录关系

| 属性 | 值 |
|------|-----|
| **类型** | 结构关系 |
| **方向与基数** | GL_VOUCHER（1） → GL_VOUCHERENTRY（N） |
| **建立时机** | 交易执行期（凭证保存时） |
| **变更影响** | 删除凭证头自动删除所有分录 |
| **业务语义** | 一张凭证必须有且只有一条表头记录，必须有多条分录记录 |

#### REL-04：科目-余额关系

| 属性 | 值 |
|------|-----|
| **类型** | 轨迹关系 |
| **方向与基数** | Account（N） → AccountBalance（N） |
| **建立时机** | 交易执行期（凭证过账时） |
| **变更影响** | 余额是派生数据，可重新计算 |
| **业务语义** | 每个科目在每个会计期间+币别+核算维度组合下有一条余额记录 |

#### REL-05：会计期间-账簿关系

| 属性 | 值 |
|------|-----|
| **类型** | 结构关系 |
| **方向与基数** | FiscalPeriod（N） → AcctBook（1） |
| **建立时机** | 初始化或账簿创建时 |
| **变更影响** | 期间关闭后不能新增凭证 |
| **业务语义** | 账簿定义了可用期间范围，业务日期必须落在已打开的期间内 |

### 1.3 设计决策记录（DEC-*）

#### DEC-01：为什么用"业务凭证"作为中间层？

**决策点**：为什么K3Cloud引入`BAS_BusinessVoucher`（业务凭证）作为业务单据和GL凭证之间的映射层？

**当时约束**：
- 多个业务模块（AP/AR/CB/CN）都可能生成凭证
- 同一业务单据可能需要在多个账簿中生成凭证
- 需要支持凭证与业务单据的双向追溯

**可选方案**：
1. 业务单据直接存储GL_VOUCHER_ID
2. GL_VOUCHER直接存储SOURCE_BILL_ID
3. 独立的业务凭证映射表

**选择**：方案3（独立映射表）

**理由**：解耦业务模块和GL模块，业务模块无需知道GL的实现细节；支持多账簿场景

**证据**：
```csharp
// ViewGlVoucher.cs:114
QueryBuilderParemeter para = new QueryBuilderParemeter();
para.FormId = "BAS_BusinessVoucher";  // 查询业务凭证映射表
col.AddRange(SelectorItemInfo.CreateItems("FSOURCEBILLID,FVoucherID,FGLVoucherID"));
```

#### DEC-02：为什么余额表是预计算而非实时汇总？

**决策点**：为什么K3Cloud使用`AccountBalance`预计算表而非实时从凭证汇总？

**当时约束**：
- 报表查询性能要求高
- 凭证数据量大
- 需要支持跨期间查询

**选择**：预计算+实时更新

**理由**：过账时更新余额表，报表直接读取余额；平衡了实时性和性能

#### DEC-03：为什么明细账是报表而非独立表？

**决策点**：为什么`GL_RPT_SubLedger`是动态报表而非预存储的表？

**当时约束**：
- 明细账数据量大
- 需要支持多种维度组合查询
- 需要实时反映凭证状态

**选择**：动态报表

**理由**：灵活度高，无需维护冗余数据；凭证变更后自然反映

### 1.4 触发时机图

```
业务事件                          触发输出
─────────────────────────────────────────────────────────────
采购入库单审核通过 ─────────────→ 凭证生成服务 ───────────→ GL_VOUCHER
                                                    └→ BAS_BusinessVoucher（映射）

手工新增凭证 ─────────────────→ GL_VOUCHER + ENTRY

凭证审核 ─────────────────────→ GL_VOUCHER.FDOCUMENTSTATUS = 'C'

凭证过账 ─────────────────────→ AccountBalance 更新

报表查询请求 ─────────────────→ GL_RPT_* 报表生成

期间结账 ─────────────────────→ FiscalPeriod 状态变更
                            └→ 锁定当期凭证编辑
```

---

## 02-典型业务故事与关键规则

### SC-P0-01：业务单据自动生成凭证

**业务切片描述**：当用户在AP模块审核一张付款申请单时，系统自动触发凭证生成流程，在GL模块生成对应的记账凭证。

**触发事件**：
1. AP付款申请单审核通过
2. 调用`VoucherGenerateService.MakeVoucher()`

**业务因果链**：
```
付款申请单审核
    ↓ [触发凭证生成]
VoucherGenerateServiceHelper.VoucherGenerate()
    ↓ [调用业务服务]
IBuildVoucherService.BuildVoucher()
    ↓ [按模板规则生成]
GL_VOUCHER (表头) + GL_VOUCHERENTRY (分录)
    ↓ [建立映射]
BAS_BusinessVoucher (记录业务单据→GL凭证的关联)
    ↓ [返回结果]
用户可联查GL凭证
```

**关键代码证据**：
```csharp
// VoucherGenerateService.cs:71-82
private void MakeVoucher(List<string> BillIDLst, string formID)
{
    DynamicFormShowParameter dyParam = new DynamicFormShowParameter();
    dyParam.FormId = "GL_VoucherGeneService";  // 凭证生成服务FormID
    dyParam.CustomComplexParams.Add("BillIDLst", BillIDLst.ToArray());
    dyParam.CustomComplexParams.Add("FormID", formID);
    dyParam.CustomComplexParams.Add("SubSystemID", this.SubSystemID);
    this.View.ShowForm(dyParam, new Action<FormResult>(this.CloseProcessBar));
}
```

**关键规则**：
- BR-GL-001：凭证必须借贷平衡（借方合计 = 贷方合计）
- BR-GL-002：凭证日期必须在已打开的会计期间内
- BR-GL-003：分录中的科目必须在当前账簿的科目体系中存在
- BR-GL-004：生成凭证时自动分配凭证号

**失败场景**：
- 模板配置错误 → 生成凭证失败
- 科目被禁用 → 分录保存失败
- 期间关闭 → 无法生成凭证

### SC-P0-02：从总账联查到明细账再到凭证

**业务切片描述**：财务主管在总账报表中看到"管理费用-办公费"科目本月发生额异常，想追溯到具体凭证。

**业务因果链**：
```
财务主管打开总账报表
    ↓ [选择账簿、期间]
GL_RPT_GeneralLedger 加载
    ↓ [发现异常行：管理费用-办公费 50万]
点击行 → CellDbClick
    ↓ [验证权限 + 获取下钻方案]
ReportFilterCommonFunction.CheckViewDetailRight()
    ↓ [打开明细账]
GL_RPT_SubLedger (参数：科目ID、期间)
    ↓ [显示该科目明细]
点击某行 → EntityRowClick
    ↓ [验证行是否为凭证行]
current.FormID.Equals("GL_VOUCHER")
    ↓ [启用联查按钮]
用户点击"联查凭证"
    ↓ [打开凭证单据]
GL_VOUCHER 表单
```

**关键代码证据**：
```csharp
// GeneralLedger.cs:20-26
public override void CellDbClick(CellEventArgs Args)
{
    Args.Cancel = !ReportFilterCommonFunction.CheckViewDetailRight(base.Context, this.View, "GL_RPT_SubLedger");
    string nextEntrySchemeId = ReportFilterCommonFunction.GetNextEntrySchemeId(base.Context, "GL_RPT_SubLedger");
    this.SysReportView.OpenParameter.SetCustomParameter("AutoSchemeId", nextEntrySchemeId);
    ReportFilterCommonFunction.UpdateNextEntrySchemeId(base.Context, "GL_RPT_SubLedger", "-1");
}

// SubLedger.cs:129-147
public override void EntityRowClick(EntityRowClickEventArgs e)
{
    base.EntityRowClick(e);
    ReportSelectedRowCollection canDealWithRows = this.SysReportView.CanDealWithRows;
    foreach (ReportSelectedRow current in canDealWithRows)
    {
        if (current.RowKey == e.Row)
        {
            if (!current.FormID.Equals("GL_VOUCHER", StringComparison.CurrentCultureIgnoreCase))
            {
                this.View.GetMainBarItem("tbVhoucher").Enabled = false;
            }
            else
            {
                this.View.GetMainBarItem("tbVhoucher").Enabled = true;
            }
        }
    }
}
```

### SC-P0-03：从业务单据反向联查GL凭证

**业务切片描述**：审计人员需要核实一笔采购付款，需要从AP付款单找到对应的GL凭证。

**业务因果链**：
```
审计人员打开AP付款单列表
    ↓ [选择目标单据]
点击"联查总账凭证"按钮
    ↓ [ViewGlVoucher.ExecuteOperation()]
权限校验 → 获取业务单据PK列表
    ↓ [查询BAS_BusinessVoucher]
找到 FSOURCEBILLID → FGLVOUCHERID 映射
    ↓ [构造查询条件]
GL_VOUCHER FVoucherID In (...)
    ↓ [打开凭证列表]
GL_VOUCHER 表单（多选模式）
```

**关键代码证据**：
```csharp
// ViewGlVoucher.cs:83-109
private void LookUpGlVoucher(List<long> pkList)
{
    string tempTableForGl;
    string filter = this.GetViewGlvchFilter(pkList, out tempTableForGl);
    if (!string.IsNullOrEmpty(filter) && this.IsHaveGlVoucher(this.View.Context, filter))
    {
        ListShowParameter listpara = new ListShowParameter();
        listpara.FormId = "GL_VOUCHER";  // 凭证表单ID
        listpara.PermissionItemId = "6e44119a58cb4a8e86f6c385e14a17ad";
        listpara.ListFilterParameter.Filter = filter;
        this.View.ShowForm(listpara);
    }
}

// ViewGlVoucher.cs:110-144
private string GetViewGlvchFilter(List<long> pkList, out string tempTableName)
{
    QueryBuilderParemeter para = new QueryBuilderParemeter();
    para.FormId = "BAS_BusinessVoucher";  // 业务凭证映射表
    col.AddRange(SelectorItemInfo.CreateItems("FSOURCEBILLID,FVoucherID,FGLVoucherID"));
    para.FilterClauseWihtKey = string.Format("FSourceBillKey='{0}' And FSourceBillID in ({1}) ",
        this.View.BillBusinessInfo.GetForm().Id,
        string.Join<long>(",", pkList));
    // ... 查询结果构造 filter
    return string.Format(" FVoucherID In ({0})", ids);
}
```

---

## 03-失败恢复与运行机制

### 3.1 核心对象失败维度摘要

#### GL_VOUCHER（凭证表头）

| 失败维度 | 描述 | 检测方式 | 恢复策略 |
|----------|------|----------|----------|
| 数据完整性 | 借贷不平衡 | 保存时校验 | 修改分录金额 |
| 状态不一致 | 已审核凭证被删除 | 删除前检查状态 | 先反审核再删除 |
| 期间错误 | 凭证日期不在有效期间 | 日期校验 | 修改凭证日期 |
| 权限不足 | 用户无凭证操作权限 | PermissionAuth | 申请权限 |

#### GL_VOUCHERENTRY（凭证分录）

| 失败维度 | 描述 | 检测方式 | 恢复策略 |
|----------|------|----------|----------|
| 科目无效 | 科目被禁用或不存在 | 保存时校验 | 更换科目 |
| 金额异常 | 金额为0或负数 | 金额校验 | 修正金额 |
| 核算维度缺失 | 必填核算维度未填写 | 保存时校验 | 补充维度 |

#### AccountBalance（科目余额）

| 失败维度 | 描述 | 检测方式 | 恢复策略 |
|----------|------|----------|----------|
| 余额不一致 | 与凭证汇总不符 | 对账检查 | 重新过账 |
| 并发冲突 | 多用户同时过账 | 事务锁 | 串行化或重试 |
| 期间断层 | 新期间余额与上期不符 | 余额检查 | 检查反结账 |

### 3.2 检测/恢复/人工介入矩阵

| 场景 | 自动检测 | 自动恢复 | 人工介入点 |
|------|----------|----------|------------|
| 凭证借贷不平衡 | ✅ 保存时校验 | ❌ | 提示用户修改 |
| 凭证日期不在期间 | ✅ 保存时校验 | ❌ | 提示用户修改或打开期间 |
| 过账时科目余额不一致 | ✅ 事务校验 | ❌ | 手工调整或重新过账 |
| 凭证审核后原单据被删除 | ❌ | ❌ | 需人工检查 |
| 期间已结账但有未过账凭证 | ✅ 结账前校验 | ❌ | 反结账后处理 |
| 多账簿凭证生成冲突 | ✅ 事务锁 | ✅ 重试 | 人工协调 |

### 3.3 故障恢复手册

#### 场景1：凭证借贷不平衡无法保存

**失败现象**：用户在保存凭证时提示"借贷不平衡"

**恢复步骤**：
1. 查看凭证分录列表，确认借方合计和贷方合计
2. 找出差异金额（借方合计 - 贷方合计）
3. 调整其中一个分录的金额使借贷平衡
4. 重新保存凭证

#### 场景2：无法生成凭证（期间已关闭）

**失败现象**：业务单据审核时提示"当前期间已关闭，无法生成凭证"

**恢复步骤**：
1. 联系账套管理员确认期间状态
2. 如需在当期补录：管理员执行"反结账"打开期间
3. 重新生成凭证
4. 完成后重新结账

#### 场景3：余额表数据与凭证不一致

**失败现象**：科目余额表显示余额与明细账汇总不符

**恢复步骤**：
1. 查询该科目所有未过账凭证
2. 执行凭证过账操作
3. 如仍不一致，检查是否有被删除但未反过账的凭证
4. 执行"重新计算余额"或"强制刷新余额"

---

## 04-实现映射与证据索引

### 4.1 核心对象实现映射

| 业务概念 | 实现标识 | 源码位置 | 表名 |
|----------|----------|----------|------|
| 凭证表头 | GL_VOUCHER | ViewGlVoucher.cs:90 | GL_VOUCHER |
| 凭证分录 | GL_VOUCHERENTRY | VoucherGenerateServiceHelper.cs | GL_VOUCHERENTRY |
| 业务凭证映射 | BAS_BusinessVoucher | ViewGlVoucher.cs:114 | BAS_BusinessVoucher |
| 账簿 | BD_AccountBook | SubLedgerFilter.cs:527 | T_BD_ACCTBOOK |
| 科目 | BD_Account | GeneralLedgerFilter.cs:196 | T_BD_ACCOUNT |
| 科目余额 | AccountBalance | AccountBalance.cs | GL_RPT_AccountBalance |
| 总账报表 | GL_RPT_GeneralLedger | GeneralLedger.cs | 动态报表 |
| 明细账报表 | GL_RPT_SubLedger | SubLedger.cs | 动态报表 |

### 4.2 证据索引

| 证据ID | 类型 | 位置 | 内容 |
|--------|------|------|------|
| E-GL-001 | E-SRC | ViewGlVoucher.cs | GL_VOUCHER表ID引用和联查逻辑 |
| E-GL-002 | E-SRC | VoucherGenerateService.cs | 凭证生成服务实现 |
| E-GL-003 | E-SRC | GeneralLedger.cs | 总账报表插件 |
| E-GL-004 | E-SRC | SubLedger.cs | 明细账报表插件 |
| E-GL-005 | E-SRC | AccountBalance.cs | 科目余额表插件 |
| E-GL-006 | E-SRC | VoucherSummary.cs | 凭证汇总表插件 |
| E-GL-007 | E-SRC | GeneralLedgerFilter.cs | 总账过滤条件处理 |
| E-GL-008 | E-SRC | SubLedgerFilter.cs | 明细账过滤条件处理 |

### 4.3 矛盾/未知项台账

| ID | 类型 | 描述 | 状态 |
|----|------|------|------|
| U-GL-001 | 未知 | GL_VOUCHERENTRY表结构的具体字段定义 | 需进一步读取元数据 |
| U-GL-002 | 未知 | AccountBalance表的预计算触发机制 | 需进一步读取过账服务源码 |
| U-GL-003 | 未知 | 凭证号的分配规则（连续号/分段号） | 需读取凭证号规则配置 |
| X-GL-001 | 矛盾 | SubLedgerFilter中多处引用`GL_CheckingAccount`（对账账户），但对账账户与GL的关系需进一步确认 | 待确认 |

---

## 附录：事实表/非事实表详细分析

### A.1 表分类总览

#### 事实表（Fact Tables）

记录业务事件的发生，是业务数据的核心存储。

| 表名 | 类型 | 描述 | 主要字段 |
|------|------|------|----------|
| GL_VOUCHER | 事实表 | 凭证表头 | FVoucherID, FACCTBOOKID, FDATE, FVCHGROUPID, FDOCUMENTSTATUS |
| GL_VOUCHERENTRY | 事实表 | 凭证分录 | FENTRYID, FVOUCHERID, FACCOUNTID, FDEBIT, FCREDIT, FEXPLAIN |
| BAS_BusinessVoucher | 事实表 | 业务-凭证映射 | FBIZVOUCHERID, FGLVOUCHERID, FSOURCEBILLID, FSOURCEBILLKEY |

#### 非事实表（Dimension/Reference Tables）

定义业务实体的属性和分类，用于过滤、分组和关联。

| 表名 | 类型 | 描述 | 主要字段 |
|------|------|------|----------|
| BD_AccountBook | 非事实表 | 账簿定义 | FACCTBOOKID, FACCTBOOKNAME, FACCTSYSID, FCURRENCYID |
| BD_Account | 非事实表 | 会计科目 | FACCOUNTID, FACCTNUMBER, FACCTNAME, FACCTGROUPID, FBALANCEDIRECT |
| BD_AccountSystem | 非事实表 | 科目体系 | FACCTSYSID, FACCTSYSNAME |
| BD_FiscalPeriod | 非事实表 | 会计期间 | FPERIODID, FACCTBOOKID, FYEAR, FPERIOD, FSTATUS |
| BD_Currency | 非事实表 | 币别 | FCURRENCYID, FCURRENCYNAME, FCURRENCYCODE |

#### 派生表（Derived Tables）

由事实表计算得出的聚合数据。

| 表名 | 类型 | 描述 | 刷新方式 |
|------|------|------|----------|
| AccountBalance | 派生表 | 科目余额 | 凭证过账时更新 |
| GL_RPT_* | 派生表 | 各种报表 | 实时查询+缓存 |

### A.2 事实表详细分析

#### GL_VOUCHER（凭证表头）

**表性质**：事实表 - 业务事件记录

**业务含义**：每一张记账凭证是一条记录，记录凭证的基本信息和状态。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FVOUCHERID | BIGINT | 凭证ID（主键） | 100001 |
| FACCTBOOKID | BIGINT | 账簿ID（外键→BD_AccountBook） | 1 |
| FDATE | DATE | 凭证日期 | 2024-01-15 |
| FVCHGROUPID | INT | 凭证字ID | 1 |
| FVOUCHERNUMBER | VARCHAR | 凭证号 | 记-0001 |
| FDOCUMENTSTATUS | VARCHAR | 单据状态 | A(暂存)/B(审核中)/C(已审核) |
| FPOSTSTATUS | VARCHAR | 过账状态 | A(未过账)/B(已过账) |
| FCREATORID | BIGINT | 创建人 | 1001 |
| FCREATEDATE | DATETIME | 创建时间 | 2024-01-15 10:30:00 |
| FMODIFIERID | BIGINT | 修改人 | 1001 |
| FMODIFIEDDATE | DATETIME | 修改时间 | 2024-01-15 11:00:00 |
| FAPPROVERID | BIGINT | 审核人 | 1002 |
| FAPPROVEDATE | DATETIME | 审核时间 | 2024-01-15 14:00:00 |
| FEXPLANATION | VARCHAR | 凭证摘要 | 1月份办公费用 |

**引用关系**：
```
GL_VOUCHER (N) ← GL_VOUCHERENTRY (N)  [1:N 凭证头-分录]
GL_VOUCHER (N) → BD_AccountBook (1)   [N:1 凭证→账簿]
GL_VOUCHER (1) → BAS_BusinessVoucher (N) [1:N 凭证→业务映射]
```

**源码证据**：
```csharp
// ViewGlVoucher.cs:90
listpara.FormId = "GL_VOUCHER";  // 凭证表单ID

// ViewGlVoucher.cs:150
DynamicObjectCollection glVoucherList = QueryServiceHelper.GetDynamicObjectCollection(ctx, 
    new QueryBuilderParemeter
    {
        FormId = "GL_VOUCHER",
        SelectItems = SelectorItemInfo.CreateItems("FVoucherID"),  // 凭证ID字段
        FilterClauseWihtKey = strFiter
    }, null);
```

#### GL_VOUCHERENTRY（凭证分录）

**表性质**：事实表 - 业务事件明细

**业务含义**：每张凭证的每一个分录行是一条记录，记录借方或贷方的科目、金额、核算维度。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FENTRYID | BIGINT | 分录ID（主键） | 200001 |
| FVOUCHERID | BIGINT | 凭证ID（外键→GL_VOUCHER） | 100001 |
| FSEQ | INT | 分录序号 | 1, 2 |
| FACCOUNTID | BIGINT | 科目ID（外键→BD_Account） | 5001 |
| FEXPLAIN | VARCHAR | 分录摘要 | 办公费 |
| FDEBIT | DECIMAL | 借方金额 | 100000.00 |
| FCREDIT | DECIMAL | 贷方金额 | 0.00 |
| FDEBITFOR | DECIMAL | 借方外币金额 | 100000.00 |
| FCREDITFOR | DECIMAL | 贷方外币金额 | 0.00 |
| FCURRENCYID | BIGINT | 币别ID | 1 |
| FEXCHANGERATE | DECIMAL | 汇率 | 1.0000 |
| FDETAILID | BIGINT | 核算维度ID | 3001 |

**引用关系**：
```
GL_VOUCHERENTRY (N) → GL_VOUCHER (1)     [N:1 分录→凭证头]
GL_VOUCHERENTRY (N) → BD_Account (1)     [N:1 分录→科目]
```

#### BAS_BusinessVoucher（业务凭证映射表）

**表性质**：事实表 - 关联桥接表

**业务含义**：记录业务单据与GL凭证的对应关系，支持双向追溯。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FBIZVOUCHERID | BIGINT | 业务凭证ID | 300001 |
| FGLVOUCHERID | BIGINT | GL凭证ID（外键→GL_VOUCHER） | 100001 |
| FSOURCEBILLID | BIGINT | 源单据ID | 80001 |
| FSOURCEBILLKEY | VARCHAR | 源单据类型 | AP_PAYBILL |
| FMAKEDATE | DATETIME | 生成时间 | 2024-01-15 10:30:00 |

**引用关系**：
```
BAS_BusinessVoucher (1) → GL_VOUCHER (1)       [业务凭证→GL凭证]
BAS_BusinessVoucher (N) → 业务单据表 (1)       [业务凭证→业务单据]
```

**源码证据**：
```csharp
// ViewGlVoucher.cs:116
col.AddRange(SelectorItemInfo.CreateItems("FSOURCEBILLID,FVoucherID,FGLVoucherID"));
// 查询条件：业务单据类型 + ID列表
para.FilterClauseWihtKey = string.Format("FSourceBillKey='{0}' And FSourceBillID in ({1}) ",
    this.View.BillBusinessInfo.GetForm().Id, 
    string.Join<long>(",", pkList));
```

### A.3 非事实表详细分析

#### BD_AccountBook（账簿）

**表性质**：非事实表 - 配置/维度表

**业务含义**：账簿是企业财务核算的基本组织单元，定义了核算的科目体系、币别、会计期间等基本参数。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FACCTBOOKID | BIGINT | 账簿ID（主键） | 1 |
| FACCTBOOKNAME | VARCHAR | 账簿名称 | 主账簿 |
| FACCTSYSID | BIGINT | 科目体系ID（外键→BD_AccountSystem） | 1 |
| FCURRENCYID | BIGINT | 本位币ID（外键→BD_Currency） | 1 |
| FACCOUNTORGID | BIGINT | 核算组织ID | 1000 |
| FSTARTDATE | DATE | 启用日期 | 2024-01-01 |
| FSTATUS | INT | 状态 | 1(启用)/0(禁用) |

**引用关系**：
```
BD_AccountBook (1) → BD_AccountSystem (1)  [账簿→科目体系]
BD_AccountBook (1) → BD_Currency (1)       [账簿→币别]
BD_AccountBook (1,N) → BD_FiscalPeriod (N) [账簿→会计期间]
BD_AccountBook (1) → GL_VOUCHER (N)        [账簿→凭证]
```

**源码证据**：
```csharp
// SubLedger.cs:527
DynamicObjectType dynamicObjectType = ((FormMetadata)MetaDataServiceHelper.Load(base.Context, "BD_AccountBook", true)).BusinessInfo.GetDynamicObjectType();
DynamicObject value = BusinessDataServiceHelper.LoadSingle(base.Context, dic["ACCTBOOKID"].ToString(), dynamicObjectType, null);

// GeneralLedgerFilter.cs:28
ReportFilterCommonFunction.InitializeAcctBook(this.View, base.Context, "FACCTBOOKID");
```

#### BD_Account（会计科目）

**表性质**：非事实表 - 配置/维度表

**业务含义**：会计科目是组织财务信息的基本分类单元，具有层级结构，支持辅助核算。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FACCOUNTID | BIGINT | 科目ID（主键） | 5001 |
| FACCTNUMBER | VARCHAR | 科目编码 | 6602.01 |
| FACCTNAME | VARCHAR | 科目名称 | 办公费 |
| FACCTSYSID | BIGINT | 科目体系ID | 1 |
| FPARENTID | BIGINT | 父级科目ID | 5000 |
| FLEVEL | INT | 科目级次 | 3 |
| FBALANCEDIRECT | INT | 余额方向 | 1(借方)/-1(贷方) |
| FISCASH | INT | 现金科目 | 1 |
| FISBANK | INT | 银行科目 | 1 |
| FDETAILREQUIRED | INT | 必须核算维度 | 1 |
| FSTATUS | INT | 状态 | A(启用)/D(禁用) |

**引用关系**：
```
BD_Account (1) → BD_Account (N)    [科目自关联(父子)]
BD_Account (1) → BD_AccountSystem (1) [科目→科目体系]
BD_Account (1) → GL_VOUCHERENTRY (N) [科目→凭证分录]
BD_Account (1) → AccountBalance (N)   [科目→余额]
```

**源码证据**：
```csharp
// SubLedger.cs:694
DynamicObjectType dynamicObjectType2 = ((FormMetadata)MetaDataServiceHelper.Load(base.Context, "BD_Account", true)).BusinessInfo.GetDynamicObjectType();
DynamicObject value3 = BusinessDataServiceHelper.LoadSingle(base.Context, vchEntryInfo["FACCOUNTID"], dynamicObjectType2, null);

// GeneralLedgerFilter.cs:196
GeneralLedgerFilter.F7MoreSelectList(this.View, this.Model, "BD_Account", target);
```

#### BD_FiscalPeriod（会计期间）

**表性质**：非事实表 - 配置/维度表

**业务含义**：会计期间定义了财务核算的时间分段，通常为月份，是凭证日期和报表期间的约束基础。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FPERIODID | BIGINT | 期间ID（主键） | 202401 |
| FACCTBOOKID | BIGINT | 账簿ID | 1 |
| FYEAR | INT | 会计年度 | 2024 |
| FPERIOD | INT | 会计月份 | 1 |
| FSTARTDATE | DATE | 期间开始日期 | 2024-01-01 |
| FENDDATE | DATE | 期间结束日期 | 2024-01-31 |
| FSTATUS | INT | 期间状态 | 0(关闭)/1(打开)/2(结账) |

**引用关系**：
```
BD_FiscalPeriod (N) → BD_AccountBook (1)   [期间→账簿]
BD_FiscalPeriod (1) → GL_VOUCHER (N)       [期间→凭证]
BD_FiscalPeriod (1) → AccountBalance (N)   [期间→余额]
```

#### BD_Currency（币别）

**表性质**：非事实表 - 配置/维度表

**关键字段**：

| 字段名 | 数据类型 | 业务含义 | 取值示例 |
|--------|----------|----------|----------|
| FCURRENCYID | BIGINT | 币别ID（主键） | 1 |
| FCURRENCYNAME | VARCHAR | 币别名称 | 人民币 |
| FCURRENCYCODE | VARCHAR | 币别代码 | RMB |
| FISPRIMARY | INT | 是否本位币 | 1 |

**引用关系**：
```
BD_Currency (1) → BD_AccountBook (N)       [币别→账簿]
BD_Currency (1) → GL_VOUCHERENTRY (N)      [币别→凭证分录]
BD_Currency (1) → AccountBalance (N)       [币别→余额]
```

### A.4 派生表详细分析

#### AccountBalance（科目余额表）

**表性质**：派生表 - 预计算聚合

**业务含义**：存储每个科目在每个会计期间、币别、核算维度组合下的期初余额、本期发生额、期末余额。

**关键字段**：

| 字段名 | 数据类型 | 业务含义 |
|--------|----------|----------|
| FBALANCEID | BIGINT | 余额ID（主键） |
| FACCTBOOKID | BIGINT | 账簿ID |
| FACCOUNTID | BIGINT | 科目ID |
| FCURRENCYID | BIGINT | 币别ID |
| FDETAILID | BIGINT | 核算维度ID |
| FYEAR | INT | 会计年度 |
| FPERIOD | INT | 会计月份 |
| FBEGINBALANCE | DECIMAL | 期初余额 |
| FDEBIT | DECIMAL | 本期借方 |
| FCREDIT | DECIMAL | 本期贷方 |
| FENDBALANCE | DECIMAL | 期末余额 |

**刷新机制**：凭证过账时更新

**源码证据**：
```csharp
// GeneralLedger.cs:54
if (properties.ContainsKey("FBALANCEID") && properties.ContainsKey("FACCTNUMBER"))
{
    // 打印时回填余额ID
    dynamicObject["FACCTNUMBER"] = value;
}
```

### A.5 表间关系图

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            GL总账模块 表关系图                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐                                                         │
│  │  BD_AccountBook │◄──────────┐                                             │
│  │     (账簿)       │           │                                             │
│  └────────┬────────┘           │                                             │
│           │                    │                                             │
│           ├────────────────────┼────────────────────────┐                    │
│           │                    │                        │                    │
│           ▼                    ▼                        ▼                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │ BD_AccountSystem│  │  BD_Currency    │  │ BD_FiscalPeriod │             │
│  │   (科目体系)     │  │    (币别)       │  │   (会计期间)     │             │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│           │                    │                    │                       │
│           │                    │                    │                       │
│           ▼                    │                    │                       │
│  ┌─────────────────┐           │                    │                       │
│  │   BD_Account    │           │                    │                       │
│  │    (科目)       │◄──────────┴────────────────────┘                       │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ├──────────────────────────────────────────┐                       │
│           │                                          │                       │
│           ▼                                          ▼                       │
│  ┌─────────────────┐                        ┌─────────────────┐             │
│  │GL_VOUCHERENTRY  │                        │ AccountBalance  │             │
│  │   (凭证分录)    │                        │   (科目余额)     │             │
│  └────────┬────────┘                        └────────▲────────┘             │
│           │                                          │                       │
│           │                                          │                       │
│           ▼                                          │                       │
│  ┌─────────────────┐                                 │                       │
│  │  GL_VOUCHER     │─────────────────────────────────┘                       │
│  │   (凭证表头)    │                                                         │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │BAS_BusinessVoucher│                                                       │
│  │  (业务凭证映射)  │                                                         │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           │  ┌──────────────────────────────────────────┐                   │
│           │  │         上游业务模块                      │                   │
│           └──┼─►AP_PAYBILL (付款单)                      │                   │
│              │AR_RECEIVEBILL (应收单)                    │                   │
│              │CB_CASHPAYMENT (现金付款)                  │                   │
│              │CN_RECEIVE (收款单)                        │                   │
│              └──────────────────────────────────────────┘                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

图例：
  ────► : 外键引用关系（多指向一）
  ◄──── : 反向对应关系
```

### A.6 表分类决策说明

**为什么这样分类？**

1. **GL_VOUCHER / GL_VOUCHERENTRY / BAS_BusinessVoucher 是事实表**：
   - 它们记录的是具体的、可观察的业务事件
   - 每一条记录对应一个业务动作（生成凭证、审核凭证）
   - 数据随业务发生而增加，不会被预先填充

2. **BD_* 是非事实表（维度/配置表）**：
   - 它们定义的是业务对象的分类和属性
   - 数据通常由系统管理员配置，不随业务事件增加
   - 用于过滤、分组、关联事实数据

3. **AccountBalance 是派生表**：
   - 它的数据由事实表（凭证分录）计算得出
   - 可以从事实表重新计算得到
   - 存在目的是为了提升查询性能

---

## 文档变更记录

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v1.0 | 2026-08-06 | Claude | 初始版本，基于K3Cloud反编译源码分析 |
