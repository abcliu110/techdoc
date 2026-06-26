# POS实物券折扣率与券抵扣字段说明

## 1. 背景

POS 使用 CRM 实物券时，折扣券、立减券、免费券都会在订单中生成券记录和对应食品行。

本次问题集中在两个口径：

1. 食品行上的 `discountRate` 是否应该体现实物券的 5 折、立减等券规则。
2. 食品行上的 `couponAmount` 是否应该记录实物券实际抵扣额。

结论：`discountRate` 不应该记录实物券规则；实物券实际抵扣额应该落到 `couponAmount`。

## 2. 字段含义

### 2.1 DwdFood.discountRate

`DwdFood.discountRate` 是普通菜品折扣后的保留比例，不是实物券折扣率。

当前后端计算逻辑中，普通折扣额按下面口径计算：

```text
普通折扣额 = foodAmount * (1 - discountRate)
```

因此：

| discountRate | 普通折扣含义 | 普通折扣额 |
| --- | --- | --- |
| `1` | 不打普通折扣 | `0` |
| `0.8` | 普通 8 折 | `foodAmount * 0.2` |
| `0.5` | 普通 5 折 | `foodAmount * 0.5` |

实物券食品行当前会被设置为 `discountRate=1`，含义是“该食品不再参与普通折扣”，不是“实物券按 100% 展示”。

### 2.2 DwdFood.discountAmount

`DwdFood.discountAmount` 是普通折扣额。

实物券抵扣不能写入该字段。否则订单会先按普通折扣扣一次，再按 `DwdCoupon.faceAmount` 扣一次，形成重复优惠。

### 2.3 DwdCoupon.faceAmount

`DwdCoupon.faceAmount` 是券在订单维度的实际抵扣金额。

CRM 实物券进入 POS 后，实物券类型 WP/MP/DP 的 `faceAmount` 已按券规则算好：

| 券类型 | 菜品金额 | faceAmount |
| --- | ---: | ---: |
| 5 折实物券 | 10.00 | 5.00 |
| 立减 3 元实物券 | 10.00 | 3.00 |
| 免费实物券 | 10.00 | 10.00 |

订单最终实收仍通过 `DwdCoupon.faceAmount` 统一扣减。

### 2.4 DwdFood.couponAmount

`DwdFood.couponAmount` 是食品行上的券抵扣金额。

本次后端修改后，WP/MP/DP 这类实物券会把 `DwdCoupon.faceAmount` 分摊回对应食品行 `couponAmount`。

如果一张券只对应一行食品：

```text
DwdFood.couponAmount = min(DwdCoupon.faceAmount, 食品行可抵扣金额)
```

如果一张券对应多行食品：

```text
按食品行可抵扣金额比例分摊，最后一行承接 0.01 尾差。
```

## 3. 典型场景

### 3.1 5 折实物券

菜品金额 10 元，使用 5 折实物券。

| 字段 | 值 | 含义 |
| --- | ---: | --- |
| `DwdFood.discountRate` | `1` | 不参与普通折扣 |
| `DwdFood.discountAmount` | `0` | 普通折扣额为 0 |
| `DwdCoupon.faceAmount` | `5` | 券实际抵扣 5 元 |
| `DwdFood.couponAmount` | `5` | 食品行券抵扣 5 元 |
| 券后实收 | `5` | 前端可按 `paidAmount - couponAmount` 派生展示 |

### 3.2 立减 3 元实物券

菜品金额 10 元，使用立减 3 元实物券。

| 字段 | 值 | 含义 |
| --- | ---: | --- |
| `DwdFood.discountRate` | `1` | 不参与普通折扣 |
| `DwdFood.discountAmount` | `0` | 普通折扣额为 0 |
| `DwdCoupon.faceAmount` | `3` | 券实际抵扣 3 元 |
| `DwdFood.couponAmount` | `3` | 食品行券抵扣 3 元 |
| 券后实收 | `7` | 前端可按 `paidAmount - couponAmount` 派生展示 |

### 3.3 免费实物券

菜品金额 10 元，使用免费实物券。

| 字段 | 值 | 含义 |
| --- | ---: | --- |
| `DwdFood.discountRate` | `1` | 不参与普通折扣 |
| `DwdFood.discountAmount` | `0` | 普通折扣额为 0 |
| `DwdCoupon.faceAmount` | `10` | 券实际抵扣 10 元 |
| `DwdFood.couponAmount` | `10` | 食品行券抵扣 10 元 |
| 券后实收 | `0` | 前端可按 `paidAmount - couponAmount` 派生展示 |

## 4. 本次后端修改

本次只修改后端，前端暂不修改。

修改位置：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\GeneralCalcOrderServiceImpl.java
```

修改内容：

1. 在订单重算食品行时，收集每张券对应的食品行。
2. 保留实物券食品行 `discountRate=1`、`discountAmount=0` 的普通折扣语义。
3. 对 WP/MP/DP 这类 `faceAmount` 由 CRM 计算好的实物券，不再用食品整行应收覆盖券金额。
4. 新增 `resetFixedFaceCouponAmount`，把 `DwdCoupon.faceAmount` 分摊回食品行 `DwdFood.couponAmount`。
5. 保留 `zJCouponAmount` 兼容逻辑，分摊实物券时先扣除，最后再加回。

## 5. 前端暂不修改的记录

本次明确暂不修改前端。

因此当前页面如果仍展示：

```text
折扣率 = discountRate * 100%
折扣额 = discountAmount
实收金额 = paidAmount
```

实物券食品行仍可能显示为普通折扣率 100%、普通折扣额 0。

这是前端展示口径问题，不是后端折扣计算字段错误。

后续前端建议：

1. 不要把实物券 5 折写入或展示为普通 `discountRate=0.5`。
2. 对有 `couponAmount > 0` 或有 `couponNo/couponName` 的食品行，额外展示：
   - 券抵扣额：`couponAmount`
   - 券后实收：`paidAmount - couponAmount`
   - 券后折扣率：`(paidAmount - couponAmount) / foodAmount`
3. 普通折扣字段仍按原含义展示，避免把券抵扣和普通折扣混在同一字段中。

## 6. 风险说明

不能把 5 折实物券写成：

```text
DwdFood.discountRate = 0.5
```

原因是该字段会参与普通折扣金额计算：

```text
discountAmount = foodAmount * (1 - discountRate)
```

如果实物券 5 折同时写入 `discountRate=0.5`，订单会出现两次优惠：

1. 食品行普通折扣先扣 5 元。
2. 订单维度再按 `DwdCoupon.faceAmount=5` 扣 5 元。

这会导致 10 元菜品被扣成 0 元，而不是 5 折后的 5 元。

## 7. 验证结果

后端已补充测试：

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\test\java\com\nms4cloud\pos2plugin\service\order\GeneralCalcOrderServiceImplTest.java
```

覆盖场景：

1. 实物券 `faceAmount` 不被 POS 重算覆盖。
2. 单食品行实物券把 `faceAmount` 写入 `couponAmount`。
3. 多食品行同券按比例分摊，最后一行处理尾差。
4. `faceAmount` 大于食品可抵扣金额时，食品行券抵扣不超过可抵扣金额。

验证命令：

```powershell
mvn -pl nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz test
```

验证结果：

```text
Tests run: 52, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```
