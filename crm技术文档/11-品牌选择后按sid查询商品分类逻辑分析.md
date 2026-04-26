# 品牌选择后按 sid 查询商品分类逻辑分析

## 一、摘要

本次排查最终确认：

1. 页面“选择品牌”后，后续商品分类/商品请求里传入的 `sid`，实际是**品牌 `lid`**
2. 这并不只是前端单纯传错参数
3. 在当前系统中，`pt_dish / pt_dish_type` 运行时并不直接落在 `a_product.pt_*` 表，而是通过 ShardingSphere 路由到 **MyCat 逻辑库 `gylregdb`** 中的：
   - `sc_dish`
   - `sc_dish_type`
4. 这些老表里同时存在两种“菜品容器”：
   - **品牌级菜品容器**：`shop_id = brand_lid`
   - **门店级菜品容器**：`shop_id = store_sid`
5. 当前页面在“按品牌选商品”场景下，实际上是在访问**品牌级菜品容器**

一句话总结：

> 品牌菜品和门店菜品共用 `sc_dish / sc_dish_type` 这组物理表，差异不在表名，而在 `shop_id` 所承载的容器 ID 含义。

## 二、问题背景

页面“选择商品”时，网络请求大致表现为：

1. 先请求品牌列表：`/biz/sys_brand/list/`
2. 再请求商品分类小类：`/merchant/pt_dish_type/list_small`
3. 再请求商品列表：`/merchant/.../listAll`

本次重点是解释：

- 为什么前端选择品牌后会传一个名为 `sid` 的字段
- 为什么这个值不是门店 `sid` 也能查到分类和商品
- 品牌菜品与门店菜品在数据库中的真实组织方式是什么

## 三、接口现象与初始观察

页面上“选择品牌”后，前端请求体中出现类似：

```json
{
  "sid": "159426136916301937",
  "pageSize": 2000,
  "current": 1,
  "timestamp": 1777028168,
  "nonce": 938377
}
```

最初从接口命名直觉看，这个 `sid` 很容易被理解为“门店 sid”。  
但数据库验证后发现，这里传的并不是门店主键，而是**品牌主键 `lid`**。

## 四、后端接口语义

### 4.1 品牌列表接口

品牌列表来自：

- `sys_brand/list`

其语义是查询当前商户下的品牌数据，对应表：

- `sc_brand`

### 4.2 分类接口

商品分类小类接口来自：

- `pt_dish_type/list_small`

代码层虽然使用的是 `pt_dish_type`，但运行时实际物理表不是 `pt_dish_type`，而是通过分片规则映射到：

- `sc_dish_type`

后端查询条件里核心依然是：

- `company_id = mid`
- `shop_id = sid`

所以真正需要澄清的是：**这里的 `sid` 到底代表哪个“菜品容器 ID”**。

## 五、Nacos 配置与表映射关系

### 5.1 `nms4cloud-product.yaml`

在 Nacos 配置中，`nms4cloud-product.yaml` 明确配置了：

```yaml
spring:
  shardingsphere:
    datasource:
      names: mycat,pt
      mycat:
        url: jdbc:mysql://192.168.1.216:3308/gylregdb
      pt:
        url: jdbc:mysql://192.168.1.216:3306/a_product
    rules:
      sharding:
        tables:
          pt_dish_type:
            actual-data-nodes: mycat.sc_dish_type
          pt_dish:
            actual-data-nodes: mycat.sc_dish
          pt_dish_unit:
            actual-data-nodes: mycat.sc_dish_unit
          pt_dish_map:
            actual-data-nodes: mycat.sc_dish_map
```

这说明：

- 代码逻辑表名：`pt_dish / pt_dish_type`
- 运行时物理表：`mycat.sc_dish / mycat.sc_dish_type`
- 实际数据源：`192.168.1.216:3308/gylregdb`

### 5.2 `nms4cloud-pos4cloud.yaml`

在 `nms4cloud-pos4cloud.yaml` 中也存在同样映射：

```yaml
pt_dish:
  actual-data-nodes: mycat.sc_dish
pt_dish_type:
  actual-data-nodes: mycat.sc_dish_type
sys_brand:
  actual-data-nodes: mycat.sc_brand
sc_store:
  actual-data-nodes: mycat.sc_store
```

这进一步确认：

- 页面所经过的商品查询链路
- 品牌查询链路
- 门店关系链路

最终都会在 **MyCat 逻辑库 `gylregdb`** 中汇合。

## 六、数据库验证结果

### 6.1 品牌记录

在 `3308 / gylregdb.sc_brand` 中查询品牌 `康师傅`，查得：

- `mid = 159411180237043484`
- `brand_sid = 159411180237074902`
- `brand_lid = 159426136916301937`
- `name = 康师傅`

由此确认：

> 页面传给后续分类/商品接口的 `sid=159426136916301937`，实际上命中的是 **品牌 `lid`**

### 6.2 品牌与门店关系

在 `3308 / gylregdb.sc_store` 中按：

```text
sc_store.brand_code = sc_brand.lid
```

查询 `康师傅` 品牌下的门店，查得多条记录，例如：

- `159426147207078756` 天河店
- `1684817396849500161` 门店结算一
- `1684817609915949058` 门店结算二
- `1746815992676028417` 康师傅-红茶
- `1746816275858657282` 康师傅-绿茶

这说明“品牌 -> 门店”的正规关系确实存在，而且是：

```text
brand_lid -> sc_store.brand_code -> 多个门店 shop_id
```

### 6.3 品牌级菜品容器验证

继续在 `3308 / gylregdb.sc_dish_type`、`sc_dish` 中直接按：

```text
company_id = 159411180237043484
shop_id    = 159426136916301937   -- 即康师傅品牌 lid
```

查询，得到结果：

- `sc_dish_type`：有 6 条分类数据
- `sc_dish`：有 10 条商品数据

这说明：

> 系统中存在一层“品牌级菜品容器”，其容器主键值就写在 `shop_id` 字段里，并且这个值等于品牌 `lid`

### 6.4 门店级菜品容器验证

再使用门店 `康师傅-红茶` 的门店 `sid = 1746815992676028417` 去查：

- `sc_dish_type`：也有 6 条分类
- `sc_dish`：有 8 条商品

其中商品包括：

- 石头鱼
- 青衣鱼
- 扩泉水
- 可乐
- 雪碧
- 炸鸡
- 炸鸡套餐
- 左口鱼

这说明：

> 门店级菜品数据和品牌级菜品数据共用同一组表，只是 `shop_id` 的值换成了门店 `sid`

## 七、品牌菜品与非品牌菜品的设计逻辑

### 7.1 品牌菜品

品牌菜品不是单独一张“品牌菜品主表”，而是用以下方式建模：

- 表：`sc_dish`、`sc_dish_type`
- 容器 ID：`shop_id = brand_lid`
- 含义：品牌维度的标准商品/标准分类模板

因此可以理解为：

> **品牌菜品 = 以品牌 `lid` 作为 `shop_id` 的商品容器**

### 7.2 非品牌菜品（门店菜品）

门店菜品也不是另一套完全独立结构，而是：

- 表：仍然是 `sc_dish`、`sc_dish_type`
- 容器 ID：`shop_id = store_sid`
- 含义：门店实际经营使用的商品和分类

因此可以理解为：

> **门店菜品 = 以门店 `sid` 作为 `shop_id` 的商品容器**

### 7.3 两者本质区别

| 维度 | 品牌菜品 | 门店菜品 |
|---|---|---|
| 所属容器 | 品牌级容器 | 门店级容器 |
| `shop_id` 含义 | `brand_lid` | `store_sid` |
| 表结构 | `sc_dish` / `sc_dish_type` | `sc_dish` / `sc_dish_type` |
| 主要用途 | 品牌模板、品牌维度选品 | 门店经营、门店实际下单/展示 |
| 数据来源 | 品牌级商品镜像 | 门店级商品镜像或门店维护数据 |

**关键点：**

> 两者不是“表不同”，而是“同一组表中，`shop_id` 的语义不同”。

## 八、重要字段逻辑

这一节只总结真正会影响“品牌菜品 / 门店菜品”判断的字段。

### 8.1 `sc_brand.lid`

含义：

- 品牌主键
- 品牌级商品容器的核心标识

已验证现象：

- `康师傅.brand_lid = 159426136916301937`
- 使用这个值去查 `sc_dish_type.shop_id` 和 `sc_dish.shop_id`，都能命中品牌级分类和商品

因此：

> `brand_lid` 不只是品牌主数据主键，同时也是品牌级菜品容器 ID。

### 8.2 `sc_store.brand_code`

含义：

- 门店所属品牌编号
- 指向 `sc_brand.lid`

因此：

```text
sc_store.brand_code = sc_brand.lid
```

这是“品牌 -> 门店”的正规关系主线。

### 8.3 `sc_dish.shop_id` / `sc_dish_type.shop_id`

这是本次分析里最关键的字段。

它在不同场景下有两种含义：

- 当值命中 `brand_lid` 时：表示品牌级菜品容器
- 当值命中 `store_sid` 时：表示门店级菜品容器

因此：

> `shop_id` 在商品表里本质上不是单纯的“门店号”，而是“菜品容器 ID”。

### 8.4 `sc_dish.lid` / `sc_dish_type.lid`

含义：

- 商品主键
- 分类主键

它们用于标识具体商品、具体分类本身，不负责区分“品牌级”还是“门店级”。  
是否属于品牌级或门店级，要结合 `shop_id` 判断。

### 8.5 `sc_dish.brand_code` / `sc_dish_type.brand_code`

从实体上看，商品和分类表本身也保留了：

- `brand`
- `brand_code`

这说明商品、分类记录会附带品牌维度信息。  
但当前页面查询是否命中品牌级或门店级容器，**主要不是靠 `brand_code` 判断**，而是靠：

```text
shop_id = brand_lid 还是 shop_id = store_sid
```

所以 `brand_code` 更像是附属归属信息，而不是当前查询容器的主入口字段。

### 8.6 `sc_dish.no_sync_to_store`

该字段在商品表中存在，含义直观上是：

- 是否不同步到门店

虽然本轮未继续深挖它在发布链路里的全部使用逻辑，但从命名上可以合理推断：

> 它是品牌菜品是否允许向门店扩散/同步的重要控制字段之一。

这类字段更像是“同步策略开关”，而不是“当前容器层级判断字段”。

## 九、当前页面为什么能工作

现在可以准确解释页面行为：

1. 页面先加载品牌列表 `sc_brand`
2. 用户选中品牌 `康师傅`
3. 前端把品牌的 `lid` 放进请求里的 `sid`
4. 后端继续查 `pt_dish_type / pt_dish`
5. ShardingSphere 将其路由到 `sc_dish_type / sc_dish`
6. 由于库里本来就有：

```text
shop_id = brand_lid
```

这层品牌级容器数据，所以查询可以命中

因此这里不能再简单说成：

> “品牌 `lid` 被错误地当成了门店 `sid`”

更准确的表述是：

> 页面在复用字段名 `sid` 来承载“品牌级菜品容器 ID”，而这个 ID 恰好就是品牌 `lid`

## 十、品牌菜品如何同步到门店：当前能确认的边界

### 10.1 已确认的部分

当前可以确认：

- 品牌级商品容器存在于 `sc_dish / sc_dish_type`
- 门店级商品容器也存在于 `sc_dish / sc_dish_type`
- 门店和品牌之间存在正规关系：

```text
sc_store.brand_code -> sc_brand.lid
```

这说明门店级商品数据不可能完全脱离品牌主数据而独立存在，二者之间一定存在某种发布或同步过程。

### 10.2 `sc_store_and_product / sc_store_and_product_flow` 的真实职责

从实体字段可以确认：

`sc_store_and_product` 主要字段包括：

- `product_type`
- `product_out_code`
- `product_inner_code`
- `product_amount`
- `cost_amt`
- `pay_amt`
- `over_time`
- `disable`

`sc_store_and_product_flow` 主要字段包括：

- `product_code`
- `product_amount_before`
- `product_amount`
- `product_amount_after`
- `pay_price`
- `pay_amt`
- `pay_bill_id`
- `over_time_before`
- `over_time_after`
- `state`

这些字段共同说明：

> 这两张表描述的是“门店产品开通/续费/授权变化”，而不是“品牌菜品明细同步映射”。

因此它们与品牌菜品同步的关系更偏**能力层/产品层**，而不是直接存储“某道菜同步到某门店”的明细。

### 10.3 当前未直接确认的部分

本轮没有在代码中找到 `sc_company_dishs / sc_company_dishs_publish_job` 的实体或明确使用点，因此尚不能下结论说：

- 品牌菜品一定通过它们下发
- 或品牌菜品一定通过它们生成门店镜像

但从命名上看，这两张表依然是后续值得继续深挖的候选对象。

### 10.4 当前最稳妥的同步逻辑总结

基于目前证据，最保守且最可靠的结论是：

1. 品牌层先维护品牌级菜品容器
2. 门店层通过 `brand_code -> brand_lid` 与品牌建立归属关系
3. 系统中存在门店产品能力表 `sc_store_and_product*`，用于控制门店是否拥有某类产品能力
4. 门店级菜品容器与品牌级菜品容器并存，说明品牌商品到门店商品之间**至少存在同步/复制/发布结果**
5. 但“哪张表/哪段代码真正执行了菜品发布”这一点，本轮未完全锁定

换句话说：

> “品牌菜品同步到门店”这件事在数据结果上是成立的，但同步动作本身的调度入口和流水表，本轮还未完全收口到单一对象。

## 十一、门店数据与品牌数据的关系推断

系统里还存在以下表：

- `sc_store_and_product`
- `sc_store_and_product_flow`

并且它们在 Nacos 配置中同样映射到了 MyCat：

```yaml
sc_store_and_product:
  actual-data-nodes: mycat.sc_store_and_product
sc_store_and_product_flow:
  actual-data-nodes: mycat.sc_store_and_product_flow
```

这说明品牌级菜品与门店级菜品之间，大概率存在：

- 发布
- 下发
- 同步
- 流转

的中间过程。

虽然这次未继续深入校验这两张表数据，但从命名与配置上可以合理推断：

> 品牌菜品很可能是门店菜品的上游模板或中间镜像来源。

## 十二、为什么容易误判

这套设计最容易误导人的地方在于：

- 字段名一直叫 `sid`
- 大多数情况下，工程师会默认它是“门店 sid”
- 但在这条链路里，它有时表示门店 `sid`
- 有时又表示品牌级容器 ID（即 `brand_lid`）

因此：

- 只看接口名和字段名，容易误以为前端传错了
- 只看 `a_product.pt_*` 表，也容易误以为商品数据不存在
- 必须结合 ShardingSphere 的实际路由，才能得到正确结论

## 十三、表结构总结

### 13.1 `sc_brand`

职责：

- 品牌主数据表

关键字段：

- `company_id`：商户
- `shop_id`：品牌记录自带的 shop_id 字段，但不是本次页面品牌容器判断主依据
- `lmnid`：品牌主键，也是品牌级菜品容器 ID
- `name`：品牌名称

### 13.2 `sc_store`

职责：

- 门店主数据表

关键字段：

- `company_id`
- `shop_id`
- `lmnid`
- `name`
- `brand_code`：指向 `sc_brand.lid`

### 13.3 `sc_dish_type`

职责：

- 商品分类表
- 同时承载品牌级分类和门店级分类

关键字段：

- `company_id`
- `shop_id`
- `lmnid`
- `name`
- `superior_code`
- `brand_code`
- `support_mode`
- `order_idx`

判断规则：

- `shop_id = brand_lid`：品牌级分类
- `shop_id = store_sid`：门店级分类

### 13.4 `sc_dish`

职责：

- 商品表
- 同时承载品牌级商品和门店级商品

关键字段：

- `company_id`
- `shop_id`
- `lmnid`
- `id`
- `name`
- `dish_type_code`
- `brand_code`
- `disable`
- `no_sync_to_store`

判断规则：

- `shop_id = brand_lid`：品牌级商品
- `shop_id = store_sid`：门店级商品

### 13.5 `sc_store_and_product`

职责：

- 门店产品开通/授权主表

关键字段：

- `shop_id`
- `product_type`
- `product_out_code`
- `product_inner_code`
- `product_amount`
- `over_time`
- `disable`

### 13.6 `sc_store_and_product_flow`

职责：

- 门店产品开通/续费/变更流水表

关键字段：

- `shop_id`
- `product_type`
- `product_code`
- `product_amount_before/after`
- `pay_amt`
- `pay_bill_id`
- `over_time_before/after`
- `state`

## 十四、最终结论

本次排查最终确认：

1. 代码中的 `pt_dish / pt_dish_type` 运行时映射到 `gylregdb.sc_dish / sc_dish_type`
2. 品牌列表来自 `sc_brand`
3. 门店列表来自 `sc_store`
4. 品牌与门店关系通过 `sc_store.brand_code = sc_brand.lid` 建立
5. 品牌级菜品和门店级菜品共用 `sc_dish / sc_dish_type`
6. 其差异不在表，而在 `shop_id` 承载的容器 ID 语义：
   - 品牌级：`shop_id = brand_lid`
   - 门店级：`shop_id = store_sid`

所以当前页面的真实业务逻辑应表述为：

> 选择品牌后，页面不是在“误把品牌当门店”，而是在访问“品牌级菜品容器”；这个容器的主键值使用品牌 `lid`，但接口字段名仍沿用了 `sid`。

## 十五、后续建议

### 12.1 文档层

后续涉及商品/分类/品牌联调时，必须在文档中明确写出：

- `sid` 在部分场景并不等于门店 `sid`
- 还可能等于品牌级菜品容器 ID

### 12.2 代码层

如果未来要降低认知成本，建议在接口契约或服务层补充更明确的语义，例如：

- `containerId`
- `brandContainerId`
- `storeContainerId`

避免继续仅依赖 `sid` 这个历史字段名。

### 12.3 排查层

后续凡是遇到：

- 品牌选品
- 品牌分类
- 门店商品同步
- 商品容器差异

都优先查：

- ShardingSphere 路由
- `gylregdb.sc_dish / sc_dish_type`

不要先默认去 `a_product.pt_*` 查真实数据。
