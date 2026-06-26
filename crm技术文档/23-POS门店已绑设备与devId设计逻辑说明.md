# POS门店已绑设备与devId设计逻辑说明

## 1. 背景

在会员储值方案并发充值测试中，`member_deposit_plan_ops/cardCharge` 曾出现如下错误：

```text
设备【12042c61c6a35f1253fe1de6f0035828】不存在
```

这类问题容易和商户后台“门店管理”里的“已绑设备”字段混淆。后台页面可以看到门店已经绑定了一个设备号，但充值接口仍然提示设备不存在。原因是：后台“已绑设备”和 `cardCharge` 请求里的 `devId` 不完全是同一个业务语义。

本文说明 POS 门店绑定设备、服务端设备、普通收银电脑设备、`devId=-1` 之间的区别。

## 2. 核心结论

后台“已绑设备”更接近于：

```text
门店绑定的 POS 服务端 / 主设备
```

它不是：

```text
这个门店下所有收银电脑的 devId 列表
```

`cardCharge` 请求里的 `devId` 表示：

```text
本次业务操作由哪个 POS 业务设备发起
```

本地 POS 服务端直接发起业务时，后端使用特殊值：

```text
devId = -1
```

普通 POS 客户端电脑发起业务时，应使用登录后 POS 后端返回并保存到前端的业务 `devId`，而不是直接复制后台页面里的“已绑设备”值。

## 3. 几种设备标识的区别

| 名称 | 示例 | 来源 | 主要用途 |
| --- | --- | --- | --- |
| 物理机器 UUID | `d8bc82872426af9accb678a0862db6e3` | Electron `window.api.device().uuid` 或 `.lmn_uuid.ini` | 标识当前电脑硬件或安装实例 |
| 后台“已绑设备” | `12042c61c6a35f1253fe1de6f0035828` | 商户后台门店管理页面 | 表示门店绑定的 POS 服务端 / 主设备 |
| POS 业务 `devId` | 登录返回值，或 `-1` | POS 登录接口返回后写入前端缓存 | 业务请求中标识本次操作设备 |
| `pos_dev.id` | 数据库 `pos_dev.id` | 本地 POS 数据表 | `cardCharge` 等业务接口校验设备存在性 |
| `pos_dev.dev_id` | 数据库 `pos_dev.dev_id` | 本地 POS 数据表 | 网络连接、socket、在线状态等场景 |
| `-1` | `-1` | 后端特殊约定 | 表示服务器设备，不查 `pos_dev` 表 |

关键点：

```text
cardCharge 校验的是请求 devId 是否能匹配当前 mid + sid 下的 pos_dev.id。
```

所以一个 UUID 即使出现在后台“已绑设备”列里，也不代表它一定能作为当前接口请求的 `devId` 通过校验。

## 4. 多台收银电脑时如何理解

一个门店可以有多台收银电脑，但后台“已绑设备”字段通常不表示“所有收银电脑”。

更合理的角色划分是：

```text
门店
  -> 绑定一个 POS 服务端 / 主设备
      -> 多台普通 POS 客户端电脑连接这个服务端
```

因此：

| 角色 | 作用 | 业务请求 devId |
| --- | --- | --- |
| POS 服务端 / 主机 | 跑本地 POS 后端、同步数据、处理本地业务接口 | 服务端场景通常用 `-1` |
| 普通 POS 客户端电脑 | 用户实际收银操作入口 | 登录成功后后端返回的业务 `devId` |
| 后台“已绑设备” | 门店绑定的主设备或服务端设备标识 | 不应直接当作所有业务请求的 `devId` |

如果其他电脑也要作为 POS 客户端使用，正常流程应是：

1. 这台电脑安装并启动 POS 客户端。
2. Electron 侧生成或读取当前电脑 UUID。
3. 登录时把设备信息传给 POS 后端。
4. 后端根据当前门店、设备、是否服务端等信息返回业务 `devId`。
5. 前端把登录返回的 `devId` 保存下来。
6. 后续业务请求自动带上这个 `devId`。

也就是说，其他电脑要绑定，不是手工把后台“已绑设备”复制到请求里，而是通过 POS 登录 / 注册 / 同步流程，让后端认可这台电脑，并返回可用于业务请求的 `devId`。

## 5. 代码证据

### 5.1 POS 前端请求会自动带 sid 和 devId

POS 前端请求拦截器会把当前缓存中的 `sid` 和 `devId` 注入到请求体：

```ts
config.data = { ...config.data, devId: UUIDUtils.getUUID(), sid: UUIDUtils.getSid() };
```

位置：

```text
nms4pos-ui/app/pos4desktop/src/requestErrorConfig.ts
```

这说明真实 POS 前端不是让用户在业务页面手动输入 `devId`，而是登录后由前端缓存自动携带。

### 5.2 登录成功后保存后端返回的 devId

登录成功后，如果后端返回 `devId`，前端保存到 `UUIDUtils`：

```ts
if (devId) {
  UUIDUtils.setUUID(devId);
}
```

位置：

```text
nms4pos-ui/app/pos4desktop/src/pages/Login/index.tsx
```

这说明业务请求使用的 `devId` 不是简单等于本机 UUID，而是以登录结果为准。

### 5.3 cardCharge 最终会校验 PosDev

`cardCharge` 最终把请求里的 `devId` 传入结账流程，并由订单工具校验设备：

```java
PosDev posDev = posDevServicePlus.getById(mid, sid, devId);
Assert.isTrue(Objects.nonNull(posDev), String.format("设备【%s】不存在", devId));
```

位置：

```text
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/util/OrderServiceUtil.java
```

### 5.4 -1 是服务器特殊设备

同一段逻辑里，`-1` 被特殊处理：

```java
if (ObjectUtil.equal(devId, "-1")) {
  return new PosDev().setId("-1").setLid(-1L).setName("服务器");
}
```

这意味着 `devId=-1` 不走 `pos_dev` 表查询，直接被当成服务器设备。

### 5.5 getById 查的是 pos_dev.id，不是 pos_dev.dev_id

设备查询逻辑按 `mid + sid + id` 查询：

```java
Chain.forQuery(mapper)
  .eq(PosDev::getMid, mid)
  .eq(PosDev::getSid, sid)
  .eq(PosDev::getId, id)
  .onlyOne();
```

位置：

```text
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/PosDevServicePlus.java
```

`pos_dev` 表里同时存在 `id` 和 `dev_id` 两个字段：

```java
@Column("id")
private String id;

@Column("dev_id")
private String devId;
```

位置：

```text
nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/PosDev.java
```

因此不能只看到一个字段叫“设备号”或“已绑设备”，就断定它一定是 `cardCharge` 使用的 `pos_dev.id`。

## 6. 为什么后台有已绑设备，接口还报设备不存在

假设后台页面显示：

```text
广州店 已绑设备 = 12042c61c6a35f1253fe1de6f0035828
```

测试请求传：

```json
{
  "sid": "1940287289892687874",
  "devId": "12042c61c6a35f1253fe1de6f0035828"
}
```

但当前 `cardCharge` 所连接的 POS 后端会查：

```sql
select *
from pos_dev
where mid = 当前商户
  and sid = 1940287289892687874
  and id = '12042c61c6a35f1253fe1de6f0035828'
```

如果当前本地 POS 后端库里没有这条记录，就会报：

```text
设备【12042c61c6a35f1253fe1de6f0035828】不存在
```

这不是 UUID 格式错误，而是当前本地 POS 后端不认可这个值是该门店下的 `pos_dev.id`。

## 7. 对真实并发充值测试的影响

当前 E2E 测试如果是直接调用本地 POS 服务端接口，而不是经过某台真实 POS 客户端登录态发起，推荐使用：

```env
POS_DEV_ID=-1
```

并发多门店配置中，也应优先使用：

```json
[
  { "sid": "1940287289892687874", "devId": "-1", "memberCardNo": "18923865943" },
  { "sid": "1942885905090105345", "devId": "-1", "memberCardNo": "18923865943" }
]
```

原因：

1. `-1` 是服务端设备特殊值。
2. 它不依赖本地 `pos_dev` 是否同步了某台客户端电脑。
3. 更符合“服务端直接压测接口”的场景。

如果测试目标是模拟真实 POS 客户端，则不能使用后台“已绑设备”列作为依据，而应拿真实客户端登录成功后返回并保存的 `devId`。

## 8. 排查建议

遇到“设备不存在”时，按以下顺序确认：

1. 当前请求是服务端直接调用，还是 POS 客户端登录后调用。
2. 如果是服务端直接调用，确认是否应该使用 `devId=-1`。
3. 如果是客户端调用，确认前端登录响应里的 `devId` 是什么。
4. 查询当前 POS 后端本地库的 `pos_dev` 表，确认是否存在：

```sql
select id, dev_id, lid, name, mid, sid
from pos_dev
where sid = 当前门店sid;
```

5. 区分 `id` 和 `dev_id`：
   - `cardCharge` 设备存在校验使用 `id`。
   - 网络连接、socket、在线状态可能使用 `dev_id`。

## 9. 一句话总结

```text
后台“已绑设备”表示门店绑定的 POS 服务端 / 主设备；
cardCharge.devId 表示本次业务请求的发起设备；
本地服务端直接调用应使用 -1；
普通收银电脑调用应使用登录后返回的 devId；
不要直接把后台“已绑设备”复制成 cardCharge 的 devId。
```
