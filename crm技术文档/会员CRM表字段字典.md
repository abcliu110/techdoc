# 会员 CRM 表字段字典

> 口径：以 `字段的映射关系.md` 中的表映射为主清单，补充本地 POS `nms` 中与会员消费、积分、赠券、会员价相关的新增表。
>
> 字段来源优先级：`information_schema` 注释 > SQL DDL 注释 > Java 实体注释 > 通用字段词典/字段名推断。
>
> “推断”表示源码、DDL 或数据库注释中未直接给出中文解释，含义按字段名和表业务域推断，后续应由业务或开发确认。

## 生成统计

- 表清单数量：313
- 已生成字段明细的表：313
- 未找到字段来源的表：0
- 字段总数：9105
- 直接来自 DB/DDL/实体注释的字段：5347
- 由通用字段词典补充的字段：1045
- 按字段名推断的字段：2713
- SQL DDL 覆盖表数：426
- Java 实体覆盖表数：348

## 字段明细

### gylregdb

#### `biz_business_hours`

- 真实表：`sc_business_hours`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：营业时段。
- 表含义：营业时段。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizBusinessHours.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `begin_time` | `datetime` | 开始时间 | 业务基础资料业务中的开始时间。 | YES | NULL | 推断 |
| `end_time` | `datetime` | 结束时间 | 业务基础资料业务中的结束时间。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务基础资料业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `Disable_wct` | `tinyint` | disablewct | 业务基础资料业务中的disablewct。 | YES | NULL | 推断 |
| `book_period` | `text` | 预订时段 | 预订时段 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `book_def_time` | `datetime` | bookdef时间 | 业务基础资料业务中的bookdef时间。 |  |  | 推断 |
| `disable_wct` | `tinyint(1)` | disablewct | 业务基础资料业务中的disablewct。 |  |  | 推断 |

#### `biz_department`

- 真实表：`sc_department`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务基础资料
- 表含义：业务基础资料相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizDepartment.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `type_` | `varchar(255)` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `brand` | `varchar(255)` | brand | 业务基础资料业务中的brand。 | YES | NULL | 推断 |
| `brand_code` | `varchar(255)` | brandcode | 业务基础资料业务对象的brandcode。 | YES | NULL | 推断 |
| `produce` | `varchar(255)` | produce | 业务基础资料业务中的produce。 | YES | NULL | 推断 |
| `produce_code` | `varchar(255)` | producecode | 业务基础资料业务对象的producecode。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 业务基础资料业务中的说明。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务基础资料业务中的disable。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 业务基础资料业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `biz_discount`

- 真实表：`sc_mall_discount`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：折扣类型。
- 表含义：折扣类型。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizDiscount.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `discount_rate` | `decimal(19,10)` | 折扣比例 | 业务基础资料业务中的折扣比例。 | YES | NULL | 推断 |
| `custom_discount` | `tinyint` | custom折扣 | 业务基础资料业务中的custom折扣。 | YES | NULL | 推断 |
| `ENABLE` | `tinyint` | enable | 标记业务基础资料业务是否启用或满足enable条件。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `update_time` | `datetime` | update时间 | 业务基础资料业务中的update时间。 | YES | NULL | 推断 |
| `card_type_lids` | `text` | 会员卡类型lids | 会员卡类型lids | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `enable` | `tinyint(1)` | 启用标记 | 是否启用该记录。 |  |  | 通用字段 |

#### `biz_discount_dish`

- 真实表：`sc_mall_discount_dish`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：参与打折的商品。
- 表含义：参与打折的商品。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizDiscountDish.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `dish_code` | `varchar(255)` | 菜品lid | 菜品lid | YES | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(255)` | 菜品name | 业务基础资料业务对象的菜品name。 | YES | NULL | 推断 |
| `discount_code` | `bigint` | 折扣lid | 折扣lid | YES | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(64)` | 单位名称 | 单位名称 | YES | NULL | DB/DDL/实体注释 |
| `discount_rate` | `decimal(10, 4)` | 菜品折扣率 | 菜品折扣率：0.0000-1.0000，如 0.85 表示 85 折 | YES | NULL | DB/DDL/实体注释 |
| `use_custom_rate` | `tinyint` | 是否使用自定义折扣率 | 是否使用自定义折扣率：0-否 (使用默认),1-是 | YES | 0 | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `biz_discount_tbl_type`

- 真实表：`sc_mall_discount_tbl_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：桌台自动折扣。
- 表含义：桌台自动折扣。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizDiscountTblType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `tbl_code` | `varchar(255)` | 桌台code | 业务基础资料业务对象的桌台code。 | YES | NULL | 推断 |
| `tbl_name` | `varchar(255)` | 桌台name | 业务基础资料业务对象的桌台name。 | YES | NULL | 推断 |
| `discount_code` | `varchar(255)` | 折扣code | 业务基础资料业务对象的折扣code。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `biz_gift_reason`

- 真实表：`sc_mall_gift_dish_reason`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：赠送原因。
- 表含义：赠送原因。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizGiftReason.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `update_time` | `datetime` | update时间 | 业务基础资料业务中的update时间。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `biz_income`

- 真实表：`sc_income`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：收入科目。
- 表含义：收入科目。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizIncome.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `creator` | `varchar(255)` | creator | 业务基础资料业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 业务基础资料业务中的说明。 | YES | NULL | 推断 |
| `editor` | `varchar(255)` | editor | 业务基础资料业务中的editor。 | YES | NULL | 推断 |
| `edit_time` | `datetime` | edit时间 | 业务基础资料业务中的edit时间。 | YES | NULL | 推断 |
| `source` | `varchar(255)` | 来源 | 业务基础资料业务中的来源。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务基础资料业务中的disable。 | YES | NULL | 推断 |
| `income_type` | `varchar(255)` | income类型 | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `income_type_code` | `varchar(255)` | income类型code | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `biz_income_type`

- 真实表：`sc_income_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：收入科目分类。
- 表含义：收入科目分类。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizIncomeType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

### a_biz

#### `biz_key_value`

- 真实表：`biz_key_value`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：键值对表
- 表含义：键值对表
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizKeyValue.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `content` | `text` | 内容 | 内容 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `biz_pay_way`

- 真实表：`sc_pay_way`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：支付方式。
- 表含义：支付方式。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizPayWay.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `pay_way_type` | `varchar(255)` | 支付way类型 | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `pay_way_type_code` | `varchar(255)` | 支付way类型code | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `src` | `varchar(255)` | src | 业务基础资料业务中的src。 | YES | NULL | 推断 |
| `actual_income` | `tinyint` | actualincome | 业务基础资料业务中的actualincome。 | YES | NULL | 推断 |
| `can_integral` | `tinyint` | canintegral | 业务基础资料业务中的canintegral。 | YES | NULL | 推断 |
| `can_invoicing` | `tinyint` | caninvoicing | 业务基础资料业务中的caninvoicing。 | YES | NULL | 推断 |
| `physical_certificate` | `tinyint` | physicalcertificate | 业务基础资料业务中的physicalcertificate。 | YES | NULL | 推断 |
| `show_in_pos` | `tinyint` | showinpos | 业务基础资料业务中的showinpos。 | YES | NULL | 推断 |
| `show_in_crm` | `tinyint` | showinCRM | 业务基础资料业务中的showinCRM。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务基础资料业务中的disable。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 业务基础资料业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `modified_by` | `varchar(255)` | modified人 | 业务基础资料业务中的modified人。 | YES | NULL | 推断 |
| `modified_time` | `datetime` | modified时间 | 业务基础资料业务中的modified时间。 | YES | NULL | 推断 |
| `show_order` | `int` | show订单 | 业务基础资料业务中的show订单。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺name | 业务基础资料业务对象的店铺name。 | YES | NULL | 推断 |
| `Type_` | `varchar(255)` | 类型 | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `Exchangable` | `tinyint` | exchangable | 业务基础资料业务中的exchangable。 | YES | NULL | 推断 |
| `cash_box` | `tinyint(1)` | 弹出钱箱 | 弹出钱箱 | YES | 0 | DB/DDL/实体注释 |
| `voice_broadcast` | `tinyint(1)` | 语音播报 | 语音播报 | YES | NULL | DB/DDL/实体注释 |
| `actual_income_rate` | `decimal(24,6)` | 实收率 | 实收率 | YES | NULL | DB/DDL/实体注释 |
| `profit_department` | `text` | 利润所属部门 | 利润所属部门 | YES | NULL | DB/DDL/实体注释 |
| `actual_amount` | `decimal(19,10)` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `face_value` | `decimal(19,10)` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `points_rate` | `decimal(19,10)` | 积分抵现率 | 积分抵现率 | YES | NULL | DB/DDL/实体注释 |
| `show_in_phone` | `tinyint(1)` | 在phone显示 | 在phone显示 | YES | NULL | DB/DDL/实体注释 |
| `show_order_in_phone` | `int` | phone显示顺序 | phone显示顺序 | YES | NULL | DB/DDL/实体注释 |
| `points_bill_rate` | `decimal(24,10)` | 积分最多抵扣账单的比率 | 积分最多抵扣账单的比率 | YES | NULL | DB/DDL/实体注释 |
| `fraction_digit` | `int` | 自动抹零小数位数 | 自动抹零小数位数 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `type` | `varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `exchangable` | `tinyint(1)` | exchangable | 业务基础资料业务中的exchangable。 |  |  | 推断 |

### a_biz

#### `biz_receipt_bind`

- 真实表：`biz_receipt_bind`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：业务接收绑定设置
- 表含义：业务接收绑定设置
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizReceiptBind.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `user_lid` | `bigint` | 用户lid | 用户lid | NO | NULL | DB/DDL/实体注释 |
| `user_id` | `varchar(90)` | 用户id | 用户id | NO | NULL | DB/DDL/实体注释 |
| `user_name` | `varchar(90)` | 用户名称 | 用户名称 | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(90)` | 公众号openId | 公众号openId | NO | NULL | DB/DDL/实体注释 |
| `receipt_type` | `int` | 接收业务类型 | 接收业务类型 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `biz_retreat_reason`

- 真实表：`sc_mall_retreat_dish_reason`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：退货原因。
- 表含义：退货原因。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizRetreatReason.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `update_time` | `datetime` | update时间 | 业务基础资料业务中的update时间。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

### a_biz

#### `biz_shop_group`

- 真实表：`biz_shop_group`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：门店分组
- 表含义：门店分组
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizShopGroup.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `shop_json` | `text` | 门店列表 | 门店列表 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `biz_sms_config`

- 真实表：`biz_sms_config`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：门店的短信网关配置
- 表含义：门店的短信网关配置
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizSmsConfig.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 门店名 | 门店名 | YES | NULL | DB/DDL/实体注释 |
| `sign` | `varchar(255)` | 签名 | 签名 | YES | NULL | DB/DDL/实体注释 |
| `code` | `varchar(255)` | 账号 | 账号 | YES | NULL | DB/DDL/实体注释 |
| `user` | `varchar(255)` | 用户名 | 用户名 | YES | NULL | DB/DDL/实体注释 |
| `pwd` | `varchar(255)` | 密码 | 密码 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `channel` | `tinyint/varchar` | 渠道 | 业务基础资料业务中的渠道。 |  |  | 推断 |
| `extra_info` | `varchar` | extrainfo | 业务基础资料业务中的extrainfo。 |  |  | 推断 |

### gylregdb

#### `biz_sms_msg_content`

- 真实表：`sms_msg_content`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：短信打印样式内容
- 表含义：短信打印样式内容
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizSmsMsgContent.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `msg_style` | `varchar(128)` | 样式类型 | 样式类型 | YES | NULL | DB/DDL/实体注释 |
| `msg_style_code` | `bigint` | 样式类型编号 | 样式类型编号 | YES | NULL | DB/DDL/实体注释 |
| `content_type` | `varchar(64)` | 样式内容类型 | 样式内容类型 | YES | NULL | DB/DDL/实体注释 |
| `print_content` | `varchar(4096)` | 样式内容 | 样式内容 | YES | NULL | DB/DDL/实体注释 |
| `condition_` | `varchar(255)` | 条件 | 条件 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `condition` | `varchar` | condition | 业务基础资料业务中的condition。 |  |  | 推断 |

#### `biz_sms_msg_style`

- 真实表：`sms_msg_style`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：短信打印样式
- 表含义：短信打印样式
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizSmsMsgStyle.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 业务基础资料业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `type_` | `varchar(64)` | 样式类型 | 样式类型 | YES | NULL | DB/DDL/实体注释 |
| `source_string` | `varchar(4096)` | 源sql | 源sql | YES | NULL | DB/DDL/实体注释 |
| `create_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(255)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `update_time` | `datetime` | 修改时间 | 修改时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(255)` | 修改人 | 修改人 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `type` | `varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

### a_biz

#### `biz_sms_send_record`

- 真实表：`biz_sms_send_record`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：短信发送记录
- 表含义：短信发送记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizSmsSendRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(255)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `error_msg` | `varchar(255)` | 发送错误消息 | 发送错误消息 | YES | NULL | DB/DDL/实体注释 |
| `success` | `tinyint(1)` | 是否发送成功 | 是否发送成功 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 手机号 | 手机号 | YES | NULL | DB/DDL/实体注释 |
| `content` | `varchar(4096)` | 发送内容 | 发送内容 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar` | 主键 | 业务或数据库主键。 |  |  | 通用字段 |
| `send` | `tinyint(1)` | send | 业务基础资料业务中的send。 |  |  | 推断 |

#### `biz_user_map`

- 真实表：`biz_user_map`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：用户的卡记录。
- 表含义：用户的卡记录。
- 字段来源：`Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizUserMap.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `user_lid` | `bigint` | userID | 业务基础资料业务关联的userID。 |  |  | 推断 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `id` | `varchar` | 主键 | 业务或数据库主键。 |  |  | 通用字段 |
| `unionid` | `varchar` | UnionID | 业务基础资料业务中的UnionID。 |  |  | 推断 |
| `appid` | `varchar` | appid | 业务基础资料业务中的appid。 |  |  | 推断 |
| `pwd` | `varchar` | pwd | 业务基础资料业务中的pwd。 |  |  | 推断 |
| `revision` | `int` | 版本号 | 乐观锁或同步版本号。 |  |  | 通用字段 |
| `created_time` | `datetime` | 创建时间 | 记录创建时间。 |  |  | 通用字段 |
| `updated_time` | `datetime` | 更新时间 | 记录最后更新时间。 |  |  | 通用字段 |
| `deleted` | `smallint` | 逻辑删除标记 | 逻辑删除状态，通常 0 表示未删除、1 表示已删除。 |  |  | 通用字段 |

#### `biz_user_storage`

- 真实表：`biz_user_storage`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：用户历史信息存储
- 表含义：用户历史信息存储
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizUserStorage.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `user_lid` | `bigint` | 用户lid | 用户lid | NO | NULL | DB/DDL/实体注释 |
| `key_` | `varchar(90)` | 键 | 键 | NO | NULL | DB/DDL/实体注释 |
| `value` | `text` | 值 | 值 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `key` | `varchar` | 键 | 业务基础资料业务中的键。 |  |  | 推断 |

### gylregdb

#### `biz_usr_merchant`

- 真实表：`biz_usr_merchant`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：用户与商户关联
- 表含义：用户与商户关联
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\BizUsrMerchant.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(255)` | openID | openid | YES | NULL | DB/DDL/实体注释 |
| `merchant_id` | `varchar(255)` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `merchant_name` | `varchar(255)` | 商户名称 | 商户名称 | YES | NULL | DB/DDL/实体注释 |
| `usr_id` | `bigint` | 用户id | 用户id | YES | NULL | DB/DDL/实体注释 |
| `usr_name` | `varchar(64)` | 账户名称 | 账户名称 | YES | NULL | DB/DDL/实体注释 |
| `staff_id` | `varchar(32)` | 用户工号 | 用户工号 | YES | NULL | DB/DDL/实体注释 |
| `union_id` | `varchar(90)` | unionID | union_id | YES | NULL | DB/DDL/实体注释 |
| `gzh_open_id` | `varchar(90)` | 公众号的openId | 公众号的openId | YES | NULL | DB/DDL/实体注释 |

### a_biz

#### `invoice_info_store`

- 真实表：`invoice_info_store`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：门店的发票配置信息
- 表含义：门店的发票配置信息
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\InvoiceInfoStore.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `taxpayer_num` | `varchar(255)` | 销方纳税人识别号 | 销方纳税人识别号 | YES | NULL | DB/DDL/实体注释 |
| `enterprise_name` | `varchar(255)` | 销方企业名称 | 销方企业名称 | YES | NULL | DB/DDL/实体注释 |
| `legal_person_name` | `varchar(255)` | 法人名称 | 法人名称 | YES | NULL | DB/DDL/实体注释 |
| `contacts_name` | `varchar(255)` | 联系人名称 | 联系人名称 | YES | NULL | DB/DDL/实体注释 |
| `contacts_email` | `varchar(255)` | 联系人邮箱 | 联系人邮箱 | YES | NULL | DB/DDL/实体注释 |
| `contacts_phone` | `varchar(255)` | 联系人手机号 | 联系人手机号 | YES | NULL | DB/DDL/实体注释 |
| `region_code` | `varchar(255)` | 地区编码 | 地区编码 | YES | NULL | DB/DDL/实体注释 |
| `city_name` | `varchar(255)` | 市名 | 市(区)名 | YES | NULL | DB/DDL/实体注释 |
| `enterprise_address` | `varchar(255)` | 详细地址 | 详细地址 | YES | NULL | DB/DDL/实体注释 |
| `taxRegistration_certificate` | `varchar(255)` | 证件图片对应的cos地址 | 证件图片对应的cos地址 | YES | NULL | DB/DDL/实体注释 |
| `review_opinion` | `varchar(255)` | 审核意见 | 审核意见 | YES | NULL | DB/DDL/实体注释 |
| `invoice_layout_file_type` | `varchar(255)` | 电子发票版式文件类型;pdf | 电子发票版式文件类型;pdf：pdf 格式; ofd：ofd 格式。 | YES | NULL | DB/DDL/实体注释 |
| `terminal_type` | `varchar(255)` | 终端设备类型 | 终端设备类型 | YES | NULL | DB/DDL/实体注释 |
| `service_status` | `varchar(255)` | 服务状态 | 服务状态 | YES | NULL | DB/DDL/实体注释 |
| `review_status` | `varchar(255)` | 审核状态 | 审核状态 | YES | NULL | DB/DDL/实体注释 |
| `invoice_kind` | `varchar(255)` | 开通的发票种类 | 开通的发票种类 | YES | NULL | DB/DDL/实体注释 |
| `invitation_code` | `varchar(255)` | 代理商邀请码 | 代理商邀请码 | YES | NULL | DB/DDL/实体注释 |
| `item_name` | `varchar(255)` | 开票项目 | 开票项目 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate_value` | `decimal(24,6)` | 税率 | 税率 | YES | NULL | DB/DDL/实体注释 |
| `tax_classification_code` | `varchar(255)` | 税收分类编码 | 税收分类编码 | YES | NULL | DB/DDL/实体注释 |
| `casher_name` | `varchar(255)` | 收款人 | 收款人 | YES | NULL | DB/DDL/实体注释 |
| `reviewer_name` | `varchar(255)` | 复核人 | 复核人 | YES | NULL | DB/DDL/实体注释 |
| `drawer_name` | `varchar(255)` | 开票人 | 开票人 | YES | NULL | DB/DDL/实体注释 |
| `expire_day` | `int` | 二维码有效天数 | 二维码有效天数 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `invoice_unit` | `varchar(64)` | 发票单位 | 发票单位 | YES | NULL | DB/DDL/实体注释 |
| `dlzh` | `varchar(255)` | 电子税局登录账号 | 电子税局登录账号 | YES | NULL | DB/DDL/实体注释 |
| `xfkhh` | `varchar(255)` | 销方开户行名称 | 销方开户行名称 | YES | NULL | DB/DDL/实体注释 |
| `xflxdh` | `varchar(255)` | 销方联系方式 | 销方联系方式 | YES | NULL | DB/DDL/实体注释 |
| `xfyhzh` | `varchar(255)` | 销方银行账号 | 销方银行账号 | YES | NULL | DB/DDL/实体注释 |
| `xfdz` | `varchar(255)` | 销方地址 | 销方地址 | YES | NULL | DB/DDL/实体注释 |
| `invoice_type` | `int` | 通道类型 | 通道类型 | YES | NULL | DB/DDL/实体注释 |
| `taxregistration_certificate` | `varchar` | taxregistrationcertificate | 发票业务中的taxregistrationcertificate。 |  |  | 推断 |

#### `plat_areas`

- 真实表：`plat_areas`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：区县
- 表含义：区县
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `code` | `bigint` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `city_code` | `bigint` | 城市编号 | 城市编号 | NO | NULL | DB/DDL/实体注释 |
| `province_code` | `bigint` | 省份编号 | 省份编号 | NO | NULL | DB/DDL/实体注释 |

#### `plat_cities`

- 真实表：`plat_cities`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：城市
- 表含义：城市
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `code` | `bigint` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `province_code` | `bigint` | 省份编号 | 省份编号 | NO | NULL | DB/DDL/实体注释 |

#### `plat_provinces`

- 真实表：`plat_provinces`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：省份
- 表含义：省份
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `code` | `bigint` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_merchant`

- 真实表：`sc_merchant`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：商户表。
- 表含义：商户表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + SQL:D:\mywork\nms4pos\sql\ddl.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScMerchant.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\ScMerchant.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 商户名称 | 商户名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `inst` | `varchar(255)` | 代理商 | 代理商 | YES | NULL | DB/DDL/实体注释 |
| `inst_code` | `varchar(255)` | 代理商编号 | 代理商编号 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `varchar(255)` | operationmodel | 供应链或基础资料业务中的operationmodel。 | YES | NULL | 推断 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 负责人手机 | 负责人手机 | YES | NULL | DB/DDL/实体注释 |
| `tel` | `varchar(255)` | tel | 供应链或基础资料业务中的tel。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | 联系地址 | 联系地址 | YES | NULL | DB/DDL/实体注释 |
| `email` | `varchar(255)` | 邮箱 | 邮箱 | YES | NULL | DB/DDL/实体注释 |
| `creator` | `varchar(255)` | 建立人 | 建立人 | YES | NULL | DB/DDL/实体注释 |
| `create_time` | `datetime` | 建立时间 | 建立时间 | YES | NULL | DB/DDL/实体注释 |
| `logo` | `varchar(255)` | logo | logo | YES | NULL | DB/DDL/实体注释 |
| `disable` | `tinyint` | 禁用 | 禁用 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `varchar(255)` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `varchar(255)` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `varchar(255)` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `industry` | `varchar(255)` | 行业名称 | 行业名称 | YES | NULL | DB/DDL/实体注释 |
| `industry_code` | `varchar(255)` | 行业编号 | 行业编号 | YES | NULL | DB/DDL/实体注释 |
| `recommend_code` | `varchar(255)` | recommendcode | 供应链或基础资料业务对象的recommendcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `Can_view` | `tinyint` | canview | 供应链或基础资料业务中的canview。 | YES | NULL | 推断 |
| `SYSType` | `int` | systype | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `Over_time` | `datetime` | over时间 | 供应链或基础资料业务中的over时间。 | YES | NULL | 推断 |
| `Renew_amount` | `decimal(19,10)` | renew金额 | 供应链或基础资料业务中的renew金额。 | YES | NULL | 推断 |
| `Inst_adm` | `varchar(255)` | instadm | 供应链或基础资料业务中的instadm。 | YES | NULL | 推断 |
| `Inst_adm_code` | `bigint` | instadmcode | 供应链或基础资料业务对象的instadmcode。 | YES | NULL | 推断 |
| `Inst_adm_tech` | `varchar(255)` | instadmtech | 供应链或基础资料业务中的instadmtech。 | YES | NULL | 推断 |
| `Inst_adm_tech_code` | `bigint` | instadmtechcode | 供应链或基础资料业务对象的instadmtechcode。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 供应链或基础资料业务中的syncfromold。 | YES | NULL | 推断 |
| `Trial_days` | `int` | trialdays | 供应链或基础资料业务中的trialdays。 | YES | NULL | 推断 |
| `ExamineTime` | `datetime` | examinetime | 供应链或基础资料业务中的examinetime。 | YES | NULL | 推断 |
| `Total_recharge_amount` | `decimal(19,10)` | total充值金额 | 供应链或基础资料业务中的total充值金额。 | YES | NULL | 推断 |
| `IsExameined` | `tinyint` | isexameined | 供应链或基础资料业务中的isexameined。 | YES | NULL | 推断 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | 0 | DB/DDL/实体注释 |
| `longitude` | `decimal(24,6)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `decimal(24,6)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `over_time` | `DATETIME` | 过期时间 | 过期时间 | YES | NULL | DB/DDL/实体注释 |
| `renew_amount` | `DECIMAL(24,6)` | 续费金额 | 续费金额 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sc_product_price`

- 真实表：`sc_product_price`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：产品价格表。
- 表含义：产品价格表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScProductPrice.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScProductPrice.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `product` | `varchar(64)` | 商品 | 供应链或基础资料业务中的商品。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | 供应链或基础资料业务中的价格。 | YES | NULL | 推断 |
| `Duration` | `decimal(19,10)` | duration | 供应链或基础资料业务中的duration。 | YES | NULL | 推断 |
| `Owner_id` | `varchar(255)` | ownerID | 供应链或基础资料业务关联的ownerID。 | YES | NULL | 推断 |
| `Owner_type` | `varchar(64)` | owner类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `Init_price` | `decimal(19,10)` | init价格 | 供应链或基础资料业务中的init价格。 | YES | NULL | 推断 |
| `Renew_cost_price` | `decimal(19,10)` | renewcost价格 | 供应链或基础资料业务中的renewcost价格。 | YES | NULL | 推断 |
| `Shop_pay_price` | `decimal(19,10)` | 店铺支付价格 | 供应链或基础资料业务中的店铺支付价格。 | YES | NULL | 推断 |
| `Show_order` | `int` | show订单 | 供应链或基础资料业务中的show订单。 | YES | NULL | 推断 |
| `Product_price_set` | `varchar(255)` | 商品价格set | 供应链或基础资料业务中的商品价格set。 | YES | NULL | 推断 |
| `Product_price_set_code` | `bigint` | 商品价格setcode | 供应链或基础资料业务对象的商品价格setcode。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `show_order` | `int` | show订单 | 供应链或基础资料业务中的show订单。 |  |  | 推断 |
| `product_price_set` | `varchar` | 商品价格set | 供应链或基础资料业务中的商品价格set。 |  |  | 推断 |
| `product_price_set_code` | `bigint` | 商品价格setcode | 供应链或基础资料业务对象的商品价格setcode。 |  |  | 推断 |
| `duration` | `int` | duration | 供应链或基础资料业务中的duration。 |  |  | 推断 |
| `owner_id` | `varchar` | ownerID | 供应链或基础资料业务关联的ownerID。 |  |  | 推断 |
| `owner_type` | `varchar` | owner类型 | 供应链或基础资料业务分类或类型。 |  |  | 推断 |
| `init_price` | `decimal` | init价格 | 供应链或基础资料业务中的init价格。 |  |  | 推断 |
| `renew_cost_price` | `decimal` | renewcost价格 | 供应链或基础资料业务中的renewcost价格。 |  |  | 推断 |
| `shop_pay_price` | `decimal` | 店铺支付价格 | 供应链或基础资料业务中的店铺支付价格。 |  |  | 推断 |

#### `sc_product_price_set`

- 真实表：`sc_product_price_set`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商等级。
- 表含义：代理商等级。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScProductPriceSet.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScProductPriceSet.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `show_order` | `int` | show订单 | 供应链或基础资料业务中的show订单。 | YES | NULL | 推断 |
| `def` | `tinyint` | def | 供应链或基础资料业务中的def。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sc_reg_dog`

- 真实表：`sc_reg_dog`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：加密狗。
- 表含义：加密狗。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScRegDog.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScRegDog.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(64)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(64)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `inst` | `varchar(255)` | inst | 供应链或基础资料业务中的inst。 | YES | NULL | 推断 |
| `inst_code` | `varchar(255)` | instcode | 供应链或基础资料业务对象的instcode。 | YES | NULL | 推断 |
| `ver` | `varchar(64)` | ver | 供应链或基础资料业务中的ver。 | YES | NULL | 推断 |
| `maketime` | `datetime` | maketime | 供应链或基础资料业务中的maketime。 | YES | NULL | 推断 |
| `firsttimewriteshopinfo` | `datetime` | firsttimewriteshopinfo | 供应链或基础资料业务中的firsttimewriteshopinfo。 | YES | NULL | 推断 |
| `overtime` | `datetime` | overtime | 供应链或基础资料业务中的overtime。 | YES | NULL | 推断 |
| `zhucejilu` | `varchar(255)` | zhucejilu | 供应链或基础资料业务中的zhucejilu。 | YES | NULL | 推断 |
| `pcnum` | `int` | pcnum | 供应链或基础资料业务中的pcnum。 | YES | NULL | 推断 |
| `dcbnum` | `int` | dcbnum | 供应链或基础资料业务中的dcbnum。 | YES | NULL | 推断 |
| `azpbnum` | `int` | azpbnum | 供应链或基础资料业务中的azpbnum。 | YES | NULL | 推断 |
| `azsjnum` | `int` | azsjnum | 供应链或基础资料业务中的azsjnum。 | YES | NULL | 推断 |
| `ipadnum` | `int` | ipadnum | 供应链或基础资料业务中的ipadnum。 | YES | NULL | 推断 |
| `zzdcnum` | `int` | zzdcnum | 供应链或基础资料业务中的zzdcnum。 | YES | NULL | 推断 |
| `province` | `varchar(255)` | province | 供应链或基础资料业务中的province。 | YES | NULL | 推断 |
| `city` | `varchar(255)` | city | 供应链或基础资料业务中的city。 | YES | NULL | 推断 |
| `district` | `varchar(255)` | district | 供应链或基础资料业务中的district。 | YES | NULL | 推断 |
| `shopname` | `varchar(255)` | shopname | 供应链或基础资料业务对象的shopname。 | YES | NULL | 推断 |
| `shopaddr` | `varchar(255)` | shopaddr | 供应链或基础资料业务中的shopaddr。 | YES | NULL | 推断 |
| `shopphone` | `varchar(255)` | shopphone | 供应链或基础资料业务中的shopphone。 | YES | NULL | 推断 |
| `pc_hylsnum` | `int` | pchylsnum | 供应链或基础资料业务中的pchylsnum。 | YES | NULL | 推断 |
| `pc_lspsnum` | `int` | pclspsnum | 供应链或基础资料业务中的pclspsnum。 | YES | NULL | 推断 |
| `pc_lsbbnum` | `int` | pclsbbnum | 供应链或基础资料业务中的pclsbbnum。 | YES | NULL | 推断 |
| `pwd` | `varchar(255)` | pwd | 供应链或基础资料业务中的pwd。 | YES | NULL | 推断 |
| `needsync` | `tinyint` | needsync | 供应链或基础资料业务中的needsync。 | YES | NULL | 推断 |
| `needsyncforce` | `tinyint` | needsyncforce | 供应链或基础资料业务中的needsyncforce。 | YES | NULL | 推断 |
| `notneedflag` | `tinyint` | notneedflag | 供应链或基础资料业务对象的notneedflag。 | YES | NULL | 推断 |
| `Renew_amount` | `decimal(19,10)` | renew金额 | 供应链或基础资料业务中的renew金额。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `renew_amount` | `decimal` | renew金额 | 供应链或基础资料业务中的renew金额。 |  |  | 推断 |

#### `sc_reg_dog_recharge_record`

- 真实表：`sc_reg_dog_recharge_record`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：加密狗充值记录。
- 表含义：加密狗充值记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScRegDogRechargeRecord.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScRegDogRechargeRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 供应链或基础资料业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 供应链或基础资料业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 供应链或基础资料业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 供应链或基础资料业务中的day。 | YES | NULL | 推断 |
| `crttime` | `datetime` | crttime | 供应链或基础资料业务中的crttime。 | YES | NULL | 推断 |
| `jinbanren` | `varchar(255)` | jinbanren | 供应链或基础资料业务中的jinbanren。 | YES | NULL | 推断 |
| `inst` | `varchar(255)` | inst | 供应链或基础资料业务中的inst。 | YES | NULL | 推断 |
| `inst_code` | `varchar(255)` | instcode | 供应链或基础资料业务对象的instcode。 | YES | NULL | 推断 |
| `jine` | `decimal(19,10)` | jine | 供应链或基础资料业务中的jine。 | YES | NULL | 推断 |
| `pcnum` | `int` | pcnum | 供应链或基础资料业务中的pcnum。 | YES | NULL | 推断 |
| `pcnumq` | `int` | pcnumq | 供应链或基础资料业务中的pcnumq。 | YES | NULL | 推断 |
| `pcnumh` | `int` | pcnumh | 供应链或基础资料业务中的pcnumh。 | YES | NULL | 推断 |
| `pc_lsnum` | `int` | pclsnum | 供应链或基础资料业务中的pclsnum。 | YES | NULL | 推断 |
| `pc_lsnumq` | `int` | pclsnumq | 供应链或基础资料业务中的pclsnumq。 | YES | NULL | 推断 |
| `pc_lsnumh` | `int` | pclsnumh | 供应链或基础资料业务中的pclsnumh。 | YES | NULL | 推断 |
| `pc_ftnum` | `int` | pcftnum | 供应链或基础资料业务中的pcftnum。 | YES | NULL | 推断 |
| `pc_ftnumq` | `int` | pcftnumq | 供应链或基础资料业务中的pcftnumq。 | YES | NULL | 推断 |
| `pc_ftnumh` | `int` | pcftnumh | 供应链或基础资料业务中的pcftnumh。 | YES | NULL | 推断 |
| `pc_zynum` | `int` | pczynum | 供应链或基础资料业务中的pczynum。 | YES | NULL | 推断 |
| `pc_zynumq` | `int` | pczynumq | 供应链或基础资料业务中的pczynumq。 | YES | NULL | 推断 |
| `pc_zynumh` | `int` | pczynumh | 供应链或基础资料业务中的pczynumh。 | YES | NULL | 推断 |
| `pc_ywnum` | `int` | pcywnum | 供应链或基础资料业务中的pcywnum。 | YES | NULL | 推断 |
| `pc_ywnumq` | `int` | pcywnumq | 供应链或基础资料业务中的pcywnumq。 | YES | NULL | 推断 |
| `pc_ywnumh` | `int` | pcywnumh | 供应链或基础资料业务中的pcywnumh。 | YES | NULL | 推断 |
| `dcbnum` | `int` | dcbnum | 供应链或基础资料业务中的dcbnum。 | YES | NULL | 推断 |
| `dcbnumq` | `int` | dcbnumq | 供应链或基础资料业务中的dcbnumq。 | YES | NULL | 推断 |
| `dcbnumh` | `int` | dcbnumh | 供应链或基础资料业务中的dcbnumh。 | YES | NULL | 推断 |
| `azpbnum` | `int` | azpbnum | 供应链或基础资料业务中的azpbnum。 | YES | NULL | 推断 |
| `azpbnumq` | `int` | azpbnumq | 供应链或基础资料业务中的azpbnumq。 | YES | NULL | 推断 |
| `azpbnumh` | `int` | azpbnumh | 供应链或基础资料业务中的azpbnumh。 | YES | NULL | 推断 |
| `azsjnum` | `int` | azsjnum | 供应链或基础资料业务中的azsjnum。 | YES | NULL | 推断 |
| `azsjnumq` | `int` | azsjnumq | 供应链或基础资料业务中的azsjnumq。 | YES | NULL | 推断 |
| `azsjnumh` | `int` | azsjnumh | 供应链或基础资料业务中的azsjnumh。 | YES | NULL | 推断 |
| `ipadnum` | `int` | ipadnum | 供应链或基础资料业务中的ipadnum。 | YES | NULL | 推断 |
| `ipadnumq` | `int` | ipadnumq | 供应链或基础资料业务中的ipadnumq。 | YES | NULL | 推断 |
| `ipadnumh` | `int` | ipadnumh | 供应链或基础资料业务中的ipadnumh。 | YES | NULL | 推断 |
| `zzdcnum` | `int` | zzdcnum | 供应链或基础资料业务中的zzdcnum。 | YES | NULL | 推断 |
| `zzdcnumq` | `int` | zzdcnumq | 供应链或基础资料业务中的zzdcnumq。 | YES | NULL | 推断 |
| `zzdcnumh` | `int` | zzdcnumh | 供应链或基础资料业务中的zzdcnumh。 | YES | NULL | 推断 |
| `pc_hylsnum` | `int` | pchylsnum | 供应链或基础资料业务中的pchylsnum。 | YES | NULL | 推断 |
| `pc_hylsnumq` | `int` | pchylsnumq | 供应链或基础资料业务中的pchylsnumq。 | YES | NULL | 推断 |
| `pc_hylsnumh` | `int` | pchylsnumh | 供应链或基础资料业务中的pchylsnumh。 | YES | NULL | 推断 |
| `pc_lspsnum` | `int` | pclspsnum | 供应链或基础资料业务中的pclspsnum。 | YES | NULL | 推断 |
| `pc_lspsnumq` | `int` | pclspsnumq | 供应链或基础资料业务中的pclspsnumq。 | YES | NULL | 推断 |
| `pc_lspsnumh` | `int` | pclspsnumh | 供应链或基础资料业务中的pclspsnumh。 | YES | NULL | 推断 |
| `pc_lsbbnum` | `int` | pclsbbnum | 供应链或基础资料业务中的pclsbbnum。 | YES | NULL | 推断 |
| `pc_lsbbnumq` | `int` | pclsbbnumq | 供应链或基础资料业务中的pclsbbnumq。 | YES | NULL | 推断 |
| `pc_lsbbnumh` | `int` | pclsbbnumh | 供应链或基础资料业务中的pclsbbnumh。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 供应链或基础资料业务中的comment。 | YES | NULL | 推断 |
| `refflag` | `varchar(64)` | refflag | 供应链或基础资料业务中的refflag。 | YES | NULL | 推断 |
| `yijinhuikuang` | `tinyint` | yijinhuikuang | 供应链或基础资料业务中的yijinhuikuang。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `jbweappnum` | `int` | jbweappnum | 供应链或基础资料业务中的jbweappnum。 |  |  | 推断 |
| `jbweappnumq` | `int` | jbweappnumq | 供应链或基础资料业务中的jbweappnumq。 |  |  | 推断 |
| `jbweappnumh` | `int` | jbweappnumh | 供应链或基础资料业务中的jbweappnumh。 |  |  | 推断 |
| `jlweappnum` | `int` | jlweappnum | 供应链或基础资料业务中的jlweappnum。 |  |  | 推断 |
| `jlweappnumq` | `int` | jlweappnumq | 供应链或基础资料业务中的jlweappnumq。 |  |  | 推断 |
| `jlweappnumh` | `int` | jlweappnumh | 供应链或基础资料业务中的jlweappnumh。 |  |  | 推断 |

#### `sc_store`

- 真实表：`sc_store`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：门店表。
- 表含义：门店表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + SQL:D:\mywork\nms4pos\sql\ddl.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScStore.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\ScStore.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(64)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(64)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 记录状态 | 记录状态 | YES | NULL | DB/DDL/实体注释 |
| `brand` | `varchar(255)` | 所属品牌名称 | 所属品牌名称 | YES | NULL | DB/DDL/实体注释 |
| `brand_code` | `bigint` | 品牌lid | 品牌lid | YES | NULL | DB/DDL/实体注释 |
| `grp` | `varchar(255)` | 所属分组名称 | 所属分组名称 | YES | NULL | DB/DDL/实体注释 |
| `grp_code` | `bigint` | 旧版的所属分组编号 | 旧版的所属分组编号 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `varchar(255)` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `varchar(255)` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `varchar(255)` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `varchar(255)` | operationmodel | 库存单据业务中的operationmodel。 | YES | NULL | 推断 |
| `business_model` | `int` | 运营模式 | 运营模式 | YES | NULL | DB/DDL/实体注释 |
| `business_begin_time` | `datetime` | 营业开始时间 | 营业开始时间 | YES | NULL | DB/DDL/实体注释 |
| `business_end_time` | `datetime` | 营业结束时间 | 营业结束时间 | YES | NULL | DB/DDL/实体注释 |
| `disable` | `tinyint` | 禁用 | 禁用 | YES | NULL | DB/DDL/实体注释 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 负责人手机 | 负责人手机 | YES | NULL | DB/DDL/实体注释 |
| `tel` | `varchar(255)` | 固定电话 | 固定电话 | YES | NULL | DB/DDL/实体注释 |
| `addr` | `varchar(255)` | 联系地址 | 联系地址 | YES | NULL | DB/DDL/实体注释 |
| `email` | `varchar(255)` | 邮箱 | 邮箱 | YES | NULL | DB/DDL/实体注释 |
| `addr_map` | `varchar(255)` | 地标 | 地标 | YES | NULL | DB/DDL/实体注释 |
| `longitude` | `varchar(255)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `varchar(255)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `logo` | `varchar(255)` | logo | logo | YES | NULL | DB/DDL/实体注释 |
| `img` | `varchar(255)` | 店铺图片 | 店铺图片 | YES | NULL | DB/DDL/实体注释 |
| `description` | `varchar(255)` | 店铺描述 | 店铺描述 | YES | NULL | DB/DDL/实体注释 |
| `placard` | `text` | 店铺公告 | 店铺公告 | YES | NULL | DB/DDL/实体注释 |
| `business_manager` | `varchar(255)` | 营业执照照片 | 营业执照照片 | YES | NULL | DB/DDL/实体注释 |
| `business_license_img` | `varchar(255)` | 营业执照照片 | 营业执照照片 | YES | NULL | DB/DDL/实体注释 |
| `business_license_code` | `varchar(255)` | 统一社会信用代码 | 统一社会信用代码 | YES | NULL | DB/DDL/实体注释 |
| `legal_representative` | `varchar(255)` | 法定代表人 | 法定代表人 | YES | NULL | DB/DDL/实体注释 |
| `business_license_name` | `varchar(255)` | 营业执照名称 | 营业执照名称 | YES | NULL | DB/DDL/实体注释 |
| `place_of_business` | `varchar(255)` | 经营场所/住所 | 经营场所/住所 | YES | NULL | DB/DDL/实体注释 |
| `registered_capital` | `decimal(19,10)` | 注册资本 | 注册资本 | YES | NULL | DB/DDL/实体注释 |
| `registered_date` | `datetime` | 注册/成立日期 | 注册/成立日期 | YES | NULL | DB/DDL/实体注释 |
| `registration_authority` | `varchar(255)` | 发证/登记机关 | 发证/登记机关 | YES | NULL | DB/DDL/实体注释 |
| `operating_period` | `datetime` | 营业期限 | 营业期限 | YES | NULL | DB/DDL/实体注释 |
| `approval_date` | `datetime` | 核准日期 | 核准日期 | YES | NULL | DB/DDL/实体注释 |
| `business_scope` | `varchar(255)` | 经营范围 | 经营范围 | YES | NULL | DB/DDL/实体注释 |
| `license` | `varchar(255)` | 许可证 | 许可证 | YES | NULL | DB/DDL/实体注释 |
| `boss_certificate` | `varchar(255)` | 手持个人证件 | 手持个人证件 | YES | NULL | DB/DDL/实体注释 |
| `licensed_documents` | `varchar(255)` | 特许证件 | 特许证件 | YES | NULL | DB/DDL/实体注释 |
| `food_safety_quantitative_classification` | `varchar(255)` | 食品安全量化分级 | 食品安全量化分级 | YES | NULL | DB/DDL/实体注释 |
| `sys_init_pwd` | `varchar(255)` | 系统初始化密码 | 系统初始化密码 | YES | NULL | DB/DDL/实体注释 |
| `Detailed_scope` | `varchar(255)` | detailed范围 | 库存单据业务中的detailed范围。 | YES | NULL | 推断 |
| `Score` | `decimal(19,10)` | score | 库存单据业务中的score。 | YES | NULL | 推断 |
| `Enable_mall` | `tinyint` | enablemall | 库存单据业务中的enablemall。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Mall_begin_time` | `datetime` | mall开始时间 | 库存单据业务中的mall开始时间。 | YES | NULL | 推断 |
| `Mall_end_time` | `datetime` | mall结束时间 | 库存单据业务中的mall结束时间。 | YES | NULL | 推断 |
| `Mall_status` | `tinyint` | mall状态 | 库存单据处理状态或启停状态。 | YES | NULL | 推断 |
| `SYSType` | `int` | systype | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Over_time` | `datetime` | over时间 | 库存单据业务中的over时间。 | YES | NULL | 推断 |
| `Over_year` | `int` | overyear | 库存单据业务中的overyear。 | YES | NULL | 推断 |
| `Over_month` | `int` | overmonth | 库存单据业务中的overmonth。 | YES | NULL | 推断 |
| `Over_day` | `int` | overday | 库存单据业务中的overday。 | YES | NULL | 推断 |
| `Renew_amount` | `decimal(19,10)` | renew金额 | 库存单据业务中的renew金额。 | YES | NULL | 推断 |
| `Book_status` | `tinyint` | book状态 | 库存单据处理状态或启停状态。 | YES | NULL | 推断 |
| `Crt_time` | `datetime` | crt时间 | 库存单据业务中的crt时间。 | YES | NULL | 推断 |
| `Creator` | `varchar(255)` | creator | 库存单据业务中的creator。 | YES | NULL | 推断 |
| `Inst` | `varchar(255)` | inst | 库存单据业务中的inst。 | YES | NULL | 推断 |
| `Inst_code` | `varchar(255)` | instcode | 库存单据业务对象的instcode。 | YES | NULL | 推断 |
| `Inst_adm` | `varchar(255)` | instadm | 库存单据业务中的instadm。 | YES | NULL | 推断 |
| `Inst_adm_code` | `bigint` | instadmcode | 库存单据业务对象的instadmcode。 | YES | NULL | 推断 |
| `Inst_adm_tech` | `varchar(255)` | instadmtech | 库存单据业务中的instadmtech。 | YES | NULL | 推断 |
| `Inst_adm_tech_code` | `bigint` | instadmtechcode | 库存单据业务对象的instadmtechcode。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 库存单据业务中的syncfromold。 | YES | NULL | 推断 |
| `Over_time_in_plat` | `datetime` | over时间in平台 | 库存单据业务中的over时间in平台。 | YES | NULL | 推断 |
| `Over_year_in_plat` | `int` | overyearin平台 | 库存单据业务中的overyearin平台。 | YES | NULL | 推断 |
| `Over_month_in_plat` | `int` | overmonthin平台 | 库存单据业务中的overmonthin平台。 | YES | NULL | 推断 |
| `Over_day_in_plat` | `int` | overdayin平台 | 库存单据业务中的overdayin平台。 | YES | NULL | 推断 |
| `can_dao_store_id` | `varchar(64)` | 餐道店铺id | 餐道店铺id | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `organization_type` | `int` | 组织类型 | 组织类型 | YES | 1 | DB/DDL/实体注释 |
| `rdc_lid` | `bigint` | 配送中心lid | 配送中心lid | YES | NULL | DB/DDL/实体注释 |
| `rdc_examine` | `tinyint(1)` | 配送中心审核订单 | 配送中心审核订单 | YES | NULL | DB/DDL/实体注释 |
| `to_examine_submit` | `tinyint(1)` | 门店审核订货单时同时提交 | 门店审核订货单时同时提交 | YES | NULL | DB/DDL/实体注释 |
| `check_in_multi_spec` | `tinyint(1)` | 门店多规格盘点 | 门店多规格盘点 | YES | NULL | DB/DDL/实体注释 |
| `self_built_goods` | `tinyint(1)` | 门店自建物品 | 门店自建物品 | YES | NULL | DB/DDL/实体注释 |
| `show_stock_check_in` | `tinyint(1)` | 盘点显示账面库存 | 盘点显示账面库存 | YES | NULL | DB/DDL/实体注释 |
| `receiver` | `varchar(255)` | 收货人 | 收货人 | YES | NULL | DB/DDL/实体注释 |
| `receiver_phone` | `varchar(255)` | 收货人联系方式 | 收货人联系方式 | YES | NULL | DB/DDL/实体注释 |
| `receiver_address` | `varchar(255)` | 收货地址 | 收货地址 | YES | NULL | DB/DDL/实体注释 |
| `number_of_item` | `int` | 数量ofitem | 库存单据业务中的数量ofitem。 | YES | NULL | 推断 |
| `number_of_supplier` | `int` | 数量ofsupplier | 库存单据业务中的数量ofsupplier。 | YES | NULL | 推断 |
| `number_of_delivery` | `int` | 数量ofdelivery | 库存单据业务中的数量ofdelivery。 | YES | NULL | 推断 |
| `number_of_supplier_price` | `int` | 数量ofsupplier价格 | 库存单据业务中的数量ofsupplier价格。 | YES | NULL | 推断 |
| `number_of_delivery_price` | `int` | 数量ofdelivery价格 | 库存单据业务中的数量ofdelivery价格。 | YES | NULL | 推断 |
| `show_in_order` | `tinyint(1)` | 可用于扫码点餐 | 可用于扫码点餐 | NO | 1 | DB/DDL/实体注释 |
| `maolink_key` | `varchar(255)` | 数字价签key | 数字价签key | YES | NULL | DB/DDL/实体注释 |
| `maolink_secret` | `varchar(255)` | 数字价签秘钥 | 数字价签秘钥 | YES | NULL | DB/DDL/实体注释 |
| `latest_online_time` | `datetime` | latestonline时间 | 库存单据业务中的latestonline时间。 | YES | NULL | 推断 |
| `server_ip` | `varchar(90)` | 服务器ip | 服务器ip | YES | NULL | DB/DDL/实体注释 |
| `server_ver` | `varchar(90)` | 服务器版本 | 服务器版本 | YES | NULL | DB/DDL/实体注释 |
| `server_ver_at` | `datetime` | 服务器编译时间 | 服务器编译时间 | YES | NULL | DB/DDL/实体注释 |
| `server_dev_id` | `varchar(90)` | 服务器设备号 | 服务器设备号 | YES | NULL | DB/DDL/实体注释 |
| `server_dev_name` | `varchar(90)` | 服务器设备名 | 服务器设备名 | YES | NULL | DB/DDL/实体注释 |
| `enable_mall` | `TINYINT(4)` | 启用微商城 | 启用微商城 | YES | NULL | DB/DDL/实体注释 |
| `creator` | `VARCHAR(255)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `crt_time` | `DATETIME` | 创建门店时间 | 创建门店时间 | YES | NULL | DB/DDL/实体注释 |
| `over_time` | `DATETIME` | 过期时间 | 过期时间 | YES | NULL | DB/DDL/实体注释 |
| `over_year` | `INT(11)` | 过期年份 | 过期年份 | YES | NULL | DB/DDL/实体注释 |
| `over_month` | `INT(11)` | 过期月份 | 过期月份 | YES | NULL | DB/DDL/实体注释 |
| `over_day` | `INT(11)` | 过期天 | 过期天 | YES | NULL | DB/DDL/实体注释 |
| `over_time_in_plat` | `DATETIME` | 过期时间 | 过期时间(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_year_in_plat` | `INT(11)` | 过期年份 | 过期年份(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_month_in_plat` | `INT(11)` | 过期月份 | 过期月份(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_day_in_plat` | `INT(11)` | 过期天 | 过期天(平台) | YES | NULL | DB/DDL/实体注释 |
| `renew_amount` | `DECIMAL(24,6)` | 续费金额 | 续费金额 | YES | NULL | DB/DDL/实体注释 |
| `mall_begin_time` | `DATETIME` | 微商城营业开始时间 | 微商城营业开始时间 | YES | NULL | DB/DDL/实体注释 |
| `mall_end_time` | `DATETIME` | 微商城营业结束时间 | 微商城营业结束时间 | YES | NULL | DB/DDL/实体注释 |
| `mall_status` | `TINYINT(4)` | 微商城营业状态 | 微商城营业状态 | YES | NULL | DB/DDL/实体注释 |
| `book_status` | `TINYINT(4)` | 是否启用预订 | 是否启用预订 | YES | NULL | DB/DDL/实体注释 |
| `detailed_scope` | `VARCHAR(255)` | 具体经营类别 | 具体经营类别 | YES | NULL | DB/DDL/实体注释 |
| `inst` | `VARCHAR(255)` | 代理商 | 代理商 | YES | NULL | DB/DDL/实体注释 |
| `inst_code` | `VARCHAR(255)` | 代理商编号 | 代理商编号 | YES | NULL | DB/DDL/实体注释 |
| `systype` | `INT` | 系统类型 | 系统类型 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `pid_tmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 |  |  | 推断 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sc_store_and_product`

- 真实表：`sc_store_and_product`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：门店产品注册记录。
- 表含义：门店产品注册记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScStoreAndProduct.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScStoreAndProduct.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(64)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `merchant_code` | `bigint` | 商户code | 库存单据业务对象的商户code。 | YES | NULL | 推断 |
| `merchant_name` | `varchar(255)` | 商户name | 库存单据业务对象的商户name。 | YES | NULL | 推断 |
| `store_code` | `bigint` | 门店code | 库存单据业务对象的门店code。 | YES | NULL | 推断 |
| `store_name` | `varchar(255)` | 门店name | 库存单据业务对象的门店name。 | YES | NULL | 推断 |
| `sc_inst_code` | `bigint` | scinstcode | 库存单据业务对象的scinstcode。 | YES | NULL | 推断 |
| `sc_inst` | `varchar(255)` | scinst | 库存单据业务中的scinst。 | YES | NULL | 推断 |
| `crt_time` | `datetime` | crt时间 | 库存单据业务中的crt时间。 | YES | NULL | 推断 |
| `last_update_time` | `datetime` | 上次update时间 | 库存单据业务中的上次update时间。 | YES | NULL | 推断 |
| `last_update_opr` | `varchar(2048)` | 上次updateopr | 库存单据业务中的上次updateopr。 | YES | NULL | 推断 |
| `sys_type` | `int` | sys类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `product_type` | `varchar(64)` | 商品类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `product_out_code` | `varchar(255)` | 商品outcode | 库存单据业务对象的商品outcode。 | YES | NULL | 推断 |
| `product_inner_code` | `varchar(255)` | 商品innercode | 库存单据业务对象的商品innercode。 | YES | NULL | 推断 |
| `product_amount` | `decimal(19,10)` | 商品金额 | 库存单据业务中的商品金额。 | YES | NULL | 推断 |
| `cost_amt` | `decimal(19,10)` | costamt | 库存单据业务中的costamt。 | YES | NULL | 推断 |
| `pay_amt` | `decimal(19,10)` | 支付amt | 库存单据业务中的支付amt。 | YES | NULL | 推断 |
| `over_time` | `datetime` | over时间 | 库存单据业务中的over时间。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 库存单据业务中的disable。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 库存单据业务中的syncfromold。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `sync_from_old` | `tinyint(1)` | syncfromold | 库存单据业务中的syncfromold。 |  |  | 推断 |

#### `sc_store_and_product_flow`

- 真实表：`sc_store_and_product_flow`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：门店产品注册记录流水。
- 表含义：门店产品注册记录流水。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScStoreAndProductFlow.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScStoreAndProductFlow.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `payer` | `varchar(255)` | payer | 库存单据业务中的payer。 | YES | NULL | 推断 |
| `merchant_code` | `bigint` | 商户code | 库存单据业务对象的商户code。 | YES | NULL | 推断 |
| `merchant_name` | `varchar(255)` | 商户name | 库存单据业务对象的商户name。 | YES | NULL | 推断 |
| `store_code` | `bigint` | 门店code | 库存单据业务对象的门店code。 | YES | NULL | 推断 |
| `store_name` | `varchar(255)` | 门店name | 库存单据业务对象的门店name。 | YES | NULL | 推断 |
| `sc_inst_code` | `bigint` | scinstcode | 库存单据业务对象的scinstcode。 | YES | NULL | 推断 |
| `sc_inst` | `varchar(255)` | scinst | 库存单据业务中的scinst。 | YES | NULL | 推断 |
| `crt_time` | `datetime` | crt时间 | 库存单据业务中的crt时间。 | YES | NULL | 推断 |
| `last_update_time` | `datetime` | 上次update时间 | 库存单据业务中的上次update时间。 | YES | NULL | 推断 |
| `last_update_opr` | `varchar(2048)` | 上次updateopr | 库存单据业务中的上次updateopr。 | YES | NULL | 推断 |
| `sys_type` | `int` | sys类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `product_type` | `varchar(64)` | 商品类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `product_code` | `varchar(255)` | 商品code | 库存单据业务对象的商品code。 | YES | NULL | 推断 |
| `product_amount_before` | `decimal(19,10)` | 商品金额before | 库存单据业务中的商品金额before。 | YES | NULL | 推断 |
| `product_amount` | `decimal(19,10)` | 商品金额 | 库存单据业务中的商品金额。 | YES | NULL | 推断 |
| `product_amount_after` | `decimal(19,10)` | 商品金额after | 库存单据业务中的商品金额after。 | YES | NULL | 推断 |
| `cost_` | `decimal(19,10)` | cost | 库存单据业务中的cost。 | YES | NULL | 推断 |
| `pay_price` | `decimal(19,10)` | 支付价格 | 库存单据业务中的支付价格。 | YES | NULL | 推断 |
| `pay_amt` | `decimal(19,10)` | 支付amt | 库存单据业务中的支付amt。 | YES | NULL | 推断 |
| `pay_bill_id` | `bigint` | 支付账单ID | 库存单据业务关联的支付账单ID。 | YES | NULL | 推断 |
| `sc_inst_finance_bill_id` | `bigint` | scinstfinance账单ID | 库存单据业务关联的scinstfinance账单ID。 | YES | NULL | 推断 |
| `over_time` | `int` | over时间 | 库存单据业务中的over时间。 | YES | NULL | 推断 |
| `over_time_before` | `datetime` | over时间before | 库存单据业务中的over时间before。 | YES | NULL | 推断 |
| `over_time_after` | `datetime` | over时间after | 库存单据业务中的over时间after。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 库存单据业务中的disable。 | YES | NULL | 推断 |
| `state_` | `varchar(64)` | 状态 | 库存单据业务中的状态。 | YES | NULL | 推断 |
| `Inst_amount_before` | `decimal(19,10)` | inst金额before | 库存单据业务中的inst金额before。 | YES | NULL | 推断 |
| `Inst_amount_after` | `decimal(19,10)` | inst金额after | 库存单据业务中的inst金额after。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `inst_amount_before` | `decimal` | inst金额before | 库存单据业务中的inst金额before。 |  |  | 推断 |
| `inst_amount_after` | `decimal` | inst金额after | 库存单据业务中的inst金额after。 |  |  | 推断 |
| `cost` | `decimal` | cost | 库存单据业务中的cost。 |  |  | 推断 |
| `state` | `varchar` | 状态 | 业务处理状态。 |  |  | 通用字段 |

### a_biz

#### `store_intro_content`

- 真实表：`store_intro_content`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：店铺介绍分组内容
- 表含义：店铺介绍分组内容
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\StoreIntroContent.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `content` | `text` | 介绍内容/图片地址 | 介绍内容/图片地址 | YES | NULL | DB/DDL/实体注释 |
| `group_lid` | `bigint` | 分组编号 | 分组编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `title` | `varchar(255)` | title | 业务业务中的title。 | YES | NULL | 推断 |

#### `store_intro_group`

- 真实表：`store_intro_group`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：店铺介绍分组
- 表含义：店铺介绍分组
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\StoreIntroGroup.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 分组名称 | 分组名称 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 内容类型 | 内容类型 | YES | NULL | DB/DDL/实体注释 |
| `store_lid` | `bigint` | 店铺编号 | 店铺编号 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `grid_cols` | `int` | 每行列数 | 每行列数 | NO | 1 | DB/DDL/实体注释 |
| `gap_x` | `int` | 左右间距 | 左右间距 | NO | 0 | DB/DDL/实体注释 |
| `gap_y` | `int` | 上下间距 | 上下间距 | NO | 0 | DB/DDL/实体注释 |
| `title_text_align` | `varchar(90)` | 标题对齐方式 | 标题对齐方式 | NO | center | DB/DDL/实体注释 |
| `address_name` | `varchar(255)` | 地点名 | 地点名 | YES | NULL | DB/DDL/实体注释 |
| `longitude` | `decimal(24,6)` | 精度 | 精度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `decimal(24,6)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

### gylregdb

#### `sys_brand`

- 真实表：`sc_brand`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：品牌。
- 表含义：品牌。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\SysBrand.java + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\ScBrand.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `business_model` | `varchar(255)` | 业务model | 业务业务中的业务model。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 业务业务中的说明。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 业务业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务业务中的create时间。 | YES | NULL | 推断 |
| `logo` | `text` | logo | logo | YES | NULL | DB/DDL/实体注释 |
| `disable` | `tinyint` | disable | 业务业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `pos_bg` | `text` | 收银系统背景图片 | 收银系统背景图片 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

### a_biz

#### `wx_color`

- 真实表：`wx_color`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：皮肤颜色
- 表含义：皮肤颜色
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxColor.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `rgb` | `varchar(90)` | 颜色 | 颜色 | YES | NULL | DB/DDL/实体注释 |
| `font_color` | `varchar(20)` | 字体颜色 | 字体颜色 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wx_componet`

- 真实表：`wx_componet`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：页面组件
- 表含义：页面组件
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxComponet.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `page_lid` | `bigint` | 页面编号 | 页面编号 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `style` | `int` | 样式 | 样式 | YES | NULL | DB/DDL/实体注释 |
| `arc` | `int` | 圆角弧度 | 圆角弧度 | YES | NULL | DB/DDL/实体注释 |
| `top_margin` | `int` | 上边距 | 上边距 | YES | NULL | DB/DDL/实体注释 |
| `bottom_margin` | `int` | 下边距 | 下边距 | YES | NULL | DB/DDL/实体注释 |
| `left_and_right_margin` | `int` | 左右边距 | 左右边距 | YES | NULL | DB/DDL/实体注释 |
| `bg_color` | `varchar(90)` | 背景色 | 背景色 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 索引 | 索引 | YES | NULL | DB/DDL/实体注释 |
| `title` | `varchar(128)` | 组件标题 | 组件标题 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(128)` | 标题 | 标题 | YES | NULL | DB/DDL/实体注释 |
| `color` | `varchar(32)` | 字体颜色 | 字体颜色 | YES | NULL | DB/DDL/实体注释 |
| `text_align` | `int` | 位置 | 位置 | YES | NULL | DB/DDL/实体注释 |
| `font_size` | `int` | 字体大小 | 字体大小 | YES | NULL | DB/DDL/实体注释 |
| `per_row_num` | `int` | 每行组件数量 | 每行组件数量 | YES | NULL | DB/DDL/实体注释 |
| `top_left_arc` | `int` | 左上圆角 | 左上圆角 | YES | NULL | DB/DDL/实体注释 |
| `top_right_arc` | `int` | 右上圆角 | 右上圆角 | YES | NULL | DB/DDL/实体注释 |
| `bottom_left_arc` | `int` | 左下圆角 | 左下圆角 | YES | NULL | DB/DDL/实体注释 |
| `bottom_right_arc` | `int` | 右下圆角 | 右下圆角 | YES | NULL | DB/DDL/实体注释 |
| `height` | `int` | 组件高度 | 组件高度 | YES | NULL | DB/DDL/实体注释 |
| `page_path` | `int` | 跳转页面 | 跳转页面 | YES | NULL | DB/DDL/实体注释 |
| `uri` | `varchar(255)` | h5或公众号文章地址 | h5或公众号文章地址 | YES | NULL | DB/DDL/实体注释 |
| `jump_type` | `int` | 跳转类型 | 跳转类型 | YES | NULL | DB/DDL/实体注释 |
| `color2` | `varchar(32)` | 字体颜色2 | 字体颜色2 | YES | NULL | DB/DDL/实体注释 |
| `image` | `varchar(255)` | 背景图片 | 背景图片 | YES | NULL | DB/DDL/实体注释 |
| `left_and_right_padding` | `int` | 左右内边距 | 左右内边距 | YES | NULL | DB/DDL/实体注释 |
| `video` | `varchar(255)` | 视频地址 | 视频地址 | YES | NULL | DB/DDL/实体注释 |
| `font_bold` | `int` | 字段粗细 | 字段粗细 | YES | NULL | DB/DDL/实体注释 |
| `title_img` | `varchar(255)` | 标题背景图 | 标题背景图 | YES | NULL | DB/DDL/实体注释 |
| `auto` | `tinyint(1)` | 自动播放 | 自动播放 | NO | 1 | DB/DDL/实体注释 |
| `extra_info` | `text` | 额外信息 | 额外信息 | YES | NULL | DB/DDL/实体注释 |
| `top_bottom_padding` | `int` | 上下内边距 | 上下内边距 | YES | NULL | DB/DDL/实体注释 |
| `avatar_size` | `int` | 会员头像大小 | 会员头像大小 | YES | NULL | DB/DDL/实体注释 |
| `icon_size` | `int` | 图标大小 | 图标大小 | YES | NULL | DB/DDL/实体注释 |
| `icon_x_gap` | `decimal(24,6)` | 组件间隙 | 组件间隙 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `wx_componet_item`

- 真实表：`wx_componet_item`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：组件元素
- 表含义：组件元素
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxComponetItem.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `componet_lid` | `bigint` | 组件编号 | 组件编号 | YES | NULL | DB/DDL/实体注释 |
| `image` | `varchar(255)` | 图片地址 | 图片地址 | YES | NULL | DB/DDL/实体注释 |
| `func` | `int` | 功能 | 功能 | YES | NULL | DB/DDL/实体注释 |
| `title` | `varchar(90)` | 标题 | 标题 | YES | NULL | DB/DDL/实体注释 |
| `description` | `varchar(255)` | 描述 | 描述 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 索引 | 索引 | YES | NULL | DB/DDL/实体注释 |
| `page_lid` | `bigint` | 索引 | 索引 | YES | NULL | DB/DDL/实体注释 |
| `position_` | `int` | 位置 | 位置 | YES | NULL | DB/DDL/实体注释 |
| `uri` | `varchar(255)` | h5或公众号文章地址 | h5或公众号文章地址 | YES | NULL | DB/DDL/实体注释 |
| `jump_type` | `int` | 跳转类型 | 跳转类型 | YES | NULL | DB/DDL/实体注释 |
| `extra_info` | `text` | 额外信息 | 额外信息 | YES | NULL | DB/DDL/实体注释 |
| `position` | `tinyint/varchar` | position | 微信或小程序业务中的position。 |  |  | 推断 |

#### `wx_navigation`

- 真实表：`wx_navigation`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：小程序底部导航
- 表含义：小程序底部导航
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxNavigation.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `idx` | `bigint` | 索引 | 索引 | YES | NULL | DB/DDL/实体注释 |
| `icon` | `varchar(255)` | 未选中时的图标 | 未选中时的图标 | YES | NULL | DB/DDL/实体注释 |
| `selected_icon` | `varchar(255)` | 选中时的图标 | 选中时的图标 | YES | NULL | DB/DDL/实体注释 |
| `text` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `page_path` | `int` | 页面 | 页面 | YES | NULL | DB/DDL/实体注释 |
| `bg_color` | `varchar(90)` | 背景色 | 背景色 | YES | NULL | DB/DDL/实体注释 |
| `text_color` | `varchar(90)` | 文字颜色 | 文字颜色 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wx_page`

- 真实表：`wx_page`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：小程序页面
- 表含义：小程序页面
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxPage.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 页面类型 | 页面类型 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 标题 | 标题 | YES | NULL | DB/DDL/实体注释 |
| `style` | `varchar(255)` | 样式 | 样式 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `bg_color` | `varchar(32)` | 背景颜色 | 背景颜色 | YES | NULL | DB/DDL/实体注释 |
| `image` | `text` | 背景图 | 背景图 | YES | NULL | DB/DDL/实体注释 |
| `full_screen` | `tinyint` | 占满屏幕 | 占满屏幕 | YES | NULL | DB/DDL/实体注释 |
| `bg_height` | `int` | 背景图高度 | 背景图高度 | YES | NULL | DB/DDL/实体注释 |
| `ext_color` | `varchar(255)` | 预留颜色 | 预留颜色 | YES | NULL | DB/DDL/实体注释 |
| `ext_color1` | `varchar(255)` | 预留颜色1 | 预留颜色1 | YES | NULL | DB/DDL/实体注释 |
| `ext_color2` | `varchar(255)` | 预留颜色2 | 预留颜色2 | YES | NULL | DB/DDL/实体注释 |
| `ext_color3` | `varchar(255)` | 预留颜色2 | 预留颜色2 | YES | NULL | DB/DDL/实体注释 |
| `extra_info` | `text` | 额外信息 | 额外信息 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 是否启用 | 是否启用 | NO | 1 | DB/DDL/实体注释 |
| `device_ids` | `text` | 设备json数组 | 设备json数组 | YES | NULL | DB/DDL/实体注释 |
| `vertical_screen` | `tinyint(1)` | 是否竖屏 | 是否竖屏 | NO | 0 | DB/DDL/实体注释 |
| `template_lid` | `bigint` | 模板lid | 模板lid | YES | NULL | DB/DDL/实体注释 |
| `template_name` | `varchar(90)` | 模板名称 | 模板名称 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `wx_program_template`

- 真实表：`wx_program_template`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：小程序代码模板
- 表含义：小程序代码模板
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxProgramTemplate.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(255)` | 编号 | 编号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 小程序代码上传记录名称 | 小程序代码上传记录名称 | YES | NULL | DB/DDL/实体注释 |
| `appid` | `varchar(255)` | appid | appid | YES | NULL | DB/DDL/实体注释 |
| `commit_audit_time` | `datetime` | 上传时间 | 上传时间 | YES | NULL | DB/DDL/实体注释 |
| `operator` | `varchar(255)` | 操作员 | 操作员 | YES | NULL | DB/DDL/实体注释 |
| `template_ver` | `varchar(255)` | 模板版本号 | 模板版本号 | YES | NULL | DB/DDL/实体注释 |
| `template_desc` | `varchar(255)` | 模板描述 | 模板描述 | YES | NULL | DB/DDL/实体注释 |
| `template_id` | `varchar(255)` | 模板编号 | 模板编号 | YES | NULL | DB/DDL/实体注释 |
| `template_create_time` | `datetime` | 模板创建时间 | 模板创建时间 | YES | NULL | DB/DDL/实体注释 |
| `submit_audit_time` | `datetime` | 提交审核时间 | 提交审核时间 | YES | NULL | DB/DDL/实体注释 |
| `auditid` | `varchar(255)` | 审核id | 审核id | YES | NULL | DB/DDL/实体注释 |
| `audit_status` | `int` | 审核状态 | 审核状态 | YES | NULL | DB/DDL/实体注释 |
| `audit_reject_reason` | `varchar(255)` | 审核被拒绝原因 | 审核被拒绝原因 | YES | NULL | DB/DDL/实体注释 |
| `audit_reject_screenshot` | `varchar(255)` | 审核失败的小程序截图示例 | 审核失败的小程序截图示例 | YES | NULL | DB/DDL/实体注释 |
| `released` | `tinyint(1)` | 已经发布 | 已经发布 | YES | NULL | DB/DDL/实体注释 |
| `release_time` | `datetime` | 发布时间 | 发布时间 | YES | NULL | DB/DDL/实体注释 |

#### `wx_template_label`

- 真实表：`wx_template_label`
- 数据源/库：`a_biz` / `biz` / `172.16.0.144:3306`
- 表中文名：广告模板标签
- 表含义：广告模板标签
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\WxTemplateLabel.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `image` | `varchar(255)` | 图片地址 | 图片地址 | NO | NULL | DB/DDL/实体注释 |
| `temp_lid` | `bigint` | 模板lid | 模板lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### a_crm

#### `crm_actuator`

- 真实表：`crm_actuator`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员执行器
- 表含义：会员执行器
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmActuator.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `actuator_type` | `tinyint` | 执行器类型 | 执行器类型：0历史未知，1批量赠券，2批量充值 | NO | 0 | DB/DDL/实体注释 |
| `exec_type` | `int` | 执行类型 | 执行类型 | NO | 1 | DB/DDL/实体注释 |
| `filter_lid` | `bigint` | 筛选器lid | 筛选器lid | YES | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,6)` | 赠送积分 | 赠送积分 | NO | 0.000000 | DB/DDL/实体注释 |
| `give_amount` | `decimal(24,6)` | 赠送金额 | 赠送金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `take_mode` | `int` | 领取模式 | 领取模式 | NO | 2 | DB/DDL/实体注释 |
| `remark` | `varchar(2000)` | 活动备注 | 活动备注 | YES | NULL | DB/DDL/实体注释 |
| `timed` | `tinyint(1)` | 定时执行 | 定时执行 | NO | 0 | DB/DDL/实体注释 |
| `exec_period` | `int` | 执行周期 | 执行周期 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 执行周期-开始时间 | 执行周期-开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 执行周期-结束时间 | 执行周期-结束时间 | YES | NULL | DB/DDL/实体注释 |
| `exec_mode` | `int` | 执行模式 | 执行模式 | NO | 2 | DB/DDL/实体注释 |
| `exec_val` | `varchar(255)` | 执行模式为月时的天数列表，逗号分割 | 执行模式为月时的天数列表，逗号分割 | YES | NULL | DB/DDL/实体注释 |
| `monday` | `tinyint(1)` | 周一 | 周一 | NO | 0 | DB/DDL/实体注释 |
| `tuesday` | `tinyint(1)` | 周二 | 周二 | NO | 0 | DB/DDL/实体注释 |
| `wednesday` | `tinyint(1)` | 周三 | 周三 | NO | 0 | DB/DDL/实体注释 |
| `thursday` | `tinyint(1)` | 周四 | 周四 | NO | 0 | DB/DDL/实体注释 |
| `friday` | `tinyint(1)` | 周五 | 周五 | NO | 0 | DB/DDL/实体注释 |
| `saturday` | `tinyint(1)` | 周六 | 周六 | NO | 0 | DB/DDL/实体注释 |
| `sunday` | `tinyint(1)` | 周日 | 周日 | NO | 0 | DB/DDL/实体注释 |
| `exec_time` | `varchar(90)` | 执行时间 | 执行时间 | YES | NULL | DB/DDL/实体注释 |
| `exec_state` | `int` | 执行状态 | 执行状态 | NO | 1 | DB/DDL/实体注释 |
| `exec_info` | `varchar(255)` | 执行信息 | 执行信息：错误信息，执行成功信息 | YES | NULL | DB/DDL/实体注释 |
| `last_exec_time` | `datetime` | 上次执行时间 | 上次执行时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `recharge_amount` | `decimal(24,6)` | 充值金额 | 充值金额 | NO | 0.000000 | DB/DDL/实体注释 |

#### `crm_actuator_coupon`

- 真实表：`crm_actuator_coupon`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：执行器券列表
- 表含义：执行器券列表
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmActuatorCoupon.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `actuator_lid` | `bigint` | 执行器lid | 执行器lid | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券lid | 优惠券lid | NO | NULL | DB/DDL/实体注释 |
| `coupon_num` | `int` | 赠送数量 | 赠送数量 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_actuator_record`

- 真实表：`crm_actuator_record`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：执行器执行记录
- 表含义：执行器执行记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmActuatorRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `actuator_lid` | `bigint` | 执行器lid | 执行器lid | NO | NULL | DB/DDL/实体注释 |
| `actuator_name` | `varchar(90)` | 执行器名称 | 执行器名称 | NO | NULL | DB/DDL/实体注释 |
| `total` | `int` | 执行总数量 | 执行总数量 | NO | NULL | DB/DDL/实体注释 |
| `suc_total` | `int` | 执行成功数量 | 执行成功数量 | NO | NULL | DB/DDL/实体注释 |
| `fail_total` | `int` | 执行失败数量 | 执行失败数量 | NO | NULL | DB/DDL/实体注释 |
| `exec_state` | `int` | 执行状态 | 执行状态 | NO | NULL | DB/DDL/实体注释 |
| `finished_at` | `datetime` | 完成时间 | 完成时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_advertising_scheme`

- 真实表：`crm_advertising_scheme`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：广告设置。
- 表含义：广告设置。
- 字段来源：`Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmAdvertisingScheme.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `advert_type` | `tinyint/varchar` | advert类型 | CRM会员业务分类或类型。 |  |  | 推断 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `begin_date_time` | `datetime` | 开始日期时间 | CRM会员业务中的开始日期时间。 |  |  | 推断 |
| `end_date_time` | `datetime` | 结束日期时间 | CRM会员业务中的结束日期时间。 |  |  | 推断 |
| `priority` | `int` | priority | CRM会员业务中的priority。 |  |  | 推断 |
| `maker` | `varchar` | maker | CRM会员业务中的maker。 |  |  | 推断 |
| `make_time` | `datetime` | make时间 | CRM会员业务中的make时间。 |  |  | 推断 |
| `disable` | `tinyint(1)` | disable | CRM会员业务中的disable。 |  |  | 推断 |
| `carousel_time` | `int` | carousel时间 | CRM会员业务中的carousel时间。 |  |  | 推断 |
| `for_all` | `tinyint(1)` | forall | CRM会员业务中的forall。 |  |  | 推断 |

#### `crm_advertising_scheme_and_shop`

- 真实表：`crm_advertising_scheme_and_shop`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：广告适用门店。
- 表含义：广告适用门店。
- 字段来源：`Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmAdvertisingSchemeAndShop.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `id` | `varchar` | 主键 | 业务或数据库主键。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `scheme` | `varchar` | scheme | CRM会员业务中的scheme。 |  |  | 推断 |
| `scheme_code` | `bigint` | schemecode | CRM会员业务对象的schemecode。 |  |  | 推断 |
| `owner_shop` | `varchar` | owner店铺 | CRM会员业务中的owner店铺。 |  |  | 推断 |
| `owner_shop_id` | `bigint` | owner店铺ID | CRM会员业务关联的owner店铺ID。 |  |  | 推断 |

#### `crm_advertising_scheme_item`

- 真实表：`crm_advertising_scheme_item`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：广告项。
- 表含义：广告项。
- 字段来源：`Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmAdvertisingSchemeItem.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `id` | `varchar` | 主键 | 业务或数据库主键。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `scheme` | `varchar` | scheme | CRM会员业务中的scheme。 |  |  | 推断 |
| `img_url` | `varchar` | imgurl | CRM会员业务中的imgurl。 |  |  | 推断 |
| `jump_url` | `varchar` | jumpurl | CRM会员业务中的jumpurl。 |  |  | 推断 |
| `jump_type` | `tinyint/varchar` | jump类型 | CRM会员业务分类或类型。 |  |  | 推断 |
| `position` | `tinyint/varchar` | position | CRM会员业务中的position。 |  |  | 推断 |
| `scheme_code` | `bigint` | schemecode | CRM会员业务对象的schemecode。 |  |  | 推断 |

### a_crm

#### `crm_birthday_record`

- 真实表：`crm_birthday_record`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：生日营销赠送记录
- 表含义：生日营销赠送记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmBirthdayRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year_` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month_` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day_` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡lid | 会员卡lid | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 会员卡号 | 会员卡号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 会员名称 | 会员名称 | NO | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 会员手机号 | 会员手机号 | NO | NULL | DB/DDL/实体注释 |
| `birthday` | `datetime` | 生日 | 生日 | NO | NULL | DB/DDL/实体注释 |
| `advance_days` | `int` | 提前天数 | 提前天数 | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 赠券lid | 赠券lid | YES | NULL | DB/DDL/实体注释 |
| `coupon_name` | `varchar(90)` | 赠券名称 | 赠券名称 | YES | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,6)` | 赠送积分 | 赠送积分 | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 赠券规则lid | 赠券规则lid | NO | NULL | DB/DDL/实体注释 |
| `rule_name` | `varchar(90)` | 赠券规则名称 | 赠券规则名称 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `year` | `int` | year | CRM会员业务中的year。 |  |  | 推断 |
| `month` | `int` | month | CRM会员业务中的month。 |  |  | 推断 |
| `day` | `int` | day | CRM会员业务中的day。 |  |  | 推断 |

#### `crm_birthday_rule`

- 真实表：`crm_birthday_rule`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员员生日营销
- 表含义：会员员生日营销
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmBirthdayRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 活动名称 | 活动名称 | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始有效期 | 开始有效期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 失效期 | 失效期 | NO | NULL | DB/DDL/实体注释 |
| `advance_days` | `int` | 提前天数 | 提前天数 | NO | NULL | DB/DDL/实体注释 |
| `is_suit_all` | `tinyint(1)` | 是否适用全部会员卡类型 | 是否适用全部会员卡类型 | NO | 0 | DB/DDL/实体注释 |
| `card_type_lids` | `varchar(2000)` | 会员卡类型lids | 会员卡类型lids | YES | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券 | 优惠券 | YES | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,6)` | 赠送积分 | 赠送积分 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_card`

- 真实表：`crm_card`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员卡。
- 表含义：会员卡。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCard.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `join_time` | `datetime` | join时间 | 会员卡业务中的join时间。 | YES | NULL | 推断 |
| `balance` | `decimal(19,10)` | 余额 | 会员卡业务中的余额。 | YES | NULL | 推断 |
| `principal_balance` | `decimal(19,10)` | principal余额 | 会员卡业务中的principal余额。 | YES | NULL | 推断 |
| `give_balance` | `decimal(19,10)` | 赠送余额 | 会员卡业务中的赠送余额。 | YES | NULL | 推断 |
| `points` | `decimal(19,10)` | 积分 | 会员卡业务中的积分。 | YES | NULL | 推断 |
| `sum_of_save_times` | `int` | sumof储值times | 会员卡业务中的sumof储值times。 | YES | NULL | 推断 |
| `sum_of_save` | `decimal(19,10)` | sumof储值 | 会员卡业务中的sumof储值。 | YES | NULL | 推断 |
| `sum_of_consume` | `decimal(19,10)` | sumof消费 | 会员卡业务中的sumof消费。 | YES | NULL | 推断 |
| `sum_of_consume_times` | `int` | sumof消费times | 会员卡业务中的sumof消费times。 | YES | NULL | 推断 |
| `over_time` | `datetime` | over时间 | 会员卡业务中的over时间。 | YES | NULL | 推断 |
| `last_consume_time` | `datetime` | 上次消费时间 | 会员卡业务中的上次消费时间。 | YES | NULL | 推断 |
| `openid` | `varchar(255)` | OpenID | 会员卡业务中的OpenID。 | YES | NULL | 推断 |
| `unionid` | `varchar(255)` | UnionID | 会员卡业务中的UnionID。 | YES | NULL | 推断 |
| `appid` | `varchar(255)` | appid | 会员卡业务中的appid。 | YES | NULL | 推断 |
| `out_id` | `varchar(255)` | outID | 会员卡业务关联的outID。 | YES | NULL | 推断 |
| `headimgurl` | `varchar(255)` | headimgurl | 会员卡业务中的headimgurl。 | YES | NULL | 推断 |
| `pwd` | `varchar(255)` | pwd | 会员卡业务中的pwd。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 会员卡业务中的disable。 | YES | NULL | 推断 |
| `province` | `varchar(255)` | province | 会员卡业务中的province。 | YES | NULL | 推断 |
| `province_code` | `varchar(255)` | provincecode | 会员卡业务对象的provincecode。 | YES | NULL | 推断 |
| `city` | `varchar(255)` | city | 会员卡业务中的city。 | YES | NULL | 推断 |
| `city_code` | `varchar(255)` | citycode | 会员卡业务对象的citycode。 | YES | NULL | 推断 |
| `county` | `varchar(255)` | county | 会员卡业务中的county。 | YES | NULL | 推断 |
| `county_code` | `varchar(255)` | countycode | 会员卡业务对象的countycode。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `card_status` | `varchar(255)` | 会员卡状态 | 会员卡处理状态或启停状态。 | YES | NULL | 推断 |
| `Card_type_level` | `varchar(255)` | 会员卡类型等级 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_level_code` | `varchar(255)` | 会员卡类型等级code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Member` | `varchar(255)` | 会员 | 会员卡业务中的会员。 | YES | NULL | 推断 |
| `Member_code` | `varchar(255)` | 会员code | 会员卡业务对象的会员code。 | YES | NULL | 推断 |
| `Member_id_alias` | `varchar(255)` | 会员IDalias | 会员卡业务中的会员IDalias。 | YES | NULL | 推断 |
| `Phone` | `varchar(255)` | phone | 会员卡业务中的phone。 | YES | NULL | 推断 |
| `Agent_lmnid` | `varchar(255)` | agentlmnid | 会员卡业务中的agentlmnid。 | YES | NULL | 推断 |
| `Agent` | `varchar(255)` | agent | 会员卡业务中的agent。 | YES | NULL | 推断 |
| `invitees_lmnid` | `bigint` | 邀请人lid | 邀请人lid | YES | NULL | DB/DDL/实体注释 |
| `Invitees` | `varchar(255)` | invitees | 会员卡业务中的invitees。 | YES | NULL | 推断 |
| `Salesman_lmnid` | `varchar(255)` | salesmanlmnid | 会员卡业务中的salesmanlmnid。 | YES | NULL | 推断 |
| `Salesman` | `varchar(255)` | salesman | 会员卡业务中的salesman。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `Unpaid_amount` | `decimal(19,10)` | unpaid金额 | 会员卡业务中的unpaid金额。 | YES | NULL | 推断 |
| `Session_key` | `varchar(255)` | 会话键 | 会员卡业务中的会话键。 | YES | NULL | 推断 |
| `last_card_level_time` | `datetime` | 上次会员卡等级时间 | 会员卡业务中的上次会员卡等级时间。 | YES | NULL | 推断 |
| `Last_charge_time` | `datetime` | 最后一次充值时间 | 最后一次充值时间 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_points` | `decimal(24,6)` | 累计消费积分 | 累计消费积分 | YES | NULL | DB/DDL/实体注释 |
| `first_gift_coupon_done` | `tinyint(1)` | 首次充值已赠券 | 首次充值已赠券 | YES | NULL | DB/DDL/实体注释 |
| `wx_card_id` | `varchar(255)` | 微信卡券编号 | 微信卡券编号 | YES | NULL | DB/DDL/实体注释 |
| `back_balance` | `decimal(24,6)` | 返现余额 | 返现余额 | YES | 0.000000 | DB/DDL/实体注释 |
| `sum_of_back` | `decimal(24,6)` | 累计返现 | 累计返现 | YES | 0.000000 | DB/DDL/实体注释 |
| `sum_of_back_times` | `int` | 返现次数 | 返现次数 | YES | 0 | DB/DDL/实体注释 |
| `sum_of_save_give` | `decimal(24,6)` | 累计充值赠送金额 | 累计充值赠送金额 | YES | 0.000000 | DB/DDL/实体注释 |
| `sum_of_consume_give` | `decimal(24,6)` | 累计消费赠送金额 | 累计消费赠送金额 | YES | 0.000000 | DB/DDL/实体注释 |
| `dash_balance` | `decimal(24,6)` | 霸王餐余额 | 霸王餐余额 | NO | 0.000000 | DB/DDL/实体注释 |
| `unpaid_at` | `datetime` | 冻结金额时间 | 冻结金额时间 | YES | NULL | DB/DDL/实体注释 |
| `unpaid_give_amount` | `decimal(24,6)` | 未到账赠送金额 | 未到账赠送金额（冻结金额） | NO | 0.000000 | DB/DDL/实体注释 |
| `invoice_balance` | `decimal(24,6)` | 发票余额 | 发票余额 | NO | 0.000000 | DB/DDL/实体注释 |
| `rebate_ratio` | `decimal(24,6)` | 返佣比例 | 返佣比例 | NO | 0.000000 | DB/DDL/实体注释 |
| `rebate_rule_lid` | `bigint` | 返佣规则lid | 返佣规则lid | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `member` | `varchar` | 会员 | 会员卡业务中的会员。 |  |  | 推断 |
| `member_code` | `varchar` | 会员code | 会员卡业务对象的会员code。 |  |  | 推断 |
| `member_id_alias` | `varchar` | 会员IDalias | 会员卡业务中的会员IDalias。 |  |  | 推断 |
| `phone` | `varchar` | 手机号 | 会员或联系人手机号。 |  |  | 通用字段 |
| `agent_lmnid` | `bigint` | agentlmnid | 会员卡业务中的agentlmnid。 |  |  | 推断 |
| `agent` | `varchar` | agent | 会员卡业务中的agent。 |  |  | 推断 |
| `invitees` | `varchar` | invitees | 会员卡业务中的invitees。 |  |  | 推断 |
| `salesman_lmnid` | `bigint` | salesmanlmnid | 会员卡业务中的salesmanlmnid。 |  |  | 推断 |
| `salesman` | `varchar` | salesman | 会员卡业务中的salesman。 |  |  | 推断 |
| `card_type_level` | `varchar` | 会员卡类型等级 | 会员卡业务分类或类型。 |  |  | 推断 |
| `card_type_level_code` | `bigint` | 会员卡类型等级code | 会员卡业务分类或类型。 |  |  | 推断 |
| `unpaid_amount` | `decimal` | unpaid金额 | 会员卡业务中的unpaid金额。 |  |  | 推断 |
| `sum_of_blue` | `decimal` | sumofblue | 会员卡业务中的sumofblue。 |  |  | 推断 |
| `sum_of_blue_give` | `decimal` | sumofblue赠送 | 会员卡业务中的sumofblue赠送。 |  |  | 推断 |
| `sum_of_red` | `decimal` | sumofred | 会员卡业务中的sumofred。 |  |  | 推断 |
| `sum_of_red_give` | `decimal` | sumofred赠送 | 会员卡业务中的sumofred赠送。 |  |  | 推断 |
| `session_key` | `varchar` | 会话键 | 会员卡业务中的会话键。 |  |  | 推断 |

### a_crm

#### `crm_card_balance`

- 真实表：`crm_card_balance`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：卡余额
- 表含义：卡余额
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardBalance.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 充值门店号 | 充值门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `cno` | `bigint` | 卡号 | 卡号 | NO | NULL | DB/DDL/实体注释 |
| `total` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `principal` | `decimal(24,6)` | 本金 | 本金 | NO | NULL | DB/DDL/实体注释 |
| `gift` | `decimal(24,6)` | 赠送金额 | 赠送金额 | NO | NULL | DB/DDL/实体注释 |
| `source` | `int` | 来源 | 来源 | YES | NULL | DB/DDL/实体注释 |
| `out_trade_no` | `varchar(32)` | 业务单号 | 业务单号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |

#### `crm_card_cost_task`

- 真实表：`crm_card_cost_task`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：付费开卡记录
- 表含义：付费开卡记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardCostTask.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 会员名称 | 会员名称 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 会员手机号 | 会员手机号 | YES | NULL | DB/DDL/实体注释 |
| `sex` | `int` | 性别 | 性别 | NO | 0 | DB/DDL/实体注释 |
| `birthday` | `datetime` | 生日 | 生日 | YES | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(90)` | openID | openId | NO | NULL | DB/DDL/实体注释 |
| `union_id` | `varchar(90)` | unionID | unionId | YES | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员卡类型lid | 会员卡类型lid | NO | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(90)` | 会员卡类型 | 会员卡类型 | YES | NULL | DB/DDL/实体注释 |
| `cost` | `decimal(24,6)` | 开卡费 | 开卡费 | NO | NULL | DB/DDL/实体注释 |
| `pay_id` | `varchar(90)` | 支付终端号 | 支付终端号 | NO | NULL | DB/DDL/实体注释 |
| `finished` | `tinyint(1)` | 是否支付 | 是否支付 | NO | 0 | DB/DDL/实体注释 |
| `finished_at` | `datetime` | 支付完成时间 | 支付完成时间 | YES | NULL | DB/DDL/实体注释 |
| `join_at` | `datetime` | 开卡时间 | 开卡时间 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 券编号 | 券编号 | YES | NULL | DB/DDL/实体注释 |
| `coupon` | `varchar(255)` | 券名称 | 券名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_card_grade_record`

- 真实表：`crm_card_grade_record`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员卡升级和降级记录
- 表含义：会员卡升级和降级记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardGradeRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `member_name` | `varchar(255)` | 会员名称 | 会员名称 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 会员电话 | 会员电话 | YES | NULL | DB/DDL/实体注释 |
| `avatar` | `varchar(255)` | 头像 | 头像 | YES | NULL | DB/DDL/实体注释 |
| `card_id` | `varchar(255)` | 卡号 | 卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡lid | 会员卡lid | YES | NULL | DB/DDL/实体注释 |
| `member_lid` | `bigint` | 会员lid | 会员lid | YES | NULL | DB/DDL/实体注释 |
| `org_card_level` | `varchar(255)` | 原会员等级 | 原会员等级 | YES | NULL | DB/DDL/实体注释 |
| `org_card_level_lid` | `bigint` | 原会员等级lid | 原会员等级lid | YES | NULL | DB/DDL/实体注释 |
| `org_card_type` | `varchar(255)` | 原会卡类型 | 原会卡类型 | YES | NULL | DB/DDL/实体注释 |
| `org_card_type_lid` | `bigint` | 原会卡类型lid | 原会卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `cur_card_level` | `varchar(255)` | 当前会员等级 | 当前会员等级 | YES | NULL | DB/DDL/实体注释 |
| `cur_card_level_lid` | `bigint` | 当前会员等级lid | 当前会员等级lid | YES | NULL | DB/DDL/实体注释 |
| `cur_card_type` | `varchar(255)` | 当前会员类型 | 当前会员类型 | YES | NULL | DB/DDL/实体注释 |
| `cur_card_type_lid` | `bigint` | 当前会卡类型lid | 当前会卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 本次操作金额 | 本次操作金额 | YES | NULL | DB/DDL/实体注释 |
| `principal_amount` | `decimal(24,6)` | 本次操作本金 | 本次操作本金 | YES | NULL | DB/DDL/实体注释 |
| `give_amount` | `decimal(24,6)` | 本次操作赠送 | 本次操作赠送 | YES | NULL | DB/DDL/实体注释 |
| `balance` | `decimal(24,6)` | 总余额 | 总余额 | YES | NULL | DB/DDL/实体注释 |
| `principal_balance` | `decimal(24,6)` | 本金余额 | 本金余额 | YES | NULL | DB/DDL/实体注释 |
| `give_balance` | `decimal(24,6)` | 赠送余额 | 赠送余额 | YES | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,6)` | 积分余额 | 积分余额 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_save` | `decimal(24,6)` | 累计充值 | 累计充值 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_save_times` | `int` | 累计充值次数 | 累计充值次数 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_consume` | `decimal(24,6)` | 累计消费 | 累计消费 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_consume_times` | `int` | 累计消费次数 | 累计消费次数 | YES | NULL | DB/DDL/实体注释 |
| `sum_of_points` | `decimal(24,6)` | 累计积分 | 累计积分 | YES | NULL | DB/DDL/实体注释 |
| `grade_type` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `operator` | `varchar(255)` | 操作人 | 操作人 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_card_level`

- 真实表：`crm_card_level`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：卡等级。
- 表含义：卡等级。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardLevel.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型lid | 会员卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `logo` | `varchar(255)` | logo | 会员卡业务中的logo。 | YES | NULL | 推断 |
| `bg_img` | `varchar(255)` | bgimg | 会员卡业务中的bgimg。 | YES | NULL | 推断 |
| `font_color` | `varchar(255)` | fontcolor | 会员卡业务中的fontcolor。 | YES | NULL | 推断 |
| `bg_color` | `varchar(255)` | bgcolor | 会员卡业务中的bgcolor。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 会员卡业务中的说明。 | YES | NULL | 推断 |
| `upg_by_cumulative_consumption_amount` | `tinyint` | upg人cumulative消费金额 | 会员卡业务中的upg人cumulative消费金额。 | YES | NULL | 推断 |
| `cumulative_consumption_amount` | `decimal(19,10)` | cumulative消费金额 | 会员卡业务中的cumulative消费金额。 | YES | NULL | 推断 |
| `upg_by_cumulative_consumption_count` | `tinyint` | upg人cumulative消费次数 | 会员卡业务中的upg人cumulative消费次数。 | YES | NULL | 推断 |
| `cumulative_consumption_count` | `decimal(19,10)` | cumulative消费次数 | 会员卡业务中的cumulative消费次数。 | YES | NULL | 推断 |
| `upg_by_cumulative_consumption_amount_and_count` | `tinyint` | upg人cumulative消费金额and次数 | 会员卡业务中的upg人cumulative消费金额and次数。 | YES | NULL | 推断 |
| `upg_by_cumulative_save_amount` | `tinyint` | upg人cumulative储值金额 | 会员卡业务中的upg人cumulative储值金额。 | YES | NULL | 推断 |
| `cumulative_save_amount` | `decimal(19,10)` | cumulative储值金额 | 会员卡业务中的cumulative储值金额。 | YES | NULL | 推断 |
| `upg_by_earn_points` | `tinyint` | upg人earn积分 | 会员卡业务中的upg人earn积分。 | YES | NULL | 推断 |
| `earn_points` | `decimal(19,10)` | earn积分 | 会员卡业务中的earn积分。 | YES | NULL | 推断 |
| `upg_by_points_balance` | `tinyint` | upg人积分余额 | 会员卡业务中的upg人积分余额。 | YES | NULL | 推断 |
| `earn_balance` | `decimal(19,10)` | earn余额 | 会员卡业务中的earn余额。 | YES | NULL | 推断 |
| `deg_by_expiration_date` | `tinyint` | deg人expiration日期 | 会员卡业务中的deg人expiration日期。 | YES | NULL | 推断 |
| `expiration_date` | `decimal(19,10)` | expiration日期 | 会员卡业务中的expiration日期。 | YES | NULL | 推断 |
| `deg_by_balance` | `tinyint` | deg人余额 | 会员卡业务中的deg人余额。 | YES | NULL | 推断 |
| `balance` | `decimal(19,10)` | 余额 | 会员卡业务中的余额。 | YES | NULL | 推断 |
| `deg_by_consumption_limit` | `tinyint` | deg人消费限制 | 会员卡业务中的deg人消费限制。 | YES | NULL | 推断 |
| `consumption_limit_day` | `int` | 消费限制day | 会员卡业务中的消费限制day。 | YES | NULL | 推断 |
| `consumption_limit_amount` | `decimal(19,10)` | 消费限制金额 | 会员卡业务中的消费限制金额。 | YES | NULL | 推断 |
| `add_point_rule_amount` | `decimal(19,10)` | add积分规则金额 | 会员卡业务中的add积分规则金额。 | YES | NULL | 推断 |
| `add_point_rule_point` | `decimal(19,10)` | add积分规则积分 | 会员卡业务中的add积分规则积分。 | YES | NULL | 推断 |
| `add_point_rule_max_point_one_time` | `decimal(19,10)` | add积分规则max积分one时间 | 会员卡业务中的add积分规则max积分one时间。 | YES | NULL | 推断 |
| `discount_rate` | `decimal(19,10)` | 折扣比例 | 会员卡业务中的折扣比例。 | YES | NULL | 推断 |
| `discount_range` | `varchar(255)` | 折扣range | 会员卡业务中的折扣range。 | YES | NULL | 推断 |
| `member_price_discount_can_use_at_the_same_time` | `tinyint` | 会员价格折扣canuseatthesame时间 | 会员卡业务中的会员价格折扣canuseatthesame时间。 | YES | NULL | 推断 |
| `can_credit` | `tinyint` | cancredit | 会员卡业务中的cancredit。 | YES | NULL | 推断 |
| `can_use_member_price` | `tinyint` | canuse会员价格 | 会员卡业务中的canuse会员价格。 | YES | NULL | 推断 |
| `can_not_use_member_price_and_discount_when_balance_below` | `decimal(19,10)` | cannotuse会员价格and折扣when余额below | 会员卡业务对象的cannotuse会员价格and折扣when余额below。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `Level_upgrade_price` | `decimal(19,10)` | 等级upgrade价格 | 会员卡业务中的等级upgrade价格。 | YES | NULL | 推断 |
| `Coupon_code` | `varchar(255)` | 优惠券code | 会员卡业务对象的优惠券code。 | YES | NULL | 推断 |
| `Coupon` | `varchar(255)` | 优惠券 | 会员卡业务中的优惠券。 | YES | NULL | 推断 |
| `Coupon_pkg_code` | `varchar(255)` | 优惠券pkgcode | 会员卡业务对象的优惠券pkgcode。 | YES | NULL | 推断 |
| `Coupon_pkg` | `varchar(255)` | 优惠券pkg | 会员卡业务中的优惠券pkg。 | YES | NULL | 推断 |
| `Discount_code` | `varchar(32)` | 折扣code | 会员卡业务对象的折扣code。 | YES | NULL | 推断 |
| `Discount` | `varchar(128)` | 折扣 | 会员卡业务中的折扣。 | YES | NULL | 推断 |
| `discount_shop_id` | `bigint` | 折扣方式店铺编号 | 折扣方式店铺编号 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `coupon_code` | `varchar` | 优惠券code | 会员卡业务对象的优惠券code。 |  |  | 推断 |
| `coupon` | `varchar` | 优惠券 | 会员卡业务中的优惠券。 |  |  | 推断 |
| `coupon_pkg_code` | `varchar` | 优惠券pkgcode | 会员卡业务对象的优惠券pkgcode。 |  |  | 推断 |
| `coupon_pkg` | `varchar` | 优惠券pkg | 会员卡业务中的优惠券pkg。 |  |  | 推断 |
| `level_upgrade_price` | `decimal` | 等级upgrade价格 | 会员卡业务中的等级upgrade价格。 |  |  | 推断 |
| `discount` | `varchar` | 折扣 | 会员卡业务中的折扣。 |  |  | 推断 |
| `discount_code` | `varchar` | 折扣code | 会员卡业务对象的折扣code。 |  |  | 推断 |

#### `crm_card_level_and_cash_back`

- 真实表：`crm_card_level_and_cash_back`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员卡
- 表含义：会员卡相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardLevelAndCashBack.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `is_all_store` | `tinyint(1)` | 是否适用所有门店 | 是否适用所有门店：1-所有门店，0-指定门店，NULL-兼容旧单门店规则 | YES | NULL | DB/DDL/实体注释 |
| `store_sids` | `json` | 门店sids | 适用门店ID列表，JSON数组；is_all_store=0时生效 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level` | `varchar(255)` | 会员卡类型等级 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level_code` | `varchar(255)` | 会员卡类型等级code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `min_amount` | `decimal(19,10)` | min金额 | 会员卡业务中的min金额。 | YES | NULL | 推断 |
| `max_amount` | `decimal(19,10)` | max金额 | 会员卡业务中的max金额。 | YES | NULL | 推断 |
| `cash_back_type` | `int` | 现金返还类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `cash_back_amount` | `decimal(19,10)` | 现金返还金额 | 会员卡业务中的现金返还金额。 | YES | NULL | 推断 |
| `cash_back_amount_rate` | `decimal(19,10)` | 现金返还金额比例 | 会员卡业务中的现金返还金额比例。 | YES | NULL | 推断 |
| `cash_back_max_amount` | `decimal(19,10)` | 现金返还max金额 | 会员卡业务中的现金返还max金额。 | YES | NULL | 推断 |
| `Valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 | YES | NULL | 推断 |
| `Valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 | YES | NULL | 推断 |
| `Deferred_day_num` | `int` | deferredday数量 | 会员卡业务中的deferredday数量。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 |  |  | 推断 |
| `deferred_day_num` | `int` | deferredday数量 | 会员卡业务中的deferredday数量。 |  |  | 推断 |
| `valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 |  |  | 推断 |

#### `crm_card_level_and_more_recharge`

- 真实表：`crm_card_level_and_more_recharge`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员卡
- 表含义：会员卡相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardLevelAndMoreRecharge.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level` | `varchar(255)` | 会员卡类型等级 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level_code` | `varchar(255)` | 会员卡类型等级code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `min_amount` | `decimal(19,10)` | min金额 | 会员卡业务中的min金额。 | YES | NULL | 推断 |
| `max_amount` | `decimal(19,10)` | max金额 | 会员卡业务中的max金额。 | YES | NULL | 推断 |
| `more_recharge_rate` | `decimal(19,10)` | more充值比例 | 会员卡业务中的more充值比例。 | YES | NULL | 推断 |
| `give_type` | `int` | 赠送类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `give_amount` | `decimal(19,10)` | 赠送金额 | 会员卡业务中的赠送金额。 | YES | NULL | 推断 |
| `give_amount_rate` | `decimal(19,10)` | 赠送金额比例 | 会员卡业务中的赠送金额比例。 | YES | NULL | 推断 |
| `give_max_amount` | `decimal(19,10)` | 赠送max金额 | 会员卡业务中的赠送max金额。 | YES | NULL | 推断 |
| `Valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 | YES | NULL | 推断 |
| `Valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 | YES | NULL | 推断 |
| `Enable_preset_recharge` | `tinyint` | enablepreset充值 | 会员卡业务中的enablepreset充值。 | YES | NULL | 推断 |
| `Preset_recharge_amount` | `decimal(19,10)` | preset充值金额 | 会员卡业务中的preset充值金额。 | YES | NULL | 推断 |
| `apply_to_store` | `varchar(2000)` | 适用门店 | 适用门店 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 |  |  | 推断 |
| `enable_preset_recharge` | `tinyint(1)` | enablepreset充值 | 会员卡业务中的enablepreset充值。 |  |  | 推断 |
| `preset_recharge_amount` | `decimal` | preset充值金额 | 会员卡业务中的preset充值金额。 |  |  | 推断 |
| `valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 |  |  | 推断 |

#### `crm_card_level_and_overlord_meal`

- 真实表：`crm_card_level_and_overlord_meal`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：霸王餐。
- 表含义：霸王餐。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardLevelAndOverlordMeal.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level` | `varchar(255)` | 会员卡类型等级 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level_code` | `varchar(255)` | 会员卡类型等级code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `min_amount` | `decimal(19,10)` | min金额 | 会员卡业务中的min金额。 | YES | NULL | 推断 |
| `max_amount` | `decimal(19,10)` | max金额 | 会员卡业务中的max金额。 | YES | NULL | 推断 |
| `recharge_multiple_times` | `int` | 充值multipletimes | 会员卡业务中的充值multipletimes。 | YES | NULL | 推断 |
| `Valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 | YES | NULL | 推断 |
| `Valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 | YES | NULL | 推断 |
| `remarks` | `text` | remarks | 会员卡业务中的remarks。 | YES | NULL | 推断 |
| `once` | `tinyint(1)` | 仅限参与一次 | 仅限参与一次 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 |  |  | 推断 |
| `valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 |  |  | 推断 |

### a_crm

#### `crm_card_map`

- 真实表：`crm_card_map`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：卡记录
- 表含义：卡记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardMap.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡的lid | 会员卡的lid | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 类型 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 编号 | 编号(手机号、openid、或者实体卡号) | NO | NULL | DB/DDL/实体注释 |
| `unionid` | `varchar(32)` | UnionID | unionid | YES | NULL | DB/DDL/实体注释 |
| `appid` | `varchar(32)` | appid | appid | YES | NULL | DB/DDL/实体注释 |
| `pwd` | `varchar(255)` | 密码 | 密码 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unionid_plus` | `varchar(32)` | UnionIDplus | 会员卡业务中的UnionIDplus。 | YES | NULL | 推断 |

### gylregdb

#### `crm_card_op_record`

- 真实表：`crm_card_op_record`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：卡操作记录。
- 表含义：卡操作记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardOpRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 会员卡业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 会员卡业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 会员卡业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 会员卡业务中的day。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 会员卡业务中的create时间。 | YES | NULL | 推断 |
| `member_name` | `varchar(255)` | 会员姓名 | 会员姓名或昵称。 | YES | NULL | 通用字段 |
| `member_id` | `varchar(255)` | 会员ID | 会员记录编号。 | YES | NULL | 通用字段 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `card_id` | `varchar(255)` | 会员卡ID | 会员卡记录 ID。 | YES | NULL | 通用字段 |
| `card_out_id` | `varchar(255)` | 会员卡outID | 会员卡业务关联的会员卡outID。 | YES | NULL | 推断 |
| `operation_model` | `varchar(255)` | operationmodel | 会员卡业务中的operationmodel。 | YES | NULL | 推断 |
| `operator` | `varchar(255)` | operator | 会员卡业务中的operator。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 会员卡业务中的comment。 | YES | NULL | 推断 |
| `Member_id_alias` | `varchar(255)` | 会员IDalias | 会员卡业务中的会员IDalias。 | YES | NULL | 推断 |
| `Card_id_alias` | `varchar(255)` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 | YES | NULL | 推断 |
| `Card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `member_id_alias` | `varchar` | 会员IDalias | 会员卡业务中的会员IDalias。 |  |  | 推断 |
| `card_id_alias` | `varchar` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 |  |  | 推断 |
| `card_type` | `varchar` | 会员卡类型 | 会员卡业务分类或类型。 |  |  | 推断 |
| `card_type_code` | `varchar` | 会员卡类型code | 会员卡业务分类或类型。 |  |  | 推断 |

#### `crm_card_points_record`

- 真实表：`crm_card_points_record`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：积分记录。
- 表含义：积分记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardPointsRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 会员卡业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 会员卡业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 会员卡业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 会员卡业务中的day。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺name | 会员卡业务对象的店铺name。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 会员卡业务中的create时间。 | YES | NULL | 推断 |
| `member_name` | `varchar(255)` | 会员姓名 | 会员姓名或昵称。 | YES | NULL | 通用字段 |
| `member_id` | `varchar(255)` | 会员ID | 会员记录编号。 | YES | NULL | 通用字段 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `card_id` | `varchar(255)` | 会员卡ID | 会员卡记录 ID。 | YES | NULL | 通用字段 |
| `card_out_id` | `varchar(255)` | 会员卡outID | 会员卡业务关联的会员卡outID。 | YES | NULL | 推断 |
| `operation_model` | `varchar(255)` | operationmodel | 会员卡业务中的operationmodel。 | YES | NULL | 推断 |
| `operator` | `varchar(255)` | operator | 会员卡业务中的operator。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 会员卡业务中的comment。 | YES | NULL | 推断 |
| `balance_before` | `decimal(19,10)` | 余额before | 会员卡业务中的余额before。 | YES | NULL | 推断 |
| `balance_after` | `decimal(19,10)` | 余额after | 会员卡业务中的余额after。 | YES | NULL | 推断 |
| `amount` | `decimal(19,10)` | 金额 | 会员卡业务中的金额。 | YES | NULL | 推断 |
| `save_rule` | `varchar(255)` | 储值规则 | 会员卡业务中的储值规则。 | YES | NULL | 推断 |
| `save_rule_code` | `varchar(255)` | 储值规则code | 会员卡业务对象的储值规则code。 | YES | NULL | 推断 |
| `order_bill_id` | `varchar(255)` | 订单账单ID | 会员卡业务关联的订单账单ID。 | YES | NULL | 推断 |
| `Member_id_alias` | `varchar(255)` | 会员IDalias | 会员卡业务中的会员IDalias。 | YES | NULL | 推断 |
| `Card_id_alias` | `varchar(255)` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 | YES | NULL | 推断 |
| `Card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Tran_source` | `varchar(255)` | tran来源 | 会员卡业务中的tran来源。 | YES | NULL | 推断 |
| `Subject` | `varchar(255)` | subject | 会员卡业务中的subject。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `Out_order_bill_id` | `varchar(255)` | out订单账单ID | 会员卡业务关联的out订单账单ID。 | YES | NULL | 推断 |
| `Is_third_party` | `tinyint` | isthirdparty | 标记会员卡业务是否启用或满足isthirdparty条件。 | YES | NULL | 推断 |
| `If_deal_success` | `tinyint` | ifdealsuccess | 会员卡业务中的ifdealsuccess。 | YES | NULL | 推断 |
| `related_points_record_lid` | `bigint` | 关联积分流水LID | 关联积分流水LID | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `member_id_alias` | `varchar` | 会员IDalias | 会员卡业务中的会员IDalias。 |  |  | 推断 |
| `card_id_alias` | `varchar` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 |  |  | 推断 |
| `card_type` | `varchar` | 会员卡类型 | 会员卡业务分类或类型。 |  |  | 推断 |
| `card_type_code` | `bigint` | 会员卡类型code | 会员卡业务分类或类型。 |  |  | 推断 |
| `tran_source` | `varchar` | tran来源 | 会员卡业务中的tran来源。 |  |  | 推断 |
| `subject` | `varchar` | subject | 会员卡业务中的subject。 |  |  | 推断 |
| `is_third_party` | `tinyint(1)` | isthirdparty | 标记会员卡业务是否启用或满足isthirdparty条件。 |  |  | 推断 |
| `out_order_bill_id` | `varchar` | out订单账单ID | 会员卡业务关联的out订单账单ID。 |  |  | 推断 |
| `if_deal_success` | `tinyint(1)` | ifdealsuccess | 会员卡业务中的ifdealsuccess。 |  |  | 推断 |

#### `crm_card_record`

- 真实表：`crm_card_record`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：卡流水记录。
- 表含义：卡流水记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 会员卡业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 会员卡业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 会员卡业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 会员卡业务中的day。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺name | 会员卡业务对象的店铺name。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 会员卡业务中的create时间。 | YES | NULL | 推断 |
| `member_name` | `varchar(255)` | 会员姓名 | 会员姓名或昵称。 | YES | NULL | 通用字段 |
| `member_id` | `varchar(255)` | 会员ID | 会员记录编号。 | YES | NULL | 通用字段 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `card_id` | `varchar(255)` | 会员卡ID | 会员卡记录 ID。 | YES | NULL | 通用字段 |
| `card_out_id` | `varchar(255)` | 会员卡outID | 会员卡业务关联的会员卡outID。 | YES | NULL | 推断 |
| `operation_model` | `varchar(255)` | operationmodel | 会员卡业务中的operationmodel。 | YES | NULL | 推断 |
| `operator` | `varchar(255)` | operator | 会员卡业务中的operator。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 会员卡业务中的comment。 | YES | NULL | 推断 |
| `balance_before` | `decimal(19,10)` | 余额before | 会员卡业务中的余额before。 | YES | NULL | 推断 |
| `balance_after` | `decimal(19,10)` | 余额after | 会员卡业务中的余额after。 | YES | NULL | 推断 |
| `principal_amount` | `decimal(19,10)` | principal金额 | 会员卡业务中的principal金额。 | YES | NULL | 推断 |
| `give_amount` | `decimal(19,10)` | 赠送金额 | 会员卡业务中的赠送金额。 | YES | NULL | 推断 |
| `amount` | `decimal(19,10)` | 金额 | 会员卡业务中的金额。 | YES | NULL | 推断 |
| `save_rule` | `varchar(255)` | 储值规则 | 会员卡业务中的储值规则。 | YES | NULL | 推断 |
| `save_rule_code` | `varchar(255)` | 储值规则code | 会员卡业务对象的储值规则code。 | YES | NULL | 推断 |
| `pay_way` | `varchar(255)` | 支付way | 会员卡业务中的支付way。 | YES | NULL | 推断 |
| `pay_way_code` | `varchar(255)` | 支付waycode | 会员卡业务对象的支付waycode。 | YES | NULL | 推断 |
| `order_bill_id` | `varchar(255)` | 订单账单ID | 会员卡业务关联的订单账单ID。 | YES | NULL | 推断 |
| `invoice_amount` | `decimal(19,10)` | 发票金额 | 会员卡业务中的发票金额。 | YES | NULL | 推断 |
| `give_point` | `decimal(19,10)` | 赠送积分 | 会员卡业务中的赠送积分。 | YES | NULL | 推断 |
| `Principal_amount_before` | `decimal(19,10)` | principal金额before | 会员卡业务中的principal金额before。 | YES | NULL | 推断 |
| `Principal_amount_after` | `decimal(19,10)` | principal金额after | 会员卡业务中的principal金额after。 | YES | NULL | 推断 |
| `Give_amount_before` | `decimal(19,10)` | 赠送金额before | 会员卡业务中的赠送金额before。 | YES | NULL | 推断 |
| `Give_amount_after` | `decimal(19,10)` | 赠送金额after | 会员卡业务中的赠送金额after。 | YES | NULL | 推断 |
| `Recharge_number` | `int` | 充值数量 | 会员卡业务中的充值数量。 | YES | NULL | 推断 |
| `Member_id_alias` | `varchar(255)` | 会员IDalias | 会员卡业务中的会员IDalias。 | YES | NULL | 推断 |
| `Card_id_alias` | `varchar(255)` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 | YES | NULL | 推断 |
| `Card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Subject` | `varchar(255)` | subject | 会员卡业务中的subject。 | YES | NULL | 推断 |
| `Source` | `varchar(255)` | 来源 | 会员卡业务中的来源。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `Is_refund` | `tinyint` | is退款 | 标记会员卡业务是否启用或满足is退款条件。 | YES | NULL | 推断 |
| `Is_cancel` | `tinyint` | iscancel | 标记会员卡业务是否启用或满足iscancel条件。 | YES | NULL | 推断 |
| `Out_order_bill_id` | `varchar(255)` | out订单账单ID | 会员卡业务关联的out订单账单ID。 | YES | NULL | 推断 |
| `Is_third_party` | `tinyint` | isthirdparty | 标记会员卡业务是否启用或满足isthirdparty条件。 | YES | NULL | 推断 |
| `If_deal_success` | `tinyint` | ifdealsuccess | 会员卡业务中的ifdealsuccess。 | YES | NULL | 推断 |
| `Give_coupon` | `varchar(255)` | 赠送优惠券 | 会员卡业务中的赠送优惠券。 | YES | NULL | 推断 |
| `Give_coupon_id` | `varchar(255)` | 赠送优惠券ID | 会员卡业务关联的赠送优惠券ID。 | YES | NULL | 推断 |
| `Marketer` | `varchar(255)` | marketer | 会员卡业务中的marketer。 | YES | NULL | 推断 |
| `Commission_amount` | `decimal(15,4)` | commission金额 | 会员卡业务中的commission金额。 | YES | NULL | 推断 |
| `Commission_ratio` | `decimal(15,4)` | commission比例 | 会员卡业务中的commission比例。 | YES | NULL | 推断 |
| `Marketer_id` | `varchar(255)` | marketerID | 会员卡业务关联的marketerID。 | YES | NULL | 推断 |
| `source_sid` | `bigint` | 源门店号 | 源门店号 | YES | NULL | DB/DDL/实体注释 |
| `task_lid` | `bigint` | 任务ID | 会员卡业务关联的任务ID。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `member_id_alias` | `varchar` | 会员IDalias | 会员卡业务中的会员IDalias。 |  |  | 推断 |
| `card_id_alias` | `varchar` | 会员卡IDalias | 会员卡业务中的会员卡IDalias。 |  |  | 推断 |
| `card_type` | `varchar` | 会员卡类型 | 会员卡业务分类或类型。 |  |  | 推断 |
| `card_type_code` | `varchar` | 会员卡类型code | 会员卡业务分类或类型。 |  |  | 推断 |
| `principal_amount_before` | `decimal` | principal金额before | 会员卡业务中的principal金额before。 |  |  | 推断 |
| `principal_amount_after` | `decimal` | principal金额after | 会员卡业务中的principal金额after。 |  |  | 推断 |
| `give_amount_before` | `decimal` | 赠送金额before | 会员卡业务中的赠送金额before。 |  |  | 推断 |
| `give_amount_after` | `decimal` | 赠送金额after | 会员卡业务中的赠送金额after。 |  |  | 推断 |
| `recharge_number` | `int` | 充值数量 | 会员卡业务中的充值数量。 |  |  | 推断 |
| `is_refund` | `tinyint(1)` | is退款 | 标记会员卡业务是否启用或满足is退款条件。 |  |  | 推断 |
| `is_cancel` | `tinyint(1)` | iscancel | 标记会员卡业务是否启用或满足iscancel条件。 |  |  | 推断 |
| `subject` | `varchar` | subject | 会员卡业务中的subject。 |  |  | 推断 |
| `is_third_party` | `tinyint(1)` | isthirdparty | 标记会员卡业务是否启用或满足isthirdparty条件。 |  |  | 推断 |
| `out_order_bill_id` | `varchar` | out订单账单ID | 会员卡业务关联的out订单账单ID。 |  |  | 推断 |
| `if_deal_success` | `tinyint(1)` | ifdealsuccess | 会员卡业务中的ifdealsuccess。 |  |  | 推断 |
| `source` | `varchar` | 来源 | 会员卡业务中的来源。 |  |  | 推断 |
| `give_coupon` | `varchar` | 赠送优惠券 | 会员卡业务中的赠送优惠券。 |  |  | 推断 |
| `give_coupon_id` | `varchar` | 赠送优惠券ID | 会员卡业务关联的赠送优惠券ID。 |  |  | 推断 |
| `marketer` | `varchar` | marketer | 会员卡业务中的marketer。 |  |  | 推断 |
| `commission_amount` | `decimal` | commission金额 | 会员卡业务中的commission金额。 |  |  | 推断 |
| `commission_ratio` | `decimal` | commission比例 | 会员卡业务中的commission比例。 |  |  | 推断 |

#### `crm_card_type`

- 真实表：`crm_card_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：卡类型。
- 表含义：卡类型。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `kind` | `varchar(255)` | kind | 会员卡业务中的kind。 | YES | NULL | 推断 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `logo` | `varchar(255)` | logo | 会员卡业务中的logo。 | YES | NULL | 推断 |
| `bg_img` | `varchar(255)` | bgimg | 会员卡业务中的bgimg。 | YES | NULL | 推断 |
| `font_color` | `varchar(255)` | fontcolor | 会员卡业务中的fontcolor。 | YES | NULL | 推断 |
| `bg_color` | `varchar(255)` | bgcolor | 会员卡业务中的bgcolor。 | YES | NULL | 推断 |
| `description` | `text` | 说明 | 会员卡业务中的说明。 | YES | NULL | 推断 |
| `points_to_cash_point` | `decimal(19,10)` | 积分to现金积分 | 会员卡业务中的积分to现金积分。 | YES | NULL | 推断 |
| `points_to_cash_money` | `decimal(19,10)` | 积分to现金money | 会员卡业务中的积分to现金money。 | YES | NULL | 推断 |
| `points_to_cash_max_rule` | `varchar(255)` | 积分to现金max规则 | 会员卡业务中的积分to现金max规则。 | YES | NULL | 推断 |
| `points_to_cash_max` | `decimal(19,10)` | 积分to现金max | 会员卡业务中的积分to现金max。 | YES | NULL | 推断 |
| `points_to_cash_rule` | `varchar(255)` | 积分to现金规则 | 会员卡业务中的积分to现金规则。 | YES | NULL | 推断 |
| `points_to_cash_min` | `decimal(19,10)` | 积分to现金min | 会员卡业务中的积分to现金min。 | YES | NULL | 推断 |
| `offline_cost` | `decimal(19,10)` | offlinecost | 会员卡业务中的offlinecost。 | YES | NULL | 推断 |
| `online_cost` | `decimal(19,10)` | onlinecost | 会员卡业务中的onlinecost。 | YES | NULL | 推断 |
| `deposit` | `decimal(19,10)` | 储值 | 会员卡业务中的储值。 | YES | NULL | 推断 |
| `save_amount_while_apply` | `decimal(19,10)` | 储值金额whileapply | 会员卡业务中的储值金额whileapply。 | YES | NULL | 推断 |
| `deduction_rule` | `varchar(255)` | deduction规则 | 会员卡业务中的deduction规则。 | YES | NULL | 推断 |
| `enable_on_line_save` | `tinyint` | enableonline储值 | 会员卡业务中的enableonline储值。 | YES | NULL | 推断 |
| `enable_on_line_deduction` | `tinyint` | enableonlinededuction | 会员卡业务中的enableonlinededuction。 | YES | NULL | 推断 |
| `use_rule` | `varchar(255)` | use规则 | 会员卡业务中的use规则。 | YES | NULL | 推断 |
| `save_desc` | `varchar(255)` | 储值desc | 会员卡业务中的储值desc。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 会员卡业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 会员卡业务中的pidtmp。 | YES | NULL | 推断 |
| `pay_by_rate` | `decimal(19,10)` | 支付人比例 | 会员卡业务中的支付人比例。 | YES | NULL | 推断 |
| `Default_card_type` | `tinyint` | default会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `Upg_by_cumulative_consumption_amount` | `tinyint` | upg人cumulative消费金额 | 会员卡业务中的upg人cumulative消费金额。 | YES | NULL | 推断 |
| `Cumulative_consumption_amount` | `decimal(19,10)` | cumulative消费金额 | 会员卡业务中的cumulative消费金额。 | YES | NULL | 推断 |
| `Upg_by_cumulative_consumption_count` | `tinyint` | upg人cumulative消费次数 | 会员卡业务中的upg人cumulative消费次数。 | YES | NULL | 推断 |
| `Cumulative_consumption_count` | `decimal(19,10)` | cumulative消费次数 | 会员卡业务中的cumulative消费次数。 | YES | NULL | 推断 |
| `Upg_by_cumulative_save_amount` | `tinyint` | upg人cumulative储值金额 | 会员卡业务中的upg人cumulative储值金额。 | YES | NULL | 推断 |
| `Cumulative_save_amount` | `decimal(19,10)` | cumulative储值金额 | 会员卡业务中的cumulative储值金额。 | YES | NULL | 推断 |
| `Upg_by_earn_points` | `tinyint` | upg人earn积分 | 会员卡业务中的upg人earn积分。 | YES | NULL | 推断 |
| `Earn_points` | `decimal(19,10)` | earn积分 | 会员卡业务中的earn积分。 | YES | NULL | 推断 |
| `Upg_by_points_balance` | `tinyint` | upg人积分余额 | 会员卡业务中的upg人积分余额。 | YES | NULL | 推断 |
| `Earn_balance` | `decimal(19,10)` | earn余额 | 会员卡业务中的earn余额。 | YES | NULL | 推断 |
| `Deg_by_expiration_date` | `tinyint` | deg人expiration日期 | 会员卡业务中的deg人expiration日期。 | YES | NULL | 推断 |
| `Expiration_date` | `decimal(19,10)` | expiration日期 | 会员卡业务中的expiration日期。 | YES | NULL | 推断 |
| `Deg_by_balance` | `tinyint` | deg人余额 | 会员卡业务中的deg人余额。 | YES | NULL | 推断 |
| `Balance` | `decimal(19,10)` | 余额 | 会员卡业务中的余额。 | YES | NULL | 推断 |
| `Deg_by_consumption_limit` | `tinyint` | deg人消费限制 | 会员卡业务中的deg人消费限制。 | YES | NULL | 推断 |
| `Consumption_limit_day` | `int` | 消费限制day | 会员卡业务中的消费限制day。 | YES | NULL | 推断 |
| `Consumption_limit_amount` | `decimal(19,10)` | 消费限制金额 | 会员卡业务中的消费限制金额。 | YES | NULL | 推断 |
| `discount_code` | `varchar(255)` | 折扣code | 会员卡业务对象的折扣code。 | YES | NULL | 推断 |
| `discount_name` | `varchar(255)` | 折扣name | 会员卡业务对象的折扣name。 | YES | NULL | 推断 |
| `integral_plan_code` | `varchar(255)` | integralplancode | 会员卡业务对象的integralplancode。 | YES | NULL | 推断 |
| `integral_plan_name` | `varchar(255)` | integralplanname | 会员卡业务对象的integralplanname。 | YES | NULL | 推断 |
| `by_recharge_validity_demote` | `tinyint` | 通过充值有效期降级 | 通过充值有效期降级 | YES | NULL | DB/DDL/实体注释 |
| `recharge_validity_days` | `int` | 充值有效期天数 | 充值有效期天数 | YES | NULL | DB/DDL/实体注释 |
| `discount_shop_id` | `bigint` | 折扣方式店铺编号 | 折扣方式店铺编号 | YES | NULL | DB/DDL/实体注释 |
| `pay_rate_for_bill` | `decimal(24,6)` | 每次支付本账单的比例 | 每次支付本账单的比例 | YES | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 购卡送券 | 购卡送券 | YES | NULL | DB/DDL/实体注释 |
| `upgrade_h5_code` | `varchar(255)` | 升级h5地址 | 升级h5地址 | YES | NULL | DB/DDL/实体注释 |
| `upgrade_qr_code` | `varchar(255)` | 升级小程序二维码 | 升级小程序二维码 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `default_card_type` | `tinyint(1)` | default会员卡类型 | 会员卡业务分类或类型。 |  |  | 推断 |
| `upg_by_cumulative_consumption_amount` | `tinyint(1)` | upg人cumulative消费金额 | 会员卡业务中的upg人cumulative消费金额。 |  |  | 推断 |
| `cumulative_consumption_amount` | `decimal` | cumulative消费金额 | 会员卡业务中的cumulative消费金额。 |  |  | 推断 |
| `upg_by_cumulative_consumption_count` | `tinyint(1)` | upg人cumulative消费次数 | 会员卡业务中的upg人cumulative消费次数。 |  |  | 推断 |
| `cumulative_consumption_count` | `decimal` | cumulative消费次数 | 会员卡业务中的cumulative消费次数。 |  |  | 推断 |
| `upg_by_cumulative_save_amount` | `tinyint(1)` | upg人cumulative储值金额 | 会员卡业务中的upg人cumulative储值金额。 |  |  | 推断 |
| `cumulative_save_amount` | `decimal` | cumulative储值金额 | 会员卡业务中的cumulative储值金额。 |  |  | 推断 |
| `upg_by_earn_points` | `tinyint(1)` | upg人earn积分 | 会员卡业务中的upg人earn积分。 |  |  | 推断 |
| `earn_points` | `decimal` | earn积分 | 会员卡业务中的earn积分。 |  |  | 推断 |
| `upg_by_points_balance` | `tinyint(1)` | upg人积分余额 | 会员卡业务中的upg人积分余额。 |  |  | 推断 |
| `earn_balance` | `decimal` | earn余额 | 会员卡业务中的earn余额。 |  |  | 推断 |
| `deg_by_expiration_date` | `tinyint(1)` | deg人expiration日期 | 会员卡业务中的deg人expiration日期。 |  |  | 推断 |
| `expiration_date` | `decimal` | expiration日期 | 会员卡业务中的expiration日期。 |  |  | 推断 |
| `deg_by_balance` | `tinyint(1)` | deg人余额 | 会员卡业务中的deg人余额。 |  |  | 推断 |
| `balance` | `decimal` | 余额 | 会员卡业务中的余额。 |  |  | 推断 |
| `deg_by_consumption_limit` | `tinyint(1)` | deg人消费限制 | 会员卡业务中的deg人消费限制。 |  |  | 推断 |
| `consumption_limit_day` | `int` | 消费限制day | 会员卡业务中的消费限制day。 |  |  | 推断 |
| `consumption_limit_amount` | `decimal` | 消费限制金额 | 会员卡业务中的消费限制金额。 |  |  | 推断 |

#### `crm_card_type_free_rule`

- 真实表：`crm_card_type_free_rule`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员免赠规则
- 表含义：会员免赠规则
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardTypeFreeRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 规则名称 | 规则名称 | YES | NULL | DB/DDL/实体注释 |
| `card_type_code` | `bigint` | 会员编号 | 会员编号 | YES | NULL | DB/DDL/实体注释 |
| `free_times` | `int` | 免赠次数 | 免赠次数 | YES | NULL | DB/DDL/实体注释 |
| `food_list` | `varchar(4096)` | 菜品编号列表 | 菜品编号列表 | YES | NULL | DB/DDL/实体注释 |
| `start_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### a_crm

#### `crm_card_upgrade_record`

- 真实表：`crm_card_upgrade_record`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：购券/升级工本费记录
- 表含义：购券/升级工本费记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardUpgradeRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(90)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 会员卡号 | 会员卡号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 会员名称 | 会员名称 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 会员手机号 | 会员手机号 | YES | NULL | DB/DDL/实体注释 |
| `rule_name` | `varchar(90)` | 储值名称 | 储值名称 | NO | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 储值lid | 储值lid | NO | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员卡类型lid | 会员卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(90)` | 会员卡类型 | 会员卡类型 | YES | NULL | DB/DDL/实体注释 |
| `org_type_lid` | `bigint` | 原会员卡类型lid | 原会员卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `org_type` | `varchar(90)` | 原会员卡类型 | 原会员卡类型 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 工本费/购券金额 | 工本费/购券金额 | NO | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,6)` | 赠送积分 | 赠送积分 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 券编号 | 券编号 | YES | NULL | DB/DDL/实体注释 |
| `coupon` | `varchar(255)` | 券名称 | 券名称 | YES | NULL | DB/DDL/实体注释 |
| `coupon_num` | `int` | 赠券数量 | 赠券数量 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `cancel` | `tinyint(1)` | 是否撤销 | 是否撤销 | NO | 0 | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_at` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `task_lid` | `bigint` | 任务lid | 任务lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_card_wx_user`

- 真实表：`crm_card_wx_user`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员卡和微信会员的绑定关系
- 表含义：会员卡和微信会员的绑定关系
- 字段来源：`119-old`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡的lid | 会员卡的lid | YES | NULL | DB/DDL/实体注释 |
| `wx_user_lid` | `bigint` | 微信用户的lid | 微信用户的lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_cash_back`

- 真实表：`crm_card_level_and_cash_back`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员卡
- 表含义：会员卡相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardLevelAndCashBack.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `is_all_store` | `tinyint(1)` | 是否适用所有门店 | 是否适用所有门店：1-所有门店，0-指定门店，NULL-兼容旧单门店规则 | YES | NULL | DB/DDL/实体注释 |
| `store_sids` | `json` | 门店sids | 适用门店ID列表，JSON数组；is_all_store=0时生效 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level` | `varchar(255)` | 会员卡类型等级 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `card_type_level_code` | `varchar(255)` | 会员卡类型等级code | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 会员卡业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | 会员卡业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `min_amount` | `decimal(19,10)` | min金额 | 会员卡业务中的min金额。 | YES | NULL | 推断 |
| `max_amount` | `decimal(19,10)` | max金额 | 会员卡业务中的max金额。 | YES | NULL | 推断 |
| `cash_back_type` | `int` | 现金返还类型 | 会员卡业务分类或类型。 | YES | NULL | 推断 |
| `cash_back_amount` | `decimal(19,10)` | 现金返还金额 | 会员卡业务中的现金返还金额。 | YES | NULL | 推断 |
| `cash_back_amount_rate` | `decimal(19,10)` | 现金返还金额比例 | 会员卡业务中的现金返还金额比例。 | YES | NULL | 推断 |
| `cash_back_max_amount` | `decimal(19,10)` | 现金返还max金额 | 会员卡业务中的现金返还max金额。 | YES | NULL | 推断 |
| `Valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 | YES | NULL | 推断 |
| `Valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 | YES | NULL | 推断 |
| `Deferred_day_num` | `int` | deferredday数量 | 会员卡业务中的deferredday数量。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `valid_begin_time` | `datetime` | 有效开始时间 | 会员卡业务中的有效开始时间。 |  |  | 推断 |
| `deferred_day_num` | `int` | deferredday数量 | 会员卡业务中的deferredday数量。 |  |  | 推断 |
| `valid_end_time` | `datetime` | 有效结束时间 | 会员卡业务中的有效结束时间。 |  |  | 推断 |

#### `crm_cash_back_food`

- 真实表：`sc_mall_cash_back_food`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：不参与消费返现的菜品
- 表含义：不参与消费返现的菜品
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Dish` | `varchar(255)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `Dish_code` | `varchar(255)` | 物品编号 | 物品编号 | YES | NULL | DB/DDL/实体注释 |
| `Dish_type` | `varchar(255)` | 物品小类 | 物品小类 | YES | NULL | DB/DDL/实体注释 |
| `Dish_type_code` | `varchar(255)` | 物品小类编号 | 物品小类编号 | YES | NULL | DB/DDL/实体注释 |
| `Cash_back` | `varchar(255)` | 返现活动名称 | 返现活动名称 | YES | NULL | DB/DDL/实体注释 |
| `Cash_back_code` | `varchar(255)` | 返现活动编号 | 返现活动编号 | YES | NULL | DB/DDL/实体注释 |
| `Unit` | `varchar(255)` | 单位 | CRM会员业务中的单位。 | YES | NULL | 推断 |

#### `crm_consume_coupon_food`

- 真实表：`sc_mall_consume_coupon_food`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：消费赠券
- 表含义：消费赠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 消费赠券业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Dish` | `varchar(255)` | 菜品 | 消费赠券业务中的菜品。 | YES | NULL | 推断 |
| `Dish_code` | `varchar(255)` | 菜品code | 消费赠券业务对象的菜品code。 | YES | NULL | 推断 |
| `Dish_type` | `varchar(255)` | 菜品类型 | 消费赠券业务分类或类型。 | YES | NULL | 推断 |
| `Dish_type_code` | `varchar(255)` | 菜品类型code | 消费赠券业务分类或类型。 | YES | NULL | 推断 |
| `Coupon` | `varchar(255)` | 优惠券 | 消费赠券业务中的优惠券。 | YES | NULL | 推断 |
| `Coupon_code` | `varchar(255)` | 优惠券code | 消费赠券业务对象的优惠券code。 | YES | NULL | 推断 |
| `Unit` | `varchar(255)` | 单位 | 消费赠券业务中的单位。 | YES | NULL | 推断 |

### a_crm

#### `crm_consumption_coupon_limit`

- 真实表：`crm_consumption_coupon_limit`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：赠券限制
- 表含义：赠券限制
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmConsumptionCouponLimit.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开始时间段 | 开始时间段 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间段 | 结束时间段 | YES | NULL | DB/DDL/实体注释 |
| `week_type` | `int` | 周类型 | 周类型 | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 活动规则lid | 活动规则lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_consumption_coupon_rule`

- 真实表：`crm_consumption_coupon_rule`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：消费赠券
- 表含义：消费赠券
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmConsumptionCouponRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `is_all_store` | `tinyint(1)` | 是否适用所有门店 | 是否适用所有门店：1-所有门店，0-指定门店，NULL-兼容旧单门店规则 | YES | NULL | DB/DDL/实体注释 |
| `store_sids` | `json` | 门店sids | 适用门店ID列表，JSON数组；is_all_store=0时生效 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 消费赠劵名称 | 消费赠劵名称 | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券lid | 优惠券lid | NO | NULL | DB/DDL/实体注释 |
| `coupon_name` | `varchar(90)` | 优惠券名称 | 优惠券名称 | YES | NULL | DB/DDL/实体注释 |
| `full_amount` | `decimal(24,6)` | 优惠券金额 | 优惠券金额 | NO | NULL | DB/DDL/实体注释 |
| `amount_method` | `int` | 金额计算方式 | 金额计算方式 | NO | NULL | DB/DDL/实体注释 |
| `gift_quantity` | `int` | 赠券数量 | 赠券数量 | NO | NULL | DB/DDL/实体注释 |
| `term_of_validity_method` | `int` | 有效期限方式 | 有效期限方式 | NO | NULL | DB/DDL/实体注释 |
| `effective_method` | `int` | 相对期限生效方式 | 相对期限生效方式 | YES | NULL | DB/DDL/实体注释 |
| `effective_days` | `int` | 开始生效的天数 | 开始生效的天数 | YES | NULL | DB/DDL/实体注释 |
| `effective_time` | `int` | 开始生效的小时数 | 开始生效的小时数 | YES | NULL | DB/DDL/实体注释 |
| `start_effective_time` | `datetime` | 开始生效时间 | 开始生效时间 | YES | NULL | DB/DDL/实体注释 |
| `end_effective_time` | `datetime` | 结束生效时间 | 结束生效时间 | YES | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员卡类型lid | 会员卡类型lid | YES | NULL | DB/DDL/实体注释 |
| `card_type_level_lid` | `bigint` | 会员卡等级lid | 会员卡等级lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `gift_by_increase` | `tinyint(1)` | 是否按消费金额递增赠券 | 是否按消费金额递增赠券 | NO | 0 | DB/DDL/实体注释 |
| `gift_eve_amount` | `decimal(24,6)` | 依次递增赠券每满金额 | 依次递增赠券每满金额 | YES | NULL | DB/DDL/实体注释 |
| `gift_max_quantity` | `int` | 单次最多赠券数量 | 单次最多赠券数量 | NO | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_coupon`

- 真实表：`sc_mall_coupon`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：优惠券
- 表含义：优惠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `coupon_type` | `varchar(255)` | 优惠券类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `face_value` | `decimal(19,10)` | 面额值 | 优惠券业务中的面额值。 | YES | NULL | 推断 |
| `full_money` | `decimal(19,10)` | fullmoney | 优惠券业务中的fullmoney。 | YES | NULL | 推断 |
| `limit_number` | `decimal(19,10)` | 限制数量 | 优惠券业务中的限制数量。 | YES | NULL | 推断 |
| `receiving_limit_number` | `decimal(19,10)` | receiving限制数量 | 优惠券业务中的receiving限制数量。 | YES | NULL | 推断 |
| `begin_reception_time` | `datetime` | 开始reception时间 | 优惠券业务中的开始reception时间。 | YES | NULL | 推断 |
| `end_reception_time` | `datetime` | 结束reception时间 | 优惠券业务中的结束reception时间。 | YES | NULL | 推断 |
| `instructions` | `varchar(255)` | instructions | 优惠券业务中的instructions。 | YES | NULL | 推断 |
| `use_restriction` | `varchar(255)` | userestriction | 优惠券业务中的userestriction。 | YES | NULL | 推断 |
| `fixed_days` | `decimal(19,10)` | fixeddays | 优惠券业务中的fixeddays。 | YES | NULL | 推断 |
| `fixed_begin_date` | `datetime` | fixed开始日期 | 优惠券业务中的fixed开始日期。 | YES | NULL | 推断 |
| `fixed_end_date` | `datetime` | fixed结束日期 | 优惠券业务中的fixed结束日期。 | YES | NULL | 推断 |
| `fixed_begin_time` | `datetime` | fixed开始时间 | 优惠券业务中的fixed开始时间。 | YES | NULL | 推断 |
| `fixed_end_time` | `datetime` | fixed结束时间 | 优惠券业务中的fixed结束时间。 | YES | NULL | 推断 |
| `moday` | `tinyint` | moday | 优惠券业务中的moday。 | YES | NULL | 推断 |
| `tuesday` | `tinyint` | tuesday | 优惠券业务中的tuesday。 | YES | NULL | 推断 |
| `wednesday` | `tinyint` | wednesday | 优惠券业务中的wednesday。 | YES | NULL | 推断 |
| `thursday` | `tinyint` | thursday | 优惠券业务中的thursday。 | YES | NULL | 推断 |
| `friday` | `tinyint` | friday | 优惠券业务中的friday。 | YES | NULL | 推断 |
| `saturday` | `tinyint` | saturday | 优惠券业务中的saturday。 | YES | NULL | 推断 |
| `sunday` | `tinyint` | sunday | 优惠券业务中的sunday。 | YES | NULL | 推断 |
| `Dish_name` | `varchar(255)` | 菜品name | 优惠券业务对象的菜品name。 | YES | NULL | 推断 |
| `Dish_code` | `varchar(255)` | 菜品code | 优惠券业务对象的菜品code。 | YES | NULL | 推断 |
| `Begin_use_time` | `datetime` | 开始use时间 | 优惠券业务中的开始use时间。 | YES | NULL | 推断 |
| `End_use_time` | `datetime` | 结束use时间 | 优惠券业务中的结束use时间。 | YES | NULL | 推断 |
| `Maker` | `varchar(255)` | maker | 优惠券业务中的maker。 | YES | NULL | 推断 |
| `Make_time` | `datetime` | make时间 | 优惠券业务中的make时间。 | YES | NULL | 推断 |
| `Update_user` | `varchar(255)` | updateuser | 优惠券业务中的updateuser。 | YES | NULL | 推断 |
| `update_Time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `Is_all_store` | `tinyint` | isall门店 | 标记优惠券业务是否启用或满足isall门店条件。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 优惠券业务中的pidtmp。 | YES | NULL | 推断 |
| `Is_review` | `tinyint` | isreview | 标记优惠券业务是否启用或满足isreview条件。 | YES | NULL | 推断 |
| `Reviewer` | `varchar(255)` | reviewer | 优惠券业务中的reviewer。 | YES | NULL | 推断 |
| `Review_time` | `datetime` | review时间 | 优惠券业务中的review时间。 | YES | NULL | 推断 |
| `Is_terminator` | `tinyint` | isterminator | 标记优惠券业务是否启用或满足isterminator条件。 | YES | NULL | 推断 |
| `Terminator` | `varchar(255)` | terminator | 优惠券业务中的terminator。 | YES | NULL | 推断 |
| `Terminat_time` | `datetime` | terminat时间 | 优惠券业务中的terminat时间。 | YES | NULL | 推断 |
| `Received_number` | `decimal(19,10)` | received数量 | 优惠券业务中的received数量。 | YES | NULL | 推断 |
| `Is_pkg` | `tinyint` | ispkg | 标记优惠券业务是否启用或满足ispkg条件。 | YES | NULL | 推断 |
| `Img_url` | `varchar(255)` | imgurl | 优惠券业务中的imgurl。 | YES | NULL | 推断 |
| `Is_ad` | `tinyint` | isad | 标记优惠券业务是否启用或满足isad条件。 | YES | NULL | 推断 |
| `enable_direct_take` | `tinyint` | enabledirecttake | 优惠券业务中的enabledirecttake。 | YES | NULL | 推断 |
| `limit_use_day` | `int` | 限制useday | 优惠券业务中的限制useday。 | YES | NULL | 推断 |
| `limit_use_num` | `int` | 限制use数量 | 优惠券业务中的限制use数量。 | YES | NULL | 推断 |
| `Is_enable_purchase` | `tinyint` | isenablepurchase | 标记优惠券业务是否启用或满足isenablepurchase条件。 | YES | NULL | 推断 |
| `Purchase_price` | `decimal(19,10)` | purchase价格 | 优惠券业务中的purchase价格。 | YES | NULL | 推断 |
| `Original_price` | `decimal(19,10)` | 原始价格 | 优惠券业务中的原始价格。 | YES | NULL | 推断 |
| `Purchase_type` | `varchar(64)` | purchase类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `Purchase_limit_type` | `varchar(64)` | purchase限制类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `Start_purchase_time` | `datetime` | 开始purchase时间 | 优惠券业务中的开始purchase时间。 | YES | NULL | 推断 |
| `End_purchase_time` | `datetime` | 结束purchase时间 | 优惠券业务中的结束purchase时间。 | YES | NULL | 推断 |
| `Max_purchase_num` | `int` | maxpurchase数量 | 优惠券业务中的maxpurchase数量。 | YES | NULL | 推断 |
| `Every_day_max_purchase_num` | `int` | everydaymaxpurchase数量 | 优惠券业务中的everydaymaxpurchase数量。 | YES | NULL | 推断 |
| `Coupon_qr_code` | `varchar(255)` | 优惠券qrcode | 优惠券业务对象的优惠券qrcode。 | YES | NULL | 推断 |
| `Desc_img_url` | `varchar(255)` | descimgurl | 优惠券业务中的descimgurl。 | YES | NULL | 推断 |
| `Sold_growth_value` | `int` | soldgrowth值 | 优惠券业务中的soldgrowth值。 | YES | NULL | 推断 |
| `Sold_base_value` | `int` | soldbase值 | 优惠券业务中的soldbase值。 | YES | NULL | 推断 |
| `Popularity_growth_value` | `int` | popularitygrowth值 | 优惠券业务中的popularitygrowth值。 | YES | NULL | 推断 |
| `Popularity_base_value` | `int` | popularitybase值 | 优惠券业务中的popularitybase值。 | YES | NULL | 推断 |
| `Desc_img_url4` | `varchar(255)` | descimgurl4 | 优惠券业务中的descimgurl4。 | YES | NULL | 推断 |
| `Desc_img_url3` | `varchar(255)` | descimgurl3 | 优惠券业务中的descimgurl3。 | YES | NULL | 推断 |
| `Desc_img_url2` | `varchar(255)` | descimgurl2 | 优惠券业务中的descimgurl2。 | YES | NULL | 推断 |
| `Desc_img_url1` | `varchar(255)` | descimgurl1 | 优惠券业务中的descimgurl1。 | YES | NULL | 推断 |
| `Desc_img_url0` | `varchar(255)` | descimgurl0 | 优惠券业务中的descimgurl0。 | YES | NULL | 推断 |
| `Desc_font_size` | `int` | descfontsize | 优惠券业务中的descfontsize。 | YES | NULL | 推断 |
| `Pay_account_storce` | `varchar(255)` | 支付accountstorce | 优惠券业务中的支付accountstorce。 | YES | NULL | 推断 |
| `Coupon_weapp_code` | `varchar(255)` | 优惠券weappcode | 优惠券业务对象的优惠券weappcode。 | YES | NULL | 推断 |
| `Start_time_slot` | `datetime` | 开始时间slot | 优惠券业务中的开始时间slot。 | YES | NULL | 推断 |
| `End_time_slot` | `datetime` | 结束时间slot | 优惠券业务中的结束时间slot。 | YES | NULL | 推断 |
| `can_make_appointment` | `tinyint` | canmakeappointment | 优惠券业务中的canmakeappointment。 | YES | NULL | 推断 |
| `Coupon_mode` | `varchar(128)` | 模式，CP | 模式，CP:劵，RE:红包 | YES | NULL | DB/DDL/实体注释 |
| `face_value_method` | `varchar(128)` | 面值金额方式，GDF | 面值金额方式，GDF:固定面值，RDF:随机面值,GDP:固定比例，RDP:范围比例 | YES | NULL | DB/DDL/实体注释 |
| `face_value_min` | `decimal(19,10)` | 随机面值时，最低面值 | 随机面值时，最低面值 | YES | NULL | DB/DDL/实体注释 |
| `face_value_max` | `decimal(19,10)` | 随机面值时，最大面值 | 随机面值时，最大面值 | YES | NULL | DB/DDL/实体注释 |
| `can_transferable` | `tinyint` | 可转赠 | 可转赠 | YES | NULL | DB/DDL/实体注释 |
| `face_value_mantissa_method` | `varchar(64)` | 取整方式 | 取整方式 | YES | NULL | DB/DDL/实体注释 |
| `by_proportion_take_value` | `varchar(64)` | 通过概率获取随机面值 | 通过概率获取随机面值 | YES | NULL | DB/DDL/实体注释 |
| `begin_valid_days` | `decimal(19,10)` | 自领取日起开始生效的天数 | 自领取日起开始生效的天数 | YES | NULL | DB/DDL/实体注释 |
| `eve_full_money` | `decimal(19,10)` | 每满xxx金额就使用 | 每满xxx金额就使用 | YES | NULL | DB/DDL/实体注释 |
| `eve_full_max_times` | `int` | 每满xxx金额最多可使用xxx张 | 每满xxx金额最多可使用xxx张 | YES | NULL | DB/DDL/实体注释 |
| `dish_shop_id` | `bigint` | 实物券菜品所属店铺编号 | 实物券菜品所属店铺编号 | YES | NULL | DB/DDL/实体注释 |
| `base_map_url` | `varchar(255)` | 优惠券底图地址 | 优惠券底图地址 | YES | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(90)` | 商品单位 | 商品单位 | YES | NULL | DB/DDL/实体注释 |
| `every_day_limit_number` | `int` | 每天限领数量 | 每天限领数量 | YES | NULL | DB/DDL/实体注释 |
| `start_valid_time` | `datetime` | 优惠券开始生效日期 | 优惠券开始生效日期 | YES | NULL | DB/DDL/实体注释 |
| `dish_discount_type` | `varchar(32)` | 实物券单品优惠方式 | 实物券单品优惠方式：FREE免费兑换，DISCOUNT折扣，AMOUNT_OFF立减 | YES | NULL | DB/DDL/实体注释 |
| `dish_discount_value` | `decimal(19,2)` | 实物券单品优惠值 | 实物券单品优惠值：折扣券为几折，立减券为金额 | YES | NULL | DB/DDL/实体注释 |

### a_crm

#### `crm_coupon_dish`

- 真实表：`crm_coupon_dish`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：优惠券与菜品关联
- 表含义：优惠券与菜品关联
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCouponDish.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券lid | 优惠券lid | NO | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(90)` | 门店名称 | 门店名称 | NO | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品编号lid | 菜品编号lid | NO | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(90)` | 菜品名称 | 菜品名称 | NO | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(90)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_coupon_festival`

- 真实表：`sc_mall_coupon_festival`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：节假日与优惠券关联
- 表含义：节假日与优惠券关联
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 优惠券业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `coupon_code` | `bigint` | 优惠券编号 | 优惠券编号 | YES | NULL | DB/DDL/实体注释 |
| `coupon` | `varchar(255)` | 优惠券 | 优惠券 | YES | NULL | DB/DDL/实体注释 |
| `festival_code` | `bigint` | 节假日编号 | 节假日编号 | YES | NULL | DB/DDL/实体注释 |
| `festival` | `varchar(255)` | 节假日 | 节假日 | YES | NULL | DB/DDL/实体注释 |

#### `crm_coupon_hours`

- 真实表：`sc_mall_coupon_hours`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：优惠券
- 表含义：优惠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `hours_begin_time` | `datetime` | hours开始时间 | 优惠券业务中的hours开始时间。 | YES | NULL | 推断 |
| `hours_end_time` | `datetime` | hours结束时间 | 优惠券业务中的hours结束时间。 | YES | NULL | 推断 |
| `Coupon` | `varchar(255)` | 优惠券 | 优惠券业务中的优惠券。 | YES | NULL | 推断 |
| `Coupon_code` | `varchar(255)` | 优惠券code | 优惠券业务对象的优惠券code。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 优惠券业务中的pidtmp。 | YES | NULL | 推断 |

#### `crm_coupon_map`

- 真实表：`sc_mall_coupon_map`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：优惠券
- 表含义：优惠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `main_code` | `varchar(255)` | maincode | 优惠券业务对象的maincode。 | YES | NULL | 推断 |
| `deputy_code` | `varchar(255)` | deputycode | 优惠券业务对象的deputycode。 | YES | NULL | 推断 |
| `main` | `varchar(255)` | main | 优惠券业务中的main。 | YES | NULL | 推断 |
| `deputy` | `varchar(255)` | deputy | 优惠券业务中的deputy。 | YES | NULL | 推断 |
| `number` | `int` | 数量 | 优惠券业务中的数量。 | YES | NULL | 推断 |

#### `crm_coupon_order`

- 真实表：`sc_mall_coupon_order`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：优惠券
- 表含义：优惠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `pkg_coupon` | `varchar(255)` | pkg优惠券 | 优惠券业务中的pkg优惠券。 | YES | NULL | 推断 |
| `pkg_coupon_code` | `varchar(255)` | pkg优惠券code | 优惠券业务对象的pkg优惠券code。 | YES | NULL | 推断 |
| `coupon` | `varchar(255)` | 优惠券 | 优惠券业务中的优惠券。 | YES | NULL | 推断 |
| `coupon_code` | `varchar(255)` | 优惠券code | 优惠券业务对象的优惠券code。 | YES | NULL | 推断 |
| `type_` | `varchar(255)` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `deadline` | `datetime` | deadline | 优惠券业务中的deadline。 | YES | NULL | 推断 |
| `get_date` | `datetime` | get日期 | 优惠券业务中的get日期。 | YES | NULL | 推断 |
| `appid` | `varchar(255)` | appid | 优惠券业务中的appid。 | YES | NULL | 推断 |
| `openid` | `varchar(255)` | OpenID | 优惠券业务中的OpenID。 | YES | NULL | 推断 |
| `unionid` | `varchar(255)` | UnionID | 优惠券业务中的UnionID。 | YES | NULL | 推断 |
| `avatarurl` | `varchar(255)` | avatarurl | 优惠券业务中的avatarurl。 | YES | NULL | 推断 |
| `nickname` | `varchar(255)` | nickname | 优惠券业务对象的nickname。 | YES | NULL | 推断 |
| `write_off_staff` | `varchar(255)` | 核销staff | 优惠券业务中的核销staff。 | YES | NULL | 推断 |
| `write_off_time` | `datetime` | 核销时间 | 优惠券业务中的核销时间。 | YES | NULL | 推断 |
| `coupon_status` | `varchar(255)` | 优惠券状态 | 优惠券处理状态或启停状态。 | YES | NULL | 推断 |
| `member_code` | `varchar(255)` | 会员code | 优惠券业务对象的会员code。 | YES | NULL | 推断 |
| `member_id_alias` | `varchar(255)` | 会员IDalias | 优惠券业务中的会员IDalias。 | YES | NULL | 推断 |
| `member` | `varchar(255)` | 会员 | 优惠券业务中的会员。 | YES | NULL | 推断 |
| `used_time` | `datetime` | used时间 | 优惠券业务中的used时间。 | YES | NULL | 推断 |
| `Abandon_time` | `datetime` | abandon时间 | 优惠券业务中的abandon时间。 | YES | NULL | 推断 |
| `Abandon_staff` | `varchar(255)` | abandonstaff | 优惠券业务中的abandonstaff。 | YES | NULL | 推断 |
| `Get_channel` | `varchar(255)` | get渠道 | 优惠券业务中的get渠道。 | YES | NULL | 推断 |
| `can_make_appointment` | `tinyint` | canmakeappointment | 优惠券业务中的canmakeappointment。 | YES | NULL | 推断 |
| `time_of_appointment` | `datetime` | 时间ofappointment | 优惠券业务中的时间ofappointment。 | YES | NULL | 推断 |
| `Store_of_appointment` | `varchar(255)` | 门店ofappointment | 优惠券业务中的门店ofappointment。 | YES | NULL | 推断 |
| `Store_code_of_appointment` | `varchar(255)` | 门店codeofappointment | 优惠券业务对象的门店codeofappointment。 | YES | NULL | 推断 |
| `order_bill_id` | `varchar(255)` | 订单账单ID | 优惠券业务关联的订单账单ID。 | YES | NULL | 推断 |
| `Used_Shop_code` | `varchar(255)` | used店铺code | 优惠券业务对象的used店铺code。 | YES | NULL | 推断 |
| `Used_Shop` | `varchar(255)` | used店铺 | 优惠券业务中的used店铺。 | YES | NULL | 推断 |
| `coupon_mode` | `varchar(128)` | 模式，CP | 模式，CP:劵，RE:红包 | YES | NULL | DB/DDL/实体注释 |
| `face_value_method` | `varchar(128)` | 面值金额方式，GDF | 面值金额方式，GDF:固定面值，RDF:随机面值,GDP:固定比例，RDP:范围比例 | YES | NULL | DB/DDL/实体注释 |
| `face_value_min` | `decimal(19,10)` | 随机面值时，最低面值 | 随机面值时，最低面值 | YES | NULL | DB/DDL/实体注释 |
| `face_value_max` | `decimal(19,10)` | 随机面值时，最大面值 | 随机面值时，最大面值 | YES | NULL | DB/DDL/实体注释 |
| `face_value` | `decimal(19,10)` | 红包或者劵的面值 | 红包或者劵的面值（随机面值或按比例时使用） | YES | NULL | DB/DDL/实体注释 |
| `bill_amount` | `decimal(19,10)` | 消费单金额 | 消费单金额 | YES | NULL | DB/DDL/实体注释 |
| `proportion_min` | `decimal(19,10)` | 范围比例时，最低比例 | 范围比例时，最低比例 | YES | NULL | DB/DDL/实体注释 |
| `proportion_max` | `decimal(19,10)` | 范围比例时，最高比例 | 范围比例时，最高比例 | YES | NULL | DB/DDL/实体注释 |
| `can_transferable` | `tinyint` | 可转赠 | 可转赠 | YES | NULL | DB/DDL/实体注释 |
| `valid_date` | `datetime` | 领取的优惠券开始使用日期 | 领取的优惠券开始使用日期 | YES | NULL | DB/DDL/实体注释 |
| `start_valid_time` | `datetime` | 优惠券开始生效日期 | 优惠券开始生效日期 | YES | NULL | DB/DDL/实体注释 |
| `dish_discount_type` | `varchar(32)` | 领取时实物券单品优惠方式快照 | 领取时实物券单品优惠方式快照 | YES | NULL | DB/DDL/实体注释 |
| `dish_discount_value` | `decimal(19,2)` | 领取时实物券单品优惠值快照 | 领取时实物券单品优惠值快照 | YES | NULL | DB/DDL/实体注释 |

#### `crm_coupon_proportion_item`

- 真实表：`sc_coupon_proportion_item`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：红包/劵按单金额比例范围
- 表含义：红包/劵按单金额比例范围
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 优惠券业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `min_amount` | `decimal(19,10)` | 最低消费金额 | 最低消费金额 | YES | NULL | DB/DDL/实体注释 |
| `max_amount` | `decimal(19,10)` | 最高消费金额 | 最高消费金额 | YES | NULL | DB/DDL/实体注释 |
| `proportion_min` | `decimal(19,10)` | 最低赠送比例 | 最低赠送比例 | YES | NULL | DB/DDL/实体注释 |
| `proportion_max` | `decimal(19,10)` | 最高赠送比例 | 最高赠送比例 | YES | NULL | DB/DDL/实体注释 |
| `coupon_code` | `bigint` | 优惠券/红包编号 | 优惠券/红包编号 | NO | NULL | DB/DDL/实体注释 |
| `coupon` | `varchar(255)` | 优惠券/红包名称 | 优惠券/红包名称 | YES | NULL | DB/DDL/实体注释 |

#### `crm_coupon_purchase`

- 真实表：`sc_mall_coupon_purchase`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：优惠券
- 表含义：优惠券相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `coupon_code` | `varchar(255)` | 优惠券code | 优惠券业务对象的优惠券code。 | YES | NULL | 推断 |
| `coupon_name` | `varchar(255)` | 优惠券名称 | 优惠券业务对象的优惠券名称。 | YES | NULL | 推断 |
| `purchase_type` | `varchar(64)` | purchase类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `purchase_limit_type` | `varchar(64)` | purchase限制类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `original_price` | `decimal(19,10)` | 原始价格 | 优惠券业务中的原始价格。 | YES | NULL | 推断 |
| `coupon_type` | `varchar(255)` | 优惠券类型 | 优惠券业务分类或类型。 | YES | NULL | 推断 |
| `member_code` | `varchar(255)` | 会员code | 优惠券业务对象的会员code。 | YES | NULL | 推断 |
| `member_phone` | `varchar(255)` | 会员phone | 优惠券业务中的会员phone。 | YES | NULL | 推断 |
| `member_name` | `varchar(255)` | 会员姓名 | 会员姓名或昵称。 | YES | NULL | 通用字段 |
| `purchase_num` | `int` | purchase数量 | 优惠券业务中的purchase数量。 | YES | NULL | 推断 |
| `purchase_price` | `decimal(19,10)` | purchase价格 | 优惠券业务中的purchase价格。 | YES | NULL | 推断 |
| `appid` | `varchar(255)` | appid | 优惠券业务中的appid。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 优惠券业务中的create时间。 | YES | NULL | 推断 |
| `openid` | `varchar(255)` | OpenID | 优惠券业务中的OpenID。 | YES | NULL | 推断 |
| `Deal_status` | `varchar(255)` | deal状态 | 优惠券处理状态或启停状态。 | YES | NULL | 推断 |
| `Tran_order_no` | `varchar(255)` | tran订单no | 优惠券业务对象的tran订单no。 | YES | NULL | 推断 |

### a_crm

#### `crm_coupon_task`

- 真实表：`crm_coupon_task`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：券交易记录
- 表含义：券交易记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCouponTask.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `out_trade_no` | `bigint` | 业务单号 | 业务单号 | YES | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券id | 优惠券id | YES | NULL | DB/DDL/实体注释 |
| `lock_state` | `int` | 锁状态 | 锁状态 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_deal_task`

- 真实表：`crm_deal_task`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：交易任务
- 表含义：交易任务
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmDealTask.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(255)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡编号 | 会员卡编号 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `int` | 交易类型 | 交易类型 | YES | NULL | DB/DDL/实体注释 |
| `out_trade_no` | `varchar(32)` | 业务单号 | 业务单号 | YES | NULL | DB/DDL/实体注释 |
| `trade_state` | `int` | 交易状态 | 交易状态 | YES | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(90)` | 会员卡类型 | 会员卡类型 | YES | NULL | DB/DDL/实体注释 |
| `card_type_code` | `bigint` | 会员卡类型编号 | 会员卡类型编号 | YES | NULL | DB/DDL/实体注释 |
| `org_type_code` | `bigint` | 原先的会员卡类型 | 原先的会员卡类型 | YES | NULL | DB/DDL/实体注释 |
| `operator` | `varchar(255)` | 操作人员 | 操作人员 | YES | NULL | DB/DDL/实体注释 |
| `comment` | `varchar(255)` | 备注信息 | 备注信息 | YES | NULL | DB/DDL/实体注释 |
| `principal_amount` | `decimal(24,6)` | 交易本金 | 交易本金 | YES | NULL | DB/DDL/实体注释 |
| `give_amount` | `decimal(24,6)` | 交易赠送金额 | 交易赠送金额 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 交易金额 | 交易金额 | YES | NULL | DB/DDL/实体注释 |
| `bill_amount` | `decimal(24,6)` | 账单金额 | 账单金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `give_point` | `decimal(24,6)` | 赠送积分 | 赠送积分 | YES | NULL | DB/DDL/实体注释 |
| `pay_way` | `varchar(90)` | 支付方式 | 支付方式 | YES | NULL | DB/DDL/实体注释 |
| `pay_way_code` | `bigint` | 支付方式编号 | 支付方式编号 | YES | NULL | DB/DDL/实体注释 |
| `canceled` | `tinyint(1)` | 已撤销 | 已撤销 | YES | NULL | DB/DDL/实体注释 |
| `cancel_time` | `datetime` | 撤销时间 | 撤销时间 | YES | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 撤销人 | 撤销人 | YES | NULL | DB/DDL/实体注释 |
| `marketer` | `varchar(90)` | 营销人 | 营销人 | YES | NULL | DB/DDL/实体注释 |
| `commission_ratio` | `decimal(24,6)` | 提成比例 | 提成比例 | YES | NULL | DB/DDL/实体注释 |
| `save_rule` | `varchar(255)` | 充值套餐名 | 充值套餐名 | YES | NULL | DB/DDL/实体注释 |
| `save_rule_code` | `bigint` | 充值套餐Lid | 充值套餐Lid | YES | NULL | DB/DDL/实体注释 |
| `balance` | `decimal(24,6)` | 充值余额 | 充值余额 | YES | NULL | DB/DDL/实体注释 |
| `dash_amount` | `decimal(24,6)` | 霸王餐赠送金额 | 霸王餐赠送金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `unpaid` | `decimal(24,6)` | 本次冻结金额 | 本次冻结金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `give_unpaid` | `decimal(24,6)` | 本次冻结赠送金额 | 本次冻结赠送金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `unpaid_at` | `datetime` | 本次冻结时间 | 本次冻结时间 | YES | NULL | DB/DDL/实体注释 |
| `only_principal` | `tinyint(1)` | 仅扣本金 | 仅扣本金 | NO | 0 | DB/DDL/实体注释 |
| `use_give` | `tinyint(1)` | 扣减指定赠送 | 扣减指定赠送 | NO | 0 | DB/DDL/实体注释 |
| `as_upgrade_cost` | `tinyint(1)` | 作为升级工本费 | 作为升级工本费 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `invoice_amount` | `decimal(24,6)` | 发票金额 | 发票金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `invoice` | `tinyint(1)` | 是否开发票 | 是否开发票 | NO | 0 | DB/DDL/实体注释 |
| `rebate_lid` | `bigint` | 返佣任务lid | 返佣任务lid | YES | NULL | DB/DDL/实体注释 |
| `rebate_ratio` | `decimal(24,6)` | 返佣比例 | 返佣比例（撤销时用） | YES | NULL | DB/DDL/实体注释 |
| `last_rebate_lid` | `bigint` | 上次返佣规则lid | 上次返佣规则lid（撤销充值时用） | YES | NULL | DB/DDL/实体注释 |
| `last_rebate_ratio` | `decimal(24,6)` | 返佣比例 | 返佣比例（撤销充值时用） | YES | NULL | DB/DDL/实体注释 |
| `canceled_amount` | `decimal(19,10)` | 已退金额 | 已退金额 | YES | NULL | DB/DDL/实体注释 |
| `canceled_principal_amount` | `decimal(19,10)` | 已退本金 | 已退本金 | YES | NULL | DB/DDL/实体注释 |
| `canceled_give_amount` | `decimal(19,10)` | 已退赠送 | 已退赠送 | YES | NULL | DB/DDL/实体注释 |

#### `crm_deal_task_item`

- 真实表：`crm_deal_task_item`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：交易任务明细
- 表含义：交易任务明细
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmDealTaskItem.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `task_lid` | `bigint` | 任务编号 | 任务编号 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡编号 | 会员卡编号 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `int` | 交易类型 | 交易类型 | YES | NULL | DB/DDL/实体注释 |
| `principal_amount` | `decimal(24,6)` | 交易本金 | 交易本金 | YES | NULL | DB/DDL/实体注释 |
| `give_amount` | `decimal(24,6)` | 交易赠送金额 | 交易赠送金额 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 交易金额 | 交易金额 | YES | NULL | DB/DDL/实体注释 |
| `save_rule` | `varchar(90)` | 充值套餐 | 充值套餐 | YES | NULL | DB/DDL/实体注释 |
| `save_rule_code` | `bigint` | 充值套餐编号 | 充值套餐编号 | YES | NULL | DB/DDL/实体注释 |
| `rule_type_lid` | `bigint` | 其他类型的lid | 其他类型的lid | YES | NULL | DB/DDL/实体注释 |
| `give_point` | `decimal(24,6)` | 赠送积分 | 赠送积分 | YES | NULL | DB/DDL/实体注释 |
| `give_coupon_num` | `int` | 赠送券数量 | 赠送券数量 | YES | NULL | DB/DDL/实体注释 |
| `give_coupon` | `varchar(255)` | 赠送券 | 赠送券 | YES | NULL | DB/DDL/实体注释 |
| `give_coupon_id` | `varchar(255)` | 赠送券编号 | 赠送券编号 | YES | NULL | DB/DDL/实体注释 |
| `give_coupon_is_map` | `tinyint(1)` | 赠送的是券包 | 赠送的是券包 | YES | NULL | DB/DDL/实体注释 |
| `first_charge_gift_coupon` | `tinyint(1)` | 首次充值赠券 | 首次充值赠券 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_envelope_proportion`

- 真实表：`sc_envelope_proportion`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：红包面值比例
- 表含义：红包面值比例
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `min_range` | `decimal(19,10)` | 最小范围 | 最小范围 | YES | NULL | DB/DDL/实体注释 |
| `max_range` | `decimal(19,10)` | 最大范围 | 最大范围 | YES | NULL | DB/DDL/实体注释 |
| `proportion` | `int` | 比例 | 比例 | YES | NULL | DB/DDL/实体注释 |
| `envelope_code` | `bigint` | 红包编号 | 红包编号 | NO | NULL | DB/DDL/实体注释 |
| `envelope` | `varchar(255)` | 红包名称 | 红包名称 | YES | NULL | DB/DDL/实体注释 |

#### `crm_festival`

- 真实表：`sc_mall_festival`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：节假日定义
- 表含义：节假日定义
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `create_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开始时间 | 开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间 | 结束时间 | YES | NULL | DB/DDL/实体注释 |

### a_crm

#### `crm_filter`

- 真实表：`crm_filter`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员筛选
- 表含义：会员筛选
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmFilter.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 筛选条件名称 | 筛选条件名称 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `crm_filter_item`

- 真实表：`crm_filter_item`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：会员筛选项
- 表含义：会员筛选项
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmFilterItem.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `filter_lid` | `bigint` | 筛选记录lid | 筛选记录lid | NO | NULL | DB/DDL/实体注释 |
| `filter_type` | `int` | 筛选类型 | 筛选类型 | NO | NULL | DB/DDL/实体注释 |
| `opt_type` | `int` | 操作类型 | 操作类型 | NO | NULL | DB/DDL/实体注释 |
| `val` | `varchar(255)` | 值 | 值 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_gift_coupon_food`

- 真实表：`sc_mall_gift_coupon_food`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：CRM会员
- 表含义：CRM会员相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Dish` | `varchar(255)` | 菜品 | CRM会员业务中的菜品。 | YES | NULL | 推断 |
| `Dish_code` | `varchar(255)` | 菜品code | CRM会员业务对象的菜品code。 | YES | NULL | 推断 |
| `Dish_type` | `varchar(255)` | 菜品类型 | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `Dish_type_code` | `varchar(255)` | 菜品类型code | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `Coupon` | `varchar(255)` | 优惠券 | CRM会员业务中的优惠券。 | YES | NULL | 推断 |
| `Coupon_code` | `varchar(255)` | 优惠券code | CRM会员业务对象的优惠券code。 | YES | NULL | 推断 |
| `Unit` | `varchar(255)` | 单位 | CRM会员业务中的单位。 | YES | NULL | 推断 |

#### `crm_invitation_reward`

- 真实表：`sc_invitation_reward`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：CRM会员
- 表含义：CRM会员相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `use_begin_time` | `datetime` | use开始时间 | CRM会员业务中的use开始时间。 | YES | NULL | 推断 |
| `use_end_time` | `datetime` | use结束时间 | CRM会员业务中的use结束时间。 | YES | NULL | 推断 |
| `maker` | `varchar(255)` | maker | CRM会员业务中的maker。 | YES | NULL | 推断 |
| `make_time` | `datetime` | make时间 | CRM会员业务中的make时间。 | YES | NULL | 推断 |
| `coupon` | `varchar(255)` | 优惠券 | CRM会员业务中的优惠券。 | YES | NULL | 推断 |
| `coupon_code` | `varchar(255)` | 优惠券code | CRM会员业务对象的优惠券code。 | YES | NULL | 推断 |
| `nums` | `decimal(19,10)` | nums | CRM会员业务中的nums。 | YES | NULL | 推断 |
| `instructions` | `varchar(255)` | instructions | CRM会员业务中的instructions。 | YES | NULL | 推断 |
| `recharge_cash_back` | `decimal(19,10)` | 充值现金返还 | CRM会员业务中的充值现金返还。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | CRM会员业务中的pidtmp。 | YES | NULL | 推断 |

#### `crm_join_activity`

- 真实表：`crm_join_activity`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：续费奖励。
- 表含义：续费奖励。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmJoinActivity.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `begin_date` | `datetime` | 开始日期 | CRM会员业务中的开始日期。 | YES | NULL | 推断 |
| `end_date` | `datetime` | 结束日期 | CRM会员业务中的结束日期。 | YES | NULL | 推断 |
| `card_type` | `varchar(255)` | 会员卡类型 | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `card_level` | `varchar(255)` | 会员卡等级 | CRM会员业务中的会员卡等级。 | YES | NULL | 推断 |
| `card_level_code` | `varchar(255)` | 会员卡等级code | CRM会员业务对象的会员卡等级code。 | YES | NULL | 推断 |
| `usage_scenarios` | `varchar(255)` | usagescenarios | CRM会员业务中的usagescenarios。 | YES | NULL | 推断 |
| `purchase_amount` | `decimal(19,10)` | purchase金额 | CRM会员业务中的purchase金额。 | YES | NULL | 推断 |
| `recharge_amount` | `decimal(19,10)` | 充值金额 | CRM会员业务中的充值金额。 | YES | NULL | 推断 |
| `card_fee` | `decimal(19,10)` | 会员卡fee | CRM会员业务中的会员卡fee。 | YES | NULL | 推断 |
| `card_validity` | `varchar(255)` | 会员卡有效期 | CRM会员业务中的会员卡有效期。 | YES | NULL | 推断 |
| `amount_of_bonus_stored_value` | `decimal(19,10)` | 金额ofbonusstored值 | CRM会员业务中的金额ofbonusstored值。 | YES | NULL | 推断 |
| `delayed_days` | `int` | delayeddays | CRM会员业务中的delayeddays。 | YES | NULL | 推断 |
| `bonus_points` | `decimal(19,10)` | bonus积分 | CRM会员业务中的bonus积分。 | YES | NULL | 推断 |
| `bonus_coupons` | `varchar(255)` | bonuscoupons | CRM会员业务中的bonuscoupons。 | YES | NULL | 推断 |
| `bonus_coupons_code` | `varchar(255)` | bonuscouponscode | CRM会员业务对象的bonuscouponscode。 | YES | NULL | 推断 |
| `is_termination` | `varchar(255)` | istermination | 标记CRM会员业务是否启用或满足istermination条件。 | YES | NULL | 推断 |
| `description` | `varchar(2048)` | 说明 | CRM会员业务中的说明。 | YES | NULL | 推断 |
| `Is_all_store` | `tinyint` | isall门店 | 标记CRM会员业务是否启用或满足isall门店条件。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `is_all_store` | `tinyint(1)` | isall门店 | 标记CRM会员业务是否启用或满足isall门店条件。 |  |  | 推断 |

#### `crm_join_activity_shop`

- 真实表：`crm_join_activity_shop`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：续费奖励适用门店。
- 表含义：续费奖励适用门店。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmJoinActivityShop.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `plan` | `varchar(255)` | plan | CRM会员业务中的plan。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | CRM会员业务中的owner店铺。 | YES | NULL | 推断 |
| `Plan_code` | `bigint` | plancode | CRM会员业务对象的plancode。 | YES | NULL | 推断 |
| `Owner_shop_id` | `bigint` | owner店铺ID | CRM会员业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `plan_code` | `bigint` | plancode | CRM会员业务对象的plancode。 |  |  | 推断 |
| `owner_shop_id` | `bigint` | owner店铺ID | CRM会员业务关联的owner店铺ID。 |  |  | 推断 |

#### `crm_large_turntable`

- 真实表：`sc_large_turntable`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：大转盘活动
- 表含义：大转盘活动
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `NAME` | `varchar(255)` | 大转盘名称 | 大转盘名称 | YES | NULL | DB/DDL/实体注释 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `ENABLE` | `tinyint` | 状态 | 状态 | YES | NULL | DB/DDL/实体注释 |
| `activity_type` | `varchar(32)` | 活动类型 | 活动类型：大奖盘，刮刮乐等 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `limit_type` | `varchar(64)` | 限制类型 | 限制类型：会员，粉丝 | YES | NULL | DB/DDL/实体注释 |
| `partake_mode` | `varchar(64)` | 参与方式 | 参与方式：免费参与，积分兑换，充值赠送，消费赠送 | YES | NULL | DB/DDL/实体注释 |
| `use_period` | `varchar(64)` | 限制使用周期 | 限制使用周期：每天，每周，每月 | YES | NULL | DB/DDL/实体注释 |
| `use_times` | `int` | 限制周期内最多使用的次数 | 限制周期内最多使用的次数 | YES | NULL | DB/DDL/实体注释 |
| `points_exchange` | `decimal(19,10)` | 兑换抽奖所需积分 | 兑换抽奖所需积分 | YES | NULL | DB/DDL/实体注释 |
| `points_exchange_times` | `int` | 积分兑换抽奖对应的抽奖次数 | 积分兑换抽奖对应的抽奖次数 | YES | NULL | DB/DDL/实体注释 |
| `charge_gift_amount` | `decimal(19,10)` | 充值满赠门槛金额 | 充值满赠门槛金额 | YES | NULL | DB/DDL/实体注释 |
| `charge_gift_times` | `int` | 充值满赠赠送的抽奖次数 | 充值满赠赠送的抽奖次数 | YES | NULL | DB/DDL/实体注释 |
| `charge_gift_max_times` | `int` | 充值最多可赠送次数 | 充值最多可赠送次数 | YES | NULL | DB/DDL/实体注释 |
| `consume_gift_amount` | `decimal(19,10)` | 消费满赠门槛金额 | 消费满赠门槛金额 | YES | NULL | DB/DDL/实体注释 |
| `consume_gift_times` | `int` | 消费满赠赠送的抽奖次数 | 消费满赠赠送的抽奖次数 | YES | NULL | DB/DDL/实体注释 |
| `consume_gift_max_times` | `int` | 消费最多可赠送次数 | 消费最多可赠送次数 | YES | NULL | DB/DDL/实体注释 |
| `prize_remarks` | `text` | 奖项说明 | 奖项说明 | YES | NULL | DB/DDL/实体注释 |
| `activity_remarks` | `text` | 活动说明 | 活动说明 | YES | NULL | DB/DDL/实体注释 |
| `fail_tips` | `varchar(255)` | 抽奖失败提示 | 抽奖失败提示 | YES | NULL | DB/DDL/实体注释 |
| `msg_img_url` | `varchar(255)` | 消息封面图片 | 消息封面图片 | YES | NULL | DB/DDL/实体注释 |
| `create_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(255)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `update_time` | `datetime` | 修改时间 | 修改时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(255)` | 修改人 | 修改人 | YES | NULL | DB/DDL/实体注释 |

#### `crm_large_turntable_item`

- 真实表：`sc_large_turntable_item`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：活动奖项明细
- 表含义：活动奖项明细
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | 奖项名称 | 奖项名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `large_turntable` | `varchar(255)` | 活动名称 | 活动名称 | YES | NULL | DB/DDL/实体注释 |
| `large_turntable_code` | `bigint` | 活动lmnid | 活动lmnid | YES | NULL | DB/DDL/实体注释 |
| `probability` | `decimal(19,10)` | 抽奖概率 | 抽奖概率 | YES | NULL | DB/DDL/实体注释 |
| `limit_number` | `int` | 限制数量 | 限制数量 | YES | NULL | DB/DDL/实体注释 |
| `drawn_out_number` | `int` | 已抽出数量 | 已抽出数量 | YES | NULL | DB/DDL/实体注释 |
| `gift_coupon` | `varchar(128)` | 奖劵名称 | 奖劵名称 | YES | NULL | DB/DDL/实体注释 |
| `gift_coupon_code` | `bigint` | 劵lmnid | 劵lmnid | YES | NULL | DB/DDL/实体注释 |
| `gift_points` | `decimal(19,10)` | 奖励积分 | 奖励积分 | YES | NULL | DB/DDL/实体注释 |
| `img_url` | `varchar(255)` | 奖品地址 | 奖品地址 | YES | NULL | DB/DDL/实体注释 |
| `img_thumbnail_url` | `varchar(255)` | 奖品缩略图地址 | 奖品缩略图地址 | YES | NULL | DB/DDL/实体注释 |

#### `crm_member`

- 真实表：`crm_member`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员。
- 表含义：会员。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmMember.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `contact_details` | `varchar(255)` | contact明细 | CRM会员业务中的contact明细。 | YES | NULL | 推断 |
| `sex` | `varchar(255)` | sex | CRM会员业务中的sex。 | YES | NULL | 推断 |
| `birthday` | `datetime` | 生日 | CRM会员业务中的生日。 | YES | NULL | 推断 |
| `birthday_type` | `varchar(255)` | 生日类型 | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `certificate` | `varchar(255)` | certificate | CRM会员业务中的certificate。 | YES | NULL | 推断 |
| `certificate_code` | `varchar(255)` | certificatecode | CRM会员业务对象的certificatecode。 | YES | NULL | 推断 |
| `email` | `varchar(255)` | email | CRM会员业务中的email。 | YES | NULL | 推断 |
| `postal_code` | `varchar(255)` | postalcode | CRM会员业务对象的postalcode。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | addr | CRM会员业务中的addr。 | YES | NULL | 推断 |
| `company` | `varchar(255)` | company | CRM会员业务中的company。 | YES | NULL | 推断 |
| `position` | `varchar(255)` | position | CRM会员业务中的position。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | CRM会员业务中的comment。 | YES | NULL | 推断 |
| `submitter` | `varchar(255)` | submitter | CRM会员业务中的submitter。 | YES | NULL | 推断 |
| `card_id` | `varchar(255)` | 会员卡ID | 会员卡记录 ID。 | YES | NULL | 通用字段 |
| `card_out_id` | `varchar(255)` | 会员卡outID | CRM会员业务关联的会员卡outID。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | CRM会员业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `varchar(255)` | owner店铺ID | CRM会员业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `Join_time` | `datetime` | join时间 | CRM会员业务中的join时间。 | YES | NULL | 推断 |
| `Agent_lmnid` | `varchar(255)` | agentlmnid | CRM会员业务中的agentlmnid。 | YES | NULL | 推断 |
| `Agent` | `varchar(255)` | agent | CRM会员业务中的agent。 | YES | NULL | 推断 |
| `Invitees_lmnid` | `varchar(255)` | inviteeslmnid | CRM会员业务中的inviteeslmnid。 | YES | NULL | 推断 |
| `Invitees` | `varchar(255)` | invitees | CRM会员业务中的invitees。 | YES | NULL | 推断 |
| `Salesman_lmnid` | `varchar(255)` | salesmanlmnid | CRM会员业务中的salesmanlmnid。 | YES | NULL | 推断 |
| `Salesman` | `varchar(255)` | salesman | CRM会员业务中的salesman。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | CRM会员业务中的pidtmp。 | YES | NULL | 推断 |
| `give_coupon_time` | `datetime` | 生日赠劵时间 | 生日赠劵时间 | YES | NULL | DB/DDL/实体注释 |
| `has_give_coupon` | `tinyint` | 已生日赠劵 | 已生日赠劵 | YES | 0 | DB/DDL/实体注释 |
| `had_modify_birthday` | `tinyint` | 已修改过生日 | 已修改过生日 | YES | 0 | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `agent_lmnid` | `varchar` | agentlmnid | CRM会员业务中的agentlmnid。 |  |  | 推断 |
| `agent` | `varchar` | agent | CRM会员业务中的agent。 |  |  | 推断 |
| `invitees_lmnid` | `varchar` | inviteeslmnid | CRM会员业务中的inviteeslmnid。 |  |  | 推断 |
| `invitees` | `varchar` | invitees | CRM会员业务中的invitees。 |  |  | 推断 |
| `salesman_lmnid` | `varchar` | salesmanlmnid | CRM会员业务中的salesmanlmnid。 |  |  | 推断 |
| `salesman` | `varchar` | salesman | CRM会员业务中的salesman。 |  |  | 推断 |
| `join_time` | `datetime` | join时间 | CRM会员业务中的join时间。 |  |  | 推断 |

#### `crm_new_gift`

- 真实表：`sc_new_gift`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：CRM会员
- 表含义：CRM会员相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `use_begin_time` | `datetime` | use开始时间 | CRM会员业务中的use开始时间。 | YES | NULL | 推断 |
| `use_end_time` | `datetime` | use结束时间 | CRM会员业务中的use结束时间。 | YES | NULL | 推断 |
| `maker` | `varchar(255)` | maker | CRM会员业务中的maker。 | YES | NULL | 推断 |
| `make_time` | `datetime` | make时间 | CRM会员业务中的make时间。 | YES | NULL | 推断 |
| `coupon` | `varchar(255)` | 优惠券 | CRM会员业务中的优惠券。 | YES | NULL | 推断 |
| `coupon_code` | `varchar(255)` | 优惠券code | CRM会员业务对象的优惠券code。 | YES | NULL | 推断 |
| `nums` | `decimal(19,10)` | nums | CRM会员业务中的nums。 | YES | NULL | 推断 |
| `instructions` | `varchar(255)` | instructions | CRM会员业务中的instructions。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | CRM会员业务中的pidtmp。 | YES | NULL | 推断 |
| `img_url` | `varchar(255)` | 消息图片 | 消息图片 | YES | NULL | DB/DDL/实体注释 |

#### `crm_new_gift_store`

- 真实表：`sc_new_gift_store`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：新人礼包适用门店
- 表含义：新人礼包适用门店
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `new_gift` | `varchar(128)` | 新人礼包名称 | 新人礼包名称 | YES | NULL | DB/DDL/实体注释 |
| `new_gift_code` | `bigint` | 新人礼包shop_id | 新人礼包shop_id | YES | NULL | DB/DDL/实体注释 |
| `store_id` | `bigint` | 门店lmnid | 门店lmnid | YES | NULL | DB/DDL/实体注释 |

### a_crm

#### `crm_overlord_once`

- 真实表：`crm_overlord_once`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：霸王餐参与关联
- 表含义：霸王餐参与关联
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmOverlordOnce.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `times` | `int` | 次数 | 次数 | NO | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡lid | 会员卡lid | NO | NULL | DB/DDL/实体注释 |
| `overlord_lid` | `bigint` | 霸王餐lid | 霸王餐lid | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `crm_overlord_store`

- 真实表：`crm_overlord_store`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：霸王餐店铺规则关联
- 表含义：霸王餐店铺规则关联
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmOverlordStore.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `overlord_lid` | `bigint` | 霸王餐lid | 霸王餐lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_point_exchange`

- 真实表：`sc_mall_point_exchange`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：CRM会员
- 表含义：CRM会员相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `effective_start_time` | `datetime` | effective开始时间 | CRM会员业务中的effective开始时间。 | YES | NULL | 推断 |
| `effective_end_time` | `datetime` | effective结束时间 | CRM会员业务中的effective结束时间。 | YES | NULL | 推断 |
| `point_exchange_value` | `decimal(19,10)` | 积分exchange值 | CRM会员业务中的积分exchange值。 | YES | NULL | 推断 |
| `coupon_name` | `varchar(255)` | 优惠券名称 | CRM会员业务对象的优惠券名称。 | YES | NULL | 推断 |
| `coupon_code` | `varchar(255)` | 优惠券code | CRM会员业务对象的优惠券code。 | YES | NULL | 推断 |
| `original_price` | `decimal(19,10)` | 原始价格 | CRM会员业务中的原始价格。 | YES | NULL | 推断 |
| `sort_number` | `int` | sort数量 | CRM会员业务中的sort数量。 | YES | NULL | 推断 |
| `exchange_num` | `int` | exchange数量 | CRM会员业务中的exchange数量。 | YES | NULL | 推断 |
| `sold_growth_value` | `int` | soldgrowth值 | CRM会员业务中的soldgrowth值。 | YES | NULL | 推断 |
| `sold_base_value` | `int` | soldbase值 | CRM会员业务中的soldbase值。 | YES | NULL | 推断 |
| `popularity_growth_value` | `int` | popularitygrowth值 | CRM会员业务中的popularitygrowth值。 | YES | NULL | 推断 |
| `popularity_base_value` | `int` | popularitybase值 | CRM会员业务中的popularitybase值。 | YES | NULL | 推断 |
| `limit_exchange_times` | `int` | 限制exchangetimes | CRM会员业务中的限制exchangetimes。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | CRM会员业务中的create时间。 | YES | NULL | 推断 |
| `update_time` | `datetime` | update时间 | CRM会员业务中的update时间。 | YES | NULL | 推断 |
| `exchange_status` | `varchar(255)` | exchange状态 | CRM会员处理状态或启停状态。 | YES | NULL | 推断 |
| `description` | `varchar(2048)` | 说明 | CRM会员业务中的说明。 | YES | NULL | 推断 |
| `Exchange_weapp_code` | `varchar(255)` | exchangeweappcode | CRM会员业务对象的exchangeweappcode。 | YES | NULL | 推断 |

### a_crm

#### `crm_purchase_coupon_record`

- 真实表：`crm_purchase_coupon_record`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：购买券记录
- 表含义：购买券记录
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmPurchaseCouponRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year_` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month_` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day_` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡lid | 会员卡lid | NO | NULL | DB/DDL/实体注释 |
| `card_id` | `varchar(90)` | 会员卡号 | 会员卡号 | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(90)` | openID | openId | NO | NULL | DB/DDL/实体注释 |
| `union_id` | `varchar(90)` | unionID | unionId | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 会员名称 | 会员名称 | NO | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 会员手机号 | 会员手机号 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `int` | 购买数量 | 购买数量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 购买单价 | 购买单价 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 购买金额 | 购买金额 | NO | NULL | DB/DDL/实体注释 |
| `coupon_name` | `varchar(90)` | 优惠券名称 | 优惠券名称 | YES | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 优惠券lid | 优惠券lid | NO | NULL | DB/DDL/实体注释 |
| `pay_id` | `varchar(90)` | 支付终端号 | 支付终端号 | NO | NULL | DB/DDL/实体注释 |
| `finished` | `tinyint(1)` | 是否支付 | 是否支付 | NO | 0 | DB/DDL/实体注释 |
| `finished_at` | `datetime` | 支付完成时间 | 支付完成时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `year` | `int` | year | CRM会员业务中的year。 |  |  | 推断 |
| `month` | `int` | month | CRM会员业务中的month。 |  |  | 推断 |
| `day` | `int` | day | CRM会员业务中的day。 |  |  | 推断 |

#### `crm_rebate_detail`

- 真实表：`crm_rebate_detail`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：返佣明细
- 表含义：返佣明细
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmRebateDetail.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `consume_card_lid` | `bigint` | 消费卡lid | 消费卡lid | YES | NULL | DB/DDL/实体注释 |
| `consume_card_id` | `varchar(32)` | 消费会员卡号 | 消费会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `consume_member_name` | `varchar(90)` | 消费会员名称 | 消费会员名称 | YES | NULL | DB/DDL/实体注释 |
| `consume_phone` | `varchar(32)` | 消费会员手机号 | 消费会员手机号 | YES | NULL | DB/DDL/实体注释 |
| `consume_amount` | `decimal(24,6)` | 消费金额 | 消费金额 | YES | NULL | DB/DDL/实体注释 |
| `consume_open_id` | `varchar(32)` | 被邀请人open_id | 被邀请人open_id | NO | NULL | DB/DDL/实体注释 |
| `consume_union_id` | `varchar(32)` | 被邀请人union_id | 被邀请人union_id | YES | NULL | DB/DDL/实体注释 |
| `rebate_card_lid` | `bigint` | 返佣卡lid | 返佣卡lid | YES | NULL | DB/DDL/实体注释 |
| `rebate_card_id` | `varchar(32)` | 返佣会员卡号 | 返佣会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `rebate_member_name` | `varchar(90)` | 返佣会员名称 | 返佣会员名称 | YES | NULL | DB/DDL/实体注释 |
| `rebate_phone` | `varchar(32)` | 返佣会员手机号 | 返佣会员手机号 | YES | NULL | DB/DDL/实体注释 |
| `rule_name` | `varchar(90)` | 规则名称 | 规则名称 | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 规则lid | 规则lid | YES | NULL | DB/DDL/实体注释 |
| `rebate_ratio` | `decimal(24,6)` | 返佣比例 | 返佣比例 | YES | NULL | DB/DDL/实体注释 |
| `rebate_amount` | `decimal(24,6)` | 返佣金额 | 返佣金额 | YES | NULL | DB/DDL/实体注释 |
| `rebate_type` | `int` | 返佣类型 | 返佣类型 | YES | NULL | DB/DDL/实体注释 |
| `done` | `tinyint(1)` | 返佣是否处理 | 返佣是否处理 | NO | 0 | DB/DDL/实体注释 |
| `done_at` | `datetime` | 返佣处理完成时间 | 返佣处理完成时间 | YES | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消操作人 | 取消操作人 | YES | NULL | DB/DDL/实体注释 |
| `cancel` | `tinyint(1)` | 返佣取消 | 返佣取消 | NO | 0 | DB/DDL/实体注释 |
| `cancel_at` | `datetime` | 返佣取消时间 | 返佣取消时间 | YES | NULL | DB/DDL/实体注释 |
| `comment` | `varchar(255)` | 返佣备注 | 返佣备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_red_envelope`

- 真实表：`sc_mall_red_envelope`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：红包活动
- 表含义：红包活动
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | CRM会员业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `begin_date` | `datetime` | 生效时间 | 生效时间 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 失效时间 | 失效时间 | YES | NULL | DB/DDL/实体注释 |
| `pay_type` | `varchar(128)` | 支付类型,ALL | 支付类型,ALL:全部,WXZF:微信支付,HYK:会员卡 | YES | NULL | DB/DDL/实体注释 |
| `full_amount` | `decimal(19,10)` | 满弹金额 | 满弹金额 | YES | NULL | DB/DDL/实体注释 |
| `envelope_code` | `bigint` | 红包编号 | 红包编号 | NO | NULL | DB/DDL/实体注释 |
| `envelope` | `varchar(255)` | 红包名称 | 红包名称 | YES | NULL | DB/DDL/实体注释 |
| `create_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(255)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `update_time` | `datetime` | 修改时间 | 修改时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(255)` | 修改人 | 修改人 | YES | NULL | DB/DDL/实体注释 |

#### `crm_save_rule`

- 真实表：`crm_save_rule`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：充值规则。
- 表含义：充值规则。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmSaveRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `begin_time` | `datetime` | 开始时间 | 储值规则业务中的开始时间。 | YES | NULL | 推断 |
| `end_time` | `datetime` | 结束时间 | 储值规则业务中的结束时间。 | YES | NULL | 推断 |
| `save_type` | `varchar(255)` | 储值类型 | 储值规则业务分类或类型。 | YES | NULL | 推断 |
| `save_amount` | `decimal(19,10)` | 储值金额 | 储值规则业务中的储值金额。 | YES | NULL | 推断 |
| `give_amount` | `decimal(19,10)` | 赠送金额 | 储值规则业务中的赠送金额。 | YES | NULL | 推断 |
| `give_point` | `decimal(19,10)` | 赠送积分 | 储值规则业务中的赠送积分。 | YES | NULL | 推断 |
| `description` | `text` | 说明 | 储值规则业务中的说明。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 储值规则业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 储值规则业务中的pidtmp。 | YES | NULL | 推断 |
| `Give_coupon` | `varchar(255)` | 赠送优惠券 | 储值规则业务中的赠送优惠券。 | YES | NULL | 推断 |
| `Give_coupon_id` | `varchar(64)` | 赠送优惠券ID | 储值规则业务关联的赠送优惠券ID。 | YES | NULL | 推断 |
| `Give_coupon_is_map` | `tinyint` | 赠送优惠券ismap | 储值规则业务中的赠送优惠券ismap。 | YES | NULL | 推断 |
| `HideInWeapp` | `tinyint` | hideinweapp | 储值规则业务中的hideinweapp。 | YES | NULL | 推断 |
| `Unpaid_amount` | `decimal(19,10)` | unpaid金额 | 储值规则业务中的unpaid金额。 | YES | NULL | 推断 |
| `give_coupon_num` | `int` | 赠送优惠券数量 | 储值规则业务中的赠送优惠券数量。 | YES | NULL | 推断 |
| `Commission_ratio` | `decimal(15,4)` | commission比例 | 储值规则业务中的commission比例。 | YES | NULL | 推断 |
| `Commission_amount` | `decimal(15,4)` | commission金额 | 储值规则业务中的commission金额。 | YES | NULL | 推断 |
| `upgrade_card_type` | `varchar(90)` | upgrade会员卡类型 | 储值规则业务分类或类型。 | YES | NULL | 推断 |
| `upgrade_card_type_code` | `varchar(32)` | upgrade会员卡类型code | 储值规则业务分类或类型。 | YES | NULL | 推断 |
| `first_charge_gift_coupon` | `tinyint(1)` | 首次充值赠券 | 首次充值赠券 | YES | NULL | DB/DDL/实体注释 |
| `apply_to_store` | `text` | 适用门店 | 适用门店 | YES | NULL | DB/DDL/实体注释 |
| `as_upgrade_cost` | `tinyint(1)` | 作为升级工本费 | 作为升级工本费 | NO | 0 | DB/DDL/实体注释 |
| `optional` | `tinyint(1)` | 赠送可选券 | 赠送可选券 | NO | 0 | DB/DDL/实体注释 |
| `optional_coupons` | `varchar(2000)` | 可选券列表 | 可选券列表 | YES | NULL | DB/DDL/实体注释 |
| `unpaid_rate` | `decimal(24,6)` | 当餐不可用比例 | 当餐不可用比例 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `give_coupon` | `varchar` | 赠送优惠券 | 储值规则业务中的赠送优惠券。 |  |  | 推断 |
| `give_coupon_id` | `varchar` | 赠送优惠券ID | 储值规则业务关联的赠送优惠券ID。 |  |  | 推断 |
| `give_coupon_is_map` | `tinyint(1)` | 赠送优惠券ismap | 储值规则业务中的赠送优惠券ismap。 |  |  | 推断 |
| `hideinweapp` | `tinyint(1)` | hideinweapp | 储值规则业务中的hideinweapp。 |  |  | 推断 |
| `unpaid_amount` | `decimal` | unpaid金额 | 储值规则业务中的unpaid金额。 |  |  | 推断 |
| `commission_amount` | `decimal` | commission金额 | 储值规则业务中的commission金额。 |  |  | 推断 |
| `commission_ratio` | `decimal` | commission比例 | 储值规则业务中的commission比例。 |  |  | 推断 |
| `ruleTypeLid` | `bigint` | ruletypelid | 储值规则业务分类或类型。 |  |  | 推断 |

#### `crm_save_rule_interval`

- 真实表：`crm_save_rule_interval`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：储值规则
- 表含义：储值规则相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmSaveRuleInterval.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `min_amount` | `decimal(19,10)` | min金额 | 储值规则业务中的min金额。 | YES | NULL | 推断 |
| `max_amount` | `decimal(19,10)` | max金额 | 储值规则业务中的max金额。 | YES | NULL | 推断 |
| `give_money_rule` | `varchar(255)` | 赠送money规则 | 储值规则业务中的赠送money规则。 | YES | NULL | 推断 |
| `give_money` | `decimal(19,10)` | 赠送money | 储值规则业务中的赠送money。 | YES | NULL | 推断 |
| `give_point_reule` | `varchar(255)` | 赠送积分reule | 储值规则业务中的赠送积分reule。 | YES | NULL | 推断 |
| `give_point` | `decimal(19,10)` | 赠送积分 | 储值规则业务中的赠送积分。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 储值规则业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

### a_crm

#### `crm_shareholder`

- 真实表：`crm_shareholder`
- 数据源/库：`a_crm` / `crm` / `172.16.0.144:3306`
- 表中文名：共享股东活动
- 表含义：共享股东活动
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmShareholder.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 活动名称 | 活动名称 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 活动状态 | 活动状态 | NO | 1 | DB/DDL/实体注释 |
| `rebate_ratio` | `decimal(24,6)` | 返佣比例 | 返佣比例 | YES | NULL | DB/DDL/实体注释 |
| `markdown_desc` | `text` | 活动描述 | 活动描述 | YES | NULL | DB/DDL/实体注释 |
| `rules` | `text` | 充值套餐列表 | 充值套餐列表 | YES | NULL | DB/DDL/实体注释 |
| `stores` | `text` | 店铺列表 | 店铺列表 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `money_desc` | `text` | 赚钱描述 | 赚钱描述 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `crm_shop_in_card_type`

- 真实表：`crm_shop_in_card_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：会员卡适用的店铺。
- 表含义：会员卡适用的店铺。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmShopInCardType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `card_type` | `varchar(255)` | 会员卡类型 | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `card_type_code` | `varchar(255)` | 会员卡类型code | CRM会员业务分类或类型。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | CRM会员业务中的pidtmp。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `crm_store_in_coupon`

- 真实表：`sc_store_in_mall_coupon`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `store` | `varchar(255)` | 门店 | 库存单据业务中的门店。 | YES | NULL | 推断 |
| `store_code` | `varchar(255)` | 门店code | 库存单据业务对象的门店code。 | YES | NULL | 推断 |
| `coupon` | `varchar(255)` | 优惠券 | 库存单据业务中的优惠券。 | YES | NULL | 推断 |
| `coupon_code` | `varchar(255)` | 优惠券code | 库存单据业务对象的优惠券code。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `tbl_type_code` | `bigint` | 桌台类型编号 | 桌台类型编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_type_name` | `varchar(128)` | 桌台类型名称 | 桌台类型名称 | YES | NULL | DB/DDL/实体注释 |

#### `pos_give_bill`

- 真实表：`pos_give_bill`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.54:3306`
- 表中文名：打赏记录
- 表含义：打赏记录
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\PosGiveBill.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 订单号 | 订单号 | YES | NULL | DB/DDL/实体注释 |
| `donee_phone` | `varchar(32)` | 受赠人手机 | 受赠人手机 | YES | NULL | DB/DDL/实体注释 |
| `donee` | `varchar(32)` | 受赠人 | 受赠人 | YES | NULL | DB/DDL/实体注释 |
| `donor_phone` | `varchar(32)` | 打赏人手机 | 打赏人手机 | YES | NULL | DB/DDL/实体注释 |
| `donor` | `varchar(32)` | 打赏人 | 打赏人 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 打赏金额 | 打赏金额 | YES | NULL | DB/DDL/实体注释 |
| `done` | `tinyint(1)` | 支付成功 | 支付成功 | YES | NULL | DB/DDL/实体注释 |
| `payment_state` | `varchar(32)` | 支付状态 | 支付状态 | YES | NULL | DB/DDL/实体注释 |
| `payment_id` | `varchar(32)` | 支付单号 | 支付单号 | YES | NULL | DB/DDL/实体注释 |
| `payment_time` | `datetime` | 支付时间 | 支付时间 | YES | NULL | DB/DDL/实体注释 |
| `payment_qr_code` | `varchar(1024)` | 支付码 | 支付码 | YES | NULL | DB/DDL/实体注释 |
| `merchant_no` | `varchar(32)` | 支付商户号 | 支付商户号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_id` | `varchar(32)` | 终端号 | 终端号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_trace` | `varchar(32)` | 支付秘钥 | 支付秘钥 | YES | NULL | DB/DDL/实体注释 |
| `closed` | `tinyint(1)` | 已经转结 | 已经转结 | YES | NULL | DB/DDL/实体注释 |
| `closed_time` | `datetime` | 转结时间 | 转结时间 | YES | NULL | DB/DDL/实体注释 |
| `closed_by` | `varchar(32)` | 转结人 | 转结人 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `depart` | `varchar(64)` | depart | 业务业务中的depart。 | YES | NULL | 推断 |
| `table_area` | `varchar(64)` | 桌台区域 | 业务业务中的桌台区域。 | YES | NULL | 推断 |
| `table_name` | `varchar(64)` | 桌台name | 业务业务对象的桌台name。 | YES | NULL | 推断 |
| `order_no` | `varchar(64)` | 订单no | 业务业务对象的订单no。 | YES | NULL | 推断 |

### a_order

#### `order_bill`

- 真实表：`order_bill`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：账单明细
- 表含义：账单明细
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderBill.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `mid` | `bigint` | 商户编号 | 商户编号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店编号 | 门店编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 日期 | 日期 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_key` | `varchar(32)` | 账单号 | 账单号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 账单流水号 | 账单流水号 | NO | NULL | DB/DDL/实体注释 |
| `person_num` | `int` | 客流 | 客流 | YES | NULL | DB/DDL/实体注释 |
| `food_amount` | `decimal(24,6)` | 流水金额 | 流水金额 | YES | NULL | DB/DDL/实体注释 |
| `discount_amount` | `decimal(24,6)` | 折扣额 | 折扣额 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,6)` | 原价合计 | 原价合计 | NO | 0.000000 | DB/DDL/实体注释 |
| `service_charge_amount` | `decimal(24,6)` | 服务费 | 服务费 | YES | NULL | DB/DDL/实体注释 |
| `fraction` | `decimal(24,6)` | 零头 | 零头 | YES | NULL | DB/DDL/实体注释 |
| `mantissa` | `decimal(24,6)` | 尾数 | 尾数 | YES | NULL | DB/DDL/实体注释 |
| `timing_amount` | `decimal(24,6)` | 计时金额 | 计时金额 | YES | NULL | DB/DDL/实体注释 |
| `timing_discount_amount` | `decimal(24,6)` | 计时折扣额 | 计时折扣额 | YES | NULL | DB/DDL/实体注释 |
| `timing_service_charge_amount` | `decimal(24,6)` | 计时服务费 | 计时服务费 | YES | NULL | DB/DDL/实体注释 |
| `overcharge_amount` | `decimal(24,6)` | 多收金额 | 多收金额 | YES | NULL | DB/DDL/实体注释 |
| `less_amount` | `decimal(24,6)` | 少收金额 | 少收金额 | YES | NULL | DB/DDL/实体注释 |
| `promotion_amount` | `decimal(24,6)` | 优惠金额 | 优惠金额 | YES | NULL | DB/DDL/实体注释 |
| `paid_amount` | `decimal(24,6)` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `cancel_amount` | `decimal(24,6)` | 退菜金额 | 退菜金额 | YES | NULL | DB/DDL/实体注释 |
| `send_amount` | `decimal(24,6)` | 赠送金额 | 赠送金额 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开台时间 | 开台时间 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time` | `datetime` | 结账时间 | 结账时间 | YES | NULL | DB/DDL/实体注释 |
| `checkout_by` | `varchar(90)` | 收银员 | 收银员 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(90)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `duration` | `bigint` | 消费时长 | 消费时长(毫秒) | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(90)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `order_sub_type` | `int` | 账单类型;堂食、外卖、自提 | 账单类型;堂食、外卖、自提 | YES | NULL | DB/DDL/实体注释 |
| `channel_name` | `varchar(90)` | 渠道 | 渠道 | YES | NULL | DB/DDL/实体注释 |
| `area_name` | `varchar(90)` | 区域名称 | 区域名称 | YES | NULL | DB/DDL/实体注释 |
| `table_no` | `varchar(255)` | 桌台号 | 桌台号 | YES | NULL | DB/DDL/实体注释 |
| `table_name` | `varchar(90)` | 桌台名称 | 桌台名称 | YES | NULL | DB/DDL/实体注释 |
| `create_by` | `varchar(90)` | 开台人员 | 开台人员 | YES | NULL | DB/DDL/实体注释 |
| `table_leader` | `varchar(90)` | 桌台负责人 | 桌台负责人 | YES | NULL | DB/DDL/实体注释 |
| `waiter_by` | `varchar(90)` | 服务员 | 服务员 | YES | NULL | DB/DDL/实体注释 |
| `channel_order_key_t_p` | `varchar(90)` | 三方单号 | 三方单号 | YES | NULL | DB/DDL/实体注释 |
| `device_code` | `varchar(90)` | 设备编号 | 设备编号 | YES | NULL | DB/DDL/实体注释 |
| `device_name` | `varchar(90)` | 设备名称 | 设备名称 | YES | NULL | DB/DDL/实体注释 |
| `discount_range` | `varchar(90)` | 折扣方式 | 折扣方式 | YES | NULL | DB/DDL/实体注释 |
| `discount_rate` | `decimal(24,6)` | 折扣率 | 折扣率 | YES | NULL | DB/DDL/实体注释 |
| `discount_by` | `varchar(90)` | 打折人 | 打折人 | YES | NULL | DB/DDL/实体注释 |
| `service_charge_rate` | `decimal(24,6)` | 服务率 | 服务率 | YES | NULL | DB/DDL/实体注释 |
| `fraction_by` | `varchar(90)` | 零头调整人 | 零头调整人 | YES | NULL | DB/DDL/实体注释 |
| `fjz_count` | `int` | 反结账次数 | 反结账次数 | YES | NULL | DB/DDL/实体注释 |
| `invoice_amount` | `decimal(24,6)` | 发票金额 | 发票金额 | YES | NULL | DB/DDL/实体注释 |
| `invoice_title` | `varchar(90)` | 发票抬头 | 发票抬头 | YES | NULL | DB/DDL/实体注释 |
| `is_vip_price` | `tinyint(1)` | 使用了会员价 | 使用了会员价 | YES | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(90)` | 会员类型 | 会员类型 | YES | NULL | DB/DDL/实体注释 |
| `card_level` | `varchar(90)` | 会员等级 | 会员等级 | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(90)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡lid | 会员卡lid | YES | NULL | DB/DDL/实体注释 |
| `saas_order_remark` | `varchar(90)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 账单类型;快餐、酒楼、酒吧 | 账单类型;快餐、酒楼、酒吧 | YES | NULL | DB/DDL/实体注释 |
| `order_status` | `int` | 状态状态 | 状态状态 | YES | NULL | DB/DDL/实体注释 |
| `num_of_jiu_xi` | `decimal(24,6)` | 席数 | 席数 | YES | NULL | DB/DDL/实体注释 |
| `single_jiu_xi_amount` | `decimal(24,6)` | 单席金额 | 单席金额 | YES | NULL | DB/DDL/实体注释 |
| `jiu_xi_amount` | `decimal(24,6)` | 酒席金额 | 酒席金额 | YES | NULL | DB/DDL/实体注释 |
| `is_jiu_xi` | `tinyint(1)` | 酒席单 | 酒席单 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(90)` | 标记 | 标记 | YES | NULL | DB/DDL/实体注释 |
| `jiu_xi_order_amount` | `decimal(24,6)` | 酒席订金 | 酒席订金 | YES | NULL | DB/DDL/实体注释 |
| `card_number` | `varchar(90)` | 食品卡号 | 食品卡号 | YES | NULL | DB/DDL/实体注释 |
| `org_bill_id` | `varchar(255)` | 线下原订单号 | 线下原订单号 | YES | NULL | DB/DDL/实体注释 |
| `pay_type` | `int` | 支付模式 | 支付模式（1后付，0先付） | YES | NULL | DB/DDL/实体注释 |
| `out_trade_no` | `varchar(255)` | 支付平台订单号 | 支付平台订单号 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 手机号 | 手机号 | YES | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(255)` | openID | open_id | YES | NULL | DB/DDL/实体注释 |
| `confirm_status` | `int` | 确认状态 | 确认状态 | YES | NULL | DB/DDL/实体注释 |
| `has_free` | `tinyint(1)` | 是否有免赠 | 是否有免赠 | YES | NULL | DB/DDL/实体注释 |
| `cust_name` | `varchar(90)` | 收货人姓名 | 收货人姓名 | YES | NULL | DB/DDL/实体注释 |
| `cust_phone` | `varchar(90)` | 收货人手机号 | 收货人手机号 | YES | NULL | DB/DDL/实体注释 |
| `cust_address` | `varchar(255)` | 收货人地址 | 收货人地址 | YES | NULL | DB/DDL/实体注释 |
| `delivery_fee` | `decimal(24,6)` | 配送费 | 配送费 | YES | NULL | DB/DDL/实体注释 |
| `packing_fee` | `decimal(24,6)` | 打包费 | 打包费 | YES | NULL | DB/DDL/实体注释 |
| `self_pick_up_time` | `datetime` | 自提时间 | 自提时间 | YES | NULL | DB/DDL/实体注释 |
| `eval_lid` | `bigint` | 评价lid | 评价lid | YES | -1 | DB/DDL/实体注释 |
| `evaluated` | `tinyint(1)` | 已评价 | 已评价 | NO | 0 | DB/DDL/实体注释 |
| `order_making_status` | `int` | 制作状态 | 制作状态 | YES | 1 | DB/DDL/实体注释 |
| `discount_lid` | `bigint` | 折扣lid | 折扣lid | YES | NULL | DB/DDL/实体注释 |
| `pick_number` | `varchar(23)` | pick数量 | 订单业务中的pick数量。 | YES | NULL | 推断 |
| `buffet_id` | `varchar(32)` | 自助餐id | 自助餐id | YES | NULL | DB/DDL/实体注释 |
| `buffet_name` | `varchar(255)` | 自助餐名称 | 自助餐名称 | YES | NULL | DB/DDL/实体注释 |
| `buffet_amount` | `decimal(24,10)` | 自助餐数量 | 自助餐数量 | YES | NULL | DB/DDL/实体注释 |
| `coupon_items` | `varchar(2048)` | 智简券抵金额原始列表 | 智简券抵金额原始列表 | YES | NULL | DB/DDL/实体注释 |
| `product_items` | `varchar(2048)` | 智简券商品原始列表 | 智简券商品原始列表 | YES | NULL | DB/DDL/实体注释 |
| `product_coupon_items` | `varchar(2048)` | 智简券商品平分金额原始列表 | 智简券商品平分金额原始列表 | YES | NULL | DB/DDL/实体注释 |
| `spec_require` | `varchar(32)` | 特殊要求 R | 特殊要求 R:叫起 S:即上 | YES | NULL | DB/DDL/实体注释 |
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |
| `channel_order_key_tp` | `varchar` | 渠道订单键tp | 订单业务中的渠道订单键tp。 |  |  | 推断 |

#### `order_comment`

- 真实表：`order_comment`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：订单评价
- 表含义：订单评价
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderComment.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `user_id` | `bigint` | 评价人的用户编号 | 评价人的用户编号 | YES | NULL | DB/DDL/实体注释 |
| `user_name` | `varchar(90)` | 评价人名称 | 评价人名称 | YES | NULL | DB/DDL/实体注释 |
| `user_phone` | `varchar(90)` | 用户手机号 | 用户手机号 | YES | NULL | DB/DDL/实体注释 |
| `card_id` | `varchar(90)` | 用户卡号 | 用户卡号 | YES | NULL | DB/DDL/实体注释 |
| `user_avatar` | `varchar(255)` | 评价人头像 | 评价人头像 | YES | NULL | DB/DDL/实体注释 |
| `anonymous` | `tinyint(1)` | 是否匿名 | 是否匿名 | NO | 0 | DB/DDL/实体注释 |
| `order_id` | `bigint` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 线下账单编号 | 线下账单编号 | YES | NULL | DB/DDL/实体注释 |
| `table_name` | `varchar(90)` | 桌台号 | 桌台号 | YES | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(90)` | 用户openid | 用户openid | YES | NULL | DB/DDL/实体注释 |
| `scores` | `int` | 综合评分 | 综合评分 | NO | NULL | DB/DDL/实体注释 |
| `taste_scores` | `decimal(24,6)` | 口味 | 口味 | NO | NULL | DB/DDL/实体注释 |
| `env_scores` | `decimal(24,6)` | 环境 | 环境 | NO | NULL | DB/DDL/实体注释 |
| `performance_scores` | `decimal(24,6)` | 性价比 | 性价比 | NO | NULL | DB/DDL/实体注释 |
| `benefit_scores` | `decimal(24,6)` | 商家服务 | 商家服务 | NO | NULL | DB/DDL/实体注释 |
| `description_scores` | `decimal(24,6)` | 描述相符 | 描述相符 | NO | NULL | DB/DDL/实体注释 |
| `content` | `varchar(2000)` | 评价内容 | 评价内容 | NO | NULL | DB/DDL/实体注释 |
| `pic_urls` | `varchar(2000)` | 评价图片地址数组 | 评价图片地址数组 | NO | NULL | DB/DDL/实体注释 |
| `visible` | `tinyint(1)` | 是否可见 | 是否可见 | NO | 1 | DB/DDL/实体注释 |
| `reply_status` | `tinyint(1)` | 商家是否回复 | 商家是否回复 | NO | 0 | DB/DDL/实体注释 |
| `reply_user_id` | `bigint` | 回复管理员编号 | 回复管理员编号 | YES | NULL | DB/DDL/实体注释 |
| `reply_user_name` | `varchar(90)` | 回复管理员名称 | 回复管理员名称 | YES | NULL | DB/DDL/实体注释 |
| `reply_content` | `varchar(2000)` | 商家回复内容 | 商家回复内容 | YES | NULL | DB/DDL/实体注释 |
| `reply_time` | `datetime` | 商家回复时间 | 商家回复时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `order_food`

- 真实表：`order_food`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：菜品销售明细
- 表含义：菜品销售明细
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderFood.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `mid` | `bigint` | 集团编号 | 集团编号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店编号 | 门店编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 流水号 | 流水号 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_key` | `varchar(32)` | 账单号 | 账单号 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 账单流水号 | 账单流水号 | NO | NULL | DB/DDL/实体注释 |
| `food_no` | `bigint` | 菜品标识 | 菜品标识 | YES | NULL | DB/DDL/实体注释 |
| `food_code` | `varchar(32)` | 菜品编码 | 菜品编码 | YES | NULL | DB/DDL/实体注释 |
| `food_name` | `varchar(90)` | 菜品名称 | 菜品名称 | YES | NULL | DB/DDL/实体注释 |
| `food_unit` | `varchar(32)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `ordering_time` | `datetime` | 点菜时间 | 点菜时间 | YES | NULL | DB/DDL/实体注释 |
| `ordered_time` | `datetime` | 上菜时间 | 上菜时间 | YES | NULL | DB/DDL/实体注释 |
| `cook_duration` | `bigint` | 制作时长 | 制作时长（毫秒） | YES | NULL | DB/DDL/实体注释 |
| `cook` | `varchar(32)` | 厨师 | 厨师 | YES | NULL | DB/DDL/实体注释 |
| `food_pro_price` | `decimal(24,6)` | 售价 | 售价 | YES | NULL | DB/DDL/实体注释 |
| `food_org_price` | `decimal(24,6)` | 原价 | 原价 | YES | NULL | DB/DDL/实体注释 |
| `food_number` | `decimal(24,6)` | 流水数量 | 流水数量 | YES | NULL | DB/DDL/实体注释 |
| `send_number` | `decimal(24,6)` | 赠送数量 | 赠送数量 | YES | NULL | DB/DDL/实体注释 |
| `unit_adjutant_number` | `decimal(24,6)` | 辅助数量 | 辅助数量 | YES | NULL | DB/DDL/实体注释 |
| `food_amount` | `decimal(24,6)` | 流水金额 | 流水金额 | YES | NULL | DB/DDL/实体注释 |
| `service_charge_amount` | `decimal(24,6)` | 服务费 | 服务费 | YES | NULL | DB/DDL/实体注释 |
| `discount_amount` | `decimal(24,6)` | 折扣额 | 折扣额 | YES | NULL | DB/DDL/实体注释 |
| `discount_range` | `varchar(90)` | 打折方式 | 打折方式 | YES | NULL | DB/DDL/实体注释 |
| `food_discount_rate` | `decimal(24,6)` | 折扣率 | 折扣率 | YES | NULL | DB/DDL/实体注释 |
| `processing_fee` | `decimal(24,6)` | 加工费 | 加工费 | YES | NULL | DB/DDL/实体注释 |
| `processing_fee_discount` | `decimal(24,6)` | 加工费折扣额 | 加工费折扣额 | YES | NULL | DB/DDL/实体注释 |
| `processing_fee_service` | `decimal(24,6)` | 加工费服务费 | 加工费服务费 | YES | NULL | DB/DDL/实体注释 |
| `promotion_amount` | `decimal(24,6)` | 优惠金额 | 优惠金额 | YES | NULL | DB/DDL/实体注释 |
| `paid_amount` | `decimal(24,6)` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `department_name` | `varchar(90)` | 出品部门 | 出品部门 | YES | NULL | DB/DDL/实体注释 |
| `food_subject_name` | `varchar(90)` | 菜品收入科目 | 菜品收入科目 | YES | NULL | DB/DDL/实体注释 |
| `channel_name` | `varchar(32)` | 渠道 | 渠道 | YES | NULL | DB/DDL/实体注释 |
| `food_taste` | `varchar(90)` | 口味 | 口味 | YES | NULL | DB/DDL/实体注释 |
| `food_practice` | `varchar(90)` | 做法 | 做法 | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(32)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `order_by` | `varchar(90)` | 点菜人 | 点菜人 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(90)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `food_remark` | `varchar(2000)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(32)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `send_by` | `varchar(90)` | 赠送人 | 赠送人 | YES | NULL | DB/DDL/实体注释 |
| `send_for` | `varchar(90)` | 赠送原因 | 赠送原因 | YES | NULL | DB/DDL/实体注释 |
| `send_time` | `datetime` | 赠送时间 | 赠送时间 | YES | NULL | DB/DDL/实体注释 |
| `cancel_number` | `decimal(24,6)` | 退菜数量 | 退菜数量 | YES | NULL | DB/DDL/实体注释 |
| `cancel_for` | `varchar(90)` | 退菜原因 | 退菜原因 | YES | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 退菜人 | 退菜人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_time` | `datetime` | 退菜时间 | 退菜时间 | YES | NULL | DB/DDL/实体注释 |
| `is_rename` | `tinyint(1)` | 修改过菜名 | 修改过菜名 | YES | NULL | DB/DDL/实体注释 |
| `rename_by` | `varchar(90)` | 菜名修改人 | 菜名修改人 | YES | NULL | DB/DDL/实体注释 |
| `is_mod_price` | `tinyint(1)` | 修改过价格 | 修改过价格 | YES | NULL | DB/DDL/实体注释 |
| `mod_price_by` | `varchar(90)` | 价格修改人 | 价格修改人 | YES | NULL | DB/DDL/实体注释 |
| `mode_price_time` | `datetime` | 改价时间 | 改价时间 | YES | NULL | DB/DDL/实体注释 |
| `discount_rate` | `decimal(24,6)` | 折扣率 | 折扣率 | YES | NULL | DB/DDL/实体注释 |
| `discount_by` | `varchar(90)` | 打折人 | 打折人 | YES | NULL | DB/DDL/实体注释 |
| `is_jiu_xi` | `tinyint(1)` | 酒席菜 | 酒席菜 | YES | NULL | DB/DDL/实体注释 |
| `food_type_code` | `bigint` | 菜品小类编号 | 菜品小类编号 | YES | NULL | DB/DDL/实体注释 |
| `food_main_code` | `bigint` | 主菜编号 | 主菜编号 | YES | NULL | DB/DDL/实体注释 |
| `coupon_no` | `bigint` | 优惠券编号 | 优惠券编号 | YES | NULL | DB/DDL/实体注释 |
| `auto_order` | `tinyint(1)` | 自动点菜 | 自动点菜 | YES | NULL | DB/DDL/实体注释 |
| `by_person` | `tinyint(1)` | 跟人数有关 | 跟人数有关 | YES | NULL | DB/DDL/实体注释 |
| `packing_fee` | `decimal(24,6)` | 打包费 | 打包费 | YES | NULL | DB/DDL/实体注释 |
| `enable_give_balance` | `tinyint(1)` | 能使用赠送余额 | 能使用赠送余额 | NO | 0 | DB/DDL/实体注释 |
| `spec_x_price` | `tinyint(1)` | 是否第X份特价 | 是否第X份特价 | NO | 0 | DB/DDL/实体注释 |
| `food_image` | `varchar(1024)` | 菜品image | 订单业务中的菜品image。 | YES | NULL | 推断 |
| `zj_coupon_amount` | `decimal(24,10)` | 智简券可用商品平分金额 | 智简券可用商品平分金额 | YES | NULL | DB/DDL/实体注释 |
| `coupon_write_off_trace_no` | `varchar(64)` | 券核销追踪号 | 券核销追踪号 | YES | NULL | DB/DDL/实体注释 |
| `platform_certificate_id` | `varchar(128)` | 平台certificateID | 平台券凭证ID(certificate_id)，POS作为DwdCoupon.couponNo | YES | NULL | DB/DDL/实体注释 |
| `platform_write_off_id` | `text` | 平台券撤销凭证 | 平台券撤销凭证:MP存verify_results JSON,DP存逗号分隔verify_id | YES | NULL | DB/DDL/实体注释 |
| `product_coupon_business_type` | `varchar(16)` | 商品券业务类型 | 商品券业务类型:WP会员券,MP美团/餐道,DP抖音 | YES | NULL | DB/DDL/实体注释 |
| `platform_price` | `decimal(18,4)` | 平台价格 | 平台券面额,供POS DwdCoupon.faceAmount | YES | NULL | DB/DDL/实体注释 |
| `platform_paid_amount` | `decimal(18,4)` | 平台实付金额 | 平台券实收金额,供POS DwdCoupon.paidAmount | YES | NULL | DB/DDL/实体注释 |
| `write_off_channel` | `varchar(64)` | 核销渠道 | 平台券核销渠道,供POS DwdCoupon.writeOffChannel | YES | NULL | DB/DDL/实体注释 |
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |

#### `order_free_food_record`

- 真实表：`order_free_food_record`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：订单免赠记录表
- 表含义：订单免赠记录表
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderFreeFoodRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 卡lid | 卡lid | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(255)` | 订单id | 订单id | YES | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(90)` | 菜品名称 | 菜品名称 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品lid | 菜品lid | YES | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(90)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `dish_price` | `decimal(24,6)` | 菜品价格 | 菜品价格 | YES | NULL | DB/DDL/实体注释 |
| `dish_num` | `decimal(24,6)` | 赠送数量 | 赠送数量 | YES | NULL | DB/DDL/实体注释 |
| `is_valid` | `tinyint(1)` | 是否有效的 | 是否有效的 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `order_pay`

- 真实表：`order_pay`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：支付明细表
- 表含义：支付明细表
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderPay.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `mid` | `bigint` | 集团编号 | 集团编号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店编号 | 门店编号 | NO | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `saas_order_key` | `varchar(255)` | 账单号 | 账单号 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 账单流水号 | 账单流水号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 流水号 | 流水号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 支付方式编号 | 支付方式编号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 支付方式名称 | 支付方式名称 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 支付类型 | 支付类型 | YES | NULL | DB/DDL/实体注释 |
| `pay_amount` | `decimal(24,6)` | 支付金额 | 支付金额 | YES | NULL | DB/DDL/实体注释 |
| `exchange_amount` | `decimal(24,6)` | 找回金额 | 找回金额 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `is_real_income` | `tinyint(1)` | 真实收入 | 真实收入 | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(32)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `checkout_by` | `varchar(90)` | 收银员 | 收银员 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(32)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `coupon_no` | `bigint` | 优惠券券no | 优惠券券no | YES | NULL | DB/DDL/实体注释 |
| `task_lid` | `bigint` | 任务编号 | 任务编号 | YES | NULL | DB/DDL/实体注释 |
| `give_amount` | `decimal(24,6)` | 赠送金额 | 赠送金额 | YES | NULL | DB/DDL/实体注释 |
| `use_give` | `tinyint(1)` | 是否赠送 | 是否赠送 | NO | 0 | DB/DDL/实体注释 |
| `deleted` | `tinyint(1)` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `points_task_lid` | `varchar(64)` | 积分流水号 | 积分流水号 | YES | NULL | DB/DDL/实体注释 |
| `points` | `decimal(24,9)` | 本次扣款积分 | 本次扣款积分 | YES | NULL | DB/DDL/实体注释 |
| `card_balance_before` | `decimal(24,9)` | 扣款前余额 | 扣款前余额 | YES | NULL | DB/DDL/实体注释 |
| `card_principal_before` | `decimal(24,9)` | 扣款前本金 | 扣款前本金 | YES | NULL | DB/DDL/实体注释 |
| `card_give_before` | `decimal(24,9)` | 扣款前赠送 | 扣款前赠送 | YES | NULL | DB/DDL/实体注释 |
| `card_point_before` | `decimal(24,9)` | 扣款前积分 | 扣款前积分 | YES | NULL | DB/DDL/实体注释 |
| `card_balance_after` | `decimal(24,9)` | 扣款后余额 | 扣款后余额 | YES | NULL | DB/DDL/实体注释 |
| `card_principal_after` | `decimal(24,9)` | 扣款后本金 | 扣款后本金 | YES | NULL | DB/DDL/实体注释 |
| `card_give_after` | `decimal(24,9)` | 扣款后赠送 | 扣款后赠送 | YES | NULL | DB/DDL/实体注释 |
| `card_point_after` | `decimal(24,9)` | 扣款后积分 | 扣款后积分 | YES | NULL | DB/DDL/实体注释 |
| `coupons` | `varchar(1024)` | 优惠券列表 | 优惠券列表 | YES | NULL | DB/DDL/实体注释 |
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |

#### `order_rebate`

- 真实表：`order_rebate`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：商品返佣记录表
- 表含义：商品返佣记录表
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderRebate.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `share_lid` | `bigint` | 分享lid | 分享lid | NO | NULL | DB/DDL/实体注释 |
| `rebate` | `decimal(24,6)` | 返佣金额 | 返佣金额 | NO | NULL | DB/DDL/实体注释 |
| `rebate_card_lid` | `bigint` | 返佣卡lid | 返佣卡lid | NO | NULL | DB/DDL/实体注释 |
| `rebate_user_name` | `varchar(90)` | 返佣人 | 返佣人 | YES | NULL | DB/DDL/实体注释 |
| `rebate_card_id` | `varchar(90)` | 返佣卡号 | 返佣卡号 | NO | NULL | DB/DDL/实体注释 |
| `rebate_phone` | `varchar(90)` | 返佣手机号 | 返佣手机号 | YES | NULL | DB/DDL/实体注释 |
| `rebate_open_id` | `varchar(90)` | 返佣人openId | 返佣人openId | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(90)` | 下单人openId | 下单人openId | NO | NULL | DB/DDL/实体注释 |
| `user_name` | `varchar(90)` | 下单人名称 | 下单人名称 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 下单人卡lid | 下单人卡lid | YES | NULL | DB/DDL/实体注释 |
| `card_id` | `varchar(90)` | 下单人卡号 | 下单人卡号 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 下单人手机号 | 下单人手机号 | YES | NULL | DB/DDL/实体注释 |
| `order_lid` | `bigint` | 订单lid | 订单lid | NO | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(90)` | 商品名 | 商品名 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `rebate_sum` | `decimal` | rebatesum | 订单业务中的rebatesum。 |  |  | 推断 |

#### `order_taste`

- 真实表：`order_taste`
- 数据源/库：`a_order` / `order` / `172.16.0.144:3306`
- 表中文名：口味做法明细
- 表含义：口味做法明细
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-dao\src\main\java\com\nms4cloud\order\dao\entity\OrderTaste.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `mid` | `bigint` | 集团编号 | 集团编号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店编号 | 门店编号 | NO | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 流水号 | 流水号 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_key` | `varchar(32)` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 订单流水号 | 订单流水号 | NO | NULL | DB/DDL/实体注释 |
| `food_name` | `varchar(90)` | 菜品 | 菜品 | YES | NULL | DB/DDL/实体注释 |
| `taste_no` | `bigint` | 做法编号 | 做法编号 | YES | NULL | DB/DDL/实体注释 |
| `food_no` | `bigint` | 菜品流水号 | 菜品流水号 | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(32)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `adjutant_unit` | `varchar(32)` | 辅助规格 | 辅助规格 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `number` | `decimal(24,6)` | 数量 | 数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 价格 | 价格 | YES | NULL | DB/DDL/实体注释 |
| `taste_amount` | `decimal(24,6)` | 费用 | 费用 | YES | NULL | DB/DDL/实体注释 |
| `discount_amount` | `decimal(24,6)` | 折扣额 | 折扣额 | YES | NULL | DB/DDL/实体注释 |
| `service_charge_amount` | `decimal(24,6)` | 服务费 | 服务费 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 实际收费 | 实际收费 | YES | NULL | DB/DDL/实体注释 |
| `department_name` | `varchar(90)` | 出品部门 | 出品部门 | YES | NULL | DB/DDL/实体注释 |
| `department` | `varchar(90)` | 利润部门 | 利润部门 | YES | NULL | DB/DDL/实体注释 |
| `send_number` | `decimal(24,6)` | 赠送数量 | 赠送数量 | YES | NULL | DB/DDL/实体注释 |
| `related_dish_num` | `tinyint(1)` | 跟菜品数量相关 | 跟菜品数量相关 | YES | NULL | DB/DDL/实体注释 |
| `can_discount` | `tinyint(1)` | 参与打折 | 参与打折 | YES | NULL | DB/DDL/实体注释 |
| `collect_service_fee` | `tinyint(1)` | 收取服务费 | 收取服务费 | YES | NULL | DB/DDL/实体注释 |
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 |  |  | 通用字段 |

### a_payment

#### `pay_channel`

- 真实表：`pay_channel`
- 数据源/库：`a_payment` / `pay` / `172.16.0.144:3306`
- 表中文名：支付通道
- 表含义：支付通道
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-dao\src\main\java\com\nms4cloud\payment\dao\entity\PayChannel.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 通道类型 | 通道类型 | YES | NULL | DB/DDL/实体注释 |
| `merchant_name` | `varchar(90)` | 商户名称 | 商户名称 | YES | NULL | DB/DDL/实体注释 |
| `merchant_no` | `varchar(90)` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_id` | `varchar(90)` | 终端号 | 终端号 | YES | NULL | DB/DDL/实体注释 |
| `access_token` | `varchar(90)` | 秘钥 | 秘钥 | YES | NULL | DB/DDL/实体注释 |
| `app_id` | `varchar(255)` | appID | appId | YES | NULL | DB/DDL/实体注释 |
| `api_key` | `text` | 证书key | 证书key | YES | NULL | DB/DDL/实体注释 |
| `api_cert` | `text` | 证书cert | 证书cert | YES | NULL | DB/DDL/实体注释 |
| `api_shop_id` | `varchar(255)` | 支付门店号 | 支付门店号 | YES | NULL | DB/DDL/实体注释 |
| `private_key` | `text` | 商户私钥 | 商户私钥 | YES | NULL | DB/DDL/实体注释 |
| `public_key` | `text` | 平台公钥 | 平台公钥 | YES | NULL | DB/DDL/实体注释 |
| `subject` | `varchar(90)` | 订单标题 | 订单标题 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `mp` | `varchar(90)` | 公众号appid | 公众号appid | YES | NULL | DB/DDL/实体注释 |
| `txn_fee_rate` | `decimal(24,6)` | 手续费率 | 手续费率 | YES | NULL | DB/DDL/实体注释 |

#### `pay_order`

- 真实表：`pay_order`
- 数据源/库：`a_payment` / `pay` / `172.16.0.144:3306`
- 表中文名：支付订单
- 表含义：支付订单
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-dao\src\main\java\com\nms4cloud\payment\dao\entity\PayOrder.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 订单号 | 订单号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_trace` | `varchar(32)` | 终端流水号，填写商户系统的订单号 | 终端流水号，填写商户系统的订单号 | YES | NULL | DB/DDL/实体注释 |
| `out_trade_no` | `varchar(256)` | 支付平台的单号 | 支付平台的单号 | YES | NULL | DB/DDL/实体注释 |
| `channel_trade_no` | `varchar(32)` | 渠道tradeno | 通道订单号，微信订单号、支付宝订单号等，返回时不参与签名 | YES | NULL | DB/DDL/实体注释 |
| `channel_order_no` | `varchar(256)` | 渠道订单no | 银行渠道订单号，微信支付时显示在支付成功页面的条码，可用作扫码查询和扫码退款时匹配 | YES | NULL | DB/DDL/实体注释 |
| `channel_type` | `int` | 通道类型 | 通道类型 | YES | NULL | DB/DDL/实体注释 |
| `channel_no` | `bigint` | 通道号 | 通道号 | YES | NULL | DB/DDL/实体注释 |
| `pay_type` | `int` | 支付渠道 | 支付渠道 | YES | NULL | DB/DDL/实体注释 |
| `pay_way` | `int` | 支付方式 | 支付方式 | YES | NULL | DB/DDL/实体注释 |
| `merchant_name` | `varchar(255)` | 商户 | 商户 | YES | NULL | DB/DDL/实体注释 |
| `merchant_no` | `varchar(32)` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_id` | `varchar(32)` | 终端号 | 终端号 | YES | NULL | DB/DDL/实体注释 |
| `terminal_time` | `datetime` | terminal时间 | 终端交易时间，yyyyMMddHHmmss，全局统一时间格式 | YES | NULL | DB/DDL/实体注释 |
| `total_fee` | `bigint` | 金额，单位分 | 金额，单位分 | YES | NULL | DB/DDL/实体注释 |
| `receipt_fee` | `bigint` | 实收金额 | 实收金额 | YES | NULL | DB/DDL/实体注释 |
| `refund_fee` | `bigint` | 退款金额 | 退款金额 | YES | NULL | DB/DDL/实体注释 |
| `trade_state` | `int` | 交易状态 | 交易状态 | YES | NULL | DB/DDL/实体注释 |
| `pay_url` | `varchar(255)` | 二维码链接 | 二维码链接 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 支付平台回调时间 | 支付平台回调时间 | YES | NULL | DB/DDL/实体注释 |
| `pay_time` | `varchar(255)` | 支付时间 | 支付时间 | YES | NULL | DB/DDL/实体注释 |
| `refund_time` | `datetime` | 退款时间 | 退款时间 | YES | NULL | DB/DDL/实体注释 |
| `close_time` | `datetime` | 关闭时间 | 关闭时间 | YES | NULL | DB/DDL/实体注释 |
| `user_id` | `varchar(255)` | userID | 付款方用户id，“微信openid”、“支付宝账户”、“qq号”等，返回时不参与签名 | YES | NULL | DB/DDL/实体注释 |
| `attach` | `varchar(255)` | 附加数据,原样返回 | 附加数据,原样返回 | YES | NULL | DB/DDL/实体注释 |
| `notify_url` | `varchar(255)` | 回调地址 | 回调地址 | YES | NULL | DB/DDL/实体注释 |
| `deal_type` | `int` | 支付种类 | 支付种类 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `txn_fee` | `decimal(24,6)` | 手续费 | 手续费 | YES | NULL | DB/DDL/实体注释 |
| `saas_order` | `varchar(90)` | 收银系统的订单号 | 收银系统的订单号 | YES | NULL | DB/DDL/实体注释 |
| `cashier` | `varchar(90)` | 收银员 | 收银员 | YES | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(255)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `txn_fee_rate` | `decimal(24,6)` | 手续费率 | 手续费率 | YES | NULL | DB/DDL/实体注释 |
| `channel_mcnt_no` | `varchar(255)` | 商户订单号 | 商户订单号 | YES | NULL | DB/DDL/实体注释 |
| `order_source` | `tinyint/varchar` | 订单来源 | 支付业务中的订单来源。 |  |  | 推断 |

#### `pay_store_and_channel`

- 真实表：`pay_store_and_channel`
- 数据源/库：`a_payment` / `pay` / `172.16.0.144:3306`
- 表中文名：门店的通道设置
- 表含义：门店的通道设置
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-dao\src\main\java\com\nms4cloud\payment\dao\entity\PayStoreAndChannel.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `store_no` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `store_name` | `varchar(90)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `channel_no` | `bigint` | 消费通道号 | 消费通道号 | YES | NULL | DB/DDL/实体注释 |
| `channel_name` | `varchar(90)` | 消费通道名称 | 消费通道名称 | YES | NULL | DB/DDL/实体注释 |
| `channel_no_for_recharge` | `bigint` | 充值通道号 | 充值通道号 | YES | NULL | DB/DDL/实体注释 |
| `channel_name_for_recharge` | `varchar(90)` | 充值通道名称 | 充值通道名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `channel_no_for_cashier` | `bigint` | 渠道noforcashier | 支付业务对象的渠道noforcashier。 |  |  | 推断 |
| `channel_name_for_cashier` | `varchar` | 渠道nameforcashier | 支付业务对象的渠道nameforcashier。 |  |  | 推断 |

### gylregdb

#### `biz_user`

- 真实表：`sc_usr`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：系统用户。
- 表含义：系统用户。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScUsr.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `description` | `varchar(255)` | 说明 | 业务基础资料业务中的说明。 | YES | NULL | 推断 |
| `salt` | `varchar(255)` | salt | 业务基础资料业务中的salt。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务基础资料业务中的create时间。 | YES | NULL | 推断 |
| `modified_time` | `datetime` | modified时间 | 业务基础资料业务中的modified时间。 | YES | NULL | 推断 |
| `user_status` | `int` | user状态 | 业务基础资料处理状态或启停状态。 | YES | NULL | 推断 |
| `pwd` | `varchar(255)` | pwd | 业务基础资料业务中的pwd。 | YES | NULL | 推断 |
| `email` | `varchar(255)` | email | 业务基础资料业务中的email。 | YES | NULL | 推断 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `wechat` | `varchar(255)` | 微信 | 业务基础资料业务中的微信。 | YES | NULL | 推断 |
| `qq` | `varchar(255)` | qq | 业务基础资料业务中的qq。 | YES | NULL | 推断 |
| `tel` | `varchar(255)` | tel | 业务基础资料业务中的tel。 | YES | NULL | 推断 |
| `create_opr` | `varchar(255)` | createopr | 业务基础资料业务中的createopr。 | YES | NULL | 推断 |
| `modified_opr` | `datetime` | modifiedopr | 业务基础资料业务中的modifiedopr。 | YES | NULL | 推断 |
| `appid` | `varchar(255)` | appid | 业务基础资料业务中的appid。 | YES | NULL | 推断 |
| `openid` | `varchar(255)` | OpenID | 业务基础资料业务中的OpenID。 | YES | NULL | 推断 |
| `unionid` | `varchar(255)` | UnionID | 业务基础资料业务中的UnionID。 | YES | NULL | 推断 |
| `avatarurl` | `varchar(255)` | avatarurl | 业务基础资料业务中的avatarurl。 | YES | NULL | 推断 |
| `nickname` | `varchar(255)` | nickname | 业务基础资料业务对象的nickname。 | YES | NULL | 推断 |
| `Pb_cat_unionid` | `varchar(255)` | pbcatUnionID | 业务基础资料业务中的pbcatUnionID。 | YES | NULL | 推断 |
| `Pb_cat_openid` | `varchar(255)` | pbcatOpenID | 业务基础资料业务中的pbcatOpenID。 | YES | NULL | 推断 |
| `Pb_dailishangid` | `varchar(255)` | pbdailishangid | 业务基础资料业务中的pbdailishangid。 | YES | NULL | 推断 |
| `Roles` | `varchar(255)` | roles | 业务基础资料业务中的roles。 | YES | NULL | 推断 |
| `Roles_code` | `varchar(255)` | rolescode | 业务基础资料业务对象的rolescode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `For_some_shop` | `tinyint` | forsome店铺 | 业务基础资料业务中的forsome店铺。 | YES | NULL | 推断 |
| `Min_discount` | `decimal(19,10)` | min折扣 | 业务基础资料业务中的min折扣。 | YES | NULL | 推断 |
| `Max_discount` | `decimal(19,10)` | max折扣 | 业务基础资料业务中的max折扣。 | YES | NULL | 推断 |
| `Min_mod_price` | `decimal(19,10)` | minmod价格 | 业务基础资料业务中的minmod价格。 | YES | NULL | 推断 |
| `Max_mod_price` | `decimal(19,10)` | maxmod价格 | 业务基础资料业务中的maxmod价格。 | YES | NULL | 推断 |
| `Write_off_bag` | `tinyint` | 核销bag | 业务基础资料业务中的核销bag。 | YES | NULL | 推断 |
| `Leave_office` | `tinyint` | leaveoffice | 业务基础资料业务中的leaveoffice。 | YES | NULL | 推断 |
| `Entry_time` | `datetime` | entry时间 | 业务基础资料业务中的entry时间。 | YES | NULL | 推断 |
| `Staff_id` | `varchar(255)` | staffID | 业务基础资料业务关联的staffID。 | YES | NULL | 推断 |
| `Charge_limit` | `decimal(19,10)` | 充值限制 | 业务基础资料业务中的充值限制。 | YES | NULL | 推断 |
| `By_permission_ratio` | `decimal(19,10)` | 人permission比例 | 业务基础资料业务中的人permission比例。 | YES | NULL | 推断 |
| `Available_quota` | `decimal(19,10)` | 可用quota | 业务基础资料业务中的可用quota。 | YES | NULL | 推断 |
| `Used_quota` | `decimal(19,10)` | usedquota | 业务基础资料业务中的usedquota。 | YES | NULL | 推断 |
| `Giving_goods_quota` | `decimal(19,10)` | givinggoodsquota | 业务基础资料业务中的givinggoodsquota。 | YES | NULL | 推断 |
| `Giving_goods_amount` | `decimal(19,10)` | givinggoods金额 | 业务基础资料业务中的givinggoods金额。 | YES | NULL | 推断 |
| `Usr_show` | `tinyint` | usrshow | 业务基础资料业务中的usrshow。 | YES | NULL | 推断 |
| `Sex` | `varchar(64)` | sex | 业务基础资料业务中的sex。 | YES | NULL | 推断 |
| `Pos_give_pwd` | `tinyint` | pos赠送pwd | 业务基础资料业务中的pos赠送pwd。 | YES | NULL | 推断 |
| `Usr_type` | `varchar(64)` | usr类型 | 业务基础资料业务分类或类型。 | YES | NULL | 推断 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | 0 | DB/DDL/实体注释 |
| `data_scope` | `int` | 数据权限 | 数据权限 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_lids` | `text` | 部门/仓库lids | 部门/仓库lids | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `write_off_bag` | `tinyint(1)` | 核销bag | 业务基础资料业务中的核销bag。 |  |  | 推断 |
| `leave_office` | `tinyint(1)` | leaveoffice | 业务基础资料业务中的leaveoffice。 |  |  | 推断 |
| `entry_time` | `datetime` | entry时间 | 业务基础资料业务中的entry时间。 |  |  | 推断 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `staff_id` | `varchar` | staffID | 业务基础资料业务关联的staffID。 |  |  | 推断 |
| `charge_limit` | `decimal` | 充值限制 | 业务基础资料业务中的充值限制。 |  |  | 推断 |
| `by_permission_ratio` | `decimal` | 人permission比例 | 业务基础资料业务中的人permission比例。 |  |  | 推断 |
| `available_quota` | `decimal` | 可用quota | 业务基础资料业务中的可用quota。 |  |  | 推断 |
| `used_quota` | `decimal` | usedquota | 业务基础资料业务中的usedquota。 |  |  | 推断 |
| `giving_goods_quota` | `decimal` | givinggoodsquota | 业务基础资料业务中的givinggoodsquota。 |  |  | 推断 |
| `giving_goods_amount` | `decimal` | givinggoods金额 | 业务基础资料业务中的givinggoods金额。 |  |  | 推断 |
| `usr_show` | `tinyint(1)` | usrshow | 业务基础资料业务中的usrshow。 |  |  | 推断 |
| `sex` | `varchar` | sex | 业务基础资料业务中的sex。 |  |  | 推断 |
| `pos_give_pwd` | `tinyint(1)` | pos赠送pwd | 业务基础资料业务中的pos赠送pwd。 |  |  | 推断 |
| `roles` | `varchar` | roles | 业务基础资料业务中的roles。 |  |  | 推断 |
| `roles_code` | `varchar` | rolescode | 业务基础资料业务对象的rolescode。 |  |  | 推断 |
| `usr_type` | `varchar` | usr类型 | 业务基础资料业务分类或类型。 |  |  | 推断 |
| `pb_cat_unionid` | `varchar` | pbcatUnionID | 业务基础资料业务中的pbcatUnionID。 |  |  | 推断 |
| `pb_cat_openid` | `varchar` | pbcatOpenID | 业务基础资料业务中的pbcatOpenID。 |  |  | 推断 |
| `pb_dailishangid` | `varchar` | pbdailishangid | 业务基础资料业务中的pbdailishangid。 |  |  | 推断 |
| `for_some_shop` | `tinyint(1)` | forsome店铺 | 业务基础资料业务中的forsome店铺。 |  |  | 推断 |
| `min_discount` | `decimal` | min折扣 | 业务基础资料业务中的min折扣。 |  |  | 推断 |
| `max_discount` | `decimal` | max折扣 | 业务基础资料业务中的max折扣。 |  |  | 推断 |
| `min_mod_price` | `decimal` | minmod价格 | 业务基础资料业务中的minmod价格。 |  |  | 推断 |
| `max_mod_price` | `decimal` | maxmod价格 | 业务基础资料业务中的maxmod价格。 |  |  | 推断 |

#### `inst_user`

- 真实表：`sc_inst_adm`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商员工。
- 表含义：代理商员工。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScInstAdm.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `inst` | `varchar(255)` | inst | 业务业务中的inst。 | YES | NULL | 推断 |
| `inst_code` | `varchar(255)` | instcode | 业务业务对象的instcode。 | YES | NULL | 推断 |
| `pwd` | `varchar(255)` | pwd | 业务业务中的pwd。 | YES | NULL | 推断 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `unionid` | `varchar(255)` | UnionID | 业务业务中的UnionID。 | YES | NULL | 推断 |
| `openid` | `varchar(255)` | OpenID | 业务业务中的OpenID。 | YES | NULL | 推断 |
| `Salt` | `varchar(255)` | salt | 业务业务中的salt。 | YES | NULL | 推断 |
| `Headimgurl` | `varchar(255)` | headimgurl | 业务业务中的headimgurl。 | YES | NULL | 推断 |
| `Type_` | `varchar(64)` | 类型 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `First_recharge_commission` | `decimal(19,10)` | first充值commission | 业务业务中的first充值commission。 | YES | NULL | 推断 |
| `Other_recharge_commission` | `decimal(19,10)` | other充值commission | 业务业务中的other充值commission。 | YES | NULL | 推断 |
| `User_status` | `tinyint` | user状态 | 业务处理状态或启停状态。 | YES | NULL | 推断 |
| `Remark` | `varchar(255)` | remark | 业务业务中的remark。 | YES | NULL | 推断 |
| `Create_time` | `datetime` | create时间 | 业务业务中的create时间。 | YES | NULL | 推断 |
| `Login_num` | `int` | login数量 | 业务业务中的login数量。 | YES | NULL | 推断 |
| `Last_login_time` | `datetime` | 上次login时间 | 业务业务中的上次login时间。 | YES | NULL | 推断 |
| `Last_login_ip` | `varchar(255)` | 上次loginip | 业务业务中的上次loginip。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 业务业务中的syncfromold。 | YES | NULL | 推断 |
| `Pid_from_old` | `bigint` | pidfromold | 业务业务中的pidfromold。 | YES | NULL | 推断 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `salt` | `varchar` | salt | 业务业务中的salt。 |  |  | 推断 |
| `headimgurl` | `varchar` | headimgurl | 业务业务中的headimgurl。 |  |  | 推断 |
| `create_time` | `datetime` | create时间 | 业务业务中的create时间。 |  |  | 推断 |

### a_pos

#### `permission_module`

- 真实表：`permission_module`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：权限模块
- 表含义：权限模块
- 字段来源：`119-old + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PermissionModule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `view_lid` | `bigint` | 视角编号 | 视角编号 | YES | NULL | DB/DDL/实体注释 |
| `code` | `varchar(32)` | 标识符 | 标识符 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `sort_index` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `package_lid` | `bigint` | 权限包编号 | 权限包编号 | YES | NULL | DB/DDL/实体注释 |

#### `permission_package`

- 真实表：`permission_package`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：权限包
- 表含义：权限包
- 字段来源：`119-old + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PermissionPackage.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `code` | `varchar(255)` | 标识符 | 标识符 | YES | NULL | DB/DDL/实体注释 |
| `sort_index` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `permission_page`

- 真实表：`permission_page`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：权限页面
- 表含义：权限页面
- 字段来源：`119-old + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\PermissionPage.java + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PermissionPage.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `module_lid` | `bigint` | 视角编号 | 视角编号 | YES | NULL | DB/DDL/实体注释 |
| `code` | `text` | 标识符 | 标识符 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `sort_index` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `view_lid` | `bigint` | 视角编号 | 视角编号 | YES | NULL | DB/DDL/实体注释 |
| `package_lid` | `bigint` | 权限包编号 | 权限包编号 | YES | NULL | DB/DDL/实体注释 |

#### `permission_right`

- 真实表：`permission_right`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：权限资源
- 表含义：权限资源
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\PermissionRight.java + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PermissionRight.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `page_lid` | `bigint` | 页面编号 | 页面编号 | YES | NULL | DB/DDL/实体注释 |
| `code` | `text` | 标识符 | 标识符 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `sort_index` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `view_lid` | `bigint` | 视角编号 | 视角编号 | YES | NULL | DB/DDL/实体注释 |
| `package_lid` | `bigint` | 权限包编号 | 权限包编号 | YES | NULL | DB/DDL/实体注释 |
| `module_lid` | `bigint` | 视角编号 | 视角编号 | YES | NULL | DB/DDL/实体注释 |

#### `permission_view`

- 真实表：`permission_view`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：权限视角
- 表含义：权限视角
- 字段来源：`119-old + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PermissionView.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `package_lid` | `bigint` | 权限包编号 | 权限包编号 | YES | NULL | DB/DDL/实体注释 |
| `code` | `varchar(32)` | 标识符 | 标识符 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `sort_index` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_inst_and_product`

- 真实表：`sc_inst_and_product`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商的站点数。
- 表含义：代理商的站点数。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScInstAndProduct.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Inst` | `varchar(255)` | inst | 供应链或基础资料业务中的inst。 | YES | NULL | 推断 |
| `Inst_code` | `varchar(255)` | instcode | 供应链或基础资料业务对象的instcode。 | YES | NULL | 推断 |
| `product_type` | `varchar(64)` | 商品类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `amount` | `decimal(19,10)` | 金额 | 供应链或基础资料业务中的金额。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `inst` | `varchar` | inst | 供应链或基础资料业务中的inst。 |  |  | 推断 |
| `inst_code` | `varchar` | instcode | 供应链或基础资料业务对象的instcode。 |  |  | 推断 |

#### `sc_inst_finance_bill`

- 真实表：`sc_inst_finance_bill`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商充值记录。
- 表含义：代理商充值记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScInstFinanceBill.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 供应链或基础资料业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 供应链或基础资料业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 供应链或基础资料业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 供应链或基础资料业务中的day。 | YES | NULL | 推断 |
| `inst` | `varchar(255)` | inst | 供应链或基础资料业务中的inst。 | YES | NULL | 推断 |
| `inst_code` | `varchar(255)` | instcode | 供应链或基础资料业务对象的instcode。 | YES | NULL | 推断 |
| `crttime` | `datetime` | crttime | 供应链或基础资料业务中的crttime。 | YES | NULL | 推断 |
| `jinbanren` | `varchar(255)` | jinbanren | 供应链或基础资料业务中的jinbanren。 | YES | NULL | 推断 |
| `type_` | `varchar(255)` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `balance_before` | `decimal(19,10)` | 余额before | 供应链或基础资料业务中的余额before。 | YES | NULL | 推断 |
| `balance` | `decimal(19,10)` | 余额 | 供应链或基础资料业务中的余额。 | YES | NULL | 推断 |
| `balance_after` | `decimal(19,10)` | 余额after | 供应链或基础资料业务中的余额after。 | YES | NULL | 推断 |
| `principal_before` | `decimal(19,10)` | principalbefore | 供应链或基础资料业务中的principalbefore。 | YES | NULL | 推断 |
| `principal` | `decimal(19,10)` | principal | 供应链或基础资料业务中的principal。 | YES | NULL | 推断 |
| `principal_after` | `decimal(19,10)` | principalafter | 供应链或基础资料业务中的principalafter。 | YES | NULL | 推断 |
| `gift_balance_before` | `decimal(19,10)` | 赠送余额before | 供应链或基础资料业务中的赠送余额before。 | YES | NULL | 推断 |
| `gift_balance` | `decimal(19,10)` | 赠送余额 | 供应链或基础资料业务中的赠送余额。 | YES | NULL | 推断 |
| `gift_balance_after` | `decimal(19,10)` | 赠送余额after | 供应链或基础资料业务中的赠送余额after。 | YES | NULL | 推断 |
| `powerbank_balance_before` | `decimal(19,10)` | powerbank余额before | 供应链或基础资料业务中的powerbank余额before。 | YES | NULL | 推断 |
| `powerbank_balance` | `decimal(19,10)` | powerbank余额 | 供应链或基础资料业务中的powerbank余额。 | YES | NULL | 推断 |
| `powerbank_balance_after` | `decimal(19,10)` | powerbank余额after | 供应链或基础资料业务中的powerbank余额after。 | YES | NULL | 推断 |
| `share_balance_before` | `decimal(19,10)` | share余额before | 供应链或基础资料业务中的share余额before。 | YES | NULL | 推断 |
| `share_balance` | `decimal(19,10)` | share余额 | 供应链或基础资料业务中的share余额。 | YES | NULL | 推断 |
| `share_balance_after` | `decimal(19,10)` | share余额after | 供应链或基础资料业务中的share余额after。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 供应链或基础资料业务中的comment。 | YES | NULL | 推断 |
| `refflag` | `varchar(64)` | refflag | 供应链或基础资料业务中的refflag。 | YES | NULL | 推断 |
| `otherbillid` | `varchar(255)` | otherbillid | 供应链或基础资料业务中的otherbillid。 | YES | NULL | 推断 |
| `Recharge_set_name` | `varchar(255)` | 充值setname | 供应链或基础资料业务对象的充值setname。 | YES | NULL | 推断 |
| `Recharge_set_code` | `varchar(255)` | 充值setcode | 供应链或基础资料业务对象的充值setcode。 | YES | NULL | 推断 |
| `Recharge_set_amount` | `decimal(19,10)` | 充值set金额 | 供应链或基础资料业务中的充值set金额。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `type` | `decimal` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `recharge_set_name` | `varchar` | 充值setname | 供应链或基础资料业务对象的充值setname。 |  |  | 推断 |
| `recharge_set_code` | `varchar` | 充值setcode | 供应链或基础资料业务对象的充值setcode。 |  |  | 推断 |
| `recharge_set_amount` | `decimal` | 充值set金额 | 供应链或基础资料业务中的充值set金额。 |  |  | 推断 |

#### `sc_inst_op_log`

- 真实表：`sc_inst_op_log`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商操作记录。
- 表含义：代理商操作记录。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScInstOpLog.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `crt_time` | `datetime` | crt时间 | 供应链或基础资料业务中的crt时间。 | YES | NULL | 推断 |
| `inst` | `varchar(255)` | inst | 供应链或基础资料业务中的inst。 | YES | NULL | 推断 |
| `inst_id` | `varchar(255)` | instID | 供应链或基础资料业务关联的instID。 | YES | NULL | 推断 |
| `operator` | `varchar(255)` | operator | 供应链或基础资料业务中的operator。 | YES | NULL | 推断 |
| `comment` | `varchar(255)` | comment | 供应链或基础资料业务中的comment。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sc_inst_recharge_set`

- 真实表：`sc_inst_recharge_set`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商的充值套餐。
- 表含义：代理商的充值套餐。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-platform\nms4cloud-platform-dao\src\main\java\com\nms4cloud\platform\dao\entity\ScInstRechargeSet.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `amount` | `decimal(19,10)` | 金额 | 供应链或基础资料业务中的金额。 | YES | NULL | 推断 |
| `gift_amount` | `decimal(19,10)` | 赠送金额 | 供应链或基础资料业务中的赠送金额。 | YES | NULL | 推断 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sys_config_data`

- 真实表：`sc_config_of_shop`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `str_val` | `varchar(4096)` | 字符串值 | 字符串值 | YES | NULL | DB/DDL/实体注释 |
| `int_val` | `int` | intval | 业务业务中的intval。 | YES | NULL | 推断 |
| `boolean_val` | `tinyint` | booleanval | 业务业务中的booleanval。 | YES | NULL | 推断 |
| `double_val` | `decimal(19,10)` | doubleval | 业务业务中的doubleval。 | YES | NULL | 推断 |
| `date_val` | `datetime` | 日期val | 业务业务中的日期val。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |

#### `sys_inst`

- 真实表：`sc_inst`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：代理商。
- 表含义：代理商。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScInst.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `principal` | `varchar(255)` | principal | 业务业务中的principal。 | YES | NULL | 推断 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `tel` | `varchar(255)` | tel | 业务业务中的tel。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | addr | 业务业务中的addr。 | YES | NULL | 推断 |
| `email` | `varchar(255)` | email | 业务业务中的email。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 业务业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务业务中的create时间。 | YES | NULL | 推断 |
| `logo` | `varchar(255)` | logo | 业务业务中的logo。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务业务中的disable。 | YES | NULL | 推断 |
| `province` | `varchar(255)` | province | 业务业务中的province。 | YES | NULL | 推断 |
| `province_code` | `varchar(255)` | provincecode | 业务业务对象的provincecode。 | YES | NULL | 推断 |
| `city` | `varchar(255)` | city | 业务业务中的city。 | YES | NULL | 推断 |
| `city_code` | `varchar(255)` | citycode | 业务业务对象的citycode。 | YES | NULL | 推断 |
| `county` | `varchar(255)` | county | 业务业务中的county。 | YES | NULL | 推断 |
| `county_code` | `varchar(255)` | countycode | 业务业务对象的countycode。 | YES | NULL | 推断 |
| `industry` | `varchar(255)` | industry | 业务业务中的industry。 | YES | NULL | 推断 |
| `industry_code` | `varchar(255)` | industrycode | 业务业务对象的industrycode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `PCNum` | `int` | pcnum | 业务业务中的pcnum。 | YES | NULL | 推断 |
| `PC_LSNum` | `int` | pclsnum | 业务业务中的pclsnum。 | YES | NULL | 推断 |
| `PC_FTNum` | `int` | pcftnum | 业务业务中的pcftnum。 | YES | NULL | 推断 |
| `PC_ZYNum` | `int` | pczynum | 业务业务中的pczynum。 | YES | NULL | 推断 |
| `PC_YWNum` | `int` | pcywnum | 业务业务中的pcywnum。 | YES | NULL | 推断 |
| `PC_HYLSNum` | `int` | pchylsnum | 业务业务中的pchylsnum。 | YES | NULL | 推断 |
| `PC_LSPSNum` | `int` | pclspsnum | 业务业务中的pclspsnum。 | YES | NULL | 推断 |
| `PC_LSBBNum` | `int` | pclsbbnum | 业务业务中的pclsbbnum。 | YES | NULL | 推断 |
| `DCBNum` | `int` | dcbnum | 业务业务中的dcbnum。 | YES | NULL | 推断 |
| `AZPBNum` | `int` | azpbnum | 业务业务中的azpbnum。 | YES | NULL | 推断 |
| `AZSJNum` | `int` | azsjnum | 业务业务中的azsjnum。 | YES | NULL | 推断 |
| `IpadNum` | `int` | ipadnum | 业务业务中的ipadnum。 | YES | NULL | 推断 |
| `ZZDCNum` | `int` | zzdcnum | 业务业务中的zzdcnum。 | YES | NULL | 推断 |
| `Balance` | `decimal(19,10)` | 余额 | 业务业务中的余额。 | YES | NULL | 推断 |
| `Gift_balance` | `decimal(19,10)` | 赠送余额 | 业务业务中的赠送余额。 | YES | NULL | 推断 |
| `Powerbank_balance` | `decimal(19,10)` | powerbank余额 | 业务业务中的powerbank余额。 | YES | NULL | 推断 |
| `Share_balance` | `decimal(19,10)` | share余额 | 业务业务中的share余额。 | YES | NULL | 推断 |
| `Principal_balance` | `decimal(19,10)` | principal余额 | 业务业务中的principal余额。 | YES | NULL | 推断 |
| `Wechat` | `varchar(255)` | 微信 | 业务业务中的微信。 | YES | NULL | 推断 |
| `Inst_type` | `varchar(255)` | inst类型 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Technical_director_name` | `varchar(255)` | technicaldirectorname | 业务业务对象的technicaldirectorname。 | YES | NULL | 推断 |
| `Technical_director_phone` | `varchar(255)` | technicaldirectorphone | 业务业务中的technicaldirectorphone。 | YES | NULL | 推断 |
| `Technical_director_email` | `varchar(255)` | technicaldirectoremail | 业务业务中的technicaldirectoremail。 | YES | NULL | 推断 |
| `Technical_director_wechat` | `varchar(255)` | technicaldirector微信 | 业务业务中的technicaldirector微信。 | YES | NULL | 推断 |
| `Business_director_name` | `varchar(255)` | 业务directorname | 业务业务对象的业务directorname。 | YES | NULL | 推断 |
| `Business_director_phone` | `varchar(255)` | 业务directorphone | 业务业务中的业务directorphone。 | YES | NULL | 推断 |
| `Business_director_email` | `varchar(255)` | 业务directoremail | 业务业务中的业务directoremail。 | YES | NULL | 推断 |
| `Business_director_wechat` | `varchar(255)` | 业务director微信 | 业务业务中的业务director微信。 | YES | NULL | 推断 |
| `Tax_identification_number` | `varchar(255)` | taxidentification数量 | 业务业务中的taxidentification数量。 | YES | NULL | 推断 |
| `Company_account_number` | `varchar(255)` | companyaccount数量 | 业务业务中的companyaccount数量。 | YES | NULL | 推断 |
| `Account_name` | `varchar(255)` | accountname | 业务业务对象的accountname。 | YES | NULL | 推断 |
| `Bank_of_deposit` | `varchar(255)` | bankof储值 | 业务业务中的bankof储值。 | YES | NULL | 推断 |
| `Remark` | `varchar(2048)` | remark | 业务业务中的remark。 | YES | NULL | 推断 |
| `Product_price_set` | `varchar(255)` | 商品价格set | 业务业务中的商品价格set。 | YES | NULL | 推断 |
| `Product_price_set_code` | `bigint` | 商品价格setcode | 业务业务对象的商品价格setcode。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 业务业务中的syncfromold。 | YES | NULL | 推断 |
| `Pid_from_old` | `bigint` | pidfromold | 业务业务中的pidfromold。 | YES | NULL | 推断 |
| `Annual` | `tinyint` | annual | 业务业务中的annual。 | YES | NULL | 推断 |
| `Over_time` | `datetime` | over时间 | 业务业务中的over时间。 | YES | NULL | 推断 |
| `JLWeappNum` | `int` | jlweappnum | 业务业务中的jlweappnum。 | YES | NULL | 推断 |
| `JBWeappNum` | `int` | jbweappnum | 业务业务中的jbweappnum。 | YES | NULL | 推断 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `wechat` | `varchar` | 微信 | 业务业务中的微信。 |  |  | 推断 |
| `inst_type` | `varchar` | inst类型 | 业务业务分类或类型。 |  |  | 推断 |
| `technical_director_name` | `varchar` | technicaldirectorname | 业务业务对象的technicaldirectorname。 |  |  | 推断 |
| `technical_director_phone` | `varchar` | technicaldirectorphone | 业务业务中的technicaldirectorphone。 |  |  | 推断 |
| `technical_director_email` | `varchar` | technicaldirectoremail | 业务业务中的technicaldirectoremail。 |  |  | 推断 |
| `technical_director_wechat` | `varchar` | technicaldirector微信 | 业务业务中的technicaldirector微信。 |  |  | 推断 |
| `business_director_name` | `varchar` | 业务directorname | 业务业务对象的业务directorname。 |  |  | 推断 |
| `business_director_phone` | `varchar` | 业务directorphone | 业务业务中的业务directorphone。 |  |  | 推断 |
| `business_director_email` | `varchar` | 业务directoremail | 业务业务中的业务directoremail。 |  |  | 推断 |
| `business_director_wechat` | `varchar` | 业务director微信 | 业务业务中的业务director微信。 |  |  | 推断 |
| `tax_identification_number` | `varchar` | taxidentification数量 | 业务业务中的taxidentification数量。 |  |  | 推断 |
| `company_account_number` | `varchar` | companyaccount数量 | 业务业务中的companyaccount数量。 |  |  | 推断 |
| `account_name` | `varchar` | accountname | 业务业务对象的accountname。 |  |  | 推断 |
| `bank_of_deposit` | `varchar` | bankof储值 | 业务业务中的bankof储值。 |  |  | 推断 |
| `pcnum` | `int` | pcnum | 业务业务中的pcnum。 |  |  | 推断 |
| `pc_lsnum` | `int` | pclsnum | 业务业务中的pclsnum。 |  |  | 推断 |
| `pc_ftnum` | `int` | pcftnum | 业务业务中的pcftnum。 |  |  | 推断 |
| `pc_zynum` | `int` | pczynum | 业务业务中的pczynum。 |  |  | 推断 |
| `pc_ywnum` | `int` | pcywnum | 业务业务中的pcywnum。 |  |  | 推断 |
| `pc_hylsnum` | `int` | pchylsnum | 业务业务中的pchylsnum。 |  |  | 推断 |
| `pc_lspsnum` | `int` | pclspsnum | 业务业务中的pclspsnum。 |  |  | 推断 |
| `pc_lsbbnum` | `int` | pclsbbnum | 业务业务中的pclsbbnum。 |  |  | 推断 |
| `dcbnum` | `int` | dcbnum | 业务业务中的dcbnum。 |  |  | 推断 |
| `azpbnum` | `int` | azpbnum | 业务业务中的azpbnum。 |  |  | 推断 |
| `azsjnum` | `int` | azsjnum | 业务业务中的azsjnum。 |  |  | 推断 |
| `ipadnum` | `int` | ipadnum | 业务业务中的ipadnum。 |  |  | 推断 |
| `zzdcnum` | `int` | zzdcnum | 业务业务中的zzdcnum。 |  |  | 推断 |
| `jlweappnum` | `int` | jlweappnum | 业务业务中的jlweappnum。 |  |  | 推断 |
| `jbweappnum` | `int` | jbweappnum | 业务业务中的jbweappnum。 |  |  | 推断 |
| `balance` | `decimal` | 余额 | 业务业务中的余额。 |  |  | 推断 |
| `principal_balance` | `decimal` | principal余额 | 业务业务中的principal余额。 |  |  | 推断 |
| `gift_balance` | `decimal` | 赠送余额 | 业务业务中的赠送余额。 |  |  | 推断 |
| `powerbank_balance` | `decimal` | powerbank余额 | 业务业务中的powerbank余额。 |  |  | 推断 |
| `remark` | `varchar` | 备注 | 人工填写或系统保留的补充说明。 |  |  | 通用字段 |
| `share_balance` | `decimal` | share余额 | 业务业务中的share余额。 |  |  | 推断 |
| `product_price_set` | `varchar` | 商品价格set | 业务业务中的商品价格set。 |  |  | 推断 |
| `product_price_set_code` | `bigint` | 商品价格setcode | 业务业务对象的商品价格setcode。 |  |  | 推断 |
| `sync_from_old` | `tinyint(1)` | syncfromold | 业务业务中的syncfromold。 |  |  | 推断 |
| `pid_from_old` | `bigint` | pidfromold | 业务业务中的pidfromold。 |  |  | 推断 |
| `over_time` | `datetime` | over时间 | 业务业务中的over时间。 |  |  | 推断 |
| `annual` | `tinyint(1)` | annual | 业务业务中的annual。 |  |  | 推断 |

#### `sys_merchant`

- 真实表：`sc_merchant`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：商户表。
- 表含义：商户表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + SQL:D:\mywork\nms4pos\sql\ddl.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScMerchant.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\ScMerchant.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 商户名称 | 商户名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `inst` | `varchar(255)` | 代理商 | 代理商 | YES | NULL | DB/DDL/实体注释 |
| `inst_code` | `varchar(255)` | 代理商编号 | 代理商编号 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `varchar(255)` | operationmodel | 业务业务中的operationmodel。 | YES | NULL | 推断 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 负责人手机 | 负责人手机 | YES | NULL | DB/DDL/实体注释 |
| `tel` | `varchar(255)` | tel | 业务业务中的tel。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | 联系地址 | 联系地址 | YES | NULL | DB/DDL/实体注释 |
| `email` | `varchar(255)` | 邮箱 | 邮箱 | YES | NULL | DB/DDL/实体注释 |
| `creator` | `varchar(255)` | 建立人 | 建立人 | YES | NULL | DB/DDL/实体注释 |
| `create_time` | `datetime` | 建立时间 | 建立时间 | YES | NULL | DB/DDL/实体注释 |
| `logo` | `varchar(255)` | logo | logo | YES | NULL | DB/DDL/实体注释 |
| `disable` | `tinyint` | 禁用 | 禁用 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `varchar(255)` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `varchar(255)` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `varchar(255)` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `industry` | `varchar(255)` | 行业名称 | 行业名称 | YES | NULL | DB/DDL/实体注释 |
| `industry_code` | `varchar(255)` | 行业编号 | 行业编号 | YES | NULL | DB/DDL/实体注释 |
| `recommend_code` | `varchar(255)` | recommendcode | 业务业务对象的recommendcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `Can_view` | `tinyint` | canview | 业务业务中的canview。 | YES | NULL | 推断 |
| `SYSType` | `int` | systype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Over_time` | `datetime` | over时间 | 业务业务中的over时间。 | YES | NULL | 推断 |
| `Renew_amount` | `decimal(19,10)` | renew金额 | 业务业务中的renew金额。 | YES | NULL | 推断 |
| `Inst_adm` | `varchar(255)` | instadm | 业务业务中的instadm。 | YES | NULL | 推断 |
| `Inst_adm_code` | `bigint` | instadmcode | 业务业务对象的instadmcode。 | YES | NULL | 推断 |
| `Inst_adm_tech` | `varchar(255)` | instadmtech | 业务业务中的instadmtech。 | YES | NULL | 推断 |
| `Inst_adm_tech_code` | `bigint` | instadmtechcode | 业务业务对象的instadmtechcode。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 业务业务中的syncfromold。 | YES | NULL | 推断 |
| `Trial_days` | `int` | trialdays | 业务业务中的trialdays。 | YES | NULL | 推断 |
| `ExamineTime` | `datetime` | examinetime | 业务业务中的examinetime。 | YES | NULL | 推断 |
| `Total_recharge_amount` | `decimal(19,10)` | total充值金额 | 业务业务中的total充值金额。 | YES | NULL | 推断 |
| `IsExameined` | `tinyint` | isexameined | 业务业务中的isexameined。 | YES | NULL | 推断 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | 0 | DB/DDL/实体注释 |
| `longitude` | `decimal(24,6)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `decimal(24,6)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `over_time` | `DATETIME` | 过期时间 | 过期时间 | YES | NULL | DB/DDL/实体注释 |
| `renew_amount` | `DECIMAL(24,6)` | 续费金额 | 续费金额 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sys_store`

- 真实表：`sc_store`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：门店表。
- 表含义：门店表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + SQL:D:\mywork\nms4pos\sql\ddl.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-biz\nms4cloud-biz-dao\src\main\java\com\nms4cloud\biz\dao\entity\ScStore.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\ScStore.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(64)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(64)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 记录状态 | 记录状态 | YES | NULL | DB/DDL/实体注释 |
| `brand` | `varchar(255)` | 所属品牌名称 | 所属品牌名称 | YES | NULL | DB/DDL/实体注释 |
| `brand_code` | `bigint` | 品牌lid | 品牌lid | YES | NULL | DB/DDL/实体注释 |
| `grp` | `varchar(255)` | 所属分组名称 | 所属分组名称 | YES | NULL | DB/DDL/实体注释 |
| `grp_code` | `bigint` | 旧版的所属分组编号 | 旧版的所属分组编号 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `varchar(255)` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `varchar(255)` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `varchar(255)` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `operation_model` | `varchar(255)` | operationmodel | 库存单据业务中的operationmodel。 | YES | NULL | 推断 |
| `business_model` | `int` | 运营模式 | 运营模式 | YES | NULL | DB/DDL/实体注释 |
| `business_begin_time` | `datetime` | 营业开始时间 | 营业开始时间 | YES | NULL | DB/DDL/实体注释 |
| `business_end_time` | `datetime` | 营业结束时间 | 营业结束时间 | YES | NULL | DB/DDL/实体注释 |
| `disable` | `tinyint` | 禁用 | 禁用 | YES | NULL | DB/DDL/实体注释 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 负责人手机 | 负责人手机 | YES | NULL | DB/DDL/实体注释 |
| `tel` | `varchar(255)` | 固定电话 | 固定电话 | YES | NULL | DB/DDL/实体注释 |
| `addr` | `varchar(255)` | 联系地址 | 联系地址 | YES | NULL | DB/DDL/实体注释 |
| `email` | `varchar(255)` | 邮箱 | 邮箱 | YES | NULL | DB/DDL/实体注释 |
| `addr_map` | `varchar(255)` | 地标 | 地标 | YES | NULL | DB/DDL/实体注释 |
| `longitude` | `varchar(255)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `varchar(255)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `logo` | `varchar(255)` | logo | logo | YES | NULL | DB/DDL/实体注释 |
| `img` | `varchar(255)` | 店铺图片 | 店铺图片 | YES | NULL | DB/DDL/实体注释 |
| `description` | `varchar(255)` | 店铺描述 | 店铺描述 | YES | NULL | DB/DDL/实体注释 |
| `placard` | `text` | 店铺公告 | 店铺公告 | YES | NULL | DB/DDL/实体注释 |
| `business_manager` | `varchar(255)` | 营业执照照片 | 营业执照照片 | YES | NULL | DB/DDL/实体注释 |
| `business_license_img` | `varchar(255)` | 营业执照照片 | 营业执照照片 | YES | NULL | DB/DDL/实体注释 |
| `business_license_code` | `varchar(255)` | 统一社会信用代码 | 统一社会信用代码 | YES | NULL | DB/DDL/实体注释 |
| `legal_representative` | `varchar(255)` | 法定代表人 | 法定代表人 | YES | NULL | DB/DDL/实体注释 |
| `business_license_name` | `varchar(255)` | 营业执照名称 | 营业执照名称 | YES | NULL | DB/DDL/实体注释 |
| `place_of_business` | `varchar(255)` | 经营场所/住所 | 经营场所/住所 | YES | NULL | DB/DDL/实体注释 |
| `registered_capital` | `decimal(19,10)` | 注册资本 | 注册资本 | YES | NULL | DB/DDL/实体注释 |
| `registered_date` | `datetime` | 注册/成立日期 | 注册/成立日期 | YES | NULL | DB/DDL/实体注释 |
| `registration_authority` | `varchar(255)` | 发证/登记机关 | 发证/登记机关 | YES | NULL | DB/DDL/实体注释 |
| `operating_period` | `datetime` | 营业期限 | 营业期限 | YES | NULL | DB/DDL/实体注释 |
| `approval_date` | `datetime` | 核准日期 | 核准日期 | YES | NULL | DB/DDL/实体注释 |
| `business_scope` | `varchar(255)` | 经营范围 | 经营范围 | YES | NULL | DB/DDL/实体注释 |
| `license` | `varchar(255)` | 许可证 | 许可证 | YES | NULL | DB/DDL/实体注释 |
| `boss_certificate` | `varchar(255)` | 手持个人证件 | 手持个人证件 | YES | NULL | DB/DDL/实体注释 |
| `licensed_documents` | `varchar(255)` | 特许证件 | 特许证件 | YES | NULL | DB/DDL/实体注释 |
| `food_safety_quantitative_classification` | `varchar(255)` | 食品安全量化分级 | 食品安全量化分级 | YES | NULL | DB/DDL/实体注释 |
| `sys_init_pwd` | `varchar(255)` | 系统初始化密码 | 系统初始化密码 | YES | NULL | DB/DDL/实体注释 |
| `Detailed_scope` | `varchar(255)` | detailed范围 | 库存单据业务中的detailed范围。 | YES | NULL | 推断 |
| `Score` | `decimal(19,10)` | score | 库存单据业务中的score。 | YES | NULL | 推断 |
| `Enable_mall` | `tinyint` | enablemall | 库存单据业务中的enablemall。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Mall_begin_time` | `datetime` | mall开始时间 | 库存单据业务中的mall开始时间。 | YES | NULL | 推断 |
| `Mall_end_time` | `datetime` | mall结束时间 | 库存单据业务中的mall结束时间。 | YES | NULL | 推断 |
| `Mall_status` | `tinyint` | mall状态 | 库存单据处理状态或启停状态。 | YES | NULL | 推断 |
| `SYSType` | `int` | systype | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Over_time` | `datetime` | over时间 | 库存单据业务中的over时间。 | YES | NULL | 推断 |
| `Over_year` | `int` | overyear | 库存单据业务中的overyear。 | YES | NULL | 推断 |
| `Over_month` | `int` | overmonth | 库存单据业务中的overmonth。 | YES | NULL | 推断 |
| `Over_day` | `int` | overday | 库存单据业务中的overday。 | YES | NULL | 推断 |
| `Renew_amount` | `decimal(19,10)` | renew金额 | 库存单据业务中的renew金额。 | YES | NULL | 推断 |
| `Book_status` | `tinyint` | book状态 | 库存单据处理状态或启停状态。 | YES | NULL | 推断 |
| `Crt_time` | `datetime` | crt时间 | 库存单据业务中的crt时间。 | YES | NULL | 推断 |
| `Creator` | `varchar(255)` | creator | 库存单据业务中的creator。 | YES | NULL | 推断 |
| `Inst` | `varchar(255)` | inst | 库存单据业务中的inst。 | YES | NULL | 推断 |
| `Inst_code` | `varchar(255)` | instcode | 库存单据业务对象的instcode。 | YES | NULL | 推断 |
| `Inst_adm` | `varchar(255)` | instadm | 库存单据业务中的instadm。 | YES | NULL | 推断 |
| `Inst_adm_code` | `bigint` | instadmcode | 库存单据业务对象的instadmcode。 | YES | NULL | 推断 |
| `Inst_adm_tech` | `varchar(255)` | instadmtech | 库存单据业务中的instadmtech。 | YES | NULL | 推断 |
| `Inst_adm_tech_code` | `bigint` | instadmtechcode | 库存单据业务对象的instadmtechcode。 | YES | NULL | 推断 |
| `Sync_from_old` | `tinyint` | syncfromold | 库存单据业务中的syncfromold。 | YES | NULL | 推断 |
| `Over_time_in_plat` | `datetime` | over时间in平台 | 库存单据业务中的over时间in平台。 | YES | NULL | 推断 |
| `Over_year_in_plat` | `int` | overyearin平台 | 库存单据业务中的overyearin平台。 | YES | NULL | 推断 |
| `Over_month_in_plat` | `int` | overmonthin平台 | 库存单据业务中的overmonthin平台。 | YES | NULL | 推断 |
| `Over_day_in_plat` | `int` | overdayin平台 | 库存单据业务中的overdayin平台。 | YES | NULL | 推断 |
| `can_dao_store_id` | `varchar(64)` | 餐道店铺id | 餐道店铺id | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建者 | 创建者 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新者 | 更新者 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `organization_type` | `int` | 组织类型 | 组织类型 | YES | 1 | DB/DDL/实体注释 |
| `rdc_lid` | `bigint` | 配送中心lid | 配送中心lid | YES | NULL | DB/DDL/实体注释 |
| `rdc_examine` | `tinyint(1)` | 配送中心审核订单 | 配送中心审核订单 | YES | NULL | DB/DDL/实体注释 |
| `to_examine_submit` | `tinyint(1)` | 门店审核订货单时同时提交 | 门店审核订货单时同时提交 | YES | NULL | DB/DDL/实体注释 |
| `check_in_multi_spec` | `tinyint(1)` | 门店多规格盘点 | 门店多规格盘点 | YES | NULL | DB/DDL/实体注释 |
| `self_built_goods` | `tinyint(1)` | 门店自建物品 | 门店自建物品 | YES | NULL | DB/DDL/实体注释 |
| `show_stock_check_in` | `tinyint(1)` | 盘点显示账面库存 | 盘点显示账面库存 | YES | NULL | DB/DDL/实体注释 |
| `receiver` | `varchar(255)` | 收货人 | 收货人 | YES | NULL | DB/DDL/实体注释 |
| `receiver_phone` | `varchar(255)` | 收货人联系方式 | 收货人联系方式 | YES | NULL | DB/DDL/实体注释 |
| `receiver_address` | `varchar(255)` | 收货地址 | 收货地址 | YES | NULL | DB/DDL/实体注释 |
| `number_of_item` | `int` | 数量ofitem | 库存单据业务中的数量ofitem。 | YES | NULL | 推断 |
| `number_of_supplier` | `int` | 数量ofsupplier | 库存单据业务中的数量ofsupplier。 | YES | NULL | 推断 |
| `number_of_delivery` | `int` | 数量ofdelivery | 库存单据业务中的数量ofdelivery。 | YES | NULL | 推断 |
| `number_of_supplier_price` | `int` | 数量ofsupplier价格 | 库存单据业务中的数量ofsupplier价格。 | YES | NULL | 推断 |
| `number_of_delivery_price` | `int` | 数量ofdelivery价格 | 库存单据业务中的数量ofdelivery价格。 | YES | NULL | 推断 |
| `show_in_order` | `tinyint(1)` | 可用于扫码点餐 | 可用于扫码点餐 | NO | 1 | DB/DDL/实体注释 |
| `maolink_key` | `varchar(255)` | 数字价签key | 数字价签key | YES | NULL | DB/DDL/实体注释 |
| `maolink_secret` | `varchar(255)` | 数字价签秘钥 | 数字价签秘钥 | YES | NULL | DB/DDL/实体注释 |
| `latest_online_time` | `datetime` | latestonline时间 | 库存单据业务中的latestonline时间。 | YES | NULL | 推断 |
| `server_ip` | `varchar(90)` | 服务器ip | 服务器ip | YES | NULL | DB/DDL/实体注释 |
| `server_ver` | `varchar(90)` | 服务器版本 | 服务器版本 | YES | NULL | DB/DDL/实体注释 |
| `server_ver_at` | `datetime` | 服务器编译时间 | 服务器编译时间 | YES | NULL | DB/DDL/实体注释 |
| `server_dev_id` | `varchar(90)` | 服务器设备号 | 服务器设备号 | YES | NULL | DB/DDL/实体注释 |
| `server_dev_name` | `varchar(90)` | 服务器设备名 | 服务器设备名 | YES | NULL | DB/DDL/实体注释 |
| `enable_mall` | `TINYINT(4)` | 启用微商城 | 启用微商城 | YES | NULL | DB/DDL/实体注释 |
| `creator` | `VARCHAR(255)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `crt_time` | `DATETIME` | 创建门店时间 | 创建门店时间 | YES | NULL | DB/DDL/实体注释 |
| `over_time` | `DATETIME` | 过期时间 | 过期时间 | YES | NULL | DB/DDL/实体注释 |
| `over_year` | `INT(11)` | 过期年份 | 过期年份 | YES | NULL | DB/DDL/实体注释 |
| `over_month` | `INT(11)` | 过期月份 | 过期月份 | YES | NULL | DB/DDL/实体注释 |
| `over_day` | `INT(11)` | 过期天 | 过期天 | YES | NULL | DB/DDL/实体注释 |
| `over_time_in_plat` | `DATETIME` | 过期时间 | 过期时间(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_year_in_plat` | `INT(11)` | 过期年份 | 过期年份(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_month_in_plat` | `INT(11)` | 过期月份 | 过期月份(平台) | YES | NULL | DB/DDL/实体注释 |
| `over_day_in_plat` | `INT(11)` | 过期天 | 过期天(平台) | YES | NULL | DB/DDL/实体注释 |
| `renew_amount` | `DECIMAL(24,6)` | 续费金额 | 续费金额 | YES | NULL | DB/DDL/实体注释 |
| `mall_begin_time` | `DATETIME` | 微商城营业开始时间 | 微商城营业开始时间 | YES | NULL | DB/DDL/实体注释 |
| `mall_end_time` | `DATETIME` | 微商城营业结束时间 | 微商城营业结束时间 | YES | NULL | DB/DDL/实体注释 |
| `mall_status` | `TINYINT(4)` | 微商城营业状态 | 微商城营业状态 | YES | NULL | DB/DDL/实体注释 |
| `book_status` | `TINYINT(4)` | 是否启用预订 | 是否启用预订 | YES | NULL | DB/DDL/实体注释 |
| `detailed_scope` | `VARCHAR(255)` | 具体经营类别 | 具体经营类别 | YES | NULL | DB/DDL/实体注释 |
| `inst` | `VARCHAR(255)` | 代理商 | 代理商 | YES | NULL | DB/DDL/实体注释 |
| `inst_code` | `VARCHAR(255)` | 代理商编号 | 代理商编号 | YES | NULL | DB/DDL/实体注释 |
| `systype` | `INT` | 系统类型 | 系统类型 | YES | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 |  |  | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 |  |  | 通用字段 |
| `pid_tmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 |  |  | 推断 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 |  |  | 通用字段 |
| `status` | `int` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |

#### `sys_user_data_scope`

- 真实表：`sc_permission`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `url` | `varchar(255)` | url | 业务业务中的url。 | YES | NULL | 推断 |
| `show_name` | `varchar(255)` | showname | 业务业务对象的showname。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 业务业务中的说明。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 业务业务中的create时间。 | YES | NULL | 推断 |
| `modified_time` | `datetime` | modified时间 | 业务业务中的modified时间。 | YES | NULL | 推断 |
| `permission_status` | `int` | permission状态 | 业务处理状态或启停状态。 | YES | NULL | 推断 |
| `showed` | `tinyint` | showed | 业务业务中的showed。 | YES | NULL | 推断 |
| `permission_type_id` | `varchar(255)` | permission类型ID | 业务业务关联的permission类型ID。 | YES | NULL | 推断 |
| `permission_type_name` | `varchar(255)` | permission类型name | 业务业务分类或类型。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `Bi_DianCaiPiCi`

- 真实表：`Bi_DianCaiPiCi`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\Bi_DianCaiPiCiEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `xiaofeid` | `varchar(255)` | xiaofeid | 业务业务中的xiaofeid。 | YES | NULL | 推断 |
| `orgpid` | `int` | orgpid | 业务业务中的orgpid。 | YES | NULL | 推断 |
| `diancairen` | `varchar(255)` | diancairen | 业务业务中的diancairen。 | YES | NULL | 推断 |
| `begintime` | `datetime` | begintime | 业务业务中的begintime。 | YES | NULL | 推断 |
| `endtime` | `datetime` | endtime | 业务业务中的endtime。 | YES | NULL | 推断 |
| `fuwufeilv` | `decimal(19, 10)` | fuwufeilv | 业务业务中的fuwufeilv。 | YES | NULL | 推断 |
| `dazheren` | `varchar(255)` | dazheren | 业务业务中的dazheren。 | YES | NULL | 推断 |
| `dazhefangshi` | `varchar(255)` | dazhefangshi | 业务业务中的dazhefangshi。 | YES | NULL | 推断 |
| `zhekoulv` | `decimal(19, 10)` | zhekoulv | 业务业务中的zhekoulv。 | YES | NULL | 推断 |
| `memberid` | `varchar(255)` | 会员ID | 业务业务中的会员ID。 | YES | NULL | 推断 |
| `membername` | `varchar(255)` | membername | 业务业务对象的membername。 | YES | NULL | 推断 |
| `membersex` | `varchar(255)` | membersex | 业务业务中的membersex。 | YES | NULL | 推断 |
| `huiyuancahao` | `varchar(255)` | huiyuancahao | 业务业务中的huiyuancahao。 | YES | NULL | 推断 |
| `huiyuanbalance` | `decimal(19, 10)` | huiyuanbalance | 业务业务中的huiyuanbalance。 | YES | NULL | 推断 |
| `huiyuanintegral` | `decimal(19, 10)` | huiyuanintegral | 业务业务中的huiyuanintegral。 | YES | NULL | 推断 |
| `shipingfei` | `decimal(19, 10)` | shipingfei | 业务业务中的shipingfei。 | YES | NULL | 推断 |
| `fuwufei` | `decimal(19, 10)` | fuwufei | 业务业务中的fuwufei。 | YES | NULL | 推断 |
| `zhekoue` | `decimal(19, 10)` | zhekoue | 业务业务中的zhekoue。 | YES | NULL | 推断 |
| `tuicaijine` | `decimal(19, 10)` | tuicaijine | 业务业务中的tuicaijine。 | YES | NULL | 推断 |
| `zengsongjine` | `decimal(19, 10)` | zengsongjine | 业务业务中的zengsongjine。 | YES | NULL | 推断 |
| `weishu` | `decimal(19, 10)` | weishu | 业务业务中的weishu。 | YES | NULL | 推断 |
| `lingtou` | `decimal(19, 10)` | lingtou | 业务业务中的lingtou。 | YES | NULL | 推断 |
| `lingtouor` | `varchar(255)` | lingtouor | 业务业务中的lingtouor。 | YES | NULL | 推断 |
| `yingshoujine` | `decimal(19, 10)` | yingshoujine | 业务业务中的yingshoujine。 | YES | NULL | 推断 |
| `tax` | `decimal(19, 10)` | tax | 业务业务中的tax。 | YES | NULL | 推断 |
| `shishoujine` | `decimal(19, 10)` | shishoujine | 业务业务中的shishoujine。 | YES | NULL | 推断 |
| `shoudaojine` | `decimal(19, 10)` | shoudaojine | 业务业务中的shoudaojine。 | YES | NULL | 推断 |
| `zhaohuijine` | `decimal(19, 10)` | zhaohuijine | 业务业务中的zhaohuijine。 | YES | NULL | 推断 |
| `fapiaojine` | `decimal(19, 10)` | fapiaojine | 业务业务中的fapiaojine。 | YES | NULL | 推断 |
| `maidancishu` | `int` | maidancishu | 业务业务中的maidancishu。 | YES | NULL | 推断 |
| `maidanzhuangtai` | `varchar(255)` | maidanzhuangtai | 业务业务中的maidanzhuangtai。 | YES | NULL | 推断 |
| `jiezhangfangshi` | `varchar(255)` | jiezhangfangshi | 业务业务中的jiezhangfangshi。 | YES | NULL | 推断 |
| `jiaobanhao` | `varchar(255)` | jiaobanhao | 业务业务中的jiaobanhao。 | YES | NULL | 推断 |
| `stationid` | `varchar(255)` | stationid | 业务业务中的stationid。 | YES | NULL | 推断 |
| `stationname` | `varchar(255)` | stationname | 业务业务对象的stationname。 | YES | NULL | 推断 |
| `shouyinren` | `varchar(255)` | shouyinren | 业务业务中的shouyinren。 | YES | NULL | 推断 |
| `isshoudongzhekou` | `tinyint` | isshoudongzhekou | 业务业务中的isshoudongzhekou。 | YES | NULL | 推断 |
| `fapiaodanhao` | `varchar(255)` | fapiaodanhao | 业务业务中的fapiaodanhao。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `p_id` | `bigint` | pID | 业务业务关联的pID。 |  |  | 推断 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `xiao_fei_d_pid` | `bigint` | xiaofeidpid | 业务业务中的xiaofeidpid。 |  |  | 推断 |
| `xiao_fei_d` | `XiaoFeiDanEx` | xiaofeid | 业务业务中的xiaofeid。 |  |  | 推断 |
| `org_pid` | `int` | orgpid | 业务业务中的orgpid。 |  |  | 推断 |
| `dian_cai_ren` | `varchar` | diancairen | 业务业务中的diancairen。 |  |  | 推断 |
| `begin_time` | `datetime` | 开始时间 | 业务业务中的开始时间。 |  |  | 推断 |
| `end_time` | `datetime` | 结束时间 | 业务业务中的结束时间。 |  |  | 推断 |
| `fu_wu_fei_lv` | `decimal` | fuwufeilv | 业务业务中的fuwufeilv。 |  |  | 推断 |
| `da_zhe_ren` | `varchar` | dazheren | 业务业务中的dazheren。 |  |  | 推断 |
| `da_zhe_fang_shi` | `varchar` | dazhefangshi | 业务业务中的dazhefangshi。 |  |  | 推断 |
| `zhe_kou_lv` | `decimal` | zhekoulv | 业务业务中的zhekoulv。 |  |  | 推断 |
| `member_id` | `varchar` | 会员ID | 会员记录编号。 |  |  | 通用字段 |
| `member_name` | `varchar` | 会员姓名 | 会员姓名或昵称。 |  |  | 通用字段 |
| `member_sex` | `varchar` | 会员sex | 业务业务中的会员sex。 |  |  | 推断 |
| `hui_yuan_ca_hao` | `varchar` | huiyuancahao | 业务业务中的huiyuancahao。 |  |  | 推断 |
| `hui_yuan_balance` | `decimal` | huiyuan余额 | 业务业务中的huiyuan余额。 |  |  | 推断 |
| `hui_yuan_integral` | `decimal` | huiyuanintegral | 业务业务中的huiyuanintegral。 |  |  | 推断 |
| `shi_ping_fei` | `decimal` | shipingfei | 业务业务中的shipingfei。 |  |  | 推断 |
| `fu_wu_fei` | `decimal` | fuwufei | 业务业务中的fuwufei。 |  |  | 推断 |
| `zhe_kou_e` | `decimal` | zhekoue | 业务业务中的zhekoue。 |  |  | 推断 |
| `tui_cai_jin_e` | `decimal` | tuicaijine | 业务业务中的tuicaijine。 |  |  | 推断 |
| `zeng_song_j_in_e` | `decimal` | zengsongjine | 业务业务中的zengsongjine。 |  |  | 推断 |
| `wei_shu` | `decimal` | weishu | 业务业务中的weishu。 |  |  | 推断 |
| `ling_tou` | `decimal` | lingtou | 业务业务中的lingtou。 |  |  | 推断 |
| `ling_tou_or` | `varchar` | lingtouor | 业务业务中的lingtouor。 |  |  | 推断 |
| `ying_shou_jin_e` | `decimal` | yingshoujine | 业务业务中的yingshoujine。 |  |  | 推断 |
| `shi_shou_jin_e` | `decimal` | shishoujine | 业务业务中的shishoujine。 |  |  | 推断 |
| `shou_dao_jin_e` | `decimal` | shoudaojine | 业务业务中的shoudaojine。 |  |  | 推断 |
| `zhao_hui_jin_e` | `decimal` | zhaohuijine | 业务业务中的zhaohuijine。 |  |  | 推断 |
| `fa_piao_jin_e` | `decimal` | fapiaojine | 业务业务中的fapiaojine。 |  |  | 推断 |
| `mai_dan_ci_shu` | `int` | maidancishu | 业务业务中的maidancishu。 |  |  | 推断 |
| `mai_dan_zhuang_tai` | `varchar` | maidanzhuangtai | 业务业务中的maidanzhuangtai。 |  |  | 推断 |
| `jie_zhang_fang_shi` | `varchar` | jiezhangfangshi | 业务业务中的jiezhangfangshi。 |  |  | 推断 |
| `jiao_ban_hao` | `varchar` | jiaobanhao | 业务业务中的jiaobanhao。 |  |  | 推断 |
| `station_id` | `varchar` | stationID | 业务业务关联的stationID。 |  |  | 推断 |
| `station_name` | `varchar` | stationname | 业务业务对象的stationname。 |  |  | 推断 |
| `shou_yin_ren` | `varchar` | shouyinren | 业务业务中的shouyinren。 |  |  | 推断 |
| `is_shou_dong_zhe_kou` | `tinyint(1)` | isshoudongzhekou | 标记业务业务是否启用或满足isshoudongzhekou条件。 |  |  | 推断 |
| `fa_piao_dan_hao` | `varchar` | fapiaodanhao | 业务业务中的fapiaodanhao。 |  |  | 推断 |
| `xiao_fei_dan_id` | `varchar` | xiaofeidanID | 业务业务关联的xiaofeidanID。 |  |  | 推断 |

### a_pos

#### `biz_gift_dish_range`

- 真实表：`biz_gift_dish_range`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：可赠菜品范围配置（支持角色级别和员工个人级别覆盖，员工配置优先于角色配置）
- 表含义：可赠菜品范围配置（支持角色级别和员工个人级别覆盖，员工配置优先于角色配置）
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\biz_gift_dish_range.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\biz_gift_dish_range.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\resources\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\target\classes\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\BizGiftDishRange.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | NO | NULL | DB/DDL/实体注释 |
| `subject_type` | `varchar(10)` | subject类型 | [enum:SubjectType] 主体类型：ROLE-角色，USER-员工 | NO | NULL | DB/DDL/实体注释 |
| `subject_id` | `bigint` | 主体lid | 主体lid（关联角色lid或员工lid） | NO | NULL | DB/DDL/实体注释 |
| `range_type` | `varchar(10)` | range类型 | [enum:RangeType] 范围类型：ALL-全部可赠，PART-指定范围 | NO | ALL | DB/DDL/实体注释 |
| `dish_codes` | `text` | 菜品codes | 可赠菜品code列表（JSON数组），range_type=ALL时为NULL | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(100)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `updated_by` | `varchar(100)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `deleted` | `tinyint` | 逻辑删除 | 逻辑删除：0-否，1-是 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号 | NO | 0 | DB/DDL/实体注释 |
| `create_time` | `DATETIME` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `update_time` | `DATETIME` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |

#### `biz_ops_limit`

- 真实表：`biz_ops_limit`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：操作额度限制配置（赠送/退菜的金额限制，支持角色级别和员工个人级别覆盖）
- 表含义：操作额度限制配置（赠送/退菜的金额限制，支持角色级别和员工个人级别覆盖）
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\biz_ops_limit.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\biz_ops_limit.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\resources\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\target\classes\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\BizOpsLimit.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | NO | NULL | DB/DDL/实体注释 |
| `subject_type` | `varchar(10)` | subject类型 | [enum:SubjectType] 主体类型：ROLE-角色，USER-员工 | NO | NULL | DB/DDL/实体注释 |
| `subject_id` | `bigint` | 主体lid | 主体lid（关联角色lid或员工lid） | NO | NULL | DB/DDL/实体注释 |
| `ops_type` | `varchar(10)` | ops类型 | [enum:OpsType] 操作类型：GIFT-赠送，REFUND-退菜 | NO | NULL | DB/DDL/实体注释 |
| `limit_order` | `decimal(10,0)` | 单额度上限，单位元 | 单额度上限，单位元（0-不限制） | NO | 0 | DB/DDL/实体注释 |
| `limit_day` | `decimal(10,0)` | 日额度上限，单位元 | 日额度上限，单位元（0-不限制） | NO | 0 | DB/DDL/实体注释 |
| `limit_week` | `decimal(10,0)` | 周额度上限，单位元 | 周额度上限，单位元（0-不限制） | NO | 0 | DB/DDL/实体注释 |
| `limit_month` | `decimal(10,0)` | 月额度上限，单位元 | 月额度上限，单位元（0-不限制） | NO | 0 | DB/DDL/实体注释 |
| `created_by` | `varchar(100)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `updated_by` | `varchar(100)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `deleted` | `tinyint` | 逻辑删除 | 逻辑删除：0-否，1-是 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号 | NO | 0 | DB/DDL/实体注释 |
| `create_time` | `DATETIME` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `update_time` | `DATETIME` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |

#### `biz_ops_limit_stat`

- 真实表：`biz_ops_limit_stat`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：操作额度消耗统计（每员工每操作类型一行，周期key变更时懒重置金额）
- 表含义：操作额度消耗统计（每员工每操作类型一行，周期key变更时懒重置金额）
- 字段来源：`119-old + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\src\test\resources\sql\biz_ops_limit_stat.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\all_tables.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-app\target\test-classes\sql\biz_ops_limit_stat.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\resources\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\target\classes\V20260327_01__biz_ops_limit.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\BizOpsLimitStat.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | NO | NULL | DB/DDL/实体注释 |
| `user_lid` | `bigint` | 员工lid | 员工lid（关联sys_user.lid） | NO | NULL | DB/DDL/实体注释 |
| `ops_type` | `varchar(10)` | ops类型 | [enum:OpsType] 操作类型：GIFT-赠送，REFUND-退菜 | NO | NULL | DB/DDL/实体注释 |
| `stat_day` | `varchar(8)` | statday | 当前日期key，格式yyyyMMdd，如20260327 | NO | NULL | DB/DDL/实体注释 |
| `day_amount` | `decimal(10,0)` | 今日已消耗金额，单位元 | 今日已消耗金额，单位元 | NO | 0 | DB/DDL/实体注释 |
| `stat_week` | `varchar(6)` | 当前周key，格式yyyyww，如202613 | 当前周key，格式yyyyww，如202613 | NO | NULL | DB/DDL/实体注释 |
| `week_amount` | `decimal(10,0)` | 本周已消耗金额，单位元 | 本周已消耗金额，单位元 | NO | 0 | DB/DDL/实体注释 |
| `stat_month` | `varchar(6)` | 当前月key，格式yyyyMM，如202603 | 当前月key，格式yyyyMM，如202603 | NO | NULL | DB/DDL/实体注释 |
| `month_amount` | `decimal(10,0)` | 本月已消耗金额，单位元 | 本月已消耗金额，单位元 | NO | 0 | DB/DDL/实体注释 |
| `created_by` | `varchar(100)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `updated_by` | `varchar(100)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `deleted` | `tinyint` | 逻辑删除 | 逻辑删除：0-否，1-是 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号（用于并发控制） | NO | 0 | DB/DDL/实体注释 |
| `version` | `BIGINT` | 乐观锁版本号 | 乐观锁版本号 | NO | 0 | DB/DDL/实体注释 |
| `create_time` | `DATETIME` | 创建时间 | 创建时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |
| `update_time` | `DATETIME` | 更新时间 | 更新时间 | NO | CURRENT_TIMESTAMP | DB/DDL/实体注释 |

### gylregdb

#### `CaiShiFa`

- 真实表：`CaiShiFa`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\CaiShiFaEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `cai` | `varchar(255)` | cai | 业务业务中的cai。 | YES | NULL | 推断 |
| `caishifaid` | `varchar(255)` | caishifaid | 业务业务中的caishifaid。 | YES | NULL | 推断 |
| `caishifaname` | `varchar(255)` | caishifaname | 业务业务对象的caishifaname。 | YES | NULL | 推断 |
| `miaoshu` | `varchar(255)` | miaoshu | 业务业务中的miaoshu。 | YES | NULL | 推断 |
| `miaoshutmp` | `varchar(255)` | miaoshutmp | 业务业务中的miaoshutmp。 | YES | NULL | 推断 |
| `shangcaishuliang` | `decimal(19, 10)` | shangcaishuliang | 业务业务中的shangcaishuliang。 | YES | NULL | 推断 |
| `buwei` | `varchar(255)` | buwei | 业务业务中的buwei。 | YES | NULL | 推断 |
| `zuofa` | `varchar(255)` | zuofa | 业务业务中的zuofa。 | YES | NULL | 推断 |
| `kuowei` | `varchar(255)` | kuowei | 业务业务中的kuowei。 | YES | NULL | 推断 |
| `yaoqiu` | `varchar(255)` | yaoqiu | 业务业务中的yaoqiu。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `xiaofeicaipingid` | `varchar(255)` | xiaofeicaipingid | 业务业务中的xiaofeicaipingid。 | YES | NULL | 推断 |
| `xiaofeicaipingpid` | `bigint` | xiaofeicaipingpid | 业务业务中的xiaofeicaipingpid。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `cai_pid` | `bigint` | caipid | 业务业务中的caipid。 |  |  | 推断 |
| `cai_shi_fa_id` | `varchar` | caishifaID | 业务业务关联的caishifaID。 |  |  | 推断 |
| `cai_shi_fa_name` | `varchar` | caishifaname | 业务业务对象的caishifaname。 |  |  | 推断 |
| `miao_shu` | `varchar` | miaoshu | 业务业务中的miaoshu。 |  |  | 推断 |
| `miao_shu_tmp` | `varchar` | miaoshutmp | 业务业务中的miaoshutmp。 |  |  | 推断 |
| `shang_cai_shu_liang` | `decimal` | shangcaishuliang | 业务业务中的shangcaishuliang。 |  |  | 推断 |
| `bu_wei` | `varchar` | buwei | 业务业务中的buwei。 |  |  | 推断 |
| `zuo_fa` | `varchar` | zuofa | 业务业务中的zuofa。 |  |  | 推断 |
| `kuo_wei` | `varchar` | kuowei | 业务业务中的kuowei。 |  |  | 推断 |
| `yao_qiu` | `varchar` | yaoqiu | 业务业务中的yaoqiu。 |  |  | 推断 |
| `xiao_fei_dan_id` | `varchar` | xiaofeidanID | 业务业务关联的xiaofeidanID。 |  |  | 推断 |
| `xiao_fei_cai_ping_id` | `varchar` | xiaofeicaipingID | 业务业务关联的xiaofeicaipingID。 |  |  | 推断 |
| `xiao_fei_cai_ping_pid` | `varchar` | xiaofeicaipingpid | 业务业务中的xiaofeicaipingpid。 |  |  | 推断 |

#### `FuKuanQingKuang`

- 真实表：`FuKuanQingKuang`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\FuKuanQingKuangEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `xiaofeid` | `bigint` | xiaofeid | 业务业务中的xiaofeid。 | YES | NULL | 推断 |
| `diancaipici` | `int` | diancaipici | 业务业务中的diancaipici。 | YES | NULL | 推断 |
| `fukuanqingkuangid` | `varchar(255)` | fukuanqingkuangid | 业务业务中的fukuanqingkuangid。 | YES | NULL | 推断 |
| `fukuanqingkuangname` | `varchar(255)` | fukuanqingkuangname | 业务业务对象的fukuanqingkuangname。 | YES | NULL | 推断 |
| `zhifujine` | `decimal(19, 10)` | zhifujine | 业务业务中的zhifujine。 | YES | NULL | 推断 |
| `huilv` | `decimal(19, 10)` | huilv | 业务业务中的huilv。 | YES | NULL | 推断 |
| `hsjine` | `decimal(19, 10)` | hsjine | 业务业务中的hsjine。 | YES | NULL | 推断 |
| `zhenshishouru` | `decimal(19, 10)` | zhenshishouru | 业务业务中的zhenshishouru。 | YES | NULL | 推断 |
| `exchangable` | `tinyint` | exchangable | 业务业务中的exchangable。 | YES | NULL | 推断 |
| `type` | `varchar(255)` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `zhaohuijine` | `decimal(19, 10)` | zhaohuijine | 业务业务中的zhaohuijine。 | YES | NULL | 推断 |
| `shishoujine` | `decimal(19, 10)` | shishoujine | 业务业务中的shishoujine。 | YES | NULL | 推断 |
| `sumofintegrate` | `decimal(19, 10)` | sumofintegrate | 业务业务中的sumofintegrate。 | YES | NULL | 推断 |
| `huiyuankaid` | `varchar(255)` | huiyuankaid | 业务业务中的huiyuankaid。 | YES | NULL | 推断 |
| `huiyuanname` | `varchar(255)` | huiyuanname | 业务业务对象的huiyuanname。 | YES | NULL | 推断 |
| `guazhangid` | `varchar(255)` | guazhangid | 业务业务中的guazhangid。 | YES | NULL | 推断 |
| `guazhangname` | `varchar(255)` | guazhangname | 业务业务对象的guazhangname。 | YES | NULL | 推断 |
| `qiandanren` | `varchar(255)` | qiandanren | 业务业务中的qiandanren。 | YES | NULL | 推断 |
| `returnbillid` | `varchar(255)` | returnbillid | 业务业务中的returnbillid。 | YES | NULL | 推断 |
| `xianjinjuanid` | `varchar(255)` | xianjinjuanid | 业务业务中的xianjinjuanid。 | YES | NULL | 推断 |
| `yujiaodingjinid` | `varchar(255)` | yujiaodingjinid | 业务业务中的yujiaodingjinid。 | YES | NULL | 推断 |
| `shouyinyuan` | `varchar(255)` | shouyinyuan | 业务业务中的shouyinyuan。 | YES | NULL | 推断 |
| `billnumber` | `varchar(255)` | billnumber | 业务业务中的billnumber。 | YES | NULL | 推断 |
| `availablepoint` | `decimal(19, 10)` | availablepoint | 业务业务中的availablepoint。 | YES | NULL | 推断 |
| `availablevalue` | `decimal(19, 10)` | availablevalue | 业务业务中的availablevalue。 | YES | NULL | 推断 |
| `morememberkaid` | `varchar(255)` | morememberkaid | 业务业务中的morememberkaid。 | YES | NULL | 推断 |
| `morememberid` | `varchar(255)` | morememberid | 业务业务中的morememberid。 | YES | NULL | 推断 |
| `moremembername` | `varchar(255)` | moremembername | 业务业务对象的moremembername。 | YES | NULL | 推断 |
| `paymoney` | `decimal(19, 10)` | paymoney | 业务业务中的paymoney。 | YES | NULL | 推断 |
| `norealincome` | `tinyint` | norealincome | 业务业务对象的norealincome。 | YES | NULL | 推断 |
| `shishoulv` | `decimal(19, 10)` | shishoulv | 业务业务中的shishoulv。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `posserialno` | `varchar(255)` | posserialno | 业务业务对象的posserialno。 | YES | NULL | 推断 |
| `paychanel` | `varchar(255)` | paychanel | 业务业务中的paychanel。 | YES | NULL | 推断 |
| `payplatform` | `varchar(255)` | payplatform | 业务业务中的payplatform。 | YES | NULL | 推断 |
| `paystatus` | `varchar(255)` | paystatus | 业务处理状态或启停状态。 | YES | NULL | 推断 |
| `subject` | `varchar(255)` | subject | 业务业务中的subject。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `ShopName` | `varchar(255)` | shopname | 业务业务对象的shopname。 | YES | NULL | 推断 |
| `TuiKuanJinE` | `decimal(19, 10)` | tuikuanjine | 业务业务中的tuikuanjine。 | YES | NULL | 推断 |
| `Is_inline` | `tinyint` | isinline | 标记业务业务是否启用或满足isinline条件。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺名称 | 店铺名称 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开台时间 | 开台时间 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time` | `datetime` | 结账时间 | 结账时间 | YES | NULL | DB/DDL/实体注释 |
| `order_sub_type` | `int` | 账单类型;堂食、外卖、自提 | 账单类型;堂食、外卖、自提 | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(32)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `area_name` | `varchar(32)` | 区域名称 | 区域名称 | YES | NULL | DB/DDL/实体注释 |
| `table_name` | `varchar(32)` | 桌台名称 | 桌台名称 | YES | NULL | DB/DDL/实体注释 |
| `checkout_by` | `text` | checkout人 | 业务业务中的checkout人。 | YES |  | 推断 |
| `remark` | `varchar(255)` | 标记 | 标记 | YES | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 账单流水号 | 账单流水号 | YES | NULL | DB/DDL/实体注释 |
| `takeout_channel` | `int` | 外卖渠道 | 外卖渠道 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(32)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `free_service_charge` | `tinyint` | 免服务费 | 免服务费 | YES | NULL | DB/DDL/实体注释 |
| `online` | `tinyint` | 线上订单 | 线上订单 | YES | NULL | DB/DDL/实体注释 |
| `actual_income` | `decimal(19, 10)` | 实际收入 | 实际收入 | YES | 0.0000000000 | DB/DDL/实体注释 |
| `virtual_income` | `decimal(19, 10)` | 虚拟收入 | 虚拟收入 | YES | 0.0000000000 | DB/DDL/实体注释 |
| `group_promote_amount` | `decimal(24, 10)` | 团购折扣 | 团购折扣 | YES | NULL | DB/DDL/实体注释 |
| `member_gift_amount` | `decimal(24, 10)` | 赠送折扣 | 赠送折扣 | YES | NULL | DB/DDL/实体注释 |
| `promote_detail` | `text` | 优惠明细 | 优惠明细 | YES |  | DB/DDL/实体注释 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `xiao_fei_d_pid` | `bigint` | xiaofeidpid | 业务业务中的xiaofeidpid。 |  |  | 推断 |
| `xiao_fei_d` | `XiaoFeiDanEx` | xiaofeid | 业务业务中的xiaofeid。 |  |  | 推断 |
| `dian_cai_pi_ci` | `int` | diancaipici | 业务业务中的diancaipici。 |  |  | 推断 |
| `fu_kuan_qing_kuang_id` | `varchar` | fukuanqingkuangID | 业务业务关联的fukuanqingkuangID。 |  |  | 推断 |
| `fu_kuan_qing_kuang_name` | `varchar` | fukuanqingkuangname | 业务业务对象的fukuanqingkuangname。 |  |  | 推断 |
| `hui_yuan_ka_id` | `varchar` | huiyuankaID | 业务业务关联的huiyuankaID。 |  |  | 推断 |
| `hui_yuan_name` | `varchar` | huiyuanname | 业务业务对象的huiyuanname。 |  |  | 推断 |
| `gua_zhang_id` | `varchar` | guazhangID | 业务业务关联的guazhangID。 |  |  | 推断 |
| `gua_zhang_name` | `varchar` | guazhangname | 业务业务对象的guazhangname。 |  |  | 推断 |
| `qian_dan_ren` | `varchar` | qiandanren | 业务业务中的qiandanren。 |  |  | 推断 |
| `return_bill_id` | `varchar` | return账单ID | 业务业务关联的return账单ID。 |  |  | 推断 |
| `xian_jin_juan_id` | `varchar` | xianjinjuanID | 业务业务关联的xianjinjuanID。 |  |  | 推断 |
| `yu_jiao_ding_jin_id` | `varchar` | yujiaodingjinID | 业务业务关联的yujiaodingjinID。 |  |  | 推断 |
| `shou_yin_yuan` | `varchar` | shouyinyuan | 业务业务中的shouyinyuan。 |  |  | 推断 |
| `bill_number` | `varchar` | 账单数量 | 业务业务中的账单数量。 |  |  | 推断 |
| `more_member_ka_id` | `varchar` | more会员kaID | 业务业务关联的more会员kaID。 |  |  | 推断 |
| `more_member_id` | `varchar` | more会员ID | 业务业务关联的more会员ID。 |  |  | 推断 |
| `more_member_name` | `varchar` | more会员name | 业务业务对象的more会员name。 |  |  | 推断 |
| `no_real_income` | `tinyint(1)` | norealincome | 业务业务对象的norealincome。 |  |  | 推断 |
| `xiao_fei_dan_id` | `varchar` | xiaofeidanID | 业务业务关联的xiaofeidanID。 |  |  | 推断 |
| `pos_serial_no` | `varchar` | posserialno | 业务业务对象的posserialno。 |  |  | 推断 |
| `pay_chanel` | `varchar` | 支付chanel | 业务业务中的支付chanel。 |  |  | 推断 |
| `pay_platform` | `varchar` | 支付平台 | 业务业务中的支付平台。 |  |  | 推断 |
| `pay_status` | `varchar` | 支付状态 | 业务处理状态或启停状态。 |  |  | 推断 |
| `is_inline` | `tinyint(1)` | isinline | 标记业务业务是否启用或满足isinline条件。 |  |  | 推断 |
| `platform_discount_amt` | `decimal` | 平台折扣amt | 业务业务中的平台折扣amt。 |  |  | 推断 |
| `profit_food` | `varchar` | profit菜品 | 业务业务中的profit菜品。 |  |  | 推断 |

#### `JiaoBanXinXi`

- 真实表：`JiaoBanXinXi`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `jiaobanhao` | `varchar(255)` | jiaobanhao | 业务业务中的jiaobanhao。 | YES | NULL | 推断 |
| `stationname` | `varchar(255)` | stationname | 业务业务对象的stationname。 | YES | NULL | 推断 |
| `jiaobanrenname` | `varchar(255)` | jiaobanrenname | 业务业务对象的jiaobanrenname。 | YES | NULL | 推断 |
| `alive` | `tinyint` | alive | 业务业务中的alive。 | YES | NULL | 推断 |
| `starttime` | `datetime` | starttime | 业务业务中的starttime。 | YES | NULL | 推断 |
| `endtime` | `datetime` | endtime | 业务业务中的endtime。 | YES | NULL | 推断 |
| `billnum` | `int` | billnum | 业务业务中的billnum。 | YES | NULL | 推断 |
| `sumofconsume` | `decimal(19, 10)` | sumofconsume | 业务业务中的sumofconsume。 | YES | NULL | 推断 |
| `sumofservice` | `decimal(19, 10)` | sumofservice | 业务业务中的sumofservice。 | YES | NULL | 推断 |
| `sumofdiscount` | `decimal(19, 10)` | sumofdiscount | 业务业务中的sumofdiscount。 | YES | NULL | 推断 |
| `sumofincome` | `decimal(19, 10)` | sumofincome | 业务业务中的sumofincome。 | YES | NULL | 推断 |
| `shijijine` | `decimal(19, 10)` | shijijine | 业务业务中的shijijine。 | YES | NULL | 推断 |
| `beiyongjin` | `decimal(19, 10)` | beiyongjin | 业务业务中的beiyongjin。 | YES | NULL | 推断 |
| `printcount` | `int` | printcount | 业务业务中的printcount。 | YES | NULL | 推断 |
| `upload` | `tinyint` | upload | 业务业务中的upload。 | YES | NULL | 推断 |
| `StationID` | `varchar(255)` | stationid | 业务业务中的stationid。 | YES | NULL | 推断 |
| `JiaoBanRenID` | `bigint` | jiaobanrenid | 业务业务中的jiaobanrenid。 | YES | NULL | 推断 |

### a_pos

#### `pos_app_ver`

- 真实表：`pos_app_ver`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：应用版本记录表
- 表含义：应用版本记录表
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosAppVer.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `app` | `int` | 应用 | 应用 | YES | NULL | DB/DDL/实体注释 |
| `ver` | `varchar(90)` | 版本号 | 版本号 | YES | NULL | DB/DDL/实体注释 |
| `gradual` | `tinyint(1)` | 灰度升级 | 灰度升级 | YES | NULL | DB/DDL/实体注释 |
| `dev_id` | `text` | 适用于灰度升级的设备 | 适用于灰度升级的设备 | YES | NULL | DB/DDL/实体注释 |
| `installer_package` | `text` | 安装包路径 | 安装包路径 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `sids` | `text` | 门店列表 | 门店列表 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `text` | 发布备注 | 发布备注 | YES | NULL | DB/DDL/实体注释 |
| `mids` | `text` | 集团列表 | 集团列表 | YES | NULL | DB/DDL/实体注释 |
| `force_install` | `tinyint(1)` | 是否强制安装升级包 | 是否强制安装升级包 | YES | NULL | DB/DDL/实体注释 |
| `scheduled_update_time` | `datetime` | 计划安装时间 | 计划安装时间 | YES | NULL | DB/DDL/实体注释 |
| `immediate_update` | `tinyint(1)` | 是否立即更新 | 是否立即更新 | YES | NULL | DB/DDL/实体注释 |
| `package_size` | `bigint` | packagesize | 业务业务中的packagesize。 |  |  | 推断 |
| `sha256` | `varchar` | sha256 | 业务业务中的sha256。 |  |  | 推断 |
| `source_url` | `varchar` | 来源url | 业务业务中的来源url。 |  |  | 推断 |
| `cdn_url` | `varchar` | cdnurl | 业务业务中的cdnurl。 |  |  | 推断 |
| `mirror_urls` | `varchar` | mirrorurls | 业务业务中的mirrorurls。 |  |  | 推断 |
| `storage_provider` | `varchar` | storageprovider | 业务业务中的storageprovider。 |  |  | 推断 |
| `download_strategy` | `tinyint/varchar` | downloadstrategy | 业务业务中的downloadstrategy。 |  |  | 推断 |
| `release_channel` | `varchar` | release渠道 | 业务业务中的release渠道。 |  |  | 推断 |

#### `pos_approval_config`

- 真实表：`pos_approval_config`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：审批配置
- 表含义：审批配置
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosApprovalConfig.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 预留字段，编号 | 预留字段，编号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 事件名称 | 事件名称 | YES | NULL | DB/DDL/实体注释 |
| `approval_type` | `int` | 事件类型 | 事件类型 | NO | NULL | DB/DDL/实体注释 |
| `approval_conf` | `text` | 审批人配置 | 审批人配置 | YES | NULL | DB/DDL/实体注释 |
| `approval_extend` | `text` | 预留字段，审批扩展 | 预留字段，审批扩展 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 审批开关 | 审批开关 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `parent_name` | `varchar` | parentname | 业务业务对象的parentname。 |  |  | 推断 |

#### `pos_approval_order`

- 真实表：`pos_approval_order`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：审批单
- 表含义：审批单
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosApprovalOrder.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 预留字段，审批单号 | 预留字段，审批单号 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 单据日期 | 单据日期 | YES | NULL | DB/DDL/实体注释 |
| `title` | `varchar(90)` | 审批主题 | 审批主题 | YES | NULL | DB/DDL/实体注释 |
| `module` | `varchar(90)` | 审批模块 | 审批模块 | YES | NULL | DB/DDL/实体注释 |
| `urgency_level` | `int` | 紧急程度 | 紧急程度 | YES | NULL | DB/DDL/实体注释 |
| `desc` | `text` | 变动说明/描述 | 变动说明/描述 | YES | NULL | DB/DDL/实体注释 |
| `attachments` | `text` | 附件列表 | 附件列表 | YES | NULL | DB/DDL/实体注释 |
| `content` | `longtext` | 成本卡内容 | 成本卡内容 | YES | NULL | DB/DDL/实体注释 |
| `approval_conf` | `text` | 审批配置 | 审批配置 | YES | NULL | DB/DDL/实体注释 |
| `approval_type` | `int` | 事件类型 | 事件类型 | NO | NULL | DB/DDL/实体注释 |
| `initiator` | `bigint` | 审批人lid | 审批人lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `approval_conf_item` | `varchar` | approvalconfitem | 业务业务中的approvalconfitem。 |  |  | 推断 |
| `pending` | `tinyint(1)` | pending | 业务业务中的pending。 |  |  | 推断 |
| `approval_state` | `int` | approval状态 | 业务业务中的approval状态。 |  |  | 推断 |

#### `pos_auto_discount`

- 真实表：`pos_auto_discount`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：自动打折
- 表含义：自动打折
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosAutoDiscount.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `discount_lid` | `bigint` | 折扣lid | 折扣lid | YES | NULL | DB/DDL/实体注释 |
| `discount_name` | `varchar(90)` | 折扣名称 | 折扣名称 | YES | NULL | DB/DDL/实体注释 |
| `tbl_type_lid` | `bigint` | 桌台类型lid | 桌台类型lid | YES | NULL | DB/DDL/实体注释 |
| `tbl_type_name` | `varchar(90)` | 桌台类型名称 | 桌台类型名称 | YES | NULL | DB/DDL/实体注释 |
| `period_lid` | `bigint` | 营业时段lid | 营业时段lid | YES | NULL | DB/DDL/实体注释 |
| `period_name` | `varchar(90)` | 营业时段名称 | 营业时段名称 | YES | NULL | DB/DDL/实体注释 |
| `auto_discount_type` | `int` | 自动打折类型 | 自动打折类型 | YES | NULL | DB/DDL/实体注释 |
| `discount_time_type` | `int` | 打折时间类型 | 打折时间类型 | YES | NULL | DB/DDL/实体注释 |
| `start_at` | `datetime` | 开始时间 | 开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_at` | `datetime` | 结束时间 | 结束时间 | YES | NULL | DB/DDL/实体注释 |
| `monday` | `tinyint(1)` | 周一 | 周一 | YES | NULL | DB/DDL/实体注释 |
| `tuesday` | `tinyint(1)` | 周二 | 周二 | YES | NULL | DB/DDL/实体注释 |
| `wednesday` | `tinyint(1)` | 周三 | 周三 | YES | NULL | DB/DDL/实体注释 |
| `thursday` | `tinyint(1)` | 周四 | 周四 | YES | NULL | DB/DDL/实体注释 |
| `friday` | `tinyint(1)` | 周五 | 周五 | YES | NULL | DB/DDL/实体注释 |
| `saturday` | `tinyint(1)` | 周六 | 周六 | YES | NULL | DB/DDL/实体注释 |
| `sunday` | `tinyint(1)` | 周日 | 周日 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `festival_lid` | `bigint` | 节日lid | 节日lid | YES | NULL | DB/DDL/实体注释 |
| `festival_name` | `varchar(100)` | 节日名称 | 节日名称 | YES | NULL | DB/DDL/实体注释 |

#### `pos_book_group`

- 真实表：`pos_book_group`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：菜谱分组
- 表含义：菜谱分组
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosBookGroup.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `book_json` | `text` | 菜谱列表 | 菜谱列表 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `brand_lid` | `bigint` | 品牌lid | 品牌lid | YES | NULL | DB/DDL/实体注释 |

#### `pos_customer_bill_setting`

- 真实表：`pos_customer_bill_setting`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：顾客联设置
- 表含义：顾客联设置
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosCustomerBillSetting.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `prn_queue` | `text` | 打印队列 | 打印队列 | YES | NULL | DB/DDL/实体注释 |
| `by_mobile` | `tinyint(1)` | 移动设备发起的操作 | 移动设备发起的操作 | YES | NULL | DB/DDL/实体注释 |
| `for_checkout` | `tinyint(1)` | 适用于结账单 | 适用于结账单 | YES | NULL | DB/DDL/实体注释 |
| `pc_lid` | `bigint` | 电脑编号 | 电脑编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_lid` | `bigint` | 桌台区域编号 | 桌台区域编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_type_lid` | `bigint` | 桌台类型编号 | 桌台类型编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_lid` | `bigint` | 桌台编号 | 桌台编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |

#### `pos_dept`

- 真实表：`pos_dept`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：出品部门和出品部门
- 表含义：出品部门和出品部门
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosDept.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `profit_dept` | `bigint` | 利润部门 | 利润部门 | YES | NULL | DB/DDL/实体注释 |
| `prn_queue` | `text` | 打印队列 | 打印队列 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `wms_dept_lids` | `text` | 供应链部门lids | 供应链部门lids | YES | NULL | DB/DDL/实体注释 |
| `cashier_dept_names` | `text` | 供应链部门lids | 供应链部门lids | YES | NULL | DB/DDL/实体注释 |

#### `pos_dev`

- 真实表：`pos_dev`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：设备列表
- 表含义：设备列表
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-pos\nms4cloud-pos-dal\src\main\java\com\nms4cloud\pos\dal\entity\PosDev.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosDev.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(128)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `name` | `varchar(90)` | 设备名称 | 设备名称 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `model` | `int` | 设备型号 | 设备型号 | YES | NULL | DB/DDL/实体注释 |
| `extra_info` | `text` | 附加信息 | 附加信息 | YES | NULL | DB/DDL/实体注释 |
| `app_ver` | `varchar(32)` | 软件版本 | 软件版本 | YES | NULL | DB/DDL/实体注释 |
| `online` | `tinyint(1)` | 在线 | 在线 | YES | NULL | DB/DDL/实体注释 |
| `last_active_time` | `datetime` | 上次激活时间 | 上次激活时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `master_` | `tinyint(1)` | 是否主设备 | 是否主设备 | NO | 0 | DB/DDL/实体注释 |
| `self_start` | `tinyint(1)` | 自启动 | 自启动 | NO | 0 | DB/DDL/实体注释 |
| `app` | `int` | 软件类型 | 软件类型 | NO | 1 | DB/DDL/实体注释 |
| `app_pack_name` | `varchar(64)` | 软件包名 | 软件包名 | YES | NULL | DB/DDL/实体注释 |
| `old_pack_name` | `varchar(64)` | 软件旧包名 | 软件旧包名 | YES | NULL | DB/DDL/实体注释 |
| `pc_lid` | `bigint` | pcID | 业务业务关联的pcID。 | YES | NULL | 推断 |
| `dev_id` | `varchar(64)` | 设备UUID | 设备UUID | YES | NULL | DB/DDL/实体注释 |
| `ip` | `varchar(50)` | 设备IP | 设备IP | YES | NULL | DB/DDL/实体注释 |
| `hostname` | `varchar(255)` | 主机名 | 主机名 | YES | NULL | DB/DDL/实体注释 |
| `compile_time` | `varchar(100)` | 编译时间 | 编译时间 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `master` | `tinyint(1)` | master | 业务业务中的master。 |  |  | 推断 |

#### `pos_dish_hide`

- 真实表：`pos_dish_hide`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：菜品隐藏设置
- 表含义：菜品隐藏设置
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosDishHide.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `day_of_the_week` | `varchar(32)` | 星期几 | 星期几 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开始时间 | 开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间 | 结束时间 | YES | NULL | DB/DDL/实体注释 |
| `dish_type_lid_list` | `text` | 菜品类别编号 | 菜品类别编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid_list` | `text` | 菜品编号 | 菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `sellout_or_hide` | `tinyint(1)` | 用于隐藏或者估清的标志位 | 用于隐藏或者估清的标志位 | YES | NULL | DB/DDL/实体注释 |
| `state` | `tinyint(1)` | 是否启用 | 是否启用 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `pos_biz_type` | `int` | 业务类型 | 业务类型 | YES | NULL | DB/DDL/实体注释 |

#### `pos_dish_to_prn_dept`

- 真实表：`pos_dish_to_prn_dept`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：菜品与出品部门的映射
- 表含义：菜品与出品部门的映射
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosDishToPrnDept.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `prn_dept_lid` | `bigint` | 出品部门编号 | 出品部门编号 | YES | NULL | DB/DDL/实体注释 |
| `pc_lid` | `bigint` | 电脑编号 | 电脑编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_lid` | `bigint` | 台区编号 | 台区编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_type_lid` | `bigint` | 菜品类别编号 | 菜品类别编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品编号 | 菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |

#### `pos_group_dish_book`

- 真实表：`pos_group_dish_book`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：集团菜谱
- 表含义：集团菜谱
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosGroupDishBook.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `brand_lid` | `bigint` | 品牌编号 | 品牌编号 | YES | NULL | DB/DDL/实体注释 |
| `published_time` | `datetime` | 上次发布时间 | 上次发布时间 | YES | NULL | DB/DDL/实体注释 |
| `published_by` | `varchar(90)` | 发布人 | 发布人 | YES | NULL | DB/DDL/实体注释 |
| `activation_time` | `datetime` | 生效时间 | 生效时间 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 发布状态 | 发布状态 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `varchar(32)` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 标签 | 标签 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `store_lids` | `text` | 默认门店 | 默认门店 | YES | NULL | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 状态 | 业务处理状态或启停状态。 |  |  | 通用字段 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pos_group_dish_book_release`

- 真实表：`pos_group_dish_book_release`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：菜谱发布记录
- 表含义：菜谱发布记录
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\PosGroupDishBookRelease.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `book_lid` | `bigint` | 菜谱 | 菜谱 | YES | NULL | DB/DDL/实体注释 |
| `store_lids` | `text` | 发布门店 | 发布门店 | YES | NULL | DB/DDL/实体注释 |
| `book_release_rule` | `int` | 发布规则 | 发布规则 | YES | NULL | DB/DDL/实体注释 |
| `dish_release_rule` | `int` | 菜品信息发布规则 | 菜品信息发布规则 | YES | NULL | DB/DDL/实体注释 |
| `release_time` | `datetime` | 发布时间 | 发布时间 | YES | NULL | DB/DDL/实体注释 |
| `release_by` | `varchar(90)` | 发布人 | 发布人 | YES | NULL | DB/DDL/实体注释 |
| `done` | `tinyint(1)` | 发布完成 | 发布完成 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `done_time` | `datetime` | 发布完成时间 | 发布完成时间 | YES | NULL | DB/DDL/实体注释 |
| `brand_lid` | `bigint` | 品牌lid | 品牌lid | YES | NULL | DB/DDL/实体注释 |

#### `pos_pricing_by_time`

- 真实表：`pos_pricing_by_time`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：计时计价表
- 表含义：计时计价表
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `pricing_type` | `int` | 计价类型 | 计价类型 | YES | NULL | DB/DDL/实体注释 |
| `timeout_type` | `int` | 超时类型 | 超时类型 | YES | NULL | DB/DDL/实体注释 |
| `time_period_type` | `int` | 时段类型 | 时段类型 | YES | NULL | DB/DDL/实体注释 |
| `constant_time` | `int` | 固定时间 | 固定时间 | YES | NULL | DB/DDL/实体注释 |
| `constant_charge` | `decimal(10,0)` | 固定收费 | 固定收费 | YES | NULL | DB/DDL/实体注释 |
| `ceiling_charge` | `decimal(10,0)` | 封顶费 | 封顶费 | YES | NULL | DB/DDL/实体注释 |
| `timing_free_time` | `int` | 计时免费时间 | 计时免费时间 | YES | NULL | DB/DDL/实体注释 |
| `minimum_spending_duration` | `int` | 最低消费时长 | 最低消费时长 | YES | NULL | DB/DDL/实体注释 |
| `minimum_billing_duration` | `int` | 最小计费时长 | 最小计费时长 | YES | NULL | DB/DDL/实体注释 |
| `timing_participation_member_discount` | `tinyint(1)` | 计时参与会员折扣 | 计时参与会员折扣 | YES | NULL | DB/DDL/实体注释 |
| `added_service_fee` | `tinyint(1)` | 加收服务费 | 加收服务费 | YES | NULL | DB/DDL/实体注释 |
| `advance_session_charge` | `tinyint(1)` | 超前场收费 | 超前场收费 | YES | NULL | DB/DDL/实体注释 |
| `advance_session_free_time` | `int` | 超前场免费时间 | 超前场免费时间 | YES | NULL | DB/DDL/实体注释 |
| `advance_session_hourly_price` | `decimal(10,0)` | 超前场每小时价格 | 超前场每小时价格 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_pricing_by_time_period`

- 真实表：`pos_pricing_by_time_period`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：计时计价时段表
- 表含义：计时计价时段表
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `time_period_type` | `int` | 时段类型 | 时段类型 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 起始时间 | 起始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间 | 结束时间 | YES | NULL | DB/DDL/实体注释 |
| `single_price` | `int` | 时段金额 | 时段金额 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_pricing_by_time_timeout`

- 真实表：`pos_pricing_by_time_timeout`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：计时计价超时表
- 表含义：计时计价超时表
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `pricing_type` | `int` | 计价类型 | 计价类型 | YES | NULL | DB/DDL/实体注释 |
| `timeout_type` | `int` | 超时类型 | 超时类型 | YES | NULL | DB/DDL/实体注释 |
| `free_time_for_due_timeout` | `int` | 到点超时免收时间 | 到点超时免收时间 | YES | NULL | DB/DDL/实体注释 |
| `interval_free_time` | `int` | 区间免收时间 | 区间免收时间 | YES | NULL | DB/DDL/实体注释 |
| `interval_time_period` | `text` | 区间时间段 | 区间时间段 | YES | NULL | DB/DDL/实体注释 |
| `interval_hourly_price` | `decimal(10,0)` | 区间每小时价格 | 区间每小时价格 | YES | NULL | DB/DDL/实体注释 |
| `session_free_time` | `int` | 按场次免收时间 | 按场次免收时间 | YES | NULL | DB/DDL/实体注释 |
| `hourly_free_time` | `int` | 按小时免收时间 | 按小时免收时间 | YES | NULL | DB/DDL/实体注释 |
| `hourly_extra_charge_per_hour` | `decimal(10,0)` | 按小时每小时加收 | 按小时每小时加收 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_prn_job`

- 真实表：`pos_prn_job`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印任务
- 表含义：打印任务
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-pos\nms4cloud-pos-dal\src\main\java\com\nms4cloud\pos\dal\entity\PosPrnJob.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPrnJob.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `biz_bill_id` | `varchar(32)` | 业务单号 | 业务单号 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `purpose` | `int` | 用途 | 用途 | YES | NULL | DB/DDL/实体注释 |
| `prn_count` | `int` | 打印次数 | 打印次数 | YES | NULL | DB/DDL/实体注释 |
| `prn_queue_lid` | `bigint` | 打印队列编号 | 打印队列编号 | YES | NULL | DB/DDL/实体注释 |
| `prn_printer_lid` | `bigint` | 打印机编号 | 打印机编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 版本号 | 乐观锁或同步版本号。 | YES | NULL | 通用字段 |
| `created_by` | `varchar(128)` | 创建人 | 创建该记录的用户或系统标识。 | YES | NULL | 通用字段 |
| `created_time` | `datetime` | 创建时间 | 记录创建时间。 | YES | NULL | 通用字段 |
| `updated_by` | `varchar(128)` | 更新人 | 最后更新该记录的用户或系统标识。 | YES | NULL | 通用字段 |
| `updated_time` | `datetime` | 更新时间 | 记录最后更新时间。 | YES | NULL | 通用字段 |
| `deleted` | `int` | 逻辑删除标记 | 逻辑删除状态，通常 0 表示未删除、1 表示已删除。 | YES | NULL | 通用字段 |
| `print` | `tinyint(1)` | print | 业务业务中的print。 | YES | NULL | 推断 |
| `print_at` | `datetime` | printat | 业务业务中的printat。 | YES | NULL | 推断 |
| `name` | `varchar(128)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `prn_dept_name` | `varchar(128)` | 打印部门name | 业务业务对象的打印部门name。 | YES | NULL | 推断 |
| `bill_id` | `varchar` | 账单ID | 业务业务关联的账单ID。 |  |  | 推断 |
| `printer` | `bigint` | 打印机 | 业务业务中的打印机。 |  |  | 推断 |
| `extra_info` | `varchar` | extrainfo | 业务业务中的extrainfo。 |  |  | 推断 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `content` | `varchar` | 内容 | 业务业务中的内容。 |  |  | 推断 |
| `finish_time` | `datetime` | finish时间 | 业务业务中的finish时间。 |  |  | 推断 |

#### `pos_prn_printer`

- 真实表：`pos_prn_printer`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印机
- 表含义：打印机
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPrnPrinter.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `pc_lid` | `bigint` | 所属计算机 | 所属计算机 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `model` | `int` | 型号 | 型号 | YES | NULL | DB/DDL/实体注释 |
| `extra_info` | `text` | 附加信息 | 附加信息 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_prn_queue`

- 真实表：`pos_prn_queue`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印队列
- 表含义：打印队列
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPrnQueue.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `pc_lid` | `bigint` | 所属计算机 | 所属计算机 | YES | NULL | DB/DDL/实体注释 |
| `primary_printer` | `text` | 主打印机 | 主打印机 | YES | NULL | DB/DDL/实体注释 |
| `standby_printer` | `text` | 备用打印机 | 备用打印机 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_prn_style`

- 真实表：`pos_prn_style`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印单据样式
- 表含义：打印单据样式
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-pos\nms4cloud-pos-dal\src\main\java\com\nms4cloud\pos\dal\entity\PosPrnStyle.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `varchar(32)` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `extra_info` | `text` | 附加信息 | 附加信息 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pos_prn_style_col`

- 真实表：`pos_prn_style_col`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印样式列
- 表含义：打印样式列
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPrnStyleCol.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `style_type` | `int` | 单据类型 | 单据类型 | YES | NULL | DB/DDL/实体注释 |
| `row_lid` | `bigint` | 行编号 | 行编号 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `ds_id` | `varchar(90)` | 数据源编号 | 数据源编号 | YES | NULL | DB/DDL/实体注释 |
| `ds_field_id` | `varchar(90)` | 数据源字段编号 | 数据源字段编号 | YES | NULL | DB/DDL/实体注释 |
| `customized_content` | `text` | 自定义内容 | 自定义内容 | YES | NULL | DB/DDL/实体注释 |
| `customized_content_suffix` | `text` | 自定义内容 | 自定义内容(后) | YES | NULL | DB/DDL/实体注释 |
| `width80` | `int` | 宽度 | 宽度(80毫米热敏纸) | YES | NULL | DB/DDL/实体注释 |
| `width76` | `int` | 宽度 | 宽度(76毫米针式打印机) | YES | NULL | DB/DDL/实体注释 |
| `width58` | `int` | 宽度 | 宽度(58毫米热敏纸) | YES | NULL | DB/DDL/实体注释 |
| `align` | `int` | 对齐方式 | 对齐方式 | YES | NULL | DB/DDL/实体注释 |
| `font_size` | `int` | 字体 | 字体 | YES | NULL | DB/DDL/实体注释 |
| `bold` | `tinyint(1)` | 加粗 | 加粗 | YES | NULL | DB/DDL/实体注释 |
| `show_index` | `int` | 显示顺序 | 显示顺序 | YES | NULL | DB/DDL/实体注释 |
| `insert_separator_line` | `int` | 插入分割线数 | 插入分割线数 | YES | NULL | DB/DDL/实体注释 |
| `insert_blank_line` | `int` | 插入空行数 | 插入空行数 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `font_type` | `int` | 字体类型 | 字体类型 | YES | NULL | DB/DDL/实体注释 |
| `font_color` | `int` | 字体颜色 | 字体颜色 | YES | NULL | DB/DDL/实体注释 |
| `condition_ds_id` | `varchar(90)` | 显示条件的数据源编号 | 显示条件的数据源编号 | YES | NULL | DB/DDL/实体注释 |
| `condition_operator` | `int` | 显示条件的操作符 | 显示条件的操作符 | YES | NULL | DB/DDL/实体注释 |
| `condition_value` | `varchar(255)` | 显示条件的右值 | 显示条件的右值 | YES | NULL | DB/DDL/实体注释 |
| `color` | `varchar(90)` | 颜色 | 颜色 | YES | NULL | DB/DDL/实体注释 |
| `bg` | `varchar(90)` | 背景颜色 | 背景颜色 | YES | NULL | DB/DDL/实体注释 |
| `summarize` | `tinyint(1)` | 需要打印汇总 | 需要打印汇总 | YES | NULL | DB/DDL/实体注释 |
| `line_spacing` | `int` | 行间距 | 行间距 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pos_prn_style_item`

- 真实表：`pos_prn_style_item`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印单据样式内容
- 表含义：打印单据样式内容
- 字段来源：`216-new + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-pos\nms4cloud-pos-dal\src\main\java\com\nms4cloud\pos\dal\entity\PosPrnStyleItem.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `style` | `bigint` | 样式 | 样式 | YES | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 顺序 | 顺序 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `varchar(32)` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `condition_` | `varchar(255)` | 打印条件 | 打印条件 | YES | NULL | DB/DDL/实体注释 |
| `content` | `varchar(255)` | 打印内容 | 打印内容 | YES | NULL | DB/DDL/实体注释 |
| `align` | `varchar(32)` | 对齐方式 | 对齐方式 | YES | NULL | DB/DDL/实体注释 |
| `width` | `varchar(32)` | 宽度设置 | 宽度设置 | YES | NULL | DB/DDL/实体注释 |
| `bold` | `tinyint(1)` | 加粗 | 加粗 | YES | NULL | DB/DDL/实体注释 |
| `w_size` | `int` | 字体宽度 | 字体宽度 | YES | NULL | DB/DDL/实体注释 |
| `h_size` | `int` | 字体高度 | 字体高度 | YES | NULL | DB/DDL/实体注释 |
| `reverse` | `tinyint(1)` | 反显 | 反显 | YES | NULL | DB/DDL/实体注释 |
| `underline` | `tinyint(1)` | 下划线 | 下划线 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |
| `condition` | `varchar` | condition | 业务业务中的condition。 |  |  | 推断 |

#### `pos_prn_style_row`

- 真实表：`pos_prn_style_row`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印样式行
- 表含义：打印样式行
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPrnStyleRow.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `ds_id` | `varchar(90)` | 数据源编号 | 数据源编号 | YES | NULL | DB/DDL/实体注释 |
| `style_type` | `int` | 单据类型 | 单据类型 | YES | NULL | DB/DDL/实体注释 |
| `show_index` | `int` | 显示顺序 | 显示顺序 | YES | NULL | DB/DDL/实体注释 |
| `display_condition` | `text` | 显示条件 | 显示条件 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `condition_ds_id` | `varchar(90)` | 显示条件的数据源编号 | 显示条件的数据源编号 | YES | NULL | DB/DDL/实体注释 |
| `condition_operator` | `int` | 显示条件的操作符 | 显示条件的操作符 | YES | NULL | DB/DDL/实体注释 |
| `condition_value` | `varchar(255)` | 显示条件的右值 | 显示条件的右值 | YES | NULL | DB/DDL/实体注释 |
| `summarize` | `tinyint(1)` | 需要打印汇总 | 需要打印汇总 | YES | NULL | DB/DDL/实体注释 |
| `summarize_col_name` | `varchar(90)` | 汇总列的名字 | 汇总列的名字 | YES | NULL | DB/DDL/实体注释 |

#### `pos_promote_rule`

- 真实表：`pos_promote_rule`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：促销方案
- 表含义：促销方案
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosPromoteRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `sids` | `text` | 适用门店 | 适用门店 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 促销名称 | 促销名称 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 是否启用 | 是否启用 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 折扣类型 | 折扣类型 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `monday` | `tinyint(1)` | 星期一 | 星期一 | YES | NULL | DB/DDL/实体注释 |
| `tuesday` | `tinyint(1)` | 星期二 | 星期二 | YES | NULL | DB/DDL/实体注释 |
| `wednesday` | `tinyint(1)` | 星期三 | 星期三 | YES | NULL | DB/DDL/实体注释 |
| `thursday` | `tinyint(1)` | 星期四 | 星期四 | YES | NULL | DB/DDL/实体注释 |
| `friday` | `tinyint(1)` | 星期五 | 星期五 | YES | NULL | DB/DDL/实体注释 |
| `saturday` | `tinyint(1)` | 星期六 | 星期六 | YES | NULL | DB/DDL/实体注释 |
| `sunday` | `tinyint(1)` | 星期日 | 星期日 | YES | NULL | DB/DDL/实体注释 |
| `everyone` | `tinyint(1)` | 所有顾客可参与 | 所有顾客可参与 | YES | NULL | DB/DDL/实体注释 |
| `only_member` | `tinyint(1)` | 仅会员可参与 | 仅会员可参与 | YES | NULL | DB/DDL/实体注释 |
| `only_part_type` | `tinyint(1)` | 指定会员可参与 | 指定会员可参与 | YES | NULL | DB/DDL/实体注释 |
| `part_types` | `text` | 会员类型列表 | 会员类型列表 | YES | NULL | DB/DDL/实体注释 |
| `promote_foods` | `text` | 促销菜品 | 促销菜品 | YES | NULL | DB/DDL/实体注释 |
| `same_day_limit` | `varchar(255)` | 当日限次 | 当日限次 | YES | NULL | DB/DDL/实体注释 |
| `rule_extend` | `text` | 规则扩展 | 规则扩展 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `review` | `tinyint(1)` | 审核 | 审核 | YES | NULL | DB/DDL/实体注释 |
| `review_at` | `varchar(255)` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `review_by` | `varchar(255)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pos_reason_type`

- 真实表：`pos_reason_type`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：退赠起菜原因
- 表含义：退赠起菜原因
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosReasonType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `reason_type` | `int` | 原因类型 | 原因类型 | YES | NULL | DB/DDL/实体注释 |
| `reason_name` | `varchar(90)` | 原因名称 | 原因名称 | YES | NULL | DB/DDL/实体注释 |
| `print_status` | `tinyint(1)` | 打印状态 | 打印状态 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pos_waiter_bill_setting`

- 真实表：`pos_waiter_bill_setting`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：传菜联设置
- 表含义：传菜联设置
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PosWaiterBillSetting.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `prn_dept` | `text` | 出品部门 | 出品部门 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area` | `text` | 桌台区域 | 桌台区域 | YES | NULL | DB/DDL/实体注释 |
| `prn_queue` | `text` | 打印队列 | 打印队列 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |

#### `print_job_type_switch`

- 真实表：`print_job_type_switch`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：打印任务开关
- 表含义：打印任务开关
- 字段来源：`216-new + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PrintJobTypeSwitch.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 打印任务类型 | 打印任务类型 | YES | NULL | DB/DDL/实体注释 |
| `disabled_kitchen` | `tinyint(1)` | 不打印档口联 | 不打印档口联 | YES | NULL | DB/DDL/实体注释 |
| `disabled_waiter` | `tinyint(1)` | 不打印传菜联 | 不打印传菜联 | YES | NULL | DB/DDL/实体注释 |
| `disabled_customer` | `tinyint(1)` | 不打印顾客联 | 不打印顾客联 | YES | NULL | DB/DDL/实体注释 |
| `num_of_kitchen` | `int` | 档口联打印份数 | 档口联打印份数 | YES | NULL | DB/DDL/实体注释 |
| `num_of_waiter` | `int` | 传菜联打印份数 | 传菜联打印份数 | YES | NULL | DB/DDL/实体注释 |
| `num_of_customer` | `int` | 顾客联打印份数 | 顾客联打印份数 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_area_period`

- 真实表：`pt_area_period`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：区域销售时段
- 表含义：区域销售时段
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtAreaPeriod.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `begin_time` | `datetime` | 开始时间 | 开始时间 | NO | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间 | 结束时间 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_auto_order`

- 真实表：`sc_mall_auto_order`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 菜品或商品业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `tbl_type_code` | `varchar(255)` | 桌台类型code | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `tbl_type_name` | `varchar(255)` | 桌台类型name | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `dish_num` | `decimal(19,10)` | 菜品数量 | 菜品或商品业务中的菜品数量。 | YES | NULL | 推断 |
| `dish_name` | `varchar(255)` | 菜品name | 菜品或商品业务对象的菜品name。 | YES | NULL | 推断 |
| `dish_code` | `varchar(255)` | 菜品code | 菜品或商品业务对象的菜品code。 | YES | NULL | 推断 |
| `dish_unit` | `varchar(255)` | 菜品单位 | 菜品或商品业务中的菜品单位。 | YES | NULL | 推断 |
| `start_time` | `varchar(255)` | 开始时间 | 菜品或商品业务中的开始时间。 | YES | NULL | 推断 |
| `end_time` | `varchar(255)` | 结束时间 | 菜品或商品业务中的结束时间。 | YES | NULL | 推断 |
| `By_quantity` | `tinyint` | 人quantity | 菜品或商品业务中的人quantity。 | YES | NULL | 推断 |
| `By_person` | `tinyint` | 人person | 菜品或商品业务中的人person。 | YES | NULL | 推断 |
| `auto_order_type` | `int` | 自动点菜类型 | 自动点菜类型 | YES | 1 | DB/DDL/实体注释 |

### a_product

#### `pt_card_type_free_rule`

- 真实表：`pt_card_type_free_rule`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：会员免赠规则
- 表含义：会员免赠规则
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtCardTypeFreeRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 规则名称 | 规则名称 | YES | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员编号 | 会员编号 | YES | NULL | DB/DDL/实体注释 |
| `free_content` | `varchar(2000)` | 免赠次数内容 | 免赠次数内容 | YES | NULL | DB/DDL/实体注释 |
| `start_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pt_cook_ref`

- 真实表：`pt_cook_ref`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：做法分类下的做法
- 表含义：做法分类下的做法
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtCookRef.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtCookRef.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `cook_type_lid` | `bigint` | 做法分类lid | 做法分类lid | NO | NULL | DB/DDL/实体注释 |
| `cook_lid` | `bigint` | 做法lid | 做法lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `import_from` | `bigint` | 源id | 源id | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 做法关联类型 | 做法关联类型 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pt_cook_type`

- 真实表：`pt_cook_type`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：做法分类
- 表含义：做法分类
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtCookType.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtCookType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 做法编号 | 做法编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 做法名称 | 做法名称 | NO | NULL | DB/DDL/实体注释 |
| `order_idx` | `int` | 排序号 | 排序号 | NO | NULL | DB/DDL/实体注释 |
| `min_practice` | `int` | 最小做法 | 最小做法 | NO | NULL | DB/DDL/实体注释 |
| `max_practice` | `int` | 最大做法 | 最大做法 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `import_from` | `bigint` | 源id | 源id | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_cookway`

- 真实表：`caipingzuofa`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `caipingzuofaid` | `varchar(64)` | caipingzuofaid | 菜品或商品业务中的caipingzuofaid。 | YES | NULL | 推断 |
| `caipingzuofaname` | `varchar(255)` | caipingzuofaname | 菜品或商品业务对象的caipingzuofaname。 | YES | NULL | 推断 |
| `leibie` | `bigint` | leibie | 菜品或商品业务中的leibie。 | YES | NULL | 推断 |
| `caidalei` | `bigint` | caidalei | 菜品或商品业务中的caidalei。 | YES | NULL | 推断 |
| `cailei` | `bigint` | cailei | 菜品或商品业务中的cailei。 | YES | NULL | 推断 |
| `caip` | `bigint` | caip | 菜品或商品业务中的caip。 | YES | NULL | 推断 |
| `pingying` | `varchar(255)` | pingying | 菜品或商品业务中的pingying。 | YES | NULL | 推断 |
| `jiage` | `decimal(19,10)` | jiage | 菜品或商品业务中的jiage。 | YES | NULL | 推断 |
| `chengbenjiage` | `decimal(19,10)` | chengbenjiage | 菜品或商品业务中的chengbenjiage。 | YES | NULL | 推断 |
| `shifuochenyushuliang` | `tinyint` | shifuochenyushuliang | 菜品或商品业务中的shifuochenyushuliang。 | YES | NULL | 推断 |
| `mulselfamount` | `tinyint` | mulselfamount | 菜品或商品业务中的mulselfamount。 | YES | NULL | 推断 |
| `bumen` | `bigint` | bumen | 菜品或商品业务中的bumen。 | YES | NULL | 推断 |
| `chupingbumen` | `bigint` | chupingbumen | 菜品或商品业务中的chupingbumen。 | YES | NULL | 推断 |
| `canyidazhe` | `tinyint` | canyidazhe | 菜品或商品业务中的canyidazhe。 | YES | NULL | 推断 |
| `shouqifuwuwei` | `tinyint` | shouqifuwuwei | 菜品或商品业务中的shouqifuwuwei。 | YES | NULL | 推断 |
| `beidiancishu` | `int` | beidiancishu | 菜品或商品业务中的beidiancishu。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 菜品或商品业务中的单位。 | YES | NULL | 推断 |
| `bihua` | `varchar(255)` | bihua | 菜品或商品业务中的bihua。 | YES | NULL | 推断 |
| `caipingzuofaname2` | `varchar(255)` | caipingzuofaname2 | 菜品或商品业务对象的caipingzuofaname2。 | YES | NULL | 推断 |
| `caipingzuofaname3` | `varchar(255)` | caipingzuofaname3 | 菜品或商品业务对象的caipingzuofaname3。 | YES | NULL | 推断 |
| `isbendi` | `tinyint` | isbendi | 菜品或商品业务中的isbendi。 | YES | NULL | 推断 |
| `uploadtowx` | `tinyint` | uploadtowx | 菜品或商品业务中的uploadtowx。 | YES | NULL | 推断 |
| `notsynctodev` | `tinyint` | notsynctodev | 菜品或商品业务对象的notsynctodev。 | YES | NULL | 推断 |
| `showorder` | `int` | showorder | 菜品或商品业务中的showorder。 | YES | NULL | 推断 |
| `Hide_in_mall` | `tinyint` | 微餐厅隐藏 | 微餐厅隐藏 | YES | NULL | DB/DDL/实体注释 |
| `buweip` | `bigint` | 部位lid | 部位lid | YES | NULL | DB/DDL/实体注释 |
| `order_default` | `tinyint` | 点单时默认做法 | 点单时默认做法 | YES | NULL | DB/DDL/实体注释 |

#### `pt_cookway_type`

- 真实表：`zuofaleibie`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `bukeduoxuan` | `tinyint` | bukeduoxuan | 菜品或商品业务中的bukeduoxuan。 | YES | NULL | 推断 |
| `isbendi` | `tinyint` | isbendi | 菜品或商品业务中的isbendi。 | YES | NULL | 推断 |
| `showinyaoqiu` | `tinyint` | showinyaoqiu | 菜品或商品业务中的showinyaoqiu。 | YES | NULL | 推断 |
| `ZuoFa` | `bigint` | zuofa | 菜品或商品业务中的zuofa。 | YES | NULL | 推断 |
| `CaiAndZuoFaLeiBie` | `bigint` | caiandzuofaleibie | 菜品或商品业务中的caiandzuofaleibie。 | YES | NULL | 推断 |
| `dish_lids` | `text` | 菜品lids | 菜品lids | YES | NULL | DB/DDL/实体注释 |
| `small_type_lids` | `text` | 菜品小类lids | 菜品小类lids | YES | NULL | DB/DDL/实体注释 |
| `super_type_lids` | `text` | 菜品大类lids | 菜品大类lids | YES | NULL | DB/DDL/实体注释 |
| `min_cook_number` | `int` | 必须做法数量 | 必须做法数量 | YES | NULL | DB/DDL/实体注释 |
| `max_cook_number` | `int` | 最多可选做法数量 | 最多可选做法数量 | YES | NULL | DB/DDL/实体注释 |
| `fixed_cook` | `tinyint` | 做法不随菜谱变更 | 做法不随菜谱变更 | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_data_sync_record`

- 真实表：`pt_data_sync_record`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：数据同步记录
- 表含义：数据同步记录
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtDataSyncRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `src_sid` | `bigint` | 源门店 | 源门店 | YES | NULL | DB/DDL/实体注释 |
| `src_store_name` | `varchar(90)` | 原门店名称 | 原门店名称 | YES | NULL | DB/DDL/实体注释 |
| `dest_sid` | `bigint` | 目标门店 | 目标门店 | YES | NULL | DB/DDL/实体注释 |
| `dest_store_name` | `varchar(90)` | 目标门店名称 | 目标门店名称 | YES | NULL | DB/DDL/实体注释 |
| `back_up_sid` | `bigint` | 备份门店 | 备份门店 | YES | NULL | DB/DDL/实体注释 |
| `status` | `int` | 状态 | 状态 | YES | NULL | DB/DDL/实体注释 |
| `error_msg` | `varchar(255)` | 错误信息 | 错误信息 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 完成时间 | 完成时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_dish`

- 真实表：`sc_dish`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品
- 表含义：菜品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `brand` | `varchar(255)` | brand | 菜品业务中的brand。 | YES | NULL | 推断 |
| `brand_code` | `varchar(255)` | brandcode | 菜品业务对象的brandcode。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 菜品业务中的disable。 | YES | NULL | 推断 |
| `dish_type` | `varchar(255)` | 菜品类型 | 菜品业务分类或类型。 | YES | NULL | 推断 |
| `dish_type_code` | `bigint` | 分类lid | 分类lid | YES | NULL | DB/DDL/实体注释 |
| `alias` | `varchar(255)` | alias | 菜品业务中的alias。 | YES | NULL | 推断 |
| `hot_code` | `varchar(255)` | hotcode | 菜品业务对象的hotcode。 | YES | NULL | 推断 |
| `mode` | `varchar(255)` | mode | 菜品业务中的mode。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 菜品业务中的department。 | YES | NULL | 推断 |
| `department_code` | `varchar(255)` | departmentcode | 菜品业务对象的departmentcode。 | YES | NULL | 推断 |
| `show_in_pad` | `tinyint` | showinpad | 菜品业务中的showinpad。 | YES | NULL | 推断 |
| `image` | `varchar(255)` | image | 菜品业务中的image。 | YES | NULL | 推断 |
| `image_2d` | `varchar(255)` | image2d | 菜品业务中的image2d。 | YES | NULL | 推断 |
| `image_3d` | `varchar(255)` | image3d | 菜品业务中的image3d。 | YES | NULL | 推断 |
| `income` | `varchar(255)` | income | 菜品业务中的income。 | YES | NULL | 推断 |
| `income_code` | `varchar(255)` | incomecode | 菜品业务对象的incomecode。 | YES | NULL | 推断 |
| `signboard` | `tinyint` | signboard | 菜品业务中的signboard。 | YES | NULL | 推断 |
| `newed` | `tinyint` | newed | 菜品业务中的newed。 | YES | NULL | 推断 |
| `recommend` | `tinyint` | recommend | 菜品业务中的recommend。 | YES | NULL | 推断 |
| `can_be_decimal` | `decimal(19,10)` | canbedecimal | 菜品业务中的canbedecimal。 | YES | NULL | 推断 |
| `support_mode` | `varchar(255)` | supportmode | 菜品业务中的supportmode。 | YES | NULL | 推断 |
| `min_amount_for_sale` | `decimal(19,10)` | min金额forsale | 菜品业务中的min金额forsale。 | YES | NULL | 推断 |
| `packing_fee` | `decimal(19,10)` | packingfee | 菜品业务中的packingfee。 | YES | NULL | 推断 |
| `need_confirm_amount` | `tinyint` | needconfirm金额 | 菜品业务中的needconfirm金额。 | YES | NULL | 推断 |
| `auto_order` | `tinyint` | auto订单 | 菜品业务中的auto订单。 | YES | NULL | 推断 |
| `can_sale_alone` | `tinyint` | cansalealone | 菜品业务中的cansalealone。 | YES | NULL | 推断 |
| `tax_rate` | `decimal(19,10)` | tax比例 | 菜品业务中的tax比例。 | YES | NULL | 推断 |
| `sales_commission` | `decimal(19,10)` | salescommission | 菜品业务中的salescommission。 | YES | NULL | 推断 |
| `order_tips` | `varchar(255)` | 订单tips | 菜品业务中的订单tips。 | YES | NULL | 推断 |
| `markdown_desc` | `text` | 简介 | 简介 | YES | NULL | DB/DDL/实体注释 |
| `item_number` | `varchar(255)` | item数量 | 菜品业务中的item数量。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 菜品业务中的单位。 | YES | NULL | 推断 |
| `scale_enabled` | `tinyint(1)` | 是否称重销售 | 是否称重销售 | NO | 0 | DB/DDL/实体注释 |
| `scale_plu_code` | `varchar(32)` | 条码秤PLU编码 | 条码秤PLU编码 | YES | NULL | DB/DDL/实体注释 |
| `scale_name` | `varchar(64)` | 秤端商品名称 | 秤端商品名称 | YES | NULL | DB/DDL/实体注释 |
| `scale_sale_mode` | `varchar(16)` | 称重计价方式 | 称重计价方式：WEIGHT重量，COUNT数量 | YES | NULL | DB/DDL/实体注释 |
| `scale_unit` | `varchar(16)` | 称重计价单位 | 称重计价单位 | YES | NULL | DB/DDL/实体注释 |
| `scale_shelf_life_days` | `int` | 保质期天数 | 保质期天数 | YES | NULL | DB/DDL/实体注释 |
| `scale_package_date_mode` | `varchar(16)` | 包装日期规则 | 包装日期规则：PRINT_TIME打印时间，SALE_DAY销售日期 | YES | NULL | DB/DDL/实体注释 |
| `scale_sync_enabled` | `tinyint(1)` | 是否下发条码秤 | 是否下发条码秤 | NO | 0 | DB/DDL/实体注释 |
| `abbreviation` | `varchar(255)` | abbreviation | 菜品业务中的abbreviation。 | YES | NULL | 推断 |
| `can_modify_price` | `tinyint` | canmodify价格 | 菜品业务中的canmodify价格。 | YES | NULL | 推断 |
| `can_discount` | `tinyint` | can折扣 | 菜品业务中的can折扣。 | YES | NULL | 推断 |
| `can_give` | `tinyint` | can赠送 | 菜品业务中的can赠送。 | YES | NULL | 推断 |
| `stock` | `decimal(19,10)` | stock | 菜品业务中的stock。 | YES | NULL | 推断 |
| `can_manage_lib` | `tinyint` | canmanagelib | 菜品业务中的canmanagelib。 | YES | NULL | 推断 |
| `origin_place` | `varchar(255)` | 原始place | 菜品业务中的原始place。 | YES | NULL | 推断 |
| `can_promotion` | `tinyint` | canpromotion | 菜品业务中的canpromotion。 | YES | NULL | 推断 |
| `joint_franchise_rate` | `decimal(19,10)` | jointfranchise比例 | 菜品业务中的jointfranchise比例。 | YES | NULL | 推断 |
| `term_of_validity` | `int` | termof有效期 | 菜品业务中的termof有效期。 | YES | NULL | 推断 |
| `valuation_method` | `varchar(255)` | valuationmethod | 菜品业务中的valuationmethod。 | YES | NULL | 推断 |
| `warning_days` | `int` | warningdays | 菜品业务中的warningdays。 | YES | NULL | 推断 |
| `can_integrate` | `tinyint` | canintegrate | 菜品业务中的canintegrate。 | YES | NULL | 推断 |
| `integral` | `int` | integral | 菜品业务中的integral。 | YES | NULL | 推断 |
| `rate_of_margin` | `decimal(19,10)` | 比例ofmargin | 菜品业务中的比例ofmargin。 | YES | NULL | 推断 |
| `royalty_method` | `varchar(255)` | royaltymethod | 菜品业务中的royaltymethod。 | YES | NULL | 推断 |
| `royalty_count` | `decimal(19,10)` | royalty次数 | 菜品业务中的royalty次数。 | YES | NULL | 推断 |
| `dish_status` | `varchar(255)` | 菜品状态 | 菜品处理状态或启停状态。 | YES | NULL | 推断 |
| `is_nissin` | `tinyint` | isnissin | 标记菜品业务是否启用或满足isnissin条件。 | YES | NULL | 推断 |
| `is_fresh` | `tinyint` | isfresh | 标记菜品业务是否启用或满足isfresh条件。 | YES | NULL | 推断 |
| `is_manage_number` | `tinyint` | ismanage数量 | 标记菜品业务是否启用或满足ismanage数量条件。 | YES | NULL | 推断 |
| `input_tax` | `decimal(19,10)` | inputtax | 菜品业务中的inputtax。 | YES | NULL | 推断 |
| `inventory_ceiling` | `decimal(19,10)` | inventoryceiling | 菜品业务中的inventoryceiling。 | YES | NULL | 推断 |
| `inventory_lower` | `decimal(19,10)` | inventorylower | 菜品业务中的inventorylower。 | YES | NULL | 推断 |
| `produce_date` | `datetime` | produce日期 | 菜品业务中的produce日期。 | YES | NULL | 推断 |
| `output_tax` | `decimal(19,10)` | outputtax | 菜品业务中的outputtax。 | YES | NULL | 推断 |
| `set_more_code1` | `varchar(255)` | setmorecode1 | 菜品业务对象的setmorecode1。 | YES | NULL | 推断 |
| `set_more_code2` | `varchar(255)` | setmorecode2 | 菜品业务对象的setmorecode2。 | YES | NULL | 推断 |
| `set_more_code3` | `varchar(255)` | setmorecode3 | 菜品业务对象的setmorecode3。 | YES | NULL | 推断 |
| `set_more_code4` | `varchar(255)` | setmorecode4 | 菜品业务对象的setmorecode4。 | YES | NULL | 推断 |
| `set_more_code5` | `varchar(255)` | setmorecode5 | 菜品业务对象的setmorecode5。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | 菜品业务中的价格。 | YES | NULL | 推断 |
| `Factory_brand` | `varchar(255)` | factorybrand | 菜品业务中的factorybrand。 | YES | NULL | 推断 |
| `Factory_brand_code` | `varchar(255)` | factorybrandcode | 菜品业务对象的factorybrandcode。 | YES | NULL | 推断 |
| `Auxiliary_unit` | `varchar(255)` | auxiliary单位 | 菜品业务中的auxiliary单位。 | YES | NULL | 推断 |
| `Unit_conversion` | `decimal(19,10)` | 单位conversion | 菜品业务中的单位conversion。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 菜品业务中的pidtmp。 | YES | NULL | 推断 |
| `Standard` | `varchar(255)` | standard | 菜品业务中的standard。 | YES | NULL | 推断 |
| `Hide_in_dine` | `tinyint` | hideindine | 菜品业务中的hideindine。 | YES | NULL | 推断 |
| `Hide_in_takeaway` | `tinyint` | hideintakeaway | 菜品业务中的hideintakeaway。 | YES | NULL | 推断 |
| `Image_second` | `varchar(255)` | imagesecond | 菜品业务中的imagesecond。 | YES | NULL | 推断 |
| `Image_third` | `varchar(255)` | imagethird | 菜品业务中的imagethird。 | YES | NULL | 推断 |
| `Image_fourth` | `varchar(255)` | imagefourth | 菜品业务中的imagefourth。 | YES | NULL | 推断 |
| `Image_fifth` | `varchar(255)` | imagefifth | 菜品业务中的imagefifth。 | YES | NULL | 推断 |
| `Dish_video` | `varchar(255)` | 菜品video | 菜品业务中的菜品video。 | YES | NULL | 推断 |
| `No_sync_to_store` | `tinyint` | nosyncto门店 | 菜品业务对象的nosyncto门店。 | YES | NULL | 推断 |
| `Detail_image` | `varchar(1024)` | 明细image | 菜品业务中的明细image。 | YES | NULL | 推断 |
| `Shipping_addr` | `varchar(255)` | shippingaddr | 菜品业务中的shippingaddr。 | YES | NULL | 推断 |
| `Shipping_addr_code` | `varchar(255)` | shippingaddrcode | 菜品业务对象的shippingaddrcode。 | YES | NULL | 推断 |
| `Security_services` | `varchar(255)` | securityservices | 菜品业务中的securityservices。 | YES | NULL | 推断 |
| `Showorder` | `int` | showorder | 菜品业务中的showorder。 | YES | NULL | 推断 |
| `Limit_number` | `decimal(19,10)` | 限制数量 | 菜品业务中的限制数量。 | YES | NULL | 推断 |
| `Min_practice` | `int` | minpractice | 菜品业务中的minpractice。 | YES | NULL | 推断 |
| `Max_practice` | `int` | maxpractice | 菜品业务中的maxpractice。 | YES | NULL | 推断 |
| `Must_order_food` | `tinyint` | must订单菜品 | 菜品业务中的must订单菜品。 | YES | NULL | 推断 |
| `Must_Num_With_Same_People` | `tinyint` | must数量withsamepeople | 菜品业务中的must数量withsamepeople。 | YES | NULL | 推断 |
| `Recommend_food` | `tinyint` | recommend菜品 | 菜品业务中的recommend菜品。 | YES | NULL | 推断 |
| `Not_inherit_subclass` | `tinyint` | notinheritsubclass | 菜品业务对象的notinheritsubclass。 | YES | NULL | 推断 |
| `Not_inherit_supperclass` | `tinyint` | notinheritsupperclass | 菜品业务对象的notinheritsupperclass。 | YES | NULL | 推断 |
| `Not_multiple_choice` | `tinyint` | notmultiplechoice | 菜品业务对象的notmultiplechoice。 | YES | NULL | 推断 |
| `Not_inherit_common` | `tinyint` | notinheritcommon | 菜品业务对象的notinheritcommon。 | YES | NULL | 推断 |
| `Not_show_practice` | `tinyint` | notshowpractice | 菜品业务对象的notshowpractice。 | YES | NULL | 推断 |
| `Need_split_order` | `tinyint` | needsplit订单 | 菜品业务中的needsplit订单。 | YES | NULL | 推断 |
| `Can_mod_name` | `tinyint` | canmodname | 菜品业务对象的canmodname。 | YES | NULL | 推断 |
| `only_show` | `tinyint` | onlyshow | 菜品业务中的onlyshow。 | YES | NULL | 推断 |
| `qr_code` | `varchar(255)` | 点餐码 | 点餐码 | YES | NULL | DB/DDL/实体注释 |
| `by_quantity_order` | `varchar(255)` | 按数量出单 | 按数量出单 | YES | NULL | DB/DDL/实体注释 |
| `time_price` | `tinyint` | 时价菜 | 时价菜 | YES | NULL | DB/DDL/实体注释 |
| `order_in_mall` | `tinyint` | 微餐厅排序值 | 微餐厅排序值 | YES | NULL | DB/DDL/实体注释 |
| `online_type` | `varchar(64)` | 线上分类名称 | 线上分类名称 | YES | NULL | DB/DDL/实体注释 |
| `online_type_code` | `bigint` | 线上分类编号 | 线上分类编号 | YES | NULL | DB/DDL/实体注释 |
| `recommend_order_idx` | `int` | 推荐菜品顺序 | 推荐菜品顺序 | YES | NULL | DB/DDL/实体注释 |
| `share_commission` | `decimal(24,6)` | sharecommission | 菜品业务中的sharecommission。 | YES | NULL | 推断 |
| `had_cook` | `tinyint(1)` | hadcook | 菜品业务中的hadcook。 | YES | NULL | 推断 |
| `non_saleable_time` | `tinyint(1)` | nonsaleable时间 | 菜品业务中的nonsaleable时间。 | YES | NULL | 推断 |
| `enable_give_balance` | `tinyint(1)` | enable赠送余额 | 菜品业务中的enable赠送余额。 | YES | NULL | 推断 |
| `sale_commission` | `decimal(24,6)` | 销售提成 | 销售提成 | YES | NULL | DB/DDL/实体注释 |
| `assist_id` | `varchar(32)` | 辅助编码 | 辅助编码 | YES | NULL | DB/DDL/实体注释 |
| `hide_in_pickup` | `tinyint(1)` | 在自提中隐藏 | 在自提中隐藏 | NO | 0 | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 禁用/启用 | 禁用/启用 | NO | 1 | DB/DDL/实体注释 |
| `shelve` | `tinyint(1)` | 上下架 | 上下架 | NO | 1 | DB/DDL/实体注释 |
| `bar_code` | `varchar(90)` | 条码 | 条码 | YES | NULL | DB/DDL/实体注释 |
| `small_pictures` | `text` | 小图片列表 | 小图片列表 | YES | NULL | DB/DDL/实体注释 |
| `big_pictures` | `text` | 大图片列表 | 大图片列表 | YES | NULL | DB/DDL/实体注释 |
| `kilo_rate` | `decimal(24,6)` | 千克比率 | 千克比率 | NO | 0.000000 | DB/DDL/实体注释 |
| `dept_commission` | `decimal(24,6)` | 部门提成 | 部门提成 | NO | 0.000000 | DB/DDL/实体注释 |
| `market_commission` | `decimal(24,6)` | 营销提成 | 营销提成 | NO | 0.000000 | DB/DDL/实体注释 |
| `market_percentage` | `decimal(24,6)` | 营销提成百分比 | 营销提成百分比 | NO | 0.000000 | DB/DDL/实体注释 |
| `draw_commission` | `decimal(24,6)` | 现抽 | 现抽 | NO | 0.000000 | DB/DDL/实体注释 |
| `sales_percentage` | `decimal(24,6)` | 销售提成百分比 | 销售提成百分比 | NO | 0.000000 | DB/DDL/实体注释 |
| `side_up_rate` | `decimal(24,6)` | 配菜上限百分比 | 配菜上限百分比 | NO | 0.000000 | DB/DDL/实体注释 |
| `side_down_rate` | `decimal(24,6)` | 配菜下限百分比 | 配菜下限百分比 | NO | 0.000000 | DB/DDL/实体注释 |
| `gift_minute` | `decimal(24,6)` | 赠送计时 | 赠送计时（分） | NO | 0.000000 | DB/DDL/实体注释 |
| `lowest` | `tinyint(1)` | 参与最低消费 | 参与最低消费 | NO | 0 | DB/DDL/实体注释 |
| `no_billing` | `tinyint(1)` | 单位不参与计费 | 单位不参与计费 | NO | 0 | DB/DDL/实体注释 |
| `discount_all` | `tinyint(1)` | 参与所有折扣方式 | 参与所有折扣方式 | NO | 1 | DB/DDL/实体注释 |
| `deposited` | `tinyint(1)` | 作为押金退款 | 作为押金退款 | NO | 0 | DB/DDL/实体注释 |
| `performed` | `tinyint(1)` | 计算业绩 | 计算业绩 | NO | 1 | DB/DDL/实体注释 |
| `settle_coupon` | `tinyint(1)` | 使用优惠券结算 | 使用优惠券结算 | NO | 0 | DB/DDL/实体注释 |
| `ext_names` | `varchar(255)` | 美团、饿了么、抖音名称 | 美团、饿了么、抖音名称 | YES | NULL | DB/DDL/实体注释 |
| `specials` | `text` | 第X杯特价 | 第X杯特价 | YES | NULL | DB/DDL/实体注释 |
| `side` | `tinyint(1)` | 可作为配菜 | 可作为配菜 | NO | 0 | DB/DDL/实体注释 |
| `auto_out` | `tinyint(1)` | 自动出库 | 自动出库 | NO | 0 | DB/DDL/实体注释 |
| `primary_` | `tinyint(1)` | 任点主菜 | 任点主菜 | NO | 0 | DB/DDL/实体注释 |
| `by_other_sure` | `tinyint(1)` | 数量由其他确定 | 数量由其他确定 | NO | 0 | DB/DDL/实体注释 |
| `prohibit_qty` | `tinyint(1)` | 禁止修改数量 | 禁止修改数量 | NO | 0 | DB/DDL/实体注释 |
| `sold_stock` | `tinyint(1)` | 作为库存沽清 | 作为库存沽清 | NO | 0 | DB/DDL/实体注释 |
| `relate_people` | `tinyint(1)` | 跟人数有关 | 跟人数有关 | NO | 0 | DB/DDL/实体注释 |
| `order_merge` | `tinyint(1)` | 点单时合并 | 点单时合并 | NO | 0 | DB/DDL/实体注释 |
| `expiry_day` | `decimal(24,6)` | 保质期 | 保质期（天） | NO | 0.000000 | DB/DDL/实体注释 |
| `delay_minute` | `decimal(24,6)` | 延迟打印分钟数 | 延迟打印分钟数 | NO | 0.000000 | DB/DDL/实体注释 |
| `order_limit_number` | `decimal(24,6)` | 单内限点 | 单内限点 | NO | 0.000000 | DB/DDL/实体注释 |
| `warn_number` | `decimal(24,6)` | 预警数量 | 预警数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `spec` | `tinyint(1)` | 特价商品 | 特价商品 | NO | 0 | DB/DDL/实体注释 |
| `crown` | `tinyint(1)` | 销冠 | 销冠 | NO | 0 | DB/DDL/实体注释 |
| `hide_in_electric` | `tinyint(1)` | 在电子菜谱隐藏 | 在电子菜谱隐藏 | NO | 0 | DB/DDL/实体注释 |
| `hide_in_waiter` | `tinyint(1)` | 在服务员小程序隐藏 | 在服务员小程序隐藏 | NO | 0 | DB/DDL/实体注释 |
| `read_electric` | `tinyint(1)` | 从电子秤中读取 | 从电子秤中读取 | NO | 0 | DB/DDL/实体注释 |
| `pop_side` | `tinyint(1)` | 点菜时自动弹出配菜 | 点菜时自动弹出配菜 | NO | 0 | DB/DDL/实体注释 |
| `pop_unit` | `tinyint(1)` | 点菜弹出多单位选择框 | 点菜弹出多单位选择框 | NO | 0 | DB/DDL/实体注释 |
| `take_service_fee` | `tinyint(1)` | 需要收取服务费 | 需要收取服务费 | NO | 0 | DB/DDL/实体注释 |
| `pop_number` | `varchar(255)` | 点菜弹出数量确认框 | 点菜弹出数量确认框 | NO | 0 | DB/DDL/实体注释 |
| `pop_cook` | `varchar(255)` | 点菜时默认显示本类做法 | 点菜时默认显示本类做法 | NO | 0 | DB/DDL/实体注释 |
| `pinyin` | `varchar(64)` | 拼音 | 拼音 | YES | NULL | DB/DDL/实体注释 |
| `markdown_detail` | `text` | 菜品简介 | 菜品简介(富文本) | YES | NULL | DB/DDL/实体注释 |
| `min_cook_number` | `int` | 必须做法数量 | 必须做法数量 | YES | NULL | DB/DDL/实体注释 |
| `max_cook_number` | `int` | 最多可选做法数量 | 最多可选做法数量 | YES | NULL | DB/DDL/实体注释 |
| `upload` | `tinyint` | 是否上传 | 是否上传 | YES | NULL | DB/DDL/实体注释 |
| `floor_split_order` | `tinyint` | 楼面也出分单 | 楼面也出分单 | YES | NULL | DB/DDL/实体注释 |
| `hide_in_self_order` | `tinyint` | 在自助点餐中隐藏 | 在自助点餐中隐藏 | YES | 0 | DB/DDL/实体注释 |
| `fixed_cook` | `tinyint` | 做法不随菜谱变更 | 做法不随菜谱变更 | YES | NULL | DB/DDL/实体注释 |
| `dish_label` | `text` | 菜品标签 | 菜品标签 | YES | NULL | DB/DDL/实体注释 |
| `approval_lids` | `varchar(255)` | 审批逻辑编号列表 | 审批逻辑编号列表 | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_dish_area`

- 真实表：`pt_dish_area`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：菜品部位
- 表含义：菜品部位
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtDishArea.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtDishArea.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `dish_code` | `bigint` | 菜品编号 | 菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_type_code` | `bigint` | 小类编号 | 小类编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_supper_type_code` | `bigint` | 大类编号 | 大类编号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 部位名称 | 部位名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `import_from` | `bigint` | 源id | 源id | YES | NULL | DB/DDL/实体注释 |
| `not_inherit_common` | `tinyint` | 不继承通用做法 | 不继承通用做法：0-否，1-是 | YES | 0 | DB/DDL/实体注释 |
| `not_multiple_choice` | `tinyint` | 不可多选 | 不可多选：0-否，1-是 | YES | 0 | DB/DDL/实体注释 |
| `not_show_practice` | `tinyint` | 不自动弹出 | 不自动弹出：0-否，1-是 | YES | 0 | DB/DDL/实体注释 |
| `fixed_cook` | `tinyint` | 做法不随菜谱变更 | 做法不随菜谱变更：0-否，1-是 | YES | 0 | DB/DDL/实体注释 |

#### `pt_dish_flavor`

- 真实表：`pt_dish_flavor`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：菜品口味
- 表含义：菜品口味
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtDishFlavor.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtDishFlavor.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 口味名称 | 口味名称 | YES | NULL | DB/DDL/实体注释 |
| `flavor_type_code` | `bigint` | 类型编号 | 类型编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `import_from` | `bigint` | 源id | 源id | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_dish_map`

- 真实表：`sc_dish_map`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品
- 表含义：菜品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `main_dish` | `varchar(255)` | main菜品 | 菜品业务中的main菜品。 | YES | NULL | 推断 |
| `main_dish_code` | `bigint` | 主菜lid | 主菜lid | YES | NULL | DB/DDL/实体注释 |
| `sub_dish` | `varchar(255)` | sub菜品 | 菜品业务中的sub菜品。 | YES | NULL | 推断 |
| `sub_dish_code` | `bigint` | 子菜lid | 子菜lid | YES | NULL | DB/DDL/实体注释 |
| `sub_dish_number` | `decimal(19,10)` | sub菜品数量 | 菜品业务中的sub菜品数量。 | YES | NULL | 推断 |
| `sub_dish_scate` | `decimal(19,10)` | sub菜品scate | 菜品业务中的sub菜品scate。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 菜品业务中的pidtmp。 | YES | NULL | 推断 |
| `Unit` | `varchar(255)` | 单位 | 菜品业务中的单位。 | YES | NULL | 推断 |
| `Unit_code` | `varchar(255)` | 单位code | 菜品业务对象的单位code。 | YES | NULL | 推断 |
| `Amount` | `int` | 金额 | 菜品业务中的金额。 | YES | NULL | 推断 |
| `Max_amount` | `int` | max金额 | 菜品业务中的max金额。 | YES | NULL | 推断 |
| `Price` | `decimal(19,10)` | 价格 | 菜品业务中的价格。 | YES | NULL | 推断 |
| `Map_type` | `int` | map类型 | 菜品业务分类或类型。 | YES | NULL | 推断 |
| `Main_type` | `int` | main类型 | 菜品业务分类或类型。 | YES | NULL | 推断 |
| `idx` | `int` | 排序值 | 排序值 | YES | NULL | DB/DDL/实体注释 |

### a_pos

#### `pt_dish_price_special`

- 真实表：`pt_dish_price_special`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：菜品特殊价格
- 表含义：菜品特殊价格
- 字段来源：`119-old + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtDishPriceSpecial.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 价格类型 | 价格类型 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品编号 | 菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(32)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 菜品价格 | 菜品价格 | YES | NULL | DB/DDL/实体注释 |
| `out_type_no` | `bigint` | 关联编号 | 关联编号 | YES | NULL | DB/DDL/实体注释 |
| `festival` | `bigint` | 节日编号 | 节日编号 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar` | 名称 | 业务对象名称。 |  |  | 通用字段 |

### a_product

#### `pt_dish_table_price`

- 真实表：`pt_dish_table_price`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：菜品房台价格
- 表含义：菜品房台价格
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtDishTablePrice.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtDishTablePrice.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `table_type_code` | `bigint` | 桌台类型 | 桌台类型 | YES | NULL | DB/DDL/实体注释 |
| `dish_code` | `bigint` | 菜品编号 | 菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(255)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `dish_price` | `decimal(24,6)` | 菜品价格 | 菜品价格 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_dish_type`

- 真实表：`sc_dish_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品
- 表含义：菜品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `brand` | `varchar(255)` | brand | 菜品业务中的brand。 | YES | NULL | 推断 |
| `brand_code` | `varchar(255)` | brandcode | 菜品业务对象的brandcode。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 菜品业务中的department。 | YES | NULL | 推断 |
| `department_code` | `varchar(255)` | departmentcode | 菜品业务对象的departmentcode。 | YES | NULL | 推断 |
| `income` | `varchar(255)` | income | 菜品业务中的income。 | YES | NULL | 推断 |
| `income_code` | `varchar(255)` | incomecode | 菜品业务对象的incomecode。 | YES | NULL | 推断 |
| `superior` | `varchar(255)` | superior | 菜品业务中的superior。 | YES | NULL | 推断 |
| `superior_code` | `varchar(255)` | superiorcode | 菜品业务对象的superiorcode。 | YES | NULL | 推断 |
| `tax_rate` | `decimal(19,10)` | tax比例 | 菜品业务中的tax比例。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 菜品业务中的说明。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 菜品业务中的disable。 | YES | NULL | 推断 |
| `order_idx` | `int` | 订单idx | 菜品业务中的订单idx。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 菜品业务中的pidtmp。 | YES | NULL | 推断 |
| `Not_inherit_supperclass` | `tinyint` | notinheritsupperclass | 菜品业务对象的notinheritsupperclass。 | YES | NULL | 推断 |
| `Not_multiple_choice` | `tinyint` | notmultiplechoice | 菜品业务对象的notmultiplechoice。 | YES | NULL | 推断 |
| `Not_inherit_common` | `tinyint` | notinheritcommon | 菜品业务对象的notinheritcommon。 | YES | NULL | 推断 |
| `Not_show_practice` | `tinyint` | notshowpractice | 菜品业务对象的notshowpractice。 | YES | NULL | 推断 |
| `Hide_in_mall` | `tinyint` | 微餐厅隐藏 | 微餐厅隐藏 | YES | NULL | DB/DDL/实体注释 |
| `order_in_mall` | `tinyint` | 微餐厅排序值 | 微餐厅排序值 | YES | NULL | DB/DDL/实体注释 |
| `support_mode` | `int` | 分类模式 | 分类模式 | YES | NULL | DB/DDL/实体注释 |
| `alias` | `varchar(128)` | 别名 | 别名 | YES | NULL | DB/DDL/实体注释 |
| `upload` | `tinyint` | 是否上传 | 是否上传 | YES | NULL | DB/DDL/实体注释 |
| `images` | `text` | 图片 | 图片 | YES | NULL | DB/DDL/实体注释 |
| `fixed_cook` | `tinyint` | 做法不随菜谱变更 | 做法不随菜谱变更 | YES | NULL | DB/DDL/实体注释 |

#### `pt_dish_unit`

- 真实表：`sc_dish_unit`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品
- 表含义：菜品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `dish` | `varchar(255)` | 菜品 | 菜品业务中的菜品。 | YES | NULL | 推断 |
| `dish_code` | `bigint` | 菜品lid | 菜品lid | NO | NULL | DB/DDL/实体注释 |
| `common_price` | `decimal(19,10)` | common价格 | 菜品业务中的common价格。 | YES | NULL | 推断 |
| `crm_price` | `decimal(19,10)` | CRM价格 | 菜品业务中的CRM价格。 | YES | NULL | 推断 |
| `org_price` | `decimal(19,10)` | org价格 | 菜品业务中的org价格。 | YES | NULL | 推断 |
| `estimate_cost` | `decimal(19,10)` | estimatecost | 菜品业务中的estimatecost。 | YES | NULL | 推断 |
| `take_away_price` | `decimal(19,10)` | takeaway价格 | 菜品业务中的takeaway价格。 | YES | NULL | 推断 |
| `online_dine_price` | `decimal(19,10)` | onlinedine价格 | 菜品业务中的onlinedine价格。 | YES | NULL | 推断 |
| `online_take_away_price` | `decimal(19,10)` | onlinetakeaway价格 | 菜品业务中的onlinetakeaway价格。 | YES | NULL | 推断 |
| `online_mention_price` | `decimal(19,10)` | onlinemention价格 | 菜品业务中的onlinemention价格。 | YES | NULL | 推断 |
| `special_price1` | `decimal(19,10)` | specialprice1 | 菜品业务中的specialprice1。 | YES | NULL | 推断 |
| `special_price2` | `decimal(19,10)` | specialprice2 | 菜品业务中的specialprice2。 | YES | NULL | 推断 |
| `special_price3` | `decimal(19,10)` | specialprice3 | 菜品业务中的specialprice3。 | YES | NULL | 推断 |
| `special_price4` | `decimal(19,10)` | specialprice4 | 菜品业务中的specialprice4。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 菜品业务中的单位。 | YES | NULL | 推断 |
| `cost` | `decimal(19,10)` | cost | 菜品业务中的cost。 | YES | NULL | 推断 |
| `lowest_price` | `decimal(19,10)` | lowest价格 | 菜品业务中的lowest价格。 | YES | NULL | 推断 |
| `distribution_price` | `decimal(19,10)` | distribution价格 | 菜品业务中的distribution价格。 | YES | NULL | 推断 |
| `crm_price1` | `decimal(19,10)` | CRMprice1 | 菜品业务中的CRMprice1。 | YES | NULL | 推断 |
| `crm_price2` | `decimal(19,10)` | CRMprice2 | 菜品业务中的CRMprice2。 | YES | NULL | 推断 |
| `crm_price3` | `decimal(19,10)` | CRMprice3 | 菜品业务中的CRMprice3。 | YES | NULL | 推断 |
| `crm_price4` | `decimal(19,10)` | CRMprice4 | 菜品业务中的CRMprice4。 | YES | NULL | 推断 |
| `crm_price5` | `decimal(19,10)` | CRMprice5 | 菜品业务中的CRMprice5。 | YES | NULL | 推断 |
| `Rate_of_def` | `varchar(255)` | 比例ofdef | 菜品业务中的比例ofdef。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 菜品业务中的pidtmp。 | YES | NULL | 推断 |
| `Item_number` | `varchar(255)` | item数量 | 菜品业务中的item数量。 | YES | NULL | 推断 |
| `Exchange_points` | `int` | exchange积分 | 菜品业务中的exchange积分。 | YES | NULL | 推断 |
| `kilo_rate` | `decimal(24,6)` | 千克比率 | 千克比率 | YES | NULL | DB/DDL/实体注释 |
| `no_billing` | `tinyint(1)` | 单位不参与计费 | 单位不参与计费 | NO | 0 | DB/DDL/实体注释 |
| `can_integrate` | `tinyint(1)` | 参与积分 | 参与积分 | NO | 0 | DB/DDL/实体注释 |
| `market_commission` | `decimal(24,6)` | 营销提成 | 营销提成 | NO | 0.000000 | DB/DDL/实体注释 |
| `market_percentage` | `decimal(24,6)` | 营销提成百分比 | 营销提成百分比 | NO | 0.000000 | DB/DDL/实体注释 |
| `dept_commission` | `decimal(24,6)` | 部门提成 | 部门提成 | NO | 0.000000 | DB/DDL/实体注释 |
| `sales_commission` | `decimal(24,6)` | 销售提成 | 销售提成 | NO | 0.000000 | DB/DDL/实体注释 |
| `sales_percentage` | `decimal(24,6)` | 销售提成百分比 | 销售提成百分比 | NO | 0.000000 | DB/DDL/实体注释 |

### a_pos

#### `pt_festival`

- 真实表：`pt_festival`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：节日
- 表含义：节日
- 字段来源：`119-old + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtFestival.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开始时间 | 开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_time` | `datetime` | 结束时间 | 结束时间 | YES | NULL | DB/DDL/实体注释 |
| `state` | `bigint` | 启用状态 | 启用状态 | YES | NULL | DB/DDL/实体注释 |
| `day_of_the_week` | `varchar(255)` | 星期几 | 星期几 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_flavor_type`

- 真实表：`pt_flavor_type`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：口味类型
- 表含义：口味类型
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtFlavorType.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtFlavorType.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 类型名称 | 类型名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `import_from` | `bigint` | 源id | 源id | YES | NULL | DB/DDL/实体注释 |

#### `pt_free_rule_dish`

- 真实表：`pt_free_rule_dish`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：免赠规则关联菜品
- 表含义：免赠规则关联菜品
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtFreeRuleDish.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtFreeRuleDish.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `free_rule_lid` | `bigint` | 免赠规则lid | 免赠规则lid | YES | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品lid | 菜品lid | YES | NULL | DB/DDL/实体注释 |
| `dish_unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pt_member_price`

- 真实表：`pt_member_price`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：会员价格
- 表含义：会员价格
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtMemberPrice.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtMemberPrice.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品Lid | 菜品Lid | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(255)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 菜品价格 | 菜品价格 | YES | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员卡类型Lid | 会员卡类型Lid | YES | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(255)` | 会员卡类型名称 | 会员卡类型名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_qr_bind`

- 真实表：`sc_qr_bind`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `qrcodekey` | `varchar(255)` | qrcodekey | 菜品或商品业务对象的qrcodekey。 | YES | NULL | 推断 |
| `qrcodevalue` | `varchar(255)` | qrcodevalue | 菜品或商品业务对象的qrcodevalue。 | YES | NULL | 推断 |
| `crttime` | `datetime` | crttime | 菜品或商品业务中的crttime。 | YES | NULL | 推断 |
| `bindshopname` | `varchar(255)` | bindshopname | 菜品或商品业务对象的bindshopname。 | YES | NULL | 推断 |
| `bindzuotai` | `varchar(255)` | bindzuotai | 菜品或商品业务中的bindzuotai。 | YES | NULL | 推断 |
| `bindusertaiid` | `varchar(255)` | bindusertaiid | 菜品或商品业务中的bindusertaiid。 | YES | NULL | 推断 |
| `bindtime` | `datetime` | bindtime | 菜品或商品业务中的bindtime。 | YES | NULL | 推断 |
| `dantype` | `int` | dantype | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `remark` | `varchar(255)` | 备注 | 人工填写或系统保留的补充说明。 | YES | NULL | 通用字段 |
| `BusinessType` | `varchar(255)` | businesstype | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `AppType` | `varchar(255)` | apptype | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `XcxQrCodeUrl` | `varchar(255)` | xcxqrcodeurl | 菜品或商品业务对象的xcxqrcodeurl。 | YES | NULL | 推断 |
| `GzhQrCodeUrl` | `varchar(255)` | gzhqrcodeurl | 菜品或商品业务对象的gzhqrcodeurl。 | YES | NULL | 推断 |
| `sun_code_url` | `varchar(255)` | 小程序太阳码 | 小程序太阳码 | YES | NULL | DB/DDL/实体注释 |
| `h5_code_url` | `varchar(128)` | h5二维码 | h5二维码 | YES | NULL | DB/DDL/实体注释 |

#### `pt_qr_code`

- 真实表：`sc_qr_code`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `qrcodetype` | `varchar(255)` | qrcodetype | 菜品或商品业务分类或类型。 | YES | NULL | 推断 |
| `qrcodekey` | `varchar(255)` | qrcodekey | 菜品或商品业务对象的qrcodekey。 | YES | NULL | 推断 |
| `crttime` | `datetime` | crttime | 菜品或商品业务中的crttime。 | YES | NULL | 推断 |

### a_product

#### `pt_queue`

- 真实表：`pt_queue`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：排队队列
- 表含义：排队队列
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtQueue.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 队列编号 | 队列编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 队列名称 | 队列名称（取号首字母） | NO | NULL | DB/DDL/实体注释 |
| `min_people` | `int` | 最少可入座人数 | 最少可入座人数 | NO | 1 | DB/DDL/实体注释 |
| `max_people` | `int` | 最多可入座人数 | 最多可入座人数 | NO | 1 | DB/DDL/实体注释 |
| `time_cost` | `int` | 预估耗时 | 预估耗时 | NO | 0 | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 是否启用 | 是否启用 | NO | 1 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pt_queue_open`

- 真实表：`pt_queue_open`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：排队叫号openId
- 表含义：排队叫号openId
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtQueueOpen.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(32)` | 会员手机号 | 会员手机号 | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(32)` | openID | open_id | NO | NULL | DB/DDL/实体注释 |
| `app_id` | `varchar(32)` | appID | app_id | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `type` | `tinyint/varchar` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pt_queue_record`

- 真实表：`pt_queue_record`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：排队叫号记录
- 表含义：排队叫号记录
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtQueueRecord.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `queue_lid` | `bigint` | 队列lid | 队列lid | NO | NULL | DB/DDL/实体注释 |
| `queue_name` | `varchar(90)` | 队列名称 | 队列名称 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(32)` | 用户手机号 | 用户手机号 | YES | NULL | DB/DDL/实体注释 |
| `nick_name` | `varchar(90)` | 用户名称 | 用户名称 | YES | NULL | DB/DDL/实体注释 |
| `avatar` | `varchar(90)` | 用户头像 | 用户头像 | YES | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(32)` | 用户open_id | 用户open_id | YES | NULL | DB/DDL/实体注释 |
| `period` | `varchar(90)` | 时段名 | 时段名 | YES | NULL | DB/DDL/实体注释 |
| `call_by` | `varchar(90)` | 叫号人 | 叫号人 | YES | NULL | DB/DDL/实体注释 |
| `call_at` | `datetime` | 叫号时间 | 叫号时间 | YES | NULL | DB/DDL/实体注释 |
| `call_num` | `int` | 叫号次数 | 叫号次数 | YES | NULL | DB/DDL/实体注释 |
| `meal_by` | `varchar(90)` | 就餐人 | 就餐人 | YES | NULL | DB/DDL/实体注释 |
| `meal_at` | `datetime` | 就餐时间 | 就餐时间 | YES | NULL | DB/DDL/实体注释 |
| `over_by` | `varchar(90)` | 过号人 | 过号人 | YES | NULL | DB/DDL/实体注释 |
| `over_at` | `datetime` | 过号时间 | 过号时间 | YES | NULL | DB/DDL/实体注释 |
| `queue_id` | `varchar(32)` | 排队序列号 | 排队序列号 | NO | NULL | DB/DDL/实体注释 |
| `people` | `int` | 人数 | 人数 | NO | NULL | DB/DDL/实体注释 |
| `queue_state` | `int` | 队列状态 | 队列状态 | NO | 1 | DB/DDL/实体注释 |
| `queue_channel` | `int` | 领号渠道 | 领号渠道 | NO | 2 | DB/DDL/实体注释 |
| `wait_minute` | `int` | 等待分钟数 | 等待分钟数 | YES | NULL | DB/DDL/实体注释 |
| `qr_code` | `varchar(255)` | 二维码链接 | 二维码链接 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `reserve` | `tinyint(1)` | 保留号码 | 保留号码 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_tbl`

- 真实表：`sc_tbl`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：桌台
- 表含义：桌台相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `area` | `varchar(255)` | 区域 | 桌台业务中的区域。 | YES | NULL | 推断 |
| `type_` | `varchar(255)` | 类型 | 业务对象类型。 | YES | NULL | 通用字段 |
| `orderable` | `tinyint` | orderable | 桌台业务中的orderable。 | YES | NULL | 推断 |
| `hide` | `tinyint` | hide | 桌台业务中的hide。 | YES | NULL | 推断 |
| `qrcode` | `varchar(255)` | qrcode | 桌台业务对象的qrcode。 | YES | NULL | 推断 |
| `Area_code` | `bigint` | 区域code | 桌台业务对象的区域code。 | YES | NULL | 推断 |
| `Type_code` | `bigint` | 类型code | 桌台业务分类或类型。 | YES | NULL | 推断 |
| `Show_order` | `int` | show订单 | 桌台业务中的show订单。 | YES | NULL | 推断 |
| `h5_code_url` | `varchar(128)` | h5二维码 | h5二维码 | YES | NULL | DB/DDL/实体注释 |
| `min_dining_capacity` | `int` | 就餐最小人数 | 就餐最小人数 | YES | NULL | DB/DDL/实体注释 |
| `max_dining_capacity` | `int` | 就餐最大人数 | 就餐最大人数 | YES | NULL | DB/DDL/实体注释 |
| `near_window` | `tinyint(1)` | 是否靠窗 | 是否靠窗 | YES | NULL | DB/DDL/实体注释 |
| `deposit` | `decimal(24,6)` | 订金 | 订金 | YES | NULL | DB/DDL/实体注释 |
| `standard_table_num` | `int` | 标准摆台桌数 | 标准摆台桌数 | YES | NULL | DB/DDL/实体注释 |
| `staff` | `bigint` | 专属服务 | 专属服务 | YES | NULL | DB/DDL/实体注释 |
| `app` | `tinyint(1)` | 营销app | 营销app | YES | NULL | DB/DDL/实体注释 |
| `online` | `tinyint(1)` | 网络预订 | 网络预订 | YES | NULL | DB/DDL/实体注释 |
| `tbl_position` | `varchar(255)` | 桌位 | 桌位 | YES | NULL | DB/DDL/实体注释 |
| `facility` | `varchar(255)` | 房间设施 | 房间设施 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `text` | 餐位说明 | 餐位说明 | YES | NULL | DB/DDL/实体注释 |
| `tbl_photo` | `varchar(255)` | 桌台图片 | 桌台图片 | YES | NULL | DB/DDL/实体注释 |
| `slide_photo` | `varchar(255)` | 轮播图 | 轮播图 | YES | NULL | DB/DDL/实体注释 |
| `vr_photo` | `varchar(255)` | vr图 | vr图 | YES | NULL | DB/DDL/实体注释 |
| `capacity` | `int` | 容纳人数 | 容纳人数 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 建议标准 | 建议标准(元/桌) | YES | NULL | DB/DDL/实体注释 |
| `max_table_num` | `int` | 最大桌数 | 最大桌数 | YES | NULL | DB/DDL/实体注释 |
| `attribute_remark` | `text` | 桌台属性 | 桌台属性 | YES | NULL | DB/DDL/实体注释 |
| `tbl_photo_list` | `text` | 桌台图片列表 | 桌台图片列表 | YES | NULL | DB/DDL/实体注释 |

#### `pt_tbl_area`

- 真实表：`sc_tbl_area`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：桌台
- 表含义：桌台相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `order_idx` | `int` | 订单idx | 桌台业务中的订单idx。 | YES | NULL | 推断 |
| `Show_order` | `int` | show订单 | 桌台业务中的show订单。 | YES | NULL | 推断 |
| `floor_height` | `decimal(10,2)` | 层高 | 层高(m) | YES | NULL | DB/DDL/实体注释 |
| `tbl_photo` | `varchar(255)` | 桌台图片 | 桌台图片 | YES | NULL | DB/DDL/实体注释 |
| `max_table_num` | `int` | 最大桌数 | 最大桌数 | YES | NULL | DB/DDL/实体注释 |
| `area_size` | `decimal(10,2)` | 面积 | 面积(㎡) | YES | NULL | DB/DDL/实体注释 |
| `attribute_remark` | `text` | 台桌属性 | 台桌属性 | YES | NULL | DB/DDL/实体注释 |
| `area_desc` | `text` | 台区描述 | 台区描述 | YES | NULL | DB/DDL/实体注释 |
| `tbl_photo_list` | `text` | 桌台图片列表 | 桌台图片列表 | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_tbl_area_dish`

- 真实表：`pt_tbl_area_dish`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：区域菜品
- 表含义：区域菜品
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtTblAreaDish.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtTblAreaDish.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `tbl_area_lid` | `bigint` | 区域lid | 区域lid | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品lid | 菜品lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `pt_tbl_type`

- 真实表：`sc_tbl_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：桌台
- 表含义：桌台相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `service_rate` | `decimal(19,10)` | 服务比例 | 桌台业务中的服务比例。 | YES | NULL | 推断 |
| `minimum_consumption` | `decimal(19,10)` | minimum消费 | 桌台业务中的minimum消费。 | YES | NULL | 推断 |
| `allowepeople` | `int` | allowepeople | 桌台业务中的allowepeople。 | YES | NULL | 推断 |
| `Book_amount` | `decimal(19,10)` | book金额 | 桌台业务中的book金额。 | YES | NULL | 推断 |
| `Mon_minimum_consumption` | `decimal(19,10)` | monminimum消费 | 桌台业务中的monminimum消费。 | YES | NULL | 推断 |
| `Tues_minimum_consumption` | `decimal(19,10)` | tuesminimum消费 | 桌台业务中的tuesminimum消费。 | YES | NULL | 推断 |
| `Wed_minimum_consumption` | `decimal(19,10)` | wedminimum消费 | 桌台业务中的wedminimum消费。 | YES | NULL | 推断 |
| `Thur_minimum_consumption` | `decimal(19,10)` | thurminimum消费 | 桌台业务中的thurminimum消费。 | YES | NULL | 推断 |
| `Fri_minimum_consumption` | `decimal(19,10)` | friminimum消费 | 桌台业务中的friminimum消费。 | YES | NULL | 推断 |
| `Sat_minimum_consumption` | `decimal(19,10)` | satminimum消费 | 桌台业务中的satminimum消费。 | YES | NULL | 推断 |
| `Sun_minimum_consumption` | `decimal(19,10)` | sunminimum消费 | 桌台业务中的sunminimum消费。 | YES | NULL | 推断 |
| `Discount_code` | `varchar(255)` | 折扣code | 桌台业务对象的折扣code。 | YES | NULL | 推断 |
| `Discount_name` | `varchar(255)` | 折扣name | 桌台业务对象的折扣name。 | YES | NULL | 推断 |
| `tbl_mode` | `varchar(64)` | 收费模式 | 收费模式 | YES | NULL | DB/DDL/实体注释 |

### a_pos

#### `takeout_aggregation_platform_channel`

- 真实表：`takeout_aggregation_platform_channel`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：外卖聚合平台通道
- 表含义：外卖聚合平台通道
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\TakeoutAggregationPlatformChannel.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `channel_type` | `int` | 通道类型 | 通道类型 | YES | NULL | DB/DDL/实体注释 |
| `channel_merchant_no` | `varchar(90)` | 在通道中的商户号 | 在通道中的商户号 | YES | NULL | DB/DDL/实体注释 |
| `channel_store_code` | `varchar(90)` | 在通道中的门店号 | 在通道中的门店号 | YES | NULL | DB/DDL/实体注释 |
| `channel_info` | `text` | 通道信息 | 通道信息 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(90)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(90)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `terminal_id` | `varchar(90)` | terminalID | 业务业务关联的terminalID。 | YES | NULL | 推断 |
| `terminal_token` | `varchar(90)` | terminaltoken | 业务业务中的terminaltoken。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 业务业务中的disable。 | YES | NULL | 推断 |

#### `takeout_food_map`

- 真实表：`takeout_food_map`
- 数据源/库：`a_pos` / `pos` / `172.16.0.144:3306`
- 表中文名：外卖菜品映射表
- 表含义：外卖菜品映射表
- 字段来源：`216-new + Java:D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-dal\src\main\java\com\nms4cloud\pos4cloud\dal\entity\TakeoutFoodMap.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `food_id_in_channel` | `varchar(90)` | 渠道菜品编号 | 渠道菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `food_unit_in_channel` | `varchar(32)` | 渠道菜品单位 | 渠道菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `food_id_in_nms` | `varchar(128)` | 我们系统的菜品编号 | 我们系统的菜品编号 | YES | NULL | DB/DDL/实体注释 |
| `food_unit_in_nms` | `varchar(32)` | 我们系统的菜品单位 | 我们系统的菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `food_name` | `varchar(90)` | 菜品name | 业务业务对象的菜品name。 | YES | NULL | 推断 |
| `channel_type` | `int` | 渠道类型 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `food_code_in_nms` | `varchar(255)` | 菜品codeinnms | 业务业务对象的菜品codeinnms。 | YES | NULL | 推断 |
| `attr_name` | `varchar(32)` | attrname | 业务业务对象的attrname。 | YES | NULL | 推断 |
| `deleted` | `int` | 逻辑删除标记 | 逻辑删除状态，通常 0 表示未删除、1 表示已删除。 | YES | NULL | 通用字段 |
| `platform_spu_id` | `varchar` | 平台spuID | 业务业务关联的平台spuID。 |  |  | 推断 |
| `has_picture` | `tinyint(1)` | haspicture | 标记业务业务是否启用或满足haspicture条件。 |  |  | 推断 |
| `disable` | `tinyint(1)` | disable | 业务业务中的disable。 |  |  | 推断 |
| `spu` | `tinyint(1)` | spu | 业务业务中的spu。 |  |  | 推断 |

### gylregdb

#### `XiaoFeiCaiPing`

- 真实表：`XiaoFeiCaiPing`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\XiaoFeiCaiPingEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `xiaofeid` | `bigint` | xiaofeid | 业务业务中的xiaofeid。 | YES | NULL | 推断 |
| `diancaipici` | `bigint` | diancaipici | 业务业务中的diancaipici。 | YES | NULL | 推断 |
| `xiafeicaipingid` | `varchar(255)` | xiafeicaipingid | 业务业务中的xiafeicaipingid。 | YES | NULL | 推断 |
| `xiafeicaipingname` | `varchar(255)` | xiafeicaipingname | 业务业务对象的xiafeicaipingname。 | YES | NULL | 推断 |
| `diancaicanduanid` | `varchar(255)` | diancaicanduanid | 业务业务中的diancaicanduanid。 | YES | NULL | 推断 |
| `diancaicanduanname` | `varchar(255)` | diancaicanduanname | 业务业务对象的diancaicanduanname。 | YES | NULL | 推断 |
| `xiaoleiid` | `varchar(255)` | xiaoleiid | 业务业务中的xiaoleiid。 | YES | NULL | 推断 |
| `xiaolei` | `varchar(255)` | xiaolei | 业务业务中的xiaolei。 | YES | NULL | 推断 |
| `daleiid` | `varchar(255)` | daleiid | 业务业务中的daleiid。 | YES | NULL | 推断 |
| `dalei` | `varchar(255)` | dalei | 业务业务中的dalei。 | YES | NULL | 推断 |
| `zuofa` | `varchar(255)` | zuofa | 业务业务中的zuofa。 | YES | NULL | 推断 |
| `jifenduihuan` | `tinyint` | jifenduihuan | 业务业务中的jifenduihuan。 | YES | NULL | 推断 |
| `zengsong` | `tinyint` | zengsong | 业务业务中的zengsong。 | YES | NULL | 推断 |
| `zengsongren` | `varchar(255)` | zengsongren | 业务业务中的zengsongren。 | YES | NULL | 推断 |
| `zengsongyuanyin` | `varchar(255)` | zengsongyuanyin | 业务业务中的zengsongyuanyin。 | YES | NULL | 推断 |
| `diancaishuliang` | `decimal(19, 10)` | diancaishuliang | 业务业务中的diancaishuliang。 | YES | NULL | 推断 |
| `shangcaishijian` | `datetime` | shangcaishijian | 业务业务中的shangcaishijian。 | YES | NULL | 推断 |
| `yilingqushuliang` | `decimal(19, 10)` | yilingqushuliang | 业务业务中的yilingqushuliang。 | YES | NULL | 推断 |
| `yishangcaishuliang` | `decimal(19, 10)` | yishangcaishuliang | 业务业务中的yishangcaishuliang。 | YES | NULL | 推断 |
| `tuicaishuliang` | `decimal(19, 10)` | tuicaishuliang | 业务业务中的tuicaishuliang。 | YES | NULL | 推断 |
| `tuicaishijian` | `datetime` | tuicaishijian | 业务业务中的tuicaishijian。 | YES | NULL | 推断 |
| `tuicairen` | `varchar(255)` | tuicairen | 业务业务中的tuicairen。 | YES | NULL | 推断 |
| `xiaofeishuliang` | `decimal(19, 10)` | xiaofeishuliang | 业务业务中的xiaofeishuliang。 | YES | NULL | 推断 |
| `tuicaijine` | `decimal(19, 10)` | tuicaijine | 业务业务中的tuicaijine。 | YES | NULL | 推断 |
| `xiaohaojifen` | `decimal(19, 10)` | xiaohaojifen | 业务业务中的xiaohaojifen。 | YES | NULL | 推断 |
| `zengsongjine` | `decimal(19, 10)` | zengsongjine | 业务业务中的zengsongjine。 | YES | NULL | 推断 |
| `shipinfei` | `decimal(19, 10)` | shipinfei | 业务业务中的shipinfei。 | YES | NULL | 推断 |
| `jiagongfei` | `decimal(19, 10)` | jiagongfei | 业务业务中的jiagongfei。 | YES | NULL | 推断 |
| `shipinfuwufei` | `decimal(19, 10)` | shipinfuwufei | 业务业务中的shipinfuwufei。 | YES | NULL | 推断 |
| `jiagongfuwufei` | `decimal(19, 10)` | jiagongfuwufei | 业务业务中的jiagongfuwufei。 | YES | NULL | 推断 |
| `shipinzhekuoe` | `decimal(19, 10)` | shipinzhekuoe | 业务业务中的shipinzhekuoe。 | YES | NULL | 推断 |
| `jiagongzhekuoe` | `decimal(19, 10)` | jiagongzhekuoe | 业务业务中的jiagongzhekuoe。 | YES | NULL | 推断 |
| `yuancailiaodangechengben` | `decimal(19, 10)` | yuancailiaodangechengben | 业务业务中的yuancailiaodangechengben。 | YES | NULL | 推断 |
| `yuancailiaozongchengben` | `decimal(19, 10)` | yuancailiaozongchengben | 业务业务中的yuancailiaozongchengben。 | YES | NULL | 推断 |
| `jiagongchengben` | `decimal(19, 10)` | jiagongchengben | 业务业务中的jiagongchengben。 | YES | NULL | 推断 |
| `danwei` | `varchar(255)` | danwei | 业务业务中的danwei。 | YES | NULL | 推断 |
| `nobillingunit` | `varchar(255)` | nobillingunit | 业务业务对象的nobillingunit。 | YES | NULL | 推断 |
| `nobillingamount` | `decimal(19, 10)` | nobillingamount | 业务业务中的nobillingamount。 | YES | NULL | 推断 |
| `jibendanwei` | `varchar(255)` | jibendanwei | 业务业务中的jibendanwei。 | YES | NULL | 推断 |
| `danweibilv` | `decimal(19, 10)` | danweibilv | 业务业务中的danweibilv。 | YES | NULL | 推断 |
| `jiage` | `decimal(19, 10)` | jiage | 业务业务中的jiage。 | YES | NULL | 推断 |
| `yuanshijiage` | `decimal(19, 10)` | yuanshijiage | 业务业务中的yuanshijiage。 | YES | NULL | 推断 |
| `shifa` | `varchar(255)` | shifa | 业务业务中的shifa。 | YES | NULL | 推断 |
| `diancairen` | `varchar(255)` | diancairen | 业务业务中的diancairen。 | YES | NULL | 推断 |
| `dangeticheng` | `decimal(19, 10)` | dangeticheng | 业务业务中的dangeticheng。 | YES | NULL | 推断 |
| `zongticheng` | `decimal(19, 10)` | zongticheng | 业务业务中的zongticheng。 | YES | NULL | 推断 |
| `tuicaiyuanyin` | `varchar(255)` | tuicaiyuanyin | 业务业务中的tuicaiyuanyin。 | YES | NULL | 推断 |
| `sfquerenshuliang` | `tinyint` | sfquerenshuliang | 业务业务中的sfquerenshuliang。 | YES | NULL | 推断 |
| `shuliangquerenyuan` | `varchar(255)` | shuliangquerenyuan | 业务业务中的shuliangquerenyuan。 | YES | NULL | 推断 |
| `diancaishijian` | `datetime` | diancaishijian | 业务业务中的diancaishijian。 | YES | NULL | 推断 |
| `xiadanshijian` | `datetime` | xiadanshijian | 业务业务中的xiadanshijian。 | YES | NULL | 推断 |
| `overtime` | `int` | overtime | 业务业务中的overtime。 | YES | NULL | 推断 |
| `cuicairenshijian` | `varchar(255)` | cuicairenshijian | 业务业务中的cuicairenshijian。 | YES | NULL | 推断 |
| `caipinginzhuotai` | `varchar(255)` | caipinginzhuotai | 业务业务中的caipinginzhuotai。 | YES | NULL | 推断 |
| `precaipinginzhuotai` | `varchar(255)` | precaipinginzhuotai | 业务业务中的precaipinginzhuotai。 | YES | NULL | 推断 |
| `zhuantaishuliang` | `decimal(19, 10)` | zhuantaishuliang | 业务业务中的zhuantaishuliang。 | YES | NULL | 推断 |
| `bumen` | `varchar(255)` | bumen | 业务业务中的bumen。 | YES | NULL | 推断 |
| `chupingbumen` | `varchar(255)` | chupingbumen | 业务业务中的chupingbumen。 | YES | NULL | 推断 |
| `chupingbumenorg` | `varchar(255)` | chupingbumenorg | 业务业务对象的chupingbumenorg。 | YES | NULL | 推断 |
| `pricemoder` | `varchar(255)` | pricemoder | 业务业务中的pricemoder。 | YES | NULL | 推断 |
| `pricemodtime` | `datetime` | pricemodtime | 业务业务中的pricemodtime。 | YES | NULL | 推断 |
| `shougonggaijia` | `tinyint` | shougonggaijia | 业务业务中的shougonggaijia。 | YES | NULL | 推断 |
| `renamedtime` | `datetime` | renamedtime | 业务业务中的renamedtime。 | YES | NULL | 推断 |
| `namemoder` | `varchar(255)` | namemoder | 业务业务对象的namemoder。 | YES | NULL | 推断 |
| `renamed` | `tinyint` | renamed | 业务业务对象的renamed。 | YES | NULL | 推断 |
| `chushi` | `varchar(255)` | chushi | 业务业务中的chushi。 | YES | NULL | 推断 |
| `maincai` | `bigint` | maincai | 业务业务中的maincai。 | YES | NULL | 推断 |
| `fenchengqianjiage` | `decimal(19, 10)` | fenchengqianjiage | 业务业务中的fenchengqianjiage。 | YES | NULL | 推断 |
| `idxinbill` | `int` | idxinbill | 业务业务中的idxinbill。 | YES | NULL | 推断 |
| `peicaimaincai` | `int` | peicaimaincai | 业务业务中的peicaimaincai。 | YES | NULL | 推断 |
| `zhekoulv` | `decimal(19, 10)` | zhekoulv | 业务业务中的zhekoulv。 | YES | NULL | 推断 |
| `dazheren` | `varchar(255)` | dazheren | 业务业务中的dazheren。 | YES | NULL | 推断 |
| `dazhebyman` | `tinyint` | dazhebyman | 业务业务中的dazhebyman。 | YES | NULL | 推断 |
| `mensetdiscount` | `tinyint` | mensetdiscount | 业务业务中的mensetdiscount。 | YES | NULL | 推断 |
| `canyizuidixiaofei` | `tinyint` | canyizuidixiaofei | 业务业务中的canyizuidixiaofei。 | YES | NULL | 推断 |
| `paid` | `tinyint` | 实付 | 业务业务中的实付。 | YES | NULL | 推断 |
| `rendian` | `tinyint` | rendian | 业务业务中的rendian。 | YES | NULL | 推断 |
| `orgpid` | `int` | orgpid | 业务业务中的orgpid。 | YES | NULL | 推断 |
| `xishu` | `int` | xishu | 业务业务中的xishu。 | YES | NULL | 推断 |
| `isjiuxi` | `tinyint` | isjiuxi | 业务业务中的isjiuxi。 | YES | NULL | 推断 |
| `autosubwarehouse` | `int` | autosubwarehouse | 业务业务中的autosubwarehouse。 | YES | NULL | 推断 |
| `autosubbumem` | `int` | autosubbumem | 业务业务中的autosubbumem。 | YES | NULL | 推断 |
| `subbumen` | `tinyint` | subbumen | 业务业务中的subbumen。 | YES | NULL | 推断 |
| `autosale` | `tinyint` | autosale | 业务业务中的autosale。 | YES | NULL | 推断 |
| `subed` | `tinyint` | subed | 业务业务中的subed。 | YES | NULL | 推断 |
| `prnidx` | `int` | prnidx | 业务业务中的prnidx。 | YES | NULL | 推断 |
| `prnsum` | `int` | prnsum | 业务业务中的prnsum。 | YES | NULL | 推断 |
| `fuzhutaihao` | `varchar(255)` | fuzhutaihao | 业务业务中的fuzhutaihao。 | YES | NULL | 推断 |
| `fuzhutaiming` | `varchar(255)` | fuzhutaiming | 业务业务中的fuzhutaiming。 | YES | NULL | 推断 |
| `songdanidx` | `bigint` | songdanidx | 业务业务中的songdanidx。 | YES | NULL | 推断 |
| `tichengren` | `varchar(255)` | tichengren | 业务业务中的tichengren。 | YES | NULL | 推断 |
| `tichengpercent` | `decimal(19, 10)` | tichengpercent | 业务业务中的tichengpercent。 | YES | NULL | 推断 |
| `istichengper` | `tinyint` | istichengper | 业务业务中的istichengper。 | YES | NULL | 推断 |
| `yufu` | `tinyint` | yufu | 业务业务中的yufu。 | YES | NULL | 推断 |
| `orderbypad` | `tinyint` | orderbypad | 业务业务中的orderbypad。 | YES | NULL | 推断 |
| `strzf1` | `varchar(255)` | strzf1 | 业务业务中的strzf1。 | YES | NULL | 推断 |
| `chengbengjia` | `decimal(19, 10)` | chengbengjia | 业务业务中的chengbengjia。 | YES | NULL | 推断 |
| `istejiacai` | `tinyint` | istejiacai | 业务业务中的istejiacai。 | YES | NULL | 推断 |
| `orderwsid` | `varchar(255)` | orderwsid | 业务业务中的orderwsid。 | YES | NULL | 推断 |
| `orderwsname` | `varchar(255)` | orderwsname | 业务业务对象的orderwsname。 | YES | NULL | 推断 |
| `yichulibanjia` | `tinyint` | yichulibanjia | 业务业务中的yichulibanjia。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `caipingtype` | `int` | caipingtype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `saletaxlv` | `int` | saletaxlv | 业务业务中的saletaxlv。 | YES | NULL | 推断 |
| `saletaxjine` | `decimal(19, 10)` | saletaxjine | 业务业务中的saletaxjine。 | YES | NULL | 推断 |
| `additionalcost` | `decimal(19, 10)` | additionalcost | 业务业务中的additionalcost。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `ShopName` | `varchar(255)` | shopname | 业务业务对象的shopname。 | YES | NULL | 推断 |
| `Factory_brand` | `varchar(255)` | factorybrand | 业务业务中的factorybrand。 | YES | NULL | 推断 |
| `Factory_brand_code` | `varchar(255)` | factorybrandcode | 业务业务对象的factorybrandcode。 | YES | NULL | 推断 |
| `MemberID` | `varchar(255)` | 会员ID | 业务业务中的会员ID。 | YES | NULL | 推断 |
| `MemberLmnID` | `bigint` | memberlmnid | 业务业务中的memberlmnid。 | YES | NULL | 推断 |
| `MemberName` | `varchar(255)` | membername | 业务业务对象的membername。 | YES | NULL | 推断 |
| `MemberSex` | `varchar(64)` | membersex | 业务业务中的membersex。 | YES | NULL | 推断 |
| `Card_type` | `varchar(255)` | 会员卡类型 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_code` | `bigint` | 会员卡类型code | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_level` | `varchar(255)` | 会员卡类型等级 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_level_code` | `bigint` | 会员卡类型等级code | 业务业务分类或类型。 | YES | NULL | 推断 |
| `CardLmnID` | `bigint` | cardlmnid | 业务业务中的cardlmnid。 | YES | NULL | 推断 |
| `HuiYuanCaHao` | `varchar(255)` | huiyuancahao | 业务业务中的huiyuancahao。 | YES | NULL | 推断 |
| `Item_number` | `varchar(255)` | item数量 | 业务业务中的item数量。 | YES | NULL | 推断 |
| `Marketing_plan` | `varchar(255)` | marketingplan | 业务业务中的marketingplan。 | YES | NULL | 推断 |
| `Is_inline` | `tinyint` | isinline | 标记业务业务是否启用或满足isinline条件。 | YES | NULL | 推断 |
| `Upload_time` | `datetime` | upload时间 | 业务业务中的upload时间。 | YES | NULL | 推断 |
| `Is_offline` | `tinyint` | isoffline | 标记业务业务是否启用或满足isoffline条件。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺名称 | 店铺名称 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开台时间 | 开台时间 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time` | `datetime` | 结账时间 | 结账时间 | YES | NULL | DB/DDL/实体注释 |
| `order_sub_type` | `int` | 账单类型;堂食、外卖、自提 | 账单类型;堂食、外卖、自提 | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(32)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `area_name` | `varchar(32)` | 区域名称 | 区域名称 | YES | NULL | DB/DDL/实体注释 |
| `table_name` | `varchar(32)` | 桌台名称 | 桌台名称 | YES | NULL | DB/DDL/实体注释 |
| `checkout_by` | `text` | checkout人 | 业务业务中的checkout人。 | YES |  | 推断 |
| `remark` | `varchar(255)` | 标记 | 标记 | YES | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 账单流水号 | 账单流水号 | YES | NULL | DB/DDL/实体注释 |
| `takeout_channel` | `int` | 外卖渠道 | 外卖渠道 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(32)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `free_service_charge` | `tinyint` | 免服务费 | 免服务费 | YES | NULL | DB/DDL/实体注释 |
| `online` | `tinyint` | 线上订单 | 线上订单 | YES | NULL | DB/DDL/实体注释 |
| `promotion_amount` | `decimal(19, 10)` | 优惠金额 | 优惠金额 | YES | NULL | DB/DDL/实体注释 |
| `total_ordered_qty` | `decimal(18, 4)` | 毛销售数量/总下单数量 | 毛销售数量/总下单数量 | YES | NULL | DB/DDL/实体注释 |
| `returned_qty` | `decimal(18, 4)` | 退菜数量 | 退菜数量（负数） | YES | NULL | DB/DDL/实体注释 |
| `free_qty` | `decimal(18, 4)` | 赠送数量 | 赠送数量（负数） | YES | NULL | DB/DDL/实体注释 |
| `gross_sales_amt` | `decimal(18, 4)` | 毛销售额 | 毛销售额 | YES | NULL | DB/DDL/实体注释 |
| `net_sales_amt` | `decimal(18, 4)` | 净销售额 | 净销售额 | YES | NULL | DB/DDL/实体注释 |
| `returned_amt` | `decimal(18, 4)` | 退菜金额 | 退菜金额（负数） | YES | NULL | DB/DDL/实体注释 |
| `free_amt` | `decimal(18, 4)` | 赠送金额 | 赠送金额（负数） | YES | NULL | DB/DDL/实体注释 |
| `food_service_charge_amt` | `decimal(18, 4)` | 食品服务费 | 食品服务费 | YES | NULL | DB/DDL/实体注释 |
| `food_discount_amt` | `decimal(18, 4)` | 食品折扣额 | 食品折扣额（负数） | YES | NULL | DB/DDL/实体注释 |
| `food_processing_fee_amt` | `decimal(18, 4)` | 加工费 | 加工费 | YES | NULL | DB/DDL/实体注释 |
| `processing_service_charge_amt` | `decimal(18, 4)` | 加工服务费 | 加工服务费 | YES | NULL | DB/DDL/实体注释 |
| `processing_fee_discount_amt` | `decimal(18, 4)` | 加工费折扣额 | 加工费折扣额（负数） | YES | NULL | DB/DDL/实体注释 |
| `receivable_amt` | `decimal(18, 4)` | 应收金额 | 应收金额 | YES | NULL | DB/DDL/实体注释 |
| `price_diff_amt` | `decimal(18, 4)` | 价差金额 | 价差金额 | YES | NULL | DB/DDL/实体注释 |
| `platform_discount_amt` | `decimal(18, 2)` | 平台优惠金额 | 平台优惠金额 | YES | 0.00 | DB/DDL/实体注释 |
| `net_sales_qty` | `decimal(18, 4)` | 净售数量 | 净售数量（计算字段） | YES | 0.0000 | DB/DDL/实体注释 |
| `group_promote_amount` | `decimal(24, 10)` | 团购折扣 | 团购折扣 | YES | NULL | DB/DDL/实体注释 |
| `member_gift_amount` | `decimal(24, 10)` | 赠送折扣 | 赠送折扣 | YES | NULL | DB/DDL/实体注释 |
| `promote_detail` | `text` | 优惠明细 | 优惠明细 | YES |  | DB/DDL/实体注释 |
| `fraction` | `decimal(19, 10)` | 零头 | 零头 | YES | NULL | DB/DDL/实体注释 |
| `mantissa` | `decimal(19, 10)` | 尾数 | 尾数 | YES | NULL | DB/DDL/实体注释 |
| `dish_category_type` | `tinyint` | 菜品类型 | 菜品类型：1-套餐 2-套餐子菜 3-单品 | YES | NULL | DB/DDL/实体注释 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `xiao_fei_d_pid` | `bigint` | xiaofeidpid | 业务业务中的xiaofeidpid。 |  |  | 推断 |
| `xiao_fei_d` | `XiaoFeiDanEx` | xiaofeid | 业务业务中的xiaofeid。 |  |  | 推断 |
| `dian_cai_pi_ci` | `varchar` | diancaipici | 业务业务中的diancaipici。 |  |  | 推断 |
| `xia_fei_cai_ping_id` | `varchar` | xiafeicaipingID | 业务业务关联的xiafeicaipingID。 |  |  | 推断 |
| `xia_fei_cai_ping_name` | `varchar` | xiafeicaipingname | 业务业务对象的xiafeicaipingname。 |  |  | 推断 |
| `dian_cai_can_duan_id` | `varchar` | diancaicanduanID | 业务业务关联的diancaicanduanID。 |  |  | 推断 |
| `dian_cai_can_duan_name` | `varchar` | diancaicanduanname | 业务业务对象的diancaicanduanname。 |  |  | 推断 |
| `xiao_lei_id` | `varchar` | xiaoleiID | 业务业务关联的xiaoleiID。 |  |  | 推断 |
| `xiao_lei` | `varchar` | xiaolei | 业务业务中的xiaolei。 |  |  | 推断 |
| `da_lei_id` | `varchar` | daleiID | 业务业务关联的daleiID。 |  |  | 推断 |
| `da_lei` | `varchar` | dalei | 业务业务中的dalei。 |  |  | 推断 |
| `zuo_fa` | `varchar` | zuofa | 业务业务中的zuofa。 |  |  | 推断 |
| `ji_fen_dui_huan` | `tinyint(1)` | jifenduihuan | 业务业务中的jifenduihuan。 |  |  | 推断 |
| `zeng_song` | `tinyint(1)` | zengsong | 业务业务中的zengsong。 |  |  | 推断 |
| `zeng_song_ren` | `varchar` | zengsongren | 业务业务中的zengsongren。 |  |  | 推断 |
| `zeng_song_yuan_yin` | `varchar` | zengsongyuanyin | 业务业务中的zengsongyuanyin。 |  |  | 推断 |
| `shang_cai_shi_jian` | `datetime` | shangcaishijian | 业务业务中的shangcaishijian。 |  |  | 推断 |
| `original_pos_lmn_id` | `bigint` | 原始poslmnID | POS 侧原始 LmnID，上传时暂存用于构建套餐跨引用映射，不持久化到数据库 |  |  | DB/DDL/实体注释 |

#### `XiaoFeiDan`

- 真实表：`XiaoFeiDan`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\XiaoFeiDanEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `xiaofeidanname` | `varchar(255)` | xiaofeidanname | 业务业务对象的xiaofeidanname。 | YES | NULL | 推断 |
| `taihao` | `varchar(255)` | taihao | 业务业务中的taihao。 | YES | NULL | 推断 |
| `taiming` | `varchar(255)` | taiming | 业务业务中的taiming。 | YES | NULL | 推断 |
| `taiquhao` | `varchar(255)` | taiquhao | 业务业务中的taiquhao。 | YES | NULL | 推断 |
| `taiquming` | `varchar(255)` | taiquming | 业务业务中的taiquming。 | YES | NULL | 推断 |
| `canduan` | `varchar(255)` | canduan | 业务业务中的canduan。 | YES | NULL | 推断 |
| `canduanid` | `varchar(255)` | canduanid | 业务业务中的canduanid。 | YES | NULL | 推断 |
| `renshu` | `int` | renshu | 业务业务中的renshu。 | YES | NULL | 推断 |
| `yanchidanhao` | `varchar(255)` | yanchidanhao | 业务业务中的yanchidanhao。 | YES | NULL | 推断 |
| `kaitaishijian` | `datetime` | kaitaishijian | 业务业务中的kaitaishijian。 | YES | NULL | 推断 |
| `firstjiezhangshijian` | `datetime` | firstjiezhangshijian | 业务业务中的firstjiezhangshijian。 | YES | NULL | 推断 |
| `jiezhangshijian` | `datetime` | jiezhangshijian | 业务业务中的jiezhangshijian。 | YES | NULL | 推断 |
| `booktime` | `datetime` | booktime | 业务业务中的booktime。 | YES | NULL | 推断 |
| `kaitairen` | `varchar(255)` | kaitairen | 业务业务中的kaitairen。 | YES | NULL | 推断 |
| `maidanren` | `varchar(255)` | maidanren | 业务业务中的maidanren。 | YES | NULL | 推断 |
| `maidanshijian` | `datetime` | maidanshijian | 业务业务中的maidanshijian。 | YES | NULL | 推断 |
| `ShouYinRen` | `text` | shouyinren | 业务业务中的shouyinren。 | YES |  | 推断 |
| `yewuyuan` | `varchar(255)` | yewuyuan | 业务业务中的yewuyuan。 | YES | NULL | 推断 |
| `rendiancha` | `decimal(19, 10)` | rendiancha | 业务业务中的rendiancha。 | YES | NULL | 推断 |
| `tuicaijine` | `decimal(19, 10)` | tuicaijine | 业务业务中的tuicaijine。 | YES | NULL | 推断 |
| `zengsongjine` | `decimal(19, 10)` | zengsongjine | 业务业务中的zengsongjine。 | YES | NULL | 推断 |
| `fuwufeilv` | `decimal(19, 10)` | fuwufeilv | 业务业务中的fuwufeilv。 | YES | NULL | 推断 |
| `dazheren` | `varchar(255)` | dazheren | 业务业务中的dazheren。 | YES | NULL | 推断 |
| `dazhefangshi` | `varchar(255)` | dazhefangshi | 业务业务中的dazhefangshi。 | YES | NULL | 推断 |
| `zhekoulv` | `decimal(19, 10)` | zhekoulv | 业务业务中的zhekoulv。 | YES | NULL | 推断 |
| `membertypeid` | `varchar(255)` | membertypeid | 业务业务分类或类型。 | YES | NULL | 推断 |
| `membertypename` | `varchar(255)` | membertypename | 业务业务分类或类型。 | YES | NULL | 推断 |
| `memberid` | `varchar(255)` | 会员ID | 业务业务中的会员ID。 | YES | NULL | 推断 |
| `membername` | `varchar(255)` | membername | 业务业务对象的membername。 | YES | NULL | 推断 |
| `membersex` | `varchar(255)` | membersex | 业务业务中的membersex。 | YES | NULL | 推断 |
| `huiyuancahao` | `varchar(255)` | huiyuancahao | 业务业务中的huiyuancahao。 | YES | NULL | 推断 |
| `huiyuanbalance` | `decimal(19, 10)` | huiyuanbalance | 业务业务中的huiyuanbalance。 | YES | NULL | 推断 |
| `huiyuanintegral` | `decimal(19, 10)` | huiyuanintegral | 业务业务中的huiyuanintegral。 | YES | NULL | 推断 |
| `mianfuwufei` | `tinyint` | mianfuwufei | 业务业务中的mianfuwufei。 | YES | NULL | 推断 |
| `miandiaofuwufei` | `decimal(19, 10)` | miandiaofuwufei | 业务业务中的miandiaofuwufei。 | YES | NULL | 推断 |
| `shipingfei` | `decimal(19, 10)` | shipingfei | 业务业务中的shipingfei。 | YES | NULL | 推断 |
| `fuwufei` | `decimal(19, 10)` | fuwufei | 业务业务中的fuwufei。 | YES | NULL | 推断 |
| `zhekoue` | `decimal(19, 10)` | zhekoue | 业务业务中的zhekoue。 | YES | NULL | 推断 |
| `weishu` | `decimal(19, 10)` | weishu | 业务业务中的weishu。 | YES | NULL | 推断 |
| `lingtou` | `decimal(19, 10)` | lingtou | 业务业务中的lingtou。 | YES | NULL | 推断 |
| `lingtouor` | `varchar(255)` | lingtouor | 业务业务中的lingtouor。 | YES | NULL | 推断 |
| `fanjiezhangren` | `varchar(255)` | fanjiezhangren | 业务业务中的fanjiezhangren。 | YES | NULL | 推断 |
| `fanjiezhangshijian` | `datetime` | fanjiezhangshijian | 业务业务中的fanjiezhangshijian。 | YES | NULL | 推断 |
| `zuidixiaofei` | `decimal(19, 10)` | zuidixiaofei | 业务业务中的zuidixiaofei。 | YES | NULL | 推断 |
| `zuidixiaofeicha` | `decimal(19, 10)` | zuidixiaofeicha | 业务业务中的zuidixiaofeicha。 | YES | NULL | 推断 |
| `quxiaozdxf` | `tinyint` | quxiaozdxf | 业务业务中的quxiaozdxf。 | YES | NULL | 推断 |
| `quxiaozdxfor` | `varchar(255)` | quxiaozdxfor | 业务业务中的quxiaozdxfor。 | YES | NULL | 推断 |
| `taxrate` | `decimal(19, 10)` | taxrate | 业务业务中的taxrate。 | YES | NULL | 推断 |
| `tax` | `decimal(19, 10)` | tax | 业务业务中的tax。 | YES | NULL | 推断 |
| `statetaxrate` | `decimal(19, 10)` | statetaxrate | 业务业务中的statetaxrate。 | YES | NULL | 推断 |
| `statetax` | `decimal(19, 10)` | statetax | 业务业务中的statetax。 | YES | NULL | 推断 |
| `yingshoujine` | `decimal(19, 10)` | yingshoujine | 业务业务中的yingshoujine。 | YES | NULL | 推断 |
| `shishoujine` | `decimal(19, 10)` | shishoujine | 业务业务中的shishoujine。 | YES | NULL | 推断 |
| `shoudaojine` | `decimal(19, 10)` | shoudaojine | 业务业务中的shoudaojine。 | YES | NULL | 推断 |
| `zhaohuijine` | `decimal(19, 10)` | zhaohuijine | 业务业务中的zhaohuijine。 | YES | NULL | 推断 |
| `fapiaojine` | `decimal(19, 10)` | fapiaojine | 业务业务中的fapiaojine。 | YES | NULL | 推断 |
| `maidancishu` | `int` | maidancishu | 业务业务中的maidancishu。 | YES | NULL | 推断 |
| `maidanzhuangtai` | `varchar(64)` | maidanzhuangtai | 业务业务中的maidanzhuangtai。 | YES | NULL | 推断 |
| `tbl` | `varchar(255)` | 桌台 | 业务业务中的桌台。 | YES | NULL | 推断 |
| `cai` | `varchar(64)` | cai | 业务业务中的cai。 | YES | NULL | 推断 |
| `pretable` | `varchar(255)` | pretable | 业务业务中的pretable。 | YES | NULL | 推断 |
| `fukuanqingkuang` | `varchar(64)` | fukuanqingkuang | 业务业务中的fukuanqingkuang。 | YES | NULL | 推断 |
| `lastcaozuoren` | `varchar(255)` | lastcaozuoren | 业务业务中的lastcaozuoren。 | YES | NULL | 推断 |
| `lastaction` | `varchar(255)` | lastaction | 业务业务中的lastaction。 | YES | NULL | 推断 |
| `printcount` | `int` | printcount | 业务业务中的printcount。 | YES | NULL | 推断 |
| `jiaobanhao` | `varchar(255)` | jiaobanhao | 业务业务中的jiaobanhao。 | YES | NULL | 推断 |
| `firststationid` | `varchar(255)` | firststationid | 业务业务中的firststationid。 | YES | NULL | 推断 |
| `stationid` | `varchar(255)` | stationid | 业务业务中的stationid。 | YES | NULL | 推断 |
| `stationname` | `varchar(255)` | stationname | 业务业务对象的stationname。 | YES | NULL | 推断 |
| `kaitaistationid` | `varchar(255)` | kaitaistationid | 业务业务中的kaitaistationid。 | YES | NULL | 推断 |
| `kaitaistationname` | `varchar(255)` | kaitaistationname | 业务业务对象的kaitaistationname。 | YES | NULL | 推断 |
| `jiezhangfangshi` | `varchar(255)` | jiezhangfangshi | 业务业务中的jiezhangfangshi。 | YES | NULL | 推断 |
| `booktype` | `varchar(64)` | booktype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `bookbilltype` | `varchar(64)` | bookbilltype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `xinkaitai` | `tinyint` | xinkaitai | 业务业务中的xinkaitai。 | YES | NULL | 推断 |
| `isorder` | `tinyint` | isorder | 业务业务中的isorder。 | YES | NULL | 推断 |
| `beizhu` | `text` | beizhu | 业务业务中的beizhu。 | YES |  | 推断 |
| `orderbillid` | `varchar(64)` | orderbillid | 业务业务中的orderbillid。 | YES | NULL | 推断 |
| `alltblname` | `varchar(255)` | alltblname | 业务业务对象的alltblname。 | YES | NULL | 推断 |
| `xishu` | `int` | xishu | 业务业务中的xishu。 | YES | NULL | 推断 |
| `isjiuxi` | `tinyint` | isjiuxi | 业务业务中的isjiuxi。 | YES | NULL | 推断 |
| `danxijine` | `decimal(19, 10)` | danxijine | 业务业务中的danxijine。 | YES | NULL | 推断 |
| `jiuxijine` | `decimal(19, 10)` | jiuxijine | 业务业务中的jiuxijine。 | YES | NULL | 推断 |
| `jiuxidingjin` | `decimal(19, 10)` | jiuxidingjin | 业务业务中的jiuxidingjin。 | YES | NULL | 推断 |
| `bulu` | `tinyint` | bulu | 业务业务中的bulu。 | YES | NULL | 推断 |
| `diancaipici` | `varchar(64)` | diancaipici | 业务业务中的diancaipici。 | YES | NULL | 推断 |
| `shopname` | `varchar(255)` | shopname | 业务业务对象的shopname。 | YES | NULL | 推断 |
| `songcanaddr` | `varchar(255)` | songcanaddr | 业务业务中的songcanaddr。 | YES | NULL | 推断 |
| `songcanjifen` | `decimal(19, 10)` | songcanjifen | 业务业务中的songcanjifen。 | YES | NULL | 推断 |
| `songcanphone` | `varchar(255)` | songcanphone | 业务业务中的songcanphone。 | YES | NULL | 推断 |
| `songcanren` | `varchar(255)` | songcanren | 业务业务中的songcanren。 | YES | NULL | 推断 |
| `diancanrenunionid` | `varchar(64)` | diancanrenunionid | 业务业务中的diancanrenunionid。 | YES | NULL | 推断 |
| `dingcanren` | `varchar(255)` | dingcanren | 业务业务中的dingcanren。 | YES | NULL | 推断 |
| `songcanshijian` | `datetime` | songcanshijian | 业务业务中的songcanshijian。 | YES | NULL | 推断 |
| `youhuihuodongid` | `varchar(255)` | youhuihuodongid | 业务业务中的youhuihuodongid。 | YES | NULL | 推断 |
| `youhuihuodongname` | `varchar(255)` | youhuihuodongname | 业务业务对象的youhuihuodongname。 | YES | NULL | 推断 |
| `youhuijine` | `decimal(19, 10)` | youhuijine | 业务业务中的youhuijine。 | YES | NULL | 推断 |
| `qtmodel` | `varchar(255)` | qtmodel | 业务业务中的qtmodel。 | YES | NULL | 推断 |
| `shangzhongshijian` | `datetime` | shangzhongshijian | 业务业务中的shangzhongshijian。 | YES | NULL | 推断 |
| `luozhongshijian` | `datetime` | luozhongshijian | 业务业务中的luozhongshijian。 | YES | NULL | 推断 |
| `jishijine` | `decimal(19, 10)` | jishijine | 业务业务中的jishijine。 | YES | NULL | 推断 |
| `isshoudongzhekou` | `tinyint` | isshoudongzhekou | 业务业务中的isshoudongzhekou。 | YES | NULL | 推断 |
| `songcantuicai` | `tinyint` | songcantuicai | 业务业务中的songcantuicai。 | YES | NULL | 推断 |
| `kaitaiyushouyajin` | `decimal(19, 10)` | kaitaiyushouyajin | 业务业务中的kaitaiyushouyajin。 | YES | NULL | 推断 |
| `buffetid` | `varchar(255)` | buffetid | 业务业务中的buffetid。 | YES | NULL | 推断 |
| `buffetname` | `varchar(255)` | buffetname | 业务业务对象的buffetname。 | YES | NULL | 推断 |
| `buffetdazhe` | `tinyint` | buffetdazhe | 业务业务中的buffetdazhe。 | YES | NULL | 推断 |
| `buffetamount` | `decimal(19, 10)` | buffetamount | 业务业务中的buffetamount。 | YES | NULL | 推断 |
| `buffetprice` | `decimal(19, 10)` | buffetprice | 业务业务中的buffetprice。 | YES | NULL | 推断 |
| `buffetmoney` | `decimal(19, 10)` | buffetmoney | 业务业务中的buffetmoney。 | YES | NULL | 推断 |
| `jifenjishu` | `decimal(19, 10)` | jifenjishu | 业务业务中的jifenjishu。 | YES | NULL | 推断 |
| `jifene` | `decimal(19, 10)` | jifene | 业务业务中的jifene。 | YES | NULL | 推断 |
| `alpay_out_trade_no` | `varchar(64)` | alpayouttradeno | 业务业务对象的alpayouttradeno。 | YES | NULL | 推断 |
| `alpay_finish` | `tinyint` | alpayfinish | 业务业务中的alpayfinish。 | YES | NULL | 推断 |
| `billprntype` | `varchar(64)` | billprntype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `jishizhekoue` | `decimal(19, 10)` | jishizhekoue | 业务业务中的jishizhekoue。 | YES | NULL | 推断 |
| `youhuijuanchae` | `decimal(19, 10)` | youhuijuanchae | 业务业务中的youhuijuanchae。 | YES | NULL | 推断 |
| `fapiaodanhao` | `varchar(255)` | fapiaodanhao | 业务业务中的fapiaodanhao。 | YES | NULL | 推断 |
| `bucanyudazhejine` | `decimal(19, 10)` | bucanyudazhejine | 业务业务中的bucanyudazhejine。 | YES | NULL | 推断 |
| `msgdealstate` | `int` | msgdealstate | 业务业务中的msgdealstate。 | YES | NULL | 推断 |
| `dealstate` | `int` | dealstate | 业务业务中的dealstate。 | YES | NULL | 推断 |
| `wmptbillid` | `varchar(255)` | wmptbillid | 业务业务中的wmptbillid。 | YES | NULL | 推断 |
| `manjianjine` | `decimal(19, 10)` | manjianjine | 业务业务中的manjianjine。 | YES | NULL | 推断 |
| `dantype` | `varchar(255)` | dantype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `tips` | `decimal(19, 10)` | tips | 业务业务中的tips。 | YES | NULL | 推断 |
| `xjtips` | `decimal(19, 10)` | xjtips | 业务业务中的xjtips。 | YES | NULL | 推断 |
| `xyktips` | `decimal(19, 10)` | xyktips | 业务业务中的xyktips。 | YES | NULL | 推断 |
| `wmptdaynum` | `int` | wmptdaynum | 业务业务中的wmptdaynum。 | YES | NULL | 推断 |
| `additionalcost` | `decimal(19, 10)` | additionalcost | 业务业务中的additionalcost。 | YES | NULL | 推断 |
| `notax` | `tinyint` | notax | 业务业务对象的notax。 | YES | NULL | 推断 |
| `additionalchargecp` | `decimal(19, 10)` | additionalchargecp | 业务业务中的additionalchargecp。 | YES | NULL | 推断 |
| `payxfdtype` | `int` | payxfdtype | 业务业务分类或类型。 | YES | NULL | 推断 |
| `danmode` | `int` | danmode | 业务业务中的danmode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `Sum_of_cost` | `decimal(20, 10)` | sumofcost | 业务业务中的sumofcost。 | YES | NULL | 推断 |
| `UploadToSaaS` | `tinyint` | uploadtosaas | 业务业务中的uploadtosaas。 | YES | NULL | 推断 |
| `MemberLmnID` | `bigint` | memberlmnid | 业务业务中的memberlmnid。 | YES | NULL | 推断 |
| `Card_type` | `varchar(255)` | 会员卡类型 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_code` | `bigint` | 会员卡类型code | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_level` | `varchar(255)` | 会员卡类型等级 | 业务业务分类或类型。 | YES | NULL | 推断 |
| `Card_type_level_code` | `bigint` | 会员卡类型等级code | 业务业务分类或类型。 | YES | NULL | 推断 |
| `CardLmnID` | `text` | 优惠券json列表 | 优惠券json列表 | YES |  | DB/DDL/实体注释 |
| `Sum_of_org_price` | `decimal(19, 10)` | sumoforg价格 | 业务业务中的sumoforg价格。 | YES | NULL | 推断 |
| `Is_inline` | `tinyint` | isinline | 标记业务业务是否启用或满足isinline条件。 | YES | NULL | 推断 |
| `PickUpCode` | `int` | pickupcode | 业务业务对象的pickupcode。 | YES | NULL | 推断 |
| `Viewmode` | `int` | viewmode | 业务业务中的viewmode。 | YES | NULL | 推断 |
| `Status` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 推断 |
| `takeout_channel` | `int` | 外卖渠道 | 外卖渠道 | YES | NULL | DB/DDL/实体注释 |
| `takeout_channel_order_number` | `varchar(255)` | 外卖渠道单号 | 外卖渠道单号 | YES | NULL | DB/DDL/实体注释 |
| `takeout_order_amount` | `decimal(19, 10)` | 订单总金额 | 订单总金额 | YES | NULL | DB/DDL/实体注释 |
| `commission_amount` | `decimal(19, 10)` | 佣金金额 | 佣金金额 | YES | NULL | DB/DDL/实体注释 |
| `business_amount` | `decimal(19, 10)` | 商家应收金额 | 商家应收金额 | YES | NULL | DB/DDL/实体注释 |
| `favourable_amount` | `decimal(19, 10)` | 优惠总金额 | 优惠总金额（商家承担+平台承担+商家替用户承担的配送费用） | YES | NULL | DB/DDL/实体注释 |
| `business_favourable_amount` | `decimal(19, 10)` | 商家承担金额 | 商家承担金额 | YES | NULL | DB/DDL/实体注释 |
| `platform_favourable_amount` | `decimal(19, 10)` | 平台承担金额 | 平台承担金额 | YES | NULL | DB/DDL/实体注释 |
| `businesses_deliveryroute_fees` | `decimal(19, 10)` | 商家替用户承担的配送费用 | 商家替用户承担的配送费用 | YES | NULL | DB/DDL/实体注释 |
| `delivery_amount` | `decimal(19, 10)` | 配送费 | 配送费 | YES | NULL | DB/DDL/实体注释 |
| `box_amount` | `decimal(19, 10)` | 打包盒金额 | 打包盒金额 | YES | NULL | DB/DDL/实体注释 |
| `takeout_pay_amount` | `decimal(19, 10)` | 支付金额 | 支付金额 | YES | NULL | DB/DDL/实体注释 |
| `price_diff_amt` | `decimal(19, 10)` | 价差金额 | 价差金额 | YES | NULL | DB/DDL/实体注释 |
| `gross_sales_amt` | `decimal(18, 4)` | 毛销售额 | 毛销售额 | YES | NULL | DB/DDL/实体注释 |
| `net_sales_amt` | `decimal(18, 4)` | 净销售额 | 净销售额 | YES | NULL | DB/DDL/实体注释 |
| `returned_amt` | `decimal(18, 4)` | 退菜金额 | 退菜金额 | YES | NULL | DB/DDL/实体注释 |
| `free_amt` | `decimal(18, 4)` | 赠送金额 | 赠送金额 | YES | NULL | DB/DDL/实体注释 |
| `food_service_charge_amt` | `decimal(18, 4)` | 食品服务费 | 食品服务费 | YES | NULL | DB/DDL/实体注释 |
| `food_discount_amt` | `decimal(18, 4)` | 食品折扣额 | 食品折扣额 | YES | NULL | DB/DDL/实体注释 |
| `food_processing_fee_amt` | `decimal(18, 4)` | 加工费 | 加工费 | YES | NULL | DB/DDL/实体注释 |
| `processing_service_charge_amt` | `decimal(18, 4)` | 加工服务费 | 加工服务费 | YES | NULL | DB/DDL/实体注释 |
| `processing_fee_discount_amt` | `decimal(18, 4)` | 加工费折扣额 | 加工费折扣额 | YES | NULL | DB/DDL/实体注释 |
| `receivable_amt` | `decimal(18, 4)` | 应收金额 | 应收金额(菜品) | YES | NULL | DB/DDL/实体注释 |
| `promotion_amount` | `decimal(18, 2)` | promotion金额 | 业务业务中的promotion金额。 | YES | 0.00 | 推断 |
| `group_promote_amount` | `decimal(24, 10)` | 团购折扣 | 团购折扣 | YES | NULL | DB/DDL/实体注释 |
| `member_gift_amount` | `decimal(24, 10)` | 赠送折扣 | 赠送折扣 | YES | NULL | DB/DDL/实体注释 |
| `promote_detail` | `text` | 优惠明细 | 优惠明细 | YES |  | DB/DDL/实体注释 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `xiao_fei_dan_id` | `varchar` | xiaofeidanID | 业务业务关联的xiaofeidanID。 |  |  | 推断 |
| `xiao_fei_dan_name` | `varchar` | xiaofeidanname | 业务业务对象的xiaofeidanname。 |  |  | 推断 |
| `tai_hao` | `varchar` | taihao | 业务业务中的taihao。 |  |  | 推断 |
| `tai_ming` | `varchar` | taiming | 业务业务中的taiming。 |  |  | 推断 |
| `tai_qu_hao` | `varchar` | taiquhao | 业务业务中的taiquhao。 |  |  | 推断 |
| `tai_qu_ming` | `varchar` | taiquming | 业务业务中的taiquming。 |  |  | 推断 |
| `can_duan` | `varchar` | canduan | 业务业务中的canduan。 |  |  | 推断 |
| `can_duan_id` | `varchar` | canduanID | 业务业务关联的canduanID。 |  |  | 推断 |
| `ren_shu` | `int` | renshu | 业务业务中的renshu。 |  |  | 推断 |
| `yan_chi_dan_hao` | `varchar` | yanchidanhao | 业务业务中的yanchidanhao。 |  |  | 推断 |
| `kai_tai_shi_jian` | `datetime` | kaitaishijian | 业务业务中的kaitaishijian。 |  |  | 推断 |
| `first_jie_zhang_shi_jian` | `datetime` | firstjiezhangshijian | 业务业务中的firstjiezhangshijian。 |  |  | 推断 |
| `jie_zhang_shi_jian` | `datetime` | jiezhangshijian | 业务业务中的jiezhangshijian。 |  |  | 推断 |
| `book_time` | `datetime` | book时间 | 业务业务中的book时间。 |  |  | 推断 |
| `kai_tai_ren` | `varchar` | kaitairen | 业务业务中的kaitairen。 |  |  | 推断 |
| `mai_dan_ren` | `varchar` | maidanren | 业务业务中的maidanren。 |  |  | 推断 |
| `mai_dan_shi_jian` | `datetime` | maidanshijian | 业务业务中的maidanshijian。 |  |  | 推断 |
| `shou_yin_ren` | `varchar` | shouyinren | 业务业务中的shouyinren。 |  |  | 推断 |
| `ye_wu_yuan` | `varchar` | yewuyuan | 业务业务中的yewuyuan。 |  |  | 推断 |
| `da_zhe_ren` | `varchar` | dazheren | 业务业务中的dazheren。 |  |  | 推断 |
| `da_zhe_fang_shi` | `varchar` | dazhefangshi | 业务业务中的dazhefangshi。 |  |  | 推断 |
| `member_type_id` | `varchar` | 会员类型ID | 业务业务关联的会员类型ID。 |  |  | 推断 |
| `member_type_name` | `varchar` | 会员类型name | 业务业务分类或类型。 |  |  | 推断 |
| `member_id` | `varchar` | 会员ID | 会员记录编号。 |  |  | 通用字段 |
| `member_lmn_id` | `varchar` | 会员lmnID | 业务业务关联的会员lmnID。 |  |  | 推断 |
| `member_name` | `varchar` | 会员姓名 | 会员姓名或昵称。 |  |  | 通用字段 |
| `member_sex` | `varchar` | 会员sex | 业务业务中的会员sex。 |  |  | 推断 |
| `card_type` | `varchar` | 会员卡类型 | 业务业务分类或类型。 |  |  | 推断 |
| `card_type_code` | `varchar` | 会员卡类型code | 业务业务分类或类型。 |  |  | 推断 |
| `card_type_level` | `varchar` | 会员卡类型等级 | 业务业务分类或类型。 |  |  | 推断 |
| `card_type_level_code` | `varchar` | 会员卡类型等级code | 业务业务分类或类型。 |  |  | 推断 |
| `card_lmn_id` | `varchar` | 会员卡lmnID | 业务业务关联的会员卡lmnID。 |  |  | 推断 |
| `hui_yuan_ca_hao` | `varchar` | huiyuancahao | 业务业务中的huiyuancahao。 |  |  | 推断 |
| `mian_fu_wu_fei` | `tinyint(1)` | mianfuwufei | 业务业务中的mianfuwufei。 |  |  | 推断 |
| `ling_tou_or` | `varchar` | lingtouor | 业务业务中的lingtouor。 |  |  | 推断 |
| `fan_jie_zhang_ren` | `varchar` | fanjiezhangren | 业务业务中的fanjiezhangren。 |  |  | 推断 |
| `fan_jie_zhang_shi_jian` | `datetime` | fanjiezhangshijian | 业务业务中的fanjiezhangshijian。 |  |  | 推断 |
| `qu_xiao_zdxf` | `tinyint(1)` | quxiaozdxf | 业务业务中的quxiaozdxf。 |  |  | 推断 |
| `qu_xiao_zdxf_or` | `varchar` | quxiaozdxfor | 业务业务中的quxiaozdxfor。 |  |  | 推断 |
| `mai_dan_ci_shu` | `int` | maidancishu | 业务业务中的maidancishu。 |  |  | 推断 |
| `mai_dan_zhuang_tai` | `varchar` | maidanzhuangtai | 业务业务中的maidanzhuangtai。 |  |  | 推断 |
| `pre_table` | `varchar` | 预处理桌台 | 业务业务中的预处理桌台。 |  |  | 推断 |
| `fu_kuan_qing_kuang` | `varchar` | fukuanqingkuang | 业务业务中的fukuanqingkuang。 |  |  | 推断 |
| `last_cao_zuo_ren` | `varchar` | 上次caozuoren | 业务业务中的上次caozuoren。 |  |  | 推断 |
| `last_action` | `varchar` | 上次action | 业务业务中的上次action。 |  |  | 推断 |
| `print_count` | `int` | print次数 | 业务业务中的print次数。 |  |  | 推断 |
| `jiao_ban_hao` | `varchar` | jiaobanhao | 业务业务中的jiaobanhao。 |  |  | 推断 |
| `first_station_id` | `varchar` | firststationID | 业务业务关联的firststationID。 |  |  | 推断 |
| `station_id` | `varchar` | stationID | 业务业务关联的stationID。 |  |  | 推断 |
| `station_name` | `varchar` | stationname | 业务业务对象的stationname。 |  |  | 推断 |
| `kai_tai_station_id` | `varchar` | kaitaistationID | 业务业务关联的kaitaistationID。 |  |  | 推断 |
| `kai_tai_station_name` | `varchar` | kaitaistationname | 业务业务对象的kaitaistationname。 |  |  | 推断 |
| `jie_zhang_fang_shi` | `varchar` | jiezhangfangshi | 业务业务中的jiezhangfangshi。 |  |  | 推断 |
| `book_type` | `varchar` | book类型 | 业务业务分类或类型。 |  |  | 推断 |
| `book_bill_type` | `varchar` | book账单类型 | 业务业务分类或类型。 |  |  | 推断 |
| `xin_kai_tai` | `tinyint(1)` | xinkaitai | 业务业务中的xinkaitai。 |  |  | 推断 |
| `is_order` | `tinyint(1)` | is订单 | 标记业务业务是否启用或满足is订单条件。 |  |  | 推断 |
| `bei_zhu` | `varchar` | beizhu | 业务业务中的beizhu。 |  |  | 推断 |
| `order_bill_id` | `varchar` | 订单账单ID | 业务业务关联的订单账单ID。 |  |  | 推断 |
| `all_tbl_name` | `varchar` | all桌台name | 业务业务对象的all桌台name。 |  |  | 推断 |
| `xi_shu` | `int` | xishu | 业务业务中的xishu。 |  |  | 推断 |
| `is_jiu_xi` | `tinyint(1)` | isjiuxi | 标记业务业务是否启用或满足isjiuxi条件。 |  |  | 推断 |
| `bu_lu` | `tinyint(1)` | bulu | 业务业务中的bulu。 |  |  | 推断 |
| `dian_cai_pi_ci` | `varchar` | diancaipici | 业务业务中的diancaipici。 |  |  | 推断 |
| `shop_name` | `varchar` | 店铺name | 业务业务对象的店铺name。 |  |  | 推断 |
| `song_can_addr` | `varchar` | songcanaddr | 业务业务中的songcanaddr。 |  |  | 推断 |
| `song_can_phone` | `varchar` | songcanphone | 业务业务中的songcanphone。 |  |  | 推断 |
| `song_can_ren` | `varchar` | songcanren | 业务业务中的songcanren。 |  |  | 推断 |
| `dian_can_ren_union_id` | `varchar` | diancanrenunionID | 业务业务关联的diancanrenunionID。 |  |  | 推断 |
| `ding_can_ren` | `varchar` | dingcanren | 业务业务中的dingcanren。 |  |  | 推断 |
| `song_can_shi_jian` | `datetime` | songcanshijian | 业务业务中的songcanshijian。 |  |  | 推断 |
| `you_hui_huo_dong_id` | `varchar` | youhuihuodongID | 业务业务关联的youhuihuodongID。 |  |  | 推断 |
| `you_hui_huo_dong_name` | `varchar` | youhuihuodongname | 业务业务对象的youhuihuodongname。 |  |  | 推断 |
| `qt_model` | `varchar` | qtmodel | 业务业务中的qtmodel。 |  |  | 推断 |
| `shang_zhong_shi_jian` | `datetime` | shangzhongshijian | 业务业务中的shangzhongshijian。 |  |  | 推断 |
| `luo_zhong_shi_jian` | `datetime` | luozhongshijian | 业务业务中的luozhongshijian。 |  |  | 推断 |
| `is_shou_dong_zhe_kou` | `tinyint(1)` | isshoudongzhekou | 标记业务业务是否启用或满足isshoudongzhekou条件。 |  |  | 推断 |
| `song_can_tui_cai` | `tinyint(1)` | songcantuicai | 业务业务中的songcantuicai。 |  |  | 推断 |
| `buffet_id` | `varchar` | buffetID | 业务业务关联的buffetID。 |  |  | 推断 |
| `buffet_name` | `varchar` | buffetname | 业务业务对象的buffetname。 |  |  | 推断 |
| `buffet_da_zhe` | `tinyint(1)` | buffetdazhe | 业务业务中的buffetdazhe。 |  |  | 推断 |
| `bill_prn_type` | `varchar` | 账单打印类型 | 业务业务分类或类型。 |  |  | 推断 |
| `fa_piao_dan_hao` | `varchar` | fapiaodanhao | 业务业务中的fapiaodanhao。 |  |  | 推断 |
| `msg_deal_state` | `int` | 消息deal状态 | 业务业务中的消息deal状态。 |  |  | 推断 |
| `deal_state` | `int` | deal状态 | 业务业务中的deal状态。 |  |  | 推断 |
| `wmpt_bill_id` | `varchar` | wmpt账单ID | 业务业务关联的wmpt账单ID。 |  |  | 推断 |
| `dan_type` | `varchar` | dan类型 | 业务业务分类或类型。 |  |  | 推断 |

#### `ZuoFaInShiFa`

- 真实表：`ZuoFaInShiFa`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：业务
- 表含义：业务相关业务数据表。
- 字段来源：`SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\order\ZuoFaInShiFaEx.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO |  | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 业务业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 业务业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 业务业务中的day。 | YES | NULL | 推断 |
| `shifa` | `varchar(255)` | shifa | 业务业务中的shifa。 | YES | NULL | 推断 |
| `caipingzuofapid` | `varchar(255)` | caipingzuofapid | 业务业务中的caipingzuofapid。 | YES | NULL | 推断 |
| `caipingzuofaid` | `varchar(255)` | caipingzuofaid | 业务业务中的caipingzuofaid。 | YES | NULL | 推断 |
| `jiage` | `decimal(19, 10)` | jiage | 业务业务中的jiage。 | YES | NULL | 推断 |
| `chengbendanjia` | `decimal(19, 10)` | chengbendanjia | 业务业务中的chengbendanjia。 | YES | NULL | 推断 |
| `selfamount` | `decimal(19, 10)` | selfamount | 业务业务中的selfamount。 | YES | NULL | 推断 |
| `yaochengyushuliang` | `tinyint` | yaochengyushuliang | 业务业务中的yaochengyushuliang。 | YES | NULL | 推断 |
| `shufuwufei` | `tinyint` | shufuwufei | 业务业务中的shufuwufei。 | YES | NULL | 推断 |
| `canyidazhe` | `tinyint` | canyidazhe | 业务业务中的canyidazhe。 | YES | NULL | 推断 |
| `ishandwrited` | `tinyint` | ishandwrited | 业务业务中的ishandwrited。 | YES | NULL | 推断 |
| `writer` | `varchar(255)` | writer | 业务业务中的writer。 | YES | NULL | 推断 |
| `bumen` | `varchar(255)` | bumen | 业务业务中的bumen。 | YES | NULL | 推断 |
| `jiagongfei` | `decimal(19, 10)` | jiagongfei | 业务业务中的jiagongfei。 | YES | NULL | 推断 |
| `chengbenzongjia` | `decimal(19, 10)` | chengbenzongjia | 业务业务中的chengbenzongjia。 | YES | NULL | 推断 |
| `fuwufei` | `decimal(19, 10)` | fuwufei | 业务业务中的fuwufei。 | YES | NULL | 推断 |
| `biaoqian` | `varchar(255)` | biaoqian | 业务业务中的biaoqian。 | YES | NULL | 推断 |
| `biaoqianpid` | `varchar(255)` | biaoqianpid | 业务业务中的biaoqianpid。 | YES | NULL | 推断 |
| `biaoqianid` | `varchar(255)` | biaoqianid | 业务业务中的biaoqianid。 | YES | NULL | 推断 |
| `zhekoue` | `decimal(19, 10)` | zhekoue | 业务业务中的zhekoue。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 业务业务中的单位。 | YES | NULL | 推断 |
| `chupingbumen` | `varchar(255)` | chupingbumen | 业务业务中的chupingbumen。 | YES | NULL | 推断 |
| `isyaoqiu` | `tinyint` | isyaoqiu | 业务业务中的isyaoqiu。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 业务业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `xiaofeicaipingid` | `varchar(255)` | xiaofeicaipingid | 业务业务中的xiaofeicaipingid。 | YES | NULL | 推断 |
| `xiaofeicaipingpid` | `bigint` | xiaofeicaipingpid | 业务业务中的xiaofeicaipingpid。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺名称 | 店铺名称 | YES | NULL | DB/DDL/实体注释 |
| `start_time` | `datetime` | 开台时间 | 开台时间 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time` | `datetime` | 结账时间 | 结账时间 | YES | NULL | DB/DDL/实体注释 |
| `order_sub_type` | `int` | 账单类型;堂食、外卖、自提 | 账单类型;堂食、外卖、自提 | YES | NULL | DB/DDL/实体注释 |
| `shift_name` | `varchar(32)` | 班次 | 班次 | YES | NULL | DB/DDL/实体注释 |
| `area_name` | `varchar(32)` | 区域名称 | 区域名称 | YES | NULL | DB/DDL/实体注释 |
| `table_name` | `varchar(32)` | 桌台名称 | 桌台名称 | YES | NULL | DB/DDL/实体注释 |
| `checkout_by` | `text` | checkout人 | 业务业务中的checkout人。 | YES |  | 推断 |
| `remark` | `varchar(255)` | 标记 | 标记 | YES | NULL | DB/DDL/实体注释 |
| `saas_order_no` | `bigint` | 账单流水号 | 账单流水号 | YES | NULL | DB/DDL/实体注释 |
| `takeout_channel` | `int` | 外卖渠道 | 外卖渠道 | YES | NULL | DB/DDL/实体注释 |
| `checkout_time_name` | `varchar(32)` | 餐段 | 餐段 | YES | NULL | DB/DDL/实体注释 |
| `free_service_charge` | `tinyint` | 免服务费 | 免服务费 | YES | NULL | DB/DDL/实体注释 |
| `online` | `tinyint` | 线上订单 | 线上订单 | YES | NULL | DB/DDL/实体注释 |
| `department` | `varchar(255)` | 部门 | 部门 | YES | NULL | DB/DDL/实体注释 |
| `send_number` | `decimal(19, 10)` | 赠送数量 | 赠送数量 | YES | NULL | DB/DDL/实体注释 |
| `lmn_id` | `bigint` | lmnID | 业务业务关联的lmnID。 |  |  | 推断 |
| `ying_ye_ri_qi` | `datetime` | yingyeriqi | 业务业务中的yingyeriqi。 |  |  | 推断 |
| `pid_tmp` | `bigint` | pidtmp | 业务业务中的pidtmp。 |  |  | 推断 |
| `shi_fa_pid` | `bigint` | shifapid | 业务业务中的shifapid。 |  |  | 推断 |
| `shi_fa` | `CaiShiFaEx` | shifa | 业务业务中的shifa。 |  |  | 推断 |
| `cai_ping_zuo_fa_pid` | `varchar` | caipingzuofapid | 业务业务中的caipingzuofapid。 |  |  | 推断 |
| `cai_ping_zuo_fa_id` | `varchar` | caipingzuofaID | 业务业务关联的caipingzuofaID。 |  |  | 推断 |
| `yao_cheng_yu_shu_liang` | `tinyint(1)` | yaochengyushuliang | 业务业务中的yaochengyushuliang。 |  |  | 推断 |
| `shu_fu_wu_fei` | `tinyint(1)` | shufuwufei | 业务业务中的shufuwufei。 |  |  | 推断 |
| `can_yi_da_zhe` | `tinyint(1)` | canyidazhe | 业务业务中的canyidazhe。 |  |  | 推断 |
| `is_hand_writed` | `tinyint(1)` | ishandwrited | 标记业务业务是否启用或满足ishandwrited条件。 |  |  | 推断 |
| `bu_men` | `varchar` | bumen | 业务业务中的bumen。 |  |  | 推断 |
| `biao_qian` | `varchar` | biaoqian | 业务业务中的biaoqian。 |  |  | 推断 |
| `biao_qian_pid` | `varchar` | biaoqianpid | 业务业务中的biaoqianpid。 |  |  | 推断 |
| `biao_qian_id` | `varchar` | biaoqianID | 业务业务关联的biaoqianID。 |  |  | 推断 |
| `chu_ping_bu_men` | `varchar` | chupingbumen | 业务业务中的chupingbumen。 |  |  | 推断 |
| `is_yao_qiu` | `tinyint(1)` | isyaoqiu | 标记业务业务是否启用或满足isyaoqiu条件。 |  |  | 推断 |
| `xiao_fei_dan_id` | `varchar` | xiaofeidanID | 业务业务关联的xiaofeidanID。 |  |  | 推断 |
| `xiao_fei_cai_ping_id` | `varchar` | xiaofeicaipingID | 业务业务关联的xiaofeicaipingID。 |  |  | 推断 |
| `xiao_fei_cai_ping_pid` | `varchar` | xiaofeicaipingpid | 业务业务中的xiaofeicaipingpid。 |  |  | 推断 |

#### `pt_buffet`

- 真实表：`sc_buffet`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 菜品或商品业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Price` | `decimal(19,9)` | 价格 | 价格 | YES | NULL | DB/DDL/实体注释 |
| `MaxPrice` | `decimal(19,9)` | 价格上限 | 价格上限 | YES | NULL | DB/DDL/实体注释 |
| `CanYiDaZhe` | `tinyint` | 参与打折 | 参与打折 | YES | NULL | DB/DDL/实体注释 |

#### `pt_buffet_food`

- 真实表：`sc_dish_buffet`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：菜品或商品
- 表含义：菜品或商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `NAME` | `varchar(255)` | name | 菜品或商品业务对象的name。 | YES | NULL | 推断 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `Buffet` | `varchar(255)` | 自助餐 | 自助餐 | YES | NULL | DB/DDL/实体注释 |
| `buffet_code` | `bigint` | 自助餐lid | 自助餐lid | YES | NULL | DB/DDL/实体注释 |
| `Dish` | `varchar(255)` | 菜品 | 菜品 | YES | NULL | DB/DDL/实体注释 |
| `dish_code` | `bigint` | 菜品lid | 菜品lid | YES | NULL | DB/DDL/实体注释 |

### a_product

#### `pt_dish_overtime`

- 真实表：`pt_dish_overtime`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：商品超时设置
- 表含义：商品超时设置
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtDishOvertime.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `relate_lid` | `bigint` | 关联标识 | 关联标识 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 1菜品 2菜品小类 3菜品大类 | 类型 1菜品 2菜品小类 3菜品大类 | YES | NULL | DB/DDL/实体注释 |
| `side_over_time` | `int` | 配菜超时时间 | 配菜超时时间（分钟） | YES | NULL | DB/DDL/实体注释 |
| `cook_over_time` | `int` | 制作超时时间 | 制作超时时间（分钟） | YES | NULL | DB/DDL/实体注释 |
| `serve_over_time` | `int` | 传菜超时时间 | 传菜超时时间（分钟） | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 | 业务对象类型。 |  |  | 通用字段 |

#### `pt_image_compress`

- 真实表：`pt_image_compress`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：图片压缩记录
- 表含义：图片压缩记录
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtImageCompress.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 图片md5值 | 图片md5值 | YES | NULL | DB/DDL/实体注释 |
| `image_biz_type` | `int` | 业务类型 | 业务类型 | YES | NULL | DB/DDL/实体注释 |
| `origin_url` | `varchar(255)` | 源路径 | 源路径 | YES | NULL | DB/DDL/实体注释 |
| `target_url` | `varchar(255)` | 目标路径 | 目标路径 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `pt_x_spec_price`

- 真实表：`pt_x_spec_price`
- 数据源/库：`a_product` / `pt` / `172.16.0.144:3306`
- 表中文名：第X份特价
- 表含义：第X份特价
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtXSpecPrice.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品lid | 菜品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 价格 | 价格 | NO | NULL | DB/DDL/实体注释 |
| `start_val` | `decimal(24,6)` | 开始份数 | 开始份数 | NO | NULL | DB/DDL/实体注释 |
| `end_val` | `decimal(24,6)` | 结束份数 | 结束份数 | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `wx_merchant_config`

- 真实表：`sc_store_wx_info`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `company_name` | `varchar(255)` | companyname | 库存单据业务对象的companyname。 | YES | NULL | 推断 |
| `shop_name` | `varchar(255)` | 店铺name | 库存单据业务对象的店铺name。 | YES | NULL | 推断 |
| `authorizer_appid` | `varchar(255)` | authorizerappid | 库存单据业务中的authorizerappid。 | YES | NULL | 推断 |
| `authorizer_refresh_token` | `varchar(255)` | authorizerrefreshtoken | 库存单据业务中的authorizerrefreshtoken。 | YES | NULL | 推断 |
| `app_type` | `varchar(255)` | app类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `func_info` | `varchar(2048)` | funcinfo | 库存单据业务中的funcinfo。 | YES | NULL | 推断 |
| `qrcode_url` | `varchar(255)` | qrcodeurl | 库存单据业务对象的qrcodeurl。 | YES | NULL | 推断 |
| `nick_name` | `varchar(255)` | nickname | 库存单据业务对象的nickname。 | YES | NULL | 推断 |
| `service_type_info` | `varchar(255)` | 服务类型info | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `verify_type_info` | `varchar(255)` | verify类型info | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `user_name` | `varchar(255)` | username | 库存单据业务对象的username。 | YES | NULL | 推断 |
| `principal_name` | `varchar(255)` | principalname | 库存单据业务对象的principalname。 | YES | NULL | 推断 |
| `alias` | `varchar(255)` | alias | 库存单据业务中的alias。 | YES | NULL | 推断 |
| `bridge_model` | `int` | 对接模式 | 对接模式 | YES | NULL | DB/DDL/实体注释 |

### a_wms

#### `order_item_depart_relate`

- 真实表：`order_item_depart_relate`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：订货单物品与部门关联
- 表含义：订货单物品与部门关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 订货单类型 | 订货单类型 | NO | 1 | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `order_lid` | `bigint` | 订单lid | 订单lid | NO | NULL | DB/DDL/实体注释 |
| `depart_lid` | `bigint` | 部门lid | 部门lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 单据状态 | 单据状态 | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(90)` | 订单id | 订单id | YES | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | YES | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | YES | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,6)` | 原订货数量 | 原订货数量（标准单位） | NO | 0.000000 | DB/DDL/实体注释 |
| `inspect_volume` | `decimal(24,6)` | 验货数量 | 验货数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,6)` | 原金额 | 原金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `inspect_amount` | `decimal(24,6)` | 验货金额 | 验货金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `inspect` | `tinyint(1)` | 是否验货 | 是否验货 | NO | 0 | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,6)` | 计量数量 | 计量数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `reject` | `tinyint(1)` | 拒收 | 拒收 | YES | 0 | DB/DDL/实体注释 |
| `reject_by` | `varchar(90)` | 拒收人 | 拒收人 | YES | NULL | DB/DDL/实体注释 |
| `reject_at` | `datetime` | 拒收时间 | 拒收时间 | YES | NULL | DB/DDL/实体注释 |
| `reject_for` | `varchar(255)` | 拒收原因 | 拒收原因 | YES | NULL | DB/DDL/实体注释 |
| `cancel` | `tinyint(1)` | 取消 | 取消 | YES | 0 | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_at` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `cancel_for` | `varchar(255)` | 取消原因 | 取消原因 | YES | NULL | DB/DDL/实体注释 |
| `refund_state` | `int` | 退货状态 | 退货状态 | YES | 0 | DB/DDL/实体注释 |
| `refund_volume` | `decimal(24,6)` | 退货数量 | 退货数量 | YES | NULL | DB/DDL/实体注释 |
| `refund_by` | `varchar(255)` | 退货人 | 退货人 | YES | NULL | DB/DDL/实体注释 |
| `refund_at` | `varchar(255)` | 退货时间 | 退货时间 | YES | NULL | DB/DDL/实体注释 |
| `refund_for` | `varchar(255)` | 退货原因 | 退货原因 | YES | NULL | DB/DDL/实体注释 |
| `refund_id` | `varchar(255)` | 退货单号 | 退货单号 | YES | NULL | DB/DDL/实体注释 |
| `scarce` | `tinyint(1)` | 缺货 | 缺货 | YES | 0 | DB/DDL/实体注释 |
| `inbound_lid` | `bigint` | 入库单lid | 入库单lid | YES | NULL | DB/DDL/实体注释 |
| `inbound_id` | `varchar(255)` | inboundID | 订单业务关联的inboundID。 | YES | NULL | 推断 |
| `inspect_indent_volume` | `decimal(24,6)` | 订购验货数量 | 订购验货数量 | YES | NULL | DB/DDL/实体注释 |
| `adjust_volume` | `decimal(19,10)` | 调整量 | 调整量 | YES | NULL | DB/DDL/实体注释 |

#### `sc_assist_cost`

- 真实表：`sc_assist_cost`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：辅助成本定义
- 表含义：辅助成本定义
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_auto_deduct_task`

- 真实表：`sc_auto_deduct_task`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：自动扣减记录（用于反扣减冲红）
- 表含义：自动扣减记录（用于反扣减冲红）
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 扣减仓库lid | 扣减仓库lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 库存单据lid | 库存单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(32)` | 库存单据id | 库存单据id | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 扣减数量 | 扣减数量 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 扣减金额 | 扣减金额 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `source_type` | `int` | 来源类型 | 来源类型 | YES | 0 | DB/DDL/实体注释 |

#### `sc_bill_invoice_order`

- 真实表：`sc_bill_invoice_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：单据发票记录
- 表含义：单据发票记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 记账日期 | 记账日期 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `invoice_type` | `int` | 发票类型 | 发票类型 | NO | NULL | DB/DDL/实体注释 |
| `invoice_no` | `varchar(90)` | 发票号码 | 发票号码 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 发票备注 | 发票备注 | YES | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_lid` | `bigint` | 取消人lid | 取消人lid | YES | NULL | DB/DDL/实体注释 |
| `cancel_time` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `settle_type` | `int` | 结算类型 | 结算类型 | NO | 1 | DB/DDL/实体注释 |

#### `sc_bill_invoice_ref`

- 真实表：`sc_bill_invoice_ref`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：发票记录与单据关联
- 表含义：发票记录与单据关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 记账日期 | 记账日期 | NO | NULL | DB/DDL/实体注释 |
| `invoice_order_lid` | `bigint` | 发票记录lid | 发票记录lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 仓库单据lid | 仓库单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(90)` | 仓库单据id | 仓库单据id | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 发票金额 | 发票金额 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_bill_pay_item`

- 真实表：`sc_bill_pay_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：单据付款记录
- 表含义：单据付款记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 付款日期 | 付款日期 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 付款名称 | 付款名称 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 仓库单据lid | 仓库单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(90)` | 仓库单据id | 仓库单据id | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 付款类型 | 付款类型 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 核销金额 | 核销金额 | NO | NULL | DB/DDL/实体注释 |
| `balance_before` | `decimal(24,6)` | 核销前金额 | 核销前金额 | NO | NULL | DB/DDL/实体注释 |
| `balance_after` | `decimal(24,6)` | 核销后金额 | 核销后金额 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 付款备注 | 付款备注 | YES | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_lid` | `bigint` | 取消人lid | 取消人lid | YES | NULL | DB/DDL/实体注释 |
| `cancel_time` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `bill_type` | `int` | 单据类型 | 单据类型 | NO | 1 | DB/DDL/实体注释 |
| `settle_type` | `int` | 结算类型 | 结算类型 | NO | 1 | DB/DDL/实体注释 |
| `bill_remark` | `varchar(255)` | 单备注 | 单备注 | YES | NULL | DB/DDL/实体注释 |

#### `sc_bill_stock`

- 真实表：`sc_bill_stock`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：账单库存预扣减
- 表含义：账单库存预扣减
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year_` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month_` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day_` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 账单编号 | 账单编号 | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 扣减数量 | 扣减数量 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counter` | `decimal(24,6)` | 扣减计数数量 | 扣减计数数量 | NO | 0.000000 | DB/DDL/实体注释 |

#### `sc_check_prohibit`

- 真实表：`sc_check_prohibit`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：盘点禁用物品
- 表含义：盘点禁用物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |

#### `sc_check_template`

- 真实表：`sc_check_template`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：盘点模板
- 表含义：盘点模板
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 盘点模板名称 | 盘点模板名称 | NO | NULL | DB/DDL/实体注释 |
| `rows_` | `int` | 物品数量 | 物品数量 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_check_template_item`

- 真实表：`sc_check_template_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：盘点模板物品
- 表含义：盘点模板物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `template_lid` | `bigint` | 模板lid | 模板lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_id` | `varchar(32)` | 物品编号 | 物品编号 | YES | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(90)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 标准数量 | 标准数量 | YES | NULL | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,6)` | 计量数量 | 计量数量 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_client`

- 真实表：`sc_client`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：供应链或基础资料
- 表含义：供应链或基础资料相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `client_type` | `varchar(255)` | client类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `client_type_code` | `varchar(255)` | client类型code | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `principal` | `varchar(255)` | principal | 供应链或基础资料业务中的principal。 | YES | NULL | 推断 |
| `phone` | `varchar(255)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `tel` | `varchar(255)` | tel | 供应链或基础资料业务中的tel。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | addr | 供应链或基础资料业务中的addr。 | YES | NULL | 推断 |
| `email` | `varchar(255)` | email | 供应链或基础资料业务中的email。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 供应链或基础资料业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 供应链或基础资料业务中的create时间。 | YES | NULL | 推断 |
| `logo` | `varchar(255)` | logo | 供应链或基础资料业务中的logo。 | YES | NULL | 推断 |
| `remarks` | `varchar(255)` | remarks | 供应链或基础资料业务中的remarks。 | YES | NULL | 推断 |
| `province` | `varchar(255)` | province | 供应链或基础资料业务中的province。 | YES | NULL | 推断 |
| `province_code` | `varchar(255)` | provincecode | 供应链或基础资料业务对象的provincecode。 | YES | NULL | 推断 |
| `city` | `varchar(255)` | city | 供应链或基础资料业务中的city。 | YES | NULL | 推断 |
| `city_code` | `varchar(255)` | citycode | 供应链或基础资料业务对象的citycode。 | YES | NULL | 推断 |
| `county` | `varchar(255)` | county | 供应链或基础资料业务中的county。 | YES | NULL | 推断 |
| `county_code` | `varchar(255)` | countycode | 供应链或基础资料业务对象的countycode。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 供应链或基础资料业务中的disable。 | YES | NULL | 推断 |
| `enable_on_line_mall` | `tinyint` | enableonlinemall | 供应链或基础资料业务中的enableonlinemall。 | YES | NULL | 推断 |
| `qualification_photo` | `varchar(255)` | qualificationphoto | 供应链或基础资料业务中的qualificationphoto。 | YES | NULL | 推断 |
| `quarantine_report_photo` | `varchar(255)` | quarantinereportphoto | 供应链或基础资料业务中的quarantinereportphoto。 | YES | NULL | 推断 |
| `tax_rate` | `decimal(19,10)` | tax比例 | 供应链或基础资料业务中的tax比例。 | YES | NULL | 推断 |
| `tax_code` | `varchar(255)` | taxcode | 供应链或基础资料业务对象的taxcode。 | YES | NULL | 推断 |
| `bank` | `varchar(255)` | bank | 供应链或基础资料业务中的bank。 | YES | NULL | 推断 |
| `card_of_bank` | `varchar(255)` | 会员卡ofbank | 供应链或基础资料业务中的会员卡ofbank。 | YES | NULL | 推断 |
| `billing_period_type` | `varchar(255)` | billingperiod类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `expiry_day_of_qualification` | `datetime` | 有效期dayofqualification | 供应链或基础资料业务中的有效期dayofqualification。 | YES | NULL | 推断 |
| `commit_audit_time` | `datetime` | commitaudit时间 | 供应链或基础资料业务中的commitaudit时间。 | YES | NULL | 推断 |
| `audit_time` | `datetime` | audit时间 | 供应链或基础资料业务中的audit时间。 | YES | NULL | 推断 |
| `reviewer` | `varchar(255)` | reviewer | 供应链或基础资料业务中的reviewer。 | YES | NULL | 推断 |
| `audit_status` | `varchar(255)` | audit状态 | 供应链或基础资料处理状态或启停状态。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_client_type`

- 真实表：`sc_client_type`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：供应链或基础资料
- 表含义：供应链或基础资料相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `disable` | `tinyint` | disable | 供应链或基础资料业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |

### a_wms

#### `sc_deduct_day`

- 真实表：`sc_deduct_day`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：有未扣减记录天数
- 表含义：有未扣减记录天数
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 日期 | 日期 | NO | NULL | DB/DDL/实体注释 |
| `deducted` | `tinyint(1)` | 是否扣减 | 是否扣减 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_deduct_goods`

- 真实表：`sc_deduct_goods`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：单据商品扣库详情
- 表含义：单据商品扣库详情
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(90)` | 门店名称 | 门店名称 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year_` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month_` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day_` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 库存单据lid | 库存单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(90)` | 库存单据id | 库存单据id | NO | NULL | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 账单编号 | 账单编号 | NO | NULL | DB/DDL/实体注释 |
| `profit_lid` | `bigint` | 毛利表lid,保留字段 | 毛利表lid,保留字段 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 扣减组织 | 扣减组织 | YES | NULL | DB/DDL/实体注释 |
| `organ_name` | `varchar(90)` | 扣减组织名称 | 扣减组织名称 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_lid` | `bigint` | 区域lid | 区域lid | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_id` | `varchar(90)` | 区域编号 | 区域编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_name` | `varchar(90)` | 区域名称 | 区域名称 | YES | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(90)` | 商品编号 | 商品编号 | NO | NULL | DB/DDL/实体注释 |
| `product_name` | `varchar(255)` | 商品名称 | 商品名称 | YES | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(90)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `product_idx` | `int` | 商品索引 | 商品索引 | NO | NULL | DB/DDL/实体注释 |
| `product_volume` | `decimal(24,6)` | 商品数量 | 商品数量 | NO | 1.000000 | DB/DDL/实体注释 |
| `product_amount` | `decimal(24,6)` | 商品金额 | 商品金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(90)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `goods_unit` | `varchar(90)` | 物品单位 | 物品单位 | NO | NULL | DB/DDL/实体注释 |
| `standard_unit` | `varchar(90)` | 标准单位 | 标准单位 | YES | NULL | DB/DDL/实体注释 |
| `goods_unit_lid` | `bigint` | 物品单位lid | 物品单位lid | NO | NULL | DB/DDL/实体注释 |
| `theory_volume` | `decimal(24,6)` | 理论用量 | 理论用量 | YES | 0.000000 | DB/DDL/实体注释 |
| `actual_volume` | `decimal(24,6)` | 实际用量 | 实际用量 | YES | 0.000000 | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,6)` | 计量数量 | 计量数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `diff_volume` | `decimal(24,6)` | 用量差异 | 用量差异 | YES | 0.000000 | DB/DDL/实体注释 |
| `theory_cost` | `decimal(24,6)` | 理论成本 | 理论成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `actual_cost` | `decimal(24,6)` | 实际成本 | 实际成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `wastage_cost` | `decimal(24,6)` | 耗损成本 | 耗损成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `diff_cost` | `decimal(24,6)` | 成本差异 | 成本差异 | YES | 0.000000 | DB/DDL/实体注释 |
| `net_rate` | `decimal(24,6)` | 出净率 | 出净率 | YES | NULL | DB/DDL/实体注释 |
| `net_weight` | `decimal(24,6)` | 净料重量 | 净料重量 | YES | NULL | DB/DDL/实体注释 |
| `yield_rate` | `decimal(24,6)` | 出成率 | 出成率 | YES | NULL | DB/DDL/实体注释 |
| `cooked_weight` | `decimal(24,6)` | 熟菜重量 | 熟菜重量 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 扣库单位类型 | 扣库单位类型 | YES | NULL | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 商品小类lid | 商品小类lid | YES | NULL | DB/DDL/实体注释 |
| `small_type` | `varchar(90)` | 商品小类名称 | 商品小类名称 | YES | NULL | DB/DDL/实体注释 |
| `super_type_lid` | `bigint` | 商品大类lid | 商品大类lid | YES | NULL | DB/DDL/实体注释 |
| `super_type` | `varchar(90)` | 商品大类名称 | 商品大类名称 | YES | NULL | DB/DDL/实体注释 |
| `source_type` | `int` | 来源类型 | 来源类型 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_deduct_rule`

- 真实表：`sc_deduct_rule`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品扣减规则
- 表含义：菜品扣减规则
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `relate_id` | `varchar(90)` | 商品/小类/大类的id | 商品/小类/大类的id | NO | NULL | DB/DDL/实体注释 |
| `relate_lid` | `bigint` | 商品/小类/大类的lid | 商品/小类/大类的lid | NO | NULL | DB/DDL/实体注释 |
| `tbl_area_id` | `varchar(32)` | 台区id | 台区id | NO | NULL | DB/DDL/实体注释 |
| `tbl_area_lid` | `bigint` | 台区lid | 台区lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 要扣减的组织lid | 要扣减的组织lid | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型，1 商品 2小类 3 大类 | 类型，1 商品 2小类 3 大类 | NO | 1 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_delivery_order`

- 真实表：`sc_delivery_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送报价单
- 表含义：配送报价单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 单据编号 | 单据编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `is_suit_all` | `tinyint(1)` | 全统一/部分例外 | 全统一/部分例外 | NO | 1 | DB/DDL/实体注释 |
| `quote_state` | `int` | 报价状态 | 报价状态 | NO | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(255)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `release_lid` | `bigint` | 发布人lid | 发布人lid | YES | NULL | DB/DDL/实体注释 |
| `release_by` | `varchar(255)` | 发布人 | 发布人 | YES | NULL | DB/DDL/实体注释 |
| `release_time` | `datetime` | 发布时间 | 发布时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_delivery_order_item`

- 真实表：`sc_delivery_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送报价物品
- 表含义：配送报价物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `goods_type_lid` | `bigint` | 物品类别lid | 物品类别lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 报价 | 报价 | NO | NULL | DB/DDL/实体注释 |
| `added_tax_type` | `int` | 采购税率 | 采购税率 | NO | NULL | DB/DDL/实体注释 |
| `last_price` | `decimal(24,6)` | 上期价格 | 上期价格 | YES | NULL | DB/DDL/实体注释 |
| `last_order_price` | `decimal(24,6)` | 最近一次进货价 | 最近一次进货价 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 价格生效日期 | 价格生效日期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 价格失效日期 | 价格失效日期 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | YES | 1 | DB/DDL/实体注释 |

#### `sc_delivery_order_store`

- 真实表：`sc_delivery_order_store`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送报价单适用组织
- 表含义：配送报价单适用组织
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 适用门店sid | 适用门店sid | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_delivery_quote`

- 真实表：`sc_delivery_quote`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送协议价
- 表含义：配送协议价
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_type_lid` | `bigint` | 物品类别lid | 物品类别lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 售价/加价/比例系数 | 售价/加价/比例系数 | NO | NULL | DB/DDL/实体注释 |
| `last_order_price` | `varchar(255)` | 上次进货单价 | 上次进货单价 | YES | 0 | DB/DDL/实体注释 |
| `final_price` | `decimal(24,6)` | 最终价格 | 最终价格 | NO | 0.000000 | DB/DDL/实体注释 |
| `added_tax_type` | `int` | 采购税率 | 采购税率 | NO | NULL | DB/DDL/实体注释 |
| `incr_type` | `int` | 加价方式 | 加价方式 | NO | NULL | DB/DDL/实体注释 |
| `is_suit_all` | `tinyint(1)` | 是否统一 | 是否统一 | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 价格生效日期 | 价格生效日期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 价格失效日期 | 价格失效日期 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | YES | 1 | DB/DDL/实体注释 |

#### `sc_delivery_rule`

- 真实表：`sc_delivery_rule`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送规则
- 表含义：配送规则
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 适用门店lid | 适用门店lid | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | NO | NULL | DB/DDL/实体注释 |
| `def_supplier_lid` | `bigint` | 默认供应商lid | 默认供应商lid | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 采购价格 | 采购价格 | NO | NULL | DB/DDL/实体注释 |
| `added_tax_type` | `int` | 采购税率 | 采购税率 | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 价格生效日期 | 价格生效日期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 价格失效日期 | 价格失效日期 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | YES | 1 | DB/DDL/实体注释 |

#### `sc_depart_order`

- 真实表：`sc_depart_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：档口订货单
- 表含义：档口订货单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `store_order_id` | `varchar(90)` | 门店订货单编号 | 门店订货单编号 | YES | NULL | DB/DDL/实体注释 |
| `store_order_lid` | `bigint` | 门店订货单lid | 门店订货单lid | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 记录数 | 记录数 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 总数量 | 总数量 | NO | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(24,6)` | 含税金额 | 含税金额 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,6)` | 订购数量 | 订购数量 | NO | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `reject_lid` | `bigint` | 驳回人lid | 驳回人lid | YES | NULL | DB/DDL/实体注释 |
| `reject_by` | `varchar(90)` | 驳回人 | 驳回人 | YES | NULL | DB/DDL/实体注释 |
| `reject_time` | `datetime` | 驳回时间 | 驳回时间 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_depart_order_item`

- 真实表：`sc_depart_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：档口订货物品
- 表含义：档口订货物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `depart_order_lid` | `bigint` | 档口订货单lid | 档口订货单lid | NO | NULL | DB/DDL/实体注释 |
| `depart_order_id` | `varchar(90)` | 档口订货单编号 | 档口订货单编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,10)` | 数量 | 数量 | YES | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,10)` | 订单数量 | 订单数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,10)` | 单价 | 单价 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,10)` | 金额 | 金额 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,10)` | 税率 | 税率 | YES | NULL | DB/DDL/实体注释 |
| `arrival_time` | `datetime` | 到货日期 | 到货日期 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `indent_price` | `decimal(24,10)` | 订购价 | 订购价 | YES | NULL | DB/DDL/实体注释 |

#### `sc_goods`

- 真实表：`sc_goods`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品
- 表含义：物品
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 物品编号 | 物品编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 物品名称 | 物品名称 | NO | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 启用/禁用 | 启用/禁用 | YES | NULL | DB/DDL/实体注释 |
| `goods_type_lid` | `bigint` | 物品类型lid | 物品类型lid | NO | NULL | DB/DDL/实体注释 |
| `mnemonic_code` | `varchar(255)` | 助记码 | 助记码 | YES | NULL | DB/DDL/实体注释 |
| `standards` | `varchar(255)` | 物品规格 | 物品规格 | YES | NULL | DB/DDL/实体注释 |
| `reference_price` | `decimal(24,6)` | 参考价 | 参考价 | YES | NULL | DB/DDL/实体注释 |
| `subject_type` | `int` | 统计科目 | 统计科目 | YES | NULL | DB/DDL/实体注释 |
| `check_in_type` | `int` | 盘点频率 | 盘点频率 | YES | NULL | DB/DDL/实体注释 |
| `indent` | `tinyint(1)` | 可订货 | 可订货 | YES | NULL | DB/DDL/实体注释 |
| `min_indent` | `decimal(24,6)` | 最小订购量 | 最小订购量 | YES | NULL | DB/DDL/实体注释 |
| `single_indent` | `decimal(24,6)` | 单次订购量 | 单次订购量 | YES | NULL | DB/DDL/实体注释 |
| `refund` | `tinyint(1)` | 可退货 | 可退货 | YES | NULL | DB/DDL/实体注释 |
| `inbound` | `tinyint(1)` | 可入库 | 可入库 | YES | NULL | DB/DDL/实体注释 |
| `min_indent_multiple` | `decimal(24,6)` | 最小订货单位倍数 | 最小订货单位倍数 | YES | NULL | DB/DDL/实体注释 |
| `check_in_order` | `tinyint(1)` | 订货校验库存 | 订货校验库存 | YES | NULL | DB/DDL/实体注释 |
| `safety_upper` | `decimal(24,6)` | 安全库存上限 | 安全库存上限 | YES | NULL | DB/DDL/实体注释 |
| `safety_lower` | `decimal(24,6)` | 安全库存下限 | 安全库存下限 | YES | NULL | DB/DDL/实体注释 |
| `mandatory` | `tinyint(1)` | 必订物品 | 必订物品 | YES | NULL | DB/DDL/实体注释 |
| `weight` | `tinyint(1)` | 称重物品 | 称重物品 | YES | NULL | DB/DDL/实体注释 |
| `loss_rate` | `decimal(24,6)` | 损耗率 | 损耗率 | YES | NULL | DB/DDL/实体注释 |
| `expiry` | `tinyint(1)` | 保质期 | 保质期 | YES | NULL | DB/DDL/实体注释 |
| `expiry_day` | `int` | 保质期 | 保质期（天） | YES | NULL | DB/DDL/实体注释 |
| `reminder_day` | `int` | 提前提醒天数 | 提前提醒天数 | YES | NULL | DB/DDL/实体注释 |
| `in_expiry_day` | `int` | 入库保质期临期天数 | 入库保质期临期天数 | YES | NULL | DB/DDL/实体注释 |
| `out_expiry_day` | `int` | 出库保质期临期天数 | 出库保质期临期天数 | YES | NULL | DB/DDL/实体注释 |
| `batch_manage` | `tinyint(1)` | 批次管理 | 批次管理 | YES | NULL | DB/DDL/实体注释 |
| `expend` | `tinyint(1)` | 入库即耗用 | 入库即耗用 | YES | NULL | DB/DDL/实体注释 |
| `sn_manage` | `tinyint(1)` | SN码管理 | SN码管理 | YES | NULL | DB/DDL/实体注释 |
| `inspect_type` | `int` | 验货比率 | 验货比率 | YES | NULL | DB/DDL/实体注释 |
| `tolerance_percent` | `int` | 验货容差百分比 | 验货容差百分比 | YES | NULL | DB/DDL/实体注释 |
| `tolerance_up_percent` | `int` | 验货向上容差百分比 | 验货向上容差百分比 | YES | NULL | DB/DDL/实体注释 |
| `tolerance_down_percent` | `int` | 验货向下容差百分比 | 验货向下容差百分比 | YES | NULL | DB/DDL/实体注释 |
| `tax_code` | `varchar(255)` | 税收分类编码 | 税收分类编码 | YES | NULL | DB/DDL/实体注释 |
| `tax_type` | `int` | 税率 | 税率 | YES | NULL | DB/DDL/实体注释 |
| `label_lid` | `bigint` | 标签lid | 标签lid | YES | NULL | DB/DDL/实体注释 |
| `producer` | `varchar(255)` | 产地 | 产地 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `storage_factor` | `varchar(255)` | 储存条件 | 储存条件 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `is_suit_all` | `tinyint(1)` | 适用所有店铺 | 适用所有店铺 | NO | NULL | DB/DDL/实体注释 |
| `shelve` | `tinyint(1)` | 上/下架 | 上/下架 | NO | 1 | DB/DDL/实体注释 |
| `indent_decimal` | `tinyint(1)` | 订货允许小数 | 订货允许小数 | NO | 1 | DB/DDL/实体注释 |
| `last_order_price` | `decimal(24,6)` | 最近订货价 | 最近订货价 | NO | 0.000000 | DB/DDL/实体注释 |
| `pinyin` | `varchar(128)` | 拼音 | 拼音 | YES | NULL | DB/DDL/实体注释 |
| `last_out_price` | `decimal(24,6)` | 最后出库单价 | 最后出库单价 | NO | 0.000000 | DB/DDL/实体注释 |
| `indent_by_counting` | `tinyint(1)` | 通过计量做订购 | 通过计量做订购 | NO | 0 | DB/DDL/实体注释 |
| `last_price_date` | `datetime` | 最后一次价格订单日期 | 最后一次价格订单日期 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `goods_type` | `varchar(255)` | goods类型 | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `goods_type_code` | `varchar(255)` | goods类型code | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `hot_code` | `varchar(255)` | hotcode | 库存商品业务对象的hotcode。 | YES | NULL | 推断 |
| `standard` | `varchar(255)` | standard | 库存商品业务中的standard。 | YES | NULL | 推断 |
| `domestic` | `tinyint` | domestic | 库存商品业务中的domestic。 | YES | NULL | 推断 |
| `nation` | `varchar(255)` | nation | 库存商品业务中的nation。 | YES | NULL | 推断 |
| `nation_code` | `varchar(255)` | nationcode | 库存商品业务对象的nationcode。 | YES | NULL | 推断 |
| `province` | `varchar(255)` | province | 库存商品业务中的province。 | YES | NULL | 推断 |
| `province_code` | `varchar(255)` | provincecode | 库存商品业务对象的provincecode。 | YES | NULL | 推断 |
| `city` | `varchar(255)` | city | 库存商品业务中的city。 | YES | NULL | 推断 |
| `city_code` | `varchar(255)` | citycode | 库存商品业务对象的citycode。 | YES | NULL | 推断 |
| `county` | `varchar(255)` | county | 库存商品业务中的county。 | YES | NULL | 推断 |
| `county_code` | `varchar(255)` | countycode | 库存商品业务对象的countycode。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 库存商品业务中的disable。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 库存商品业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 库存商品业务中的create时间。 | YES | NULL | 推断 |
| `modified_by` | `varchar(255)` | modified人 | 库存商品业务中的modified人。 | YES | NULL | 推断 |
| `modified_time` | `datetime` | modified时间 | 库存商品业务中的modified时间。 | YES | NULL | 推断 |
| `description` | `varchar(255)` | 说明 | 库存商品业务中的说明。 | YES | NULL | 推断 |
| `minimum_order` | `decimal(19, 10)` | minimum订单 | 库存商品业务中的minimum订单。 | YES | NULL | 推断 |
| `minimum_order_once` | `decimal(19, 10)` | minimum订单once | 库存商品业务中的minimum订单once。 | YES | NULL | 推断 |
| `must_order` | `tinyint` | must订单 | 库存商品业务中的must订单。 | YES | NULL | 推断 |
| `minimum_order_unit_multiples` | `decimal(19, 10)` | minimum订单单位multiples | 库存商品业务中的minimum订单单位multiples。 | YES | NULL | 推断 |
| `maxmun_safety` | `decimal(19, 10)` | maxmunsafety | 库存商品业务中的maxmunsafety。 | YES | NULL | 推断 |
| `minimun_safety` | `decimal(19, 10)` | minimunsafety | 库存商品业务中的minimunsafety。 | YES | NULL | 推断 |
| `reminder_days_in_advance` | `int` | reminderdaysinadvance | 库存商品业务中的reminderdaysinadvance。 | YES | NULL | 推断 |
| `attrition_rate` | `decimal(19, 10)` | attrition比例 | 库存商品业务中的attrition比例。 | YES | NULL | 推断 |
| `enable_shelf_life` | `tinyint` | enableshelflife | 库存商品业务中的enableshelflife。 | YES | NULL | 推断 |
| `shelf_life` | `int` | shelflife | 库存商品业务中的shelflife。 | YES | NULL | 推断 |
| `in_shelf_life` | `int` | inshelflife | 库存商品业务中的inshelflife。 | YES | NULL | 推断 |
| `out_shelf_life` | `int` | outshelflife | 库存商品业务中的outshelflife。 | YES | NULL | 推断 |
| `tax_rate` | `decimal(19, 10)` | tax比例 | 库存商品业务中的tax比例。 | YES | NULL | 推断 |
| `consume_while_buy` | `tinyint` | 消费whilebuy | 库存商品业务中的消费whilebuy。 | YES | NULL | 推断 |
| `enable_batch` | `tinyint` | enablebatch | 库存商品业务中的enablebatch。 | YES | NULL | 推断 |
| `enable_sn` | `tinyint` | enablesn | 库存商品业务中的enablesn。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |
| `in_transit_quantity` | `decimal(19, 10)` | 在途数量 | 在途数量 | YES | NULL | DB/DDL/实体注释 |
| `last_transit_time` | `datetime` | 最后在途时间 | 最后在途时间 | YES | NULL | DB/DDL/实体注释 |
| `last_receipt_time` | `datetime` | 最后入库时间 | 最后入库时间 | YES | NULL | DB/DDL/实体注释 |
| `img_url` | `varchar(128)` | 物品图片 | 物品图片 | YES | NULL | DB/DDL/实体注释 |

#### `sc_goods_img`

- 真实表：`sc_goods_img`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品与图片关联
- 表含义：物品与图片关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `img_url` | `varchar(255)` | 物品图片地址 | 物品图片地址 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品Lid | 物品Lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_goods_in_department`

- 真实表：`sc_goods_in_department`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存商品
- 表含义：库存商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `goods` | `varchar(255)` | goods | 库存商品业务中的goods。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存商品业务中的department。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | 库存商品业务中的价格。 | YES | NULL | 推断 |
| `volume` | `decimal(19,10)` | volume | 库存商品业务中的volume。 | YES | NULL | 推断 |
| `bill_id` | `varchar(255)` | 账单ID | 库存商品业务关联的账单ID。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存商品业务对象的goodscode。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存商品业务对象的departmentcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |

### a_wms

#### `sc_goods_in_warehouse`

- 真实表：`sc_goods_in_warehouse`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品仓库库存
- 表含义：物品仓库库存
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 库存价格 | 库存价格 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 当前数量 | 当前数量 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 当前金额 | 当前金额 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 单据lid | 单据lid | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 物品的lid | 物品的lid | NO | NULL | DB/DDL/实体注释 |
| `last_stock_time` | `datetime` | 入库时间 | 入库时间 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counting` | `decimal(24,6)` | 当前数量 | 当前数量 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `goods` | `varchar(255)` | goods | 库存商品业务中的goods。 | YES | NULL | 推断 |
| `bill_id` | `varchar(255)` | 账单ID | 库存商品业务关联的账单ID。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存商品业务对象的goodscode。 | YES | NULL | 推断 |
| `Warehouse` | `varchar(255)` | warehouse | 库存商品业务中的warehouse。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存商品业务对象的warehousecode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |
| `Owner_shop` | `varchar(255)` | owner店铺 | 库存商品业务中的owner店铺。 | YES | NULL | 推断 |
| `owner_shop_id` | `bigint` | owner店铺ID | 库存商品业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `Super_dish_type` | `varchar(255)` | super菜品类型 | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `Super_dish_type_code` | `bigint` | super菜品类型code | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `Dish_type` | `varchar(255)` | 菜品类型 | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `Dish_type_code` | `bigint` | 菜品类型code | 库存商品业务分类或类型。 | YES | NULL | 推断 |
| `Inventory_time` | `datetime` | inventory时间 | 库存商品业务中的inventory时间。 | YES | NULL | 推断 |

### gylregdb

#### `sc_goods_route_rule`

- 真实表：`sc_goods_route_rule`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存商品
- 表含义：库存商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_goods_sales_delivery_record`

- 真实表：`sc_goods_sales_delivery_record`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存商品
- 表含义：库存商品相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存商品业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 库存商品业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 库存商品业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 库存商品业务中的day。 | YES | NULL | 推断 |
| `owner_shop` | `varchar(255)` | owner店铺 | 库存商品业务中的owner店铺。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存商品业务中的goods。 | YES | NULL | 推断 |
| `volume` | `decimal(19,10)` | volume | 库存商品业务中的volume。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 库存商品业务中的create时间。 | YES | NULL | 推断 |
| `reduce_status` | `int` | reduce状态 | 库存商品处理状态或启停状态。 | YES | NULL | 推断 |
| `deal_time` | `datetime` | deal时间 | 库存商品业务中的deal时间。 | YES | NULL | 推断 |
| `request_id` | `varchar(255)` | 请求ID | 库存商品业务关联的请求ID。 | YES | NULL | 推断 |
| `begin_volume` | `decimal(19,10)` | 开始volume | 库存商品业务中的开始volume。 | YES | NULL | 推断 |
| `end_volume` | `decimal(19,10)` | 结束volume | 库存商品业务中的结束volume。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存商品业务中的warehouse。 | YES | NULL | 推断 |
| `Owner_shop_id` | `bigint` | owner店铺ID | 库存商品业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存商品业务对象的goodscode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存商品业务对象的warehousecode。 | YES | NULL | 推断 |

### a_wms

#### `sc_goods_store`

- 真实表：`sc_goods_store`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品门店关联
- 表含义：物品门店关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `store_lid` | `bigint` | 门店sid | 门店sid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_goods_type`

- 真实表：`sc_goods_type`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品类型
- 表含义：物品类型
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 编码 | 编码 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `parent_lid` | `bigint` | 上一级 | 上一级 | YES | NULL | DB/DDL/实体注释 |
| `level` | `int` | 层级 | 层级 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `superior` | `varchar(255)` | superior | 库存商品业务中的superior。 | YES | NULL | 推断 |
| `superior_code` | `varchar(255)` | superiorcode | 库存商品业务对象的superiorcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_goods_unit`

- 真实表：`sc_goods_unit`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品单位
- 表含义：物品单位
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 单位名称 | 单位名称 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品Lid | 物品Lid | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid(备用) | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 单位类型 | 单位类型 | NO | NULL | DB/DDL/实体注释 |
| `bar_code` | `varchar(64)` | 条码 | 条码 | YES | NULL | DB/DDL/实体注释 |
| `org_ratio` | `decimal(24,6)` | 标准单位数量 | 标准单位数量 | NO | NULL | DB/DDL/实体注释 |
| `ratio` | `decimal(24,6)` | 当前单位数量 | 当前单位数量 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `for_counting` | `tinyint(1)` | 用于计数 | 用于计数 | YES | NULL | DB/DDL/实体注释 |
| `generate` | `tinyint(1)` | 已产生单据 | 已产生单据 | YES | 0 | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `goods` | `varchar(255)` | goods | 库存商品业务中的goods。 | YES | NULL | 推断 |
| `goods_code` | `varchar(255)` | goodscode | 库存商品业务对象的goodscode。 | YES | NULL | 推断 |
| `conversion_rate` | `decimal(19, 10)` | conversion比例 | 库存商品业务中的conversion比例。 | YES | NULL | 推断 |
| `for_standard` | `tinyint` | forstandard | 库存商品业务中的forstandard。 | YES | NULL | 推断 |
| `for_order` | `tinyint` | for订单 | 库存商品业务中的for订单。 | YES | NULL | 推断 |
| `for_cost` | `tinyint` | forcost | 库存商品业务中的forcost。 | YES | NULL | 推断 |
| `for_stock` | `tinyint` | forstock | 库存商品业务中的forstock。 | YES | NULL | 推断 |
| `for_assist` | `tinyint` | forassist | 库存商品业务中的forassist。 | YES | NULL | 推断 |
| `barcode` | `varchar(255)` | barcode | 库存商品业务对象的barcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存商品业务中的pidtmp。 | YES | NULL | 推断 |
| `used_stock` | `tinyint` | 是否已产生库存 | 是否已产生库存 | YES | NULL | DB/DDL/实体注释 |

#### `sc_history_order`

- 真实表：`sc_history_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：最后一次订单记录
- 表含义：最后一次订单记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `uid` | `bigint` | 用户编号 | 用户编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 记录数 | 记录数 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 总数量 | 总数量 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(24,6)` | 含税金额 | 含税金额 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_history_order_item`

- 真实表：`sc_history_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：最后一次订单物品记录
- 表含义：最后一次订单物品记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `uid` | `bigint` | 用户编号 | 用户编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `history_order_lid` | `bigint` | 订单lid | 订单lid | NO | NULL | DB/DDL/实体注释 |
| `history_order_id` | `varchar(90)` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 订购数量 | 订购数量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 订购价格 | 订购价格 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 订购总额 | 订购总额 | NO | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,6)` | 税率 | 税率 | NO | NULL | DB/DDL/实体注释 |
| `arrival_time` | `datetime` | 到货日期 | 到货日期 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_history_remark`

- 真实表：`sc_history_remark`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：历史备注
- 表含义：历史备注
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `uid` | `bigint` | 用户lid | 用户lid | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_invoice_attachment`

- 真实表：`sc_invoice_attachment`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：发票附件列表
- 表含义：发票附件列表
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 记账日期 | 记账日期 | NO | NULL | DB/DDL/实体注释 |
| `invoice_order_lid` | `bigint` | 发票记录lid | 发票记录lid | NO | NULL | DB/DDL/实体注释 |
| `url` | `varchar(255)` | 附件地址 | 附件地址 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_item_attachment`

- 真实表：`sc_item_attachment`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品附件
- 表含义：物品附件
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 日期 | 日期 | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 单据lid | 单据lid | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | NO | NULL | DB/DDL/实体注释 |
| `url` | `varchar(255)` | 附件地址 | 附件地址 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_order_template`

- 真实表：`sc_order_template`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：订货模板
- 表含义：订货模板
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 模板名称 | 模板名称 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_order_template_item`

- 真实表：`sc_order_template_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：订货模板物品
- 表含义：订货模板物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `order_lid` | `bigint` | 模板lid | 模板lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 物品数量 | 物品数量 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `indent_price` | `decimal(24,10)` | 订购单价 | 订购单价 | YES | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,10)` | 订购数量 | 订购数量 | YES | NULL | DB/DDL/实体注释 |

#### `sc_organ_target`

- 真实表：`sc_organ_target`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：组织目标管理
- 表含义：组织目标管理
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年份 | 年份 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月份 | 月份 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 目标金额 | 目标金额 | NO | NULL | DB/DDL/实体注释 |
| `min_rate` | `decimal(24,6)` | 毛利润参考最小值 | 毛利润参考最小值 | NO | NULL | DB/DDL/实体注释 |
| `max_rate` | `decimal(24,6)` | 毛利润参考最大值 | 毛利润参考最大值 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | NO | 0 | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_pay_task`

- 真实表：`sc_pay_task`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供应链支付申请记录
- 表含义：供应链支付申请记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 支付金额 | 支付金额 | NO | NULL | DB/DDL/实体注释 |
| `wms_type` | `int` | 供应链业务类型 | 供应链业务类型 | NO | NULL | DB/DDL/实体注释 |
| `state` | `int` | 支付状态 | 支付状态 | NO | NULL | DB/DDL/实体注释 |
| `app_id` | `varchar(32)` | appID | appId | NO | NULL | DB/DDL/实体注释 |
| `open_id` | `varchar(32)` | 用户open_id | 用户open_id | NO | NULL | DB/DDL/实体注释 |
| `pay_id` | `varchar(32)` | 支付单号 | 支付单号 | NO | NULL | DB/DDL/实体注释 |
| `finished_at` | `datetime` | 支付完成时间 | 支付完成时间 | YES | NULL | DB/DDL/实体注释 |
| `order_lids` | `varchar(1024)` | 订单lid列表 | 订单lid列表 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_prepay_checked_item`

- 真实表：`sc_prepay_checked_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：预付款核销记录
- 表含义：预付款核销记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 付款日期 | 付款日期 | NO | NULL | DB/DDL/实体注释 |
| `prepay_order_lid` | `bigint` | 预付款单lid | 预付款单lid | NO | NULL | DB/DDL/实体注释 |
| `prepay_order_item_lid` | `bigint` | 预付款项lid | 预付款项lid | NO | NULL | DB/DDL/实体注释 |
| `bill_pay_item_lid` | `bigint` | 单据某次的预付款lid | 单据某次的预付款lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 仓库单据lid | 仓库单据lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商的lid | 供货商的lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 付款类型 | 付款类型 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 核销金额 | 核销金额 | NO | NULL | DB/DDL/实体注释 |
| `balance_before` | `decimal(24,6)` | 核销前金额 | 核销前金额 | NO | NULL | DB/DDL/实体注释 |
| `balance_after` | `decimal(24,6)` | 核销后金额 | 核销后金额 | NO | NULL | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_lid` | `bigint` | 取消人lid | 取消人lid | YES | NULL | DB/DDL/实体注释 |
| `cancel_time` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_prepay_order`

- 真实表：`sc_prepay_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商预付款
- 表含义：供货商预付款
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 单据编号 | 单据编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 单据日期 | 单据日期 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商编号 | 供货商编号 | NO | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 记录数 | 记录数 | NO | NULL | DB/DDL/实体注释 |
| `total_amount` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `surplus_amount` | `decimal(24,6)` | 剩余金额 | 剩余金额 | NO | NULL | DB/DDL/实体注释 |
| `checked_amount` | `decimal(24,6)` | 已核销金额 | 已核销金额 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_prepay_order_item`

- 真实表：`sc_prepay_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商预付款项
- 表含义：供货商预付款项
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 单据日期 | 单据日期 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商编号 | 供货商编号 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `prepay_order_id` | `varchar(90)` | 预付款单据编号 | 预付款单据编号 | NO | NULL | DB/DDL/实体注释 |
| `prepay_order_lid` | `bigint` | 预付款单lid | 预付款单lid | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 预付金额 | 预付金额 | NO | NULL | DB/DDL/实体注释 |
| `surplus_amount` | `decimal(24,6)` | 剩余金额 | 剩余金额 | NO | NULL | DB/DDL/实体注释 |
| `checked_amount` | `decimal(24,6)` | 已核销金额 | 已核销金额 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 预付款名称 | 预付款名称 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 付款类型 | 付款类型 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product`

- 真实表：`sc_product`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品
- 表含义：菜品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `product_type_lid` | `bigint` | 商品类别lid | 商品类别lid | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 菜品编号 | 菜品编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 菜品名称 | 菜品名称 | NO | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 启用/禁用 | 启用/禁用 | NO | 1 | DB/DDL/实体注释 |
| `idx` | `int` | 菜品顺序 | 菜品顺序 | NO | NULL | DB/DDL/实体注释 |
| `setup` | `tinyint(1)` | 是否设置 | 是否设置 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_cost`

- 真实表：`sc_product_cost`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品其他成本
- 表含义：菜品其他成本
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(32)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 成本名称 | 成本名称 | NO | NULL | DB/DDL/实体注释 |
| `assist_lid` | `bigint` | 辅助成本的lid | 辅助成本的lid | NO | NULL | DB/DDL/实体注释 |
| `rate` | `decimal(24,6)` | 占比 | 占比 | NO | NULL | DB/DDL/实体注释 |
| `cost` | `decimal(24,6)` | 成本 | 成本 | NO | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 顺序 | 顺序 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_raw`

- 真实表：`sc_product_raw`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品原料
- 表含义：菜品原料
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(32)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_unit` | `varchar(90)` | 物品单位 | 物品单位 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `raw_weight` | `decimal(24,6)` | 原料重量 | 原料重量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 原料单价 | 原料单价 | NO | NULL | DB/DDL/实体注释 |
| `net_rate` | `decimal(24,6)` | 出净率 | 出净率 | NO | NULL | DB/DDL/实体注释 |
| `net_weight` | `decimal(24,6)` | 净料重量 | 净料重量 | NO | NULL | DB/DDL/实体注释 |
| `yield_rate` | `decimal(24,6)` | 出成率 | 出成率 | NO | NULL | DB/DDL/实体注释 |
| `cooked_weight` | `decimal(24,6)` | 熟菜重量 | 熟菜重量 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额（元） | NO | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 顺序 | 顺序 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 物品单位类型 | 物品单位类型 | NO | 1 | DB/DDL/实体注释 |
| `last_order_price` | `decimal(24,6)` | 上次进货单价 | 上次进货单价 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_resource`

- 真实表：`sc_product_resource`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品视频/图片
- 表含义：菜品视频/图片
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(32)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `url` | `varchar(255)` | 资源地址 | 资源地址 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 资源类型 | 资源类型 | NO | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 顺序 | 顺序 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_sale_cost`

- 真实表：`sc_product_sale_cost`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品销售成本分析
- 表含义：菜品销售成本分析
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `profit_lid` | `bigint` | 毛利表lid,保留字段 | 毛利表lid,保留字段 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(90)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_unit` | `varchar(90)` | 物品单位 | 物品单位 | NO | NULL | DB/DDL/实体注释 |
| `goods_unit_lid` | `bigint` | 物品单位lid | 物品单位lid | NO | NULL | DB/DDL/实体注释 |
| `theory_volume` | `decimal(24,6)` | 理论用量 | 理论用量 | YES | 0.000000 | DB/DDL/实体注释 |
| `actual_volume` | `decimal(24,6)` | 实际用量 | 实际用量 | YES | 0.000000 | DB/DDL/实体注释 |
| `diff_volume` | `decimal(24,6)` | 用量差异 | 用量差异 | YES | 0.000000 | DB/DDL/实体注释 |
| `theory_cost` | `decimal(24,6)` | 理论成本 | 理论成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `actual_cost` | `decimal(24,6)` | 实际成本 | 实际成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `wastage_cost` | `decimal(24,6)` | 耗损成本 | 耗损成本 | YES | 0.000000 | DB/DDL/实体注释 |
| `diff_cost` | `decimal(24,6)` | 成本差异 | 成本差异 | YES | 0.000000 | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `organ_name` | `varchar(90)` | 组织名称 | 组织名称 | YES | NULL | DB/DDL/实体注释 |
| `product_name` | `varchar(90)` | 商品名称 | 商品名称 | YES | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(90)` | 商品名称 | 商品名称 | YES | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(90)` | 店铺名称 | 店铺名称 | YES | NULL | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,6)` | 计量数量 | 计量数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `source_type` | `int` | 来源类型 | 来源类型 | YES | 0 | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 账单编号 | 账单编号 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_sale_profit`

- 真实表：`sc_product_sale_profit`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品销售毛利分析
- 表含义：菜品销售毛利分析
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 组织lid | 组织lid | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(90)` | 商品单位 | 商品单位 | NO | NULL | DB/DDL/实体注释 |
| `sale_volume` | `decimal(24,6)` | 销售数量 | 销售数量 | NO | NULL | DB/DDL/实体注释 |
| `sale_price` | `decimal(24,6)` | 平均售价 | 平均售价 | NO | NULL | DB/DDL/实体注释 |
| `sale_amount` | `decimal(24,6)` | 销售金额 | 销售金额 | NO | NULL | DB/DDL/实体注释 |
| `theory_cost` | `decimal(24,6)` | 理论成本 | 理论成本 | NO | NULL | DB/DDL/实体注释 |
| `actual_cost` | `decimal(24,6)` | 实际成本 | 实际成本 | NO | NULL | DB/DDL/实体注释 |
| `other_cost` | `decimal(24,6)` | 其他成本 | 其他成本 | NO | NULL | DB/DDL/实体注释 |
| `diff_cost` | `decimal(24,6)` | 成本差异 | 成本差异 | NO | NULL | DB/DDL/实体注释 |
| `bill_type` | `int` | 账单类型 | 账单类型 | NO | 1 | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `organ_name` | `varchar(90)` | 组织名称 | 组织名称 | YES | NULL | DB/DDL/实体注释 |
| `product_name` | `varchar(90)` | 商品名称 | 商品名称 | YES | NULL | DB/DDL/实体注释 |
| `shop_name` | `varchar(90)` | 店铺名称 | 店铺名称 | YES | NULL | DB/DDL/实体注释 |
| `source_type` | `int` | 来源类型 | 来源类型 | YES | 0 | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 账单编号 | 账单编号 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_type`

- 真实表：`sc_product_type`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品类别
- 表含义：菜品类别
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `parent_lid` | `bigint` | 上级分类 | 上级分类 | YES | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 顺序 | 顺序 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_product_unit`

- 真实表：`sc_product_unit`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：菜品单位
- 表含义：菜品单位
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | NO | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 单位类型 | 单位类型 | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位名称 | 单位名称 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 单位价格 | 单位价格 | NO | NULL | DB/DDL/实体注释 |
| `make_duration` | `int` | 制作时长 | 制作时长 | YES | NULL | DB/DDL/实体注释 |
| `process_flow` | `varchar(900)` | 工艺流程 | 工艺流程 | YES | NULL | DB/DDL/实体注释 |
| `weight` | `decimal(24,6)` | 重量 | 重量 | NO | 0.000000 | DB/DDL/实体注释 |
| `raw_cost` | `decimal(24,6)` | 原材料成本 | 原材料成本 | NO | 0.000000 | DB/DDL/实体注释 |
| `gross_rate` | `decimal(24,6)` | 毛利率 | 毛利率 | NO | 0.000000 | DB/DDL/实体注释 |
| `assist_cost` | `decimal(24,6)` | 辅助成本 | 辅助成本 | NO | 0.000000 | DB/DDL/实体注释 |
| `total_cost` | `decimal(24,6)` | 综合总成本 | 综合总成本 | NO | 0.000000 | DB/DDL/实体注释 |
| `profit` | `decimal(24,6)` | 纯利润 | 纯利润 | NO | 0.000000 | DB/DDL/实体注释 |
| `profit_rate` | `decimal(24,6)` | 纯利率 | 纯利率 | NO | 0.000000 | DB/DDL/实体注释 |
| `cost_rate` | `decimal(24,6)` | 成本率 | 成本率 | NO | 0.000000 | DB/DDL/实体注释 |
| `raw_weight` | `decimal(24,6)` | 原料重量 | 原料重量 | NO | 0.000000 | DB/DDL/实体注释 |
| `net_weight` | `decimal(24,6)` | 净料重量 | 净料重量 | NO | 0.000000 | DB/DDL/实体注释 |
| `cooked_weight` | `decimal(24,6)` | 熟菜重量 | 熟菜重量 | NO | 0.000000 | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额（元） | NO | 0.000000 | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `approval_lids` | `varchar(255)` | 当前审批的lids | 当前审批的lids | YES | NULL | DB/DDL/实体注释 |
| `approval_temporary` | `longtext` | 暂存 | 暂存 | YES | NULL | DB/DDL/实体注释 |

#### `sc_quote_order`

- 真实表：`sc_quote_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商报价单
- 表含义：供货商报价单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 单据编号 | 单据编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `quote_state` | `int` | 报价状态 | 报价状态 | NO | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(255)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `release_lid` | `bigint` | 发布人lid | 发布人lid | YES | NULL | DB/DDL/实体注释 |
| `release_by` | `varchar(255)` | 发布人 | 发布人 | YES | NULL | DB/DDL/实体注释 |
| `release_time` | `datetime` | 发布时间 | 发布时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_quote_order_item`

- 真实表：`sc_quote_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商报价单物品
- 表含义：供货商报价单物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 报价 | 报价 | NO | NULL | DB/DDL/实体注释 |
| `added_tax_type` | `int` | 采购税率 | 采购税率 | NO | NULL | DB/DDL/实体注释 |
| `last_price` | `decimal(24,6)` | 上期价格 | 上期价格 | YES | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 价格生效日期 | 价格生效日期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 价格失效日期 | 价格失效日期 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | YES | 1 | DB/DDL/实体注释 |

#### `sc_quote_order_store`

- 真实表：`sc_quote_order_store`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商报价单适用组织
- 表含义：供货商报价单适用组织
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 适用门店sid | 适用门店sid | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_quote_order_supplier`

- 真实表：`sc_quote_order_supplier`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商报价单适用供货商
- 表含义：供货商报价单适用供货商
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 报价日期 | 报价日期 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_rdc_order`

- 真实表：`sc_rdc_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送中心订货单
- 表含义：配送中心订货单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 订货单号 | 订货单号 | NO | NULL | DB/DDL/实体注释 |
| `store_order_lid` | `bigint` | 门店订货单lid | 门店订货单lid | YES | NULL | DB/DDL/实体注释 |
| `store_order_id` | `varchar(90)` | 门店订货单号 | 门店订货单号 | YES | NULL | DB/DDL/实体注释 |
| `purchase_order_lid` | `bigint` | 采购单lid | 采购单lid | YES | NULL | DB/DDL/实体注释 |
| `purchase_order_id` | `varchar(90)` | 采购单号 | 采购单号 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 记录数 | 记录数 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 总数量 | 总数量 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(24,6)` | 含税金额 | 含税金额 | NO | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,6)` | 标准数量 | 标准数量 | NO | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `reject_lid` | `bigint` | 驳回人lid | 驳回人lid | YES | NULL | DB/DDL/实体注释 |
| `reject_by` | `varchar(90)` | 驳回人 | 驳回人 | YES | NULL | DB/DDL/实体注释 |
| `reject_time` | `datetime` | 驳回时间 | 驳回时间 | YES | NULL | DB/DDL/实体注释 |
| `submit_lid` | `bigint` | 提交人lid | 提交人lid | YES | NULL | DB/DDL/实体注释 |
| `submit_by` | `varchar(90)` | 提交人 | 提交人 | YES | NULL | DB/DDL/实体注释 |
| `submit_time` | `datetime` | 提交时间 | 提交时间 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `inspect_rows` | `int` | 验货记录数 | 验货记录数 | NO | 0 | DB/DDL/实体注释 |
| `payed` | `tinyint(1)` | 是否付款 | 是否付款 | NO | 0 | DB/DDL/实体注释 |
| `delivery_fee` | `decimal(24,6)` | 配送费 | 配送费 | NO | 0.000000 | DB/DDL/实体注释 |
| `paid_amount` | `decimal(24,6)` | 已付款金额 | 已付款金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `checked_amount` | `decimal(24,6)` | 已核销金额 | 已核销金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `invoice_amount` | `decimal(24,6)` | 已开金额 | 已开金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `settle_state` | `int` | 结算状态 | 结算状态 | NO | 1 | DB/DDL/实体注释 |
| `check_state` | `int` | 对账状态 | 对账状态 | NO | 1 | DB/DDL/实体注释 |
| `check_by` | `varchar(90)` | 对账人 | 对账人 | YES | NULL | DB/DDL/实体注释 |
| `check_lid` | `bigint` | 对账人lid | 对账人lid | YES | NULL | DB/DDL/实体注释 |
| `check_time` | `datetime` | 对账时间 | 对账时间 | YES | NULL | DB/DDL/实体注释 |
| `to_paid_amount` | `decimal(24,6)` | 要付款金额 | 要付款金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `task_lid` | `bigint` | 支付任务lid | 支付任务lid | YES | NULL | DB/DDL/实体注释 |
| `inspect_rdc_type` | `int` | 配送中心验货类型 | 配送中心验货类型 | YES | 1 | DB/DDL/实体注释 |
| `out_at` | `datetime` | 出库时间 | 出库时间 | YES | NULL | DB/DDL/实体注释 |
| `out_by` | `varchar(32)` | 出库人 | 出库人 | YES | NULL | DB/DDL/实体注释 |
| `inbound_lid` | `bigint` | 验货入库lid | 验货入库lid | YES | NULL | DB/DDL/实体注释 |
| `inbound_id` | `varchar(32)` | 验货入库单号 | 验货入库单号 | YES | NULL | DB/DDL/实体注释 |
| `outbound_lid` | `bigint` | 配送出库lid | 配送出库lid | YES | NULL | DB/DDL/实体注释 |
| `outbound_id` | `varchar(32)` | 配送出库单号 | 配送出库单号 | YES | NULL | DB/DDL/实体注释 |
| `inspect_by` | `varchar(32)` | 验货人 | 验货人 | YES | NULL | DB/DDL/实体注释 |
| `inspect_time` | `datetime` | 验货时间 | 验货时间 | YES | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商或者配送出库仓 | 供货商或者配送出库仓 | YES | NULL | DB/DDL/实体注释 |

#### `sc_rdc_order_item`

- 真实表：`sc_rdc_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：配送中心订货单物品
- 表含义：配送中心订货单物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `rdc_order_lid` | `bigint` | 配送中心订货单lid | 配送中心订货单lid | NO | NULL | DB/DDL/实体注释 |
| `rdc_order_id` | `varchar(90)` | 配送中心订货单号 | 配送中心订货单号 | NO | NULL | DB/DDL/实体注释 |
| `purchase_order_lid` | `bigint` | 采购单lid | 采购单lid | YES | NULL | DB/DDL/实体注释 |
| `purchase_order_id` | `varchar(90)` | 采购单号 | 采购单号 | YES | NULL | DB/DDL/实体注释 |
| `org_item_lid` | `bigint` | 原始物品lid | 原始物品lid | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,10)` | 体积/数量 | 体积/数量 | YES | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,10)` | 订单数量 | 订单数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,10)` | 单价 | 单价 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,10)` | 金额 | 金额 | YES | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,10)` | 原始数量 | 原始数量 | YES | NULL | DB/DDL/实体注释 |
| `org_price` | `decimal(24,10)` | 原始单价 | 原始单价 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,10)` | 原始金额 | 原始金额 | YES | NULL | DB/DDL/实体注释 |
| `total_amount` | `decimal(24,10)` | 总金额 | 总金额 | YES | NULL | DB/DDL/实体注释 |
| `total_volume` | `decimal(24,10)` | 总数量 | 总数量 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,10)` | 税率 | 税率 | YES | NULL | DB/DDL/实体注释 |
| `arrival_time` | `datetime` | 到货日期 | 到货日期 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `submitted` | `tinyint(1)` | 已提交 | 已提交 | YES | NULL | DB/DDL/实体注释 |
| `submitted_lid` | `bigint` | 提交人lid | 提交人lid | YES | NULL | DB/DDL/实体注释 |
| `submitted_by` | `varchar(90)` | 提交人 | 提交人 | YES | NULL | DB/DDL/实体注释 |
| `submitted_time` | `datetime` | 提交时间 | 提交时间 | YES | NULL | DB/DDL/实体注释 |
| `split_lid` | `bigint` | 拆单人lid | 拆单人lid | YES | NULL | DB/DDL/实体注释 |
| `split_by` | `varchar(90)` | 拆单人 | 拆单人 | YES | NULL | DB/DDL/实体注释 |
| `split_time` | `datetime` | 拆单时间 | 拆单时间 | YES | NULL | DB/DDL/实体注释 |
| `parented` | `tinyint(1)` | 主单 | 主单 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `inspect_volume` | `decimal(24,10)` | 检验数量 | 检验数量 | YES | NULL | DB/DDL/实体注释 |
| `inspect_price` | `decimal(24,10)` | 检验单价 | 检验单价 | YES | NULL | DB/DDL/实体注释 |
| `inspect_amount` | `decimal(24,10)` | 检验金额 | 检验金额 | YES | NULL | DB/DDL/实体注释 |
| `inspected_volume` | `decimal(24,10)` | 已检验数量 | 已检验数量 | YES | NULL | DB/DDL/实体注释 |
| `inspect_lid` | `bigint` | 验货人lid | 验货人lid | YES | NULL | DB/DDL/实体注释 |
| `inspect_by` | `varchar(90)` | 验货人 | 验货人 | YES | NULL | DB/DDL/实体注释 |
| `inspect_time` | `datetime` | 验货时间 | 验货时间 | YES | NULL | DB/DDL/实体注释 |
| `out_volume` | `decimal(24,10)` | 出库数量 | 出库数量 | YES | NULL | DB/DDL/实体注释 |
| `inbound_lid` | `bigint` | 入库单lid | 入库单lid | YES | NULL | DB/DDL/实体注释 |
| `inbound_id` | `varchar(255)` | inboundID | 供应链或基础资料业务关联的inboundID。 | YES | NULL | 推断 |
| `production_date` | `datetime` | 生产日期 | 生产日期 | YES | NULL | DB/DDL/实体注释 |
| `batch_no` | `varchar(90)` | 批次号 | 批次号 | YES | NULL | DB/DDL/实体注释 |
| `inspect_remark` | `varchar(255)` | 验货备注 | 验货备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `out_remark` | `varchar(255)` | 发货备注 | 发货备注 | YES | NULL | DB/DDL/实体注释 |
| `weighted` | `tinyint(1)` | 已称重 | 已称重 | NO | 0 | DB/DDL/实体注释 |
| `scarce` | `tinyint(1)` | 物品缺货 | 物品缺货 | NO | 0 | DB/DDL/实体注释 |
| `out_state` | `int` | 发货状态 | 发货状态 | NO | 1 | DB/DDL/实体注释 |
| `out_at` | `datetime` | 发货时间 | 发货时间 | YES | NULL | DB/DDL/实体注释 |
| `out_by` | `varchar(90)` | 发货人 | 发货人 | YES | NULL | DB/DDL/实体注释 |
| `outbound_lid` | `bigint` | 出库单lid | 出库单lid | YES | NULL | DB/DDL/实体注释 |
| `outbound_id` | `varchar(90)` | 出库单编号 | 出库单编号 | YES | NULL | DB/DDL/实体注释 |
| `payed` | `tinyint(1)` | 是否付款 | 是否付款 | NO | 0 | DB/DDL/实体注释 |
| `delivery_fee` | `decimal(24,10)` | 运费 | 运费 | YES | NULL | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,10)` | 盘点数量 | 盘点数量 | YES | NULL | DB/DDL/实体注释 |
| `refund_for` | `varchar(255)` | 退货原因 | 退货原因 | YES | NULL | DB/DDL/实体注释 |
| `refund_id` | `varchar(255)` | 退货单号 | 退货单号 | YES | NULL | DB/DDL/实体注释 |
| `reject` | `tinyint(1)` | 拒收 | 拒收 | YES | 0 | DB/DDL/实体注释 |
| `reject_by` | `varchar(90)` | 拒收人 | 拒收人 | YES | NULL | DB/DDL/实体注释 |
| `reject_at` | `datetime` | 拒收时间 | 拒收时间 | YES | NULL | DB/DDL/实体注释 |
| `reject_for` | `varchar(255)` | 拒收原因 | 拒收原因 | YES | NULL | DB/DDL/实体注释 |
| `cancel` | `tinyint(1)` | 取消 | 取消 | YES | 0 | DB/DDL/实体注释 |
| `cancel_by` | `varchar(90)` | 取消人 | 取消人 | YES | NULL | DB/DDL/实体注释 |
| `cancel_at` | `datetime` | 取消时间 | 取消时间 | YES | NULL | DB/DDL/实体注释 |
| `cancel_for` | `varchar(255)` | 取消原因 | 取消原因 | YES | NULL | DB/DDL/实体注释 |
| `refund_state` | `int` | 退货状态 | 退货状态 | YES | 0 | DB/DDL/实体注释 |
| `refund_volume` | `decimal(24,10)` | 退款数量 | 退款数量 | YES | NULL | DB/DDL/实体注释 |
| `refund_by` | `varchar(255)` | 退货人 | 退货人 | YES | NULL | DB/DDL/实体注释 |
| `refund_at` | `varchar(255)` | 退货时间 | 退货时间 | YES | NULL | DB/DDL/实体注释 |
| `inspect_indent_volume` | `decimal(24,10)` | 检验订单数量 | 检验订单数量 | YES | NULL | DB/DDL/实体注释 |
| `share_id` | `varchar(32)` | 分享汇总单号 | 分享汇总单号 | YES | NULL | DB/DDL/实体注释 |
| `share_lid` | `bigint` | 分享汇总单号lid | 分享汇总单号lid | YES | NULL | DB/DDL/实体注释 |
| `share_by` | `varchar(32)` | 分享人 | 分享人 | YES | NULL | DB/DDL/实体注释 |
| `share_at` | `datetime` | 分享时间 | 分享时间 | YES | NULL | DB/DDL/实体注释 |
| `printed` | `tinyint(1)` | 打印状态 | 打印状态 | YES | 0 | DB/DDL/实体注释 |
| `print_state` | `int` | 打印状态 | 打印状态（位标志组合） | YES | 0 | DB/DDL/实体注释 |
| `sort_status` | `int` | 分拣状态 | 分拣状态：0-未分拣，1-已分拣 | YES | 0 | DB/DDL/实体注释 |
| `edited` | `tinyint(1)` | 是否编辑 | 是否编辑 | YES | NULL | DB/DDL/实体注释 |
| `inspect_rdc_type` | `int` | 配送中心验货类型 | 配送中心验货类型 | YES | 1 | DB/DDL/实体注释 |
| `diff_volume` | `decimal(24,10)` | 差异数量 | 差异数量 | YES | NULL | DB/DDL/实体注释 |
| `diff_amount` | `decimal(24,10)` | 差异金额 | 差异金额 | YES | NULL | DB/DDL/实体注释 |
| `store_order_id` | `varchar(32)` | 订货单号 | 订货单号 | YES | NULL | DB/DDL/实体注释 |
| `reject_volume` | `decimal(24,10)` | 拒收数量 | 拒收数量 | YES | NULL | DB/DDL/实体注释 |
| `cancel_volume` | `decimal(24,10)` | 取消数量 | 取消数量 | YES | NULL | DB/DDL/实体注释 |
| `outbound_amount` | `decimal(24,10)` | 出库金额 | 出库金额 | YES | NULL | DB/DDL/实体注释 |
| `edited_by_shop` | `tinyint` | 门店是否已编辑 | 门店是否已编辑 | YES | 0 | DB/DDL/实体注释 |
| `indent_price` | `decimal(24,10)` | 订购价 | 订购价 | YES | NULL | DB/DDL/实体注释 |
| `adjust_volume` | `decimal(19,10)` | 调整量 | 调整量 | YES | NULL | DB/DDL/实体注释 |

#### `sc_sale_cost_relate`

- 真实表：`sc_sale_cost_relate`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品成本关联
- 表含义：物品成本关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `relate_lid` | `bigint` | 销售成本分析lid | 销售成本分析lid | NO | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 账单lid | 账单lid | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 账单物品lid | 账单物品lid | NO | NULL | DB/DDL/实体注释 |
| `volume` | `bigint` | 用量 | 用量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 均价 | 均价 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | NULL | DB/DDL/实体注释 |
| `type` | `int` | 类型 扣库/盘点 | 类型 扣库/盘点 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_st_account_period`

- 真实表：`sc_st_account_period`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：会计周期
- 表含义：会计周期
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 会计周期名称 | 会计周期名称 | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始日期 | 开始日期 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 结束日期 | 结束日期 | YES | NULL | DB/DDL/实体注释 |
| `post_date` | `datetime` | 转结日期 | 转结日期 | YES | NULL | DB/DDL/实体注释 |
| `posted` | `tinyint(1)` | 是否转结 | 是否转结 | YES | NULL | DB/DDL/实体注释 |
| `last_period_lid` | `bigint` | 上一会计周期 | 上一会计周期 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_st_bill`

- 真实表：`sc_st_bill`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：仓库单据
- 表含义：仓库单据
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店sid | 门店sid | NO | -1 | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(255)` | 单据编号 | 单据编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 票据类型 | 票据类型 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `bill_remark` | `varchar(500)` | 账单备注 | 账单备注 | YES | NULL | DB/DDL/实体注释 |
| `client` | `varchar(90)` | 客户 | 客户 | YES | NULL | DB/DDL/实体注释 |
| `client_lid` | `bigint` | 客户编号 | 客户编号 | YES | NULL | DB/DDL/实体注释 |
| `applicant_lid` | `bigint` | 申请人编号 | 申请人编号 | YES | NULL | DB/DDL/实体注释 |
| `applicant` | `varchar(255)` | 申请人 | 申请人 | YES | NULL | DB/DDL/实体注释 |
| `keeper_lid` | `bigint` | 库管员编号 | 库管员编号 | YES | NULL | DB/DDL/实体注释 |
| `keeper` | `varchar(255)` | 库管员 | 库管员 | YES | NULL | DB/DDL/实体注释 |
| `purchase_order_lid` | `bigint` | 采购订单lid | 采购订单lid | YES | NULL | DB/DDL/实体注释 |
| `maker_lid` | `bigint` | 制单人编号 | 制单人编号 | YES | NULL | DB/DDL/实体注释 |
| `maker` | `varchar(255)` | 制单人 | 制单人 | YES | NULL | DB/DDL/实体注释 |
| `manual_no` | `varchar(255)` | 手工单号 | 手工单号 | YES | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | -1 | DB/DDL/实体注释 |
| `manager_lid` | `bigint` | 经办人编号 | 经办人编号 | YES | NULL | DB/DDL/实体注释 |
| `manager` | `varchar(255)` | 经办人 | 经办人 | YES | NULL | DB/DDL/实体注释 |
| `arrival_time` | `datetime` | 到货日期 | 到货日期 | YES | NULL | DB/DDL/实体注释 |
| `make_time` | `datetime` | 开票时间 | 开票时间 | YES | NULL | DB/DDL/实体注释 |
| `post_time` | `datetime` | 过帐日期 | 过帐日期 | YES | NULL | DB/DDL/实体注释 |
| `poster_lid` | `bigint` | 过账人编号 | 过账人编号 | YES | NULL | DB/DDL/实体注释 |
| `poster` | `varchar(255)` | 过账人 | 过账人 | YES | NULL | DB/DDL/实体注释 |
| `posted` | `int` | 是否过账 | 是否过账 | NO | NULL | DB/DDL/实体注释 |
| `post_id` | `bigint` | 过账顺序;用于单据排序 | 过账顺序;用于单据排序 | YES | NULL | DB/DDL/实体注释 |
| `last_mod_time` | `datetime` | 上一次修改的时间 | 上一次修改的时间 | YES | NULL | DB/DDL/实体注释 |
| `total_amount` | `decimal(24,6)` | 金额合计 | 金额合计 | YES | NULL | DB/DDL/实体注释 |
| `total_volume` | `decimal(24,6)` | 数量合计 | 数量合计 | YES | NULL | DB/DDL/实体注释 |
| `ref_flag` | `int` | 是否冲红 | 是否冲红 | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库编号 | 仓库编号 | NO | NULL | DB/DDL/实体注释 |
| `take_warehouse_lid` | `bigint` | 领用仓库编号 | 领用仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `in_bill_lid` | `bigint` | 调入仓库单据编号 | 调入仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `in_warehouse_lid` | `bigint` | 调入仓库编号 | 调入仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `out_bill_lid` | `bigint` | 调出仓库单据编号 | 调出仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `out_warehouse_lid` | `bigint` | 调出仓库编号 | 调出仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `org_id` | `varchar(255)` | 原始单号 | 原始单号 | YES | NULL | DB/DDL/实体注释 |
| `shipper` | `varchar(255)` | 发货方 | 发货方 | YES | NULL | DB/DDL/实体注释 |
| `consignee` | `varchar(255)` | 收货方 | 收货方 | YES | NULL | DB/DDL/实体注释 |
| `in_out_flag` | `int` | 进出仓库的标志位 | 进出仓库的标志位 | YES | NULL | DB/DDL/实体注释 |
| `check_bill_lid` | `bigint` | 盘点单lid | 盘点单lid | YES | NULL | DB/DDL/实体注释 |
| `org_bill_lid` | `bigint` | 原订单编号 | 原订单编号 | YES | NULL | DB/DDL/实体注释 |
| `account_period_lid` | `bigint` | 所属会计期间编号 | 所属会计期间编号 | YES | NULL | DB/DDL/实体注释 |
| `order_src` | `int` | 单据来源 | 单据来源 | NO | NULL | DB/DDL/实体注释 |
| `purchaser_lid` | `bigint` | 采购商商户id | 采购商商户id | YES | NULL | DB/DDL/实体注释 |
| `relate_bill_lid` | `bigint` | 关联单据编号,入库和关联供货商单使用 | 关联单据编号,入库和关联供货商单使用 | YES | NULL | DB/DDL/实体注释 |
| `relate_bill_id` | `varchar(90)` | 关联单号 | 关联单号 | YES | NULL | DB/DDL/实体注释 |
| `shipment_bill_lid` | `bigint` | 发货单号 | 发货单号 | YES | NULL | DB/DDL/实体注释 |
| `receipt_bill_lid` | `bigint` | 收货单号 | 收货单号 | YES | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(24,6)` | 税额 | 税额 | NO | NULL | DB/DDL/实体注释 |
| `qi_state` | `int` | 质检状态 | 质检状态 | NO | NULL | DB/DDL/实体注释 |
| `print_state` | `int` | 打印状态 | 打印状态 | NO | NULL | DB/DDL/实体注释 |
| `promotion_amount` | `decimal(24,6)` | 优惠金额 | 优惠金额 | NO | NULL | DB/DDL/实体注释 |
| `paid_amount` | `decimal(24,6)` | 已付款金额 | 已付款金额 | NO | NULL | DB/DDL/实体注释 |
| `checked_amount` | `decimal(24,6)` | 已核销金额 | 已核销金额 | NO | NULL | DB/DDL/实体注释 |
| `invoice_amount` | `decimal(24,6)` | 已开金额 | 已开金额 | NO | NULL | DB/DDL/实体注释 |
| `settle_state` | `int` | 结算状态 | 结算状态 | NO | NULL | DB/DDL/实体注释 |
| `check_state` | `int` | 对账状态 | 对账状态 | NO | NULL | DB/DDL/实体注释 |
| `check_by` | `varchar(90)` | 对账人 | 对账人 | YES | NULL | DB/DDL/实体注释 |
| `check_lid` | `bigint` | 对账人lid | 对账人lid | YES | NULL | DB/DDL/实体注释 |
| `check_time` | `datetime` | 对账时间 | 对账时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | YES | 1 | DB/DDL/实体注释 |
| `process_factory_lid` | `bigint` | 加工厂lid | 加工厂lid | YES | NULL | DB/DDL/实体注释 |
| `dest_sid` | `bigint` | 目的仓库sid | 目的仓库sid | YES | NULL | DB/DDL/实体注释 |
| `amount_sub` | `tinyint` | 是否按金额扣减 | 是否按金额扣减 | YES | 0 | DB/DDL/实体注释 |
| `reconciliation_apply_id` | `varchar(32)` | 对账申请单id | 对账申请单id | YES | NULL | DB/DDL/实体注释 |
| `reconciliation_apply_lid` | `bigint` | 对账申请单lid | 对账申请单lid | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `out_department` | `varchar(255)` | outdepartment | 库存单据业务中的outdepartment。 | YES | NULL | 推断 |
| `comments` | `varchar(255)` | comments | 库存单据业务中的comments。 | YES | NULL | 推断 |
| `supplier` | `varchar(255)` | supplier | 库存单据业务中的supplier。 | YES | NULL | 推断 |
| `last_mode_time` | `datetime` | 上次mode时间 | 库存单据业务中的上次mode时间。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `out_warehouse` | `varchar(255)` | outwarehouse | 库存单据业务中的outwarehouse。 | YES | NULL | 推断 |
| `in_out_flag_of_warehouse` | `int` | inoutflagofwarehouse | 库存单据业务中的inoutflagofwarehouse。 | YES | NULL | 推断 |
| `in_out_flag_of_department` | `int` | inoutflagofdepartment | 库存单据业务中的inoutflagofdepartment。 | YES | NULL | 推断 |
| `aotu_maked` | `tinyint` | aotumaked | 库存单据业务中的aotumaked。 | YES | NULL | 推断 |
| `check_bill_id` | `varchar(255)` | check账单ID | 库存单据业务关联的check账单ID。 | YES | NULL | 推断 |
| `book_bill_id` | `varchar(255)` | book账单ID | 库存单据业务关联的book账单ID。 | YES | NULL | 推断 |
| `account_period` | `varchar(255)` | accountperiod | 库存单据业务中的accountperiod。 | YES | NULL | 推断 |
| `delivery_bill_id` | `varchar(255)` | delivery账单ID | 库存单据业务关联的delivery账单ID。 | YES | NULL | 推断 |
| `xfd_id` | `varchar(255)` | xfdID | 库存单据业务关联的xfdID。 | YES | NULL | 推断 |
| `printed_count` | `int` | printed次数 | 库存单据业务中的printed次数。 | YES | NULL | 推断 |
| `settlement_person` | `varchar(255)` | settlementperson | 库存单据业务中的settlementperson。 | YES | NULL | 推断 |
| `settlement_time` | `datetime` | settlement时间 | 库存单据业务中的settlement时间。 | YES | NULL | 推断 |
| `have_settlement_amount` | `decimal(19, 10)` | havesettlement金额 | 库存单据业务中的havesettlement金额。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |
| `Out_department_code` | `bigint` | outdepartmentcode | 库存单据业务对象的outdepartmentcode。 | YES | NULL | 推断 |
| `Maker_code` | `bigint` | makercode | 库存单据业务对象的makercode。 | YES | NULL | 推断 |
| `Client_code` | `bigint` | clientcode | 库存单据业务对象的clientcode。 | YES | NULL | 推断 |
| `Supplier_code` | `bigint` | suppliercode | 库存单据业务对象的suppliercode。 | YES | NULL | 推断 |
| `Manager_code` | `bigint` | managercode | 库存单据业务对象的managercode。 | YES | NULL | 推断 |
| `Poster_code` | `bigint` | postercode | 库存单据业务对象的postercode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Out_warehouse_code` | `bigint` | outwarehousecode | 库存单据业务对象的outwarehousecode。 | YES | NULL | 推断 |
| `Account_period_code` | `bigint` | accountperiodcode | 库存单据业务对象的accountperiodcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `In_department` | `varchar(255)` | indepartment | 库存单据业务中的indepartment。 | YES | NULL | 推断 |
| `In_department_code` | `bigint` | indepartmentcode | 库存单据业务对象的indepartmentcode。 | YES | NULL | 推断 |
| `In_warehouse` | `varchar(255)` | inwarehouse | 库存单据业务中的inwarehouse。 | YES | NULL | 推断 |
| `In_warehouse_code` | `bigint` | inwarehousecode | 库存单据业务对象的inwarehousecode。 | YES | NULL | 推断 |
| `purchase_order_no` | `varchar(64)` | 采购订单号 | 采购订单号 | YES | NULL | DB/DDL/实体注释 |
| `organization` | `varchar(64)` | 录入机构 | 录入机构 | YES | NULL | DB/DDL/实体注释 |
| `organization_code` | `bigint` | 录入机构编号 | 录入机构编号 | YES | NULL | DB/DDL/实体注释 |
| `applicant_code` | `bigint` | 申请人编号 | 申请人编号 | YES | NULL | DB/DDL/实体注释 |
| `keeper_code` | `bigint` | 库管员编号 | 库管员编号 | YES | NULL | DB/DDL/实体注释 |
| `updater_code` | `bigint` | 修改人编号 | 修改人编号 | YES | NULL | DB/DDL/实体注释 |
| `updater` | `varchar(64)` | 修改人编号 | 修改人编号 | YES | NULL | DB/DDL/实体注释 |
| `update_time` | `datetime` | 修改人编号 | 修改人编号 | YES | NULL | DB/DDL/实体注释 |
| `in_bill_code` | `bigint` | 入库仓库单据编号 | 入库仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `out_bill_code` | `bigint` | 出库仓库单据编号 | 出库仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `org_bill_code` | `bigint` | 原仓库单据编号 | 原仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `relate_bill_code` | `bigint` | 关联单据编号 | 关联单据编号 | YES | NULL | DB/DDL/实体注释 |
| `purchaser_merchant_id` | `bigint` | 采购商商户号 | 采购商商户号 | YES | NULL | DB/DDL/实体注释 |
| `shipment_bill_code` | `bigint` | 关联的发货单编号 | 关联的发货单编号 | YES | NULL | DB/DDL/实体注释 |
| `receipt_bill_code` | `bigint` | 关联的收货单编号 | 关联的收货单编号 | YES | NULL | DB/DDL/实体注释 |

#### `sc_st_bill_item`

- 真实表：`sc_st_bill_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：单据物品表
- 表含义：单据物品表
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店sid | 门店sid | NO | -1 | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `bill_type_` | `int` | 票据类型 | 票据类型 | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 仓库单据lid | 仓库单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(90)` | 仓库单据编号 | 仓库单据编号 | NO | NULL | DB/DDL/实体注释 |
| `make_time` | `datetime` | 开票时间 | 开票时间 | NO | NULL | DB/DDL/实体注释 |
| `post_time` | `datetime` | 过帐日期 | 过帐日期 | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | -1 | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `take_warehouse_lid` | `bigint` | 领用仓库编号 | 领用仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `goods_id` | `varchar(255)` | 物品编号 | 物品编号 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | NO | NULL | DB/DDL/实体注释 |
| `actual_volume` | `decimal(24,6)` | 到货数量 | 到货数量（用于采购订货） | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 单价 | 单价 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | NULL | DB/DDL/实体注释 |
| `base_unit_lid` | `bigint` | 基本单位lid | 基本单位lid | NO | NULL | DB/DDL/实体注释 |
| `base_unit` | `varchar(90)` | 基本单位 | 基本单位 | NO | NULL | DB/DDL/实体注释 |
| `volume_of_base_unit` | `decimal(24,6)` | 基本数量 | 基本数量 | NO | NULL | DB/DDL/实体注释 |
| `price_of_base_unit` | `decimal(24,6)` | 基本单价 | 基本单价 | NO | NULL | DB/DDL/实体注释 |
| `old_price` | `decimal(24,6)` | 原库存价 | 原库存价 | YES | NULL | DB/DDL/实体注释 |
| `new_price` | `decimal(24,6)` | 新库存价 | 新库存价 | YES | NULL | DB/DDL/实体注释 |
| `beginning_volume_of_in_warehouse` | `decimal(24,6)` | 入库仓库期初数量 | 入库仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `beginning_amount_of_in_warehouse` | `decimal(24,6)` | 入库仓库期初金额 | 入库仓库期初金额 | YES | NULL | DB/DDL/实体注释 |
| `beginning_volume_of_out_warehouse` | `decimal(24,6)` | 出库仓库期初数量 | 出库仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `beginning_amount_of_out_warehouse` | `decimal(24,6)` | 出库仓库期初金额 | 出库仓库期初金额 | YES | NULL | DB/DDL/实体注释 |
| `in_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | YES | NULL | DB/DDL/实体注释 |
| `in_amount_of_warehouse` | `decimal(24,6)` | 仓库收入金额 | 仓库收入金额 | YES | NULL | DB/DDL/实体注释 |
| `out_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | YES | NULL | DB/DDL/实体注释 |
| `out_amount_of_warehouse` | `decimal(24,6)` | 仓库发出金额 | 仓库发出金额 | YES | NULL | DB/DDL/实体注释 |
| `ending_volume_of_in_warehouse` | `decimal(24,6)` | 入库仓库结存数量 | 入库仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_amount_of_in_warehouse` | `decimal(24,6)` | 入库仓库结存金额 | 入库仓库结存金额 | YES | NULL | DB/DDL/实体注释 |
| `ending_volume_of_out_warehouse` | `decimal(24,6)` | 出库仓库结存数量 | 出库仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_amount_of_out_warehouse` | `decimal(24,6)` | 出库仓库结存金额 | 出库仓库结存金额 | YES | NULL | DB/DDL/实体注释 |
| `account_period_lid` | `bigint` | 所属会计期间编号 | 所属会计期间编号 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `production_date` | `datetime` | 生产日期 | 生产日期 | YES | NULL | DB/DDL/实体注释 |
| `batch_no` | `varchar(90)` | 批次号 | 批次号 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,6)` | 税率 | 税率 | NO | NULL | DB/DDL/实体注释 |
| `posted` | `int` | 是否过账 | 是否过账 | NO | NULL | DB/DDL/实体注释 |
| `ref_flag` | `int` | 是否冲红 | 是否冲红 | NO | NULL | DB/DDL/实体注释 |
| `qi_state` | `int` | 质检状态 | 质检状态 | NO | NULL | DB/DDL/实体注释 |
| `qi_volume` | `tinyint(1)` | 质检-数量 | 质检-数量 | NO | NULL | DB/DDL/实体注释 |
| `qi_time` | `tinyint(1)` | 质检-时间 | 质检-时间 | NO | NULL | DB/DDL/实体注释 |
| `qi_mass` | `tinyint(1)` | 质检-质量 | 质检-质量 | NO | NULL | DB/DDL/实体注释 |
| `qi_remark` | `varchar(255)` | 质检备注 | 质检备注 | YES | NULL | DB/DDL/实体注释 |
| `org_item_lid` | `bigint` | 原物品lid | 原物品lid | YES | NULL | DB/DDL/实体注释 |
| `delivery_price` | `decimal(24,6)` | 配送单价 | 配送单价 | YES | NULL | DB/DDL/实体注释 |
| `delivery_amount` | `decimal(24,6)` | 配送金额 | 配送金额 | YES | NULL | DB/DDL/实体注释 |
| `delivery_tax` | `decimal(24,6)` | 配送税率 | 配送税率 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,6)` | 原物品数量 | 原物品数量 | YES | NULL | DB/DDL/实体注释 |
| `org_price` | `decimal(24,6)` | 原物品价格 | 原物品价格 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,6)` | 原物品金额 | 原物品金额 | YES | NULL | DB/DDL/实体注释 |
| `weighted` | `tinyint(1)` | 已称重 | 已称重 | NO | 0 | DB/DDL/实体注释 |
| `out_volume` | `decimal(24,6)` | 发货数量 | 发货数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | YES | 1 | DB/DDL/实体注释 |
| `rdc_order_lid` | `bigint` | 配送单lid | 配送单lid | YES | NULL | DB/DDL/实体注释 |
| `last_order_price` | `decimal(24,6)` | 最后一次入库价格 | 最后一次入库价格 | NO | 0.000000 | DB/DDL/实体注释 |
| `rdc_order_id` | `varchar(90)` | 配送单编号 | 配送单编号 | YES | NULL | DB/DDL/实体注释 |
| `poster` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counting` | `decimal(24,6)` | 基于计数单位的数量 | 基于计数单位的数量 | YES | NULL | DB/DDL/实体注释 |
| `beginning_counting_volume_of_in_warehouse` | `decimal(24,6)` | 入库仓库期初数量 | 入库仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `beginning_counting_volume_of_out_warehouse` | `decimal(24,6)` | 出库仓库期初数量 | 出库仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `in_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | YES | NULL | DB/DDL/实体注释 |
| `out_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_counting_volume_of_in_warehouse` | `decimal(24,6)` | 入库仓库结存数量 | 入库仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_counting_volume_of_out_warehouse` | `decimal(24,6)` | 出库仓库结存数量 | 出库仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `real_volume_for_counting` | `decimal(24,6)` | 基于计数单位的实盘数量 | 基于计数单位的实盘数量 | YES | NULL | DB/DDL/实体注释 |
| `org_volume_for_counting` | `decimal(24,6)` | 基于计数单位的库存数量 | 基于计数单位的库存数量 | YES | NULL | DB/DDL/实体注释 |
| `volmun_of_rofitand_loss_for_counting` | `decimal(24,6)` | 基于计数单位的盈亏数量 | 基于计数单位的盈亏数量 | YES | NULL | DB/DDL/实体注释 |
| `counting_unit_lid` | `bigint` | 计数单位lid | 计数单位lid | YES | NULL | DB/DDL/实体注释 |
| `counting_unit` | `varchar(90)` | 计数单位 | 计数单位 | YES | NULL | DB/DDL/实体注释 |
| `last_out_price` | `decimal(24,6)` | 最后一次出库单价 | 最后一次出库单价 | NO | 0.000000 | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 小类lid | 小类lid | YES | NULL | DB/DDL/实体注释 |
| `supper_type_lid` | `bigint` | 大类lid | 大类lid | YES | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(19,10)` | 订购数量 | 订购数量 | YES | NULL | DB/DDL/实体注释 |
| `tax_price` | `decimal(19,10)` | tax价格 | 1 | YES | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(19,10)` | tax金额 | 1 | YES | NULL | DB/DDL/实体注释 |
| `process_factory_lid` | `bigint` | 加工厂lid | 加工厂lid | YES | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 物品顺序 | 物品顺序 | YES | NULL | DB/DDL/实体注释 |
| `dest_sid` | `bigint` | 目的仓库sid | 目的仓库sid | YES | NULL | DB/DDL/实体注释 |
| `rdc_order_item_lid` | `bigint` | 配送物品lid | 配送物品lid | YES | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(64)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `standards` | `varchar(64)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `adjust_volume` | `decimal(19,10)` | 调整量 | 调整量 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `big_type` | `varchar(255)` | big类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `small_type` | `varchar(255)` | small类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存单据业务中的goods。 | YES | NULL | 推断 |
| `standard` | `varchar(255)` | standard | 库存单据业务中的standard。 | YES | NULL | 推断 |
| `def_unit` | `varchar(255)` | def单位 | 库存单据业务中的def单位。 | YES | NULL | 推断 |
| `total_volume` | `decimal(19, 10)` | totalvolume | 库存单据业务中的totalvolume。 | YES | NULL | 推断 |
| `comments` | `varchar(255)` | comments | 库存单据业务中的comments。 | YES | NULL | 推断 |
| `barcode` | `varchar(255)` | barcode | 库存单据业务对象的barcode。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `beginning_volume_of_warhouse` | `decimal(19, 10)` | beginningvolumeofwarhouse | 库存单据业务中的beginningvolumeofwarhouse。 | YES | NULL | 推断 |
| `beginning_amount_of_warhouse` | `decimal(19, 10)` | beginning金额ofwarhouse | 库存单据业务中的beginning金额ofwarhouse。 | YES | NULL | 推断 |
| `int_volume_of_warhouse` | `decimal(19, 10)` | intvolumeofwarhouse | 库存单据业务中的intvolumeofwarhouse。 | YES | NULL | 推断 |
| `in_amount_of_warhouse` | `decimal(19, 10)` | in金额ofwarhouse | 库存单据业务中的in金额ofwarhouse。 | YES | NULL | 推断 |
| `out_volume_of_warhouse` | `decimal(19, 10)` | outvolumeofwarhouse | 库存单据业务中的outvolumeofwarhouse。 | YES | NULL | 推断 |
| `out_amount_of_warhouse` | `decimal(19, 10)` | out金额ofwarhouse | 库存单据业务中的out金额ofwarhouse。 | YES | NULL | 推断 |
| `ending_volume_of_warhouse` | `decimal(19, 10)` | endingvolumeofwarhouse | 库存单据业务中的endingvolumeofwarhouse。 | YES | NULL | 推断 |
| `ending_amount_of_warhouse` | `decimal(19, 10)` | ending金额ofwarhouse | 库存单据业务中的ending金额ofwarhouse。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `beginning_volume_of_department` | `decimal(19, 10)` | beginningvolumeofdepartment | 库存单据业务中的beginningvolumeofdepartment。 | YES | NULL | 推断 |
| `beginning_amount_of_department` | `decimal(19, 10)` | beginning金额ofdepartment | 库存单据业务中的beginning金额ofdepartment。 | YES | NULL | 推断 |
| `int_volume_of_department` | `decimal(19, 10)` | intvolumeofdepartment | 库存单据业务中的intvolumeofdepartment。 | YES | NULL | 推断 |
| `in_amount_of_department` | `decimal(19, 10)` | in金额ofdepartment | 库存单据业务中的in金额ofdepartment。 | YES | NULL | 推断 |
| `out_volume_of_department` | `decimal(19, 10)` | outvolumeofdepartment | 库存单据业务中的outvolumeofdepartment。 | YES | NULL | 推断 |
| `out_amount_of_department` | `decimal(19, 10)` | out金额ofdepartment | 库存单据业务中的out金额ofdepartment。 | YES | NULL | 推断 |
| `ending_volume_of_department` | `decimal(19, 10)` | endingvolumeofdepartment | 库存单据业务中的endingvolumeofdepartment。 | YES | NULL | 推断 |
| `ending_amount_of_department` | `decimal(19, 10)` | ending金额ofdepartment | 库存单据业务中的ending金额ofdepartment。 | YES | NULL | 推断 |
| `Bill_type_` | `varchar(255)` | 账单类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Make_time` | `datetime` | make时间 | 库存单据业务中的make时间。 | YES | NULL | 推断 |
| `Post_time` | `datetime` | post时间 | 库存单据业务中的post时间。 | YES | NULL | 推断 |
| `Beginning_volume_of_warehouse` | `decimal(19, 10)` | beginningvolumeofwarehouse | 库存单据业务中的beginningvolumeofwarehouse。 | YES | NULL | 推断 |
| `Beginning_amount_of_warehouse` | `decimal(19, 10)` | beginning金额ofwarehouse | 库存单据业务中的beginning金额ofwarehouse。 | YES | NULL | 推断 |
| `In_volume_of_warehouse` | `decimal(19, 10)` | involumeofwarehouse | 库存单据业务中的involumeofwarehouse。 | YES | NULL | 推断 |
| `In_amount_of_warehouse` | `decimal(19, 10)` | in金额ofwarehouse | 库存单据业务中的in金额ofwarehouse。 | YES | NULL | 推断 |
| `Out_volume_of_warehouse` | `decimal(19, 10)` | outvolumeofwarehouse | 库存单据业务中的outvolumeofwarehouse。 | YES | NULL | 推断 |
| `Out_amount_of_warehouse` | `decimal(19, 10)` | out金额ofwarehouse | 库存单据业务中的out金额ofwarehouse。 | YES | NULL | 推断 |
| `Ending_volume_of_warehouse` | `decimal(19, 10)` | endingvolumeofwarehouse | 库存单据业务中的endingvolumeofwarehouse。 | YES | NULL | 推断 |
| `Ending_amount_of_warehouse` | `decimal(19, 10)` | ending金额ofwarehouse | 库存单据业务中的ending金额ofwarehouse。 | YES | NULL | 推断 |
| `In_volume_of_department` | `decimal(19, 10)` | involumeofdepartment | 库存单据业务中的involumeofdepartment。 | YES | NULL | 推断 |
| `St_bill_code` | `bigint` | st账单code | 库存单据业务对象的st账单code。 | YES | NULL | 推断 |
| `Big_type_code` | `bigint` | big类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Small_type_code` | `bigint` | small类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存单据业务对象的goodscode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |
| `Is_reduce` | `int` | isreduce | 标记库存单据业务是否启用或满足isreduce条件。 | YES | NULL | 推断 |

#### `sc_st_check_bill`

- 真实表：`sc_st_check_bill`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：盘点单据
- 表含义：盘点单据
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(64)` | 单据编号 | 单据编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 开始时间 | 开始时间 | YES | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 完成时间 | 完成时间 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库/部门编号 | 仓库/部门编号 | NO | NULL | DB/DDL/实体注释 |
| `check_for_beginning` | `tinyint(1)` | 是否为期初盘点 | 是否为期初盘点 | YES | NULL | DB/DDL/实体注释 |
| `check_for_month_end` | `tinyint(1)` | 是否为月末盘点 | 是否为月末盘点 | YES | NULL | DB/DDL/实体注释 |
| `finished` | `tinyint(1)` | 是否已过账 | 是否已过账 | YES | NULL | DB/DDL/实体注释 |
| `finisher_lid` | `bigint` | 过账人lid | 过账人lid | YES | NULL | DB/DDL/实体注释 |
| `finisher` | `varchar(255)` | 过账人 | 过账人 | YES | NULL | DB/DDL/实体注释 |
| `amount_of_balance` | `decimal(24,6)` | 结存金额 | 结存金额 | YES | NULL | DB/DDL/实体注释 |
| `amount_of_rofitand_loss` | `decimal(24,6)` | 盈亏金额 | 盈亏金额 | YES | NULL | DB/DDL/实体注释 |
| `check_in_type` | `int` | 盘点类型 | 盘点类型 | YES | NULL | DB/DDL/实体注释 |
| `account_period_lid` | `bigint` | 所属会计期间lid | 所属会计期间lid | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `pyd_lid` | `bigint` | 盘盈单lid | 盘盈单lid | YES | NULL | DB/DDL/实体注释 |
| `pkd_lid` | `bigint` | 盘亏单lid | 盘亏单lid | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `manager` | `varchar(255)` | manager | 库存单据业务中的manager。 | YES | NULL | 推断 |
| `maker` | `varchar(255)` | maker | 库存单据业务中的maker。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存单据业务中的goods。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `account_period` | `varchar(255)` | accountperiod | 库存单据业务中的accountperiod。 | YES | NULL | 推断 |
| `Warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `Manager_code` | `bigint` | managercode | 库存单据业务对象的managercode。 | YES | NULL | 推断 |
| `Maker_code` | `bigint` | makercode | 库存单据业务对象的makercode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |
| `Account_period_code` | `bigint` | accountperiodcode | 库存单据业务对象的accountperiodcode。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_st_check_bill_item`

- 真实表：`sc_st_check_bill_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：盘点单据物品
- 表含义：盘点单据物品
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 被盘物品lid | 被盘物品lid | NO | NULL | DB/DDL/实体注释 |
| `goods_id` | `varchar(255)` | 被盘物品编号 | 被盘物品编号 | NO | NULL | DB/DDL/实体注释 |
| `check_bill_lid` | `bigint` | 盘点单编号 | 盘点单编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 价格 | 价格 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | YES | NULL | DB/DDL/实体注释 |
| `real_unit_lid` | `bigint` | 实盘单位lid | 实盘单位lid | NO | NULL | DB/DDL/实体注释 |
| `real_unit` | `varchar(255)` | 实盘单位 | 实盘单位 | YES | NULL | DB/DDL/实体注释 |
| `real_volume` | `decimal(24,6)` | 实盘数量 | 实盘数量 | YES | NULL | DB/DDL/实体注释 |
| `real_amount` | `decimal(24,6)` | 实盘金额 | 实盘金额 | YES | NULL | DB/DDL/实体注释 |
| `org_price` | `decimal(24,6)` | 库存单价 | 库存单价 | YES | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,6)` | 库存数量 | 库存数量 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,6)` | 库存金额 | 库存金额 | YES | NULL | DB/DDL/实体注释 |
| `volmun_of_rofitand_loss` | `decimal(24,6)` | 盈亏数量 | 盈亏数量 | YES | NULL | DB/DDL/实体注释 |
| `amount_of_rofitand_loss` | `decimal(24,6)` | 盈亏金额 | 盈亏金额 | YES | NULL | DB/DDL/实体注释 |
| `prohibit` | `tinyint(1)` | 是否禁盘 | 是否禁盘 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `goods_type_lid` | `bigint` | 物品类别 | 物品类别 | NO | -1 | DB/DDL/实体注释 |
| `real_volume_for_counting` | `decimal(24,6)` | 基于计数单位的实盘数量 | 基于计数单位的实盘数量 | YES | NULL | DB/DDL/实体注释 |
| `org_volume_for_counting` | `decimal(24,6)` | 基于计数单位的库存数量 | 基于计数单位的库存数量 | YES | NULL | DB/DDL/实体注释 |
| `volmun_of_rofitand_loss_for_counting` | `decimal(24,6)` | 基于计数单位的盈亏数量 | 基于计数单位的盈亏数量 | YES | NULL | DB/DDL/实体注释 |
| `counting_unit_lid` | `bigint` | 计数单位lid | 计数单位lid | YES | NULL | DB/DDL/实体注释 |
| `counting_unit` | `varchar(90)` | 计数单位 | 计数单位 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | NO | 1 | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `big_type` | `varchar(255)` | big类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `small_type` | `varchar(255)` | small类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存单据业务中的goods。 | YES | NULL | 推断 |
| `standard` | `varchar(255)` | standard | 库存单据业务中的standard。 | YES | NULL | 推断 |
| `Real_unit` | `varchar(255)` | real单位 | 库存单据业务中的real单位。 | YES | NULL | 推断 |
| `Check_bill_id` | `bigint` | check账单ID | 库存单据业务关联的check账单ID。 | YES | NULL | 推断 |
| `Big_type_code` | `bigint` | big类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Small_type_code` | `bigint` | small类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存单据业务对象的goodscode。 | YES | NULL | 推断 |
| `Amount` | `decimal(19, 10)` | 金额 | 库存单据业务中的金额。 | YES | NULL | 推断 |
| `Org_price` | `decimal(19, 10)` | org价格 | 库存单据业务中的org价格。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |

### gylregdb

#### `sc_st_convert_bill`

- 真实表：`sc_st_convert_bill`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 库存单据业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 库存单据业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 库存单据业务中的day。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `comments` | `varchar(255)` | comments | 库存单据业务中的comments。 | YES | NULL | 推断 |
| `maker` | `varchar(255)` | maker | 库存单据业务中的maker。 | YES | NULL | 推断 |
| `manager` | `varchar(255)` | manager | 库存单据业务中的manager。 | YES | NULL | 推断 |
| `make_time` | `datetime` | make时间 | 库存单据业务中的make时间。 | YES | NULL | 推断 |
| `post_time` | `datetime` | post时间 | 库存单据业务中的post时间。 | YES | NULL | 推断 |
| `poster` | `varchar(255)` | poster | 库存单据业务中的poster。 | YES | NULL | 推断 |
| `posted` | `varchar(64)` | posted | 库存单据业务中的posted。 | YES | NULL | 推断 |
| `post_id` | `int` | postID | 库存单据业务关联的postID。 | YES | NULL | 推断 |
| `last_mode_time` | `datetime` | 上次mode时间 | 库存单据业务中的上次mode时间。 | YES | NULL | 推断 |
| `total_amount` | `decimal(19,10)` | total金额 | 库存单据业务中的total金额。 | YES | NULL | 推断 |
| `total_volume` | `decimal(19,10)` | totalvolume | 库存单据业务中的totalvolume。 | YES | NULL | 推断 |
| `ref_flag` | `varchar(64)` | refflag | 库存单据业务中的refflag。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `org_id` | `varchar(255)` | orgID | 库存单据业务关联的orgID。 | YES | NULL | 推断 |
| `aotu_maked` | `tinyint` | aotumaked | 库存单据业务中的aotumaked。 | YES | NULL | 推断 |
| `check_bill_id` | `varchar(255)` | check账单ID | 库存单据业务关联的check账单ID。 | YES | NULL | 推断 |
| `book_bill_id` | `varchar(255)` | book账单ID | 库存单据业务关联的book账单ID。 | YES | NULL | 推断 |
| `account_period` | `varchar(255)` | accountperiod | 库存单据业务中的accountperiod。 | YES | NULL | 推断 |
| `delivery_bill_id` | `varchar(255)` | delivery账单ID | 库存单据业务关联的delivery账单ID。 | YES | NULL | 推断 |
| `xfd_id` | `varchar(255)` | xfdID | 库存单据业务关联的xfdID。 | YES | NULL | 推断 |
| `printed_count` | `int` | printed次数 | 库存单据业务中的printed次数。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |
| `Maker_code` | `bigint` | makercode | 库存单据业务对象的makercode。 | YES | NULL | 推断 |
| `Manager_code` | `bigint` | managercode | 库存单据业务对象的managercode。 | YES | NULL | 推断 |
| `Poster_code` | `bigint` | postercode | 库存单据业务对象的postercode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Account_period_code` | `bigint` | accountperiodcode | 库存单据业务对象的accountperiodcode。 | YES | NULL | 推断 |

#### `sc_st_convert_bill_item_in`

- 真实表：`sc_st_convert_bill_item_in`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 库存单据业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 库存单据业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 库存单据业务中的day。 | YES | NULL | 推断 |
| `make_time` | `datetime` | make时间 | 库存单据业务中的make时间。 | YES | NULL | 推断 |
| `post_time` | `datetime` | post时间 | 库存单据业务中的post时间。 | YES | NULL | 推断 |
| `big_type` | `varchar(255)` | big类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `small_type` | `varchar(255)` | small类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存单据业务中的goods。 | YES | NULL | 推断 |
| `item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |
| `standard` | `varchar(255)` | standard | 库存单据业务中的standard。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 库存单据业务中的单位。 | YES | NULL | 推断 |
| `volume` | `decimal(19,10)` | volume | 库存单据业务中的volume。 | YES | NULL | 推断 |
| `def_unit` | `varchar(255)` | def单位 | 库存单据业务中的def单位。 | YES | NULL | 推断 |
| `actual_volume` | `decimal(19,10)` | actualvolume | 库存单据业务中的actualvolume。 | YES | NULL | 推断 |
| `total_volume` | `decimal(19,10)` | totalvolume | 库存单据业务中的totalvolume。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | 库存单据业务中的价格。 | YES | NULL | 推断 |
| `amount` | `decimal(19,10)` | 金额 | 库存单据业务中的金额。 | YES | NULL | 推断 |
| `base_unit` | `varchar(255)` | base单位 | 库存单据业务中的base单位。 | YES | NULL | 推断 |
| `volume_of_base_unit` | `decimal(19,10)` | volumeofbase单位 | 库存单据业务中的volumeofbase单位。 | YES | NULL | 推断 |
| `price_of_base_unit` | `decimal(19,10)` | 价格ofbase单位 | 库存单据业务中的价格ofbase单位。 | YES | NULL | 推断 |
| `barcode` | `varchar(255)` | barcode | 库存单据业务对象的barcode。 | YES | NULL | 推断 |
| `old_price` | `decimal(19,10)` | old价格 | 库存单据业务中的old价格。 | YES | NULL | 推断 |
| `new_price` | `decimal(19,10)` | new价格 | 库存单据业务中的new价格。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `beginning_volume_of_warehouse` | `decimal(19,10)` | beginningvolumeofwarehouse | 库存单据业务中的beginningvolumeofwarehouse。 | YES | NULL | 推断 |
| `beginning_amount_of_warehouse` | `decimal(19,10)` | beginning金额ofwarehouse | 库存单据业务中的beginning金额ofwarehouse。 | YES | NULL | 推断 |
| `in_volume_of_warehouse` | `decimal(19,10)` | involumeofwarehouse | 库存单据业务中的involumeofwarehouse。 | YES | NULL | 推断 |
| `in_amount_of_warehouse` | `decimal(19,10)` | in金额ofwarehouse | 库存单据业务中的in金额ofwarehouse。 | YES | NULL | 推断 |
| `out_volume_of_warehouse` | `decimal(19,10)` | outvolumeofwarehouse | 库存单据业务中的outvolumeofwarehouse。 | YES | NULL | 推断 |
| `out_amount_of_warehouse` | `decimal(19,10)` | out金额ofwarehouse | 库存单据业务中的out金额ofwarehouse。 | YES | NULL | 推断 |
| `ending_volume_of_warehouse` | `decimal(19,10)` | endingvolumeofwarehouse | 库存单据业务中的endingvolumeofwarehouse。 | YES | NULL | 推断 |
| `ending_amount_of_warehouse` | `decimal(19,10)` | ending金额ofwarehouse | 库存单据业务中的ending金额ofwarehouse。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `beginning_volume_of_department` | `decimal(19,10)` | beginningvolumeofdepartment | 库存单据业务中的beginningvolumeofdepartment。 | YES | NULL | 推断 |
| `beginning_amount_of_department` | `decimal(19,10)` | beginning金额ofdepartment | 库存单据业务中的beginning金额ofdepartment。 | YES | NULL | 推断 |
| `in_volume_of_department` | `decimal(19,10)` | involumeofdepartment | 库存单据业务中的involumeofdepartment。 | YES | NULL | 推断 |
| `in_amount_of_department` | `decimal(19,10)` | in金额ofdepartment | 库存单据业务中的in金额ofdepartment。 | YES | NULL | 推断 |
| `out_volume_of_department` | `decimal(19,10)` | outvolumeofdepartment | 库存单据业务中的outvolumeofdepartment。 | YES | NULL | 推断 |
| `out_amount_of_department` | `decimal(19,10)` | out金额ofdepartment | 库存单据业务中的out金额ofdepartment。 | YES | NULL | 推断 |
| `ending_volume_of_department` | `decimal(19,10)` | endingvolumeofdepartment | 库存单据业务中的endingvolumeofdepartment。 | YES | NULL | 推断 |
| `ending_amount_of_department` | `decimal(19,10)` | ending金额ofdepartment | 库存单据业务中的ending金额ofdepartment。 | YES | NULL | 推断 |
| `comments` | `varchar(255)` | comments | 库存单据业务中的comments。 | YES | NULL | 推断 |
| `St_bill_code` | `bigint` | st账单code | 库存单据业务对象的st账单code。 | YES | NULL | 推断 |
| `Big_type_code` | `bigint` | big类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Small_type_code` | `bigint` | small类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存单据业务对象的goodscode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |

#### `sc_st_convert_bill_item_out`

- 真实表：`sc_st_convert_bill_item_out`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 库存单据业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 库存单据业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 库存单据业务中的day。 | YES | NULL | 推断 |
| `make_time` | `datetime` | make时间 | 库存单据业务中的make时间。 | YES | NULL | 推断 |
| `post_time` | `datetime` | post时间 | 库存单据业务中的post时间。 | YES | NULL | 推断 |
| `big_type` | `varchar(255)` | big类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `small_type` | `varchar(255)` | small类型 | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `goods` | `varchar(255)` | goods | 库存单据业务中的goods。 | YES | NULL | 推断 |
| `item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |
| `standard` | `varchar(255)` | standard | 库存单据业务中的standard。 | YES | NULL | 推断 |
| `unit` | `varchar(255)` | 单位 | 库存单据业务中的单位。 | YES | NULL | 推断 |
| `volume` | `decimal(19,10)` | volume | 库存单据业务中的volume。 | YES | NULL | 推断 |
| `def_unit` | `varchar(255)` | def单位 | 库存单据业务中的def单位。 | YES | NULL | 推断 |
| `actual_volume` | `decimal(19,10)` | actualvolume | 库存单据业务中的actualvolume。 | YES | NULL | 推断 |
| `total_volume` | `decimal(19,10)` | totalvolume | 库存单据业务中的totalvolume。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | 库存单据业务中的价格。 | YES | NULL | 推断 |
| `amount` | `decimal(19,10)` | 金额 | 库存单据业务中的金额。 | YES | NULL | 推断 |
| `base_unit` | `varchar(255)` | base单位 | 库存单据业务中的base单位。 | YES | NULL | 推断 |
| `volume_of_base_unit` | `decimal(19,10)` | volumeofbase单位 | 库存单据业务中的volumeofbase单位。 | YES | NULL | 推断 |
| `price_of_base_unit` | `decimal(19,10)` | 价格ofbase单位 | 库存单据业务中的价格ofbase单位。 | YES | NULL | 推断 |
| `barcode` | `varchar(255)` | barcode | 库存单据业务对象的barcode。 | YES | NULL | 推断 |
| `old_price` | `decimal(19,10)` | old价格 | 库存单据业务中的old价格。 | YES | NULL | 推断 |
| `new_price` | `decimal(19,10)` | new价格 | 库存单据业务中的new价格。 | YES | NULL | 推断 |
| `warehouse` | `varchar(255)` | warehouse | 库存单据业务中的warehouse。 | YES | NULL | 推断 |
| `beginning_volume_of_warehouse` | `decimal(19,10)` | beginningvolumeofwarehouse | 库存单据业务中的beginningvolumeofwarehouse。 | YES | NULL | 推断 |
| `beginning_amount_of_warehouse` | `decimal(19,10)` | beginning金额ofwarehouse | 库存单据业务中的beginning金额ofwarehouse。 | YES | NULL | 推断 |
| `in_volume_of_warehouse` | `decimal(19,10)` | involumeofwarehouse | 库存单据业务中的involumeofwarehouse。 | YES | NULL | 推断 |
| `in_amount_of_warehouse` | `decimal(19,10)` | in金额ofwarehouse | 库存单据业务中的in金额ofwarehouse。 | YES | NULL | 推断 |
| `out_volume_of_warehouse` | `decimal(19,10)` | outvolumeofwarehouse | 库存单据业务中的outvolumeofwarehouse。 | YES | NULL | 推断 |
| `out_amount_of_warehouse` | `decimal(19,10)` | out金额ofwarehouse | 库存单据业务中的out金额ofwarehouse。 | YES | NULL | 推断 |
| `ending_volume_of_warehouse` | `decimal(19,10)` | endingvolumeofwarehouse | 库存单据业务中的endingvolumeofwarehouse。 | YES | NULL | 推断 |
| `ending_amount_of_warehouse` | `decimal(19,10)` | ending金额ofwarehouse | 库存单据业务中的ending金额ofwarehouse。 | YES | NULL | 推断 |
| `department` | `varchar(255)` | department | 库存单据业务中的department。 | YES | NULL | 推断 |
| `beginning_volume_of_department` | `decimal(19,10)` | beginningvolumeofdepartment | 库存单据业务中的beginningvolumeofdepartment。 | YES | NULL | 推断 |
| `beginning_amount_of_department` | `decimal(19,10)` | beginning金额ofdepartment | 库存单据业务中的beginning金额ofdepartment。 | YES | NULL | 推断 |
| `in_volume_of_department` | `decimal(19,10)` | involumeofdepartment | 库存单据业务中的involumeofdepartment。 | YES | NULL | 推断 |
| `in_amount_of_department` | `decimal(19,10)` | in金额ofdepartment | 库存单据业务中的in金额ofdepartment。 | YES | NULL | 推断 |
| `out_volume_of_department` | `decimal(19,10)` | outvolumeofdepartment | 库存单据业务中的outvolumeofdepartment。 | YES | NULL | 推断 |
| `out_amount_of_department` | `decimal(19,10)` | out金额ofdepartment | 库存单据业务中的out金额ofdepartment。 | YES | NULL | 推断 |
| `ending_volume_of_department` | `decimal(19,10)` | endingvolumeofdepartment | 库存单据业务中的endingvolumeofdepartment。 | YES | NULL | 推断 |
| `ending_amount_of_department` | `decimal(19,10)` | ending金额ofdepartment | 库存单据业务中的ending金额ofdepartment。 | YES | NULL | 推断 |
| `comments` | `varchar(255)` | comments | 库存单据业务中的comments。 | YES | NULL | 推断 |
| `St_bill_code` | `bigint` | st账单code | 库存单据业务对象的st账单code。 | YES | NULL | 推断 |
| `Big_type_code` | `bigint` | big类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Small_type_code` | `bigint` | small类型code | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `Goods_code` | `bigint` | goodscode | 库存单据业务对象的goodscode。 | YES | NULL | 推断 |
| `Warehouse_code` | `bigint` | warehousecode | 库存单据业务对象的warehousecode。 | YES | NULL | 推断 |
| `Department_code` | `bigint` | departmentcode | 库存单据业务对象的departmentcode。 | YES | NULL | 推断 |

### a_wms

#### `sc_st_goods_day_book`

- 真实表：`sc_st_goods_day_book`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品流水账
- 表含义：物品流水账
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `bill_type_` | `int` | 票据类型 | 票据类型 | NO | NULL | DB/DDL/实体注释 |
| `st_bill_lid` | `bigint` | 仓库单据lid | 仓库单据lid | NO | NULL | DB/DDL/实体注释 |
| `st_bill_id` | `varchar(90)` | 仓库单据编号 | 仓库单据编号 | NO | NULL | DB/DDL/实体注释 |
| `make_time` | `datetime` | 开票时间 | 开票时间 | NO | NULL | DB/DDL/实体注释 |
| `post_time` | `datetime` | 过帐日期 | 过帐日期 | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | YES | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `take_warehouse_lid` | `bigint` | 领用仓库编号 | 领用仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `goods_id` | `varchar(255)` | 物品编号 | 物品编号 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `unit_type` | `int` | 单位类型 | 单位类型 | NO | NULL | DB/DDL/实体注释 |
| `actual_volume` | `decimal(24,6)` | 到货数量 | 到货数量（用于采购订货） | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 单价 | 单价 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | NULL | DB/DDL/实体注释 |
| `base_unit_lid` | `bigint` | 基本单位lid | 基本单位lid | NO | NULL | DB/DDL/实体注释 |
| `base_unit` | `varchar(90)` | 基本单位 | 基本单位 | NO | NULL | DB/DDL/实体注释 |
| `volume_of_base_unit` | `decimal(24,6)` | 基本数量 | 基本数量 | NO | NULL | DB/DDL/实体注释 |
| `price_of_base_unit` | `decimal(24,6)` | 基本单价 | 基本单价 | NO | NULL | DB/DDL/实体注释 |
| `old_price` | `decimal(24,6)` | 原库存价 | 原库存价 | YES | NULL | DB/DDL/实体注释 |
| `new_price` | `decimal(24,6)` | 新库存价 | 新库存价 | YES | NULL | DB/DDL/实体注释 |
| `beginning_volume_of_warehouse` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | NO | NULL | DB/DDL/实体注释 |
| `beginning_amount_of_warehouse` | `decimal(24,6)` | 仓库期初金额 | 仓库期初金额 | NO | NULL | DB/DDL/实体注释 |
| `in_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | NO | NULL | DB/DDL/实体注释 |
| `in_amount_of_warehouse` | `decimal(24,6)` | 仓库收入金额 | 仓库收入金额 | NO | NULL | DB/DDL/实体注释 |
| `out_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | NO | NULL | DB/DDL/实体注释 |
| `out_amount_of_warehouse` | `decimal(24,6)` | 仓库发出金额 | 仓库发出金额 | NO | NULL | DB/DDL/实体注释 |
| `ending_volume_of_warehouse` | `decimal(24,6)` | 仓库结存数量 | 仓库结存数量 | NO | NULL | DB/DDL/实体注释 |
| `ending_amount_of_warehouse` | `decimal(24,6)` | 仓库结存金额 | 仓库结存金额 | NO | NULL | DB/DDL/实体注释 |
| `account_period_lid` | `bigint` | 所属会计期间编号 | 所属会计期间编号 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `production_date` | `datetime` | 生产日期 | 生产日期 | YES | NULL | DB/DDL/实体注释 |
| `batch_no` | `varchar(90)` | 批次号 | 批次号 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,6)` | 税率 | 税率 | NO | NULL | DB/DDL/实体注释 |
| `posted` | `int` | 是否过账 | 是否过账 | NO | NULL | DB/DDL/实体注释 |
| `ref_flag` | `int` | 是否冲红 | 是否冲红 | NO | NULL | DB/DDL/实体注释 |
| `qi_state` | `int` | 质检状态 | 质检状态 | NO | NULL | DB/DDL/实体注释 |
| `qi_volume` | `tinyint(1)` | 质检-数量 | 质检-数量 | NO | NULL | DB/DDL/实体注释 |
| `qi_time` | `tinyint(1)` | 质检-时间 | 质检-时间 | NO | NULL | DB/DDL/实体注释 |
| `qi_mass` | `tinyint(1)` | 质检-质量 | 质检-质量 | NO | NULL | DB/DDL/实体注释 |
| `qi_remark` | `varchar(255)` | 质检备注 | 质检备注 | YES | NULL | DB/DDL/实体注释 |
| `org_item_lid` | `bigint` | 原物品lid | 原物品lid | YES | NULL | DB/DDL/实体注释 |
| `delivery_price` | `decimal(24,6)` | 配送单价 | 配送单价 | YES | NULL | DB/DDL/实体注释 |
| `delivery_amount` | `decimal(24,6)` | 配送金额 | 配送金额 | YES | NULL | DB/DDL/实体注释 |
| `delivery_tax` | `decimal(24,6)` | 配送税率 | 配送税率 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | YES | 1 | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 物品小类lid | 物品小类lid | YES | NULL | DB/DDL/实体注释 |
| `supper_type_lid` | `bigint` | 物品大类lid | 物品大类lid | YES | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,6)` | 原订购数量 | 原订购数量 | YES | NULL | DB/DDL/实体注释 |
| `org_price` | `decimal(24,6)` | 原订购价格 | 原订购价格 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,6)` | 原订购总额 | 原订购总额 | YES | NULL | DB/DDL/实体注释 |
| `bill_date` | `datetime` | 开票日期 | 开票日期 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counting` | `decimal(24,6)` | 基于计数单位基本数量 | 基于计数单位基本数量 | YES | NULL | DB/DDL/实体注释 |
| `beginning_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `in_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | YES | NULL | DB/DDL/实体注释 |
| `out_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库结存数量 | 仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `dest_sid` | `bigint` | 目的仓库sid | 目的仓库sid | YES | NULL | DB/DDL/实体注释 |
| `standards` | `varchar(64)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(64)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `bigint` | 原始单据编号 | 原始单据编号 | YES | NULL | DB/DDL/实体注释 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO |  | DB/DDL/实体注释 |
| `yingyeriqi` | `datetime` | 营业日期 | 营业日期 | YES | NULL | DB/DDL/实体注释 |
| `st_bill_code` | `bigint` | 仓库单据编号 | 仓库单据编号 | YES | NULL | DB/DDL/实体注释 |
| `type_code` | `bigint` | 物品类别编号 | 物品类别编号 | YES | NULL | DB/DDL/实体注释 |
| `goods_code` | `bigint` | 物品编号 | 物品编号 | YES | NULL | DB/DDL/实体注释 |
| `goods` | `varchar(255)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `standard` | `varchar(255)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_code` | `bigint` | 仓库编号 | 仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `comments` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `client_code` | `bigint` | 客户编号 | 客户编号 | YES | NULL | DB/DDL/实体注释 |
| `supplier_code` | `bigint` | 供应商编号 | 供应商编号 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |

#### `sc_st_goods_summary`

- 真实表：`sc_st_goods_summary`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品汇总账
- 表含义：物品汇总账
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `period_lid` | `bigint` | 会计周期lid | 会计周期lid | NO | NULL | DB/DDL/实体注释 |
| `goods_id` | `varchar(255)` | 物品编号 | 物品编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 物品小类lid | 物品小类lid | YES | NULL | DB/DDL/实体注释 |
| `supper_type_lid` | `bigint` | 物品大类lid | 物品大类lid | YES | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counting` | `decimal(24,6)` | 基于计数单位的数量 | 基于计数单位的数量 | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 单价 | 单价 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `beginning_volume_of_warehouse` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | NO | NULL | DB/DDL/实体注释 |
| `beginning_amount_of_warehouse` | `decimal(24,6)` | 仓库期初金额 | 仓库期初金额 | NO | NULL | DB/DDL/实体注释 |
| `in_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | NO | NULL | DB/DDL/实体注释 |
| `in_amount_of_warehouse` | `decimal(24,6)` | 仓库收入金额 | 仓库收入金额 | NO | NULL | DB/DDL/实体注释 |
| `out_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | NO | NULL | DB/DDL/实体注释 |
| `out_amount_of_warehouse` | `decimal(24,6)` | 仓库发出金额 | 仓库发出金额 | NO | NULL | DB/DDL/实体注释 |
| `ending_volume_of_warehouse` | `decimal(24,6)` | 仓库结存数量 | 仓库结存数量 | NO | NULL | DB/DDL/实体注释 |
| `ending_amount_of_warehouse` | `decimal(24,6)` | 仓库结存金额 | 仓库结存金额 | NO | NULL | DB/DDL/实体注释 |
| `check_volume` | `decimal(24,6)` | 仓库盘点数量 | 仓库盘点数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `check_amount` | `decimal(24,6)` | 仓库盘点金额 | 仓库盘点金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `check_in_volume` | `decimal(24,6)` | 仓库盘点盈收数量 | 仓库盘点盈收数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `check_in_amount` | `decimal(24,6)` | 仓库盘点盈收金额 | 仓库盘点盈收金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `check_out_volume` | `decimal(24,6)` | 仓库盘点亏损数量 | 仓库盘点亏损数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `check_out_amount` | `decimal(24,6)` | 仓库盘点亏损金额 | 仓库盘点亏损金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `init_check_volume` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `init_check_amount` | `decimal(24,6)` | 仓库期初金额 | 仓库期初金额 | NO | 0.000000 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | 0 | DB/DDL/实体注释 |
| `beginning_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | YES | NULL | DB/DDL/实体注释 |
| `in_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库收入数量 | 仓库收入数量 | YES | NULL | DB/DDL/实体注释 |
| `out_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库发出数量 | 仓库发出数量 | YES | NULL | DB/DDL/实体注释 |
| `ending_counting_volume_of_warehouse` | `decimal(24,6)` | 仓库结存数量 | 仓库结存数量 | YES | NULL | DB/DDL/实体注释 |
| `check_counting_volume` | `decimal(24,6)` | 仓库盘点数量 | 仓库盘点数量 | YES | 0.000000 | DB/DDL/实体注释 |
| `check_in_counting_volume` | `decimal(24,6)` | 仓库盘点盈收数量 | 仓库盘点盈收数量 | YES | 0.000000 | DB/DDL/实体注释 |
| `check_out_counting_volume` | `decimal(24,6)` | 仓库盘点亏损数量 | 仓库盘点亏损数量 | YES | 0.000000 | DB/DDL/实体注释 |
| `init_check_counting_volume` | `decimal(24,6)` | 仓库期初数量 | 仓库期初数量 | YES | 0.000000 | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |
| `goods_name` | `varchar(64)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `standards` | `varchar(64)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | lmn内部编号 | lmn内部编号 | NO |  | DB/DDL/实体注释 |
| `name` | `varchar(255)` | 仓库业务单中的商品明细名称 | 仓库业务单中的商品明细名称 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 记录状态 | 记录状态 | YES | NULL | DB/DDL/实体注释 |
| `period_id` | `bigint` | 会计周期 | 会计周期 | YES | NULL | DB/DDL/实体注释 |
| `period` | `varchar(255)` | 会计名称 | 会计名称 | YES | NULL | DB/DDL/实体注释 |
| `type` | `varchar(255)` | 物品类型名称 | 物品类型名称 | YES | NULL | DB/DDL/实体注释 |
| `type_id` | `bigint` | 类型编号 | 类型编号 | YES | NULL | DB/DDL/实体注释 |
| `goods` | `varchar(255)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `item_number` | `varchar(255)` | 物品货号 | 物品货号 | YES | NULL | DB/DDL/实体注释 |
| `standard` | `varchar(255)` | 规格 | 规格 | YES | NULL | DB/DDL/实体注释 |
| `barcode` | `varchar(255)` | 条码 | 条码 | YES | NULL | DB/DDL/实体注释 |
| `warehouse` | `varchar(255)` | 仓库 | 仓库 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_id` | `bigint` | 仓库编号 | 仓库编号 | YES | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_st_item_change`

- 真实表：`sc_st_item_change`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `year` | `int` | year | 库存单据业务中的year。 | YES | NULL | 推断 |
| `month` | `int` | month | 库存单据业务中的month。 | YES | NULL | 推断 |
| `day` | `int` | day | 库存单据业务中的day。 | YES | NULL | 推断 |
| `xiafeicaipingid` | `varchar(255)` | xiafeicaipingid | 库存单据业务中的xiafeicaipingid。 | YES | NULL | 推断 |
| `shopname` | `varchar(255)` | shopname | 库存单据业务对象的shopname。 | YES | NULL | 推断 |
| `xiafeicaipingname` | `varchar(255)` | xiafeicaipingname | 库存单据业务对象的xiafeicaipingname。 | YES | NULL | 推断 |
| `xiaoleiid` | `varchar(255)` | xiaoleiid | 库存单据业务中的xiaoleiid。 | YES | NULL | 推断 |
| `xiaolei` | `varchar(255)` | xiaolei | 库存单据业务中的xiaolei。 | YES | NULL | 推断 |
| `daleiid` | `varchar(255)` | daleiid | 库存单据业务中的daleiid。 | YES | NULL | 推断 |
| `dalei` | `varchar(255)` | dalei | 库存单据业务中的dalei。 | YES | NULL | 推断 |
| `xiaofeishuliang` | `decimal(19,10)` | xiaofeishuliang | 库存单据业务中的xiaofeishuliang。 | YES | NULL | 推断 |
| `danwei` | `varchar(255)` | danwei | 库存单据业务中的danwei。 | YES | NULL | 推断 |
| `jibendanwei` | `varchar(255)` | jibendanwei | 库存单据业务中的jibendanwei。 | YES | NULL | 推断 |
| `danweibilv` | `decimal(19,10)` | danweibilv | 库存单据业务中的danweibilv。 | YES | NULL | 推断 |
| `jiage` | `decimal(19,10)` | jiage | 库存单据业务中的jiage。 | YES | NULL | 推断 |
| `diancaishijian` | `datetime` | diancaishijian | 库存单据业务中的diancaishijian。 | YES | NULL | 推断 |
| `subed` | `tinyint` | subed | 库存单据业务中的subed。 | YES | NULL | 推断 |
| `caipingtype` | `int` | caipingtype | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 库存单据业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `autosale` | `tinyint` | autosale | 库存单据业务中的autosale。 | YES | NULL | 推断 |
| `st_bill_code` | `bigint` | st账单code | 库存单据业务对象的st账单code。 | YES | NULL | 推断 |
| `upload` | `tinyint` | upload | 库存单据业务中的upload。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Xfcp_lmnid` | `varchar(255)` | xfcplmnid | 库存单据业务中的xfcplmnid。 | YES | NULL | 推断 |
| `Upload_time` | `datetime` | upload时间 | 库存单据业务中的upload时间。 | YES | NULL | 推断 |

#### `sc_st_item_change_fjz`

- 真实表：`sc_st_item_change_fjz`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `xiafeicaipingid` | `varchar(255)` | xiafeicaipingid | 库存单据业务中的xiafeicaipingid。 | YES | NULL | 推断 |
| `shopname` | `varchar(255)` | shopname | 库存单据业务对象的shopname。 | YES | NULL | 推断 |
| `xiafeicaipingname` | `varchar(255)` | xiafeicaipingname | 库存单据业务对象的xiafeicaipingname。 | YES | NULL | 推断 |
| `xiaoleiid` | `varchar(255)` | xiaoleiid | 库存单据业务中的xiaoleiid。 | YES | NULL | 推断 |
| `xiaolei` | `varchar(255)` | xiaolei | 库存单据业务中的xiaolei。 | YES | NULL | 推断 |
| `daleiid` | `varchar(255)` | daleiid | 库存单据业务中的daleiid。 | YES | NULL | 推断 |
| `dalei` | `varchar(255)` | dalei | 库存单据业务中的dalei。 | YES | NULL | 推断 |
| `xiaofeishuliang` | `decimal(19,10)` | xiaofeishuliang | 库存单据业务中的xiaofeishuliang。 | YES | NULL | 推断 |
| `danwei` | `varchar(255)` | danwei | 库存单据业务中的danwei。 | YES | NULL | 推断 |
| `jibendanwei` | `varchar(255)` | jibendanwei | 库存单据业务中的jibendanwei。 | YES | NULL | 推断 |
| `danweibilv` | `decimal(19,10)` | danweibilv | 库存单据业务中的danweibilv。 | YES | NULL | 推断 |
| `jiage` | `decimal(19,10)` | jiage | 库存单据业务中的jiage。 | YES | NULL | 推断 |
| `diancaishijian` | `datetime` | diancaishijian | 库存单据业务中的diancaishijian。 | YES | NULL | 推断 |
| `baoshunshuliang` | `decimal(19,10)` | baoshunshuliang | 库存单据业务中的baoshunshuliang。 | YES | NULL | 推断 |
| `subed` | `tinyint` | subed | 库存单据业务中的subed。 | YES | NULL | 推断 |
| `caipingtype` | `int` | caipingtype | 库存单据业务分类或类型。 | YES | NULL | 推断 |
| `item_number` | `varchar(255)` | item数量 | 库存单据业务中的item数量。 | YES | NULL | 推断 |
| `xiaofeidanid` | `varchar(255)` | xiaofeidanid | 库存单据业务中的xiaofeidanid。 | YES | NULL | 推断 |
| `autosale` | `tinyint` | autosale | 库存单据业务中的autosale。 | YES | NULL | 推断 |
| `st_bill_code` | `bigint` | st账单code | 库存单据业务对象的st账单code。 | YES | NULL | 推断 |
| `upload` | `tinyint` | upload | 库存单据业务中的upload。 | YES | NULL | 推断 |
| `dealed` | `tinyint` | dealed | 库存单据业务中的dealed。 | YES | NULL | 推断 |
| `deal_time` | `datetime` | deal时间 | 库存单据业务中的deal时间。 | YES | NULL | 推断 |
| `deal_opr` | `varchar(255)` | dealopr | 库存单据业务中的dealopr。 | YES | NULL | 推断 |
| `deal_opr_code` | `varchar(255)` | dealoprcode | 库存单据业务对象的dealoprcode。 | YES | NULL | 推断 |
| `yingyeriqi` | `datetime` | yingyeriqi | 库存单据业务中的yingyeriqi。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |
| `Xfcp_lmnid` | `varchar(255)` | xfcplmnid | 库存单据业务中的xfcplmnid。 | YES | NULL | 推断 |

### a_wms

#### `sc_st_type_summary`

- 真实表：`sc_st_type_summary`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品单据类型汇总
- 表含义：物品单据类型汇总
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 营业日期 | 营业日期 | NO | NULL | DB/DDL/实体注释 |
| `year` | `int` | 年 | 年 | NO | NULL | DB/DDL/实体注释 |
| `month` | `int` | 月 | 月 | NO | NULL | DB/DDL/实体注释 |
| `day` | `int` | 日 | 日 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 单据类型 | 单据类型 | NO | NULL | DB/DDL/实体注释 |
| `period_lid` | `bigint` | 会计周期lid | 会计周期lid | NO | NULL | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 物品小类lid | 物品小类lid | YES | NULL | DB/DDL/实体注释 |
| `supper_type_lid` | `bigint` | 物品大类lid | 物品大类lid | YES | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `in_out_flag` | `int` | 出入库标识 | 出入库标识 | NO | 0 | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 数量 | 数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `counting_volume` | `decimal(24,6)` | 计量数量 | 计量数量 | NO | 0.000000 | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 金额 | 金额 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | NO | 0 | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | NO | NULL | DB/DDL/实体注释 |

### gylregdb

#### `sc_st_unit`

- 真实表：`sc_st_unit`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：库存单据
- 表含义：库存单据相关业务数据表。
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO | NULL | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `id` | `varchar(255)` | 主键 | 业务或数据库主键。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO | NULL | 通用字段 |
| `name` | `varchar(255)` | 名称 | 业务对象名称。 | YES | NULL | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `PIDTmp` | `bigint` | pidtmp | 库存单据业务中的pidtmp。 | YES | NULL | 推断 |

### a_wms

#### `sc_stock_snapshot_of_month`

- 真实表：`sc_stock_snapshot_of_month`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：月末转结快照
- 表含义：月末转结快照
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `period_lid` | `bigint` | 会计区间lid | 会计区间lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 库存价格 | 库存价格 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 当前数量 | 当前数量 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 当前金额 | 当前金额 | NO | NULL | DB/DDL/实体注释 |
| `unit_lid` | `bigint` | 单位lid | 单位lid | NO | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 单位 | 单位 | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 单据lid | 单据lid | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 物品的lid | 物品的lid | NO | NULL | DB/DDL/实体注释 |
| `last_stock_time` | `datetime` | 入库时间 | 入库时间 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `volume_for_counting` | `decimal(24,6)` | 当前数量 | 当前数量 | YES | NULL | DB/DDL/实体注释 |

#### `sc_store_order`

- 真实表：`sc_store_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：门店订货单
- 表含义：门店订货单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 订单编号 | 订单编号 | NO | NULL | DB/DDL/实体注释 |
| `rdc_order_lid` | `bigint` | 配送中心订货单lid | 配送中心订货单lid | YES | NULL | DB/DDL/实体注释 |
| `rdc_order_id` | `varchar(90)` | 配送中心订货单编号 | 配送中心订货单编号 | YES | NULL | DB/DDL/实体注释 |
| `merge_order_id` | `varchar(255)` | 合并后订单id | 合并后订单id | YES | NULL | DB/DDL/实体注释 |
| `merge_order_lid` | `bigint` | 合并后的订单lid | 合并后的订单lid | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 记录数 | 记录数 | NO | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 总数量 | 总数量 | NO | NULL | DB/DDL/实体注释 |
| `tax_amount` | `decimal(24,6)` | 含税金额 | 含税金额 | NO | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 总金额 | 总金额 | NO | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,6)` | 订购数量 | 订购数量 | NO | NULL | DB/DDL/实体注释 |
| `audit_lid` | `bigint` | 审核人lid | 审核人lid | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `reject_lid` | `bigint` | 驳回人lid | 驳回人lid | YES | NULL | DB/DDL/实体注释 |
| `reject_by` | `varchar(90)` | 驳回人 | 驳回人 | YES | NULL | DB/DDL/实体注释 |
| `reject_time` | `datetime` | 驳回时间 | 驳回时间 | YES | NULL | DB/DDL/实体注释 |
| `submit_lid` | `bigint` | 提交人lid | 提交人lid | YES | NULL | DB/DDL/实体注释 |
| `submit_by` | `varchar(90)` | 提交人 | 提交人 | YES | NULL | DB/DDL/实体注释 |
| `submit_time` | `datetime` | 提交时间 | 提交时间 | YES | NULL | DB/DDL/实体注释 |
| `rdc_audit_lid` | `bigint` | 配送中心审核人lid | 配送中心审核人lid | YES | NULL | DB/DDL/实体注释 |
| `rdc_audit_by` | `varchar(90)` | 配送中心审核人 | 配送中心审核人 | YES | NULL | DB/DDL/实体注释 |
| `rdc_audit_time` | `datetime` | 配送中心审核时间 | 配送中心审核时间 | YES | NULL | DB/DDL/实体注释 |
| `receive_lid` | `bigint` | 接单人lid | 接单人lid | YES | NULL | DB/DDL/实体注释 |
| `receive_by` | `varchar(90)` | 接单人 | 接单人 | YES | NULL | DB/DDL/实体注释 |
| `receive_time` | `datetime` | 接单时间 | 接单时间 | YES | NULL | DB/DDL/实体注释 |
| `split_lid` | `bigint` | 拆单人lid | 拆单人lid | YES | NULL | DB/DDL/实体注释 |
| `split_by` | `varchar(90)` | 拆单人 | 拆单人 | YES | NULL | DB/DDL/实体注释 |
| `split_time` | `datetime` | 拆单时间 | 拆单时间 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_store_order_item`

- 真实表：`sc_store_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：门店订货单物品
- 表含义：门店订货单物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订货日期 | 订货日期 | NO | NULL | DB/DDL/实体注释 |
| `store_order_lid` | `bigint` | 门店订货单lid | 门店订货单lid | NO | NULL | DB/DDL/实体注释 |
| `store_order_id` | `varchar(90)` | 门店订货单编号 | 门店订货单编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `organ_lid` | `bigint` | 机构lid | 机构lid | NO | NULL | DB/DDL/实体注释 |
| `indent_volume` | `decimal(24,10)` | 订单数量 | 订单数量 | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,10)` | 实际数量 | 实际数量 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,10)` | 单价 | 单价 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,10)` | 金额 | 金额 | YES | NULL | DB/DDL/实体注释 |
| `org_volume` | `decimal(24,10)` | 原始数量 | 原始数量 | YES | NULL | DB/DDL/实体注释 |
| `org_price` | `decimal(24,10)` | 原始单价 | 原始单价 | YES | NULL | DB/DDL/实体注释 |
| `org_amount` | `decimal(24,10)` | 原始金额 | 原始金额 | YES | NULL | DB/DDL/实体注释 |
| `tax_rate` | `decimal(24,10)` | 税率 | 税率 | YES | NULL | DB/DDL/实体注释 |
| `arrival_time` | `datetime` | 到货日期 | 到货日期 | NO | NULL | DB/DDL/实体注释 |
| `delivery_type` | `int` | 配送方式 | 配送方式 | NO | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 订货单类型 | 订货单类型 | NO | NULL | DB/DDL/实体注释 |
| `order_state` | `int` | 订单状态 | 订单状态 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `indent_price` | `decimal(24,10)` | 订购价 | 订购价 | YES | NULL | DB/DDL/实体注释 |

#### `sc_supplier`

- 真实表：`sc_supplier`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供应商
- 表含义：供应商
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | NO | NULL | DB/DDL/实体注释 |
| `supplier_type_lid` | `bigint` | 供应商类别lid | 供应商类别lid | YES | NULL | DB/DDL/实体注释 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 负责人电话 | 负责人电话 | YES | NULL | DB/DDL/实体注释 |
| `longitude` | `decimal(24,6)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `decimal(24,6)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `bigint` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `bigint` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `bigint` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `address` | `varchar(255)` | 详细地址 | 详细地址 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 启用/禁用 | 启用/禁用 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `is_suit_all` | `tinyint(1)` | 适用所有店铺 | 适用所有店铺 | NO | 1 | DB/DDL/实体注释 |
| `pinyin` | `varchar(90)` | 拼音 | 拼音 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 编号 | 编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `supplier_type` | `varchar(255)` | supplier类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `supplier_type_code` | `varchar(255)` | supplier类型code | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `tel` | `varchar(255)` | tel | 供应链或基础资料业务中的tel。 | YES | NULL | 推断 |
| `addr` | `varchar(255)` | addr | 供应链或基础资料业务中的addr。 | YES | NULL | 推断 |
| `email` | `varchar(255)` | email | 供应链或基础资料业务中的email。 | YES | NULL | 推断 |
| `creator` | `varchar(255)` | creator | 供应链或基础资料业务中的creator。 | YES | NULL | 推断 |
| `create_time` | `datetime` | create时间 | 供应链或基础资料业务中的create时间。 | YES | NULL | 推断 |
| `logo` | `varchar(255)` | logo | 供应链或基础资料业务中的logo。 | YES | NULL | 推断 |
| `disable` | `tinyint` | disable | 供应链或基础资料业务中的disable。 | YES | NULL | 推断 |
| `enable_on_line_mall` | `tinyint` | enableonlinemall | 供应链或基础资料业务中的enableonlinemall。 | YES | NULL | 推断 |
| `qualification_photo` | `varchar(255)` | qualificationphoto | 供应链或基础资料业务中的qualificationphoto。 | YES | NULL | 推断 |
| `quarantine_report_photo` | `varchar(255)` | quarantinereportphoto | 供应链或基础资料业务中的quarantinereportphoto。 | YES | NULL | 推断 |
| `tax_rate` | `decimal(19, 10)` | tax比例 | 供应链或基础资料业务中的tax比例。 | YES | NULL | 推断 |
| `tax_code` | `varchar(255)` | taxcode | 供应链或基础资料业务对象的taxcode。 | YES | NULL | 推断 |
| `bank` | `varchar(255)` | bank | 供应链或基础资料业务中的bank。 | YES | NULL | 推断 |
| `card_of_bank` | `varchar(255)` | 会员卡ofbank | 供应链或基础资料业务中的会员卡ofbank。 | YES | NULL | 推断 |
| `billing_period_type` | `varchar(255)` | billingperiod类型 | 供应链或基础资料业务分类或类型。 | YES | NULL | 推断 |
| `expiry_day_of_qualification` | `datetime` | 有效期dayofqualification | 供应链或基础资料业务中的有效期dayofqualification。 | YES | NULL | 推断 |
| `Remarks` | `varchar(255)` | remarks | 供应链或基础资料业务中的remarks。 | YES | NULL | 推断 |
| `Commit_audit_time` | `datetime` | commitaudit时间 | 供应链或基础资料业务中的commitaudit时间。 | YES | NULL | 推断 |
| `Audit_time` | `datetime` | audit时间 | 供应链或基础资料业务中的audit时间。 | YES | NULL | 推断 |
| `Reviewer` | `varchar(255)` | reviewer | 供应链或基础资料业务中的reviewer。 | YES | NULL | 推断 |
| `Audit_status` | `varchar(255)` | audit状态 | 供应链或基础资料处理状态或启停状态。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `supplier_merchant_id` | `bigint` | 货商商户编号 | 货商商户编号 | YES | NULL | DB/DDL/实体注释 |
| `supplier_shop_id` | `bigint` | 货商店铺编号 | 货商店铺编号 | YES | NULL | DB/DDL/实体注释 |

#### `sc_supplier_apply`

- 真实表：`sc_supplier_apply`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商申请关联记录
- 表含义：供货商申请关联记录
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `apply_id` | `varchar(90)` | 申请账号 | 申请账号 | NO | NULL | DB/DDL/实体注释 |
| `apply_by` | `varchar(90)` | 申请人 | 申请人 | NO | NULL | DB/DDL/实体注释 |
| `apply_at` | `datetime` | 申请时间 | 申请时间 | NO | NULL | DB/DDL/实体注释 |
| `apply_phone` | `varchar(90)` | 申请电话 | 申请电话 | NO | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `audit_at` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `apply_state` | `int` | 状态 | 状态 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | -1 | DB/DDL/实体注释 |

### gylregdb

#### `sc_supplier_goods`

- 真实表：`sc_supplier_goods`
- 数据源/库：`gylregdb` / `mycat` / `172.16.0.12:3306`
- 表中文名：供应商物品关联
- 表含义：供应商物品关联
- 字段来源：`119-old + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `COMPANY_ID` | `varchar(32)` | 商户号 | 商户号 | YES | NULL | DB/DDL/实体注释 |
| `SHOP_ID` | `varchar(32)` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `LMNID` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `varchar(255)` | 记录状态 | 记录状态 | YES | NULL | DB/DDL/实体注释 |
| `supplier` | `varchar(255)` | 供应商 | 供应商 | YES | NULL | DB/DDL/实体注释 |
| `supplier_code` | `bigint` | 供应商编号 | 供应商编号 | YES | NULL | DB/DDL/实体注释 |
| `goods` | `varchar(255)` | 物品 | 物品 | YES | NULL | DB/DDL/实体注释 |
| `goods_code` | `bigint` | 物品编号 | 物品编号 | YES | NULL | DB/DDL/实体注释 |

### a_wms

#### `sc_supplier_quote`

- 真实表：`sc_supplier_quote`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商报价
- 表含义：供货商报价
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 适用门店 | 适用门店 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `quote_order_lid` | `bigint` | 报价单lid | 报价单lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 报价 | 报价 | NO | NULL | DB/DDL/实体注释 |
| `added_tax_type` | `int` | 采购税率 | 采购税率 | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供货商lid | 供货商lid | NO | NULL | DB/DDL/实体注释 |
| `begin_date` | `datetime` | 价格生效日期 | 价格生效日期 | NO | NULL | DB/DDL/实体注释 |
| `end_date` | `datetime` | 价格失效日期 | 价格失效日期 | NO | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(255)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_supplier_relate`

- 真实表：`sc_supplier_relate`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供货商与商户关联
- 表含义：供货商与商户关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(90)` | 商户企业账号 | 商户企业账号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 商户名称 | 商户名称 | NO | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(90)` | 商户手机号 | 商户手机号 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_supplier_store`

- 真实表：`sc_supplier_store`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供应商和门店关联
- 表含义：供应商和门店关联
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `store_lid` | `bigint` | 门店lid | 门店lid | NO | NULL | DB/DDL/实体注释 |
| `supplier_lid` | `bigint` | 供应商lid | 供应商lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_supplier_type`

- 真实表：`sc_supplier_type`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：供应商类型
- 表含义：供应商类型
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 供应商名称 | 供应商名称 | NO | NULL | DB/DDL/实体注释 |
| `parent_lid` | `bigint` | 上一级分类 | 上一级分类 | YES | NULL | DB/DDL/实体注释 |
| `level` | `int` | 层级 | 层级 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 启用/禁用 | 启用/禁用 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 供应商类型编号 | 供应商类型编号 | NO | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `disable` | `tinyint` | disable | 供应链或基础资料业务中的disable。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |

#### `sc_tbl_area`

- 真实表：`sc_tbl_area`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：台区
- 表含义：台区
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 台区编号 | 台区编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 台区名称 | 台区名称 | NO | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 台区顺序 | 台区顺序 | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `order_idx` | `int` | 订单idx | 供应链或基础资料业务中的订单idx。 | YES | NULL | 推断 |
| `Show_order` | `int` | show订单 | 供应链或基础资料业务中的show订单。 | YES | NULL | 推断 |
| `floor_height` | `decimal(10, 2)` | 层高 | 层高(m) | YES | NULL | DB/DDL/实体注释 |
| `tbl_photo` | `varchar(255)` | 桌台图片 | 桌台图片 | YES | NULL | DB/DDL/实体注释 |
| `max_table_num` | `int` | 最大桌数 | 最大桌数 | YES | NULL | DB/DDL/实体注释 |
| `area_size` | `decimal(10, 2)` | 面积 | 面积(㎡) | YES | NULL | DB/DDL/实体注释 |
| `attribute_remark` | `text` | 台桌属性 | 台桌属性 | YES |  | DB/DDL/实体注释 |
| `area_desc` | `text` | 台区描述 | 台区描述 | YES |  | DB/DDL/实体注释 |
| `tbl_photo_list` | `text` | 桌台图片列表 | 桌台图片列表 | YES |  | DB/DDL/实体注释 |

#### `sc_warehouse`

- 真实表：`sc_warehouse`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：仓库
- 表含义：仓库
- 字段来源：`216-new + SQL:D:\mywork\techdoc\crm技术文档\表结构\gylregdb0508.sql`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理主键 | 数据库物理自增主键。 | NO | NULL | 通用字段 |
| `mid` | `bigint` | 集团 | 集团 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 所属门店 | 所属门店 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | lmn内部编号 | lmn内部编号 | NO | NULL | DB/DDL/实体注释 |
| `init_bill_lid` | `bigint` | 仓库期初编号 | 仓库期初编号 | YES | NULL | DB/DDL/实体注释 |
| `check_bill_lid` | `bigint` | 仓库盘点单号 | 仓库盘点单号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 仓库名称 | 仓库名称 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `principal` | `varchar(255)` | 负责人 | 负责人 | YES | NULL | DB/DDL/实体注释 |
| `phone` | `varchar(255)` | 手机号 | 手机号 | YES | NULL | DB/DDL/实体注释 |
| `enable` | `tinyint(1)` | 启用/禁用 | 启用/禁用 | YES | NULL | DB/DDL/实体注释 |
| `address` | `varchar(900)` | 仓库地址 | 仓库地址 | YES | NULL | DB/DDL/实体注释 |
| `reduce_level` | `int` | 扣减顺序 | 扣减顺序 | YES | NULL | DB/DDL/实体注释 |
| `inited` | `tinyint(1)` | 是否期初 | 是否期初 | YES | NULL | DB/DDL/实体注释 |
| `checking` | `tinyint(1)` | 正在盘点 | 正在盘点 | YES | NULL | DB/DDL/实体注释 |
| `for_default` | `tinyint(1)` | 默认仓库 | 默认仓库 | YES | NULL | DB/DDL/实体注释 |
| `last_inventory_time` | `datetime` | 最近盘点日期 | 最近盘点日期 | YES | NULL | DB/DDL/实体注释 |
| `last_order_time` | `datetime` | 最近订货日期 | 最近订货日期 | YES | NULL | DB/DDL/实体注释 |
| `time_of_last_bill` | `datetime` | 最近库存单据日期 | 最近库存单据日期 | YES | NULL | DB/DDL/实体注释 |
| `time_of_last_auto_out` | `datetime` | 最后自动出库日期 | 最后自动出库日期 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `init_time` | `datetime` | 仓库期初时间 | 仓库期初时间 | YES | NULL | DB/DDL/实体注释 |
| `owner_shop_id` | `bigint` | 所属店铺编号 | 所属店铺编号 | YES | NULL | DB/DDL/实体注释 |
| `owner_shop` | `varchar(90)` | 所属店铺 | 所属店铺 | YES | NULL | DB/DDL/实体注释 |
| `longitude` | `decimal(24,6)` | 经度 | 经度 | YES | NULL | DB/DDL/实体注释 |
| `latitude` | `decimal(24,6)` | 纬度 | 纬度 | YES | NULL | DB/DDL/实体注释 |
| `province` | `varchar(255)` | 所在省 | 所在省 | YES | NULL | DB/DDL/实体注释 |
| `province_code` | `bigint` | 省编码 | 省编码 | YES | NULL | DB/DDL/实体注释 |
| `city` | `varchar(255)` | 所在市 | 所在市 | YES | NULL | DB/DDL/实体注释 |
| `city_code` | `bigint` | 市编码 | 市编码 | YES | NULL | DB/DDL/实体注释 |
| `county` | `varchar(255)` | 所在区县 | 所在区县 | YES | NULL | DB/DDL/实体注释 |
| `county_code` | `bigint` | 所在区县编码 | 所在区县编码 | YES | NULL | DB/DDL/实体注释 |
| `receiver` | `varchar(255)` | 收货人 | 收货人 | YES | NULL | DB/DDL/实体注释 |
| `receiver_phone` | `varchar(255)` | 收货人联系方式 | 收货人联系方式 | YES | NULL | DB/DDL/实体注释 |
| `receiver_address` | `varchar(255)` | 收货地址 | 收货地址 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 仓库编号 | 仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `alias` | `varchar(90)` | 别名 | 别名 | YES | NULL | DB/DDL/实体注释 |
| `outbound` | `tinyint(1)` | 物品审核入库即耗用 | 物品审核入库即耗用 | YES | NULL | DB/DDL/实体注释 |
| `company_id` | `bigint` | 公司ID | 公司或商户主体编号。 | NO |  | 通用字段 |
| `shop_id` | `bigint` | 店铺ID | 店铺或门店编号。 | YES | NULL | 通用字段 |
| `lmnid` | `bigint` | 乐檬内部ID | 老系统或乐檬体系中的内部编号。 | NO |  | 通用字段 |
| `status_` | `int` | 状态 | 业务处理状态或启停状态。 | YES | NULL | 通用字段 |
| `delivery_center` | `varchar(255)` | deliverycenter | 供应链或基础资料业务中的deliverycenter。 | YES | NULL | 推断 |
| `delivery_center_id` | `varchar(255)` | deliverycenterID | 供应链或基础资料业务关联的deliverycenterID。 | YES | NULL | 推断 |
| `number_of_item` | `int` | 数量ofitem | 供应链或基础资料业务中的数量ofitem。 | YES | NULL | 推断 |
| `number_of_supplier` | `int` | 数量ofsupplier | 供应链或基础资料业务中的数量ofsupplier。 | YES | NULL | 推断 |
| `number_of_route_rule` | `int` | 数量ofroute规则 | 供应链或基础资料业务中的数量ofroute规则。 | YES | NULL | 推断 |
| `number_of_supply_contract` | `int` | 数量ofsupplycontract | 供应链或基础资料业务中的数量ofsupplycontract。 | YES | NULL | 推断 |
| `number_of_delivery_contract` | `int` | 数量ofdeliverycontract | 供应链或基础资料业务中的数量ofdeliverycontract。 | YES | NULL | 推断 |
| `Phone` | `varchar(255)` | phone | 供应链或基础资料业务中的phone。 | YES | NULL | 推断 |
| `Telephone` | `varchar(255)` | telephone | 供应链或基础资料业务中的telephone。 | YES | NULL | 推断 |
| `Warehouse_describe` | `varchar(255)` | warehousedescribe | 供应链或基础资料业务中的warehousedescribe。 | YES | NULL | 推断 |
| `Crt_time` | `datetime` | crt时间 | 供应链或基础资料业务中的crt时间。 | YES | NULL | 推断 |
| `Address` | `varchar(255)` | address | 供应链或基础资料业务中的address。 | YES | NULL | 推断 |
| `Checking` | `tinyint` | checking | 供应链或基础资料业务中的checking。 | YES | NULL | 推断 |
| `PIDTmp` | `bigint` | pidtmp | 供应链或基础资料业务中的pidtmp。 | YES | NULL | 推断 |
| `Owner_shop` | `varchar(255)` | owner店铺 | 供应链或基础资料业务中的owner店铺。 | YES | NULL | 推断 |
| `Owner_shop_id` | `varchar(255)` | owner店铺ID | 供应链或基础资料业务关联的owner店铺ID。 | YES | NULL | 推断 |
| `Reduce_level` | `int` | reduce等级 | 供应链或基础资料业务中的reduce等级。 | YES | NULL | 推断 |
| `Init_time` | `datetime` | init时间 | 供应链或基础资料业务中的init时间。 | YES | NULL | 推断 |

#### `sc_weight_img`

- 真实表：`sc_weight_img`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：称重图片拍照
- 表含义：称重图片拍照
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 日期 | 日期 | NO | NULL | DB/DDL/实体注释 |
| `order_lid` | `bigint` | 订单lid | 订单lid | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 订单物品lid | 订单物品lid | NO | NULL | DB/DDL/实体注释 |
| `url` | `varchar(255)` | 图片地址 | 图片地址 | NO | NULL | DB/DDL/实体注释 |
| `idx` | `int` | 拍照索引 | 拍照索引 | NO | 0 | DB/DDL/实体注释 |
| `type_` | `int` | 类型 0订货单 1入库单 | 类型 0订货单 1入库单 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `sc_weight_record`

- 真实表：`sc_weight_record`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：称重记录表
- 表含义：称重记录表
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 日期 | 日期 | NO | NULL | DB/DDL/实体注释 |
| `order_lid` | `bigint` | 订单lid | 订单lid | NO | NULL | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 订单物品lid | 订单物品lid | NO | NULL | DB/DDL/实体注释 |
| `measure` | `decimal(24,6)` | 读数 | 读数 | NO | 0.000000 | DB/DDL/实体注释 |
| `tare` | `decimal(24,6)` | 皮重 | 皮重 | NO | 0.000000 | DB/DDL/实体注释 |
| `weight_type` | `int` | 称重单位类型 | 称重单位类型 | NO | 0 | DB/DDL/实体注释 |
| `idx` | `int` | 称重索引 | 称重索引 | NO | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 0订货单 1入库单 | 类型 0订货单 1入库单 | NO | 0 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_bom`

- 真实表：`wms_bom`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物料清单
- 表含义：物料清单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `dish_id` | `bigint` | 商品编号 | 商品编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_name` | `varchar(90)` | 商品 | 商品 | YES | NULL | DB/DDL/实体注释 |
| `hide` | `varchar(255)` | 隐藏 | 隐藏（酒水） | YES | NULL | DB/DDL/实体注释 |
| `audit_time` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `audited` | `tinyint(1)` | 已审核 | 已审核 | YES | NULL | DB/DDL/实体注释 |
| `audit_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_bom_item`

- 真实表：`wms_bom_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物料清单明细
- 表含义：物料清单明细
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `bom_id` | `bigint` | 物料清单编号 | 物料清单编号 | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(90)` | 商品单位 | 商品单位 | YES | NULL | DB/DDL/实体注释 |
| `goods_id` | `bigint` | 物品编号 | 物品编号 | YES | NULL | DB/DDL/实体注释 |
| `goods` | `varchar(90)` | 物品名称 | 物品名称 | YES | NULL | DB/DDL/实体注释 |
| `goods_unit` | `varchar(90)` | 物品单位 | 物品单位 | YES | NULL | DB/DDL/实体注释 |
| `goods_cost` | `decimal(24,6)` | 物品用量 | 物品用量 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_cost_order`

- 真实表：`wms_cost_order`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：成本报损单
- 表含义：成本报损单
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `id` | `varchar(32)` | 报损单号 | 报损单号 | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订单日期 | 订单日期 | YES | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 报损单类型 | 报损单类型 | YES | NULL | DB/DDL/实体注释 |
| `rows` | `int` | 物品总数 | 物品总数 | YES | NULL | DB/DDL/实体注释 |
| `volume` | `decimal(24,6)` | 总数量 | 总数量 | YES | NULL | DB/DDL/实体注释 |
| `amount` | `decimal(24,6)` | 总金额 | 总金额 | YES | NULL | DB/DDL/实体注释 |
| `review` | `tinyint(1)` | 审核 | 审核 | YES | NULL | DB/DDL/实体注释 |
| `review_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `review_at` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `reason` | `varchar(255)` | 报损原因 | 报损原因 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(900)` | 报损备注 | 报损备注 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_cost_order_item`

- 真实表：`wms_cost_order_item`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：成本报损单物品
- 表含义：成本报损单物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 订单日期 | 订单日期 | YES | NULL | DB/DDL/实体注释 |
| `order_type` | `int` | 报损单类型 | 报损单类型 | YES | NULL | DB/DDL/实体注释 |
| `cost_order_id` | `varchar(32)` | 成本单号 | 成本单号 | YES | NULL | DB/DDL/实体注释 |
| `cost_order_lid` | `bigint` | 成本单lid | 成本单lid | YES | NULL | DB/DDL/实体注释 |
| `small_type_lid` | `bigint` | 商品小类lid | 商品小类lid | YES | NULL | DB/DDL/实体注释 |
| `small_type` | `varchar(90)` | 商品小类名称 | 商品小类名称 | YES | NULL | DB/DDL/实体注释 |
| `super_type_lid` | `bigint` | 商品大类lid | 商品大类lid | YES | NULL | DB/DDL/实体注释 |
| `super_type` | `varchar(90)` | 商品大类名称 | 商品大类名称 | YES | NULL | DB/DDL/实体注释 |
| `product_id` | `varchar(32)` | 商品id | 商品id | YES | NULL | DB/DDL/实体注释 |
| `product_lid` | `bigint` | 商品lid | 商品lid | YES | NULL | DB/DDL/实体注释 |
| `product_name` | `varchar(90)` | 商品名称 | 商品名称 | YES | NULL | DB/DDL/实体注释 |
| `product_unit` | `varchar(90)` | 商品单位 | 商品单位 | YES | NULL | DB/DDL/实体注释 |
| `product_volume` | `decimal(24,6)` | 商品数量 | 商品数量 | YES | NULL | DB/DDL/实体注释 |
| `product_price` | `decimal(24,6)` | 商品单价 | 商品单价 | YES | NULL | DB/DDL/实体注释 |
| `product_amount` | `decimal(24,6)` | 商品金额 | 商品金额 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(900)` | 商品备注 | 商品备注 | YES | NULL | DB/DDL/实体注释 |
| `review` | `tinyint(1)` | 审核 | 审核 | YES | NULL | DB/DDL/实体注释 |
| `review_at` | `datetime` | 审核时间 | 审核时间 | YES | NULL | DB/DDL/实体注释 |
| `review_by` | `varchar(90)` | 审核人 | 审核人 | YES | NULL | DB/DDL/实体注释 |
| `raw_rows` | `bigint` | 报损原材料数 | 报损原材料数 | YES | NULL | DB/DDL/实体注释 |
| `raw_volume` | `decimal(24,6)` | 原料材料扣库数量 | 原料材料扣库数量 | YES | NULL | DB/DDL/实体注释 |
| `raw_amount` | `decimal(24,6)` | 原料材料扣库金额 | 原料材料扣库金额 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_deduct_setting`

- 真实表：`wms_deduct_setting`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：商品扣仓设置
- 表含义：商品扣仓设置
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `dish_id` | `bigint` | 商品号 | 商品号 | YES | NULL | DB/DDL/实体注释 |
| `dish` | `varchar(90)` | 商品 | 商品 | YES | NULL | DB/DDL/实体注释 |
| `dish_super_type_id` | `bigint` | 商品大类编号 | 商品大类编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_super_type` | `varchar(90)` | 商品大类 | 商品大类 | YES | NULL | DB/DDL/实体注释 |
| `dish_type_id` | `bigint` | 商品小类编号 | 商品小类编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_type` | `varchar(90)` | 商品小类 | 商品小类 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area_id` | `bigint` | 台区编号 | 台区编号 | YES | NULL | DB/DDL/实体注释 |
| `tbl_area` | `varchar(90)` | 台区 | 台区 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_id` | `bigint` | 仓库编号 | 仓库编号 | YES | NULL | DB/DDL/实体注释 |
| `warehouse` | `varchar(90)` | 仓库 | 仓库 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_depart_goods`

- 真实表：`wms_depart_goods`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：部门/仓库物品
- 表含义：部门/仓库物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_goods_last_price`

- 真实表：`wms_goods_last_price`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：物品上次入库价格
- 表含义：物品上次入库价格
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | NO | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | NO | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `price` | `decimal(24,6)` | 价格 | 价格 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 价格类型 | 价格类型 | NO | 1 | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `warehouse_lid` | `bigint` | 仓库lid | 仓库lid | NO | -1 | DB/DDL/实体注释 |
| `item_lid` | `bigint` | 单据物品lid | 单据物品lid | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 单据lid | 单据lid | YES | NULL | DB/DDL/实体注释 |
| `bill_id` | `varchar(90)` | 单据id | 单据id | YES | NULL | DB/DDL/实体注释 |
| `report_date` | `datetime` | 最后一次价格订单日期 | 最后一次价格订单日期 | YES | NULL | DB/DDL/实体注释 |

#### `wms_label_unit`

- 真实表：`wms_label_unit`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：单位/标签
- 表含义：单位/标签
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `name` | `varchar(90)` | 名称 | 名称 | YES | NULL | DB/DDL/实体注释 |
| `remark` | `varchar(900)` | 备注 | 备注 | YES | NULL | DB/DDL/实体注释 |
| `type_` | `int` | 类型 | 类型 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

#### `wms_user_goods`

- 真实表：`wms_user_goods`
- 数据源/库：`a_wms` / `wms` / `172.16.0.12:3306`
- 表中文名：用户常用物品
- 表含义：用户常用物品
- 字段来源：`216-new`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | NO | NULL | DB/DDL/实体注释 |
| `user_lid` | `bigint` | 用户lid | 用户lid | NO | NULL | DB/DDL/实体注释 |
| `goods_lid` | `bigint` | 物品lid | 物品lid | NO | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(32)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(32)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `bigint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |

### nms

#### `crm_consume_cash_event`

- 真实表：`crm_consume_cash_event`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费返现事件。
- 表含义：POS本地消费返现事件。
- 字段来源：`local-pos + SQL:D:\mywork\nms4pos\sql\update\2026-5-16-crm-consume-cash.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCashEvent.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 消费返现事件逻辑主键 | 消费返现事件逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 消费返现会话LID | 消费返现会话LID | YES | NULL | DB/DDL/实体注释 |
| `round_lid` | `bigint` | 消费返现轮次LID | 消费返现轮次LID | YES | NULL | DB/DDL/实体注释 |
| `event_type` | `int` | 事件类型 | 事件类型 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 事件状态 | 事件状态 | YES | NULL | DB/DDL/实体注释 |
| `payload_json` | `text` | 事件载荷JSON | 事件载荷JSON | YES | NULL | DB/DDL/实体注释 |
| `error_msg` | `text` | 错误信息 | 错误信息 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 事件记录状态 | 事件记录状态。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_cash_round`

- 真实表：`crm_consume_cash_round`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费返现轮次。
- 表含义：POS本地消费返现轮次。
- 字段来源：`local-pos + SQL:D:\mywork\nms4pos\sql\update\2026-5-16-crm-consume-cash.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCashRound.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 消费返现轮次逻辑主键 | 消费返现轮次逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 消费返现会话LID | 消费返现会话LID | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | POS账单LID | POS账单LID | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | 订单号 | POS订单号，对应dwd_bill.saas_order_key | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | POS本地会员卡LID | POS本地会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `round_no` | `int` | 会话内轮次序号 | 会话内轮次序号 | YES | NULL | DB/DDL/实体注释 |
| `round_key` | `varchar(128)` | CRM幂等键，同一轮发放和撤销保持一致 | CRM幂等键，同一轮发放和撤销保持一致 | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | CRM命中的消费返现规则LID | CRM命中的消费返现规则LID | YES | NULL | DB/DDL/实体注释 |
| `cash_back_amount` | `decimal(19,10)` | CRM实际返现金额，单位元 | CRM实际返现金额，单位元 | YES | NULL | DB/DDL/实体注释 |
| `task_lid` | `bigint` | CRM返现任务LID，用于绑定原返现任务撤销 | CRM返现任务LID，用于绑定原返现任务撤销 | YES | NULL | DB/DDL/实体注释 |
| `bill_amount_snapshot` | `decimal(19,10)` | 参与返现计算的账单实付金额快照，单位元 | 参与返现计算的账单实付金额快照，单位元 | YES | NULL | DB/DDL/实体注释 |
| `pay_snapshot_json` | `text` | 支付快照JSON | 支付方式快照JSON，仅用于排查，不用于重新扩散扫描历史账单 | YES | NULL | DB/DDL/实体注释 |
| `grant_request_json` | `text` | 发放请求JSON | CRM发放请求快照JSON，包含结账时间、金额和菜品快照，补偿时按该快照回放 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 轮次状态 | 轮次状态：1-待发放，2-已返现，3-发放失败，4-待撤销，5-已撤销，6-撤销失败，7-未命中 | YES | NULL | DB/DDL/实体注释 |
| `active_flag` | `int` | 是否当前有效轮次 | 是否当前有效轮次：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `retry_count` | `int` | 累计重试次数 | 累计重试次数 | YES | NULL | DB/DDL/实体注释 |
| `next_retry_time` | `datetime` | 下次重试时间 | 下次重试时间 | YES | NULL | DB/DDL/实体注释 |
| `last_retry_time` | `datetime` | 最近一次执行时间 | 最近一次执行时间 | YES | NULL | DB/DDL/实体注释 |
| `last_error_msg` | `text` | 最近一次失败原因 | 最近一次失败原因 | YES | NULL | DB/DDL/实体注释 |
| `grant_time` | `datetime` | 成功返现时间 | 成功返现时间 | YES | NULL | DB/DDL/实体注释 |
| `revoke_time` | `datetime` | 成功撤销时间 | 成功撤销时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `active_session_lid` | `BIGINT` | 当前有效轮次唯一约束列 | 当前有效轮次唯一约束列 | YES |  | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 轮次状态，决定补偿任务走发放、撤销还是跳过 | 轮次状态，决定补偿任务走发放、撤销还是跳过。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_cash_session`

- 真实表：`crm_consume_cash_session`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费返现会话。
- 表含义：POS本地消费返现会话。
- 字段来源：`local-pos + SQL:D:\mywork\nms4pos\sql\update\2026-5-16-crm-consume-cash.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCashSession.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 消费返现会话逻辑主键 | 消费返现会话逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | POS账单LID | POS账单LID | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | 订单号 | POS订单号，对应dwd_bill.saas_order_key | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | POS本地会员卡LID | POS本地会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `current_round_lid` | `bigint` | 当前有效返现轮次LID | 当前有效返现轮次LID | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 会话状态 | 会话状态：1-打开，2-已关闭，3-失败 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `member_key` | `VARCHAR(128)` | 会员唯一约束归一化键，优先使用稳定card_no | 会员唯一约束归一化键，优先使用稳定card_no | NO |  | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 状态 | 会话状态，只描述本地生命周期，真实发放/撤销结果以轮次状态为准。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_coupon_event`

- 真实表：`crm_consume_coupon_event`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS消费赠券事件流水表。
- 表含义：POS消费赠券事件流水表。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4cloud\docs\sql\migration\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4pos\docs\sql\V202605xx_crm_consume_coupon_session_round_event.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCouponEvent.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 所属会话LID | 所属会话LID | YES | NULL | DB/DDL/实体注释 |
| `round_lid` | `bigint` | 所属轮次PID | 所属轮次PID | YES | NULL | DB/DDL/实体注释 |
| `event_type` | `int` | 事件类型 | 事件类型：1-发放，2-撤销 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 事件状态 | 事件状态：1-已记录，2-成功，3-失败 | YES | NULL | DB/DDL/实体注释 |
| `payload_json` | `text` | 事件载荷JSON | 事件载荷JSON | YES | NULL | DB/DDL/实体注释 |
| `error_msg` | `text` | 失败原因 | 失败原因 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 逻辑删除 | 逻辑删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `event_status` | `VARCHAR(16)` | 事件状态 | 事件状态：SUCCESS/FAILED/PENDING | NO |  | DB/DDL/实体注释 |
| `request_payload` | `TEXT` | 发出时的请求体 | 发出时的请求体（JSON） | YES |  | DB/DDL/实体注释 |
| `response_payload` | `TEXT` | CRM返回体 | CRM返回体（JSON） | YES |  | DB/DDL/实体注释 |
| `error_message` | `VARCHAR(256)` | 错误原因 | 错误原因 | YES |  | DB/DDL/实体注释 |
| `revision` | `INT` | 数据版本 | 数据版本 | NO | 0 | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 事件状态 | 事件状态。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_coupon_round`

- 真实表：`crm_consume_coupon_round`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS消费赠券轮次表。
- 表含义：POS消费赠券轮次表。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4cloud\docs\sql\migration\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4pos\docs\sql\V202605xx_crm_consume_coupon_session_round_event.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCouponRound.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑ID | 轮次业务主键，传给CRM作为lifecycleId | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 所属会话PID | 所属会话PID | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | 账单LID | 账单LID（幂等键字段） | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | POS订单号 | POS订单号 | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡LID | 会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `round_no` | `int` | 轮次序号，从1开始 | 轮次序号，从1开始 | YES | NULL | DB/DDL/实体注释 |
| `round_key` | `varchar(128)` | 幂等轮次键，保持同一业务轮次重复请求落同一键 | 幂等轮次键，保持同一业务轮次重复请求落同一键。 | YES | NULL | DB/DDL/实体注释 |
| `parent_round_lid` | `bigint` | 上一轮次LID | 上一轮次LID | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 命中的规则LID | 命中的规则LID | YES | NULL | DB/DDL/实体注释 |
| `coupon_lid` | `bigint` | 本轮发放的券模板 LID | 本轮发放的券模板 LID。 | YES | NULL | DB/DDL/实体注释 |
| `coupon_num` | `int` | 本轮计划发放的券数量 | 本轮计划发放的券数量。 | YES | NULL | DB/DDL/实体注释 |
| `coupon_order_lids_json` | `text` | 本轮生成的券订单 LID 列表快照 JSON | 本轮生成的券订单 LID 列表快照 JSON。 | YES | NULL | DB/DDL/实体注释 |
| `coupon_lids_json` | `text` | 本轮生成的券 LID 列表快照 JSON | 本轮生成的券 LID 列表快照 JSON。 | YES | NULL | DB/DDL/实体注释 |
| `bill_amount_snapshot` | `decimal(19,10)` | 账单金额快照 | 账单金额快照。 | YES | NULL | DB/DDL/实体注释 |
| `crm_amount_snapshot` | `decimal(19,10)` | CRM 口径金额快照 | CRM 口径金额快照。 | YES | NULL | DB/DDL/实体注释 |
| `other_amount_snapshot` | `decimal(19,10)` | 其他金额快照 | 其他金额快照。 | YES | NULL | DB/DDL/实体注释 |
| `pay_snapshot_json` | `text` | 支付拆分快照JSON | 支付拆分快照JSON | YES | NULL | DB/DDL/实体注释 |
| `grant_basis_snapshot_json` | `text` | 发券依据快照 JSON | 发券依据快照 JSON。 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 轮次状态 | 轮次状态：1-待发放，2-已发放，3-发放失败，4-待撤销，5-撤销中，6-已撤销，7-撤销失败，8-等待重试 | YES | NULL | DB/DDL/实体注释 |
| `active_flag` | `int` | 是否当前有效轮次 | 是否当前有效轮次：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `retry_count` | `int` | 重试次数 | 重试次数 | YES | NULL | DB/DDL/实体注释 |
| `next_retry_time` | `datetime` | 下次重试时间 | 下次重试时间 | YES | NULL | DB/DDL/实体注释 |
| `last_retry_time` | `datetime` | 最近一次执行时间 | 最近一次执行时间 | YES | NULL | DB/DDL/实体注释 |
| `last_error_msg` | `text` | 最近一次失败原因 | 最近一次失败原因 | YES | NULL | DB/DDL/实体注释 |
| `grant_time` | `datetime` | 成功发放时间 | 成功发放时间 | YES | NULL | DB/DDL/实体注释 |
| `revoke_time` | `datetime` | 成功撤销时间 | 成功撤销时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 数据版本 | 数据版本 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 逻辑删除 | 逻辑删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `out_order_id` | `VARCHAR(64)` | 外部订单号 | 外部订单号（幂等键字段） | YES |  | DB/DDL/实体注释 |
| `event_type` | `TINYINT` | 事件类型 | 事件类型：1-发放，2-撤销 | NO |  | DB/DDL/实体注释 |
| `status` | `TINYINT` | 轮次状态 | 轮次状态：1-待处理，2-等待CRM回调，3-已发放成功，4-发放失败，5-撤销待处理，6-撤销中，7-已撤销，8-撤销失败，9-需人工处理 | NO | 1 | DB/DDL/实体注释 |
| `crm_task_lid` | `VARCHAR(64)` | CRM任务LID | CRM任务LID（回调后更新） | YES |  | DB/DDL/实体注释 |
| `rule_snapshot` | `JSON` | 规则快照 | 规则快照（JSON） | YES |  | DB/DDL/实体注释 |
| `grant_amount` | `DECIMAL(18,2)` | 赠券金额 | 赠券金额（快照） | YES |  | DB/DDL/实体注释 |
| `error_message` | `VARCHAR(256)` | 最近失败原因 | 最近失败原因 | YES |  | DB/DDL/实体注释 |
| `grant_coupon_plan_snapshot` | `TEXT` | 应赠券计划快照JSON | 应赠券计划快照JSON | YES |  | DB/DDL/实体注释 |
| `amount_snapshot` | `DECIMAL(20,2)` | 可积分金额快照 | 可积分金额快照 | YES |  | DB/DDL/实体注释 |
| `rule_snapshot_json` | `TEXT` | 规则快照JSON | 规则快照JSON | YES |  | DB/DDL/实体注释 |

#### `crm_consume_coupon_session`

- 真实表：`crm_consume_coupon_session`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS消费赠券会话表。
- 表含义：POS消费赠券会话表。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4cloud\docs\sql\migration\V20260515__consume_coupon_session_round_event.sql + SQL:D:\mywork\nms4pos\docs\sql\V202605xx_crm_consume_coupon_session_round_event.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumeCouponSession.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | YES | NULL | DB/DDL/实体注释 |
| `source_` | `int` | 来源 | 来源：1-POS清台，2-线上订单 | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | POS账单LID | POS账单LID | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | POS订单号 | POS订单号（幂等键） | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | 会员卡LID | 会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `current_round_lid` | `bigint` | 当前有效轮次LID | 当前有效轮次LID | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 会话状态 | 会话状态：1-打开，2-已闭环，3-失败 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 数据版本 | 数据版本 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 逻辑删除 | 逻辑删除：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `origin_lifecycle_id` | `VARCHAR(64)` | 消费生命周期ID | 消费生命周期ID（POS清台/round ID） | YES |  | DB/DDL/实体注释 |
| `source` | `TINYINT` | 来源 | 来源：1-POS，2-线上订单 | NO | 1 | DB/DDL/实体注释 |
| `status` | `VARCHAR(16)` | 会话状态 | 会话状态：ACTIVE/COMPLETED/CLOSED | NO | ACTIVE | DB/DDL/实体注释 |

#### `crm_consume_points_event`

- 真实表：`crm_consume_points_event`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费积分异事件。
- 表含义：POS本地消费积分异事件。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\consume_points_tables.sql + SQL:D:\mywork\nms4pos\sql\update\2026-5-6.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsEvent.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 事件逻辑主键 | 事件逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 消费积分会话LID | 消费积分会话LID | YES | NULL | DB/DDL/实体注释 |
| `round_lid` | `bigint` | 消费积分轮次LID | 消费积分轮次LID | YES | NULL | DB/DDL/实体注释 |
| `event_type` | `int` | 事件类型 | 事件类型 | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 事件状态 | 事件状态 | YES | NULL | DB/DDL/实体注释 |
| `payload_json` | `text` | 事件载荷JSON | 事件载荷JSON | YES | NULL | DB/DDL/实体注释 |
| `error_msg` | `text` | 错误信息 | 错误信息 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 事件状态 | 事件状态。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_points_round`

- 真实表：`crm_consume_points_round`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费积分轮次。
- 表含义：POS本地消费积分轮次。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\consume_points_tables.sql + SQL:D:\mywork\nms4pos\sql\update\2026-5-6.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsRound.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 轮次逻辑主键 | 轮次逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `session_lid` | `bigint` | 消费积分会话LID | 消费积分会话LID | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | POS账单LID | POS账单LID | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | POS订单号 | POS订单号 | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | POS本地会员卡LID | POS本地会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `round_no` | `int` | 轮次序号 | 轮次序号 | YES | NULL | DB/DDL/实体注释 |
| `parent_round_lid` | `bigint` | 上一轮轮次LID | 上一轮轮次LID | YES | NULL | DB/DDL/实体注释 |
| `crm_task_lid` | `bigint` | CRM会员卡消费任务LID | CRM会员卡消费任务LID | YES | NULL | DB/DDL/实体注释 |
| `grant_points` | `decimal(19,10)` | 本次消费应赠积分值 | 本次消费应赠积分值 | YES | NULL | DB/DDL/实体注释 |
| `current_effective_points` | `decimal(19,10)` | 当前净有效积分 | 当前净有效积分 | YES | NULL | DB/DDL/实体注释 |
| `grant_points_record_lid` | `bigint` | CRM发放积分流水LID | CRM发放积分流水LID | YES | NULL | DB/DDL/实体注释 |
| `revoke_points_record_lid` | `bigint` | CRM撤销积分流水LID | CRM撤销积分流水LID | YES | NULL | DB/DDL/实体注释 |
| `rule_lid` | `bigint` | 积分规则LID | 积分规则LID | YES | NULL | DB/DDL/实体注释 |
| `eligible_amount_snapshot` | `decimal(19,10)` | 可积分金额快照 | 可积分金额快照 | YES | NULL | DB/DDL/实体注释 |
| `pay_snapshot_json` | `text` | 支付拆分快照JSON | 支付拆分快照JSON | YES | NULL | DB/DDL/实体注释 |
| `grant_basis_snapshot_json` | `text` | 授分依据快照JSON | 授分依据快照JSON | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 轮次状态 | 轮次状态 | YES | NULL | DB/DDL/实体注释 |
| `active_flag` | `int` | 是否当前有效轮次 | 是否当前有效轮次：0-否，1-是 | YES | NULL | DB/DDL/实体注释 |
| `retry_count` | `int` | 重试次数 | 重试次数 | YES | NULL | DB/DDL/实体注释 |
| `next_retry_time` | `datetime` | 下次重试时间 | 下次重试时间 | YES | NULL | DB/DDL/实体注释 |
| `last_retry_time` | `datetime` | 最近一次执行时间 | 最近一次执行时间 | YES | NULL | DB/DDL/实体注释 |
| `last_error_msg` | `text` | 最近一次失败原因 | 最近一次失败原因 | YES | NULL | DB/DDL/实体注释 |
| `grant_time` | `datetime` | 成功发放时间 | 成功发放时间 | YES | NULL | DB/DDL/实体注释 |
| `revoke_time` | `datetime` | 成功撤销时间 | 成功撤销时间 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `active_session_lid` | `BIGINT` | 当前有效轮次唯一约束列 | 当前有效轮次唯一约束列 | YES |  | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 当前轮次状态 | 当前轮次状态。 |  |  | DB/DDL/实体注释 |

#### `crm_consume_points_session`

- 真实表：`crm_consume_points_session`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：POS本地消费积分会话。
- 表含义：POS本地消费积分会话。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4pos\consume_points_tables.sql + SQL:D:\mywork\nms4pos\sql\update\2026-5-6.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsSession.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 会话逻辑主键 | 会话逻辑主键 | YES | NULL | DB/DDL/实体注释 |
| `source_` | `int` | 积分来源 | 积分来源：1-POS | YES | NULL | DB/DDL/实体注释 |
| `bill_lid` | `bigint` | POS账单LID | POS账单LID | YES | NULL | DB/DDL/实体注释 |
| `order_id` | `varchar(128)` | POS订单号 | POS订单号 | YES | NULL | DB/DDL/实体注释 |
| `card_no` | `varchar(128)` | 会员卡号 | 会员卡号 | YES | NULL | DB/DDL/实体注释 |
| `card_lid` | `bigint` | POS本地会员卡LID | POS本地会员卡LID | YES | NULL | DB/DDL/实体注释 |
| `current_round_lid` | `bigint` | 当前有效轮次LID | 当前有效轮次LID | YES | NULL | DB/DDL/实体注释 |
| `status_` | `int` | 会话状态 | 会话状态：1-打开，2-闭环，3-失败 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `int` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
| `source` | `tinyint/varchar` | 消费积分来源 | 消费积分来源。 |  |  | DB/DDL/实体注释 |
| `status` | `tinyint/varchar` | 会话状态 | 会话状态。 |  |  | DB/DDL/实体注释 |

#### `crm_points_rule`

- 真实表：`crm_points_rule`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：积分权益规则主表。
- 表含义：积分权益规则主表。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\crm升级\脚本修改\nms4cloud\points_rule.sql + SQL:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\test\resources\sql\2026-04-17_积分权益规则表.sql + SQL:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\target\test-classes\sql\2026-04-17_积分权益规则表.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\pointsrule\CrmPointsRule.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmPointsRule.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户ID | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店ID | 门店ID；兼容字段，积分权益规则当前不按门店隔离，保存时为空 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号(雪花算法) | YES | NULL | DB/DDL/实体注释 |
| `name` | `varchar(128)` | 名称 | 规则名称；当前接口层未开放编辑，通常为空，预留给后台运营展示 | YES | NULL | DB/DDL/实体注释 |
| `plan_lid` | `bigint` | 所属会员方案逻辑编号 | 所属会员方案逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `points_rule_enabled` | `int` | 积分规则全局开关 | 积分规则全局开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `earning_enabled` | `int` | 是否启用消费送积分 | 是否启用消费送积分:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `gift_amount_earn_enabled` | `int` | 储值赠送参与积分 | 储值赠送参与积分:0-关闭,1-开启 | YES | NULL | DB/DDL/实体注释 |
| `earning_mode` | `int` | 积分模式 | 积分模式:1-按支付方式实收积分,2-按商品实收积分 | YES | NULL | DB/DDL/实体注释 |
| `earning_product_scope_type` | `int` | 获取积分适用商品范围 | 获取积分适用商品范围:1-全部商品,2-指定商品参与,3-指定商品不参与 | YES | NULL | DB/DDL/实体注释 |
| `earning_specified_product_lids` | `longtext` | 获取积分指定商品ID列表 | 获取积分指定商品ID列表(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `level_rates` | `longtext` | 会员等级赠分规则 | 会员等级赠分规则(JSON数组): [{memberLevelId,consumeAmount,earnPoints,sortOrder}] | YES | NULL | DB/DDL/实体注释 |
| `single_earn_limit_type` | `int` | 单笔获取上限类型 | 单笔获取上限类型:1-不限制,2-限制 | YES | NULL | DB/DDL/实体注释 |
| `single_earn_limit_value` | `decimal(19,10)` | 单笔获取上限积分值 | 单笔获取上限积分值 | YES | NULL | DB/DDL/实体注释 |
| `bonus_enabled` | `int` | 多倍积分总开关 | 多倍积分总开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `birthday_enabled` | `int` | 生日多倍积分开关 | 生日多倍积分开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `birthday_period` | `int` | 生日范围 | 生日范围:1-当天,2-当周,3-当月 | YES | NULL | DB/DDL/实体注释 |
| `birthday_multiplier` | `decimal(19,10)` | 生日积分倍数 | 生日积分倍数 | YES | NULL | DB/DDL/实体注释 |
| `member_day_enabled` | `int` | 会员日多倍积分开关 | 会员日多倍积分开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `member_day_period` | `int` | 会员日周期 | 会员日周期:1-每周,2-每月 | YES | NULL | DB/DDL/实体注释 |
| `member_day_days_of_week` | `longtext` | 会员daydaysofweek | 会员日按周生效星期，JSON数字数组，1-周一，2-周二，3-周三，4-周四，5-周五，6-周六，7-周日 | YES | NULL | DB/DDL/实体注释 |
| `member_day_days_of_month` | `longtext` | 会员日按月生效日期，JSON数字数组，1-31 | 会员日按月生效日期，JSON数字数组，1-31 | YES | NULL | DB/DDL/实体注释 |
| `member_day_multiplier` | `decimal(19,10)` | 会员日积分倍数 | 会员日积分倍数 | YES | NULL | DB/DDL/实体注释 |
| `available_cycle` | `int` | 获取积分可用周期 | 获取积分可用周期:1-按日,2-按周,3-按月 | YES | NULL | DB/DDL/实体注释 |
| `available_days_of_week` | `longtext` | 可用daysofweek | 获取积分按周生效星期，JSON数字数组，1-周一，2-周二，3-周三，4-周四，5-周五，6-周六，7-周日 | YES | NULL | DB/DDL/实体注释 |
| `available_days_of_month` | `longtext` | 获取积分按月生效日期，JSON数字数组，1-31 | 获取积分按月生效日期，JSON数字数组，1-31 | YES | NULL | DB/DDL/实体注释 |
| `available_time_type` | `int` | 获取积分可用时段类型 | 获取积分可用时段类型:1-全天,2-指定时段 | YES | NULL | DB/DDL/实体注释 |
| `available_time_slots` | `longtext` | 获取积分指定时段 | 获取积分指定时段(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `wecom_exclusive_enabled` | `int` | 企微会员专享开关 | 企微会员专享开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `wecom_exclusive_type` | `int` | 企微会员专享类型 | 企微会员专享类型:1-好友或群客,2-好友,3-群客,4-好友且群客 | YES | NULL | DB/DDL/实体注释 |
| `order_scene_limit` | `longtext` | 订单场景限制 | 获取积分订单场景限制，JSON数字数组，1-堂食，2-外卖，3-自提，4-外带 | YES | NULL | DB/DDL/实体注释 |
| `order_channel_limit` | `longtext` | 订单渠道限制 | 获取积分订单渠道限制，JSON数字数组，1-门店POS，2-微信小程序，3-支付宝小程序，4-抖音小程序，5-商户中心，6-自助大屏，7-码牌收银 | YES | NULL | DB/DDL/实体注释 |
| `deduction_enabled` | `int` | 是否启用积分抵现 | 是否启用积分抵现:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `deduction_rate` | `decimal(19,10)` | 积分抵扣比例 | 积分抵扣比例(X积分=1元) | YES | NULL | DB/DDL/实体注释 |
| `min_deduction_type` | `int` | 起扣积分限制类型 | 起扣积分限制类型:1-不限制,2-限制 | YES | NULL | DB/DDL/实体注释 |
| `min_deduction_value` | `decimal(19,10)` | 起扣积分数 | 起扣积分数 | YES | NULL | DB/DDL/实体注释 |
| `deduction_multiple_type` | `int` | 抵扣倍数类型 | 抵扣倍数类型:1-不限制,2-限制 | YES | NULL | DB/DDL/实体注释 |
| `deduction_multiple_value` | `int` | 抵扣整数倍数值 | 抵扣整数倍数值 | YES | NULL | DB/DDL/实体注释 |
| `deduction_rounding` | `int` | 抵扣金额取整 | 抵扣金额取整:1-不取整,2-向下取整 | YES | NULL | DB/DDL/实体注释 |
| `deduction_ceiling_type` | `int` | 抵扣上限类型 | 抵扣上限类型:1-不限制,2-固定积分,3-账单比例 | YES | NULL | DB/DDL/实体注释 |
| `deduction_ceiling_points` | `decimal(19,10)` | 固定积分上限 | 固定积分上限 | YES | NULL | DB/DDL/实体注释 |
| `deduction_ceiling_ratio` | `decimal(19,10)` | 账单比例上限，单位% | 账单比例上限，单位% | YES | NULL | DB/DDL/实体注释 |
| `deduct_cycle` | `int` | 积分抵现可用周期 | 积分抵现可用周期:1-按日,2-按周,3-按月 | YES | NULL | DB/DDL/实体注释 |
| `deduct_days_of_week` | `longtext` | deductdaysofweek | 积分抵现按周生效星期，JSON数字数组，1-周一，2-周二，3-周三，4-周四，5-周五，6-周六，7-周日 | YES | NULL | DB/DDL/实体注释 |
| `deduct_days_of_month` | `longtext` | 积分抵现按月生效日期，JSON数字数组，1-31 | 积分抵现按月生效日期，JSON数字数组，1-31 | YES | NULL | DB/DDL/实体注释 |
| `deduct_time_type` | `int` | 积分抵现可用时段类型 | 积分抵现可用时段类型:1-全天,2-指定时段 | YES | NULL | DB/DDL/实体注释 |
| `deduct_time_slots` | `longtext` | 积分抵现指定时段 | 积分抵现指定时段(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `product_limit_enabled` | `int` | 抵现商品限制开关 | 抵现商品限制开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `product_scope_type` | `int` | 抵现商品范围 | 抵现商品范围:2-指定商品参与,3-指定商品不参与,4-指定分类参与,5-指定分类不参与 | YES | NULL | DB/DDL/实体注释 |
| `deduct_specified_product_lids` | `longtext` | 抵现指定商品ID列表 | 抵现指定商品ID列表(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `deduct_pos_category_lids` | `longtext` | 抵现POS分类ID列表 | 抵现POS分类ID列表(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `deduct_miniapp_category_lids` | `longtext` | 抵现小程序分类ID列表 | 抵现小程序分类ID列表(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `deduct_exclude_product_lids` | `longtext` | 抵现排除商品ID列表 | 抵现排除商品ID列表(JSON数组) | YES | NULL | DB/DDL/实体注释 |
| `deduct_scene_limit` | `longtext` | deduct场景限制 | 抵现订单场景限制，JSON数字数组，1-堂食，2-外卖，3-自提，4-外带 | YES | NULL | DB/DDL/实体注释 |
| `deduct_channel_limit` | `longtext` | deduct渠道限制 | 抵现订单渠道限制，JSON数字数组，1-门店POS，2-微信小程序，3-支付宝小程序，4-抖音小程序，5-商户中心，6-自助大屏，7-码牌收银 | YES | NULL | DB/DDL/实体注释 |
| `expiry_enabled` | `int` | 是否启用积分清零 | 是否启用积分清零:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `expiry_mode` | `int` | 清零模式 | 清零模式:1-自发放日期,2-年度清零 | YES | NULL | DB/DDL/实体注释 |
| `expiry_duration` | `varchar(128)` | 有效期duration | 自发放清零时限；expiry_mode=1 时有值 | YES | NULL | DB/DDL/实体注释 |
| `expiry_frequency` | `int` | 清零频次 | 清零频次:1-日清,2-月清；expiry_mode=1 时有值 | YES | NULL | DB/DDL/实体注释 |
| `expiry_annual_years` | `int` | 有效期annualyears | 年度清零下N年；expiry_mode=2 时有值 | YES | NULL | DB/DDL/实体注释 |
| `expiry_annual_date` | `varchar(128)` | 年度清零日期；expiry_mode=2 时有值 | 年度清零日期；expiry_mode=2 时有值 | YES | NULL | DB/DDL/实体注释 |
| `expiry_notify_enabled` | `int` | 积分清零提醒开关 | 积分清零提醒开关:0-否,1-是 | YES | NULL | DB/DDL/实体注释 |
| `expiry_remind_days` | `int` | 有效期reminddays | 提前通知天数；expiry_notify_enabled=1 时有值 | YES | NULL | DB/DDL/实体注释 |
| `rule_description` | `longtext` | 积分规则公示说明 | 积分规则公示说明 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `tinyint` | 逻辑删除 | 逻辑删除(0-否,1-是) | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁版本号 | 乐观锁版本号 | YES | NULL | DB/DDL/实体注释 |
| `validity_mode` | `TINYINT` | 积分有效期模式 | 积分有效期模式:1-永久有效,2-每年固定日期清零 | NO | 1 | DB/DDL/实体注释 |
| `validity_fixed_month` | `TINYINT` | 有效期fixedmonth | 每年固定日期清零月份，validity_mode=2 时有值，范围1-12 | YES |  | DB/DDL/实体注释 |
| `validity_fixed_day` | `TINYINT` | 有效期fixedday | 每年固定日期清零日期，validity_mode=2 时有值，2月最多28日 | YES |  | DB/DDL/实体注释 |
| `validity_next_clear_time` | `DATETIME` | 有效期下一次clear时间 | 下一次固定日期积分清零时间，仅固定日期模式有值；由积分有效期清零任务按清零月日计算，用于扫描到期待清零规则 | YES |  | DB/DDL/实体注释 |
| `validity_notify_enabled` | `TINYINT` | 清零前消息提醒开关 | 清零前消息提醒开关:0-不提醒,1-提醒 | YES |  | DB/DDL/实体注释 |
| `validity_remind_days` | `INT` | 有效期reminddays | 距清零提前提醒天数，validity_notify_enabled=1 时有值 | YES |  | DB/DDL/实体注释 |

#### `dwd_coupon`

- 真实表：`dwd_coupon`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：优惠券。
- 表含义：优惠券。
- 字段来源：`local-pos + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\DwdCoupon.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 商户ID | 商户或租户编号，用于商户维度的数据隔离。 | YES | NULL | 通用字段 |
| `sid` | `bigint` | 门店ID | 门店编号，用于门店维度的数据隔离。 | YES | NULL | 通用字段 |
| `lid` | `bigint` | 逻辑ID | 业务逻辑编号，跨服务或前端引用时优先使用。 | YES | NULL | 通用字段 |
| `report_date` | `datetime` | 营业日期 | 业务归属营业日期或报表日期。 | YES | NULL | 通用字段 |
| `dwd_bill_lid` | `bigint` | 账单明细逻辑ID | POS优惠券业务关联的账单明细逻辑ID。 | YES | NULL | 推断 |
| `dwd_bill_id` | `varchar(128)` | 账单明细ID | POS优惠券业务关联的账单明细ID。 | YES | NULL | 推断 |
| `sub_bill_lid` | `bigint` | 子账单逻辑ID | POS优惠券业务关联的子账单逻辑ID。 | YES | NULL | 推断 |
| `sub_bill_id` | `varchar(128)` | 子账单ID | POS优惠券业务关联的子账单ID。 | YES | NULL | 推断 |
| `coupon_type_no` | `varchar(128)` | 优惠券类型编号 | POS优惠券业务分类或类型。 | YES | NULL | 推断 |
| `coupon_no` | `text` | 优惠券编号 | POS优惠券业务对象的优惠券编号。 | YES | NULL | 推断 |
| `product_no` | `varchar(128)` | 商品编号 | POS优惠券业务对象的商品编号。 | YES | NULL | 推断 |
| `product_name` | `varchar(128)` | 商品名称 | POS优惠券业务对象的商品名称。 | YES | NULL | 推断 |
| `product_unit` | `varchar(128)` | 商品单位 | POS优惠券业务中的商品单位。 | YES | NULL | 推断 |
| `coupon_name` | `varchar(128)` | 优惠券名称 | POS优惠券业务对象的优惠券名称。 | YES | NULL | 推断 |
| `numbers` | `int` | 数量 | POS优惠券业务中的数量。 | YES | NULL | 推断 |
| `coupon_type` | `int` | 优惠券类型 | POS优惠券业务分类或类型。 | YES | NULL | 推断 |
| `member_name` | `varchar(128)` | 会员姓名 | 会员姓名或昵称。 | YES | NULL | 通用字段 |
| `phone` | `varchar(128)` | 手机号 | 会员或联系人手机号。 | YES | NULL | 通用字段 |
| `paid_amount` | `decimal(19,10)` | 实付金额 | POS优惠券业务中的实付金额。 | YES | NULL | 推断 |
| `face_amount` | `decimal(19,10)` | 券面额 | POS优惠券业务中的券面额。 | YES | NULL | 推断 |
| `threshold_amount` | `decimal(19,10)` | 使用门槛金额 | POS优惠券业务中的使用门槛金额。 | YES | NULL | 推断 |
| `begin_at` | `datetime` | 开始时间 | POS优惠券业务中的开始时间。 | YES | NULL | 推断 |
| `end_at` | `datetime` | 结束时间 | POS优惠券业务中的结束时间。 | YES | NULL | 推断 |
| `encrypt_id` | `text` | 加密ID | POS优惠券业务关联的加密ID。 | YES | NULL | 推断 |
| `write_off_channel` | `varchar(128)` | 核销渠道 | POS优惠券业务中的核销渠道。 | YES | NULL | 推断 |
| `write_off_id` | `text` | 核销ID | POS优惠券业务关联的核销ID。 | YES | NULL | 推断 |
| `write_off` | `tinyint(1)` | 是否核销 | POS优惠券业务中的是否核销。 | YES | NULL | 推断 |
| `write_off_at` | `datetime` | 核销时间 | POS优惠券业务中的核销时间。 | YES | NULL | 推断 |
| `write_off_by` | `varchar(128)` | 核销人 | POS优惠券业务中的核销人。 | YES | NULL | 推断 |
| `shift_id` | `varchar(128)` | 班次ID | POS优惠券业务关联的班次ID。 | YES | NULL | 推断 |
| `remark` | `varchar(128)` | 备注 | 人工填写或系统保留的补充说明。 | YES | NULL | 通用字段 |
| `revision` | `int` | 版本号 | 乐观锁或同步版本号。 | YES | NULL | 通用字段 |
| `created_by` | `varchar(128)` | 创建人 | 创建该记录的用户或系统标识。 | YES | NULL | 通用字段 |
| `created_time` | `datetime` | 创建时间 | 记录创建时间。 | YES | NULL | 通用字段 |
| `updated_by` | `varchar(128)` | 更新人 | 最后更新该记录的用户或系统标识。 | YES | NULL | 通用字段 |
| `updated_time` | `datetime` | 更新时间 | 记录最后更新时间。 | YES | NULL | 通用字段 |
| `deleted` | `int` | 逻辑删除标记 | 逻辑删除状态，通常 0 表示未删除、1 表示已删除。 | YES | NULL | 通用字段 |
| `product_unit_no` | `varchar(128)` | 商品单位编号 | POS优惠券业务对象的商品单位编号。 | YES | NULL | 推断 |
| `food_details` | `text` | 菜品明细 | POS优惠券业务中的菜品明细。 | YES | NULL | 推断 |
| `plat_service_amount` | `decimal(19,10)` | 平台服务费 | POS优惠券业务中的平台服务费。 | YES | NULL | 推断 |
| `price` | `decimal(19,10)` | 价格 | POS优惠券业务中的价格。 | YES | NULL | 推断 |
| `promotional_amount` | `decimal(19,10)` | 优惠金额 | POS优惠券业务中的优惠金额。 | YES | NULL | 推断 |
| `receivable_amount` | `decimal(19,10)` | 应收金额 | POS优惠券业务中的应收金额。 | YES | NULL | 推断 |
| `pre_resp_str` | `text` | 预处理响应str | POS优惠券业务中的预处理响应str。 | YES | NULL | 推断 |
| `dish_discount_type` | `varchar(128)` | 菜品折扣类型 | POS优惠券业务分类或类型。 | YES | NULL | 推断 |
| `dish_discount_value` | `decimal(19,10)` | 菜品折扣值 | POS优惠券业务中的菜品折扣值。 | YES | NULL | 推断 |
| `original_resp` | `text` | 原始响应 | POS优惠券业务中的原始响应。 | YES | NULL | 推断 |

#### `pt_member_price`

- 真实表：`pt_member_price`
- 数据源/库：`nms` / `local` / `localhost:8066`
- 表中文名：会员价格。
- 表含义：会员价格。
- 字段来源：`local-pos + SQL:D:\mywork\techdoc\crm技术文档\表结构\a_product0511.sql + SQL:D:\mywork\nms4pos\sql\nms-default-data-20260528.sql + Java:D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-dao\src\main\java\com\nms4cloud\product\dao\entity\PtMemberPrice.java + Java:D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\PtMemberPrice.java`

| 字段 | 类型 | 中文名 | 字段含义 | 可空 | 默认值 | 来源 |
|---|---|---|---|---|---|---|
| `pid` | `bigint` | 物理编号 | 物理编号 | NO | NULL | DB/DDL/实体注释 |
| `mid` | `bigint` | 租户号 | 租户号 | YES | NULL | DB/DDL/实体注释 |
| `sid` | `bigint` | 门店号 | 门店号 | YES | NULL | DB/DDL/实体注释 |
| `lid` | `bigint` | 逻辑编号 | 逻辑编号 | YES | NULL | DB/DDL/实体注释 |
| `dish_lid` | `bigint` | 菜品Lid | 菜品Lid | YES | NULL | DB/DDL/实体注释 |
| `unit` | `varchar(128)` | 菜品单位 | 菜品单位 | YES | NULL | DB/DDL/实体注释 |
| `price` | `decimal(19,10)` | 菜品价格 | 菜品价格 | YES | NULL | DB/DDL/实体注释 |
| `card_type_lid` | `bigint` | 会员卡类型Lid | 会员卡类型Lid | YES | NULL | DB/DDL/实体注释 |
| `card_type` | `varchar(128)` | 会员卡类型名称 | 会员卡类型名称 | YES | NULL | DB/DDL/实体注释 |
| `revision` | `int` | 乐观锁 | 乐观锁 | YES | NULL | DB/DDL/实体注释 |
| `created_by` | `varchar(128)` | 创建人 | 创建人 | YES | NULL | DB/DDL/实体注释 |
| `created_time` | `datetime` | 创建时间 | 创建时间 | YES | NULL | DB/DDL/实体注释 |
| `updated_by` | `varchar(128)` | 更新人 | 更新人 | YES | NULL | DB/DDL/实体注释 |
| `updated_time` | `datetime` | 更新时间 | 更新时间 | YES | NULL | DB/DDL/实体注释 |
| `deleted` | `tinyint` | 是否删除 | 是否删除 | YES | NULL | DB/DDL/实体注释 |
