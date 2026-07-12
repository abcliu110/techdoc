---
id: E-KINGDEE-FORM-002
type: evidence
competitor: Kingdee-Cosmic
module: bill-designer
source_channel: official-doc
source_type: doc
source_url: https://help.open.kingdee.com/dokuwiki/doku.php?id=%E5%8D%95%E6%8D%AE%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%BA%94%E7%94%A8
source_owner: competitor-official
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：金蝶单据设计与应用步骤

## 原始观察

金蝶云产品手册的“单据设计与应用”页面说明：业务单据用于保存业务流程中发生的数据，并承载业务流程之间的逻辑关系。

操作步骤中包含：登录 BOS 集成开发平台，选择业务领域和子系统，新建业务对象，拖动常规字段和通用控件到单据模板界面；通过属性窗口配置整单属性、字段属性和控件属性，包括菜单集合、编码规则、单据状态；保存后可查看元数据校验，也可测试；之后创建单据视图、设置单据转换、发布到主控台、制作部署包、创建套打模板、创建单据类型、配置工作流/业务流程，并在客户端主控台使用通用操作、过滤、附件、引入引出等能力。

## 证据强度

直接事实：官方产品手册明确给出单据设计链路和表单设计器相关操作对象。

## 可抽取知识

- 金蝶表单/单据设计器包含字段与控件拖放、属性配置、元数据校验、测试、视图、转换、发布、部署和流程配置等完整链路。
- 表单设计在金蝶体系中会连接菜单、编码规则、单据状态、单据转换、工作流、套打、附件和导入导出，不只是 UI 布局。
- 自研平台的表单设计器如果面向企业业务，应把“保存后元数据校验”和“发布/部署前验证”纳入核心流程。

