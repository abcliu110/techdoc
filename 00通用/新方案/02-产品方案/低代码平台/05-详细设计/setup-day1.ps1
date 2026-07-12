# Phase 1 - Day 1 自动化安装脚本 (Windows PowerShell版)
# 用途：一键完成Monorepo工程搭建
# 执行方式：.\setup-day1.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Form Designer - Phase 1 Day 1 Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查Node.js
Write-Host "🔍 检查环境..." -ForegroundColor Yellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js 未安装，请先安装 Node.js" -ForegroundColor Red
    exit 1
}

# 检查pnpm
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ pnpm 未安装，正在安装..." -ForegroundColor Yellow
    npm install -g pnpm
}

Write-Host "✅ 环境检查通过" -ForegroundColor Green
Write-Host ""

# 设置工作目录（选择一个合适的位置）
$projectRoot = "D:\projects\form-designer"
Write-Host "📁 项目将创建在: $projectRoot" -ForegroundColor Cyan

# Step 1: 创建项目目录
Write-Host "📁 Step 1: 创建项目目录..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
Set-Location $projectRoot

# Step 2: 创建workspace配置
Write-Host "📦 Step 2: 初始化workspace..." -ForegroundColor Yellow
@"
packages:
  - 'packages/*'
"@ | Out-File -FilePath "pnpm-workspace.yaml" -Encoding UTF8

@"
{
  "name": "form-designer",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding UTF8

Write-Host "✅ Workspace配置完成" -ForegroundColor Green
Write-Host ""

# Step 3: 创建目录结构
Write-Host "📂 Step 3: 创建packages目录结构..." -ForegroundColor Yellow
$dirs = @(
    "packages\core\src\types",
    "packages\core\src\models",
    "packages\shared\src\utils",
    "packages\renderer\src",
    "packages\designer\src",
    "packages\components\src"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host "✅ 目录结构创建完成" -ForegroundColor Green
Write-Host ""

# Step 4: 创建package.json文件
Write-Host "📝 Step 4: 初始化各个package..." -ForegroundColor Yellow

# core
@"
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
"@ | Out-File -FilePath "packages\core\package.json" -Encoding UTF8

# shared
@"
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
"@ | Out-File -FilePath "packages\shared\package.json" -Encoding UTF8

Write-Host "✅ Package配置完成" -ForegroundColor Green
Write-Host ""

# Step 5: 安装依赖
Write-Host "📦 Step 5: 安装依赖（可能需要几分钟）..." -ForegroundColor Yellow
Write-Host "   这可能需要一些时间，请耐心等待..." -ForegroundColor Gray

pnpm add -D -w typescript@^5.0.0 vite@^4.0.0 vitest@^0.34.0 @types/node
pnpm add -w mobx@^6.10.0 mobx-react-lite@^4.0.0
pnpm add -w react@^18.2.0 react-dom@^18.2.0
pnpm add -D -w @types/react @types/react-dom

Write-Host "✅ 依赖安装完成" -ForegroundColor Green
Write-Host ""

# Step 6: 创建TypeScript配置
Write-Host "⚙️  Step 6: 创建TypeScript配置..." -ForegroundColor Yellow
@"
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
      "@form-designer/shared": ["./packages/shared/src"]
    }
  },
  "include": ["packages/*/src"],
  "exclude": ["node_modules", "dist"]
}
"@ | Out-File -FilePath "tsconfig.json" -Encoding UTF8

Write-Host "✅ TypeScript配置完成" -ForegroundColor Green
Write-Host ""

# Step 7: 创建核心类型定义
Write-Host "📝 Step 7: 创建核心类型定义..." -ForegroundColor Yellow

# BO类型 (简化版，完整版见文档)
@"
/**
 * 业务对象定义
 */
export interface BusinessObject {
  boId: string;
  boName: string;
  boType: 'entity' | 'view';
  version: string;

  fields: BOField[];
  relations: BORelation[];
}

export interface BOField {
  fieldId: string;
  fieldName: string;
  fieldType: 'string' | 'number' | 'date' | 'boolean';
  required: boolean;
  defaultValue?: any;
}

export interface BORelation {
  relationId: string;
  relationType: 'one-to-one' | 'one-to-many' | 'many-to-many';
  sourceBO: string;
  targetBO: string;
}
"@ | Out-File -FilePath "packages\core\src\types\bo.ts" -Encoding UTF8

# Form类型
@"
/**
 * 表单定义
 */
export interface FormDefinition {
  formId: string;
  formName: string;
  boId: string;
  formType: 'create' | 'edit' | 'view';
  fields: FormField[];
}

export interface FormField {
  fieldId: string;
  boField: string;
  componentType: string;
  label?: string;
}
"@ | Out-File -FilePath "packages\core\src\types\form.ts" -Encoding UTF8

# 索引
@"
export * from './bo';
export * from './form';
"@ | Out-File -FilePath "packages\core\src\types\index.ts" -Encoding UTF8

@"
export * from './types';
"@ | Out-File -FilePath "packages\core\src\index.ts" -Encoding UTF8

Write-Host "✅ 核心类型定义完成" -ForegroundColor Green
Write-Host ""

# Step 8: 创建.gitignore
Write-Host "📄 Step 8: 创建Git配置..." -ForegroundColor Yellow
@"
node_modules/
dist/
.DS_Store
*.log
.env
coverage/
.vscode/
.idea/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# README
@"
# Form Designer

Web表单设计器 - MVVM + 元数据驱动架构

## Phase 1 - 核心架构（Week 1-4）

- [x] Day 1: Monorepo工程搭建 ✅
- [ ] Day 2: 路径系统实现
- [ ] Day 3-4: Field Model实现

## 开发

``````bash
# 安装依赖
pnpm install

# 构建
pnpm build
``````
"@ | Out-File -FilePath "README.md" -Encoding UTF8

Write-Host "✅ Git配置完成" -ForegroundColor Green
Write-Host ""

# Step 9: 初始化Git
Write-Host "🔧 Step 9: 初始化Git仓库..." -ForegroundColor Yellow
git init
git add .
git commit -m "chore: 初始化Monorepo工程结构 - Phase 1 Day 1"

Write-Host "✅ Git仓库初始化完成" -ForegroundColor Green
Write-Host ""

# 完成
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ Day 1 Setup 完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 完成情况：" -ForegroundColor Yellow
Write-Host "  ✓ Monorepo工程结构" -ForegroundColor Green
Write-Host "  ✓ 5个packages" -ForegroundColor Green
Write-Host "  ✓ TypeScript配置" -ForegroundColor Green
Write-Host "  ✓ 依赖安装" -ForegroundColor Green
Write-Host "  ✓ 核心类型定义" -ForegroundColor Green
Write-Host "  ✓ Git初始化" -ForegroundColor Green
Write-Host ""
Write-Host "📂 项目位置：" -ForegroundColor Yellow
Write-Host "  $projectRoot" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 下一步：" -ForegroundColor Yellow
Write-Host "  1. cd $projectRoot" -ForegroundColor White
Write-Host "  2. code .  (用VS Code打开项目)" -ForegroundColor White
Write-Host ""
Write-Host "💡 明天任务：" -ForegroundColor Yellow
Write-Host "  Day 2: 实现路径系统" -ForegroundColor White
Write-Host ""
