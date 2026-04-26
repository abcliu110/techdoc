# nms4cloud项目通用指令

## 1. 适用范围

本文档适用于 `D:\mywork\nms4cloud` 项目中的通用开发、分析、排障、文档输出任务。

这是一个多模块 Maven 单体仓式微服务项目，前后端协作场景以 `Spring Cloud + React` 为主，业务服务集中在 `nms4cloud-app` 下。

如果任务落在 `nms4cloud-app/2_business/nms4cloud-crm/`，除本文档外，还必须遵守 CRM 专项规则，且 CRM 规则优先于平台通用规则。

## 2. 项目总览

### 2.1 技术栈

- Java 21
- Spring Boot 3.4.1
- Spring Cloud 2024.0.0
- Spring Cloud Alibaba 2022.0.0.0-RC2
- Maven 多模块
- Nacos
- RocketMQ
- Sa-Token

### 2.2 目录结构

```text
nms4cloud/
  nms4cloud-starter/    基础设施与公共 starter
  nms4cloud-app/        业务应用
    1_platform/         平台核心服务
    2_business/         业务服务
    3_customer/         客户侧服务
  docs/                 项目文档
  scripts/              脚本
```

### 2.3 服务统一分层

每个业务服务一般拆成四层：

```text
nms4cloud-{service}/
  {service}-api/
  {service}-dao/
  {service}-service/
  {service}-app/
```

职责边界：

- `*-app`：Controller、启动类、配置
- `*-service`：业务逻辑、事务、编排
- `*-dao`：Entity、Mapper、数据访问
- `*-api`：DTO、VO、Feign、枚举、常量

## 3. 绝对约束

### 3.1 编码与文件读写

项目处于中文 Windows 环境。

处理已有文本文件时必须遵守：

- 先用 `chardet` 检测是 `GBK` 还是 `UTF-8`
- 必须用检测到的准确编码读取
- 修改已有文件时，必须保持原编码写回
- Python `open()` 必须显式传 `encoding=`

新建文本文件和生成 CSV 时：

- 使用 `utf-8-sig`

### 3.2 分层边界不可破坏

严格遵守：

- Controller 只做接收请求、参数校验、转发调用、包装响应
- Service 才是业务规则唯一归属地
- DAO/Mapper 只做数据访问
- 不允许 Controller 直接调用 Mapper
- 不允许 Entity 依赖 DTO/VO
- 不允许跨服务直接访问对方 Mapper
- 跨服务调用统一走 `api` 模块中的 Feign

### 3.3 多租户隔离

必须默认存在并检查：

- `mid`：商户 ID
- `sid`：门店 ID

分析或修改业务逻辑时必须确认：

- 数据是否按租户隔离
- 查询和更新是否带租户条件
- 是否存在跨门店/跨商户误操作风险

### 3.4 枚举必须闭环

只要业务字段是固定选项，必须按枚举处理，不允许半套落地。

必须覆盖：

- DTO
- VO
- Entity
- Service 判断逻辑
- OpenAPI/Apifox 文档

必须遵守：

- 前端传枚举 `code`
- 数据库存枚举 `code`
- 业务代码比较枚举常量，不比较魔法值
- 枚举类和枚举项写中文注释

### 3.5 验证要求

任何非纯文档任务完成前，至少做最小必要验证：

- 编译
- 定向测试
- 相关模块测试
- 必要时接口或链路验证

优先跑最小相关范围，而不是无脑全量跑。

## 4. CRM 模块覆盖规则

当任务范围位于：

`D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\`

必须先阅读并遵守：

- `D:\mywork\techdoc\AI提示语\多Agent协作-页面深度分析通用版V9\code-style-crm.txt`
- `D:\mywork\techdoc\AI提示语\多Agent协作-页面深度分析通用版V9\code-style-nms4cloud.txt`

其中 CRM 模块的关键覆盖规则如下。

### 4.1 ORM 与注解体系

CRM 使用的是 `MyBatis-Plus`，不是 `MyBatis-Flex`。

标准注解体系：

- `@TableName`
- `@TableId`
- `@TableField`
- `@TableLogic`

### 4.2 CRM 分层约束

CRM 的典型调用链：

- Controller
- ServicePlus
- IService / Mapper

对象转换优先使用：

- `BeanUtilsPlus.mapBean(...)`

### 4.3 CRM 命名规范

CRM 方法命名统一用：

- `add`
- `update`
- `get`
- `list`
- `del`

不要使用：

- `create`
- `getDetail`
- `delete`

类命名通常带 `Crm` 前缀。

### 4.4 CRM 接口规范

CRM 业务接口统一使用：

- `POST`

不要新增 `GET/PUT/DELETE` 风格接口。

### 4.5 多值字段存储规则

以下类型字段如果是多选，不允许存逗号分隔字符串：

- 场景
- 渠道
- 周几
- 每月几号

标准做法：

- Java 使用 `List<Integer>`
- 持久化使用 JSON 整数数组
- 配合 `JacksonTypeHandler`

### 4.6 互斥字段清理规则

当业务字段存在模式切换、开关切换、范围互斥时：

- 不相关字段必须在 Convert 层的 `toEntity()` 中主动置 `null`
- 不要校验当前模式下无关的字段

### 4.7 CRM 枚举规则

CRM 中只要业务字段属于状态、模式、范围、类型、开关类，必须做枚举端到端建模。

如果已经存在枚举类，但 DTO/Entity/Service 仍在用 `Integer`，这不算完成，必须补齐调用链。

## 5. 任务执行方式

### 5.1 如果任务是“理解功能”

必须按“功能闭环”分析，而不是按文件浏览。

分析顺序：

1. 找入口
2. 找前端交互
3. 找 API
4. 找后端主链路
5. 找数据变化
6. 找状态流转
7. 找异常与配置影响
8. 输出证据表

最终交付至少包含：

- 功能摘要
- 用户入口与操作路径
- 前端实现链路
- 后端调用链
- 业务规则
- 数据与状态流转
- 异常与风险
- 证据表

### 5.2 如果任务是“改代码”

必须遵守以下顺序：

1. 先明确改动模块和层级
2. 先确认是否已有相同模式、相同枚举、相同 Convert、相同 Service 写法
3. 优先复用现有工具和既有模式
4. 小步修改，不新增不必要抽象
5. 修改后做最小充分验证
6. 输出影响范围和风险点

### 5.3 如果任务是“清理/重构”

必须额外遵守：

- 先写清理计划
- 能先补测试就先补测试
- 优先删除，不优先新增层次
- 不得改变既有行为
- 必须说明行为保护证据

## 6. 常用命令

在仓库根目录 `D:\mywork\nms4cloud` 下使用 Maven Wrapper。

全量构建：

```powershell
.\mvnw.cmd clean install -DskipTests
```

全量测试：

```powershell
.\mvnw.cmd test
```

测试 CRM 单模块：

```powershell
.\mvnw.cmd -pl nms4cloud-app/2_business/nms4cloud-crm/nms4cloud-crm-app -am test
```

运行某个 Spring Boot 模块：

```powershell
.\mvnw.cmd -pl nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-app spring-boot:run
```

## 7. 输出要求

输出必须优先让人能直接用，不要只堆源码细节。

建议结构：

1. 结论摘要
2. 改动或分析结果
3. 关键文件
4. 验证结果
5. 风险与待确认问题

如果是功能分析类任务，必须附证据表。

如果是代码修改类任务，必须说明：

- 改了哪些模块
- 为什么这样改
- 验证做了什么
- 还有什么没验证

## 8. 给其他AI的项目标准指令

下面这段可以直接发给其他 AI 执行。

```text
你正在处理 D:\mywork\nms4cloud 项目。

这是一个 Java 21 + Spring Boot 3.4.1 + Spring Cloud 2024.0.0 的多模块 Maven 微服务项目。业务服务位于 nms4cloud-app，下分 1_platform、2_business、3_customer 三层。每个服务通常按 api / dao / service / app 四层拆分。

执行时必须遵守：
1. 严格分层，Controller 不写业务逻辑，不直接调 Mapper。
2. 跨服务调用统一走 api 模块的 Feign，不跨服务访问 Mapper。
3. 处理已有文本文件前，必须先用 chardet 检测是 GBK 还是 UTF-8，并按原编码读写。
4. 多租户场景默认检查 mid/sid 约束。
5. 业务固定选项字段必须做枚举端到端建模，前端传 code，数据库存 code，业务逻辑比较枚举而不是魔法值。
6. 修改后必须做最小充分验证，至少说明已验证和未验证项。

如果任务位于 nms4cloud-app/2_business/nms4cloud-crm/，追加遵守：
1. CRM 使用 MyBatis-Plus，不是 MyBatis-Flex。
2. CRM 方法命名统一使用 add/update/get/list/del。
3. CRM 所有接口使用 POST。
4. 多值字段必须使用 List<Integer> + JSON 数组 + JacksonTypeHandler，不得使用逗号字符串。
5. 互斥字段必须在 Convert 的 toEntity() 中清空无关字段。
6. 必须先阅读：
   - D:\mywork\techdoc\AI提示语\多Agent协作-页面深度分析通用版V9\code-style-crm.txt
   - D:\mywork\techdoc\AI提示语\多Agent协作-页面深度分析通用版V9\code-style-nms4cloud.txt

输出时请明确：
- 结论
- 证据
- 风险
- 已验证项
- 未验证项
```

## 9. 最终原则

在 nms4cloud 项目里，最重要的不是“写出能跑的代码”，而是：

- 不破坏分层
- 不绕过租户边界
- 不留下半套枚举
- 不违反模块既有风格
- 不在中文 Windows 环境中把编码搞坏

项目已有模式优先于个人习惯，模块规则优先于通用框架习惯，CRM 规则优先于平台泛化规则。
