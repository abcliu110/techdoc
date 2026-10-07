# 整洁性建议与重构方案

## 1. 重构建议概览

### 1.1 抽取共享代码

#### 能力标签统一化

**问题**: 能力标签映射在多处重复定义

**当前分散位置**:
```
src/application/use-cases/GetAbilityProfile.ts:41-50
src/hooks/useAbilityProfile.ts:56-79
src/pages/Home.tsx:40-49
src/i18n/zh-CN.ts:29-35
```

**重构方案**:

创建统一的标签常量文件:

```typescript
// src/shared/constants/ability.ts
import { Ability, AbilityLevel } from '../domain/types/ability';

/**
 * 能力名称映射
 */
export const ABILITY_LABELS: Record<Ability, string> = {
  [Ability.NUMBER_SHAPE_INTEGRATION]: '数形结合',
  [Ability.UNIT_UNIFICATION]: '单位统一',
  [Ability.WHOLE_PART_THINKING]: '整体部分思想',
  [Ability.TRANSFORMATION]: '转化化归思想',
  [Ability.EQUATION_REASONING]: '等量关系与方程',
};

/**
 * 能力等级标签
 */
export const ABILITY_LEVEL_LABELS: Record<AbilityLevel, string> = {
  [AbilityLevel.NOT_STARTED]: '未开始',
  [AbilityLevel.AWARE]: '初步认识',
  [AbilityLevel.DEVELOPING]: '正在发展',
  [AbilityLevel.MASTERED]: '已掌握',
};
```

**应用位置更新**:

```typescript
// GetAbilityProfile.ts
import { ABILITY_LABELS } from '../../shared/constants/ability';

// 删除 getAbilityLabel 方法，直接使用
private getAbilityLabel(ability: Ability): string {
  return ABILITY_LABELS[ability] ?? ability;
}

// useAbilityProfile.ts
import { ABILITY_LABELS, ABILITY_LEVEL_LABELS } from '../shared/constants/ability';

// 删除重复的方法，使用导入的常量

// Home.tsx
import { ABILITY_LABELS } from '../shared/constants/ability';

// 删除 getAbilityLabel 方法，使用 ABILITY_LABELS[ability as Ability]
```

---

### 1.2 Repository 接口修复

#### ProfileRepository 接口补充

**文件**: `src/application/ports/ProfileRepository.ts`

```typescript
import type { AbilityProfile } from '../../domain/types/ability-profile';

/**
 * 能力画像仓储接口
 */
export interface ProfileRepository {
  /**
   * 初始化仓储
   */
  initialize(): Promise<void>;

  /**
   * 保存能力画像
   */
  save(profile: AbilityProfile): Promise<void>;

  /**
   * 获取用户的能力画像
   */
  findByUserId(userId: string): Promise<AbilityProfile | null>;

  /**
   * 删除能力画像
   */
  delete(userId: string): Promise<void>;
}
```

---

### 1.3 类型完善

#### LearningSession 添加 userId

**文件**: `src/domain/types/learning-session.ts`

```typescript
export interface LearningSession {
  /** 会话唯一标识 */
  readonly id: string;
  /** 用户唯一标识 */
  readonly userId: string;
  /** 知识点 ID */
  readonly knowledgePointId: string;
  /** 数学思想 */
  readonly ability: Ability;
  /** 当前状态 */
  status: SessionStatus;
  /** 当前步骤索引 */
  currentStepIndex: number;
  /** 开始时间 */
  startedAt: number;
  /** 暂停时间（暂停时记录） */
  pausedAt?: number;
  /** 完成时间 */
  completedAt?: number;
  /** 已记录的证据 */
  evidence: LearningEvidence[];
  /** 暂停时的快照数据 */
  snapshot?: SessionSnapshot;
}
```

**级联更新**:

1. `LearningSessionService.createSession()` 添加 userId 参数
2. `StartLearningSession.execute()` 传入 userId
3. `DexieRepository.findByUserId()` 正确过滤

---

### 1.4 内容验证启用

#### 使用 Zod Schema 验证

**文件**: `src/platform/content/FileSystemContentRepository.ts`

```typescript
import { 
  validateKnowledgePoint, 
  validateLearningStep 
} from '../../content/schema';

export class FileSystemContentRepository implements ContentRepository {
  async findKnowledgePoint(id: string): Promise<KnowledgePointMeta | null> {
    const kp = await this.loadKnowledgePoint(id);
    if (!kp) return null;
    
    try {
      const validated = validateKnowledgePoint(kp);
      return this.toMeta(validated);
    } catch (error) {
      console.error(`知识点验证失败: ${id}`, error);
      return null;
    }
  }

  async findSteps(knowledgePointId: string): Promise<LearningStep[]> {
    const steps = await this.loadSteps(knowledgePointId);
    
    return steps.map((step, index) => {
      try {
        return validateLearningStep(step);
      } catch (error) {
        console.error(`步骤验证失败: ${knowledgePointId}[${index}]`, error);
        // 返回原始数据，但记录错误
        return step as LearningStep;
      }
    });
  }
}
```

---

### 1.5 错误处理统一

#### 用例中统一使用领域错误

**CompleteStep.ts**:
```typescript
import { SessionError, ContentError } from '../../domain/errors';

async execute(sessionId: string, stepData: Record<string, unknown>, ...): Promise<...> {
  const session = await this.sessionRepo.findById(sessionId);
  if (!session) {
    throw new SessionError(`会话 ${sessionId} 不存在`);
  }

  const steps = await this.contentRepo.findSteps(session.knowledgePointId);
  const currentStep = steps[session.currentStepIndex];
  if (!currentStep) {
    throw new ContentError(`步骤 ${session.currentStepIndex} 不存在`);
  }
  // ...
}
```

**StartLearningSession.ts**:
```typescript
import { SessionError, ContentError } from '../../domain/errors';

async execute(userId: string, knowledgePointId: string): Promise<LearningSession> {
  const kp = await this.contentRepo.findKnowledgePoint(knowledgePointId);
  if (!kp) {
    throw new ContentError(`知识点 ${knowledgePointId} 不存在`);
  }
  // ...
}
```

---

### 1.6 Hooks 重构

#### 使用 React Context 提供 Platform

**创建 Context**:

```typescript
// src/contexts/PlatformContext.tsx
import React, { createContext, useContext, useMemo } from 'react';
import { createWebPlatform, type PlatformConfig } from '../platform';

const PlatformContext = createContext<PlatformConfig | null>(null);

export function PlatformProvider({ children }: { children: React.ReactNode }) {
  const platform = useMemo(() => createWebPlatform(), []);
  
  return (
    <PlatformContext.Provider value={platform}>
      {children}
    </PlatformContext.Provider>
  );
}

export function usePlatform(): PlatformConfig {
  const context = useContext(PlatformContext);
  if (!context) {
    throw new Error('usePlatform must be used within PlatformProvider');
  }
  return context;
}
```

**更新 Hook**:

```typescript
// src/hooks/useLearningSession.ts
import { usePlatform } from '../contexts/PlatformContext';
import { LearningSessionService } from '../domain/services/LearningSessionService';
import { StartLearningSession } from '../application/use-cases/StartLearningSession';

export function useLearningSession() {
  const { sessionRepo, contentRepo } = usePlatform();
  const sessionService = useMemo(() => new LearningSessionService(), []);
  const startLearningSession = useMemo(
    () => new StartLearningSession(sessionRepo, contentRepo, sessionService),
    [sessionRepo, contentRepo, sessionService]
  );
  
  // ... rest of hook
}
```

---

## 2. 代码质量提升

### 2.1 命名一致性

| 当前 | 建议 | 说明 |
|------|------|------|
| `getAbilityLabel` | `getAbilityName` | 与 `getLevelLabel` 对应 |
| `findByUserId` | 保持 | 标准命名 |
| `contentRepo` | 保持 | 缩写清晰 |

### 2.2 注释增强

为关键领域方法添加 JSDoc:

```typescript
/**
 * 计算能力等级
 * 
 * 能力等级跃迁规则:
 * - NOT_STARTED → AWARE: 有操作证据
 * - AWARE → DEVELOPING: 有答案证据且正确率 >= 50%
 * - DEVELOPING → MASTERED: 有迁移证据且正确率 >= 80%
 * 
 * @param ability - 能力类型
 * @param evidence - 学习证据列表
 * @returns 计算后的能力状态
 */
private calculateLevel(ability: Ability, evidence: LearningEvidence[]): AbilityState {
  // ...
}
```

---

## 3. 性能优化建议

### 3.1 Memoization

**hooks/useAbilityProfile.ts**:
```typescript
const getLevelLabel = useCallback((level: number): string => {
  const labels: Record<number, string> = { ... };
  return labels[level] ?? '未知';
}, []); // 空依赖，只创建一次
```

### 3.2 避免不必要的重渲染

**Home.tsx**:
```typescript
const knowledgePoints = useMemo(() => {
  return data.map(kp => ({
    ...kp,
    abilityLabel: ABILITY_LABELS[kp.ability as Ability],
  }));
}, [data]);
```

---

## 4. 重构实施计划

### Phase 1: 阻断问题修复 (1天)
1. 添加 `LearningSession.userId`
2. 补充 `ProfileRepository.initialize()`
3. 更新所有依赖方

### Phase 2: 代码重复消除 (2天)
1. 创建 `shared/constants/ability.ts`
2. 更新所有使用能力标签的位置
3. 启用 Zod Schema 验证

### Phase 3: 错误处理统一 (1天)
1. 将所有 `new Error()` 替换为领域错误
2. 添加错误边界组件

### Phase 4: 架构优化 (可选, 3天)
1. 实现 Platform Context
2. 添加单元测试
3. 性能优化

---

## 5. 重构后预期效果

| 指标 | 重构前 | 重构后 |
|------|--------|--------|
| 重复代码率 | 约 15% | < 5% |
| 类型覆盖率 | 70% | 95% |
| Repository 接口一致性 | 不一致 | 完全一致 |
| 错误处理一致性 | 分散 | 统一 |
| 可维护性评分 | B | A |
