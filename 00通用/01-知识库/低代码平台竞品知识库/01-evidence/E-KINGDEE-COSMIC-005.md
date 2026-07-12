---
id: E-KINGDEE-COSMIC-005
type: evidence
competitor: Kingdee-Cosmic
module: kddm
source_channel: media-report
source_type: article
source_url: https://www.jjckb.cn/2021-05/14/c_139945710.htm
source_owner: third-party-media
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：KDDM 动态领域模型公开报道

## 原始观察

公开报道将 KDDM 描述为以元数据描述领域模型元素和属性，并在运行期动态加载元数据来构建和运行模型。

报道还提到动态领域建模包含模型库、领域模型、动态解释引擎、可视化建模工具、领域构建和企业服务等组成部分，并把插件作为处理非标准能力的一种扩展方式。

## 证据强度

高可信推断：该来源为公开媒体报道，不是源码或官方开发手册。可用于增强对 KDDM 公开机制的理解，但不能证明内部实现细节。

## 可抽取知识

- KDDM 可被抽象为“模型库 + 模型元素 + 属性 + 动态解释引擎 + 可视化工具 + 插件扩展”。
- 自研平台可借鉴“80% 元模型配置 + 20% 插件扩展”的分层思想，但比例和边界需要实测或业务约束验证。
- 插件不是逃避建模的垃圾桶，应作为明确扩展点参与既定生命周期。
