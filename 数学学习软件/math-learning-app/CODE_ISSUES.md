# 代码问题清单

## 问题分类

| 严重程度 | 说明 |
|----------|------|
| **阻断** | 架构缺陷或编译错误，必须修复 |
| **高** | 功能性问题或严重的不一致 |
| **中** | 代码质量问题，建议修复 |
| **低** | 优化建议，可延后处理 |

---

## 阻断问题

### [阻断-1] LearningSession 缺少 userId 字段

**位置**: `src/domain/types/learning-session.ts`

**问题**: `SessionRepository.findByUserId()` 和 `findActiveByUserId()` 需要 userId，但 `LearningSession` 接口未定义此字段。

**当前代码**:
```typescript
export interface LearningSession {
  readonly id: string;
  readonly knowledgePointId: string;
  readonly ability: Ability;
  status: SessionStatus;
  // 缺少 userId!
  ...
}
```

**修复建议**:
```typescript
export interface LearningSession {
  readonly id: string;
  readonly userId: string;  // 添加此字段
  readonly knowledgePointId: string;
  readonly ability: Ability;
  status: SessionStatus;
  ...
}
```

**影响范围**: 所有会话相关操作

---

## 高优先级问题

### [高-1] ProfileRepository 接口缺少 initialize() 方法

**位置**: `src/application/ports/ProfileRepository.ts`

**问题**: 接口定义不完整，与 `SessionRepository` 不一致。

**当前代码**:
```typescript
export interface ProfileRepository {
  save(profile: AbilityProfile): Promise<void>;
  findByUserId(userId: string): Promise<AbilityProfile | null>;
  delete(userId: string): Promise<void>;
  // 缺少 initialize()
}
```

**修复建议**: 添加 `initialize()` 方法到接口定义

---

### [高-2] 用例中未使用领域错误类

**位置**: 
- `src/application/use-cases/CompleteStep.ts`
- `src/application/use-cases/StartLearningSession.ts`

**问题**: 使用通用 `Error` 而非 `DomainError` 子类

**当前代码**:
```typescript
if (!session) {
  throw new Error(`会话 ${sessionId} 不存在`);  // 应使用 SessionError
}
```

**修复建议**:
```typescript
import { SessionError } from '../../domain/errors';

if (!session) {
  throw new SessionError(`会话 ${sessionId} 不存在`);
}
```

---

## 中优先级问题

### [中-1] 能力标签映射重复

**位置**: 
- `src/application/use-cases/GetAbilityProfile.ts` (行41-50)
- `src/hooks/useAbilityProfile.ts` (行56-79)
- `src/pages/Home.tsx` (行40-49)

**问题**: 相同的能力标签映射逻辑在多处重复实现

**当前代码**:
```typescript
// GetAbilityProfile.ts
private getAbilityLabel(ability: string): string {
  const labels: Record<string, string> = {
    'number-shape-integration': '数形结合',
    ...
  };
}

// useAbilityProfile.ts
const getAbilityName = useCallback((ability: string): string => {
  const labels: Record<string, string> = {
    'number-shape-integration': '数形结合',
    ...
  };
});

// Home.tsx
const getAbilityLabel = (ability: string): string => {
  const labels: Record<string, string> = {
    [Ability.NUMBER_SHAPE_INTEGRATION]: '数形结合',
    ...
  };
};
```

**修复建议**: 
1. 创建 `src/shared/ability-labels.ts` 统一管理
2. 或使用现有的 `src/i18n/zh-CN.ts`

```typescript
// src/shared/ability-labels.ts
import { Ability } from '../domain/types/ability';

export const ABILITY_LABELS: Record<Ability, string> = {
  [Ability.NUMBER_SHAPE_INTEGRATION]: '数形结合',
  [Ability.UNIT_UNIFICATION]: '单位统一',
  [Ability.WHOLE_PART_THINKING]: '整体部分思想',
  [Ability.TRANSFORMATION]: '转化化归思想',
  [Ability.EQUATION_REASONING]: '等量关系与方程',
};
```

---

### [中-2] Zod Schema 未被使用

**位置**: `src/content/schema.ts`

**问题**: 定义了 `LearningStepSchema` 和 `KnowledgePointSchema`，但内容加载时未进行验证

**当前代码**:
```typescript
// schema.ts 已定义
export const LearningStepSchema = z.object({ ... });

// 但在 FileSystemContentRepository 中未使用
export class FileSystemContentRepository implements ContentRepository {
  async findSteps(knowledgePointId: string): Promise<LearningStep[]> {
    // 直接返回，未验证
    return steps as LearningStep[];
  }
}
```

**修复建议**:
```typescript
import { validateLearningStep } from '../../content/schema';

async findSteps(knowledgePointId: string): Promise<LearningStep[]> {
  const steps = await this.loadSteps(knowledgePointId);
  return steps.map(step => validateLearningStep(step));
}
```

---

### [中-3] visualConfig 类型过于宽泛

**位置**: `src/components/steps/ConcreteStep.tsx` (行73-78)

**问题**: 使用 `Record<string, unknown>` 导致类型安全丢失

**当前代码**:
```typescript
const visualConfig = (content.interaction.visualConfig ?? {}) as {
  circles?: Array<{ denominator: number; highlighted: number[] }>;
};
```

**修复建议**: 在 domain 类型中正确定义

```typescript
// domain/types/learning-step.ts
export interface ConcreteVisualConfig {
  circles?: Array<{
    denominator: number;
    highlighted: number[];
  }>;
}

export interface ConcreteContent {
  type: 'concrete';
  scenario: { ... };
  interaction: {
    kind: 'drag' | 'tap' | 'draw' | 'split' | 'select';
    target: string;
    visualType: string;
    visualConfig: ConcreteVisualConfig;  // 具体类型
  };
}
```

---

### [中-4] DexieRepository 中 Evidence 未关联 sessionId

**位置**: `src/platform/web/DexieRepository.ts` (行73-74)

**问题**: `saveEvidence` 方法接收 sessionId 但未使用

**当前代码**:
```typescript
async saveEvidence(_sessionId: string, evidence: LearningEvidence): Promise<void> {
  // _sessionId 未被使用
  await db.evidence.put(evidence);
}
```

**修复建议**:
```typescript
async saveEvidence(sessionId: string, evidence: LearningEvidence): Promise<void> {
  const storedEvidence: StoredLearningEvidence = {
    ...evidence,
    sessionId,
  };
  await db.evidence.put(storedEvidence);
}
```

---

### [中-5] findByUserId 实现与接口不符

**位置**: `src/platform/web/DexieRepository.ts` (行54-58)

**问题**: 方法接收 userId 参数但未使用，直接返回所有会话

**当前代码**:
```typescript
async findByUserId(_userId: string): Promise<LearningSession[]> {
  // 由于 LearningSession 结构中没有 userId 字段，这里返回所有会话
  return db.sessions.toArray();
}
```

**修复建议**: 配合 [阻断-1] 添加 userId 后实现正确的过滤

---

## 低优先级问题

### [低-1] Platform 实例在 Hook 外创建

**位置**: `src/hooks/useLearningSession.ts` (行7-13)

**问题**: platform 实例在 hook 外部创建，可能导致状态问题

**当前代码**:
```typescript
const platform = createWebPlatform();  // Hook 外创建
const sessionService = new LearningSessionService();
const startLearningSession = new StartLearningSession(...);

export function useLearningSession() {
  // 使用外部实例
}
```

**修复建议**: 
- 方案1: 使用 React Context 提供 platform
- 方案2: 保持现状但在文档中说明

---

### [低-2] 能力等级标签重复

**位置**: 
- `src/application/use-cases/GetAbilityProfile.ts`
- `src/hooks/useAbilityProfile.ts`

**问题**: 能力等级标签映射重复

**当前代码**:
```typescript
// GetAbilityProfile.ts
private getAbilityLabel(state: AbilityState): string {
  const labels: Record<Ability, string> = { ... };
}

// useAbilityProfile.ts
const getLevelLabel = useCallback((level: number): string => {
  const labels: Record<number, string> = {
    0: '未开始', 1: '初步认识', ...
  };
});
```

**修复建议**: 统一使用 `src/i18n/zh-CN.ts`

---

### [低-3] 缺少单元测试

**位置**: `src/domain/services/` 目录

**问题**: 领域服务有良好的可测试性但缺少测试

**建议**: 添加以下测试
- `AbilityProfileService.test.ts`
- `LearningSessionService.test.ts`

---

### [低-4] 硬编码用户ID

**位置**: 多处

**问题**: 使用硬编码的 `'default-user'`

**当前代码**:
```typescript
async execute(userId: string = 'default-user'): Promise<ProfileResult> {
  // ...
}
```

**建议**: 从认证上下文获取真实用户ID

---

## 问题统计

| 严重程度 | 数量 |
|----------|------|
| 阻断 | 1 |
| 高 | 2 |
| 中 | 5 |
| 低 | 4 |
| **总计** | **12** |

---

## 修复优先级建议

1. **立即修复**: [阻断-1], [高-1]
2. **本周修复**: [高-2], [中-1], [中-2], [中-4], [中-5]
3. **计划修复**: [中-3]
4. **可选优化**: [低-1], [低-2], [低-3], [低-4]
