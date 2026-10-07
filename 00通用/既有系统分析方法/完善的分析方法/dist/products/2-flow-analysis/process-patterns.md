# 业务模式分析

## 模式概览

| 模式 | 描述 | 涉及领域 | 匹配对象数 | 业务目的 |
|------|------|----------|------------|----------|
| Order-Payment | 订单与支付 | 待确认 | 797 | 跨域协作 |
| Master-Detail | 主从明细 | 待确认 | 481 | 跨域协作 |
| User-Role | 用户权限 | 待确认 | 159 | 跨域协作 |
| Category-Tree | 树形分类 | 待确认 | 73 | 跨域协作 |
| Config-Reference | 配置参照 | 待确认 | 443 | 跨域协作 |
| Print-Label | 打印标签 | 待确认 | 651 | 跨域协作 |
| Goods-SKU | 商品SKU | 待确认 | 396 | 跨域协作 |

## 核心模式详解

### 模式：Order-Payment

**模式描述**：订单与支付

**参与对象**（前10个）：
- `ChoosePayTypeEnum`
- `OrderGoodsTypeEnum`
- `ExecOrderEngineBo`
- `OrderBo`
- `PromotionPayBo`
- `SdkExecuteOrderBo`
- `SyncExecuteOrderListBo`
- `OrderBo`
- `OrderDetailBo`
- `OrderPayBo`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：Master-Detail

**模式描述**：主从明细

**参与对象**（前10个）：
- `DetailGoodsPromotionBo`
- `OrderDetailBo`
- `OrderDetailEntity`
- `CombinationGoodsDetail`
- `GoodsPracticeItem`
- `GoodsTagDetail`
- `OrgGoodsItemVo`
- `BookDetailConvert`
- `BookDetailConvertImpl`
- `RefreshOnlineStatusRequest`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：User-Role

**模式描述**：用户权限

**参与对象**（前10个）：
- `BaseAuthPageDto`
- `MultipleMemberTypeEnum`
- `UserAccount`
- `UserAccountConvert`
- `UserAccountConvertImpl`
- `UserAuthEnum`
- `AccountRightAuthRequest`
- `AccountRightAuthService`
- `UserAccountService`
- `SyncAccountAuthInfoService`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：Category-Tree

**模式描述**：树形分类

**参与对象**（前10个）：
- `CategoryLevelEnum`
- `SyncGoodsCategoryService`
- `SyncOrgPaySubjectCategoryService`
- `GoodsCategoryStatistics`
- `ZcPosCategoryDisplayEnum`
- `PaySubjectCategoryEnum`
- `CategoryManager`
- `GoodsCategoryDao`
- `OrgPaySubjectCategoryDao`
- `PrintGroupRelationCategoryDao`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：Config-Reference

**模式描述**：配置参照

**参与对象**（前10个）：
- `OSSConst`
- `ErrorCodeEnum`
- `AliyunOssAutoConfiguration`
- `BaseCodeEnum`
- `YesOrNoEnum`
- `AmountRuleEnum`
- `AutoExecuteEnum`
- `BalanceLimittRuleEnum`
- `BrandScopeEnum`
- `CalrGoodsTypeEnum`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：Print-Label

**模式描述**：打印标签

**参与对象**（前10个）：
- `RechargeInvoicePrintRequest`
- `SyncOrgPrintTemplateService`
- `SyncPrintDeviceSetService`
- `SyncPrintGoodsGroupSetService`
- `SyncPrintGoodsSetService`
- `SyncPrintGroupFreeTimeService`
- `SyncPrintGroupRelationService`
- `SyncPrintOnlineSetService`
- `SyncPrintSetService`
- `SyncPrintTableSetService`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

### 模式：Goods-SKU

**模式描述**：商品SKU

**参与对象**（前10个）：
- `CalrGoodsTypeEnum`
- `GoodsApplyTypeEnum`
- `OrderGoodsTypeEnum`
- `UnDiscountGoodsJoinEnum`
- `ComGoodsData`
- `ComLessGoodsData`
- `DetailGoodsPromotionBo`
- `ExecuteGoodsBo`
- `GoodsBo`
- `GoodsEngineBo`

**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---


## 模式归纳总结

### 主导模式

系统中最核心的业务模式为 **Order-Payment**，
涉及 **797** 个业务对象。

### 模式特征

1. **主-明细模式突出**：订单与订单明细的关系是核心
2. **支付集成**：订单-支付模式贯穿整个业务流程
3. **本地化特性**：KDS、打印等本地POS特有模式

### 需人工确认项

- [ ] 各模式的参与对象需人工确认
- [ ] 模式间的边界需业务专家评审
- [ ] 补偿机制需验证正确性

---

**生成时间**: 2026-09-11 10:22:24
