# 商户表与 `shop_id` 字段说明

## 结论

当前项目中，商户相关数据并不是只有一张表，而是至少有两张核心表：

- `sc_merchant`：商户端业务模块实际使用的商户表
- `sys_merchant`：平台模块使用的商户表

如果问题是“商户端业务代码实际在查哪个商户表”，答案是 `sc_merchant`。

## 代码证据

### 1. `sc_merchant` 是商户端业务模块使用的商户表

`ScMerchant` 实体直接映射到 `sc_merchant`：

- 文件：`nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-dao/src/main/java/com/nms4cloud/biz/dao/entity/ScMerchant.java`
- 关键代码：

```java
@Table(value = "sc_merchant", onInsert = NmsInsertListener.class, dataSource = OLD_DATASOURCE)
public class ScMerchant extends BaseEntity {
```

`ScMerchantServicePlus` 的 `get/list/add/update` 都是围绕 `ScMerchant` 操作：

- 文件：`nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-service/src/main/java/com/nms4cloud/biz/service/ScMerchantServicePlus.java`

`ScMerchantController` 的接口路径虽然是 `/sys_merchant`，但底层调用的是 `ScMerchantServicePlus`：

- 文件：`nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-app/src/main/java/com/nms4cloud/biz/app/controller/ScMerchantController.java`

这说明商户端接口命名沿用了 `sys_merchant` 路径，但实际落表是 `sc_merchant`。

### 2. `sys_merchant` 是平台模块使用的商户表

`SysMerchant` 实体映射到 `sys_merchant`：

- 文件：`nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-dao/src/main/java/com/nms4cloud/platform/dao/entity/SysMerchant.java`
- 关键代码：

```java
@TableName(value = "sys_merchant", autoResultMap = true)
public class SysMerchant extends BaseEntity {
```

平台侧服务 `SysMerchantServicePlus` 也是围绕 `SysMerchant` 查询和维护数据：

- 文件：`nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-service/src/main/java/com/nms4cloud/platform/service/SysMerchantServicePlus.java`

## 为什么 `sc_merchant` 也有 `shop_id`

### 直接结论

`sc_merchant.shop_id` 不是多余字段，它是这套系统统一的多商户/多门店数据模型的一部分。  
更合理的理解是：

- `company_id` / `mid` 表示商户
- `shop_id` / `sid` 表示门店上下文
- 即使是商户主表，也保留 `shop_id`，用于兼容统一的数据隔离、缓存、配置和通用查询逻辑

### 证据与分析

#### 1. 项目规范要求大量表统一携带 `mid` 和 `sid`

项目说明中明确写了：

- 项目支持多商户架构
- 商户和门店隔离在数据层和业务层实现
- 每张表通过 `mid` 和 `sid` 字段实现数据隔离

对应文件：

- `CLAUDE.md`

关键描述：

```text
项目支持多商户架构，商户和门店隔离在数据层和业务层实现。每张表通过 mid（商户ID）和 sid（门店ID）字段实现数据隔离。
```

这意味着 `sid` 并不只属于门店表，系统希望大多数业务表都统一具备这两个维度。

#### 2. `sc_merchant` 模型本身就定义了 `company_id` 和 `shop_id`

在 `biz.pdma.json` 中，`sc_merchant` 表定义明确包含：

- `company_id`
- `shop_id`
- `lmnid`

并且还定义了唯一索引：

- `IDX_U_sc_merchant_COMPANY_SHOP_LmnID`

这说明设计阶段就已经把 `shop_id` 当作商户表的一部分，而不是临时补充字段。

#### 3. 新增商户时系统会直接生成一个 `sid`

在 `ScMerchantServicePlus.add` 中：

```java
entity.setSid(IdWorkerPlus.getId());
entity.setStatus(1);
entity.setDeleted((short) 0);
```

平台侧 `SysMerchantServicePlus.add` 里也有同样的处理：

```java
entity.setSid(IdWorkerPlus.getId());
```

这说明商户记录在创建时就会绑定一个 `sid`，不是后续偶然补上的。

#### 4. 平台侧存在“根据 `mid` 查询 `sid`”的能力

`SysMerchantServicePlus` 提供了 `getSidByMid`：

```java
query.lambda().select(SysMerchant::getSid).eq(SysMerchant::getMid, request.getMid());
```

并且平台侧其他逻辑会调用这个能力。  
这说明商户表上的 `sid` 在系统里是有实际用途的，不是历史残留字段而已。

#### 5. 更像“商户默认门店 / 主门店 / 商户级上下文门店”

从现有代码看，`sc_merchant.shop_id` 最合理的业务语义，不是“商户拥有的全部门店”，而更像下面三种之一：

- 商户默认门店
- 商户主门店
- 商户级配置和缓存所依赖的门店上下文

当前代码里没有看到一段显式注释直接写明“`sc_merchant.shop_id` = 主门店”，所以这部分属于基于代码行为的推断。  
但结合以下事实，这个推断是成立的：

- 商户创建时立即生成 `sid`
- 系统支持通过 `mid` 直接反查 `sid`
- 全系统很多通用逻辑都默认依赖 `mid + sid`

## 与门店表的关系

门店主表本身是 `sc_store` / `sys_store` 这类表，商户表不是门店表。  
因此 `sc_merchant.shop_id` 更适合理解为“商户记录上挂的一个门店标识”，而不是“把商户表当门店表使用”。

平台侧 `SysStoreServicePlus` 中新增门店时会独立生成门店自己的 `sid`：

```java
entity.setSid(IdWorkerPlus.getId());
entity.setLid(entity.getSid());
```

这也进一步说明：

- 门店有自己的独立记录
- 商户表上的 `sid` 只是商户记录携带的门店上下文标识

## 最终结论

可以把当前项目的商户表理解为：

- 商户端业务看 `sc_merchant`
- 平台侧看 `sys_merchant`
- 两张商户表都带 `sid/shop_id`

`sc_merchant` 之所以也有 `shop_id`，本质上是为了适配项目统一的 `mid + sid` 多租户/多门店模型。  
在业务语义上，它更像商户的默认门店或主门店标识，而不是说商户表本身就是门店表。

## 参考文件

- `D:\mywork\nms4cloud\CLAUDE.md`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScMerchant.java`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-service\src\main\java\com\nms4cloud\biz\service\ScMerchantServicePlus.java`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-app\src\main\java\com\nms4cloud\biz\app\controller\ScMerchantController.java`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-app\src\test\resources\biz.pdma.json`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\SysMerchant.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-service\src\main\java\com\nms4cloud\platform\service\SysMerchantServicePlus.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-service\src\main\java\com\nms4cloud\platform\service\SysStoreServicePlus.java`
