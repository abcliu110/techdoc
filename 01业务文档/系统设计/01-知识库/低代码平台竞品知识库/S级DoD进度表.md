# S级 DoD 进度表

日期：2026-07-05

## 结论

当前仍未达到 S 级完成态。本表用于防止把“源码证据数量达标”误判为完整 S 级完成。

说明：本轮已把 NocoBase 与 Frappe 的源码证据卡补到每核心模块约 20 张，满足“开源源码深度渠道”的数量阶段目标；并已补 NocoBase/Frappe 各 10 张官方可见界面证据与 10 张页面拆解卡，达到页面/UI 数量线。当前仍缺本地截图/录屏、运行时权限差异、工作流执行日志、业务规则卡和 Docker 实测验证，因此只能记为“源码证据数量达标，UI 页面数量线达标，S 级未完成”。

## NocoBase

| 核心模块 | 源码证据卡 | 知识卡 | 已覆盖源码文件 | 当前状态 | 剩余缺口 |
|---|---:|---:|---|---|---|
| 数据模型/元模型 | 22 | 3 | `collection.ts`、`field.ts`、`relation-field.ts` | 源码证据数量达标 | 补 data-source-manager、collection manager、字段类型全量清单、运行时导出样例 |
| 权限模型 | 23 | 2 | `acl.ts`、`acl-role.ts`、`apply-data-permissions.ts` | 源码证据数量达标 | 补 ACLResource、scope collection、权限 UI 配置、测试样例、运行时权限截图 |
| 页面/视图构建 | 21 + UI 证据 10 | 12 | `plugin-ui-schema-storage/src/server/repository.ts` + 官方教程截图 | 源码证据数量达标；官方可见 UI 与页面拆解数量线达标 | 补本地截图/录屏、运行时权限差异、workflow 执行日志 |
| 流程/工作流 | 21 | 2 | `workflows.ts` | 源码证据数量达标 | 补 triggers、nodes、executions、workflow engine 执行链路、运行时执行日志 |
| 扩展机制 | 22 | 2 | `plugin-manager.ts`、`migration.ts` | 源码证据数量达标 | 补 Plugin 基类、插件包结构、依赖排序、运行时安装流程、插件样例 |

## Frappe

| 核心模块 | 源码证据卡 | 知识卡 | 已覆盖源码文件 | 当前状态 | 剩余缺口 |
|---|---:|---:|---|---|---|
| 数据模型/元模型 | 22 | 3 | `doctype.json`、`docfield.json` | 源码证据数量达标 | 补完整 DocField 字段清单、Custom Field、Form/List 元数据、运行时导出样例 |
| 权限模型 | 24 | 3 | `permissions.py`、`docperm.json`、`user_permission.json` | 源码证据数量达标 | 补 Role、Permission Manager、字段 permlevel 运行时验证、权限截图 |
| 页面/视图构建 | 23 + UI 证据 10 | 12 | `layout.js`、`list_view.js`、`workspace.json` + 官方文档截图 | 源码证据数量达标；官方可见 UI 与页面拆解数量线达标 | 补本地截图/录屏、运行时权限差异、workflow 执行日志 |
| 流程/工作流 | 23 | 3 | `workflow.json`、`workflow_transition.json`、`workflow_document_state.json` | 源码证据数量达标 | 补 Workflow Action Permitted Role、运行时执行链路、审批样例 |
| 扩展机制 | 21 | 2 | `hooks.py`、`site.py` | 源码证据数量达标 | 补 app 安装、fixtures/export、patch/migrate 运行时链路、扩展样例 |

## 下一批必须补的源码文件

```text
NocoBase:
- packages/core/acl/src/acl-resource.ts
- packages/plugins/@nocobase/plugin-acl/src/server/collections/*
- packages/plugins/@nocobase/plugin-workflow/src/server/*
- packages/core/server/src/plugin.ts 或 Plugin 基类实际路径
- packages/core/data-source-manager/src/*

Frappe:
- frappe/public/js/frappe/form_builder/*
- frappe/desk/doctype/doctype_layout/*
- frappe/workflow/doctype/workflow_action_permitted_role/workflow_action_permitted_role.json
- frappe/modules/ 或 installer/migrate/fixtures 相关源码
```

## 验收状态

```text
S 级完成：否
当前阶段：源码证据数量达标；官方可见界面证据与页面拆解数量线达标；本地实测、运行时权限/工作流验证、业务规则卡和部分知识卡仍未达完整 S 级
是否允许 accepted ADR：否
是否允许作为商用平台最终架构：否
```
