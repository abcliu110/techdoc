# 后端接口未显式传 mid 时的获取方式分析

## 1. 文档目的

本文用于说明在 `D:\mywork\nms4cloud` 后端项目中，当 API 请求没有显式传入 `mid` 时，系统是如何获取当前 `mid` 的。

重点回答以下问题：

- `mid` 是否由框架统一自动注入
- 哪些接口依赖登录态自动补 `mid`
- 哪些接口通过 `merchantNo` 转换为 `mid`
- 哪些接口通过 `appId + bizId` 反推出 `mid`
- 在什么情况下会因为缺少 `mid` 而直接报错

## 2. 结论概览

在这套后端里，`mid` 不是单一来源，也不是所有接口都靠同一机制自动获取。

常见来源一共有五类：

1. 请求对象本身已经带 `mid`
2. AOP 切面从登录态自动写入 `mid`
3. 控制器手工从登录用户中写入 `mid`
4. 控制器手工从 `merchantNo` 转成 `mid`
5. 控制器或 service 根据 `appId + bizId` 反推出 `mid`

如果以上来源都没有，则很多接口会直接抛出：

- `mid不能为空`
- `mid is not null`
- `集团mid不能为空`

## 3. 基础 DTO 本身不会自动注入 mid

后端公共基类：

- `BasePOJO`
- `BaseDTO`

只是普通数据结构，不包含自动赋值逻辑。

因此：

- 请求对象继承 `BaseDTO` 不代表 `mid` 会自动出现
- `mid` 是否有值，仍然取决于切面、控制器或 service 的补齐逻辑

## 4. 商户后台接口：通过 AOP 自动重置 mid

对于商户后台接口，如果方法上使用了：

- `@SaBizCheckLogin`
- `@SaBizCheckPermission`
- `@SaBizCheckRole`

会触发切面：

- `ResetMidAndSidAspect`

该切面会：

1. 从商户后台 Sa-Token Session 中取出 `BizAdminVO`
2. 把 `user.getMid()` 写回请求对象
3. 同时按权限范围处理 `sid / sids / sidList`

也就是说，这类接口即使前端没传 `mid`，只要当前是商户后台登录态，就会被切面自动补上。

## 5. C 端接口：通过 AOP 自动重置 mid

对于 C 端接口，如果方法上使用了：

- `@SaCheckLogin`
- `@SaCheckPermission`
- `@SaCheckRole`

会触发切面：

- `ResetCustomerLidAspect`

该切面会：

1. 从 C 端用户 Session 中取出 `CUserVO`
2. 将 `user.getMid()` 写入请求对象
3. 同时写入 `cardLid`

因此，会员端、用户端接口如果使用了这些登录注解，即使请求体中没传 `mid`，后端通常也能从当前用户登录态中拿到它。

## 6. 控制器手工从登录态补 mid

除了 AOP 之外，代码中大量控制器会显式写：

- `request.setMid(user.getMid())`
- `request.setMid(admin.getMid())`
- `request.setMid(getMidOfBizAdmin())`

常见来源：

- `getUser()`：C 端用户
- `getBizAdmin()`：商户后台管理员
- `getForceAdmin()`：兼容管理员/老板
- `getMidOfBizAdmin()`：商户后台当前 mid

这种模式的特点是：

- 控制器不依赖 DTO 自带 `mid`
- 在进入 service 前显式把 `mid` 补齐
- 逻辑清晰，但较分散

## 7. 第三方/签名接口：通过 merchantNo 补 mid

许多面对第三方、签名请求、设备接口、POS 接口的 API 并不直接传 `mid`，而是传：

- `merchantNo`
- `terminalId`

控制器里常见写法是：

- `request.setMid(request.getMerchantNo())`

这意味着：

- 对外协议层可以使用 `merchantNo`
- 进入内部业务处理前，统一转换成 `mid`

## 8. 小程序/H5 公版场景：通过 appId + bizId 反推 mid

这类场景主要出现在面向小程序前端、H5 前端、二维码回流、页面动态配置等接口中。

这些接口往往不直接传 `mid`，而是传：

- `appId`
- `bizId`

然后由后端通过配置关系换算出真正的 `mid`。

典型模式包括：

1. 如果请求里已有 `mid`，直接使用
2. 如果有 `bizId`，通过商户表查询 `mid`
3. 如果没有 `bizId`，但有 `appId`，通过微信应用配置反查 `mid`
4. 如果三者都没有，则报错

## 9. service 层也会直接依赖当前登录用户

有些逻辑在 controller 没补 `mid`，但 service 层本身会直接调用：

- `BaseService.getUser()`
- `BaseService.getBizAdmin()`
- `BaseService.getMidOfBizAdmin()`

所以即使 request 对象里没有 `mid`，只要 service 内部是按当前会话用户处理，也仍然可以获得当前商户上下文。

## 10. 哪些情况会直接报错

当接口不属于上述可自动补齐的场景时，如果请求对象中没有 `mid`，后端就会直接校验失败。

常见错误信息包括：

- `mid不能为空`
- `mid is not null`
- `集团mid不能为空`

## 11. 常见接口类型与 mid 来源对照

| 接口类型 | mid 来源 |
|---|---|
| 商户后台管理接口 | `ResetMidAndSidAspect` 从 `BizAdminVO` 自动写入 |
| C 端用户接口 | `ResetCustomerLidAspect` 从 `CUserVO` 自动写入 |
| 控制器内显式处理的业务接口 | `request.setMid(user/admin.getMid())` |
| 第三方签名/POS/设备接口 | `merchantNo -> mid` |
| 小程序/H5 公版接口 | `appId + bizId -> mid` |
| 无登录态、无转换信息的接口 | 必须显式传 `mid`，否则报错 |

## 12. 一个典型例子：二维码绑定接口

二维码绑定查询接口的 service 中，`mid` 的获取逻辑非常典型：

1. 如果 request 自带 `mid`，直接用
2. 如果没有 `mid`，但有 `bizId`，通过商户表查 `mid`
3. 如果连 `bizId` 也没有，但有 `appId`，通过微信应用配置查 `mid`
4. 如果都没有，报错

这说明对于面向小程序前端的接口，后端经常把“恢复商户身份”这一步放在 service 内部完成。

## 13. 最终结论

在 `nms4cloud` 后端里，“API 没传 `mid` 时如何获取 `mid`”的答案不是单一规则，而是多套机制并存：

- 有登录态的后台接口，靠商户后台切面自动写入
- 有登录态的 C 端接口，靠用户切面自动写入
- 很多控制器会手工从当前用户写入 `mid`
- 签名或第三方接口通常用 `merchantNo` 转成 `mid`
- 小程序/H5/公版相关接口则常通过 `appId + bizId` 反推出 `mid`
- 如果以上条件都不成立，就只能显式传 `mid`，否则失败

所以，分析某个接口“为什么没传 `mid` 还能工作”时，优先判断它属于哪一类场景，而不要假设系统里存在一个全局统一的 `mid` 自动注入机制。
