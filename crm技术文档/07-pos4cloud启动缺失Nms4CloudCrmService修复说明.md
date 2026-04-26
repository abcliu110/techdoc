# Pos4cloud 启动缺失 `Nms4CloudCrmService` 修复说明

## 问题背景

`pos4cloud` 启动时出现如下错误：

```text
Field nms4CloudCrmService in com.nms4cloud.pos2plugin.service.sync.SyncBaseDataService
required a bean of type 'com.nms4cloud.pos2plugin.service.member.cloud.Nms4CloudCrmService'
that could not be found.
```

排查结果：

1. `Nms4CloudCrmService` 是 Forest 接口客户端，不是普通的 `@Service` Bean。
2. `SyncBaseDataService` 最近新增了对 `Nms4CloudCrmService` 的强依赖注入。
3. `Pos4cloudApplication` 之前没有对 `com.nms4cloud.pos2plugin.service.member.cloud` 包执行 `@ForestScan`，因此启动时无法注册该 Bean。

## 本次修改

本次只修改了 1 个文件：

`D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-app\src\main\java\com\nms4cloud\pos4cloud\Pos4cloudApplication.java`

具体修改内容：

1. 新增导入：

```java
import com.dtflys.forest.springboot.annotation.ForestScan;
```

2. 在启动类注解区域新增：

```java
@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})
```

3. 新增注释，说明原因：

```java
// Pos4cloud loads pos2plugin sync services, so its Forest clients must be registered here too.
```

## 修改位置说明

修改后的关键位置如下：

1. `Pos4cloudApplication.java` 导入区增加 `ForestScan`
2. `@MapperScan(...)` 下方新增 Forest 扫描注解
3. Forest 扫描注解上方新增说明性注释

## 这样修改的原因

`pos4cloud` 已经依赖了 `nms4cloud-pos2plugin-biz`，并且会加载其中的同步服务。
这些服务内部会使用 `Nms4CloudCrmService` 等 Forest 客户端。

如果只做普通的 `@ComponentScan`，Forest 接口不会自动成为 Spring Bean。
因此必须在启动类中显式补充 `@ForestScan`，让 `Nms4CloudCrmService` 正常注册到 Spring 容器。

## 验证情况

已执行编译命令：

```powershell
mvn -pl nms4cloud-pos4cloud/nms4cloud-pos4cloud-app -am -DskipTests compile
```

结果：

1. 本次新增的 `@ForestScan` 没有产生新的语法错误。
2. 构建未能完整结束，但失败原因不是本次修改导致。
3. 当前编译失败点在：

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\DwdBillOpsServiceImpl.java:3878`

报错信息为：

```text
找不到符号
符号:   方法 getNonZeroDecimalDigits(java.math.BigDecimal)
位置: 类 com.nms4cloud.common.util.NumberUtilPlus
```

因此，本次修改已经落地，但完整构建验证被现有无关编译问题阻断。

## 结论

本次修复属于启动层面的 Bean 注册修复，目的如下：

1. 保留最近 `SyncBaseDataService` 中新增的 CRM 积分权益规则同步逻辑
2. 避免因 `Nms4CloudCrmService` 未注册导致 `pos4cloud` 启动失败
3. 以最小改动方式修复问题，不回退业务代码，不扩大改动范围
