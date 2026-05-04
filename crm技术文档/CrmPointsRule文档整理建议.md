# CrmPointsRule 文档整理建议

更新时间：2026-04-30

## 建议保留

### 1. `CrmPointsRule同步接口升级原理——消除Forest-baseUrl依赖.md`

保留原因：

- 这是当前最完整的“技术改造说明”版本。
- 内容覆盖了问题背景、根因、接口抽象方案、两端实现方式、调用链对照和常见问题。
- 与 `CrmPointsRule同步去除ForestBaseUrl依赖-实施方案.md` 高度重复，但表达更完整，状态也更明确。

### 2. `CrmPointsRule同步链路与Nacos服务发现问题复盘.md`

保留原因：

- 这是当前最完整的“最终复盘”版本。
- 覆盖了同步链路、建表问题、Forest `baseUrl` 问题、ReactiveFeign 改造后的 Nacos 超时问题。
- 明确说明了 `memberDayDaysOfWeek`、`memberDayDaysOfMonth` 字段在当前代码中已经补齐，能纠正早期分析文档里的过时结论。

## 你本次列出的 4 份文档处理建议

| 文档名 | 处理建议 | 原因 |
| --- | --- | --- |
| `CrmPointsRule云端到POS本地同步链路分析.md` | 可删除 | 属于早期链路分析稿，后续已被 `CrmPointsRule同步链路与Nacos服务发现问题复盘.md` 覆盖；其中“会员日字段缺失”结论已过时。 |
| `CrmPointsRule同步去除ForestBaseUrl依赖-实施方案.md` | 可删除 | 属于实施阶段文档，主要内容已被 `CrmPointsRule同步接口升级原理——消除Forest-baseUrl依赖.md` 完整覆盖。 |
| `CrmPointsRule同步去除ForestBaseUrl依赖方案.md` | 可删除 | 属于更早的方案稿，保留价值低；其核心结论已并入后续“实施方案/升级原理”文档。 |
| `CrmPointsRule同步接口升级原理——消除Forest-baseUrl依赖.md` | 保留 | 作为最终技术说明文档保留。 |

## 同目录补充建议

`CrmPointsRule同步改造方案.md` 也建议删除。

原因：

- 这是更早的一版简要提纲。
- 被后续 3 份文档完整覆盖，没有独立保留价值。

## 推荐最终保留集

如果目标是“保留最少、信息最全”，最终只保留下面 2 份即可：

1. `CrmPointsRule同步接口升级原理——消除Forest-baseUrl依赖.md`
2. `CrmPointsRule同步链路与Nacos服务发现问题复盘.md`

## 推荐阅读顺序

1. 先看 `CrmPointsRule同步接口升级原理——消除Forest-baseUrl依赖.md`
2. 再看 `CrmPointsRule同步链路与Nacos服务发现问题复盘.md`

这样一个负责说明“怎么改”，一个负责说明“为什么这样改、最终问题怎么收敛”，职责最清晰。
