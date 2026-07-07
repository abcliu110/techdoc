# 微信小程序自动化 tabBar 页面栈上下文规则

## 核心模型

微信小程序是全局页面栈，不是浏览器 DOM 页面模型。tabBar 页面有特殊路由规则：tabBar 页面只能通过 `switchTab` 进入，业务子页面不能当作 tabBar 根页面处理。

测试框架按 4 棵业务树建模：

| 树 | tabBar 根页面 | 业务含义 |
|---|---|---|
| 首页树 | `pagesIndex/page0/index` | 首页 |
| 点餐树 | `pagesIndex/page1/index` | 点餐/订单入口 |
| 账单树 | `pagesIndex/page2/index` | 账单/订单 |
| 会员树 | `pagesIndex/page3/index` | 会员中心 |

## switchTab 规则

只有当前 `currentPage().path` 是 4 个 tabBar 根页面之一时，才允许 `switchTab` 到其他 tabBar。

如果当前 path 不是 4 个根页面，说明处在业务子页面或弹窗状态，禁止直接跨 tab。必须先按当前业务状态用真实 UI `tap` 退出到底层 tabBar，再 `switchTab`。

常见业务子页面：

- `pagePop/orderfoods/index`：点餐页。
- `pagePop/selectnumberofpeople/index`：人数选择。
- `pagePop/cart/index`：购物车/现在下单。
- `pagePop/orderstatus/index`：下单结果。
- `pagePop/paycenter/index`：支付中心。
- `pagePop/recharge...`：充值页。

## 原子操作规范

每个微信小程序原子操作必须按顺序执行：

1. 读取 `currentPage().path`，判断 tab 根或业务子页面。
2. 判断业务上下文：`tabTree`、页面状态、可见根元素。
3. 上下文不对直接报错，不允许兜底乱点。
4. 上下文正确后，查找目标元素是否可见。
5. 只使用真实 UI 操作：`tap` 或合法的 `switchTab`。
6. 点击后必须验证页面、状态、请求或可见文本变化，确认按钮真的生效。

点餐页是业务单页面状态集合，人数、规格、购物车、支付中心等必须按 path + 可见根元素判断，不能只靠文本全局扫描。

## 诊断脚本注意

PowerShell 中不要用双引号 `node -e "..."` 执行包含 `$$` 的小程序自动化代码，`$$` 会被 PowerShell 展开导致脚本损坏。使用 stdin here-string 或脚本文件：

```powershell
$OutputEncoding=[System.Text.UTF8Encoding]::new()
[Console]::InputEncoding=[System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new()
@'
const page = await miniProgram.currentPage()
const items = await page.$$('view')
'@ | node -
```

中文读写必须显式 UTF-8，禁止把乱码写回 JSON、脚本或文档。
