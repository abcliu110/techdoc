# @lowcode/form-core

表单设计器核心层 - MVVM架构 + 元数据驱动

## 功能

- ✅ BO（Business Object）定义
- ✅ Form（表单）定义
- ✅ Field Model（字段模型，MVVM）
- ✅ Form Model（表单模型，MVVM）
- 🚧 表达式引擎（开发中）
- 🚧 校验引擎（开发中）

## 使用

```typescript
import { BusinessObject, FormDefinition } from '@lowcode/form-core';

const userBO: BusinessObject = {
  boId: 'user',
  boName: '用户',
  // ...
};

const userForm: FormDefinition = {
  formId: 'user_form',
  formName: '用户表单',
  boId: 'user',
  // ...
};
```

## Phase 1 进度

- [x] Day 1: 类型定义 ✅
- [ ] Day 2: Field Model实现
- [ ] Day 3: Form Model实现
- [ ] Day 4: 路径系统
- [ ] Day 5: 单元测试
