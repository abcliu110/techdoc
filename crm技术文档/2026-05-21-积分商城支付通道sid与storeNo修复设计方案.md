# 积分商城支付通道 sid 与 storeNo 修复设计方案

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复积分商城微信支付因 `sid` 与支付通道 `store_no` 语义不一致导致的「请设置门店号对应的支付通道」报错。

**Architecture:** 当前短期方案在商城业务层解析支付通道门店号，不改订单业务 `sid`，只在调用支付服务时传入与 `pay_store_and_channel.store_no` 对齐的值。长期方案是在支付请求模型中显式区分业务 `sid` 与支付通道 `storeNo`，逐步消除字段复用。

**Tech Stack:** Java, Spring Boot, MyBatis-Plus, RocketMQ, nms4cloud mall/payment modules, Taro frontend.

---

## 1. 背景

积分商城微信支付报错：

```text
请设置门店号对应的支付通道
```

现有排查结论：

- 商户后台支付通道配置总部记录时，`pay_store_and_channel.store_no` 保存为 `mid`。
- 积分商城下单和支付链路中，订单 `sid` 来自会员登录态 `user.sid`。
- 支付服务在未指定支付通道 `lid` 时，会用支付请求里的 `sid` 去查询 `pay_store_and_channel.store_no`。
- 当会员登录态 `sid = 1`，支付服务实际查询的是 `store_no = 1`，但总部支付通道配置实际是 `store_no = mid`，因此查不到。

核心问题不是支付通道配置漏保存 `store_no = 1`，而是 `sid` 被不同模块赋予了不同语义：

| 模块 | 字段 | 当前语义 |
|---|---|---|
| 商城订单 | `mall_order.sid` | 订单/会员登录态上下文 |
| 支付请求 | `MiniPayRequest.sid` | 被支付服务当作支付通道门店号使用 |
| 支付通道表 | `pay_store_and_channel.store_no` | 支付通道绑定的收款门店号；总部使用 `mid` |
| 页面装修 | `sid = -1` | 总部/全局配置 |

## 2. 直接证据

### 2.1 商城后端覆盖前端 sid

文件：

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-app\src\main\java\com\nms4cloud\mall\app\controller\MallUserController.java
```

当前逻辑：

```java
public void setMallUser(MallUserDTO request) {
  CUserVO user = checkUser();
  request.setMid(user.getMid());
  request.setSid(user.getSid());
  request.setUserId(user.getCardLid());
  request.setNickname(user.getName());
  request.setHeadImg(user.getAvatar());
  request.setOpenId(user.getOpenid());
  request.setUserName(user.getName());
  request.setUserPhone(user.getPhone());
  Assert.isTrue(Objects.nonNull(user.getCardLid()), "请先开通会员");
}
```

结论：只改前端传参不能解决问题，因为后端会用登录态覆盖前端 `sid`。

### 2.2 商城支付把订单 sid 传给支付服务

文件：

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-service\src\main\java\com\nms4cloud\mall\service\MallOrderServicePlus.java
```

当前 `toPay()` 中创建微信支付请求：

```java
final MiniPayRequest payRequest = new MiniPayRequest();
payRequest.setMid(order.getMid());
payRequest.setSid(order.getSid());
payRequest.setSubAppid(order.getAppId());
payRequest.setOpenId(order.getOpenId());
payRequest.setTotalFee(total.longValue());
```

结论：订单 `sid` 被原样传入支付模块。

### 2.3 支付服务用 sid 查询 store_no

文件：

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-service\src\main\java\com\nms4cloud\payment\service\PayChannelServicePlus.java
```

当前逻辑：

```java
final PayStoreAndChannelVO storeAndChannelVO =
    payStoreAndChannelServicePlus.get(
        new PayStoreAndChannelGetDTO().setStoreNo(request.getSid()));
Assert.notNull(storeAndChannelVO, "请设置门店号对应的支付通道");
```

结论：支付服务把 `PayChannelGetDTO.sid` 当作 `pay_store_and_channel.store_no` 使用。

### 2.4 后台总部支付通道保存为 mid

文件：

```text
D:\mywork\nms4cloud-biz-ui\src\pages\OperationalInfoMrg\components\PayChannel\index.tsx
```

当前逻辑会把总部虚拟门店 `sid = -1` 转为 `sid = mid`：

```tsx
res.data = res.data?.map((v) => {
  if (v.sid === '-1') {
    return {
      ...v,
      sid: v.mid,
    };
  }
  return { ...v };
});
```

保存支付通道时：

```tsx
storeNo: record.sid,
storeName: record.name,
channelNo: val || '',
```

结论：总部支付通道应查 `store_no = mid`，不是 `store_no = 1`。

## 3. 推荐方案：商城支付前解析 payStoreNo

### 3.1 方案说明

短期修复不修改 `mall_order.sid`，只在商城调用支付模块前，把支付请求中的 `sid` 设置为支付通道需要的 `store_no`。

当前积分商城按总部商城处理，因此支付通道门店号解析为：

```text
payStoreNo = order.mid
```

也就是说：

- 订单业务字段 `mall_order.sid` 保持原样，避免影响订单、订单明细、统计和历史数据。
- 支付请求 `MiniPayRequest.sid` 在当前支付模块语义下传 `mid`，用于命中总部支付通道。
- 支付模块暂不改公共接口，减少回归风险。

### 3.2 修改文件

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-service\src\main\java\com\nms4cloud\mall\service\MallOrderServicePlus.java
```

### 3.3 代码修改

新增私有方法：

```java
private Long resolveMallPayStoreNo(MallOrder order) {
  return order.getMid();
}
```

将 `toPay()` 中：

```java
payRequest.setSid(order.getSid());
```

修改为：

```java
payRequest.setSid(resolveMallPayStoreNo(order));
```

修改后的局部代码：

```java
final MiniPayRequest payRequest = new MiniPayRequest();
payRequest.setMid(order.getMid());
payRequest.setSid(resolveMallPayStoreNo(order));
payRequest.setSubAppid(order.getAppId());
payRequest.setOpenId(order.getOpenId());
payRequest.setTotalFee(total.longValue());
String terminalTrace = IdWorkerPlus.getIdStr();
payRequest.setTerminalTrace(terminalTrace);
payRequest.setNotifyUrl(
    CommonConstants.NOTIFY_URL_PREFIX_ROCKETMQ
        + RocketMqTopicConstants.MALL_ORDER_CLOSE_QUEUE);
payRequest.setAttach(JSON.toJSONString(orderNotifyAttach));
```

### 3.4 是否修改 success()

同文件 `success()` 方法中也有：

```java
payRequest.setSid(order.getSid());
```

这里不是正常发起微信支付的主路径，而是通知支付模块支付成功/发送队列消息的辅助路径。建议处理方式：

1. 如果确认该方法不会触发支付通道解析，可以先不改。
2. 如果该方法也会进入支付通道解析或支付结果补偿流程，应同步改为：

```java
payRequest.setSid(resolveMallPayStoreNo(order));
```

为保持语义一致，推荐同步修改。

## 4. 不推荐方案

### 4.1 不推荐只改前端

涉及文件：

```text
D:\mywork\taro-mall\src\pagePop\pointsmallpay\index.tsx
D:\mywork\taro-mall\src\pagePop\pointsmallpaycenter\index.tsx
```

前端当前传：

```ts
sid: currentUser?.sid?.replace('-', '')
```

即使改成 `shopStore.curShop.sid` 或 `mid`，后端 `MallUserController.setMallUser()` 仍会执行：

```java
request.setSid(user.getSid());
```

所以前端改动不能作为根因修复点。前端可以后续清理，但不能只依赖前端。

### 4.2 不推荐修改 pay_store_and_channel 补 store_no = 1

原因：

- 当前总部支付通道保存为 `store_no = mid` 是后台逻辑明确产生的结果。
- 强行补 `store_no = 1` 会制造一条和业务约定不一致的数据。
- 后续换商户、迁移数据、门店真实 sid 为 1 等场景容易产生歧义。

### 4.3 不推荐支付通道查询全局 fallback

例如在支付模块中做：

```java
// 伪代码，不推荐
PayStoreAndChannelVO vo = getByStoreNo(request.getSid());
if (vo == null) {
  vo = getByStoreNo(request.getMid());
}
```

原因：

- 支付模块是通用能力，POS、充值、二维码收款、商城等入口都会经过。
- 全局 fallback 会掩盖调用方传错支付门店号的问题。
- 如果真实门店没有配置支付通道，fallback 到总部可能导致资金走错通道。

## 5. 长期方案：支付请求显式增加 storeNo

### 5.1 目标

从模型层面区分两个概念：

| 字段 | 含义 |
|---|---|
| `sid` | 业务门店/订单上下文 |
| `storeNo` | 支付通道绑定的收款门店号 |

### 5.2 修改范围

长期方案需要修改：

```text
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-api\src\main\java\com\nms4cloud\payment\api\request\BasePayRequest.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-payment\nms4cloud-payment-service\src\main\java\com\nms4cloud\payment\service\PayChannelServicePlus.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-service\src\main\java\com\nms4cloud\mall\service\MallOrderServicePlus.java
```

### 5.3 BasePayRequest 增加字段

```java
@Schema(title = "支付通道门店号")
private Long storeNo;
```

### 5.4 商城侧设置 storeNo

```java
payRequest.setMid(order.getMid());
payRequest.setSid(order.getSid());
payRequest.setStoreNo(resolveMallPayStoreNo(order));
```

### 5.5 支付通道查询优先使用 storeNo

```java
Long storeNo = Optional.ofNullable(request.getStoreNo()).orElse(request.getSid());
Assert.notNull(storeNo, "门店号不能为空");
final PayStoreAndChannelVO storeAndChannelVO =
    payStoreAndChannelServicePlus.get(
        new PayStoreAndChannelGetDTO().setStoreNo(storeNo));
```

这个方案更干净，但涉及公共支付 API，需要完整回归，因此不建议作为本次紧急修复的第一步。

## 6. 实施计划

### Task 1: 增加商城支付门店号解析

**Files:**

- Modify: `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-service\src\main\java\com\nms4cloud\mall\service\MallOrderServicePlus.java`

- [ ] **Step 1: 在 `MallOrderServicePlus` 中新增解析方法**

```java
private Long resolveMallPayStoreNo(MallOrder order) {
  return order.getMid();
}
```

- [ ] **Step 2: 修改 `toPay()` 中的 `MiniPayRequest.sid`**

```java
payRequest.setSid(resolveMallPayStoreNo(order));
```

- [ ] **Step 3: 同步检查 `success()` 中的 `MiniPayRequest.sid`**

推荐同步改为：

```java
payRequest.setSid(resolveMallPayStoreNo(order));
```

### Task 2: 增加单元测试或服务层验证

**Files:**

- Test: `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-mall\nms4cloud-mall-service\src\test\java\com\nms4cloud\mall\service\MallOrderServicePlusTest.java`

- [ ] **Step 1: 增加测试覆盖支付请求 sid 解析**

测试目标：

```text
given mall order mid = 10001, sid = 1
when mall order creates MiniPayRequest for WeChat payment
then MiniPayRequest.sid = 10001
```

如果现有服务测试搭建成本较高，可先对新增解析方法做包内可见方法测试，或通过 mock `dealFeign.miniPay()` 捕获请求参数。

- [ ] **Step 2: 验证失败场景**

修改前期望：

```text
MiniPayRequest.sid = 1
```

修改后期望：

```text
MiniPayRequest.sid = 10001
```

### Task 3: 回归验证

- [ ] **Step 1: 数据验证**

确认总部支付通道记录：

```sql
select mid, store_no, channel_no, channel_no_for_recharge
from pay_store_and_channel
where mid = ${mid}
  and store_no = ${mid}
  and deleted = 0;
```

- [ ] **Step 2: 订单验证**

确认积分商城订单仍保留原业务 sid：

```sql
select mid, sid, lid, state, out_trade_no
from mall_order
where lid = ${order_lid};
```

- [ ] **Step 3: 支付请求验证**

通过日志、断点或 mock 验证：

```text
MiniPayRequest.mid = 当前商户 mid
MiniPayRequest.sid = 当前商户 mid
```

- [ ] **Step 4: 支付通道命中验证**

确认支付服务实际查询：

```text
pay_store_and_channel.store_no = mid
```

并不再报：

```text
请设置门店号对应的支付通道
```

## 7. 风险与边界

### 7.1 当前方案的风险

当前方案仍然复用 `MiniPayRequest.sid` 表示支付通道门店号，只是把商城侧传入值修正为 `mid`。它没有彻底解决支付请求字段语义混用问题。

### 7.2 风险可控原因

- 修改范围只在商城支付调用点。
- 不改变订单表 `sid`。
- 不改变支付通道配置保存逻辑。
- 不改变通用支付模块的全局行为。
- 不影响 POS、二维码收款、充值等其他入口的支付通道选择逻辑。

### 7.3 需要业务确认的问题

如果未来支持门店级积分商城，需要明确：

1. 积分商城订单是否归属具体门店。
2. 门店级积分商城支付是否应走门店自己的 `store_no = sc_store.sid`。
3. 总部积分商城和门店积分商城的入口是否能从请求或页面上下文明确区分。

如果答案是支持门店级积分商城，则 `resolveMallPayStoreNo()` 需要扩展为：

```java
private Long resolveMallPayStoreNo(MallOrder order) {
  if (isHeadquartersMallOrder(order)) {
    return order.getMid();
  }
  return order.getSid();
}
```

其中 `isHeadquartersMallOrder(order)` 不能靠猜测，需要有明确业务字段或入口标记。

## 8. 最终建议

本次修复建议采用：

```text
商城支付前解析 payStoreNo，并将 MiniPayRequest.sid 设置为 mid。
```

不建议：

- 只改前端。
- 补一条 `store_no = 1` 的支付通道配置。
- 在支付模块做全局 fallback。
- 直接把 `mall_order.sid` 改成 `mid`。

后续技术治理建议采用：

```text
BasePayRequest 增加 storeNo，支付通道查询从 sid 迁移到 storeNo。
```

这样可以最终消除 `sid` 与 `store_no` 的语义混用。
