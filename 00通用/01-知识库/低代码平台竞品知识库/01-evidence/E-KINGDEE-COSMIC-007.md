---
id: E-KINGDEE-COSMIC-007
type: evidence
competitor: Kingdee-Cosmic
module: developer-platform
source_channel: official-doc
source_type: developer-guide
source_url: https://vip.kingdee.com/knowledge/specialDetail/218022218066869248?category=218025948732895488&id=239044899968826368&type=Knowledge&productLineId=29&lang=zh-CN
source_owner: competitor-official
captured_at: 2026-07-08
valid_until: 2026-10-08
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：金蝶开发平台的云与应用治理层

## 原始观察

金蝶 AI 苍穹开发指南中的“云管理 / 云与应用整体介绍”将“云”定义为企业业务领域划分：一朵云代表一个完整业务领域解决方案，例如财务云、采购云。业务云是平台顶层业务设计，一个云下可包含多个应用，企业交付时可选择某个云下的部分应用分批上线。

该文档还说明业务云支持创建、修改、删除、Git/SVN 同步等操作。创建云时需要编码、名称、序号、行业、描述、主题图片等信息；编码通常由开发商标识和自定义编码组成，用于代码识别并具备唯一性。

同一开发指南中的“应用管理说明”将应用定义为业务云下一组具有相同意义的功能。应用包含一个或多个功能分组，用于分类管理表单页面。应用管理包含新建、修改、Git/SVN 管理、扩展、导入导出、菜单、预览、启用等能力。

应用导出内容包括页面元数据、脚本、所属业务云信息、应用信息、菜单、功能分组、SQL 语句、资源文件、安装包信息等。多个应用之间有依赖关系时，可通过安装顺序配置导入顺序。

## 证据强度

直接事实：官方开发指南明确说明“云”的业务域含义、云与应用的包含关系、应用的功能分组和页面管理，以及导入导出的元数据包内容。

推断边界：该证据不能证明金蝶内部源码结构或数据库表结构，只能证明其公开产品设计和开发平台对象层级。

## 可抽取知识

- 企业级低代码平台的顶层对象不应直接从“应用”开始，还需要业务域 / 解决方案包层级。
- 应用不是单个页面集合，而是带菜单、功能分组、权限、导入导出、版本同步、资源和 SQL 的交付单元。
- 开发商标识、编码唯一性、Git/SVN、安装顺序和资源包说明金蝶把低代码资产纳入工程治理。
- 自研平台应将“业务域、应用、功能分组、页面、菜单、发布包”建成显式元模型。
