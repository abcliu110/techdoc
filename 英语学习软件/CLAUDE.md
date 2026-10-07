# 英语学习软件 AI 研发入口

本文件是项目级入口。任何 AI 研发任务都必须先读取本文件和 `../00通用/ai工作流/` 下的五份权威规范：

1. `00-AI研发执行协议.md`
2. `01-AI软件架构设计规范.md`
3. `02-AI软件测试与代码质量规范.md`
4. `03-AI质量门控制器接口规范.md`
5. `ai研发质量门.yaml`

规范读取失败、版本无法确认、控制器适配器无法验证、独立 Agent 无法创建或证据无法验证时，任务必须输出 `blocked`，不得继续编码、测试或启动应用。

## 唯一执行模式

项目固定使用 `strict_multi_agent`。不得询问或提供 `strict/simple/single`、MVP、快速模式或单 Agent 选项。一个 `feature_id` 是一个独立验收周期，同一时间只能有一个功能处于开发中。

## 功能闭环

每个小功能都必须建立独立 `feature_team`，并完成架构师、设计师（适用时）、编码 Agent、自动化测试 Agent、Clean Code Reviewer、E2E/视觉验证 Agent（前端适用）及各自对抗角色的交接。每个角色必须有不同的运行时 `agent_id` 和持久化交接单。

功能必须按以下顺序推进：

```text
规范启动与 Agent 运行时验证
→ 任务契约、架构设计、交互设计和对抗评审
→ 测试策略门
→ 每个 checkpoint：Red → Green → Refactor
→ 自动化测试、Clean Code、架构、测试和独立代码评审
→ 适用的安全、契约、迁移和发布验证
→ 功能级真实验收
→ 缺陷关闭、证据冻结、功能关闭
→ 授权下一个功能
```

Red 阶段必须先写失败测试并记录非零退出码；Green 才允许最小生产实现；Refactor 后必须重新回归。先写生产代码、删除断言、吞掉错误、修改预期制造通过、直接 Shell 写入或绕过质量门，都会使当前 checkpoint `invalidated/unverified` 并阻塞。

## 评审独立性

不同角色必须分别评审不同产物：

| 产物 | 生产角色 | 独立评审角色 | 对抗/审计角色 |
|------|----------|--------------|---------------|
| 任务契约 | Task Orchestrator | Task Owner | Workflow Auditor、Acceptance Challenger |
| 架构/契约 | Architect | Architecture Reviewer | Architecture Adversary、Architecture Review Auditor |
| 交互设计 | Interaction Designer | Task Owner | Design Adversary |
| 实现代码 | Implementer | Independent Code Reviewer | Implementation Adversary、Review Auditor |
| 测试 | Automated Test Agent | Test Reviewer | Test Adequacy Adversary、Test Review Auditor |
| 可维护性 | Clean Code Reviewer | Task Owner | Maintainability Adversary |
| E2E/视觉 | E2E and Visual Reviewer | Acceptance Challenger | User Journey Adversary |
| 功能验收 | Task Owner | Acceptance Challenger | Feature Process Auditor |

产物作者不得批准自己的产物；评审必须记录 `agent_id`、评审版本、结论、发现、证据和独立性比较。缺少评审交接单、命令、退出码、报告、截图、trace 或视频时，质量门不得通过。

## 功能验收与推进

每个功能完成所有适用门后必须通过：

```text
feature_acceptance_passed
→ defect_registry_resolved
→ feature_evidence_frozen
→ feature_closed
→ next_feature_authorized
```

后端验收从真实 API、数据库和依赖链路执行；前端和全栈验收从真实浏览器入口执行，覆盖成功、失败、重试、边界和持久化结果。验收失败、证据缺失或存在高/阻断缺陷时不得开始下一个功能，也不得用项目最终验收替代功能验收。

## 控制器与禁止操作

所有文件写入和命令执行必须经 `ai-quality-gate-controller`。控制器不可用、命令未注册、路径越界、Agent 身份未验证、阶段不匹配或审计无法追加时，必须拒绝请求并保持 `blocked`。禁止删除源码、测试、文档或证据来“清理后重来”，禁止使用 `git reset --hard`、`git clean`、`git checkout` 或递归删除恢复现场。

修复必须拆为独立 checkpoint，先由架构师确认边界，再按 TDD 和多角色评审循环执行；不得由主 Agent 接管缺失角色或自行宣布通过。
