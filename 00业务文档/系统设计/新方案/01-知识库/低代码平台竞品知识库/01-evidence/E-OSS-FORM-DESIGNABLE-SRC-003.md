---
id: E-OSS-FORM-DESIGNABLE-SRC-003
type: evidence
competitor: Designable
module: schema-reverse
source_channel: github
source_type: discussion
source_url: https://github.com/alibaba/formily/discussions/1912
source_owner: user-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Designable JSON Schema 反显到设计器树

## 原始观察

Formily GitHub discussion 中，维护者回复“如何将 DesignAble 生成的 jsonSchema 反显在 DesignAble 上”时，说明大致两步：将 json schema 对象递归创建成以 TreeNode 实例为节点的节点树；将这棵树设置到当前 Workspace 的 operation.tree 下级节点中。回复还提到可使用 `@designable/formily` 提供的 `transformToTreeNode` 方法。

## 证据强度

高可信推断：该信息来自 GitHub discussion 的维护者回复，可作为机制线索；仍需源码和运行验证确认当前版本 API。

## 可抽取知识

- Designable 设计器的核心运行结构可以抽象为 Workspace + operation.tree + TreeNode。
- schema 反显不是简单 JSON 渲染，而是需要把 schema 转为设计器节点树。
- 自研设计器必须支持“已发布 schema -> 设计器可编辑树”的反向加载，否则无法维护历史表单。

