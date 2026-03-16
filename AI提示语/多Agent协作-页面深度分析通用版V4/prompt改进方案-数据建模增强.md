# Prompt 改进方案：数据建模增强（面向代码生成）

## 问题根因

当前 prompt 有三个结构性缺陷导致 AI 无法输出合理的数据库设计：

### 缺陷一：阶段一初扫只看"交互元素"，不看"数据容器"

AI 扫描 UI 时只关注下拉框、按钮、Checkbox 等交互元素，但忽略了一个关键维度：
**哪些 UI 区域是"数据容器"？** 即：哪些区域代表一个独立的数据实体？

一个可重复的卡片区域（如"档位1"、"档位2"）= 明细表。
一个按钮触发的弹窗 = 子实体。
一个多选标签组 = 关联表。

如果初扫阶段不识别这些，后面建模就是在"平地上建高楼"。

### 缺陷二：第二层数据建模指令太抽象

```
2-1 实体关系：主从关系、数量约束、实体vs值对象、关系图
2-2 字段字典：字段名 | UI标签 | 元素类型 | 数据类型 | ...
```

这导致 AI 做了什么？把所有字段按"UI区块"分组（活动基础信息、储值推荐规则、购买规则），
而不是按"数据库实体"分组。结果就是字段字典变成了一张大平表，主表和明细表的边界消失了。

### 缺陷三：业务规则只描述 UI 显隐，不分层

```
RULE-001: WHEN dateType = 永久有效 THEN 隐藏日期范围选择器
```

这只是前端渲染规则。但代码生成还需要知道：
- 这条规则是否影响数据库设计？（如：dateType 是判别字段，决定 startDate/endDate 是否为 NULL）
- 这条规则是否需要后端校验？（如：dateType=指定日期时，startDate 和 endDate 后端也必须校验非空）
- 这条规则的事务边界在哪？（如：保存储值套餐时，档位、礼品、券包是一个事务还是多个？）

---

## 改进方案

### 改进一：阶段一增加"数据容器标注"

在初扫的"快速描述页面"之后、"生成交互探索清单"之前，插入一个新步骤：

```
■ 1.5 数据容器识别

扫描页面，识别以下 5 类数据容器并标注：

[M] 主表单区域 — 页面本身就是主实体的表单
    判断依据：页面标题含"新增/编辑"、整个表单围绕同一业务对象
    示例：「新增储值套餐」页面 → 储值套餐主表

[D] 可重复明细区域 — 页面内可添加/删除多条记录的区域
    判断依据：有「+ 添加」「删除」按钮、有序号或编号、卡片式布局可复制
    示例：档位1/档位2/...（最多5个）→ 储值档位明细表

[P] 弹窗子实体 — 点击按钮弹出的表单弹窗，产生独立数据
    判断依据：弹窗内有自己的表单字段和保存/确定按钮
    示例：「+ 加入礼品」弹窗 → 档位赠送礼品配置表

[G] 弹窗内表格 — 弹窗内嵌套的表格，每行是一条子记录
    判断依据：弹窗内有表格结构，行可编辑
    示例：券包弹窗内的「礼品核销时计入实收」表格 → 券包礼品实收配置表

[J] 多选关联 — 多选下拉框、Checkbox组、标签选择器等产生的 N:N 关系
    判断依据：可选择多个已有实体进行关联
    示例：「品牌」多选 → 套餐品牌关联表
    示例：「适用渠道」Checkbox组 → 套餐渠道关联表
    示例：「适用组织」弹窗多选 → 套餐组织关联表

■ 输出格式：

## 数据容器识别

[M] 主实体：「{页面标题}」→ {建议表名}
  [D] 明细1：「{区域标题}」→ {建议表名}（{数量约束}）
    [P] 子实体1.1：「{弹窗标题}」→ {建议表名}
      [G] 嵌套表格1.1.1：「{表格标题}」→ {建议表名}
    [P] 子实体1.2：「{弹窗标题}」→ {建议表名}
  [J] 关联1：「{元素标题}」→ {建议表名}
  [J] 关联2：「{元素标题}」→ {建议表名}

★ 层级嵌套直接反映主从关系：缩进越深 = 数据库外键层级越深
```

---

### 改进二：重写第二层数据建模

将原来的：
```
2-1 实体关系：主从关系、数量约束、实体vs值对象、关系图
2-2 字段字典：字段名(英文) | UI标签 | 元素类型 | 数据类型 | 存储 | 必填 | 默认值 | 备注
```

替换为：

```
──── 第二层：数据建模（面向数据库设计）────

★ 核心原则：UI 层级 = 数据表层级。字段必须按所属实体分组，不按 UI 区块分组。

2-1 实体识别与层级关系

基于阶段一的「数据容器识别」结果，输出实体层级图：

格式：
{实体中文名}({英文表名}) [{容器类型}]
  PK: {主键字段}
  FK: {外键字段} → {父表名}
  数量约束: {1:N 的 N 上限}
  UI来源: {对应的页面区域/弹窗名称}

示例：
储值套餐(stored_value_package) [M]
  PK: id
  FK: merchant_id → merchant
  UI来源: 页面主表单

  └─ 储值档位(stored_value_tier) [D]
      PK: id
      FK: package_id → stored_value_package
      数量约束: 最多5个
      UI来源: 「储值推荐规则」可重复卡片区域

      └─ 档位赠送礼品(tier_gift) [P]
          PK: id
          FK: tier_id → stored_value_tier
          UI来源: 「+ 加入礼品」弹窗

      └─ 档位赠送券包(tier_gift_bundle) [P]
          PK: id
          FK: tier_id → stored_value_tier
          UI来源: 「+ 加入券包」弹窗

          └─ 券包礼品实收配置(tier_bundle_gift_revenue) [G]
              PK: id
              FK: tier_gift_bundle_id → tier_gift_bundle
              UI来源: 券包弹窗内「礼品核销时计入实收」表格

      └─ 档位会员升级配置(tier_member_upgrade) [D]
          PK: id
          FK: tier_id → stored_value_tier
          UI来源: 「升级到指定会员等级」配置表格

  └─ 套餐品牌关联(package_brand) [J]
      PK: id
      FK: package_id → stored_value_package, brand_id → brand
      UI来源: 「品牌」多选下拉框

  └─ 套餐适用渠道(package_channel) [J]
      PK: id
      FK: package_id → stored_value_package
      字段: channel_code (枚举)
      UI来源: 「适用渠道」Checkbox组

  └─ 套餐适用组织(package_organization) [J]
      ...

  └─ 套餐可用时段(package_time_slot) [D]
      PK: id
      FK: package_id → stored_value_package
      UI来源: 「可用时段」指定时段时的多条时间范围

  └─ 套餐排除日期(package_exclude_date) [D]
      PK: id
      FK: package_id → stored_value_package
      UI来源: 「排除日期」多日期选择器


2-2 字段字典（按实体分表输出）

★ 关键变化：每个实体单独一张表，不要把所有字段混在一起。
★ 每张表必须包含：主键、外键、审计字段（create_time, update_time, create_by）
★ 判别字段必须标注它控制哪些字段的存在性

格式：

#### 表名：{中文名}({英文表名})
父表：{父表名} | 关系：{1:N / N:N} | UI来源：{页面区域/弹窗}

| 字段名 | 列名(英文) | 数据类型 | 必填 | 默认值 | 说明 | 判别控制 |
|--------|-----------|---------|------|--------|------|---------|
| 主键 | id | BIGINT | 是 | 自增 | - | - |
| 外键-套餐 | package_id | BIGINT | 是 | - | FK→stored_value_package | - |
| 活动名称 | activity_name | VARCHAR(100) | 是 | - | UI:「活动名称」 | - |
| 活动日期类型 | date_type | TINYINT | 是 | 1 | 1=指定日期 2=永久有效 | =1时 start_date/end_date 必填 |
| 开始日期 | start_date | DATE | 条件 | NULL | date_type=1时必填 | - |
| ... | ... | ... | ... | ... | ... | ... |

★ "判别控制"列是关键：它直接告诉代码生成器哪些字段是条件必填、条件存在。


2-3 实体关系图（ER 图文本表示）

用标准 ER 表示法输出所有实体间关系，包含基数：

stored_value_package ||──o{ stored_value_tier : "1:N (max 5)"
stored_value_tier ||──o{ tier_gift : "1:N"
stored_value_tier ||──o{ tier_gift_bundle : "1:N"
tier_gift_bundle ||──o{ tier_bundle_gift_revenue : "1:N"
stored_value_tier ||──o{ tier_member_upgrade : "1:N"
stored_value_package }o──o{ brand : "N:N via package_brand"
stored_value_package }o──o{ organization : "N:N via package_organization"
...


2-4 保存事务边界

明确哪些表在同一个事务中保存（前端提交一次 = 后端一个事务）：

事务1「保存储值套餐」：
  - stored_value_package (INSERT/UPDATE)
  - stored_value_tier (批量 INSERT/DELETE+INSERT)
  - tier_gift (随档位一起保存)
  - tier_gift_bundle (随档位一起保存)
  - tier_bundle_gift_revenue (随券包一起保存)
  - tier_member_upgrade (随档位一起保存)
  - package_brand (DELETE+INSERT)
  - package_channel (DELETE+INSERT)
  - package_organization (DELETE+INSERT)
  - package_time_slot (DELETE+INSERT)
  - package_exclude_date (DELETE+INSERT)

事务2「新增分类」（内联创建）：
  - activity_category (INSERT)


2-5 跨区依赖（保留原有）
2-6 判别字段汇总（保留原有，但增加数据层影响列）

| 判别字段 | UI控制效果 | 数据层影响 |
|---------|-----------|-----------|
| date_type | 控制日期选择器显隐 | =永久有效时 start_date/end_date 存 NULL |
| gift_type | 控制礼品/券包按钮显隐 | 决定 tier_gift / tier_gift_bundle 是否有数据 |
| org_scope | 控制门店选择弹窗显隐 | =全部门店时 package_organization 表无数据 |
```

---

### 改进三：业务规则增加"规则分层"

在原有的 3-2 UI条件渲染之后，增加一个新节：

```
3-5 规则执行层分类

将所有 RULE 按执行层分类，直接指导代码生成：

| 规则编号 | 规则描述 | 前端UI层 | 后端校验层 | 数据库层 | 说明 |
|---------|---------|---------|-----------|---------|------|
| RULE-001 | dateType=永久有效 → 隐藏日期 | 显隐控制 | dateType=指定日期时校验startDate/endDate非空 | start_date/end_date 允许NULL | 三层都要处理 |
| RULE-006 | 勾选优惠券 → 显示加入礼品按钮 | 显隐控制 | - | gift_type 枚举字段 | 仅前端 |
| INV-001 | 每套餐最多5档位 | 前端禁用添加按钮 | 后端校验档位数≤5 | - | 前端+后端 |
| INV-003 | 储值当日限制冻结隔日解冻 | - | 定时任务/事件驱动 | 需要冻结金额字段 | 后端+数据库 |

分类标准：
- 「前端UI层」：仅影响界面渲染（显隐、禁用、选项联动）→ 生成前端代码
- 「后端校验层」：需要服务端二次校验或业务逻辑处理 → 生成 Service/Validator 代码
- 「数据库层」：影响表结构设计（字段可空性、约束、索引）→ 生成 DDL/Entity
- 「定时任务/事件」：需要异步处理 → 生成 Job/EventHandler 代码


3-6 保存接口的请求体结构（嵌套 DTO 预览）

基于实体层级，预览保存接口的请求体嵌套结构，让代码生成器直接使用：

POST /api/stored-value-packages
{
  // ─── 主表字段 ───
  "brandIds": [1, 2],              // → package_brand 关联表
  "activityCategoryId": 10,
  "activityName": "充100送20",
  "dateType": 1,
  "startDate": "2024-01-01",
  "endDate": "2024-12-31",
  ...

  // ─── 明细表：档位列表 ───
  "tiers": [
    {
      "storedAmount": 100,
      "bonusAmount": 20,
      "bonusPoints": 50,
      "amountLimitType": 1,
      "amountLimitPercent": 80,

      // ─── 子明细：赠送礼品 ───
      "gifts": [
        {
          "giftId": 101,
          "issueCount": 2,
          "validityType": 1,
          "validDays": 30,
          "effectType": 1,
          "effectTime": 0,
          "countAsRevenue": false
        }
      ],

      // ─── 子明细：赠送券包 ───
      "giftBundles": [
        {
          "bundleId": 201,
          "bundleQuantity": 1,
          // ─── 孙明细：券包内礼品实收配置 ───
          "giftRevenueList": [
            {
              "giftId": 301,
              "countAsRevenue": true,
              "revenueType": 1,
              "revenuePercent": 80
            }
          ]
        }
      ],

      // ─── 子明细：会员升级 ───
      "memberUpgrades": [
        { "memberPlanId": 1, "targetLevelId": 5 }
      ],

      "levelExtension": true,
      "extensionDays": 30
    }
  ],

  // ─── 关联表：渠道 ───
  "channels": ["POS", "WECHAT_MINI", "ALIPAY_MINI"],

  // ─── 关联表：组织 ───
  "orgScope": 1,
  "orgIds": [1001, 1002],

  // ─── 关联表：适用用户 ───
  "userScope": 1,
  "userPlanIds": [1],
  "userLevelIds": [1, 2],

  // ─── 关联表：时段 ───
  "timeSlots": [
    { "startTime": "09:00", "endTime": "12:00" },
    { "startTime": "14:00", "endTime": "18:00" }
  ],

  // ─── 关联表：排除日期 ───
  "excludeDates": ["2024-02-10", "2024-10-01"],

  "legalAgreed": true
}

★ 嵌套层级必须与 2-1 的实体层级完全对应。
★ 代码生成器可以直接从这个结构生成 DTO 类。
```

---

### 改进四：输出结构调整

将原来的：
```
三、数据模型（3.1 实体关系图 3.2 字段字典 3.3 判别字段 3.4 跨区依赖）
```

替换为：
```
三、数据模型
  3.1 数据容器识别（UI层级 → 表层级映射）
  3.2 实体层级与关系图（含 PK/FK/基数/UI来源）
  3.3 字段字典（按实体分表输出，每表含主键、外键、审计字段）
  3.4 判别字段汇总（含数据层影响）
  3.5 跨区依赖
  3.6 保存事务边界

四、业务规则
  4.1 UI联动规则（保留原有）
  4.2 不变量（保留原有）
  4.3 计算字段（保留原有）
  4.4 规则执行层分类（新增：前端/后端/数据库/定时任务）
  4.5 保存接口请求体结构（新增：嵌套 DTO 预览）
```

---

## 完整的修改差异（可直接应用到 prompt-all-in-one-需求分析.txt）

### 修改点 1：阶段一，在"■ 2. 生成交互探索清单"之前插入

位置：第 31 行之后

插入内容见上方「改进一」的完整文本。

### 修改点 2：阶段三，替换第二层

位置：第 185-191 行

替换内容见上方「改进二」的完整文本。

### 修改点 3：阶段三，在第三层末尾追加

位置：第 205 行之后

追加内容见上方「改进三」的 3-5 和 3-6。

### 修改点 4：阶段三输出结构

位置：第 261-263 行

替换内容见上方「改进四」。

---

## 这套改进为什么有效？

| 问题 | 原因 | 改进后 |
|------|------|--------|
| 主表和明细表关系丢失 | 字段按 UI 区块分组，不按实体分组 | 强制按实体分表输出字段字典 |
| 弹窗产生的子实体没有建表 | 弹窗被当作"交互细节"而非"数据容器" | 阶段一就标注 [P] 弹窗子实体 |
| 多选关联缺少中间表 | 没有识别 N:N 关系的机制 | 阶段一标注 [J] 多选关联 |
| 业务规则只描述 UI 显隐 | 规则没有分层 | 新增规则执行层分类表 |
| 代码生成器不知道 DTO 嵌套结构 | 需求文档没有请求体预览 | 新增保存接口请求体结构 |
| 事务边界不明确 | 没有说明哪些表一起保存 | 新增保存事务边界说明 |

核心思想：**让需求分析文档的结构天然对齐代码结构**。
实体层级 → Java Entity 类层级。
字段字典 → Entity 字段定义。
请求体结构 → DTO 类定义。
规则执行层 → Service/Controller/前端代码的分工。
事务边界 → @Transactional 的范围。

---

## 第二轮补充（深度审查后发现的5个断点）

### 断点一：代码生成师（Agent-5）不知道要生成多张表

原 Agent-5 假设每个页面只有一个主实体。已修改为：
- 按实体层级关系，为每个 [OWN] 实体生成独立的 Entity + Mapper
- CreateReqDTO 按请求体结构生成嵌套 DTO（主表 DTO 包含 List<子表DTO>）
- Service 层一个主 Service 注入所有子表 Mapper
- 修改了代码生成顺序：枚举 → Entity → 嵌套DTO → 嵌套VO → Mapper → Convert → Service → Controller

### 断点二：拥有实体 vs 引用实体

新增 [OWN] / [REF] 标记：
- [OWN] 本页面创建的数据（储值套餐、档位、礼品配置等）→ 生成完整代码
- [REF] 本页面引用的已有数据（品牌、会员方案、优惠券等）→ 只存 ID，不生成代码

### 断点三：枚举值缺少标准化定义

新增「枚举值定义表」（2-2.5 / 2-7），要求：
- 所有 Radio、单选下拉框、Toggle 字段必须定义数值映射
- 格式：字段名 | 所属表 | 枚举值(int) | 含义 | 说明
- 代码生成器直接用此表生成 Java 枚举类

### 断点四：编辑模式 DTO 差异

请求体结构同时输出新增和编辑两种模式：
- 新增(POST)：明细记录没有 id
- 编辑(PUT)：明细记录有 id（更新）或没有 id（新增），未出现的 id = 删除

### 断点五：深度追踪时回更新数据容器

阶段二深度追踪规则新增第 0 步：
- 当新界面被发现时，先判断是否包含新的数据容器
- 如有，更新数据容器层级图

---

## 最终修改文件清单（共 11 个文件）

| 文件 | 修改内容 |
|------|---------|
| `prompt-all-in-one-需求分析.txt` | 数据容器识别、实体层级建模、枚举表、规则分层、请求体结构、深度追踪回更新 |
| `prompt-00-信息补全者.txt` | G-1.5 数据容器识别维度 |
| `01-Agent-信息补全者-通用-V2.md` | 同步 G-1.5 |
| `prompt-01-业务分析师.txt` | 实体层级、按实体分表、OWN/REF、枚举表、判别字段数据层影响 |
| `02-Agent-业务分析师-通用-V2.md` | 同步上述 + 更新输出模板 |
| `prompt-02-规则工程师.txt` | 规则执行层分类(3-5)、请求体结构(3-6) |
| `03-Agent-规则工程师-通用-V2.md` | 同步 3-5、3-6 |
| `prompt-04-文档整合者.txt` | 更新输出结构（三、四章节） |
| `05-Agent-文档整合者-通用-V2.md` | 更新输出模板（三、四章节） |
| `prompt-05-代码生成师.txt` | V3增强指令、枚举层、嵌套DTO、OWN/REF、事务边界、生成顺序 |
| `06-Agent-代码生成师-通用-V2.md` | 同步上述所有修改 |

