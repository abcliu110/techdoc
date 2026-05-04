# 品牌选择后按 sid 查询商品分类逻辑分析

## 一、摘要

本次排查最终确认：

1. 页面“选择品牌”后，后续商品分类/商品请求里传入的 `sid`，实际是**品牌 `lid`**
2. 这并不只是前端单纯传错参数
3. 在当前系统中，`pt_dish / pt_dish_type` 运行时并不直接落在 `a_product.pt_*` 表，而是通过 ShardingSphere 路由到 **MyCat 逻辑库 `gylregdb`** 中的：
   - `sc_dish`
   - `sc_dish_type`
4. 这些老表里不只存在“品牌/门店”两种菜品容器，当前代码还能确认一层**集团菜谱方案容器**：
   - **品牌菜品库容器**：`shop_id = brand_lid`
   - **集团菜谱方案容器**：`shop_id = pos_group_dish_book.lid`
   - **门店菜品容器**：`shop_id = store_sid`
5. 当前页面在“按品牌选商品”场景下，实际上是在访问**品牌菜品库容器**

一句话总结：

> 品牌菜品库、集团菜谱方案、门店菜品共用 `sc_dish / sc_dish_type` 这组物理表，差异不在表名，而在 `shop_id` 所承载的容器 ID 含义。

## 二、问题背景

页面“选择商品”时，网络请求大致表现为：

1. 先请求品牌列表：`/biz/sys_brand/list/`
2. 再请求商品分类小类：`/merchant/pt_dish_type/list_small`
3. 再请求商品列表：`/merchant/.../listAll`

本次重点是解释：

- 为什么前端选择品牌后会传一个名为 `sid` 的字段
- 为什么这个值不是门店 `sid` 也能查到分类和商品
- 品牌菜品库、集团菜谱方案、门店菜品在数据库中的真实组织方式是什么

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

### 6.3 品牌菜品库容器验证

继续在 `3308 / gylregdb.sc_dish_type`、`sc_dish` 中直接按：

```text
company_id = 159411180237043484
shop_id    = 159426136916301937   -- 即康师傅品牌 lid
```

查询，得到结果：

- `sc_dish_type`：当前有 7 条分类数据，其中 `list_small` 默认 POS 条件下会返回 3 条小类
- `sc_dish`：有 10 条商品数据

这说明：

> 系统中存在一层“品牌菜品库容器”，其容器主键值就写在 `shop_id` 字段里，并且这个值等于品牌 `lid`

### 6.4 门店级菜品容器验证

再使用门店 `康师傅-红茶` 的门店 `sid = 1746815992676028417` 去查：

- `sc_dish_type`：当前也有 7 条分类，其中 `list_small` 默认 POS 条件下会返回 3 条小类
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

> 门店级菜品数据和品牌菜品库数据共用同一组表，只是 `shop_id` 的值换成了门店 `sid`

## 七、品牌菜品、集团菜谱与门店菜品的设计逻辑

### 7.1 品牌菜品库

品牌菜品库不是单独一张“品牌菜品主表”，而是用以下方式建模：

- 表：`sc_dish`、`sc_dish_type`
- 容器 ID：`shop_id = brand_lid`
- 含义：品牌维度的标准商品/标准分类模板

因此可以理解为：

> **品牌菜品库 = 以品牌 `lid` 作为 `shop_id` 的商品容器**

### 7.2 集团菜谱方案

当前代码里还存在 `pos_group_dish_book` / `pos_group_dish_book_release` 这一层。它保存的是集团菜谱方案的元数据和发布记录，而菜谱方案里的菜品明细仍然落在 `sc_dish / sc_dish_type`。

- 元数据表：`pos_group_dish_book`
- 发布记录表：`pos_group_dish_book_release`
- 菜品明细表：仍然是 `sc_dish`、`sc_dish_type`
- 容器 ID：`shop_id = pos_group_dish_book.lid`
- 品牌归属：`pos_group_dish_book.brand_lid = sc_brand.lid`
- 含义：某个品牌下可发布到一个或多个门店的集团菜谱方案

因此可以理解为：

> **集团菜谱方案 = 以菜谱方案 `lid` 作为 `shop_id` 的商品容器，并通过 `brand_lid` 归属到品牌**

### 7.3 门店菜品

门店菜品也不是另一套完全独立结构，而是：

- 表：仍然是 `sc_dish`、`sc_dish_type`
- 容器 ID：`shop_id = store_sid`
- 含义：门店实际经营使用的商品和分类

因此可以理解为：

> **门店菜品 = 以门店 `sid` 作为 `shop_id` 的商品容器**

### 7.4 三者本质区别

| 维度 | 品牌菜品库 | 集团菜谱方案 | 门店菜品 |
|---|---|---|---|
| 所属容器 | 品牌级容器 | 菜谱方案容器 | 门店级容器 |
| `shop_id` 含义 | `brand_lid` | `pos_group_dish_book.lid` | `store_sid` |
| 表结构 | `sc_dish` / `sc_dish_type` | `sc_dish` / `sc_dish_type` | `sc_dish` / `sc_dish_type` |
| 主要用途 | 品牌维度选品、品牌菜品库 | 集团菜谱方案、发布模板 | 门店经营、门店实际下单/展示 |
| 数据来源 | 门店同步或品牌维护 | 从品牌菜品库导入/发布 | 集团菜谱发布或门店维护 |

**关键点：**

> 三者不是“表不同”，而是“同一组表中，`shop_id` 的语义不同”；集团菜谱方案还需要结合 `pos_group_dish_book.brand_lid` 判断品牌归属。

## 八、重要字段逻辑

这一节只总结真正会影响“品牌菜品库 / 集团菜谱方案 / 门店菜品”判断的字段。

### 8.1 `sc_brand.lid`

含义：

- 品牌主键
- 品牌菜品库容器的核心标识

已验证现象：

- `康师傅.brand_lid = 159426136916301937`
- 使用这个值去查 `sc_dish_type.shop_id` 和 `sc_dish.shop_id`，都能命中品牌菜品库分类和商品

因此：

> `brand_lid` 不只是品牌主数据主键，同时也是品牌菜品库容器 ID。

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

它在不同场景下至少有三种含义：

- 当值命中 `brand_lid` 时：表示品牌菜品库容器
- 当值命中 `pos_group_dish_book.lid` 时：表示集团菜谱方案容器
- 当值命中 `store_sid` 时：表示门店级菜品容器

因此：

> `shop_id` 在商品表里本质上不是单纯的“门店号”，而是“菜品容器 ID”。

### 8.4 `sc_dish.lid` / `sc_dish_type.lid`

含义：

- 商品主键
- 分类主键

它们用于标识具体商品、具体分类本身，不负责区分“品牌级”“集团菜谱方案级”还是“门店级”。

是否属于哪个容器，要结合 `shop_id` 判断。

### 8.5 `sc_dish.brand_code` / `sc_dish_type.brand_code`

从实体上看，商品和分类表本身也保留了：

- `brand`
- `brand_code`

这说明商品、分类记录会附带品牌维度信息。  
但当前页面查询是否命中品牌菜品库、集团菜谱方案或门店级容器，**主要不是靠 `brand_code` 判断**，而是靠：

```text
shop_id = brand_lid / pos_group_dish_book.lid / store_sid
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

这层品牌菜品库容器数据，所以查询可以命中

因此这里不能再简单说成：

> “品牌 `lid` 被错误地当成了门店 `sid`”

更准确的表述是：

> 页面在复用字段名 `sid` 来承载“品牌菜品库容器 ID”，而这个 ID 恰好就是品牌 `lid`

## 十、品牌菜品库、集团菜谱与门店菜品的同步链路

### 10.1 已确认的容器层级

当前可以确认：

- 品牌菜品库容器存在于 `sc_dish / sc_dish_type`，入口 ID 是 `sc_brand.lid`
- 集团菜谱方案容器也存在于 `sc_dish / sc_dish_type`，入口 ID 是 `pos_group_dish_book.lid`
- 门店菜品容器也存在于 `sc_dish / sc_dish_type`，入口 ID 是 `sc_store.shop_id`
- 门店和品牌之间存在正规关系：

```text
sc_store.brand_code -> sc_brand.lid
pos_group_dish_book.brand_lid -> sc_brand.lid
```

因此不能只把关系理解为“品牌菜品 -> 门店菜品”。更完整的模型是：

```text
门店菜品容器
   -> 可全量复制到品牌菜品库容器
品牌菜品库容器
   -> 可导入/发布到集团菜谱方案容器
集团菜谱方案容器
   -> 可按发布规则合并、替换、删除到门店菜品容器
```

### 10.2 门店菜品同步到品牌菜品库

代码中已经能确认入口：

- `PtDishTypeServicePlus.syncToBrand(...)`
- `GroupDishBookReleaseService.syncStoreToBrand(mid, storeSid, brandSid)`

其逻辑是：

1. 校验 `storeSid`、`brandSid` 都存在且不能相同
2. 校验品牌库 `brandSid` 下不能已有商品分类
3. 查询 `storeSid` 下的菜品、分类、单位、套餐、做法、口味等数据
4. 克隆这些数据并统一改成 `sid = brandSid`
5. 保存到品牌菜品库容器

因此这条链路可以明确表述为：

> **门店菜品 -> 品牌菜品库** 是全量复制链路，复制后的品牌库明细仍然存入 `sc_dish / sc_dish_type` 等商品表，只是 `shop_id` 改成品牌 `lid`。

### 10.3 品牌菜品库发布到集团菜谱方案

代码中已经能确认入口：

- `GroupDishBookReleaseService.release2Book(...)`
- `PosGroupDishBook`
- `pos_group_dish_book`

其逻辑是：

1. 请求里的 `sid` 必须能在 `sc_brand.lid` 查到品牌
2. 目标菜谱方案必须属于该品牌，即 `pos_group_dish_book.brand_lid = sid`
3. 从品牌菜品库容器读取商品明细：`queryDataByDishLids(mid, sid, dishLids)`
4. 按规则保存到目标菜谱方案容器：`shop_id = pos_group_dish_book.lid`

因此这条链路可以明确表述为：

> **品牌菜品库 -> 集团菜谱方案** 是品牌内选菜发布链路，集团菜谱方案的商品明细仍然在 `sc_dish / sc_dish_type` 中，只是 `shop_id` 改成菜谱方案 `lid`。

### 10.4 集团菜谱方案发布到门店

代码中已经能确认入口：

- `pos_group_dish_book_release`
- `DishBookReleaseTask`
- `PublishDishConsumer`
- `GroupDishBookReleaseService.release(...)`

其逻辑是：

1. 发布记录里保存 `book_lid`、`brand_lid`、`store_lids`、发布规则
2. 定时任务扫描未完成发布记录并发送 `PUBLISH_DISH` 消息
3. 消费者调用 `release(...)`
4. `release(...)` 读取菜谱方案容器的数据，并按 `store_lids` 发布到一个或多个门店容器
5. 发布规则支持合并、仅更新相同菜品、完全替换、仅删除相同菜品等

因此这条链路可以明确表述为：

> **集团菜谱方案 -> 门店菜品** 是规则化发布链路，最终仍然落回门店自己的 `shop_id = store_sid` 容器。

### 10.5 `sc_store_and_product / sc_store_and_product_flow` 的真实职责

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

> 这两张表描述的是“门店产品开通/续费/授权变化”，而不是“菜品明细同步映射”。

因此它们与菜品同步的关系更偏**能力层/产品层**，不是直接存储“某道菜同步到某门店”的明细。

### 10.6 当前最稳妥的同步逻辑总结

基于目前证据，最稳妥的结论是：

1. 品牌菜品库、集团菜谱方案、门店菜品三者共用 `sc_dish / sc_dish_type`
2. 三者差异主要靠 `shop_id` 表达容器 ID
3. `sc_store.brand_code` 和 `pos_group_dish_book.brand_lid` 都指向 `sc_brand.lid`
4. 门店菜品可以全量复制到品牌菜品库
5. 品牌菜品库可以发布到集团菜谱方案
6. 集团菜谱方案可以按规则发布到门店

换句话说：

> “集团菜品和门店菜品的关系”不是直接靠一张映射表维护，而是通过“同表不同容器 + 菜谱方案发布流程”来实现。

### 10.7 系统实际如何处理“品牌菜品”和“非品牌菜品”

如果从代码实现角度看，系统并没有给“品牌菜品”和“非品牌菜品”设计两套完全独立的 Service 或两套完全独立的表结构。系统真正的处理方式更接近：

1. 先把所有菜品都当成 `PtDish / PtDishType` 这一套统一结构的数据
2. 再通过 `mid + sid(shop_id)` 判断当前操作落在哪个容器
3. 最后由同步/发布流程决定这些数据怎样在品牌、菜谱方案、门店之间流动

具体可以拆成四层理解。

#### 10.7.1 查询和 CRUD 层：先按容器查，不先按“品牌/非品牌”分支

在 `PtDishServicePlus`、`PtDishTypeServicePlus` 这类商品服务里，核心查询条件几乎都是：

```text
mid + sid
```

也就是说：

- 当 `sid = brand_lid` 时，查到的是品牌菜品库
- 当 `sid = pos_group_dish_book.lid` 时，查到的是集团菜谱方案
- 当 `sid = store_sid` 时，查到的是门店菜品

所以系统并不是先问“这是不是品牌菜品”，而是先问“你现在在操作哪个容器”。

#### 10.7.2 非品牌菜品在系统里的真实含义

业务口径里常说的“非品牌菜品”，如果对应到当前实现，最接近的其实是：

> **落在门店容器里的菜品**

这类菜品有两种来源：

- 从品牌菜品库或集团菜谱方案发布下来
- 直接在门店容器内新增、维护

一旦它们落在 `shop_id = store_sid` 这个容器里，后续点餐、门店展示、门店套餐、门店单位、门店做法等逻辑，都是按门店菜品处理，不会继续保留“它最初是不是品牌菜品”的强运行时分支。

换句话说：

> “非品牌菜品”在当前系统里更像是**运行位置概念**，不是一个单独的数据类型枚举。

#### 10.7.3 品牌模式 / 非门店模式：会有少量跨容器联动

虽然大多数增删改查都是“只改当前容器”，但代码里仍保留了少量“非门店模式”的特殊处理。

例如在 `PtDishServicePlus` 的更新逻辑里，有一段明确写着：

- 如果当前 `sid` 不是门店 ID
- 那么它属于“品牌模式、菜谱模式（也就是非门店模式）”
- 此时会把 `department / departmentCode` 同步到其他相同 `lid` 的记录

这说明系统内部依然承认：

- **门店模式**
- **非门店模式（品牌库 / 菜谱方案）**

这两个大类在少量字段联动上存在区别。

但同一段代码后面又有注释说明：

> 现在改成任何时候都只更新门店和品牌自己的数据

因此当前实现的总体趋势是：

> **尽量收敛为“每个容器只维护自己的数据”，只在个别场景保留有限的跨容器联动。**

#### 10.7.4 菜谱方案模式：有些数据会回退到品牌侧读取

集团菜谱方案虽然有自己的菜品容器，但并不是所有周边数据都完全独立。

例如 `PosDeptServicePlus.list(...)` 里，如果传入的 `sid` 实际上是菜谱方案 `lid`，代码会先通过 `GroupDishBookHook` 找到对应的 `brandLid`，再用这个 `brandLid` 去查部门数据。

这说明：

- 菜谱方案自己的菜品明细可以独立存在
- 但有些附属主数据仍然被视为“品牌侧数据”，查询时会回退到品牌容器

因此更准确的理解是：

> **集团菜谱方案是“菜品明细独立、部分主数据继承品牌”的中间层，而不是一个完全自治的第三套主数据系统。**

## 十一、为什么容易误判

这套设计最容易误导人的地方在于：

- 字段名一直叫 `sid`
- 大多数情况下，工程师会默认它是“门店 sid”
- 但在这条链路里，它有时表示门店 `sid`
- 有时又表示品牌菜品库容器 ID（即 `brand_lid`）
- 在集团菜谱方案链路里，它还可能表示菜谱方案 `lid`

因此：

- 只看接口名和字段名，容易误以为前端传错了
- 只看 `a_product.pt_*` 表，也容易误以为商品数据不存在
- 必须结合 ShardingSphere 的实际路由、`pos_group_dish_book` 元数据和 `shop_id` 容器语义，才能得到正确结论

## 十二、表结构总结

### 12.1 `sc_brand`

职责：

- 品牌主数据表

关键字段：

- `company_id`：商户
- `shop_id`：品牌记录自带的 shop_id 字段，但不是本次页面品牌容器判断主依据
- `lmnid`：品牌主键，也是品牌菜品库容器 ID
- `name`：品牌名称

### 12.2 `sc_store`

职责：

- 门店主数据表

关键字段：

- `company_id`
- `shop_id`
- `lmnid`
- `name`
- `brand_code`：指向 `sc_brand.lid`

### 12.3 `pos_group_dish_book`

职责：

- 集团菜谱方案主表

关键字段：

- `mid`
- `sid`
- `lid`：菜谱方案主键，也是集团菜谱方案容器 ID
- `name`
- `brand_lid`：指向 `sc_brand.lid`
- `store_lids`：可发布的门店范围
- `status_`
- `type_`

### 12.4 `pos_group_dish_book_release`

职责：

- 集团菜谱方案发布记录表

关键字段：

- `mid`
- `sid`
- `lid`
- `book_lid`：指向 `pos_group_dish_book.lid`
- `brand_lid`：指向 `sc_brand.lid`
- `store_lids`：本次发布目标门店
- `book_release_rule`
- `dish_release_rule`
- `release_time`
- `done`

### 12.5 `sc_dish_type`

职责：

- 商品分类表
- 同时承载品牌菜品库分类、集团菜谱方案分类和门店级分类

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

- `shop_id = brand_lid`：品牌菜品库分类
- `shop_id = pos_group_dish_book.lid`：集团菜谱方案分类
- `shop_id = store_sid`：门店级分类

### 12.6 `sc_dish`

职责：

- 商品表
- 同时承载品牌菜品库商品、集团菜谱方案商品和门店级商品

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

- `shop_id = brand_lid`：品牌菜品库商品
- `shop_id = pos_group_dish_book.lid`：集团菜谱方案商品
- `shop_id = store_sid`：门店级商品

### 12.7 `sc_store_and_product`

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

### 12.8 `sc_store_and_product_flow`

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

## 十三、最终结论

本次排查最终确认：

1. 代码中的 `pt_dish / pt_dish_type` 运行时映射到 `gylregdb.sc_dish / sc_dish_type`
2. 品牌列表来自 `sc_brand`
3. 门店列表来自 `sc_store`
4. 品牌与门店关系通过 `sc_store.brand_code = sc_brand.lid` 建立
5. 集团菜谱方案来自 `pos_group_dish_book`，发布记录来自 `pos_group_dish_book_release`
6. 品牌菜品库、集团菜谱方案、门店菜品共用 `sc_dish / sc_dish_type`
7. 其差异不在表，而在 `shop_id` 承载的容器 ID 语义：
   - 品牌菜品库：`shop_id = brand_lid`
   - 集团菜谱方案：`shop_id = pos_group_dish_book.lid`
   - 门店级：`shop_id = store_sid`
8. 当前代码已经能确认三段链路：
   - 门店菜品全量复制到品牌菜品库
   - 品牌菜品库发布到集团菜谱方案
   - 集团菜谱方案按规则发布到门店
9. 系统处理“品牌菜品”和“非品牌菜品”时，并不是先按布尔概念分两套逻辑，而是先按 `sid` 所属容器处理；所谓“非品牌菜品”，在当前实现里更接近“落在门店容器里的菜品”

所以当前页面的真实业务逻辑应表述为：

> 选择品牌后，页面不是在“误把品牌当门店”，而是在访问“品牌菜品库容器”；这个容器的主键值使用品牌 `lid`，但接口字段名仍沿用了 `sid`。如果后续进入集团菜谱发布链路，还需要继续区分 `sid` 是品牌 `lid`、菜谱方案 `lid`，还是门店 `sid`。

## 十四、后续建议

### 14.1 文档层

后续涉及商品/分类/品牌联调时，必须在文档中明确写出：

- `sid` 在部分场景并不等于门店 `sid`
- 还可能等于品牌菜品库容器 ID
- 在集团菜谱方案链路里，还可能等于 `pos_group_dish_book.lid`
- “品牌菜品 / 非品牌菜品”首先是容器位置差异，不是两张完全不同的业务主表

### 14.2 代码层

如果未来要降低认知成本，建议在接口契约或服务层补充更明确的语义，例如：

- `containerId`
- `brandContainerId`
- `dishBookContainerId`
- `storeContainerId`

避免继续仅依赖 `sid` 这个历史字段名。

### 14.3 排查层

后续凡是遇到：

- 品牌选品
- 品牌分类
- 集团菜谱方案
- 门店商品同步
- 品牌菜品 / 非品牌菜品差异
- 商品容器差异

都优先查：

- ShardingSphere 路由
- `gylregdb.sc_dish / sc_dish_type`
- `pos_group_dish_book / pos_group_dish_book_release`

不要先默认去 `a_product.pt_*` 查真实数据。
