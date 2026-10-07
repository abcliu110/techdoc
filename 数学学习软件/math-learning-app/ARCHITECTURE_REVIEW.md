# 数学学习软件架构审查报告

## 1. 目录结构分析

### 1.1 当前结构

```
src/
├── domain/              # 领域层 - 核心业务逻辑
│   ├── types/           # 类型定义（枚举、接口）
│   ├── services/        # 领域服务
│   └── errors/          # 领域错误类
├── application/         # 应用层 - 用例编排
│   ├── ports/           # 仓储接口（抽象层）
│   └── use-cases/       # 用例实现
├── engine/              # 引擎层 - 专业能力
│   ├── math/            # 数学表达式解析与等价检查
│   └── step-runtime/    # 步骤运行时
├── platform/            # 平台适配层
│   ├── web/             # Dexie IndexedDB实现
│   ├── tauri/           # SQLite实现
│   ├── content/         # 文件系统内容加载
│   └── StorageAdapter.ts
├── components/          # UI组件层
│   ├── layout/          # 布局组件
│   ├── steps/           # 步骤组件
│   ├── ui/              # 基础UI组件
│   └── visuals/         # 可视化组件
├── stores/              # Zustand状态管理
├── hooks/               # React Hooks
├── pages/               # 页面组件
├── router/              # 路由配置
├── i18n/                # 国际化资源
└── content/             # 内容Schema定义
```

### 1.2 架构评分

| 维度 | 评分 | 说明 |
|------|------|------|
| 分层清晰度 | 8/10 | 领域层、应用层、平台层分离良好 |
| 依赖方向 | 7/10 | 大部分正确，platform层耦合需优化 |
| 领域纯净度 | 9/10 | domain层无UI依赖，良好的设计 |
| 抽象程度 | 8/10 | Repository接口抽象合理 |
| 可扩展性 | 8/10 | 平台适配器模式支持多端 |

## 2. 分层架构验证

### 2.1 依赖方向检查

```
UI层 (components, pages)
    ↓ 依赖
Hooks层 (hooks)
    ↓ 依赖
Stores层 (stores) ← Zustand状态
    ↓ 依赖
应用层 (use-cases)
    ↓ 依赖
领域层 (domain/types, services)
    ↓ 依赖
引擎层 (engine)

平台层 (platform) ← 被应用层注入，不反向依赖
```

**结论**: 依赖方向基本正确，遵循了从外到内的依赖规则。

### 2.2 领域层纯净度检查

检查 domain 层是否依赖 UI 框架（React/Zustand）：

| 文件 | 依赖检查 | 结果 |
|------|----------|------|
| `domain/types/*.ts` | 无 | 通过 |
| `domain/services/*.ts` | 无 | 通过 |
| `domain/errors/*.ts` | 无 | 通过 |

**结论**: 领域层完全纯净，未依赖任何 UI 框架。

## 3. Repository 接口审查

### 3.1 接口定义一致性

| 接口 | 方法签名 | 问题 |
|------|----------|------|
| `SessionRepository` | `initialize()`, `save()`, `findById()`... | 接口定义完整 |
| `ProfileRepository` | `save()`, `findByUserId()`, `delete()` | **缺少 initialize()** |
| `ContentRepository` | `listKnowledgePoints()`, `findSteps()`... | 接口定义完整 |

**问题**: `ProfileRepository` 接口缺少 `initialize()` 方法，但实现类包含此方法。

### 3.2 类型定义问题

| 问题 | 位置 | 说明 |
|------|------|------|
| `LearningSession` 缺少 `userId` | `domain/types/learning-session.ts` | 查询需要但未定义 |
| `ContentRepository.findSteps` 返回值未验证 | `platform/content/` | 有Zod schema但未使用 |

## 4. 整洁性问题

### 4.1 重复代码

| 重复项 | 位置 | 说明 |
|--------|------|------|
| `getAbilityLabel` | `GetAbilityProfile.ts`, `useAbilityProfile.ts`, `Home.tsx` | 三处重复实现 |
| 能力等级标签 | `useAbilityProfile.ts`, `GetAbilityProfile.ts` | 两处重复 |

**建议**: 统一使用 `i18n/zh-CN.ts` 中的资源。

### 4.2 类型问题

| 问题 | 文件 | 说明 |
|------|------|------|
| 未使用的类型 | `src/content/schema.ts` | Zod schema定义但未导入使用 |
| 类型不一致 | `LearningSession` | 缺少 `userId` 字段 |
| 类型收窄 | `ConcreteStep.tsx` | `visualConfig` 使用 `Record<string, unknown>` 过于宽泛 |

### 4.3 错误处理

| 问题 | 文件 | 说明 |
|------|------|------|
| 使用通用 Error | 多处 | 应使用 `DomainError` 子类 |
| 缺少错误码 | 错误类 | 仅使用消息，无错误码体系 |

## 5. 组件层审查

### 5.1 组件职责检查

| 组件 | 职责 | 评估 |
|------|------|------|
| `ConcreteStep.tsx` | 接收props，渲染UI | 良好 |
| `StepContainer.tsx` | 根据类型路由到具体组件 | 良好 |
| `SplitCircle.tsx` | 可视化渲染 | 良好 |

### 5.2 逻辑分离检查

`ConcreteStep.tsx` 中存在轻量级业务逻辑（完成判断），建议：
- 考虑将交互完成判断移到 `StepRuntime`
- 当前实现可接受，但需注意边界

## 6. 架构改进建议

### 6.1 高优先级

1. **统一能力标签映射**
   - 抽取 `getAbilityLabel` 到 `i18n` 或共享工具
   - 修改 `GetAbilityProfile.ts`、`useAbilityProfile.ts`、`Home.tsx`

2. **修复 ProfileRepository 接口**
   - 添加 `initialize()` 方法到接口定义

3. **添加 LearningSession.userId**
   - 与 `SessionRepository.findByUserId()` 配套

### 6.2 中优先级

4. **启用 Zod Schema 验证**
   - 内容加载时使用 `validateLearningStep()` 验证

5. **统一错误处理**
   - 用例中统一使用 `DomainError` 子类

6. **抽取能力等级映射**
   - 合并 `useAbilityProfile.ts` 和 `GetAbilityProfile.ts` 中的标签映射

### 6.3 低优先级

7. **优化 Hooks 中的 platform 实例化**
   - 考虑使用 React Context 或 Dependency Injection

8. **添加单元测试**
   - 领域服务有良好的可测试性，建议添加

## 7. 总结

### 优点
- 架构分层清晰，领域层纯净
- Repository 模式抽象良好，支持多平台
- 类型定义完善，使用了 TypeScript 高级特性
- Zod Schema 为未来扩展预留了验证能力
- 数学引擎（表达式解析、等价检查）设计合理

### 需要改进
- Repository 接口定义不一致（ProfileRepository 缺少 initialize）
- 存在重复的能力标签映射代码
- 错误处理未统一使用领域错误
- Zod Schema 未被实际使用
- LearningSession 类型缺少 userId 字段

### 架构评级: B+ (良好)

项目整体架构设计合理，符合 DDD 思想，主要问题集中在细节实现的一致性上。
