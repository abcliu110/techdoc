# 小程序点菜下单会员字段来源与 cardId 判断链路

## 结论

小程序点菜下单时，会员信息不是在下单按钮点击时重新查询出来的，而是从前端 `userStore.currentUser` 读取。

`currentUser` 的来源链路是：

```text
后端登录/会员接口返回会员字段
  ↓
userStore.replaceState / userStore.setState 写入 MobX 状态
  ↓
同步写入本地缓存 currentUser
  ↓
页面启动或刷新时从缓存恢复 currentUser
  ↓
下单页读取 userStore.currentUser
  ↓
用 cardId || cardNo || cardIdAlias 组装下单请求 cardId
```

下单时并不是判断 `cardId` 和 `cardNo` 两个字段都存在，而是按优先级取第一个有值的卡号字段。

```ts
cardId: currentUserAny?.cardId || currentUserAny?.cardNo || currentUserAny?.cardIdAlias
```

优先级为：

```text
currentUser.cardId
  ↓ 没值
currentUser.cardNo
  ↓ 没值
currentUser.cardIdAlias
  ↓ 都没值
下单请求 cardId 为空/undefined
```

## 关键代码位置

### 1. 下单页读取 currentUser

文件：

```text
D:\mywork\taro-mall\src\pagePop\cart\index.tsx
```

关键逻辑：

```ts
const {currentUser} = userStore
```

下单时组装用户上下文：

```ts
const currentUserAny = currentUser as any
const orderUserContext = {
    cardLid: currentUser?.cardLid,
    cardId: currentUserAny?.cardId || currentUserAny?.cardNo || currentUserAny?.cardIdAlias,
    phone: currentUserAny?.phone || currentUser?.phoneNumber || custPhone,
    userName: currentUser?.nickName || currentUser?.name || custName,
    openId: currentUser?.openid,
}
```

随后 `crtOrder` 创建订单时将 `orderUserContext` 展开到请求体中。

### 2. 预选桌台下单入口也使用同样逻辑

文件：

```text
D:\mywork\taro-mall\src\pagePop\cart\components\SelectTablePopup\index.tsx
```

关键逻辑：

```ts
const currentUserAny = currentUser as any
const { success, errorMessage, data={} } = await crtOrder({
  sid: bill?.sid,
  tblId: curTbl?.id,
  preOrder: true,
  cardLid: currentUser?.cardLid,
  cardId: currentUserAny?.cardId || currentUserAny?.cardNo || currentUserAny?.cardIdAlias,
  phone: currentUserAny?.phone || currentUser?.phoneNumber,
  userName: currentUser?.nickName || currentUser?.name,
  openId: currentUser?.openid,
})
```

### 3. currentUser 的本地读取与写入

文件：

```text
D:\mywork\taro-mall\src\common\store\user.ts
```

缓存 key：

```ts
const KEY_IN_STORAGE = 'currentUser'
```

初始化读取：

```ts
@observable currentUser = isH5 ? Tips.getSessionStorage(KEY_IN_STORAGE) : Taro.getStorageSync(KEY_IN_STORAGE)
```

增量合并写入：

```ts
@action setState(user: CurrentUser = {}) {
  this.currentUser = { ...this.currentUser, ...user }
  if(isH5){
    Tips.setSessionStorage(KEY_IN_STORAGE, this.currentUser)
    return
  }
  Taro.setStorageSync(KEY_IN_STORAGE, this.currentUser)
}
```

整体替换写入：

```ts
@action replaceState(user: CurrentUser = {}) {
  this.currentUser = { ...user }
  if(isH5){
    Tips.setSessionStorage(KEY_IN_STORAGE, this.currentUser)
    return
  }
  Taro.setStorageSync(KEY_IN_STORAGE, this.currentUser)
}
```

## currentUser 的主要写入来源

文件：

```text
D:\mywork\taro-mall\src\common\service\api\auth.ts
```

### 1. 小程序微信登录

接口：

```text
/scrm/user/wxMaLogin
```

成功后：

```ts
replaceState(res.data || {})
```

含义：登录返回的用户信息会整体替换到 `currentUser`。

### 2. H5 微信登录

接口同样是：

```text
/scrm/user/wxMaLogin
```

成功后：

```ts
replaceState(res.data || {})
```

含义：H5 登录返回的用户信息也会整体替换到 `currentUser`。

### 3. 获取手机号

接口：

```text
/scrm/user/wxMaGetPhone
```

调用方会在成功后执行：

```ts
userStore.setState(res.data || {})
```

含义：手机号接口返回的数据会合并到 `currentUser`。

### 4. 获取会员信息

接口：

```text
/scrm/crm_card_op/customer/get_member_info
```

封装位置：

```text
D:\mywork\taro-mall\src\common\service\api\auth.ts
```

调用方示例：

```text
D:\mywork\taro-mall\src\common\func\useMemberInfo.ts
D:\mywork\taro-mall\src\pagesIndex\pageIndex\index.tsx
D:\mywork\taro-mall\src\pages\Order\index.tsx
```

成功后通常执行：

```ts
userStore.setState(data || {})
```

或：

```ts
setState({...data})
```

含义：会员资料接口返回的会员字段会合并到 `currentUser`。

## 文本流程图

```text
用户进入小程序/点菜页面
  ↓
触发登录或会员信息刷新
  ↓
调用后端接口
  ├─ /scrm/user/wxMaLogin
  ├─ /scrm/user/wxMaGetPhone
  └─ /scrm/crm_card_op/customer/get_member_info
  ↓
后端返回用户/会员字段
  ↓
前端写入 userStore.currentUser
  ├─ replaceState：整体替换 currentUser
  └─ setState：合并更新 currentUser
  ↓
同步写入本地缓存 key=currentUser
  ├─ H5：sessionStorage
  └─ 小程序：Taro storage
  ↓
用户点击下单
  ↓
下单页读取 userStore.currentUser
  ↓
组装 orderUserContext
  ↓
判断会员卡号字段
  ↓
currentUser.cardId 是否有值？
  ├─ 是：请求 cardId = currentUser.cardId
  └─ 否
       ↓
       currentUser.cardNo 是否有值？
       ├─ 是：请求 cardId = currentUser.cardNo
       └─ 否
            ↓
            currentUser.cardIdAlias 是否有值？
            ├─ 是：请求 cardId = currentUser.cardIdAlias
            └─ 否：请求 cardId 为空/undefined
  ↓
同时传递 cardLid = currentUser.cardLid
  ↓
调用 crtOrder 创建订单
```

## 5 Why 分析

### 问题

小程序点菜下单时，`currentUser` 里的会员信息从哪里来？

### Why 1：为什么下单时能拿到 currentUser？

因为下单页直接从 `userStore` 读取：

```ts
const {currentUser} = userStore
```

证据：

```text
D:\mywork\taro-mall\src\pagePop\cart\index.tsx
```

### Why 2：为什么 userStore 里有 currentUser？

因为 `userStore` 初始化时会从本地缓存读取 `currentUser`。

```ts
@observable currentUser = isH5 ? Tips.getSessionStorage(KEY_IN_STORAGE) : Taro.getStorageSync(KEY_IN_STORAGE)
```

证据：

```text
D:\mywork\taro-mall\src\common\store\user.ts
```

### Why 3：为什么本地缓存里会有 currentUser？

因为登录、获取手机号、获取会员信息等流程成功后，会调用 `replaceState` 或 `setState`，并同步写入缓存。

```ts
Tips.setSessionStorage(KEY_IN_STORAGE, this.currentUser)
Taro.setStorageSync(KEY_IN_STORAGE, this.currentUser)
```

证据：

```text
D:\mywork\taro-mall\src\common\store\user.ts
```

### Why 4：哪些接口会把会员信息写进 currentUser？

主要来源是：

```text
/scrm/user/wxMaLogin
/scrm/user/wxMaGetPhone
/scrm/crm_card_op/customer/get_member_info
```

证据：

```text
D:\mywork\taro-mall\src\common\service\api\auth.ts
D:\mywork\taro-mall\src\common\func\useMemberInfo.ts
D:\mywork\taro-mall\src\pagesIndex\pageIndex\index.tsx
D:\mywork\taro-mall\src\pages\Order\index.tsx
```

### Why 5：cardId/cardNo/cardLid 最终来自哪里？

前端不生成 `cardId/cardNo/cardLid` 这些会员字段。它们来自后端接口返回值，写入 `currentUser` 后，下单页再从 `currentUser` 读取。

下单时：

```ts
cardLid: currentUser?.cardLid,
cardId: currentUserAny?.cardId || currentUserAny?.cardNo || currentUserAny?.cardIdAlias,
```

所以：

```text
cardLid：直接取 currentUser.cardLid
cardId：按 currentUser.cardId → currentUser.cardNo → currentUser.cardIdAlias 取第一个有值字段
```

## 字段含义与边界

### cardLid

`cardLid` 在前端常作为是否会员的判断依据。

示例：

```ts
if (!currentUser.cardLid) {
    return
}
```

常见用途：

```text
是否已经注册会员
是否可以刷新会员资料
是否展示会员相关入口
是否允许使用会员储值/会员权益
```

### cardId/cardNo/cardIdAlias

下单时真正传给后端请求字段的是 `cardId`，但这个字段值可能来自三个候选字段之一：

```text
1. currentUser.cardId
2. currentUser.cardNo
3. currentUser.cardIdAlias
```

前端代码没有要求三个字段同时存在，也没有要求 `cardId` 和 `cardNo` 同时存在。

## 已确认事实与未确认边界

### 已确认

1. 下单页从 `userStore.currentUser` 读取会员字段。
2. `userStore.currentUser` 初始化时从本地缓存 `currentUser` 读取。
3. `replaceState` 会整体替换 `currentUser` 并写入缓存。
4. `setState` 会合并更新 `currentUser` 并写入缓存。
5. 下单请求中的 `cardId` 使用 `cardId || cardNo || cardIdAlias` 的优先级。
6. 下单请求中的 `cardLid` 直接来自 `currentUser.cardLid`。

### 未在本文完全展开

1. 后端 `/scrm/user/wxMaLogin` 内部如何查询 CRM 卡并填充 `cardId/cardLid`。
2. 后端 `/scrm/crm_card_op/customer/get_member_info` 内部如何组装会员 VO。
3. 订单创建接口收到 `cardId/cardLid` 后，在订单表、POS 同步表中的完整落字段链路。

这些问题需要继续沿 `nms4cloud` 后端 CRM、order、POS 同步链路追踪。

## 一句话总结

小程序点菜下单时，会员字段先由登录/会员接口写入 `userStore.currentUser` 和本地缓存；下单时不重新查会员，只读取当前 `currentUser`，并用 `cardId || cardNo || cardIdAlias` 选出一个卡号传给 `crtOrder`。
