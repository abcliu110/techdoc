---
id: LICENSE-LOWCODE-001
type: nfr
domain_object: LowCodeLicenseBoundary
competitors: [NocoBase, Frappe, Appsmith, Directus]
evidence: [E-NOCOBASE-LICENSE-001, E-FRAPPE-LICENSE-001, E-APPSMITH-LICENSE-001, E-DIRECTUS-LICENSE-001]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: []
owner: AI
ai_generated: true
---

# 开源竞品 License 与商用边界

## 证据来源

本卡基于 2026-07-05 直接读取 GitHub 仓库 license 文件，对应证据卡为 `E-NOCOBASE-LICENSE-001`、`E-FRAPPE-LICENSE-001`、`E-APPSMITH-LICENSE-001`、`E-DIRECTUS-LICENSE-001`：

```text
NocoBase: nocobase/nocobase LICENSE.txt, main, 1c41defe6c458771dd3449cb8b4557a49e584737
Frappe: frappe/frappe LICENSE, develop, b2fd06632503ddffd751a1a5556e33cb2ceccc7c
Appsmith: appsmithorg/appsmith LICENSE, release branch, 2026-07-05 GitHub API access
Directus: directus/directus license, main, 2026-07-05 GitHub API access
```

## 直接事实

| 竞品 | License 观察 | 自研商用边界 |
|---|---|---|
| NocoBase | 自定义 NocoBase License Agreement；社区版引用 Apache-2.0 但附加补充条款；明确不允许用原始或修改软件向公众提供 no-code/zero-code/low-code/AI platform SaaS/PaaS 产品 | 只能学习设计思想和公开源码结构，不能直接基于其代码做对外低代码平台 |
| Frappe | MIT License | 可作为宽松开源参考，但仍需遵守版权声明与商标边界 |
| Appsmith | Apache License 2.0 | 可作为宽松开源参考，但不能复制品牌和特定产品表达 |
| Directus | Monospace Sustainable Core License 1.0；定义 `Competing Use`；并声明第四个周年后转 GPL-3.0 | 对竞争性产品存在明确限制，不能直接基于其代码构建同类商业平台 |

## 设计决策含义

知识库可以学习：

```text
元模型结构
权限链路
工作流抽象
UI 信息架构
插件边界
工程组织方式
```

知识库不能变成：

```text
复制源码
复制 UI 表达
复制品牌资产
绕开竞品商业许可做同类平台
```

## 对自研平台的启发

正式商用的低代码平台建议采取“干净借鉴”策略：

```text
从竞品源码抽象概念和设计取舍
用自己的领域模型、代码实现和 UI 表达重建
关键 ADR 记录借鉴来源和不复制边界
License 风险高的竞品只作为架构参考，不作为代码基座
```

## 待补

本卡当前覆盖 4 个重点竞品。下一轮需要补齐 ToolJet、Budibase、Lowcoder、NocoDB 的 license 与企业版边界。
