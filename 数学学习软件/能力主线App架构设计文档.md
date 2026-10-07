# 数学思维训练 App 架构设计文档

> 产品形态：桌面端（Windows/macOS）+ Android
> 前置文档：《深度分析报告.md》（问题诊断）、《能力主线与深度理解设计方案.md》（目标定义）
> 本文档回答：**怎么实现**——技术架构、数据结构、交互引擎、平台工程、里程碑。

---

## 一、设计目标与最高原则

### 1.1 一句话产品定义

> 以「能力主线」驱动的数学思维训练 App：学生必须**猜想、操作、表达、犯错、修正**才能前进，系统以**行为证据**验证理解，而非以点击放行。

### 1.2 最高架构原则（吸取 math-explorer 教训）

| # | 原则 | 含义 | 对应旧版教训 |
|---|------|------|-------------|
| 1 | **教学法决定组件，而非组件决定教学法** | 每个学习步骤先定义"学生必须产出什么"，再选/建组件 | 架构v2"组件能力决定数据结构"导致全面退化 |
| 2 | **无验证，不过关** | `completionCriteria` 由统一校验器强制执行，禁止任何组件硬编码 `completed: true` | 旧版全套配置是死代码 |
| 3 | **数据与渲染是结构化契约** | 禁止从自然语言文案里 regex 抠参数；可视化参数必须结构化入 schema | ConcreteStep regex 抠数字 |
| 4 | **本地优先（Local-first）** | 核心学习体验零网络依赖；后端只做同步与内容分发 | — |
| 5 | **一份代码，双端产物** | 桌面端与 Android 共享全部业务代码，仅交互适配层分叉 | — |

---

## 二、核心领域模型

### 2.1 能力主线四层（贯穿全部设计）

```
能力 Ability → 行为指标 Behavior → 交互机制 Mechanism → 验证标准 Evidence
（5+2 能力）   （可观测动作）       （步骤类型/组件）      （校验器规则）
```

### 2.2 八步学习流（六步法 + 补两环）

在旧六步基础上插入 **猜想（conjecture）** 与 **认知冲突（conflict）** 两个步骤类型：

```
具象操作 → 猜想 → 认知冲突 → 图示表达 → 语言描述 → 符号表示 → 灵活应用 → 反思内化
concrete   conjecture conflict  pictorial  verbal    symbolic   application reflection
```

| 步骤类型 | 学生必须产出 | 验证方式 |
|---------|-------------|---------|
| concrete 具象操作 | 真实的操作动作（分割、拖动、摆放） | 操作结果达标（如等分误差 < 容差） |
| **conjecture 猜想（新）** | 写出/选出自己的猜想 | 提交即记录（不判对错，判"有没有猜"） |
| **conflict 认知冲突（新）** | 先暴露直觉判断，再观察证伪动画 | 完成"判断→冲突→修正"三段记录 |
| pictorial 图示表达 | 自己涂/画/选图 | 图与目标关系匹配 |
| verbal 语言描述 | 真实文本输入 | 关键词覆盖 + 逻辑连接词校验 |
| symbolic 符号表示 | 真实输入符号/算式 | 等价式判定（如 `3x+11=50` ≡ `11+3x=50`） |
| application 灵活应用 | 独立作答变式题 | 正确率 ≥ minCorrect/totalQuestions |
| reflection 反思内化 | 写下总结 + 自评 | 字数下限 + 自评与实测校准记录 |

---

## 三、总体架构

### 3.1 分层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        表现层（React 19 + TS）                    │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌─────────────────┐  │
│  │ 地图/岛屿  │ │ 学习会话页 │ │ 学情报告页 │ │ 家长视图         │  │
│  └───────────┘ └───────────┘ └───────────┘ └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                      交互引擎层（框架无关核心）                     │
│  ┌──────────────┐ ┌───────────────┐ ┌───────────────────────┐  │
│  │ StepEngine   │ │ Validator     │ │ VisualComponent       │  │
│  │ 步骤状态机    │ │ Registry      │ │ Registry              │  │
│  │ 驱动八步流程  │ │ 统一过关校验   │ │ 可视化组件注册表        │  │
│  └──────────────┘ └───────────────┘ └───────────────────────┘  │
│  ┌──────────────┐ ┌───────────────┐ ┌───────────────────────┐  │
│  │ Conjecture   │ │ Conflict      │ │ ErrorPattern          │  │
│  │ Engine 猜想  │ │ Engine 冲突   │ │ Library 错误模式库     │  │
│  └──────────────┘ └───────────────┘ └───────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                        领域数据层                                │
│  ┌──────────────┐ ┌───────────────┐ ┌───────────────────────┐  │
│  │ Content      │ │ Learning      │ │ AbilityProfile        │  │
│  │ Schema 内容  │ │ Evidence      │ │ 能力画像（行为证据聚合）│  │
│  └──────────────┘ └───────────────┘ └───────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                        持久化层                                  │
│          SQLite（tauri-plugin-sql）+ 内容包（JSON 资源）           │
├─────────────────────────────────────────────────────────────────┤
│                        原生壳层（Tauri 2 / Rust）                 │
│   Windows MSI/NSIS │ macOS DMG │ Android APK/AAB                │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 技术选型

| 层 | 选型 | 理由 |
|----|------|------|
| 跨端壳 | **Tauri 2.x** | 单代码库同时产出 Windows/macOS/Android；包体小（<15MB，对比 Electron 150MB+）；Rust 壳安全且性能好；官方支持 mobile（Android/iOS） |
| 前端 | React 19 + TypeScript + Vite | 复用 math-explorer 已有资产与团队经验；Vite 与 Tauri 原生集成 |
| 状态 | Zustand | 轻量；学习会话状态机可用 store 切片表达 |
| 持久化 | **SQLite（tauri-plugin-sql）** | 替代旧版 Dexie/IndexedDB：Android WebView 的 IndexedDB 有容量与清理风险，SQLite 可靠且可导出备份 |
| 内容包 | JSON + zod 校验 | 内容与代码分离，支持热更新下发；zod 保证 schema 契约（原则3） |
| 数学判定 | 自研轻量等价式判定（表达式解析 + 规范化比对） | 判 `3x+11=50` ≡ `11+3x=50`；MVP 不需要 CAS，初中后段再评估 mathjs/Algebrite |
| 后端（二期） | 账号/同步/内容分发：任意 BaaS 或自建（推荐：Supabase 或 CloudBase） | MVP 无后端 |

**为什么不选 Flutter**：团队已有 React/TS 资产与组件；Tauri 的 Web 技术栈对"数据驱动 + 可视化交互"类应用足够；包体与桌面端体验 Tauri 更优。
**为什么不选 Electron**：无 Android 能力，包体大。

---

## 四、交互引擎层设计（核心）

### 4.1 StepEngine：步骤状态机

每个学习步骤是一个独立状态机，引擎只认接口、不认组件：

```typescript
// 每个步骤类型实现统一契约
interface StepRuntime<S> {
  /** 初始状态 */
  init(content: StepContent): S;
  /** 处理用户动作，返回新状态（纯函数，可单测） */
  reduce(state: S, action: StepAction): S;
  /** 当前状态是否满足过关条件 —— 唯一允许返回 completed 的地方 */
  validate(state: S, criteria: CompletionCriteria): ValidationResult;
  /** 从状态中提取学情证据 */
  extractEvidence(state: S): LearningEvidence[];
}

interface ValidationResult {
  passed: boolean;
  /** 未过时给学生的具体反馈（不是"再想想"，是指出差在哪） */
  feedback?: string;
  /** 命中的错误模式（接入错误模式库） */
  matchedErrorPattern?: string;
}
```

**铁律**：`completed` 只能由 `validate()` 返回。组件层无权调用 `onComplete(true)`——从类型层面就拿走这个能力（组件只派发 action，不接触完成回调）。

### 4.2 ValidatorRegistry：让 completionCriteria 活过来

```typescript
// 每种完成条件对应一个校验器，集中注册
const validators: Record<CompletionType, Validator> = {
  interactive: (state, cfg: InteractiveConfig) => { /* 操作达标判定 */ },
  input:       (state, cfg: InputConfig)       => { /* 等价式/容差判定 */ },
  choice:      (state, cfg: ChoiceConfig)      => { /* 选项判定 + 乱序映射 */ },
  verbal:      (state, cfg: VerbalConfig)      => { /* 关键词覆盖 + 连接词 */ },
  conjecture:  (state, cfg: ConjectureConfig)  => { /* 已提交实质猜想 */ },
  conflict:    (state, cfg: ConflictConfig)    => { /* 三段记录完整 */ },
  reflection:  (state, cfg: ReflectionConfig)  => { /* 字数下限 + 非模板 */ },
};
```

### 4.3 语言步校验（verbal validator）MVP 规则

不接大模型也能做的有效校验：

1. **长度**：≥ 15 字（拒绝"不知道"/空提交）；
2. **关键词覆盖**：命中 `expectedKeywords` 至少 `minKeywords` 个；
3. **逻辑连接词**：至少含一个「因为/所以/如果/就是/相当于」（说理特征）；
4. 未达标 → 给出**具体**反馈："你说到了'平均分'，但还没说清'取几份'，补充一下？"
5. 连续 3 次未达标 → 降级为填空模板（脚手架撤除的逆操作），并记入证据。

二期可替换为大模型语义评分，接口不变。

### 4.4 猜想引擎（ConjectureEngine）

```
观察区（特例序列，如 1/2÷1/4=2, 1/2÷1/3=?, ...）
   → 学生写下猜想（文本/选择/拖拽构造）
   → 系统用可视化动画验证：证实 ✓ 或 证伪 ✗
   → 证伪时：学生修正猜想（记录修正轨迹）
证据记录：initialConjecture, revisedConjecture, revisionCount, verified
```

教学要点：**猜想不判对错、判"有没有猜"**；修正次数本身是宝贵的学情数据（归纳能力指标）。

### 4.5 认知冲突引擎（ConflictEngine）

以分数加法为例的三段式：

```
① 暴露：先问 "1/2 + 1/3 = ?" —— 学生自由作答（预期大量 2/5）
② 冲突：等分动画演示正确结果 5/6，与学生答案并置对照
③ 重构：学生选择/书写"我之前错在哪"（匹配错误模式库）
证据记录：intuitiveAnswer, wasConflicted, rootCauseId
```

### 4.6 错误模式库（ErrorPatternLibrary）

把《数学思维体系分析文档》的诊断表结构化为数据：

```typescript
interface ErrorPattern {
  id: string;                    // 'frac-add-nodenominator'
  topic: string;                 // 'fraction-addition'
  match: AnswerMatcher;          // 判定函数/规则，如 (a/b)+(c/d) => (a+c)/(b+d)
  rootCause: string;             // '不理解异分母需先统一单位'
  remediation: RemediationRef;   // 指向干预内容（可视化+2道变式+1道综合）
}
```

作答先过 `validators`，错了再过 `ErrorPatternLibrary.match()`——**答错时的反馈不是"错了"，而是"你犯了'分子分母分别相加'的典型错误，我们看看为什么这不对"**。这是与刷题 App 的核心差异点。

---

## 五、内容与数据 Schema

### 5.1 知识点内容包（zod 契约）

```typescript
interface KnowledgePoint {
  id: string;
  name: string;
  grade: number;                 // 1-9
  strand: 'number' | 'algebra' | 'geometry' | 'logic' | 'statistics';
  prerequisites: string[];

  /** 能力主线锚点（新） */
  abilityTargets: AbilityTarget[];

  steps: LearningStep[];         // 八步学习流（子集，按知识点裁剪）
}

interface AbilityTarget {
  ability: Ability;              // 'number-sense' | 'symbolic' | 'reasoning' | ...
  behavior: string;              // 可观测行为指标，如"能口述通分的算理"
  evidence: EvidenceRule;        // 该行为在哪些步骤、以什么规则被观测
}
```

### 5.2 学情证据模型（替代"正确率+自评"）

```typescript
interface LearningEvidence {
  pointId: string;
  stepId: string;
  ability: Ability;
  behavior: string;
  outcome: 'demonstrated' | 'partial' | 'not-yet';
  detail: {
    attempts: number;
    hintsUsed: number;
    firstTryCorrect?: boolean;
    conjectureRevisions?: number;   // 猜想修正次数
    conflictedErrorPattern?: string; // 命中的错误模式
    verbalKeywordCoverage?: number;  // 语言步关键词覆盖率
  };
  timestamp: number;
}
```

**能力雷达图数据源** = 按 ability 聚合 evidence 的 `outcome` 加权（demonstrated=1, partial=0.5），首试正确、少提示加权上调。自评仅用于**校准度**（自评 vs 实测偏差），绝不计入能力分。

### 5.3 自适应规则引擎（MVP 用规则，不用 AI）

```
IF 某 evidence.outcome = 'not-yet' AND hintsUsed ≥ 2
THEN 退回该步骤的更具体表征层级（符号→图示→具象）

IF application 步 minCorrect 未达 AND 命中错误模式 P
THEN 推送 P.remediation 干预包，完成后重测

IF 连续 3 个知识点 demonstrated 且 firstTryCorrect
THEN 解锁挑战区（开放题/一题多解）
```

---

## 六、页面与用户流

```
首页（能力星图，非知识列表）
  └─ 能力岛（按 5+2 能力组织，知识点挂在能力下）
       └─ 知识点学习会话（八步流，StepEngine 驱动）
            └─ 结算页（能力证据回执："你展示了'能口述算理'⭐"，而非"得分 100"）
  └─ 错题诊所（错误模式视角："你最近 3 次犯了'忽略单位统一'"）
  └─ 成长报告（能力雷达 + 行为证据时间线 + 校准度）
```

**关键反转**：导航的第一层级是**能力**不是知识点——这从信息架构上固化能力主线。

---

## 七、平台工程：桌面端 + Android

### 7.1 单代码库结构

```
math-thinking-app/
├── src/                      # 共享前端（100% 业务代码）
│   ├── engine/               # 交互引擎层（纯 TS，无 React 依赖，可单测）
│   │   ├── step-runtime/     # 8 种 StepRuntime 实现
│   │   ├── validators/       # ValidatorRegistry
│   │   ├── conjecture/       # 猜想引擎
│   │   ├── conflict/         # 认知冲突引擎
│   │   └── error-patterns/   # 错误模式库
│   ├── content/              # 内容包（JSON + zod schema）
│   ├── domain/               # 领域模型（Ability/Evidence/Profile）
│   ├── stores/               # Zustand（会话/档案/设置）
│   ├── components/
│   │   ├── steps/            # 8 种步骤 UI 组件
│   │   ├── visuals/          # SplitCircle/BalanceScale/SegmentDiagram/
│   │   │                     #   EquationBuilder/ConjecturePad/DrawingPad
│   │   └── platform/         # 平台适配组件（触摸 vs 鼠标）
│   └── pages/
├── src-tauri/                # Rust 壳
│   ├── src/main.rs
│   ├── capabilities/         # 权限声明（sql/fs）
│   ├── icons/
│   ├── gen/android/          # Tauri 生成的 Android 工程
│   └── tauri.conf.json
├── e2e/                      # Playwright（桌面 WebView 流程测试）
└── package.json
```

**架构边界**：`engine/` 不 import React——八步逻辑可纯函数单测，这是"无验证不过关"的测试保障。

### 7.2 Tauri 配置要点

```jsonc
// tauri.conf.json（节选）
{
  "identifier": "com.mathexplorer.thinking",
  "build": { "frontendDist": "../dist", "devUrl": "http://localhost:1420" },
  "plugins": { "sql": { "preload": ["sqlite:learning.db"] } },
  "bundle": {
    "active": true,
    "targets": ["msi", "nsis", "dmg"],     // 桌面产物
    "android": { "minSdkVersion": 26 }      // Android 8.0+（覆盖 95%+ 设备）
  }
}
```

### 7.3 双端差异与适配

| 维度 | 桌面端 | Android | 适配策略 |
|------|--------|---------|---------|
| 输入 | 鼠标拖拽、键盘输入 | 触摸拖拽、软键盘 | 交互组件统一用 Pointer Events；拖拽热区 ≥ 44px |
| 屏幕 | 横屏为主 | 竖屏为主 | 学习会话页双布局：桌面左右分栏（可视化\|任务区），手机上下堆叠 |
| 键盘遮挡 | 无 | 输入框被软键盘遮挡 | verbal/symbolic 步输入区自动滚入视口 + `interactive-widget=resizes-content` |
| 存储 | SQLite 文件于应用数据目录 | 同左（沙盒内） | 同一插件 API，无分叉 |
| 性能 | 无压力 | 低端机 SVG 动画掉帧风险 | 可视化组件 SVG 元素数预算 ≤ 200；动画用 transform/opacity |
| 分发 | MSI/NSIS + DMG，自有渠道或商店 | APK（官网/家长群）+ AAB（应用市场） | 见 7.4 |

### 7.4 构建与分发流水线

```
开发:  pnpm tauri dev            # 桌面调试
       pnpm tauri android dev    # 真机/模拟器调试（需 Android Studio + NDK）

发布:  pnpm tauri build                    → MSI/NSIS/DMG
       pnpm tauri android build --apk      → 签名 APK（直发）
       pnpm tauri android build --aab      → AAB（上架华为/小米/应用宝等）

签名:  Android keystore 单签管理（CI  Secrets）；
       Windows 后期购代码签名证书消除 SmartScreen 警告
CI:    GitHub Actions 三 job（windows / macos / android），
       内容包 zod 校验 + engine 单测 + Playwright e2e 全绿才出包
```

### 7.5 升级与内容热更

- 应用本体：Tauri Updater（桌面）；Android 走市场更新或应用内下载 APK。
- **内容包与代码分离**：知识点 JSON 可独立下发（HTTP 拉取 + zod 校验 + 版本号），不修代码即可上新课——这是内容团队迭代的关键。

---

## 八、后端演进（二期，MVP 不建）

| 能力 | 方案 | 触发时机 |
|------|------|---------|
| 账号与学情云同步 | Supabase/CloudBase，evidence 表增量同步 | 用户量 > 1000 或家长强烈需求多端 |
| 内容管理后台 | 低代码表单直出内容包 JSON（zod 校验） | 知识点 > 50 个 |
| AI 助教追问 | 大模型 API，替换 verbal validator 与 followUp 生成 | 验证规则引擎覆盖率不足时 |
| 家长端报告推送 | 周报生成 + 微信模板消息 | 商业化阶段 |

---

## 九、里程碑

| 里程碑 | 周期 | 范围 | 验收标准 |
|--------|------|------|---------|
| **M1 引擎底座** | 2-3 周 | engine/ 全部 + 2 个示范知识点（分数初步、字母表示数）跑通八步流；桌面端可玩 | ① 全程无产出无法过关（e2e 用例证明）② engine 单测覆盖 ≥ 90% |
| **M2 机制补全** | 2-3 周 | 猜想引擎 + 冲突引擎 + 错误模式库（首批 20 条）+ 语言步校验 | 每个示范知识点至少含 1 个猜想步与 1 个冲突步；答错反馈带错因 |
| **M3 双端发布** | 2 周 | Android 适配 + 触摸交互 + 构建签名流水线 | 双端安装包；低端机（Android 8）流畅运行 |
| **M4 内容铺开** | 持续 | 按能力优先级补内容：数感算理（分数/运算）→ 符号意识（方程）→ 推理（规律/假设法）→ 图形岛重建 | 每能力 ≥ 3 个知识点；雷达图数据来自行为证据 |

### 旧资产处置

| 旧资产 | 处置 |
|--------|------|
| 5 个六步知识点数据 | 按新 schema 改写（补 abilityTargets + conjecture/conflict 步），修 eq-app-3 错题 |
| 16 个旧模式知识点 | 隐藏，按 M4 计划逐个重写，不做"新旧混跑" |
| 可视化组件（SplitCircle 等） | 参数结构化改造后移入 `components/visuals/`；SplitCircle 改为真分割交互 |
| 8 份旧设计文档 | 理论部分（思维体系、障碍诊断表）归档为内容知识库；架构 v2 废止 |

---

## 十、风险与对策

| 风险 | 等级 | 对策 |
|------|------|------|
| 校验太严导致挫败感（尤其兴趣型用户） | 高 | 双难度通道：挑战通道严格执行验证；兴趣通道脚手架更厚（提示更多、降级更早），但**产出要求不降**——这是底线，不是可调参数 |
| 语言步规则校验误判（学生说得对但没踩关键词） | 中 | 误判申诉入口（"我觉得我说对了"）→ 进入家长/教师复核队列；误判样本反哺规则 |
| Tauri Android 生态成熟度 | 中 | M3 先做 1 周 spike 验证：SQLite 插件、触摸、构建链全通再正式排期；备选方案 Capacitor |
| 内容生产成本（八步内容比讲题内容贵 3-5 倍） | 高 | M4 起用模板化内容工厂：每种 stepType 固化数据模板 + 填空式创作指南，先量产再打磨 |
| 猜想/冲突引擎的教学设计质量 | 高 | 每个知识点的猜想步、冲突步必须由懂教学的人撰写脚本（迷思概念库先行），技术只提供容器 |

---

## 十一、验收总标尺（呼应前置文档）

产品是否达成"培养数学思维"，最终只看三件事：

1. **无产出不过关**：自动化测试证明学生不操作、不猜想、不书写就无法完成任何知识点；
2. **答错有错因**：抽查任意错题，系统反馈的是"错因诊断"而非"再想想"；
3. **雷达图可信**：能力分全部来自行为证据，家长看到的每一分都能点开看到"哪一步、哪个动作"挣来的。

---

*文档版本：v1.0*
*创建日期：2026-10-05*
*前置文档：《深度分析报告.md》《能力主线与深度理解设计方案.md》*
*下一步：M1 开工——engine/ 目录的 StepRuntime 契约与 ValidatorRegistry 实现*
