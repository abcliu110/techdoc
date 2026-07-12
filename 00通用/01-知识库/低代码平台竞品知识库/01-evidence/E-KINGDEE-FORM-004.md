---
id: E-KINGDEE-FORM-004
type: evidence
competitor: Kingdee-Cosmic
module: form-designer-principle
source_channel: third-party-report
source_type: post
source_url: https://www.jjckb.cn/2021-05/14/c_139945710.htm
source_owner: third-party
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：KDDM 元数据与动态解释公开报道

## 原始观察

经济参考网对金蝶 KDDM 的报道说明：KDDM 采用元数据描述领域模型中的元素及属性，并在运行期动态加载元数据来构建和运行模型。报道还说明动态领域建模由模型库、领域模型、动态解释引擎、可视化动态领域建模工具、领域构建、企业服务等部分组成。

报道提到在线开发设计平台中，大部分功能可通过所见即所得方式设计实现，另一部分通过插件实现，插件通过接口参与既定逻辑。

## 证据强度

高可信推断：该来源是公开媒体报道，不是金蝶官方开发手册或源码；可支撑对 KDDM 公开机制的理解，不能证明内部实现细节。

## 可抽取知识

- 金蝶表单设计器的原理可抽象为“元数据描述 + 可视化建模工具 + 动态解释引擎 + 插件扩展”。
- 表单控件、字段、布局、规则和插件更可能是模型元素/属性的一部分，而不是纯前端配置。
- 插件是处理复杂或定制逻辑的扩展通道，但其具体接口和生命周期仍需官方开发文档或试用验证。

