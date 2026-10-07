# 数学学习软件 - 项目规格说明

> 版本：v1.0.0
> 创建日期：2026-10-06
> 状态：开发中

## 1. 项目概述

### 1.1 产品定位

数学思维启发型学习系统，帮助小学到初中学生形成数学思维能力，通过数形结合等方式深度理解数学概念。

### 1.2 核心目标

- 从具体现象中发现数量、空间和变化关系
- 使用多种方式表示同一问题
- 通过猜想和验证形成概念
- 将数学思想迁移到新情境

### 1.3 第一阶段范围

**数学思想**：数形结合

**学习单元**：分数大小比较

**学习流程**：情境观察 → 图形操作 → 数量比较 → 提出猜想 → 验证猜想 → 符号表达 → 新情境迁移 → 反思

## 2. 技术架构

### 2.1 技术栈

| 层级 | 技术 |
|------|------|
| 前端框架 | React 18 + TypeScript |
| 构建工具 | Vite 5 |
| 桌面/移动 | Tauri 2 |
| 状态管理 | Zustand |
| 本地存储（Web） | Dexie (IndexedDB) |
| 本地存储（原生） | SQLite (tauri-plugin-sql) |
| 路由 | React Router 6 |
| 内容校验 | Zod |

### 2.2 目录结构

```
math-learning-app/
├── src/
│   ├── domain/                 # 领域层（纯TypeScript）
│   │   ├── types/            # 核心类型定义
│   │   ├── services/          # 领域服务
│   │   └── errors/            # 领域错误
│   ├── application/            # 应用层
│   │   ├── ports/             # Repository接口
│   │   └── use-cases/         # 用例
│   ├── platform/               # 平台适配层
│   │   ├── tauri/             # Tauri实现
│   │   └── web/               # Web实现
│   ├── stores/                 # Zustand状态
│   ├── hooks/                  # React Hooks
│   ├── components/             # React组件
│   │   ├── ui/               # 基础UI
│   │   ├── steps/            # 步骤组件
│   │   ├── visuals/          # 可视化组件
│   │   └── layout/           # 布局组件
│   ├── pages/                 # 页面组件
│   ├── content/               # 学习内容JSON
│   ├── engine/                # 交互引擎
│   ├── router/                # 路由配置
│   └── styles/                 # 样式
├── src-tauri/                  # Tauri原生配置
└── public/                     # 静态资源
```

### 2.3 领域模型

**核心实体**
- `LearningSession` - 学习会话
- `LearningEvidence` - 学习证据
- `AbilityProfile` - 能力画像

**枚举**
- `SessionStatus` - 会话状态
- `EvidenceType` - 证据类型
- `StepType` - 步骤类型
- `Ability` - 数学思想
- `AbilityLevel` - 能力等级

### 2.4 平台适配

通过 Repository 接口抽象存储差异：
- **Web端**：Dexie + IndexedDB
- **Tauri端**：SQLite（待实现）

## 3. 功能清单

### 3.1 已实现功能

| 功能 | 状态 |
|------|------|
| 首页展示数学思想 | ✅ |
| 点击进入学习页面 | ✅ |
| 显示分数面积图可视化 | ✅ |
| 可交互的分割圆组件 | ✅ |
| 步骤反馈系统 | ✅ |
| 提示系统 | ✅ |
| 学习进度显示 | ✅ |
| 学习完成页面 | ✅ |
| 会话状态管理 | ✅ |
| 证据记录 | ✅ |
| 能力画像计算 | ✅ |

### 3.2 待实现功能

| 功能 | 优先级 |
|------|--------|
| 多个学习步骤 | P0 |
| 猜想与验证步骤 | P0 |
| 符号表示步骤 | P0 |
| 迁移应用步骤 | ✅ |
| Tauri SQLite存储 | P1 |
| 能力报告页面 | P1 |
| 数据持久化 | P1 |
| Android构建 | P2 |

## 4. 交互设计

### 4.1 页面路由

| 路径 | 页面 | 说明 |
|------|------|------|
| `/` | HomePage | 首页，显示数学思想选择 |
| `/learn/:kpId` | LearnPage | 学习页面，显示步骤和可视化 |
| `/profile` | ProfilePage | 能力报告（待实现） |

### 4.2 会话状态机

```
NOT_STARTED → IN_PROGRESS → PAUSED
                        → COMPLETED
                        → ABANDONED
```

### 4.3 步骤类型

| 类型 | 说明 |
|------|------|
| concrete | 具象操作（分割图形、拖拽） |
| pictorial | 图示表达 |
| symbolic | 符号表示 |
| conjecture | 猜想 |
| verification | 验证 |
| application | 迁移应用 |

## 5. 运行命令

```bash
# 安装依赖
npm install

# Web开发
npm run dev

# 类型检查
npm run typecheck

# 构建生产版本
npm run build

# Tauri桌面开发（需Rust）
npm run tauri:dev

# Tauri生产构建（需Rust）
npm run tauri:build
```

## 6. 验收标准

### 6.1 功能验收

- [ ] 首页显示"数形结合"思想卡片
- [ ] 点击卡片进入学习页面
- [ ] 显示分蛋糕情境和分割圆可视化
- [ ] 点击扇形可以高亮显示
- [ ] 点击"完成"按钮进入下一步或完成页

### 6.2 技术验收

- [ ] TypeScript类型检查通过
- [ ] Web端npm run dev正常运行
- [ ] 生产构建成功
- [ ] 领域层无框架依赖

## 7. 扩展计划

### V1 - 数学思想最小闭环
- [x] 项目架构
- [x] 分数大小比较单元
- [ ] 更多步骤类型
- [ ] 数据持久化

### V2 - 能力画像
- [ ] 能力报告页面
- [ ] 历史记录
- [ ] 复习任务生成

### V3 - 多平台
- [ ] Tauri桌面端
- [ ] Android构建
- [ ] 云端同步

---

*最后更新：2026-10-06*
