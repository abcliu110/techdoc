# 高级英语学习App 技术架构文档

> 版本：v1.0
> 日期：2026-10-08
> 状态：初稿，待评审
> 用途：指导 Web + Android + 桌面端 三端跨平台英语学习应用的架构决策

---

## 一、项目愿景与技术约束回顾

### 1.1 核心目标

基于认知语言学六维分析框架（语义、搭配、语法、隐喻、英汉对比、语体 + 音韵、词源、词素、词块、义项），构建支持 Web / Android / 桌面端 的英语单词深度学习应用。每个单词一份 Markdown 文件存储深度分析内容，用户学习数据通过间隔重复算法（FSRS）驱动复习计划。**纯本地存储，无后端**，数据通过文件导入/导出实现备份和迁移。

### 1.2 技术约束

| 约束项 | 说明 |
|--------|------|
| 三端一致性 | Web / Android / 桌面端视觉与交互一致 |
| 离线优先 | 核心学习功能在无网络时可用 |
| 纯本地存储 | 无后端，数据存本地 SQLite，用户通过文件导入/导出备份迁移 |
| 原型已验证 | Web 原型已验证：marked.js 渲染 markdown + XHR 加载本地文件 |
| 已有数据资产 | SQLite 数据库已含 3538 词、26 张表、近万条关系数据 |

---

## 二、技术选型

### 2.1 跨平台框架：Taro + React

**推荐方案：Taro 4.x + React**

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **Taro + React** | 一套代码编译至 H5 / Android / iOS / 桌面；React 生态成熟；团队熟悉度高 | 桌面端需额外配置 Electron；部分 npm 包需适配 | **首选** |
| React Native | 原生性能，体验好 | 不支持 Web；代码无法复用；需维护两套代码 | 不推荐 |
| Flutter | 高性能；设计自由度大 | Dart 语言；UI 无法与 Web 共用；学习曲线陡 | 不推荐 |
| 纯 Web 方案 | 简单；原型可完全复用 | 无法编译为原生 App | 仅适合 MVP 阶段验证 |

**Taro 选型理由：**
1. Web 原型的 HTML/CSS/JS 可移植至 React 组件，复用成本最低
2. marked.js、Zustand 等主流库天然支持 Taro 编译链
3. Android 打包成熟（Gradle + JDK 21）；桌面端可通过 H5 套壳（Tauri/Electron）后期补充
4. 团队已有 Taro + React 技术栈（参考 nms4cloud 项目的 React 前端经验）

### 2.2 状态管理：Zustand

- 轻量级（无 Provider 嵌套）；API 简洁；支持 persist 中间件直接对接 localStorage/AsyncStorage
- 跨 Taro 各端（Web/H5/小程序）行为一致，无需平台适配代码
- 替代方案对比：Redux（过于笨重）；Jotai（依赖原子化概念，学习成本高）

### 2.3 本地持久化：SQLite + localStorage 分层

**纯本地存储，无后端。**

| 层级 | 存储内容 | 技术方案 | 说明 |
|------|---------|---------|------|
| 结构化学习数据 | 单词详情、FSRS 进度、用户记录 | SQLite（taro-sqlite） | 复杂关系查询；FSRS 参数持久化 |
| 偏好配置 | 用户设置、当前学段 | localStorage / AsyncStorage | 轻量 KV 存储 |
| Markdown 内容 | 单词深度分析文档 | 静态文件内嵌 + 按需加载 | 离线缓存至 IndexedDB |

**数据备份策略：**
- 导出：用户将数据导出为 JSON 文件，可通过微信/邮件等方式迁移到其他设备
- 导入：App 内置导入功能，读取 JSON 文件恢复数据
- 音频：使用在线音频 API（MVP），正式版支持本地缓存

### 2.4 Markdown 渲染：marked + 自定义渲染器

- `marked` 解析 Markdown；自定义 Renderer 注入品牌样式和交互（如点击表格行高亮）
- 语法高亮：`highlight.js`（Web 端）或 `taro-syntax-highlighter`（移动端降级处理）
- 离线缓存：首次加载后存入 IndexedDB，后续无需网络

### 2.6 间隔重复算法：FSRS（Free Spaced Repetition Scheduler）

- 使用 `fsrs.js`（官方 JS 实现）计算复习间隔
- 参数持久化至 `user_progress` 表（已有 Schema 支持）
- Android 端后台推送提醒：使用 `react-native-push-notification` 或 Taro 插件

### 2.7 桌面端方案

| 阶段 | 方案 | 说明 |
|------|------|------|
| 第一阶段 | Taro H5 打包为 PWA | 直接使用；离线可用；桌面体验一般 |
| 第二阶段 | Tauri（Rust 后端） | 体积小（< 10MB）；原生窗口；可调用系统通知 |
| 第三阶段 | Electron（可选） | 如果 Tauri 无法满足所有需求（如复杂的 WebView 交互） |

---

## 三、目录结构设计

### 3.1 顶层目录

```
english-learning-app/
├── src/
│   ├── app/                    # Taro 入口文件
│   ├── pages/                  # 页面（各端共享）
│   ├── components/             # 组件库（各端共享）
│   ├── business/               # 业务逻辑
│   │   ├── word/               # 单词域
│   │   ├── learning/           # 学习/复习域
│   │   ├── exercise/           # 练习域
│   │   └── user/               # 用户域
│   ├── services/               # 数据服务层（API / DB / Sync）
│   ├── stores/                 # Zustand 状态管理
│   ├── data/                   # 内置词库（JSON 导出自 SQLite）
│   │   └── words/              # 各单词的 JSON 数据文件
│   ├── types/                  # TypeScript 类型定义
│   ├── utils/                  # 工具函数（FSRS / 拼音 / 格式等）
│   ├── hooks/                  # React 自定义 Hooks
│   └── assets/                 # 静态资源（图片、音频占位）
│
├── docs/                       # 架构与设计文档（本文档所在）
├── scripts/                    # 数据导入/导出脚本（Python）
├── android/                    # Android 原生工程（Taro 编译产物）
├── ios/                        # iOS 原生工程（Taro 编译产物）
└── desktop/                    # Tauri / Electron 桌面工程
```

### 3.2 组件目录按职责拆分

```
components/
├── ui/                         # 基础 UI 组件（与业务无关）
│   ├── Button/
│   ├── Card/
│   ├── Badge/
│   └── MarkdownRenderer/       # Markdown 渲染组件（复用原型）
│
├── word/                       # 单词域组件
│   ├── WordCard/               # 单词列表卡片（复用原型 word-card 样式）
│   ├── WordDetail/             # 单词详情页（渲染 Markdown）
│   ├── PhoneticBadge/          # 音标/发音组件
│   ├── TagFilter/              # 标签筛选（复用原型）
│   └── DimensionPanel/         # 六维分析面板
│
├── learning/                   # 学习域组件
│   ├── ReviewCard/             # 复习卡片
│   ├── ProgressRing/           # 学习进度环
│   └── FsrsSchedule/           # FSRS 复习调度日历
│
├── exercise/                   # 练习域组件
│   ├── CollocationExercise/    # 搭配练习（L3）
│   ├── ContextSenseExercise/   # 语境选义（L4）
│   ├── RegisterExercise/       # 语体判断（L4-L5）
│   └── SentenceExercise/       # 造句练习（L5）
│
└── common/                     # 通用布局组件
    ├── PageHeader/
    ├── SearchBar/              # 复用原型 search-wrap 样式
    └── BottomNav/
```

### 3.3 业务逻辑目录（business/）

```
business/
├── word/
│   ├── WordService.ts          # 单词 CRUD、搜索、筛选
│   ├── WordRelationService.ts  # 词际关系查询（同义词/反义词/搭配等）
│   └── WordMorphemeService.ts  # 词素分解服务
│
├── learning/
│   ├── LearningService.ts      # 学习流程编排
│   ├── FsrsScheduler.ts        # FSRS 调度器封装
│   └── ReviewService.ts        # 复习任务生成
│
├── exercise/
│   ├── ExerciseGenerator.ts    # 练习题生成
│   └── ExerciseEvaluator.ts    # 练习答案评测
│
└── user/
    ├── UserService.ts          # 用户信息、偏好设置
    ├── ExportService.ts          # 数据导出为 JSON
    └── ProfileService.ts       # 学习报告、统计
```

---

## 四、数据模型设计

### 4.1 核心实体（基于已有 SQLite Schema 扩展）

#### Word（单词词条）

```typescript
interface Word {
  id: string;            // 单词唯一ID（UUID）
  word: string;          // 单词原形（全部小写，索引键）
  phonetic_us: string;   // 美式音标，如 /rʌn/
  phonetic_uk: string;   // 英式音标
  audio_us_url: string;  // 美式发音音频 URL
  audio_uk_url: string;  // 英式发音音频 URL
  frequency_band: string; // 词频等级：A1/A2/B1/B2/C1/C2
  cefr_level: string;    // CEFR 等级
  grade_levels: number[]; // 适用年级 [1, 2, 3, 4, 5]（小学1-高中）
  created_at: string;
  updated_at: string;
}
```

#### WordSense（义项）

```typescript
interface WordSense {
  id: string;
  word_id: string;
  sense_no: number;           // 义项序号（1, 2, 3...）
  pos: string;                // 词性：noun, verb, adjective, adverb...
  meaning_cn: string;         // 中文释义
  definition_en: string;      // 英文释义（可选）
  connotation: 'positive' | 'negative' | 'neutral'; // 情感色彩
  register: 'informal' | 'neutral' | 'formal';       // 语体
  // 后续字段省略，对应 word_senses 表
}
```

#### UserProgress（用户学习记录）

```typescript
interface UserProgress {
  id: string;
  word_id: string;
  user_id: string;
  mastery_status: 'new' | 'learning' | 'reviewing' | 'mastered';
  skill_code: string;         // form_recognition | spelling | meaning_recall | usage | sound_recognition
  first_seen_at: string;
  due_at: string;             // FSRS 下次复习时间
  correct_count: number;
  wrong_count: number;
  // FSRS 核心参数
  fsrs_stability: number;     // 记忆稳定性
  fsrs_difficulty: number;    // 记忆难度（1-10）
  retrievability: number;     // 当前可提取性（0-1）
  updated_at: string;
}
```

### 4.2 关系数据模型（复用已有 26 张表）

| 表名 | 用途 | 记录量（当前） |
|------|------|---------------|
| words | 词条主表 | 3538 |
| word_senses | 义项表 | 3538 |
| word_forms | 词形变化（复数/时态等） | 1229 |
| word_morphemes | 词素分解（前缀/词根/后缀） | 1846 |
| word_collocations | 搭配关系 | 1961 |
| word_relations | 词际关系（同义/反义/上下位等） | 902 |
| word_metaphors | 隐喻关联 | 31 |
| sense_relations | 多义派生链 | 630 |
| metaphor_frames | 隐喻框架 | 20 |
| connotation_groups | 情感色彩组 | 21 |
| word_connotation_group | 词-情感组关联 | 81 |
| themes | 主题 | 24 |
| word_themes | 词-主题关联 | 1397 |
| topic_clusters | 主题词簇 | 23 |
| word_topic_clusters | 词-词簇关联 | 186 |
| same_syntax_frames | 句法框架 | 16 |
| syntax_frames | 句型 | 26 |
| word_mistakes | 错因分析 | 230 |
| letter_patterns | 字母组合 | 60 |
| phonics_patterns | 拼读规则 | 85 |
| morphemes | 词素词根表 | 87 |
| prerequisite_groups | 先备关系组 | 15 |
| word_prerequisites | 词-先备关联 | 107 |
| grade_levels | 年级/难度等级 | 12 |
| word_levels | 词-等级关联 | 3538 |
| user_progress | 用户学习进度 | 0（预留） |

### 4.3 Markdown 内容存储策略

每个单词的深度分析内容存储为独立 Markdown 文件：

```
data/words/
├── run.md          # 完整深度分析（语义+搭配+语法+隐喻+英汉对比+语体+音韵+词源+词素+词块）
├── abandon.md
├── abandon/
│   ├── index.md    # 主入口，包含全部维度摘要
│   ├── semantics.md    # 语义维度（原型场景+义项派生）
│   ├── collocation.md  # 搭配维度
│   ├── grammar.md      # 语法维度
│   ├── metaphor.md     # 隐喻维度
│   ├── register.md     # 语体维度
│   ├── phonetics.md    # 音韵维度
│   └── etymology.md    # 词源维度
```

**文件命名规则：**
- 单词名全部小写
- 多义词各维度内容按目录组织（`abandon/semantics.md`）
- 简单词或 MVP 阶段：单文件（`run.md`）
- Markdown 内 front-matter 标注元数据：

```yaml
---
word: run
phonetic_us: /rʌn/
phonetic_uk: /rʌn/
grade_levels: [1, 2, 3, 4, 5]
cefr: A1
connotation: neutral
updated_at: 2026-10-08
---
```

---

## 五、Web 原型与正式 App 的关系

### 5.1 原型复用清单

| 原型文件 | 复用方式 | 目标位置 |
|---------|---------|---------|
| `app/prototype/index.html` | 提取 CSS 样式为 `.module.css`；JS 逻辑移植为 React 组件 | `components/ui/` + `components/word/` |
| `app/prototype/marked.min.js` | 替换为 npm 包 `marked` | `package.json` |
| `app/prototype/md/run-*.md` | 作为初始内容导入 `data/words/run/` | `data/words/run/` |
| 搜索/标签筛选逻辑 | 封装为 `useWordFilter` Hook | `hooks/useWordFilter.ts` |
| Markdown 渲染样式 | 提取 `.md-body` 及后代样式 | `components/ui/MarkdownRenderer/` |

### 5.2 原型 CSS 样式迁移

原型中的以下样式模式需提取为设计 Token：

```css
/* 设计 Token（design tokens）*/
--color-primary: #58a6ff;      /* 主色调（蓝色） */
--color-bg: #0d1117;           /* 深色背景 */
--color-surface: #161b22;      /* 卡片/面板背景 */
--color-border: #30363d;       /* 边框色 */
--color-text: #e6edf3;         /* 主文本 */
--color-text-secondary: #8b949e; /* 次级文本 */
--color-accent: #f472b6;       /* 强调色（粉色） */
--color-accent-purple: #d2a8ff; /* 紫色强调 */

/* 圆角/间距遵循 4px 基准网格 */
--radius-sm: 6px;
--radius-md: 10px;
--radius-lg: 16px;
```

### 5.3 渐进增强策略

```
阶段一（MVP）：
  Web 原型 → React 组件（复用全部 CSS + 交互逻辑）
  数据来源：内嵌 JSON（来自 SQLite 导出）
  纯本地存储，无后端

阶段二（离线增强）：
  引入 SQLite 本地持久化
  Markdown 按需加载（首次加载后缓存）
  离线时完整功能可用

阶段三（桌面端）：
  Taro H5 → PWA（桌面浏览器直接用）
  Tauri 打包桌面版（独立工作流）
```

---

## 六、数据备份与迁移

### 6.1 整体架构

```
┌─────────────────────────────────────────┐
│              客户端（多端）               │
│  Taro + React │ Zustand │ SQLite        │
└────────────────────┬────────────────────┘
                     │ 导入/导出 JSON 文件
                     ▼
┌─────────────────────────────────────────┐
│          用户设备（本地存储）              │
│  SQLite 存储所有数据                      │
│  通过文件分享迁移至其他设备                 │
└─────────────────────────────────────────┘
```

### 6.2 导出机制

用户可在设置页一键导出全部数据为 JSON 文件，包含：
- 用户进度（FSRS 参数、复习记录）
- 用户偏好设置
- 学习统计数据

导出文件可命名保存，通过微信/邮件/网盘等任意方式传输到其他设备。

### 6.3 导入机制

新设备安装 App 后，在设置页导入之前导出的 JSON 文件，数据完整恢复。

### 6.4 音频资源

- MVP 阶段：使用在线音频 API 按需获取发音（需网络）
- 正式版：首次发音后缓存至本地，后续离线可用

---

## 七、功能添加流程

每个新功能的开发遵循以下流程，确保质量可追溯：

### 7.1 流程总览

```
需求提出
  │
  ▼
1. 功能规格（Feature Spec）
  - 明确功能范围、验收标准、数据模型影响
  - 输出至 docs/features/YYYY-MM-DD-{feature-name}-spec.md
  │
  ▼
2. 创建功能分支
  git checkout -b feature/{feature-name}
  │
  ▼
3. 数据层变更（如涉及）
  - 新增/修改 SQLite 表
  - 新增/修改 TypeScript 类型
  - 输出迁移脚本至 scripts/
  │
  ▼
4. 业务逻辑层实现
  - 在 business/ 下创建或扩展 Service
  - 单元测试（Vitest）：覆盖率 ≥ 80%
  │
  ▼
5. 组件实现
  - 在 components/ 下创建组件
  - Storybook 文档（如配置了 Storybook）
  │
  ▼
6. 集成与端到端测试
  - 页面级集成测试
  - 离线场景测试
  │
  ▼
7. 代码评审（Code Review）
  - 至少一名评审者
  - 重点检查：数据迁移影响、UI 一致性、FSRS 参数兼容性
  │
  ▼
8. 合并至 main 分支
  │
  ▼
9. 发布验证
  - 在真实设备（Android + 浏览器）上验证
```

### 7.2 新功能检查清单

在动手实现前，必须确认：

- [ ] 数据模型是否需要新增表或字段？（若是，先写 Schema 迁移脚本）
- [ ] 离线场景下该功能是否可用？（若否，明确标注并告知用户）
- [ ] 是否影响 FSRS 调度参数？（若影响，在 FsrsScheduler 中记录变更原因）
- [ ] 多端 UI 是否一致？（使用设计 Token，禁止硬编码颜色/字号）
- [ ] 是否需要新增 Markdown 文档模板？（若是，在 `data/words/` 下建立目录结构）

### 7.3 示例：添加"介词搭配练习"功能

```text
1. 规格：docs/features/2026-10-08-preposition-exercise-spec.md
   - 功能：展示介词填空题，用户从 run + ___ + noun 中选正确介词
   - 数据来源：word_collocations 表，筛选 coll_type = 'prepositional'

2. 分支：feature/preposition-exercise

3. 数据层：
   - 类型：components/exercise/types.ts 新增 PrepositionExerciseItem
   - Service：business/exercise/ExerciseGenerator.ts 新增 generatePrepositionExercise()

4. 组件：
   - components/exercise/PrepositionExercise/index.tsx
   - 复用 components/ui/ 基础组件

5. 测试：
   - business/exercise/ExerciseGenerator.test.ts（单元测试）
   - pages/ExercisePage.test.tsx（集成测试）

6. 评审：
   - 检查题库覆盖度（是否覆盖所有介词类型）
   - 检查难度梯度（初中 vs 高中介词难度差异）

7. 合并发布
```

---

## 八、技术债务与后续决策项

### 8.1 已知技术债务

| 债务项 | 影响 | 建议处理 |
|--------|------|---------|
| SQLite Schema 尚未迁移至 TypeScript 类型定义 | 类型安全缺失 | 初期用 JSDoc 标注，逐步迁移至 `.d.ts` 文件 |
| 音频资源未本地化 | 离线时无法发音 | MVP 使用在线 API；正式版接入 Storage |
| FSRS 参数未持久化到 user_progress | 复习计划重启后丢失 | 确认 SQLite user_progress 表字段完整后启用 |
| Markdown 文件未建立模板规范 | 各词条格式不统一 | 制定 front-matter 标准；在 CI 中验证 YAML 格式 |

### 8.2 待确认决策项

| 决策项 | 影响范围 | 建议 |
|--------|---------|------|
| 桌面端使用 Tauri 还是 Electron？ | 构建流程 | 先用 Tauri 实验；Electron 作为 fallback |
| Markdown 内容是否支持用户贡献（UGC）？ | 社区运营 | MVP 否；正式版按需引入 |
| 是否接入 AI 辅助生成词源/搭配内容？ | 内容生产效率 | 后期通过本地 LLM 或在线 API 生成 |
| 微信小程序是否作为独立端支持？ | Taro 编译目标 | MVP 否；正式版按需增加 |

---

## 九、附录

### 9.1 核心技术栈汇总

| 层级 | 技术选型 | 版本要求 |
|------|---------|---------|
| 跨平台框架 | Taro | 4.x |
| 前端框架 | React | 18.x |
| 语言 | TypeScript | 5.x |
| 状态管理 | Zustand | 4.x + persist |
| 本地数据库 | SQLite（taro-sqlite） | 最新稳定版 |
| Markdown 解析 | marked | 12.x |
| 语法高亮 | highlight.js | 11.x |
| 间隔重复 | fsrs.js | 最新稳定版 |
| 桌面端 | Tauri | 2.x |
| 构建工具 | Vite + Webpack 5 | — |
| 测试框架 | Vitest + React Testing Library | — |
| CI/CD | GitHub Actions | — |

### 9.2 与 Web 原型文件对应关系

| 原型文件路径 | 迁移目标路径 | 说明 |
|------------|------------|------|
| `app/prototype/index.html` | `src/pages/WordListPage.tsx` | 单词列表页 |
| `app/prototype/index.html` | `src/pages/WordDetailPage.tsx` | 单词详情页 |
| `app/prototype/index.html`（CSS） | `src/styles/tokens.css` | 设计 Token |
| `app/prototype/words/run.md` | `data/words/run.md` | 初始词库内容 |
| `app/prototype/marked.min.js` | `package.json`（npm 包） | 直接替换为 marked |

### 9.3 架构决策记录（ADR）

本文档为初始架构文档。随着项目演进，重大架构变更应记录至 `docs/adr/` 目录下的 ADR 文件，格式为：

```
docs/adr/
├── 0001-use-taro-react.md
├── 0002-use-sqlite-for-local-storage.md
├── 0003-use-fsrs-for-spaced-repetition.md
└── 0004-use-zustand-for-state-management.md
```

---
