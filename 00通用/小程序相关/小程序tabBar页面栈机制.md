# 小程序 tabBar 与页面栈机制

本文说明微信小程序中 tabBar 页面、普通页面、页面栈和常见路由 API 的行为差异，重点解释 `switchTab`、`navigateTo`、`redirectTo`、`reLaunch` 对页面栈的影响。

## 1. tabBar 页面是什么

`tabBar` 页面是小程序的一级入口页面，通常对应首页、分类、购物车、我的等主导航页面。

示例：

```json
{
  "pages": [
    "pages/home/index",
    "pages/category/index",
    "pages/cart/index",
    "pages/user/index",
    "pages/detail/index"
  ],
  "tabBar": {
    "list": [
      {
        "pagePath": "pages/home/index",
        "text": "首页"
      },
      {
        "pagePath": "pages/category/index",
        "text": "分类"
      },
      {
        "pagePath": "pages/cart/index",
        "text": "购物车"
      },
      {
        "pagePath": "pages/user/index",
        "text": "我的"
      }
    ]
  }
}
```

上面的配置中：

- `pages/home/index` 是 tabBar 页面。
- `pages/category/index` 是 tabBar 页面。
- `pages/cart/index` 是 tabBar 页面。
- `pages/user/index` 是 tabBar 页面。
- `pages/detail/index` 是普通页面。

可以把页面分成两类：

```text
tabBar 页面 = 一级页面
普通页面 = 从一级页面继续打开的业务页面
```

例如：

```text
首页 tab -> 商品详情 -> 规格选择 -> 提交订单
```

其中：

- `首页 tab` 是 tabBar 页面。
- `商品详情`、`规格选择`、`提交订单` 是普通页面。

## 2. 页面栈是什么

小程序框架会维护一个页面栈。页面栈可以理解成一个数组，数组中的每一项都是一个页面实例。

例如当前访问链路是：

```text
首页 -> 商品详情 -> 提交订单
```

页面栈可以理解为：

```js
[
  首页,
  商品详情页,
  提交订单页
]
```

页面栈的特点：

- 第一个页面通常是入口页。
- 最后一个页面是当前正在展示的页面。
- `navigateTo` 会新增页面，也就是入栈。
- `navigateBack` 会关闭页面，也就是出栈。
- `redirectTo` 会替换当前栈顶页面。
- `switchTab` 会切换到 tabBar 页面，并关闭所有非 tabBar 页面。
- `reLaunch` 会清空整个页面栈，然后重新打开指定页面。

可以通过下面的 API 查看当前页面栈：

```js
const pages = getCurrentPages()
const currentPage = pages[pages.length - 1]
```

注意：`getCurrentPages()` 主要用于读取当前页面栈信息，不应该直接修改返回的页面数组或页面实例，否则容易造成路由状态和页面状态不一致。

## 3. navigateTo：普通页面入栈

`wx.navigateTo` 用于打开普通页面。

```js
wx.navigateTo({
  url: '/pages/detail/index?id=100'
})
```

假设跳转前页面栈是：

```text
[首页]
```

跳转后页面栈是：

```text
[首页, 商品详情]
```

`navigateTo` 的特点：

- 保留当前页面。
- 新页面进入页面栈顶部。
- 用户可以通过返回回到上一个页面。
- 可以在 `url` 中携带 query 参数。
- 不能跳转到 tabBar 页面。

错误示例：

```js
wx.navigateTo({
  url: '/pages/cart/index'
})
```

如果 `pages/cart/index` 是 tabBar 页面，上面的写法不正确。跳转 tabBar 页面应该使用 `wx.switchTab`。

## 4. navigateBack：页面出栈

`wx.navigateBack` 用于关闭当前页面，返回上一层或多层页面。

```js
wx.navigateBack()
```

假设当前页面栈是：

```text
[首页, 商品详情, 提交订单]
```

执行后变成：

```text
[首页, 商品详情]
```

也可以指定返回多级：

```js
wx.navigateBack({
  delta: 2
})
```

页面栈变化：

```text
[首页, 商品详情, 提交订单]
=> [首页]
```

`navigateBack` 只能返回页面栈中已经存在的页面，不能打开新页面。

## 5. redirectTo：替换当前页面

`wx.redirectTo` 用于关闭当前页面，然后打开一个普通页面。

```js
wx.redirectTo({
  url: '/pages/pay-result/index?orderId=123'
})
```

假设跳转前页面栈是：

```text
[首页, 提交订单]
```

跳转后页面栈是：

```text
[首页, 支付结果]
```

它不是在页面栈上新增页面，而是替换当前栈顶页面。

适合场景：

- 提交订单页跳转到支付结果页。
- 表单提交页跳转到成功页。
- 登录中间页跳转到后续页面。

这样做的好处是，用户点击返回时不会回到已经提交过的页面。

限制：

- `redirectTo` 不能跳转到 tabBar 页面。
- 如果目标是 tabBar 页面，应使用 `switchTab` 或 `reLaunch`。

## 6. switchTab：切换 tabBar 页面

`wx.switchTab` 专门用于跳转 tabBar 页面。

```js
wx.switchTab({
  url: '/pages/user/index'
})
```

`switchTab` 的特点：

- 只能跳转到 `app.json` 中 `tabBar.list` 配置过的页面。
- 不能跳转到普通页面。
- `url` 不能携带 query 参数。
- 会关闭所有非 tabBar 页面。

例如当前页面栈是：

```text
[首页, 商品详情, 提交订单]
```

执行：

```js
wx.switchTab({
  url: '/pages/user/index'
})
```

页面栈会变成：

```text
[我的]
```

也就是说，`商品详情`、`提交订单` 等普通页面会被关闭。

这也是很多问题的来源：

```text
从详情页 switchTab 到购物车后，再点返回，回不到详情页。
```

这是正常行为，因为 `switchTab` 会关闭非 tabBar 页面。

## 7. reLaunch：清空整个页面栈

`wx.reLaunch` 用于关闭所有页面，然后打开指定页面。

```js
wx.reLaunch({
  url: '/pages/login/index'
})
```

它的核心行为是：

```text
清空整个页面栈 -> 打开目标页面
```

这里的“整个页面栈”包括栈底的 tabBar 页面。

例如当前页面栈是：

```text
[首页 tab, 商品详情页, 确认订单页]
```

执行：

```js
wx.reLaunch({
  url: '/pages/login/index'
})
```

页面栈变成：

```text
[登录页]
```

如果执行：

```js
wx.reLaunch({
  url: '/pages/home/index'
})
```

页面栈变成：

```text
[首页 tab]
```

所以，`reLaunch` 不是只清空非 tabBar 页面，而是清空所有页面，包括原来的 tabBar 页面。

`reLaunch` 和 `switchTab` 的区别：

```text
switchTab:
[首页 tab, 商品详情页, 确认订单页]
=> [目标 tab]
关闭非 tabBar 页面，切换到目标 tabBar 页面。

reLaunch:
[首页 tab, 商品详情页, 确认订单页]
=> [目标页面]
关闭所有页面，包括原来的 tabBar 页面，然后打开目标页面。
```

`reLaunch` 可以打开普通页面，也可以打开 tabBar 页面；`switchTab` 只能打开 tabBar 页面。

适合使用 `reLaunch` 的场景：

- 退出登录后回到登录页。
- 登录态失效后重置页面栈。
- 切换门店、切换租户后重置业务上下文。
- 完成某个流程后，不希望用户再返回旧流程页面。
- 小程序启动后根据身份重新落到某个明确页面。

不适合滥用 `reLaunch` 的场景：

- 普通页面跳转。
- 普通 tab 切换。
- 只是想回到上一页。
- 只是想避免某个页面刷新问题。

滥用 `reLaunch` 会让用户丢失返回路径，也可能掩盖页面状态设计问题。

## 8. tabBar 页面的生命周期特点

tabBar 页面通常不会因为切换 tab 而销毁。

例如访问流程：

```text
首页 -> 我的 -> 首页
```

第一次进入首页：

```text
首页 onLoad
首页 onShow
```

切换到我的：

```text
首页 onHide
我的 onLoad
我的 onShow
```

再切回首页：

```text
我的 onHide
首页 onShow
```

一般不会再次触发首页的 `onLoad`。

因此：

- `onLoad` 适合做一次性初始化。
- `onShow` 适合做每次进入页面都要刷新的逻辑。

例如购物车 tab：

```js
Page({
  onLoad() {
    // 初始化页面结构、读取静态配置。
  },

  onShow() {
    // 每次切回购物车，都重新拉取购物车数量、价格和选中状态。
    this.loadCart()
  }
})
```

如果把购物车刷新逻辑只写在 `onLoad`，用户从商品详情加入购物车后切回购物车 tab，可能看不到最新数据。

## 9. tabBar 页面不能通过 switchTab 直接带参数

错误示例：

```js
wx.switchTab({
  url: '/pages/cart/index?skuId=100'
})
```

`switchTab` 的 `url` 不支持 query 参数。

常见传参方式有三种。

### 9.1 使用全局状态

跳转前：

```js
const app = getApp()

app.globalData.cartSourceSkuId = 100

wx.switchTab({
  url: '/pages/cart/index'
})
```

购物车页：

```js
const app = getApp()

Page({
  onShow() {
    const skuId = app.globalData.cartSourceSkuId

    if (skuId) {
      this.handleSku(skuId)
      app.globalData.cartSourceSkuId = null
    }
  }
})
```

适合短期、临时、进程内状态。

### 9.2 使用本地缓存

跳转前：

```js
wx.setStorageSync('cartSourceSkuId', 100)

wx.switchTab({
  url: '/pages/cart/index'
})
```

购物车页：

```js
Page({
  onShow() {
    const skuId = wx.getStorageSync('cartSourceSkuId')

    if (skuId) {
      wx.removeStorageSync('cartSourceSkuId')
      this.handleSku(skuId)
    }
  }
})
```

适合需要跨页面、跨重启保留的轻量状态。

### 9.3 使用状态管理或事件机制

在 Taro、uni-app 或复杂原生项目中，可以使用状态管理或事件机制传递状态。

适合场景：

- 多个页面需要共享同一份状态。
- 状态需要被多个组件订阅。
- 页面切换和业务状态变化比较复杂。

## 10. 典型页面栈变化示例

假设页面包括：

```text
首页 tab：首页
分类 tab：分类
购物车 tab：购物车
我的 tab：我的

普通页：商品详情、确认订单、支付结果
```

### 10.1 从首页进入商品详情

```js
wx.navigateTo({
  url: '/pages/detail/index?id=1'
})
```

页面栈：

```text
[首页]
=> [首页, 商品详情]
```

### 10.2 从商品详情进入确认订单

```js
wx.navigateTo({
  url: '/pages/order-confirm/index'
})
```

页面栈：

```text
[首页, 商品详情]
=> [首页, 商品详情, 确认订单]
```

### 10.3 确认订单提交成功后进入支付结果

```js
wx.redirectTo({
  url: '/pages/pay-result/index?orderId=123'
})
```

页面栈：

```text
[首页, 商品详情, 确认订单]
=> [首页, 商品详情, 支付结果]
```

这里用 `redirectTo` 的原因是：不希望用户从支付结果页返回确认订单页，避免重复提交。

### 10.4 支付结果页回首页 tab

```js
wx.switchTab({
  url: '/pages/home/index'
})
```

页面栈：

```text
[首页, 商品详情, 支付结果]
=> [首页]
```

商品详情和支付结果都会被关闭。

### 10.5 退出登录回登录页

```js
wx.reLaunch({
  url: '/pages/login/index'
})
```

页面栈：

```text
[首页 tab, 商品详情页, 确认订单页]
=> [登录页]
```

原来的 tabBar 页面和普通页面都会被关闭。

## 11. 常见错误和正确做法

### 11.1 用 navigateTo 跳转 tabBar 页面

错误：

```js
wx.navigateTo({
  url: '/pages/cart/index'
})
```

如果购物车是 tabBar 页面，应该改成：

```js
wx.switchTab({
  url: '/pages/cart/index'
})
```

### 11.2 用 switchTab 跳转普通页面

错误：

```js
wx.switchTab({
  url: '/pages/detail/index'
})
```

普通页面应该使用：

```js
wx.navigateTo({
  url: '/pages/detail/index'
})
```

或者根据业务需要使用：

```js
wx.redirectTo({
  url: '/pages/detail/index'
})
```

### 11.3 用 switchTab 携带 query 参数

错误：

```js
wx.switchTab({
  url: '/pages/cart/index?id=1'
})
```

正确做法是使用全局状态、缓存或状态管理。

### 11.4 把 tabBar 页面刷新逻辑只写在 onLoad

问题写法：

```js
Page({
  onLoad() {
    this.loadCart()
  }
})
```

更稳妥写法：

```js
Page({
  onShow() {
    this.loadCart()
  }
})
```

因为 tabBar 页面切换回来时通常只触发 `onShow`，不会再次触发 `onLoad`。

### 11.5 以为 switchTab 后还能返回原普通页面

错误理解：

```text
详情页 switchTab 到购物车后，点击返回应该回到详情页。
```

实际行为：

```text
switchTab 会关闭所有非 tabBar 页面，因此不能返回详情页。
```

如果业务要求用户处理完购物车后回到原详情页，需要单独保存来源信息，然后通过业务按钮重新打开详情页，而不是依赖页面栈返回。

### 11.6 滥用 reLaunch

`reLaunch` 会清空所有页面。它适合重置流程，不适合普通跳转。

不建议为了刷新页面而使用 `reLaunch`。刷新页面应该优先处理页面生命周期、状态同步和接口重新拉取。

## 12. 自动化测试中的 tap 与 trigger

微信小程序自动化测试中，经常会同时遇到 `tap` 和 `trigger`。有些项目会把 `trigger` 封装成 `strigger`，用于稳定触发某个选择器节点上的事件。

可以先这样区分：

```text
tap：模拟用户点击某个节点。
trigger / strigger：直接触发某个节点上的指定事件，并可手动构造事件 detail。
```

也就是说，`tap` 更接近用户行为，`trigger` 更接近直接让绑定事件处理函数执行。

例如按钮：

```xml
<button bindtap="submitOrder">提交订单</button>
```

测试中通常应该优先使用：

```js
const button = await page.$('.submit-button')
await button.tap()
```

因为这里要验证的是：

```text
按钮是否存在。
按钮是否能被点击。
点击后是否执行提交逻辑。
点击后页面状态或路由是否正确变化。
```

但如果业务监听的不是 `tap`，而是 `change`、`input`、`confirm`、`select` 等事件，单纯 `tap` 往往无法触发目标业务逻辑。

### 12.1 为什么有些场景必须用 trigger

典型例子是 `picker`：

```xml
<picker bindchange="onShopChange" range="{{shops}}">
  <view>选择门店</view>
</picker>
```

业务逻辑：

```js
Page({
  onShopChange(e) {
    const index = e.detail.value
    this.setData({
      currentShopIndex: index
    })
  }
})
```

如果自动化测试只写：

```js
await picker.tap()
```

它只是点了一下 `picker`。真实用户点击后，还会经历：

```text
打开原生选择器 -> 选择某一项 -> 产生 change 事件 -> 带回 e.detail.value
```

自动化工具对微信原生弹层、日期选择器、地区选择器、门店选择器等场景，不一定能稳定完成完整 UI 操作链路。

这时更稳定的做法是直接触发 `change`：

```js
await picker.trigger('change', {
  value: 1
})
```

如果项目封装了 `strigger`，可能类似：

```js
await strigger('.shop-picker', 'change', {
  value: 1
})
```

这类测试的目标不是验证“用户能不能点开 picker”，而是验证：

```text
当 picker 产生 change 事件，并返回指定 e.detail.value 时，业务逻辑是否正确。
```

因此必须用 `trigger` 或封装后的 `strigger`。

### 12.2 input、switch、slider 等值变化组件

输入框业务一般监听 `input`：

```xml
<input bindinput="onKeywordInput" />
```

```js
Page({
  onKeywordInput(e) {
    this.setData({
      keyword: e.detail.value
    })
  }
})
```

点击输入框：

```js
await input.tap()
```

通常只表示聚焦，不等于输入了值，也不一定产生业务需要的 `e.detail.value`。

更合适的方式是使用自动化工具提供的输入方法，或者直接触发 `input`：

```js
await input.trigger('input', {
  value: '奶茶'
})
```

`switch`、`slider`、`radio-group`、`checkbox-group` 也是类似逻辑：

```xml
<switch bindchange="onEnableChange" />
```

```js
await switchNode.trigger('change', {
  value: true
})
```

这类组件的业务入口不是点击本身，而是值变化事件。

### 12.3 自定义组件向父页面抛事件

自定义组件内部经常通过 `triggerEvent` 向父页面抛事件。

组件内部：

```js
Component({
  methods: {
    confirmSku() {
      this.triggerEvent('confirm', {
        skuId: 1001,
        count: 2
      })
    }
  }
})
```

父页面：

```xml
<sku-popup bind:confirm="onSkuConfirm" />
```

父页面逻辑：

```js
Page({
  onSkuConfirm(e) {
    const { skuId, count } = e.detail
    this.addCart(skuId, count)
  }
})
```

如果测试目标是验证父页面收到规格确认事件后，购物车状态是否正确，可以直接：

```js
const popup = await page.$('sku-popup')

await popup.trigger('confirm', {
  skuId: 1001,
  count: 2
})
```

这里用 `tap` 不一定合适，因为父页面监听的是 `confirm`，不是 `tap`。

完整 UI 链路测试可以使用真实点击：

```text
打开规格弹窗 -> 选择规格 -> 点击确认 -> 父页面收到 confirm
```

事件处理逻辑测试可以直接使用：

```text
trigger('confirm', detail)
```

### 12.4 图片包在 button 内时，为什么人工点击可以，自动化不行

小程序里常见这样的结构：

```xml
<button class="delete-btn" bindtap="onDelete">
  <image class="delete-icon" src="/assets/delete.png" />
</button>
```

视觉上用户看到的是图片，实际绑定事件的是外层 `button`。

人工点击时，流程更接近：

```text
手指点在图片位置
-> 这个屏幕坐标落在 button 的可点击区域内
-> 小程序运行时命中外层 button
-> 执行 bindtap="onDelete"
```

自动化测试如果写成：

```js
const icon = await page.$('.delete-icon')
await icon.tap()
```

它的语义更接近：

```text
找到 image 节点
-> 对 image 节点执行 tap
```

问题是：

```text
image 自己没有 bindtap，真正的业务事件绑定在外层 button 上。
```

因此会出现：

```text
人工点图片能触发删除。
自动化点 image 不一定触发删除。
```

根本原因是：

```text
人工点击的是屏幕坐标。
自动化点击的是被定位到的节点。
```

屏幕坐标落在 `button` 可点击区域内，就能触发 `button`；但自动化选择器如果选中的是 `image`，事件可能只发给 `image` 节点，未必完整复刻真实触摸系统的命中、冒泡和组件默认行为。

正确做法是优先定位真正绑定事件的节点：

```js
const button = await page.$('.delete-btn')
await button.tap()
```

如果真实点击链路在自动化环境中仍不稳定，再对绑定事件的节点使用 `trigger`：

```js
const button = await page.$('.delete-btn')
await button.trigger('tap')
```

或使用项目封装：

```js
await strigger('.delete-btn', 'tap')
```

不要优先对内部展示图片执行：

```js
await page.$('.delete-icon').then((el) => el.tap())
```

除非事件确实绑定在 `image` 节点上。

### 12.5 button 是特殊组件

`button` 在小程序中不是普通 `view`。它可能带有：

```text
open-type
form-type
disabled
hover-class
授权能力
表单提交能力
默认样式和点击区域
```

例如：

```xml
<button open-type="getPhoneNumber" bindgetphonenumber="onGetPhone">
  <image src="/assets/phone.png" />
</button>
```

如果测试代码点的是内部图片：

```js
await image.tap()
```

这不等价于真实用户点击了 `open-type="getPhoneNumber"` 的 `button`。

这种情况下应该根据测试目标选择：

```js
await button.tap()
```

或者直接触发授权回调事件：

```js
await button.trigger('getphonenumber', {
  encryptedData: 'mock-encrypted-data',
  iv: 'mock-iv'
})
```

这里要清楚区分测试目标：

```text
测试真实授权按钮是否可点：用 tap。
测试拿到授权数据后的业务逻辑：用 trigger('getphonenumber', detail)。
```

### 12.6 自动化 tap 不等于完整手指触摸链路

真实用户点击通常会经历：

```text
touchstart -> touchend -> tap -> 事件冒泡 -> 组件默认行为
```

自动化的 `tap()` 通常更接近“让某个元素发生点击”，不一定完整复刻真实触摸的所有细节。

在下面这些场景中差异更明显：

```text
image 包在 button 内。
自定义组件内部多层嵌套。
cover-view / cover-image。
scroll-view 内部元素。
movable-area 内部元素。
页面上有遮罩层。
父子节点同时绑定 bindtap / catchtap。
元素使用 absolute、transform、透明区域或复杂定位。
```

因此，人工点击能成功，只能说明屏幕上的某个坐标可以触发业务；自动化点击失败，往往说明测试选错了节点，或者自动化点击没有完整模拟真实触摸命中链路。

### 12.7 bindtap 与 catchtap 对自动化的影响

例如：

```xml
<button class="outer" bindtap="onOuter">
  <image class="inner" catchtap="onInner" />
</button>
```

这里：

```text
bindtap：允许事件冒泡。
catchtap：会阻止事件冒泡。
```

如果自动化定位 `.inner` 并点击：

```js
await page.$('.inner').then((el) => el.tap())
```

事件可能被内部 `catchtap` 截断，外层 `button` 的 `onOuter` 不会执行。

如果测试目标是外层逻辑，应直接操作外层绑定事件的节点：

```js
await page.$('.outer').then((el) => el.tap())
```

或者：

```js
await page.$('.outer').then((el) => el.trigger('tap'))
```

### 12.8 自动化测试选择 tap 还是 trigger

优先用 `tap` 的场景：

```text
测试真实用户点击链路。
测试按钮、卡片、菜单是否可以点击。
测试点击后是否跳转、弹窗、提交或状态变化。
测试元素是否真的可见、可点、没有被遮罩挡住。
```

必须或更适合用 `trigger` / `strigger` 的场景：

```text
业务监听的不是 tap，而是 change、input、confirm、blur、focus、select、close、submit 等事件。
业务方法依赖 e.detail.value、e.detail.id、e.detail.selected 等数据。
需要测试自定义组件向父页面抛出的事件。
原生组件弹层无法稳定自动化操作，例如 picker、日期选择、地区选择。
内部真实点击链路太深，当前测试只想验证事件处理逻辑。
元素被组件封装，外层可拿到但内部真实按钮不好稳定定位。
需要构造边界数据，例如空值、异常 code、特殊枚举值。
```

最终判断规则：

```text
如果要验证真实用户行为链路，优先 tap。
如果要验证某个事件收到指定 detail 后的业务逻辑，优先 trigger / strigger。
如果页面结构是图片包在 button 内，优先操作绑定事件的外层 button，不要只点内部 image。
```

### 12.9 自动化点击失败时，先分清“视觉目标”和“事件目标”

人工测试时，人看到的是视觉目标：

```text
删除图标。
加号图标。
购物车图标。
确认按钮的文字。
图片区域。
```

自动化测试时，脚本操作的是节点目标：

```text
.delete-icon
.delete-btn
button
image
custom-component
```

这两个目标可能不是同一个节点。

例如：

```xml
<button class="cart-btn" bindtap="onAddCart">
  <image class="cart-icon" src="/assets/cart.png" />
  <text>加入购物车</text>
</button>
```

人的理解：

```text
点击购物车图标就是点击加入购物车按钮。
```

自动化脚本的真实行为可能是：

```js
await page.$('.cart-icon').then((el) => el.tap())
```

也就是：

```text
只点击 image 节点。
```

如果 `image` 没有绑定事件，或者自动化点击没有正确冒泡到外层 `button`，业务逻辑就不会执行。

因此写自动化脚本前，应先回答三个问题：

```text
1. 用户视觉上点的是哪里？
2. WXML 中真正绑定事件的是哪个节点？
3. 自动化选择器当前定位到的是哪个节点？
```

只有第 2 点和第 3 点一致，测试才相对稳定。

更推荐的写法：

```js
const cartButton = await page.$('.cart-btn')
await cartButton.tap()
```

不推荐优先写：

```js
const cartIcon = await page.$('.cart-icon')
await cartIcon.tap()
```

除非 `bindtap` 明确写在 `.cart-icon` 上。

### 12.10 判断事件绑定节点的方法

排查自动化点击问题时，不要只看截图，要回到 WXML 和组件源码中查事件绑定。

常见绑定方式包括：

```xml
<view bindtap="onTap" />
<view catchtap="onTap" />
<button bindtap="onSubmit" />
<picker bindchange="onChange" />
<input bindinput="onInput" />
<switch bindchange="onSwitchChange" />
<custom-component bind:confirm="onConfirm" />
```

判断规则：

```text
bindtap / catchtap 在哪个节点上，tap 或 trigger('tap') 就优先打哪个节点。
bindchange 在哪个节点上，trigger('change', detail) 就优先打哪个节点。
bindinput 在哪个节点上，trigger('input', detail) 或输入方法就优先打哪个节点。
bind:confirm / bindconfirm 在哪个组件上，trigger('confirm', detail) 就优先打哪个组件。
```

例如：

```xml
<view class="goods-card">
  <image class="goods-img" src="{{goods.image}}" />
  <button class="add-btn" bindtap="onAddCart">
    <image class="add-icon" src="/assets/add.png" />
  </button>
</view>
```

事件绑定节点是：

```text
.add-btn
```

不是：

```text
.goods-card
.goods-img
.add-icon
```

测试应写：

```js
const addButton = await page.$('.add-btn')
await addButton.tap()
```

如果自动化真实点击不稳定，可以写：

```js
await addButton.trigger('tap')
```

但仍然应该打 `.add-btn`，而不是打 `.add-icon`。

### 12.11 strigger 通常解决的不是“点击”，而是“事件入口”

很多项目封装 `strigger`，不是为了替代所有 `tap`，而是为了让测试能够稳定地调用业务事件入口。

假设封装类似：

```js
async function strigger(page, selector, eventName, detail = {}) {
  const element = await page.$(selector)

  if (!element) {
    throw new Error(`element not found: ${selector}`)
  }

  await element.trigger(eventName, detail)
}
```

使用方式：

```js
await strigger(page, '.shop-picker', 'change', {
  value: 1
})
```

它表达的是：

```text
找到 .shop-picker 节点。
直接触发它的 change 事件。
把 { value: 1 } 放进事件 detail。
```

它不表达：

```text
真实用户点开 picker。
真实用户在弹层里选择第二项。
真实弹层渲染、滚动和确认按钮都正常。
```

因此，`strigger` 更像“事件级测试工具”，不是“用户行为级测试工具”。

使用 `strigger` 的优势：

```text
稳定。
速度快。
可以构造 e.detail。
可以绕过原生弹层或复杂 UI。
适合验证业务事件处理逻辑。
```

使用 `strigger` 的风险：

```text
绕过真实点击。
无法证明元素真的可见。
无法证明用户真的点得到。
无法证明 disabled、遮罩、层级、样式点击区域正确。
无法证明原生组件弹层真实可操作。
```

所以不要把所有测试都改成 `strigger`。更合理的分层是：

```text
少量主流程测试：用 tap 验证真实用户链路。
大量边界和业务状态测试：用 trigger / strigger 验证事件处理逻辑。
```

### 12.12 不同组件的自动化处理建议

下面是常见组件的选择建议。

| 组件或场景 | 常见业务事件 | 优先方式 | 说明 |
|---|---|---|---|
| 普通按钮 | `tap` | `tap()` | 验证真实点击链路。 |
| 图片包在按钮里 | 外层 `button` 的 `tap` | 对外层按钮 `tap()` | 不要优先点内部 `image`。 |
| `picker` | `change` | `trigger('change', { value })` | 原生选择器自动化不稳定时直接触发 change。 |
| `input` | `input` / `confirm` / `blur` | 输入方法或 `trigger` | 点击只代表聚焦，不代表输入。 |
| `switch` | `change` | `trigger('change', { value: true })` | 业务通常依赖 `e.detail.value`。 |
| `slider` | `changing` / `change` | `trigger('change', { value })` | 根据业务监听的事件选择。 |
| `radio-group` | `change` | `trigger('change', { value })` | 直接构造选中值。 |
| `checkbox-group` | `change` | `trigger('change', { value: [] })` | `value` 通常是数组。 |
| 自定义弹窗 | `confirm` / `close` / `select` | 对组件 `trigger(event, detail)` | 验证父页面收到组件事件后的逻辑。 |
| 授权按钮 | `getphonenumber` 等 | `tap()` 或 `trigger` | 真实授权入口用 tap，业务回调逻辑用 trigger。 |
| 表单 | `submit` | `trigger('submit', { value })` | 需要构造表单字段时更适合 trigger。 |

示例：`checkbox-group`：

```xml
<checkbox-group bindchange="onSceneChange">
  <label wx:for="{{sceneList}}" wx:key="value">
    <checkbox value="{{item.value}}" />
    {{item.name}}
  </label>
</checkbox-group>
```

业务代码：

```js
Page({
  onSceneChange(e) {
    this.setData({
      selectedScenes: e.detail.value
    })
  }
})
```

测试：

```js
const group = await page.$('.scene-checkbox-group')

await group.trigger('change', {
  value: ['takeout', 'dine-in']
})
```

这里用 `tap` 逐个点复选框也可以，但如果当前测试目标只是验证业务处理逻辑，直接触发 `change` 更稳定。

### 12.13 什么时候 trigger('tap') 也比 tap() 更合适

一般来说，真实点击优先用 `tap()`。但有些情况下，即使事件名也是 `tap`，也会选择 `trigger('tap')` 或 `strigger(selector, 'tap')`。

常见原因：

```text
节点在自动化环境中可查询，但点击坐标不稳定。
节点视觉上被内部 image/text 覆盖，tap 子节点不触发父节点。
节点在 scroll-view 内，自动化点击中心点被遮挡。
节点有 transform 或 absolute 定位，自动化计算点击区域有偏差。
外层按钮才绑定 bindtap，但测试原来定位的是内部图标。
当前测试只关心 bindtap 业务逻辑，不关心真实 UI 点击区域。
```

例如：

```xml
<button class="icon-button" bindtap="onDelete">
  <image class="icon" src="/assets/delete.png" />
</button>
```

如果：

```js
await page.$('.icon-button').then((el) => el.tap())
```

在当前自动化环境仍不稳定，可以改成：

```js
await page.$('.icon-button').then((el) => el.trigger('tap'))
```

这时要在测试说明中明确：

```text
这里验证的是 onDelete 事件处理逻辑，不验证真实点击命中区域。
```

否则后续维护者可能误以为这条用例已经覆盖了真实用户点击能力。

### 12.14 自动化点击失败的排查清单

遇到“人工点击可以，自动化点击不行”时，按下面顺序排查。

第一步：确认自动化选中的节点。

```text
选择器是否命中了预期节点？
是否命中了多个节点中的第一个错误节点？
命中的是否是内部 image/text，而不是外层 button/view？
节点是否属于自定义组件内部，而父页面实际监听的是组件事件？
```

第二步：确认事件绑定位置。

```text
bindtap 写在哪个节点？
catchtap 写在哪个节点？
bindchange / bindinput / bindconfirm 写在哪个节点？
父页面监听的是组件事件，还是内部 DOM 事件？
```

第三步：确认事件类型。

```text
业务方法是否监听 tap？
业务方法是否实际监听 change/input/confirm/select？
是否需要 e.detail.value？
是否需要 e.currentTarget.dataset？
是否需要 e.target.dataset？
```

第四步：确认节点状态。

```text
是否 disabled？
是否 hidden？
是否 wx:if 未渲染？
是否被遮罩盖住？
是否在 scroll-view 可视区域外？
是否样式透明或点击区域很小？
```

第五步：确认是否需要滚动或等待。

```text
元素是否还没渲染出来？
接口数据是否还没回来？
动画是否还没结束？
弹窗是否还没打开？
列表是否需要滚动到目标项？
```

第六步：选择修复方式。

```text
如果选错节点：改为选择真正绑定事件的节点。
如果事件类型错了：改为 trigger 对应事件。
如果缺少 detail：补充 e.detail 数据。
如果只是 UI 等待问题：等待渲染完成或滚动到可见区域。
如果真实点击链路需要覆盖：保留 tap，并修正定位和等待。
如果只测业务处理逻辑：改用 trigger / strigger。
```

### 12.15 dataset 也是 tap 和 trigger 差异的重要来源

很多小程序代码依赖 `dataset`：

```xml
<button
  class="goods-add-btn"
  data-id="{{goods.id}}"
  data-name="{{goods.name}}"
  bindtap="onAddGoods"
>
  加入购物车
</button>
```

业务代码：

```js
Page({
  onAddGoods(e) {
    const { id, name } = e.currentTarget.dataset
    this.addGoods(id, name)
  }
})
```

如果自动化点的是内部节点：

```xml
<button class="goods-add-btn" data-id="{{goods.id}}" bindtap="onAddGoods">
  <image class="goods-add-icon" src="/assets/add.png" />
</button>
```

脚本：

```js
const icon = await page.$('.goods-add-icon')
await icon.tap()
```

可能出现的问题是：

```text
事件触发节点和 currentTarget 不是预期 button。
dataset 不是业务代码想要的 dataset。
e.currentTarget.dataset.id 取不到值。
```

更稳妥做法：

```js
const button = await page.$('.goods-add-btn')
await button.tap()
```

如果改用 `trigger('tap')`，也应该打在带 `data-id` 的节点上：

```js
await button.trigger('tap')
```

不要打内部图片：

```js
await icon.trigger('tap')
```

因为内部图片没有 `data-id`。

如果业务逻辑强依赖 `dataset`，测试稳定性通常取决于：

```text
选择器是否选中了携带 data-* 的节点。
事件是否从该节点触发。
currentTarget 是否是业务预期节点。
```

### 12.16 自动化测试分层建议

不要用一种方法覆盖所有测试场景。建议分成三层。

第一层：真实主流程冒烟测试。

```text
目标：验证用户从页面入口到关键结果的真实链路。
方法：尽量用 tap、输入、滚动、等待。
覆盖：按钮是否可见、是否可点、路由是否正常、关键结果是否出现。
数量：少而关键。
```

例如：

```text
进入商品详情 -> 点击加入购物车按钮 -> 切到购物车 tab -> 看到商品。
```

第二层：事件处理逻辑测试。

```text
目标：验证指定事件和指定 detail 下，页面业务逻辑是否正确。
方法：使用 trigger / strigger。
覆盖：picker change、input input、组件 confirm、表单 submit、边界枚举值。
数量：可以多一些。
```

例如：

```js
await strigger(page, '.coupon-picker', 'change', {
  value: 2
})
```

验证：

```text
页面选中第三张券。
金额重新计算。
提交参数中的 couponId 正确。
```

第三层：组件内部测试。

```text
目标：验证自定义组件内部交互是否能正确抛出事件。
方法：在组件级测试中 tap 内部按钮，然后断言组件 triggerEvent。
覆盖：组件内部选择、关闭、确认、校验。
```

例如：

```text
sku-popup 内部：
点击规格 A -> 点击规格 B -> 点击确认 -> 组件抛出 confirm。
```

父页面测试不一定要重复这条完整链路，可以直接：

```js
await skuPopup.trigger('confirm', {
  skuId: 1001,
  count: 2
})
```

这样可以减少重复、降低脆弱性。

### 12.17 推荐的测试代码注释写法

当用 `trigger` / `strigger` 替代 `tap` 时，建议在测试中写清楚原因。

推荐：

```js
// picker 的原生选择弹层在自动化环境中不稳定，这里直接触发 change，
// 本用例验证门店变更后的价格和提交参数，不验证 picker 弹层交互。
await strigger(page, '.shop-picker', 'change', {
  value: 1
})
```

推荐：

```js
// 事件绑定在外层 button，内部 image 只是图标。
// 这里直接触发 button 的 tap，验证删除逻辑，不验证真实坐标命中。
await strigger(page, '.delete-btn', 'tap')
```

不推荐：

```js
await strigger(page, '.delete-icon', 'tap')
```

原因：

```text
delete-icon 不是事件绑定节点。
后续维护者不知道为什么绕过 tap。
测试失败时难以判断是 UI 问题还是事件问题。
```

### 12.18 最终决策表

可以用下面的决策表快速判断。

| 问题 | 选择 |
|---|---|
| 要验证用户真实点击是否可用？ | `tap()` |
| 要验证按钮点击后的业务逻辑？ | 优先 `tap()`，不稳定时对绑定节点 `trigger('tap')` |
| 要验证 picker 选择后的逻辑？ | `trigger('change', { value })` |
| 要验证输入值变化？ | 输入方法或 `trigger('input', { value })` |
| 要验证自定义组件通知父页面？ | 对组件 `trigger('事件名', detail)` |
| 视觉上是图片，事件绑在外层按钮？ | 操作外层按钮 |
| 自动化点 image 失败但人工可点？ | 检查是否选错节点，改点外层绑定事件节点 |
| 业务依赖 `e.detail`？ | 用 `trigger` 构造 detail |
| 业务依赖 `dataset`？ | 选择携带 `data-*` 的节点 |
| 要证明遮罩、disabled、层级没有问题？ | 用真实 `tap()` |

## 13. 路由 API 选择建议

普通页面之间跳转：

```text
navigateTo
```

提交成功、不希望用户返回原表单页：

```text
redirectTo
```

跳转到首页、分类、购物车、我的等 tabBar 页面：

```text
switchTab
```

登录失效、退出登录、切换门店、切换租户、重置业务流程：

```text
reLaunch
```

返回上一页或返回多级页面：

```text
navigateBack
```

tabBar 页面每次进入都要刷新数据：

```text
onShow
```

tabBar 页面需要接收跳转参数：

```text
不要依赖 query 参数，使用全局状态、缓存、状态管理或事件机制。
```

自动化测试点击：

```text
优先定位真正绑定事件的节点。测试真实点击链路用 tap；测试事件处理逻辑用 trigger / strigger。
```

## 14. 总结

小程序 tabBar 和页面栈的核心规则可以概括为：

```text
navigateTo：普通页面入栈。
navigateBack：页面出栈。
redirectTo：替换当前页面。
switchTab：切换到 tabBar 页面，并关闭非 tabBar 页面。
reLaunch：清空整个页面栈，包括栈底 tabBar 页面，然后打开指定页面。
```

最需要记住的是：

- tabBar 页面是一级入口页面，不是普通页面。
- `navigateTo` 和 `redirectTo` 不能跳转 tabBar 页面。
- `switchTab` 只能跳转 tabBar 页面。
- `switchTab` 不能携带 query 参数。
- `switchTab` 会关闭非 tabBar 页面。
- `reLaunch` 会清空所有页面，包括原来的 tabBar 页面。
- tabBar 页面切换回来通常触发 `onShow`，不要只依赖 `onLoad` 刷新业务数据。
- 自动化测试中，人工点击成功不代表 `tap` 内部图片节点也一定成功；应优先操作真正绑定事件的节点。
- `tap` 更适合验证真实用户点击链路，`trigger` / `strigger` 更适合验证指定事件和 `e.detail` 驱动的业务逻辑。
