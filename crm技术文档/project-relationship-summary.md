# 项目关系总表

| 项目 | 角色 | 技术形态 | 主要接口前缀/能力 | 真实服务名/归属 | 主要关系 |
|---|---|---|---|---|---|
| nms4cloud | 主 SaaS 平台后端 | Java / Spring Cloud | `shopping_cart/*` `order_bill/*` `biz_param/*` `wx_*` `pay/*` `mq/*` | `nms4cloud-*` 微服务集群 | 整个平台基座，承载顾客侧、商户侧、支付、微信、MQ |
| nms4cloud-bi | 旧 BI/报表服务 | Java / Spring Cloud | `/boss/*` 报表接口 | `nms4cloud-bi` | 旧报表线，服务名仍为 BI |
| nms4cloud-pos11report | POS 报表重构版 | Java / Spring Cloud | `/boss/*` 报表接口 | 仍挂 `nms4cloud-bi` 服务名 | BI 新实现 / 重构线 |
| nms4cloud-wms | WMS / 库存成本 | Java / Spring Cloud | WMS 自身接口，反调 `/boss/paid` | `nms4cloud-wms` | 依赖 BI 报表结果，服务 WMS 业务 |
| nms4pos | POS 后端体系 | Java / Spring Cloud | `/api/pos4cloud/app/*` `PATH_PREFIX_PLATFORM/*` `PATH_PREFIX_MERCHANT/*` `PATH_PREFIX_INNER/*` | `nms4cloud-pos` | POS 云端、门店、离线协同、打印、同步 |
| nms4cloud-biz-ui | SaaS 后台 Web | React / Umi / Ant Design Pro | `/api/*` | 走统一网关，落到 `nms4cloud` 各服务 | 商户/运营/后台管理前端 |
| nms4pos-ui | POS 前端工作区 | React / Taro / PNPM Workspace | `/api/sys/*`，部分 POS 专属接口 | 主要归 `nms4pos` | 对接 POS 云端和设备业务 |
| taro-mall | 顾客侧商城/扫码点餐 | Taro | `shopping_cart/*` `order_bill/*` `biz/*` 微信登录/页面配置 | 主要归 `nms4cloud-order` / `nms4cloud-wechat` / `nms4cloud-crm` | 顾客点餐和商城入口 |
| uni4merchant | 商户端 uniapp | Vue / uni-app | `/api/sys/*` | 统一网关后落到商户业务服务 | 商户移动端/小程序 |
| uni4pay | 支付页/收款页 uniapp | Vue / uni-app | `/api/pay/*` `/api/wx/mp/oauth2/*` `/api/mq/pay/*` | `nms4cloud-payment` / `nms4cloud-wechat` / `nms4cloud-mq` | 支付、公众号授权、二维码收款 |
| web4share | 前端共享库 | TypeScript package | `@nms/share` | 公共类型、请求、工具库 | 被 `nms4cloud-biz-ui`、`uni4merchant`、`uni4pay` 复用 |
| pos4install | 安装/部署辅助仓 | 未识别出核心源码 | 暂无 | 暂无 | 更像安装资源或辅助仓 |

## 服务名常量

- `nms4cloud-platform`
- `nms4cloud-mq`
- `nms4cloud-wechat`
- `nms4cloud-biz`
- `nms4cloud-product`
- `nms4cloud-crm`
- `nms4cloud-wms`
- `nms4cloud-bi`
- `nms4cloud-payment`
- `nms4cloud-order`
- `nms4cloud-mall`
- `nms4cloud-pos`

## 接口前缀到真实服务

| 前缀 | 真实服务 |
|---|---|
| `/api/pay/*` | `nms4cloud-payment` |
| `/api/wx/mp/oauth2/*` | `nms4cloud-wechat` |
| `/api/mq/*` | `nms4cloud-mq` |
| `/shopping_cart/*` | `nms4cloud-order` |
| `/order_bill/*` | `nms4cloud-order` |
| `/boss/*` | `nms4cloud-bi`，当前由 `nms4cloud-pos11report` 承担新实现 |
| WMS 自身 Feign/API | `nms4cloud-wms` |
| `/api/pos4cloud/app/*` | `nms4cloud-pos` |
| `/api/sys/*` | 统一网关前缀，真实落点依业务而定 |
