# 数学学习软件

基于数形结合思想的数学学习应用。

## 技术栈

- **前端框架**: React 18 + TypeScript 5.x
- **构建工具**: Vite 5.x
- **状态管理**: Zustand 4.x
- **路由**: React Router 6.x
- **持久化**: Dexie (IndexedDB) / SQLite (Tauri)
- **桌面端**: Tauri 2.x

## 项目结构

```
math-learning-app/
├── src/
│   ├── domain/           # 领域层（纯 TypeScript）
│   │   ├── types/        # 类型定义
│   │   ├── services/     # 领域服务
│   │   └── errors/       # 领域错误
│   ├── application/      # 应用层
│   │   ├── ports/        # 端口接口
│   │   └── use-cases/    # 用例
│   ├── engine/           # 交互引擎
│   │   ├── step-runtime/ # 步骤运行时
│   │   ├── validators/   # 验证器
│   │   └── math/         # 数学判定
│   ├── stores/           # Zustand 状态
│   ├── hooks/            # React Hooks
│   ├── components/       # React 组件
│   ├── pages/            # 页面
│   ├── platform/         # 平台适配
│   ├── content/          # 学习内容（JSON）
│   └── router/           # 路由
├── src-tauri/            # Tauri 原生壳
└── e2e/                  # 端到端测试
```

## 三端运行命令

### Web 端

```bash
# 安装依赖
npm install

# 开发模式
npm run dev

# 构建生产版本
npm run build

# 预览生产版本
npm run preview
```

### Tauri 桌面端

```bash
# 安装依赖
npm install

# 开发模式（需要 Rust 环境）
npm run tauri:dev

# 构建桌面应用
npm run tauri:build
```

### Android 端（通过 Tauri）

```bash
# 安装 Android SDK 和 NDK
# 配置 ANDROID_HOME 和 ANDROID_NDK_HOME 环境变量

# 开发模式
npm run tauri:dev android

# 构建 APK
npm run tauri:build android
```

## 验证步骤

1. **依赖安装**
   ```bash
   npm install
   ```
   验证：无错误输出

2. **类型检查**
   ```bash
   npm run typecheck
   ```
   验证：无 TypeScript 错误

3. **开发服务器**
   ```bash
   npm run dev
   ```
   验证：浏览器打开 http://localhost:3000 显示首页

4. **功能验证**
   - 首页显示"数学学习"标题
   - 点击"分数大小比较"卡片进入学习页面
   - 学习页面显示分割圆可视化
   - 点击扇形可以高亮显示

## 依赖列表

### 生产依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| react | ^18.3.1 | UI 框架 |
| react-dom | ^18.3.1 | DOM 渲染 |
| react-router-dom | ^6.26.0 | 路由管理 |
| zustand | ^4.5.4 | 状态管理 |
| dexie | ^4.0.7 | IndexedDB ORM |
| zod | ^3.23.8 | 数据校验 |

### 开发依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| @tauri-apps/cli | ^2.0.0 | Tauri CLI |
| @tauri-apps/api | ^2.0.0 | Tauri API |
| @tauri-apps/plugin-sql | ^2.0.0 | Tauri SQL 插件 |
| @types/react | ^18.3.3 | React 类型 |
| @types/react-dom | ^18.3.0 | React DOM 类型 |
| @vitejs/plugin-react | ^4.3.1 | Vite React 插件 |
| typescript | ^5.5.4 | TypeScript 编译器 |
| vite | ^5.4.0 | 构建工具 |

## 核心文件列表

### 领域层
- `src/domain/types/ability.ts` - 能力类型定义
- `src/domain/types/learning-session.ts` - 学习会话类型
- `src/domain/types/learning-step.ts` - 学习步骤类型
- `src/domain/types/ability-profile.ts` - 能力画像类型
- `src/domain/services/LearningSessionService.ts` - 会话服务
- `src/domain/services/AbilityProfileService.ts` - 画像服务
- `src/domain/errors/index.ts` - 领域错误

### 应用层
- `src/application/ports/SessionRepository.ts` - 会话仓储接口
- `src/application/ports/ContentRepository.ts` - 内容仓储接口
- `src/application/ports/ProfileRepository.ts` - 画像仓储接口
- `src/application/use-cases/StartLearningSession.ts` - 开始会话用例
- `src/application/use-cases/CompleteStep.ts` - 完成步骤用例
- `src/application/use-cases/RecordEvidence.ts` - 记录证据用例

### 平台适配层
- `src/platform/StorageAdapter.ts` - 存储适配器接口
- `src/platform/web/DexieRepository.ts` - Web 端实现
- `src/platform/tauri/SqliteRepository.ts` - Tauri 端实现

### 组件层
- `src/components/ui/Button.tsx` - 按钮组件
- `src/components/ui/Card.tsx` - 卡片组件
- `src/components/ui/ProgressBar.tsx` - 进度条组件
- `src/components/visuals/SplitCircle.tsx` - 分割圆可视化
- `src/components/steps/StepContainer.tsx` - 步骤容器
- `src/components/steps/ConcreteStep.tsx` - 具象操作步骤
- `src/components/layout/AppLayout.tsx` - 应用布局

### 页面
- `src/pages/Home.tsx` - 首页
- `src/pages/Learn.tsx` - 学习页面

## 学习内容

### 第一阶段：分数大小比较

- **数学思想**: 数形结合
- **学习单元**: 分数大小比较
- **完整流程**:
  1. 情境观察 - 分蛋糕故事
  2. 图形操作 - 分割圆表示分数
  3. 数量比较 - 比较分数大小
  4. 提出猜想 - 归纳比较方法
  5. 验证猜想 - 应用到新情境
  6. 符号表达 - 用数学符号表示
  7. 新情境迁移 - 巩固练习
  8. 反思 - 总结学习收获

## 后续扩展

- [ ] 图示表达步骤组件
- [ ] 符号表示步骤组件
- [ ] 猜想步骤组件
- [ ] 迁移应用步骤组件
- [ ] 能力画像页面
- [ ] 更多学习内容包
