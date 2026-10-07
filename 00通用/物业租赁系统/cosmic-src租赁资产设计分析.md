# D:\cosmic-src 租赁资产设计分析

## 附录：财务函数对照表

| 缩写 | 全称 | 中文 | 含义 | 租赁场景示例 |
|------|------|------|------|-------------|
| **PV** | Present Value | 现值 | 未来的钱在今天的价值 | 租赁负债 = 未来各期租金的现值之和 |
| **FV** | Future Value | 未来值 | 现在的钱在将来的价值 | 100万存1年，年利率5%，FV=105万 |
| **PMT** | Payment | 付款额 | 每期支付的金额 | 月租金2.25万，PMT=22,500 |
| **NPER** | Number of Periods | 期数 | 总共多少期 | 租2年月付，NPER=24期 |
| **RATE** | Rate | 利率 | 每期利率 | 月利率 = (1+5%)^(1/12) - 1 ≈ 0.41% |
| **NPV** | Net Present Value | 净现值 | 现值减去初始投资 | NPV>0则投资可行 |
| **IRR** | Internal Rate of Return | 内部收益率 | 使NPV=0的折现率 | 租赁内含利率 |

**核心公式**：
```
现值 = 未来值 ÷ (1 + 利率)^期数
PV = FV / (1+r)^n

年金现值（每期金额固定）：
PV = PMT × [1 - (1+r)^(-n)] / r

利息 = 期初负债 × 期利率
还本 = 支付 - 利息
```

---

## 一、模块架构概览

`cosmic-src` 财务模块（fi-fa）实现了完整的 IFRS 16/CAS 21 租赁资产管理体系，核心代码位于：

```
fi-fa/src/main/java/kd/fi/fa/
├── business/
│   ├── enums/lease/          # 租赁枚举定义
│   ├── lease/                # 核心业务逻辑
│   │   ├── InterestDetailGenerator.java      # 利息明细生成
│   │   ├── FaLeaseDebitBalanceGenerator.java # 租赁负债余额生成
│   │   ├── LeaseContractGenerator.java       # 租赁合同生成
│   │   ├── LeaseTerminationHandler.java       # 租赁终止处理
│   │   ├── RentSettleGenerator.java          # 租金结算生成
│   │   ├── LeaseContractCal.java             # 合同自动计算
│   │   ├── partter/                        # 部分终止计算
│   │   ├── cardgenerate/impl/               # 卡片生成
│   │   └── utils/                           # 工具类
│   └── constants/              # 常量定义
├── formplugin/lease/          # 表单插件
├── opplugin/lease/            # 操作插件
├── mservice/lease/           # 服务接口
└── report/                   # 报表
```

---

## 二、核心枚举设计

### 2.1 租赁合同来源类型 (LeaseContractSourceType)

```java
public enum LeaseContractSourceType {
    A,  // 新增租赁合同
    B,  // 租赁变更
    C;  // 续租/部分终止
}
```

### 2.2 付款频率 (PayFrequency)

```java
public enum PayFrequency {
    A(1),   // 每月
    B(2),   // 每2月
    C(3),   // 每季度
    D(6),   // 每半年
    E(12),  // 每年
    F(-1),  // 不定期
    G(4);   // 每4月
}
```

### 2.3 折旧类型 (LeaseContractDepreTypeEnum)

```java
public enum LeaseContractDepreTypeEnum {
    DAY("1"),   // 按日折旧
    MONTH("2"); // 按月折旧
}
```

### 2.4 转换方案 (TransitionPlan)

```java
public enum TransitionPlan {
    A,  // 存量租赁追溯调整法
    B,  // 简化追溯法
    C;  // 完全追溯法
}
```

### 2.5 日利率计算方式 (DailyDiscountRateFormula)

```java
public enum DailyDiscountRateFormula {
    COMPOUND_INTEREST("A"),  // 复利法
    SIMPLE_INTEREST("B");    // 单利法
}
```

---

## 三、核心数据结构

### 3.1 租赁合同主表 (fa_lease_contract)

关键字段（定义于 `FaLeaseContract.java`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `leaseassets` | BigDecimal | **使用权资产原值** |
| `leaseliab` | BigDecimal | **租赁负债现值** |
| `leaseliabori` | BigDecimal | **租赁负债原值** |
| `assetsaccumdepre` | BigDecimal | 使用权资产累计折旧 |
| `assetsaddupyeardepre` | BigDecimal | 本年累计折旧 |
| `depremonths` | Integer | 折旧月数 |
| `discountrate` | BigDecimal | 年折现率 |
| `dailydiscountrate` | BigDecimal | 日折现率 |
| `initconfirmdate` | Date | 初始确认日期 |
| `leasetermstartdate` | Date | 租赁期开始日 |
| `leasestartdate` | Date | 租赁开始日期 |
| `leaseenddate` | Date | 租赁结束日期 |
| `transitionplan` | String | 转换方案 (A/B/C) |
| `isexempt` | Boolean | **是否豁免（≤12个月）** |
| `sourcetype` | String | 来源类型 (A/B/C) |
| `sysswitchdate` | Date | 系统切换日 |

### 3.2 利息明细表 (fa_interest_detail)

关键字段（定义于 `FaInterestDetail.java`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `dailyrate` | BigDecimal | 日利率 |
| `detailentry` | Entry | 明细集合 |
| `seq` | Integer | 序号 |
| `date` | Date | 日期 |
| `beginbalance` | BigDecimal | 期初余额 |
| `leaseliabpay` | BigDecimal | 租赁负债支付 |
| `leaseliabint` | BigDecimal | 租赁负债利息 |
| `endbalance` | BigDecimal | 期末余额 |
| `realdailyrate` | BigDecimal | 实际日利率 |
| `sourcetype` | String | 来源类型 (A/B) |
| `latestdata` | Boolean | 是否最新数据 |

### 3.3 租赁负债余额表 (fa_lease_debit_balance)

关键字段（定义于 `FaLeaseDebitBalance.java`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `amortizationperiod` | Long | 摊销期间 |
| `deadlinedate` | Date | 截止日期 |
| `interestbalance` | BigDecimal | 利息余额（累计利息） |
| `leaseliaboribalbance` | BigDecimal | 负债原值余额（累计还本） |

### 3.4 折现率表 (fa_discount_rate)

关键字段（定义于 `FaDiscountRate.java`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `org` | Long | 组织 |
| `currency` | Long | 币种 |
| `effectivedate` | Date | 生效日期 |
| `entryentity` | Entry | 期间利率明细 |
| `term` | Integer | 租赁期间（月数） |
| `annualizedrate` | BigDecimal | 年化利率 |

---

## 四、利率计算详解

### 4.1 基本术语

| 缩写 | 英文全称 | 中文含义 |
|------|----------|----------|
| **FV** | Future Value | 终值（未来的钱） |
| **PV** | Present Value | 现值（现在的钱） |
| **r** | Rate | 利率 |
| **n** | Number of periods | 期数 |

### 4.2 期利率的计算

```
期利率 = (1 + 年利率)^(1/期数) - 1
```

| 周期 | 期数 n | 年利率 5% 时的期利率 |
|------|---------|---------------------|
| 日利率 | 365 | 0.0001334 |
| 月利率 | 12 | 0.004074 |
| 季度利率 | 4 | 0.012272 |

### 4.3 终值与现值公式

```
终值公式：FV = PV × (1 + r)^n
现值公式：PV = FV ÷ (1 + r)^n
```

### 4.4 日利率计算的两种方式

代码支持两种日利率计算方式（`LeaseContractCal.java:109-123`）：

#### 方式A：复利法（默认）

```java
private static BigDecimal calDailyRateByCompoundInterest(BigDecimal discountRate) {
    // 日利率 = (1 + 年利率)^(1/365) - 1
    BigDecimal number = BigDecimal.ONE.add(discountRate);
    BigDecimal root = FaBigDecimalUtil.rooting(number, 365, 10, 4);
    return root.subtract(BigDecimal.ONE);
}
```

**公式**：`日利率 = (1 + 年利率)^(1/365) - 1`

#### 方式B：单利法

```java
private static BigDecimal calDailyRateBySimpleInterest(BigDecimal discountRate) {
    // 日利率 = 年利率 / 365
    return discountRate.divide(new BigDecimal("365"), 10, 4);
}
```

**公式**：`日利率 = 年利率 ÷ 365`

### 4.5 系统参数控制

```java
String dailyDiscountRateFormula = SystemParamHelper.getStringParam(
    "dailydiscountrateformula",  // 参数名
    orgId,
    DailyDiscountRateFormula.COMPOUND_INTEREST.getValue()  // 默认复利法
);
```

### 4.6 折现率表查询

代码会自动根据组织、币种、日期查询折现率表（`LeaseContractCal.java:178-214`）：

```java
// 查询条件
// 1. org = 组织
// 2. currency = 币种
// 3. effectivedate <= 初始确认日期
// 4. enable = 1
// 5. 按生效日期降序取第一条

// 根据租赁期间匹配利率
for (DynamicObject row : entry) {
    if (depreMonths > term) continue;
    rate = row.getBigDecimal("annualizedrate");  // 取第一条满足条件的
    break;
}
```

---

## 五、核心业务逻辑

### 5.1 自动计算钩子 (LeaseContractCal)

租赁合同保存时自动计算关键字段：

```java
// LeaseContractGenerator.handleAutoCalFields()
public void handleAutoCalFields(DynamicObject leaseContract) {
    LeaseContractCal.setLeaseMonths(objWrapper);        // 租赁月数
    LeaseContractCal.setInitConfirmDate(objWrapper);    // 初始确认日
    LeaseContractCal.setLeaseTermStartDate(objWrapper); // 租赁期开始日
    LeaseContractCal.setIsExempt(objWrapper);          // 是否豁免
    LeaseContractCal.setDiscountRate(objWrapper);       // 年折现率
    LeaseContractCal.setDailyDiscountRate(objWrapper);   // 日折现率
    LeaseContractCal.setDepreMonths(objWrapper);       // 折旧月数
}
```

### 5.2 豁免判断逻辑

**判断条件**（`LeaseContractCal.setIsExempt()`）：
```
租赁期 ≤ 12个月 → isExempt = true
```

```java
public static void setIsExempt(IObjWrapper wrapper) {
    Date initConfirmDate = wrapper.getValue("initconfirmdate");
    Date leaseEndDate = wrapper.getValue("leaseenddate");
    int diffMonths = getDiffMonths(initConfirmDate, leaseEndDate);

    if (diffMonths <= 12) {
        wrapper.setValue("isexempt", Boolean.TRUE);
    } else {
        wrapper.setValue("isexempt", Boolean.FALSE);
    }
}
```

**豁免合同的处理**：
- 不计算折现率和日利率
- 租赁负债为零
- 不生成利息明细

### 5.3 使用权资产计算

**位置**：`LeaseUtil.calFinInfoFields()` (LeaseUtil.java:458-523)

```java
// 核心算法逻辑
for (DynamicObject row : planEntry) {
    String acctClass = payItem.getString("accountingclass");
    if ("C".equals(acctClass)) continue; // 忽略费用类付款项

    // 计算折现因子（复利公式）
    BigDecimal liabDiscountFactor = (1 + dailyRate)^discountDays;

    // 计算现值（现值公式）
    BigDecimal liabPresentValue = unpaidRent / liabDiscountFactor;

    // 累加
    leaseLiab += liabPresentValue;           // 租赁负债现值
    leaseLiabOri += unpaidRent;               // 租赁负债原值

    // 根据转换方案计算使用权资产
    if (TransitionPlan.A/C) {
        leaseAssets += assetsPresentValue;
    }
}
```

**关键公式**：
```
使用权资产 = Σ 每期付款额 / (1 + 日折现率)^折现天数
租赁负债现值 = Σ 本金类付款额 / (1 + 日折现率)^折现天数
租赁负债原值 = Σ 本金类付款额（未折现）
```

### 5.4 利息明细生成

**位置**：`InterestDetailGenerator.java`

```java
// 每日利息计算（复利）
while (rowDate <= detailEndDate) {
    // 期初余额
    BigDecimal beginBalance = getDetailBeginBalance();

    // 利息 = 期初余额 × 日利率
    BigDecimal leaseLiabInt = beginBalance.multiply(dailyRate);

    // 期末余额 = 期初余额 - 支付 + 利息
    BigDecimal endBalance = beginBalance - leaseLiabPay + leaseLiabInt;

    // 记录到明细表
    row.set("beginbalance", beginBalance);
    row.set("leaseliabpay", leaseLiabPay);
    row.set("leaseliabint", leaseLiabInt);
    row.set("endbalance", endBalance);

    beginBalance = endBalance;  // 利息加入本金
    rowDate = rowDate + 1;    // 按日计算
}
```

### 5.5 租赁负债余额生成

**位置**：`FaLeaseDebitBalanceGenerator.java`

```java
// 按会计期间分组汇总
Map<Long, List<Detail>> periodMap = groupByPeriod(detailEntry);

for (Long periodId : periodMap) {
    BigDecimal periodInterestSum = sum(leaseliabint);
    BigDecimal periodPaySum = sum(leaseliabpay);

    // 累计值
    BigDecimal totalInterest = previousTotal + periodInterestSum;
    BigDecimal totalPay = previousTotal + periodPaySum;

    createLeaseDebitBalance(periodId, totalInterest, totalPay);
}
```

---

## 六、部分终止计算

### 6.1 计算器类

**位置**：`LeasePartTerCalculator.java`

### 6.2 计算逻辑

```java
public static TerClearAmountInfo calcTerCardInfo(
    BigDecimal proportion,      // 终止比例
    DynamicObject leaseContract,
    long amortizationPeriodId,
    Date effectiveDate
) {
    // 获取结清明细数据
    Map detailData = convertor.getDetailData(leaseContract);

    for (ClearBillDetailData detail : detailData) {
        // 按终止比例计算各项金额
        BigDecimal clrAssetValue = originalVal.multiply(proportion);    // 结清资产原值
        BigDecimal clrAddUpDepre = accumDepre.multiply(proportion);     // 结清累计折旧
        BigDecimal clrNetAmount = netAmount.multiply(proportion);      // 结清净额
    }
}
```

### 6.3 终止后的租赁信息

```java
public static TerLeaseInfo calcTerLeaseInfo(
    BigDecimal proportion,
    DynamicObject leaseContract,
    Date effectiveDate
) {
    // 查询生效日之后的利息明细
    // 按终止比例计算
    BigDecimal leaseDebtOrigin = balance.multiply(proportion);      // 负债原值
    BigDecimal leaseDebtPresent = present.multiply(proportion);      // 负债现值
    BigDecimal noConfirmFinCost = finCost.multiply(proportion);     // 未确认融资费用
}
```

---

## 七、租金结算生成

### 7.1 结算器类

**位置**：`RentSettleGenerator.java`

### 7.2 生成流程

```java
public void generate() {
    // Step 1: 生成利息明细
    InterestDetailGenerator generator = new InterestDetailGenerator(paramPos);
    List<DynamicObject> interestDetails = generator.generate();

    // Step 2: 生成租金结算单
    for (DynamicObject interestDetail : interestDetails) {
        rentSettles.addAll(generateByInterestDetail(interestDetail));
    }

    // Step 3: 生成租赁负债余额
    for (DynamicObject interestDetail : interestDetails) {
        FaLeaseDebitBalanceGenerator gen = new FaLeaseDebitBalanceGenerator(interestDetail);
        debitBalanceList.addAll(gen.genLeaseDebitBalance());
    }

    // Step 4: 保存
    SaveServiceHelper.save(interestDetails);
    SaveServiceHelper.save(rentSettles);
    SaveServiceHelper.save(debitBalanceList);
}
```

### 7.3 按会计期间汇总

```java
protected List<DynamicObject> generateByInterestDetail(DynamicObject interestDetail) {
    for (DetailRow detail : detailEntry) {
        // 按期间汇总租金和利息
        rent += leaseLiabPay;
        interestSum += leaseLiabInt;
        interestDays++;

        // 期间变化时，生成结算单
        if (amortizationPeriodId 变化) {
            generateRentSettle(period, rent, interestSum, interestDays);
        }
    }
}
```

---

## 八、租赁变更处理

### 8.1 变更类型

| 类型 | 说明 | 代码位置 |
|------|------|----------|
| 完全终止 | 租赁合同终止 | `LeaseTerminationHandler` |
| 部分终止 | 部分租赁资产终止 | `LeasePartTerCalculator` |
| 续租 | 合同到期后续租 | 续租相关处理 |
| 租金变更 | 调整租金金额 | 变更单处理 |

### 8.2 终止处理流程

```java
public void handle() {
    generateClearBill();              // 生成租赁结清单
    generateRenewalContract();        // 生成续租合同（如有）
    generateReversalRentSettle();     // 生成反向租金结算
    updateLeaseContractBaseInfo();     // 更新合同基本信息
    updateClearEntryBalanceInfo();     // 更新余额信息
    generateTerminationRecords();      // 生成终止记录
}
```

---

## 九、财务卡片生成

### 9.1 常规租赁卡片

**位置**：`LeaseContractToFinCardGenerate.java`

```java
// 设置使用权资产相关字段
finCard.set("originalval", contract.get("leaseassets"));     // 原值
finCard.set("leasedebtorigin", contract.get("leaseliabori")); // 负债原值
finCard.set("leasedebtpresent", contract.get("leaseliab"));    // 负债现值
finCard.set("noconfirmfincost", leaseLiabOri - leaseLiab);     // 未确认融资费用
```

### 9.2 初始确认租赁卡片

**位置**：`InitLeaseContractToFinCardGenerate.java`

特点：
- 处理存量租赁（系统切换前的合同）
- 保留已计提的累计折旧
- 支持过渡方案 A/B/C

---

## 十、报表体系

### 10.1 摊销成本报表

**位置**：`FaAmortisedCostReportServiceImpl.java`

输出字段：
```java
leaseContractNumber      // 合同编号
leaseContractName        // 合同名称
startleaseliab          // 期初租赁负债
leaseamountchg          // 本期变更
rent                    // 本期租金
interest                // 本期利息
endleaseliab            // 期末租赁负债
startnetamount          // 期初净额
monthdepre              // 本期折旧
endnetamount            // 期末净额
accumdepre              // 累计折旧
```

---

## 十一、设计特点总结

### 11.1 高精度计算
- **按日计算利息**，避免月/季分割误差
- 日利率计算到 10 位小数精度
- 支持复利法和单利法两种日利率计算

### 11.2 灵活的付款频率
- 支持 7 种标准付款频率
- 支持不定期付款（PayFrequency.F）

### 11.3 完整的生命周期管理
- 新增 → 变更 → 部分终止/续租 → 完全终止
- 每个阶段都有对应的业务处理

### 11.4 多种转换方案支持
- 存量租赁可选择不同的 IFRS 16/CAS 21 过渡方案
- 自动计算累计影响数

### 11.5 期间结转机制
- 利息明细按日记录
- 负债余额按会计期间汇总
- 支持期间结账和解锁

### 11.6 折现率表管理
- 按组织、币种、生效日期维护利率
- 根据租赁期间自动匹配对应利率

---

## 十二、与准则对应关系

| IFRS 16/CAS 21 概念 | 代码实现 | 文件位置 |
|---------------------|----------|----------|
| 使用权资产原值 | `leaseassets` | `FaLeaseContract` |
| 租赁负债现值 | `leaseliab` | `FaLeaseContract` |
| 租赁负债原值 | `leaseliabori` | `FaLeaseContract` |
| 利息费用 | `leaseliabint` | `FaInterestDetail` |
| 本金偿还 | `leaseliabpay` | `FaInterestDetail` |
| 累计利息 | `interestbalance` | `FaLeaseDebitBalance` |
| 累计还本 | `leaseliaboribalbance` | `FaLeaseDebitBalance` |
| 日利率 | `dailyrate` | `FaInterestDetail` |
| 折现公式 | 复利折现 | `LeaseUtil.calFinInfoFields` |
| 实际利率法 | 按日复利 | `InterestDetailGenerator` |
| 短期租赁豁免 | `isexempt` | `FaLeaseContract` |
| 折现率表 | `fa_discount_rate` | `FaDiscountRate` |

---

## 附录：公式速查表

| 计算项 | 公式 |
|--------|------|
| 期利率 | `期利率 = (1 + 年利率)^(1/期数) - 1` |
| 复利日利率 | `日利率 = (1 + 年利率)^(1/365) - 1` |
| 单利日利率 | `日利率 = 年利率 ÷ 365` |
| 终值 | `FV = PV × (1 + r)^n` |
| 现值（折现） | `PV = FV ÷ (1 + r)^n` |
| 日利息 | `利息 = 期初余额 × 日利率` |
| 期末余额 | `期末余额 = 期初余额 - 支付 + 利息` |
| 豁免判断 | `租赁月数 ≤ 12 → isExempt = true` |
