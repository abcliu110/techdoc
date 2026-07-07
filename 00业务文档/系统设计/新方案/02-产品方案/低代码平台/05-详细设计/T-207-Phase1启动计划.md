# Phase 1 启动计划 - 核心架构开发

> 基于：T-207完整架构设计v1.0  
> 启动日期：2026-07-07  
> 工期：4周（Week 1-4）  
> 状态：🚀 立即启动  

---

## 执行摘要

Phase 1是整个项目的基础，目标是建立**MVVM架构基础**，包括BO/Form定义层、Field/Form Model、路径系统和MobX集成。

### 关键目标

✅ Monorepo工程搭建  
✅ BO定义层实现  
✅ Form定义层实现  
✅ Field Model实现  
✅ Form Model实现  
✅ 路径系统实现  
✅ MobX响应式集成  
✅ 单元测试（覆盖率>80%）  

---

## 一、立即行动（今天/明天）

### Day 1: 工程初始化（今天）

#### 任务1.1: 创建Monorepo工程结构

```bash
# 1. 创建项目根目录
mkdir form-designer
cd form-designer

# 2. 初始化pnpm workspace
pnpm init

# 3. 创建workspace配置
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
EOF

# 4. 创建packages目录结构
mkdir -p packages/core
mkdir -p packages/shared
mkdir -p packages/renderer
mkdir -p packages/designer
mkdir -p packages/components

# 5. 初始化各个package
cd packages/core && pnpm init && cd ../..
cd packages/shared && pnpm init && cd ../..
cd packages/renderer && pnpm init && cd ../..
cd packages/designer && pnpm init && cd ../..
cd packages/components && pnpm init && cd ../..

# 6. 安装根依赖
pnpm add -D -w typescript vite vitest @types/node
pnpm add -D -w @typescript-eslint/eslint-plugin @typescript-eslint/parser
pnpm add -D -w prettier eslint

# 7. 创建TypeScript配置
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "paths": {
      "@form-designer/*": ["./packages/*/src"]
    }
  }
}
EOF

# 8. 创建.gitignore
cat > .gitignore << 'EOF'
node_modules/
dist/
.DS_Store
*.log
.env
coverage/
EOF

# 9. 初始化Git
git init
git add .
git commit -m "chore: 初始化Monorepo工程结构"
```

**预计时间**：2小时  
**负责人**：架构师  
**产出**：工程骨架

---

#### 任务1.2: 定义核心类型（今天下午）

```typescript
// packages/core/src/types/bo.ts

/**
 * 业务对象定义
 */
export interface BusinessObject {
  boId: string;
  boName: string;
  boType: 'entity' | 'view';
  version: string;
  
  entity: EntityDefinition;
  fields: BOField[];
  relations: BORelation[];
  rules: BusinessRule[];
  permissions?: PermissionRule[];
}

export interface BOField {
  fieldId: string;
  fieldName: string;
  fieldType: 'string' | 'number' | 'date' | 'boolean' | 'reference' | 'calculated';
  dataType: string;
  length?: number;
  precision?: number;
  required: boolean;
  unique: boolean;
  defaultValue?: any;
  formula?: string;
  refBO?: string;
  refField?: string;
  validations?: ValidationRule[];
}

export interface BORelation {
  relationId: string;
  relationType: 'one-to-one' | 'one-to-many' | 'many-to-many';
  sourceBO: string;
  targetBO: string;
  sourceField: string;
  targetField: string;
  cascadeDelete?: boolean;
}

export interface BusinessRule {
  ruleId: string;
  ruleName: string;
  ruleType: 'before-save' | 'after-save' | 'before-delete' | 'computed';
  condition?: string;
  action: string;
}

export interface EntityDefinition {
  tableName: string;
  primaryKey: string;
  displayField: string;
}

export interface ValidationRule {
  type: 'required' | 'range' | 'pattern' | 'custom';
  message: string;
  min?: number;
  max?: number;
  pattern?: string;
  validator?: (value: any, formData: any) => boolean | string;
}

export interface PermissionRule {
  roleId: string;
  permissions: ('read' | 'write' | 'delete')[];
}
```

```typescript
// packages/core/src/types/form.ts

/**
 * 表单定义
 */
export interface FormDefinition {
  formId: string;
  formName: string;
  boId: string;
  formType: 'create' | 'edit' | 'view' | 'query';
  version: string;
  
  layout: FormLayout;
  fields: FormField[];
  toolbar?: ToolbarConfig;
  permissions?: FormPermission;
}

export interface FormField {
  fieldId: string;
  boField: string;
  componentType: string;
  
  label?: string;
  placeholder?: string;
  helpText?: string;
  
  componentProps?: Record<string, any>;
  
  visible?: boolean | string;
  disabled?: boolean | string;
  readonly?: boolean | string;
  
  validations?: ValidationRule[];
  reactions?: Reaction[];
}

export interface FormLayout {
  type: 'horizontal' | 'vertical' | 'inline' | 'grid';
  columns?: number;
  gutter?: number;
  labelAlign?: 'left' | 'right';
  labelCol?: { span: number };
  wrapperCol?: { span: number };
}

export interface Reaction {
  condition?: string;
  target: string;
  action: 'set-value' | 'set-visible' | 'set-disabled' | 'set-options';
  value?: any;
}

export interface ToolbarConfig {
  buttons: ToolbarButton[];
}

export interface ToolbarButton {
  id: string;
  label: string;
  type: 'primary' | 'default' | 'dashed' | 'link';
  action: string;
  visible?: string;
}

export interface FormPermission {
  roleId: string;
  fieldPermissions: Record<string, 'readonly' | 'hidden'>;
}
```

**预计时间**：3小时  
**负责人**：架构师  
**产出**：核心类型定义

---

### Day 2: 路径系统实现（明天）

```typescript
// packages/shared/src/utils/path.ts

export function getIn(obj: any, path: string | string[], defaultValue?: any): any {
  if (!obj) return defaultValue;
  
  const pathArray = Array.isArray(path) ? path : parsePath(path);
  
  let current = obj;
  for (const key of pathArray) {
    if (current === null || current === undefined) {
      return defaultValue;
    }
    current = current[key];
  }
  
  return current !== undefined ? current : defaultValue;
}

export function setIn(obj: any, path: string | string[], value: any): void {
  if (!obj) return;
  
  const pathArray = Array.isArray(path) ? path : parsePath(path);
  const lastKey = pathArray[pathArray.length - 1];
  
  let current = obj;
  for (let i = 0; i < pathArray.length - 1; i++) {
    const key = pathArray[i];
    const nextKey = pathArray[i + 1];
    
    if (!(key in current)) {
      current[key] = /^\d+$/.test(nextKey) ? [] : {};
    }
    
    current = current[key];
  }
  
  current[lastKey] = value;
}

export function deleteIn(obj: any, path: string | string[]): void {
  if (!obj) return;
  
  const pathArray = Array.isArray(path) ? path : parsePath(path);
  const lastKey = pathArray[pathArray.length - 1];
  
  let current = obj;
  for (let i = 0; i < pathArray.length - 1; i++) {
    if (!(pathArray[i] in current)) return;
    current = current[pathArray[i]];
  }
  
  if (Array.isArray(current)) {
    current.splice(Number(lastKey), 1);
  } else {
    delete current[lastKey];
  }
}

export function hasIn(obj: any, path: string | string[]): boolean {
  if (!obj) return false;
  
  const pathArray = Array.isArray(path) ? path : parsePath(path);
  
  let current = obj;
  for (const key of pathArray) {
    if (current === null || current === undefined || !(key in current)) {
      return false;
    }
    current = current[key];
  }
  
  return true;
}

function parsePath(path: string): string[] {
  return path
    .replace(/\[(\d+)\]/g, '.$1')
    .split('.')
    .filter(Boolean);
}
```

```typescript
// packages/shared/src/utils/path.test.ts

import { describe, it, expect } from 'vitest';
import { getIn, setIn, deleteIn, hasIn } from './path';

describe('Path Utils', () => {
  describe('getIn', () => {
    it('should get nested object value', () => {
      const obj = { user: { address: { city: 'Beijing' } } };
      expect(getIn(obj, 'user.address.city')).toBe('Beijing');
    });
    
    it('should get array element', () => {
      const obj = { items: [{ name: 'A' }, { name: 'B' }] };
      expect(getIn(obj, 'items[1].name')).toBe('B');
    });
    
    it('should return default value for non-existent path', () => {
      const obj = { user: {} };
      expect(getIn(obj, 'user.address.city', 'Unknown')).toBe('Unknown');
    });
  });
  
  // ... 更多测试
});
```

**预计时间**：4小时  
**负责人**：核心工程师2  
**产出**：路径系统 + 单元测试

---

## 二、Week 1 详细计划

### Day 1-2: 工程搭建 + 路径系统
- ✅ Monorepo工程结构
- ✅ 核心类型定义
- ✅ 路径系统实现

### Day 3-4: Field Model实现

```typescript
// packages/core/src/models/FieldModel.ts

import { makeObservable, observable, action, computed } from 'mobx';

export class FieldModel {
  fieldId: string;
  boFieldId: string;
  
  @observable value: any;
  @observable initialValue: any;
  @observable errors: string[] = [];
  
  @observable visible: boolean = true;
  @observable disabled: boolean = false;
  @observable readonly: boolean = false;
  @observable touched: boolean = false;
  
  definition: FormField;
  boField: BOField;
  formModel: FormModel;
  
  constructor(definition: FormField, boField: BOField, formModel: FormModel) {
    this.fieldId = definition.fieldId;
    this.boFieldId = definition.boField;
    this.definition = definition;
    this.boField = boField;
    this.formModel = formModel;
    
    this.initialValue = boField.defaultValue;
    this.value = this.initialValue;
    
    makeObservable(this);
  }
  
  @computed
  get dirty(): boolean {
    return this.value !== this.initialValue;
  }
  
  @action
  setValue(value: any, options?: { silent?: boolean }): void {
    const oldValue = this.value;
    this.value = value;
    this.touched = true;
    
    if (!options?.silent) {
      this.formModel.eventBus.emit('field:change', {
        fieldId: this.fieldId,
        oldValue,
        newValue: value,
      });
    }
    
    this.executeReactions();
  }
  
  getValue(): any {
    return this.value;
  }
  
  @action
  async validate(): Promise<boolean> {
    this.errors = [];
    
    // BO级校验
    if (this.boField.validations) {
      for (const rule of this.boField.validations) {
        const result = await this.formModel.validatorEngine.executeRule(
          rule,
          this.value,
          this.formModel.getValues()
        );
        if (result !== true) {
          this.errors.push(result as string);
        }
      }
    }
    
    // Form级校验
    if (this.definition.validations) {
      for (const rule of this.definition.validations) {
        const result = await this.formModel.validatorEngine.executeRule(
          rule,
          this.value,
          this.formModel.getValues()
        );
        if (result !== true) {
          this.errors.push(result as string);
        }
      }
    }
    
    return this.errors.length === 0;
  }
  
  @action
  reset(): void {
    this.value = this.initialValue;
    this.errors = [];
    this.touched = false;
  }
  
  @action
  setVisible(visible: boolean): void {
    this.visible = visible;
  }
  
  @action
  setDisabled(disabled: boolean): void {
    this.disabled = disabled;
  }
  
  private executeReactions(): void {
    // 执行联动规则
    // TODO: 实现
  }
}
```

**预计时间**：2天  
**负责人**：核心工程师1

### Day 5: Form Model实现（基础版）

```typescript
// packages/core/src/models/FormModel.ts

import { makeObservable, observable, action, computed } from 'mobx';
import { EventEmitter } from 'events';

export class FormModel {
  formId: string;
  boId: string;
  
  @observable fields: Map<string, FieldModel> = new Map();
  
  eventBus: EventEmitter;
  validatorEngine: ValidatorEngine;
  expressionEngine: ExpressionEngine;
  
  constructor(definition: FormDefinition, bo: BusinessObject) {
    this.formId = definition.formId;
    this.boId = definition.boId;
    this.eventBus = new EventEmitter();
    
    // 初始化字段
    definition.fields.forEach(fieldDef => {
      const boField = bo.fields.find(f => f.fieldId === fieldDef.boField);
      if (boField) {
        const fieldModel = new FieldModel(fieldDef, boField, this);
        this.fields.set(fieldDef.fieldId, fieldModel);
      }
    });
    
    makeObservable(this);
  }
  
  getField(path: string): FieldModel | undefined {
    return this.fields.get(path);
  }
  
  @action
  setFieldValue(path: string, value: any): void {
    const field = this.getField(path);
    if (field) {
      field.setValue(value);
    }
  }
  
  getValues(): any {
    const values = {};
    this.fields.forEach((field, path) => {
      setIn(values, path, field.getValue());
    });
    return values;
  }
  
  @action
  setValues(values: any): void {
    this.fields.forEach((field, path) => {
      const value = getIn(values, path);
      if (value !== undefined) {
        field.setValue(value, { silent: true });
      }
    });
  }
  
  async validate(): Promise<boolean> {
    const results = await Promise.all(
      Array.from(this.fields.values()).map(field => field.validate())
    );
    return results.every(r => r);
  }
  
  @action
  reset(): void {
    this.fields.forEach(field => field.reset());
  }
  
  @computed
  get isDirty(): boolean {
    return Array.from(this.fields.values()).some(f => f.dirty);
  }
}
```

**预计时间**：1天  
**负责人**：核心工程师1

---

## 三、Week 1 交付物

### 代码交付
- ✅ Monorepo工程结构
- ✅ 核心类型定义（BO、Form）
- ✅ 路径系统（getIn/setIn/deleteIn/hasIn）
- ✅ Field Model（基础版）
- ✅ Form Model（基础版）

### 测试交付
- ✅ 路径系统单元测试（覆盖率>90%）
- ✅ Field Model单元测试（覆盖率>80%）

### 文档交付
- ✅ 工程README
- ✅ 开发规范文档
- ✅ API文档（TypeDoc）

---

## 四、资源需求

### 人员
- 架构师 x 1（全职）
- 核心工程师1 x 1（全职）
- 核心工程师2 x 1（全职）

### 工具
- IDE: VS Code
- 版本控制: Git + GitHub/GitLab
- CI/CD: GitHub Actions
- 文档: TypeDoc

---

## 五、风险与应对

| 风险 | 概率 | 影响 | 应对 |
|------|------|------|------|
| MobX学习曲线 | 中 | 中 | 提前学习，技术分享 |
| TypeScript类型复杂 | 中 | 低 | 循序渐进，先实现再优化 |
| 进度延期 | 低 | 中 | 每日站会，及时调整 |

---

## 六、下周预告

### Week 2计划
- Field Model完善（计算字段、联动）
- Form Model完善（依赖追踪）
- 表达式引擎基础实现
- 校验引擎基础实现

---

**文档状态**：✅ 完成  
**执行状态**：🚀 立即启动  
**下一步**：开始Day 1任务
