---
id: BIZ-KINGDEE-001
type: business
domain_object: KingdeeKDDM
competitors: [Kingdee-Cosmic]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [BIZ-LOWCODE-001, DM-LOWCODE-001, ADR-LOWCODE-001]
owner: AI
ai_generated: true
---

# 金蝶 KDDM 业务元模型路线

## 证据边界

金蝶 AI 苍穹 / 云苍穹为闭源平台，本卡只基于官方公开页面。官方页面可以证明其公开定位和能力表述，不能证明内部源码结构、数据库表结构或运行时实现。

因此本卡强度为“高可信推断”，confidence 按方法论上限控制在 0.6。

## 抽象

金蝶路线的核心不是“拖拽页面”，而是以 KDDM 动态领域模型为中心，把以下对象统一到元数据体系：

```text
业务对象
布局
规则
流程
组织
人员
客商
权限
应用扩展
AI 辅助开发
```

## 对自研平台的启发

如果目标是正式商用的企业业务低代码平台，内核优先级应为：

```text
业务对象元模型 > 权限和组织 > 流程规则 > 版本迁移 > 页面构建器
```

页面构建器是业务模型的表现层，不应成为平台的唯一中心。

## 差异化机会

闭源商用平台的优势是企业基础设施完整，但弱点通常是学习成本、平台绑定和二次开发门槛。自研平台可以选择：

```text
保留业务元模型和治理能力
降低建模入口复杂度
把插件、脚本、API 逃逸通道做得更透明
用知识库驱动模块逐步成型，而不是一次性复制大平台
```

## 待验证

- KDDM 的完整对象字段清单。
- 动态表单、单据、流程、权限的真实配置结构。
- 扩展插件和二开 API 的边界。
- 私有化部署、租户隔离、版本迁移机制。
