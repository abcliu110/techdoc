#!/bin/bash

# Phase 1 - Day 1 自动化安装脚本
# 用途：一键完成Monorepo工程搭建
# 执行方式：bash setup-day1.sh

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  Form Designer - Phase 1 Day 1 Setup"
echo "=========================================="
echo ""

# 检查必要工具
echo "🔍 检查环境..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm 未安装，正在安装..."
    npm install -g pnpm
fi

echo "✅ 环境检查通过"
echo ""

# Step 1: 创建项目目录
echo "📁 Step 1: 创建项目目录..."
mkdir -p form-designer
cd form-designer

# Step 2: 初始化pnpm workspace
echo "📦 Step 2: 初始化workspace..."
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
EOF

cat > package.json << 'EOF'
{
  "name": "form-designer",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "eslint packages --ext .ts,.tsx"
  }
}
EOF

echo "✅ Workspace配置完成"
echo ""

# Step 3: 创建目录结构
echo "📂 Step 3: 创建packages目录结构..."
mkdir -p packages/core/src/types
mkdir -p packages/core/src/models
mkdir -p packages/shared/src/utils
mkdir -p packages/renderer/src
mkdir -p packages/designer/src
mkdir -p packages/components/src

echo "✅ 目录结构创建完成"
echo ""

# Step 4: 初始化各个package
echo "📝 Step 4: 初始化各个package..."

# core
cat > packages/core/package.json << 'EOF'
{
  "name": "@form-designer/core",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  }
}
EOF

# shared
cat > packages/shared/package.json << 'EOF'
{
  "name": "@form-designer/shared",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  }
}
EOF

# renderer
cat > packages/renderer/package.json << 'EOF'
{
  "name": "@form-designer/renderer",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  }
}
EOF

# designer
cat > packages/designer/package.json << 'EOF'
{
  "name": "@form-designer/designer",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "vite"
  }
}
EOF

# components
cat > packages/components/package.json << 'EOF'
{
  "name": "@form-designer/components",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  }
}
EOF

echo "✅ Package配置完成"
echo ""

# Step 5: 安装依赖
echo "📦 Step 5: 安装依赖（可能需要几分钟）..."
pnpm add -D -w typescript@^5.0.0 vite@^4.0.0 vitest@^0.34.0 @types/node
pnpm add -D -w @typescript-eslint/eslint-plugin @typescript-eslint/parser
pnpm add -D -w prettier eslint

# 安装MobX
pnpm add -w mobx@^6.10.0 mobx-react-lite@^4.0.0

# 安装React
pnpm add -w react@^18.2.0 react-dom@^18.2.0
pnpm add -D -w @types/react @types/react-dom

echo "✅ 依赖安装完成"
echo ""

# Step 6: 创建TypeScript配置
echo "⚙️  Step 6: 创建TypeScript配置..."
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
    "experimentalDecorators": true,
    "useDefineForClassFields": true,
    "paths": {
      "@form-designer/core": ["./packages/core/src"],
      "@form-designer/shared": ["./packages/shared/src"],
      "@form-designer/renderer": ["./packages/renderer/src"],
      "@form-designer/designer": ["./packages/designer/src"],
      "@form-designer/components": ["./packages/components/src"]
    }
  },
  "include": ["packages/*/src"],
  "exclude": ["node_modules", "dist"]
}
EOF

# 为每个package创建tsconfig
for pkg in core shared renderer designer components; do
  cat > packages/$pkg/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}
EOF
done

echo "✅ TypeScript配置完成"
echo ""

# Step 7: 创建核心类型定义
echo "📝 Step 7: 创建核心类型定义..."

# BO类型
cat > packages/core/src/types/bo.ts << 'EOF'
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
EOF

# Form类型
cat > packages/core/src/types/form.ts << 'EOF'
import { ValidationRule } from './bo';

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
EOF

# 导出索引
cat > packages/core/src/types/index.ts << 'EOF'
export * from './bo';
export * from './form';
EOF

cat > packages/core/src/index.ts << 'EOF'
export * from './types';
EOF

echo "✅ 核心类型定义完成"
echo ""

# Step 8: 创建.gitignore
echo "📄 Step 8: 创建Git配置..."
cat > .gitignore << 'EOF'
node_modules/
dist/
.DS_Store
*.log
.env
.env.local
coverage/
.vscode/
.idea/
*.tsbuildinfo
EOF

# Step 9: 创建README
cat > README.md << 'EOF'
# Form Designer

Web表单设计器 - MVVM + 元数据驱动架构

## 项目结构

```
form-designer/
├── packages/
│   ├── core/          # 核心层（BO、Form定义、Model）
│   ├── shared/        # 共享工具（路径系统等）
│   ├── renderer/      # 渲染器（表单运行时）
│   ├── designer/      # 设计器（可视化编辑）
│   └── components/    # 组件库
├── pnpm-workspace.yaml
└── package.json
```

## 开发

```bash
# 安装依赖
pnpm install

# 构建所有包
pnpm build

# 运行测试
pnpm test
```

## Phase 1 - 核心架构（Week 1-4）

- [x] Day 1: Monorepo工程搭建 ✅
- [ ] Day 2: 路径系统实现
- [ ] Day 3-4: Field Model实现
- [ ] Day 5: Form Model实现

## 文档

详细文档见：`D:\mywork\techdoc\00业务文档\系统设计\新方案\02-产品方案\低代码平台\05-详细设计\`
EOF

echo "✅ Git配置完成"
echo ""

# Step 10: 初始化Git
echo "🔧 Step 10: 初始化Git仓库..."
git init
git add .
git commit -m "chore: 初始化Monorepo工程结构

Phase 1 Day 1 完成：
- Monorepo workspace配置
- 5个packages目录结构
- TypeScript配置
- 依赖安装（MobX, React, TypeScript等）
- 核心类型定义（BO, Form）
- Git配置

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
"

echo "✅ Git仓库初始化完成"
echo ""

# 完成
echo "=========================================="
echo "  ✅ Day 1 Setup 完成！"
echo "=========================================="
echo ""
echo "📊 完成情况："
echo "  ✓ Monorepo工程结构"
echo "  ✓ 5个packages"
echo "  ✓ TypeScript配置"
echo "  ✓ 依赖安装"
echo "  ✓ 核心类型定义"
echo "  ✓ Git初始化"
echo ""
echo "📂 项目位置："
echo "  $(pwd)"
echo ""
echo "🚀 下一步："
echo "  1. cd form-designer"
echo "  2. code .  (用VS Code打开项目)"
echo "  3. 查看 README.md"
echo ""
echo "💡 明天任务："
echo "  Day 2: 实现路径系统（getIn/setIn/deleteIn/hasIn）"
echo ""
