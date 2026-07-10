# GLM 驱动的 AI 原型设计闭环验证方法论

> 文档版本：v5.0  
> 编写日期：2026-07-10  
> 最后修订：2026-07-10（经 2 轮 × 10 次评审 + 零人工改造 + 5 角色对抗评审 5 轮修复 + 6 缺口代码补全）  
> 适用范围：新产品从竞品调研到原型交付的全流程工程化方法  
> 核心目标：让 AI 生成的原型具备**合理性、先进性、可扩展性、易用性**，并通过工程化手段消除视觉缺陷，**全流程零人工参与**

---

## 一、问题背景与核心矛盾

### 1.1 业务诉求

在开发一款旨在超越同类商业软件的新产品时，我们采用 AI 驱动的工作流：

1. AI 采集竞品及同类商业软件的公开技术文档、使用手册、界面信息
2. AI 进行信息汇总与智能功能分析
3. AI 逆向设计出产品原型

软件界面体现了软件的设计思想。如何采集各家之长、设计出超越竞品的软件，本身就是一个技术问题。

### 1.2 核心矛盾

当前流程存在一个根本性的**验证鸿沟**：

| 维度 | 现状问题 | 后果 |
|------|----------|------|
| 设计质量 | AI 不知道自己的设计是否满足"合理/先进/可扩展/易用" | 设计质量不可控，无法自证达标 |
| 视觉正确性 | AI 原型未经视觉校验 | 内容溢出、元素覆盖、错位、裁剪等问题频发 |
| 流程可控性 | 生成过程自由、不可复现 | 每次结果随机，无法工程化管理 |

### 1.3 关键认知

**不要让 AI"自由设计"，而要让 AI"在强约束下生成，在闭环中收敛"。**

自由生成的错误空间是无限的；约束生成能把错误空间收敛到可控范围。这是整套方法论的出发点。

---

## 二、方法论总览

### 2.1 三大问题与解决方向

| 问题 | 本质 | 解决方向 |
|------|------|----------|
| AI 不知道设计是否满足要求 | 缺乏可量化的设计评价标准 | 建立评分体系 + 多角色评审 |
| AI 原型有视觉缺陷 | 缺乏闭环视觉校验 | 真实渲染 + DOM 分析 + 视觉模型审查 |
| 整个流程不可控 | 缺乏工程化流水线 | 约束驱动生成 + 迭代收敛管线 |

### 2.2 闭环验证管线总览

```
竞品研究 → 特征矩阵 → 设计规格(Design Spec) → 原型生成
    ↑                                              ↓
    |                                         视觉渲染校验
    |                                              ↓
    |                                         评分(多维度)
    |                                              ↓
    |                                    评分达标? ──是──→ 自动终审(多LLM共识)
    |                        ↓否
    |                  缺陷分析(多Agent) → 迭代精修
    └──────────────────────────────────────────────┘
```

两个关键设计原则：

1. **上游强约束**：在生成阶段就用规则消除大部分错误（栅格、间距、组件库、内容边界）
2. **下游闭环校验**：生成后真实渲染，自动化检测缺陷，不达标则回炉

---

## 三、上游：约束驱动生成（预防错误）

这是性价比最高的一层——错误在生成阶段就预防掉约 80%。

### 3.1 设计系统约束（Design Token 体系）

不让 AI 自由编写样式，而是强制它只能使用预定义的设计令牌：

```json
{
  "spacing": [4, 8, 12, 16, 24, 32, 48, 64],
  "color": {
    "primary": "#2563EB",
    "surface": "#FFFFFF",
    "text": { "primary": "#1F2937", "secondary": "#6B7280" }
  },
  "typography": {
    "h1": { "size": 32, "lineHeight": 40, "weight": 700 },
    "h2": { "size": 24, "lineHeight": 32, "weight": 600 },
    "body": { "size": 14, "lineHeight": 22, "weight": 400 }
  },
  "radius": [0, 4, 8, 12, 16],
  "grid": { "columns": 12, "gutter": 16, "margin": 24 }
}
```

AI 生成的原型必须引用这些 token，**禁止使用任意值**。这一条即可消除绝大多数间距混乱、字号不一致的问题。

### 3.2 组件库约束

预置一套经过视觉校验的组件库（按钮、卡片、表单、表格、导航等），AI 只能组合这些组件，不能从零画。

这一步把"视觉正确性"的责任从 AI 转移到了组件库本身——只要组件库本身是对的，组合出来的结果就不会出现基础视觉错误。

### 3.3 内容边界约束

很多溢出问题源于内容长度不可控。在设计规格（Design Spec）中强制声明：

- 每个文本字段的最大字符数
- 图片的宽高比和最大尺寸
- 列表的预期最大条目数

AI 必须按"最坏情况"设计：

- 文本超长用 `text-overflow: ellipsis`
- 内容区域用 `max-height` + 滚动
- 弹性项用 `flex-shrink` / `min-width: 0`
- 图片用 `object-fit: cover`

### 3.4 布局规则约束

强制要求所有页面遵循：

- **12 栅格系统**：所有区块对齐栅格
- **8px 间距基准**：所有间距是 8 的倍数
- **明确断点**：375 / 768 / 1024 / 1440 四档
- **Flex/Grid 优先**：禁止用绝对定位做主布局（绝对定位是溢出/覆盖的重灾区）

### 3.5 约束的技术执行机制

上述约束不能仅靠 prompt 指令（AI 可能不遵守），必须通过工程手段在代码层面强制执行：

| 约束层 | 执行机制 | 说明 |
|--------|----------|------|
| 设计 Token | **Tailwind 配置** | 在 `tailwind.config.js` 中只暴露 token 值，AI 只能用 `spacing-4`、`text-h1` 等语义类名 |
| 任意值禁止 | **eslint-plugin-tailwindcss** | 使用 `no-custom-classname` 规则拦截非白名单类名；禁用 Tailwind 任意值语法 `p-[13px]`（在 `tailwind.config.js` 中不开启 JIT 任意值模式） |
| 自定义 CSS 检查 | **stylelint** | 检查 `.css` 文件中的硬编码像素值（如有自定义样式），不检查 Tailwind 类名 |
| 组件库限制 | **仅导出 Approved 组件** | 组件库只导出白名单组件，AI 无法使用未校验的组件 |
| 布局规则 | **eslint-plugin-tailwindcss** | 检测 JSX 中使用 `absolute` 类名做主布局的情况并报 warning |
| 内容边界 | **TypeScript 类型约束** | 组件 props 强制声明 `maxChars`、`maxItems`，编译时拦截缺失声明 |

**执行流程**：

```
AI 生成代码 → ESLint + stylelint 检查 → (不通过) 拒绝并返回错误信息给 AI 重新生成
                                      → (通过) 进入下游渲染校验
```

> **关键原则**：约束在编译期/构建期拦截，不依赖运行时。AI 生成的代码如果不满足约束，直接被 linter 打回，根本不会进入渲染阶段。这样把"约束违反"的检测前移，成本最低。

---

## 四、下游：自动化视觉校验（检测错误）

这是解决"溢出、覆盖、错位"的核心技术层。核心思路：**把 AI 生成的原型真正跑在无头浏览器里，然后用程序化方式检测缺陷。**

### 4.1 真实渲染 + DOM 分析（最关键）

使用 Playwright 无头浏览器渲染原型，然后通过 `page.evaluate` 注入检测脚本，程序化地扫描所有 DOM 节点。

以下所有检测片段共享以下初始化代码与辅助函数：

```javascript
const problems = []; // 所有片段共用的缺陷收集数组

// 安全的元素选择器描述，兼容 SVG 元素（SVG 的 className 是 SVGAnimatedString）
function getSelector(el) {
  let s = el.tagName.toLowerCase();
  if (el.id) s += '#' + el.id;
  const cls = typeof el.className === 'string' ? el.className : '';
  if (cls) s += '.' + cls.trim().split(/\s+/).join('.');
  return s;
}
```

#### 4.1.1 检测内容溢出

```javascript
document.querySelectorAll('*').forEach(el => {
  if (el.scrollWidth > el.clientWidth + 1) {
    problems.push({
      type: 'OVERFLOW_X',
      selector: getSelector(el),
      scrollW: el.scrollWidth,
      clientW: el.clientWidth
    });
  }
  if (el.scrollHeight > el.clientHeight + 1 &&
      getComputedStyle(el).overflowY === 'hidden') {
    problems.push({ type: 'OVERFLOW_Y_CLIPPED', selector: getSelector(el) });
  }
});
```

能检测出：横向溢出、内容被裁剪不可见。

#### 4.1.2 检测零尺寸/负尺寸元素

```javascript
document.querySelectorAll('*').forEach(el => {
  const r = el.getBoundingClientRect();
  if (r.width <= 0 || r.height <= 0) {
    problems.push({ type: 'ZERO_SIZE', selector: getSelector(el) });
  }
});
```

能检测出：渲染后不可见的元素、布局塌陷。

#### 4.1.3 检测元素重叠

```javascript
// 收集所有可见元素的位置
const rects = [];
document.querySelectorAll('body *:not(script):not(style)').forEach(el => {
  const r = el.getBoundingClientRect();
  if (r.width > 0 && r.height > 0) rects.push({ el, r });
});

// 按 left 坐标排序，使内循环可提前 break（x 方向无重叠则跳过）
rects.sort((a, b) => a.r.left - b.r.left);

// 预缓存 zIndex，避免在 O(n²) 内循环中重复调用 getComputedStyle
const zCache = new Map();
function getZ(el) {
  if (!zCache.has(el)) zCache.set(el, parseInt(getComputedStyle(el).zIndex) || 0);
  return zCache.get(el);
}

// 两两检测重叠
for (let i = 0; i < rects.length; i++) {
  for (let j = i + 1; j < rects.length; j++) {
    const a = rects[i], b = rects[j];
    // x 方向排序剪枝：b.left 已超过 a.right 则后续元素更远，提前 break
    if (b.r.left > a.r.right) break;

    // 排除父子关系（父包含子是正常重叠，非缺陷）
    if (a.el.contains(b.el) || b.el.contains(a.el)) continue;

    const overlap = !(a.r.right < b.r.left || a.r.left > b.r.right ||
                     a.r.bottom < b.r.top || a.r.top > b.r.bottom);
    if (!overlap) continue;

    const aZ = getZ(a.el), bZ = getZ(b.el);
    if (aZ !== bZ) continue; // 不同 z-index 的叠盖是刻意的

    const overlapArea = (Math.min(a.r.right, b.r.right) - Math.max(a.r.left, b.r.left)) *
                       (Math.min(a.r.bottom, b.r.bottom) - Math.max(a.r.top, b.r.top));
    const minArea = Math.min(a.r.width * a.r.height, b.r.width * b.r.height);
    if (overlapArea / minArea > 0.5) {
      problems.push({
        type: 'SUSPICIOUS_OVERLAP', severity: 'critical',
        a: getSelector(a.el), b: getSelector(b.el),
        parent_child: false
      });
    }
  }
}
```

> **优化说明**：x 方向排序剪枝将平均复杂度从 O(n²) 降至 O(n·k)（k 为水平方向重叠的邻居数）。父子元素排除消除了最高频的假阳性来源。zIndex 预缓存避免重复调用 `getComputedStyle`。

#### 4.1.4 多断点校验

```javascript
for (const vp of [375, 768, 1024, 1440]) {
  await page.setViewportSize({ width: vp, height: 900 });
  // 重复执行上述全部检测
}
```

确保原型在移动端、平板、桌面端均无缺陷。

#### 4.1.5 完整可运行脚本

将上述所有检测片段组装为一个可直接执行的 Playwright 脚本：

```javascript
// validate-prototype.js — 用法: node validate-prototype.js <url>
const { chromium } = require('playwright');

async function validatePrototype(url) {
  // URL 安全校验：仅允许 localhost 或预定义白名单域名，防止 SSRF
  const allowed = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?\//;
  if (!allowed.test(url)) {
    console.error('URL not allowed: ' + url);
    process.exit(2);
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();
  // 拦截跨域资源加载，防止原型页面加载外部跟踪脚本
  await page.route('**/*', route => {
    const reqUrl = route.request().url();
    if (reqUrl.startsWith('http://localhost') || reqUrl.startsWith('http://127.0.0.1')) {
      route.continue();
    } else {
      route.abort();
    }
  });
  // 放弃 networkidle（SPA 长/WebSocket 连接会导致永不触发）
  // 改用 domcontentloaded + 显式布局稳定检测
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 15000 });

  const allIssues = [];
  const breakpoints = [375, 768, 1024, 1440];

  for (const vp of breakpoints) {
    await page.setViewportSize({ width: vp, height: 900 });
    // 布局稳定检测：连续两次 requestAnimationFrame 后 scrollHeight 不变
    await page.waitForFunction(() => {
      return new Promise(resolve => {
        let h1 = document.body.scrollHeight;
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            resolve(document.body.scrollHeight === h1);
          });
        });
      });
    }, { timeout: 10000 }).catch(() => {}); // 超时不阻塞，继续检测

    const issues = await page.evaluate(() => {
      const problems = [];

      function getSelector(el) {
        let s = el.tagName.toLowerCase();
        if (el.id) s += '#' + el.id;
        const cls = typeof el.className === 'string' ? el.className : '';
        if (cls) s += '.' + cls.trim().split(/\s+/).join('.');
        return s;
      }

      // —— 1. 溢出检测 ——
      document.querySelectorAll('*').forEach(el => {
        if (el.scrollWidth > el.clientWidth + 1) {
          problems.push({
            type: 'OVERFLOW_X', severity: 'critical',
            selector: getSelector(el),
            detail: `scrollW=${el.scrollWidth} > clientW=${el.clientWidth}`
          });
        }
        if (el.scrollHeight > el.clientHeight + 1 &&
            getComputedStyle(el).overflowY === 'hidden') {
          problems.push({
            type: 'OVERFLOW_Y_CLIPPED', severity: 'critical',
            selector: getSelector(el)
          });
        }
      });

      // —— 2. 零尺寸检测 ——
      document.querySelectorAll('*').forEach(el => {
        const r = el.getBoundingClientRect();
        if (r.width <= 0 || r.height <= 0) {
          problems.push({
            type: 'ZERO_SIZE', severity: 'warning',
            selector: getSelector(el)
          });
        }
      });

      // —— 3. 重叠检测 ——
      const rects = [];
      document.querySelectorAll('body *:not(script):not(style)').forEach(el => {
        const r = el.getBoundingClientRect();
        if (r.width > 0 && r.height > 0) rects.push({ el, r });
      });
      for (let i = 0; i < rects.length; i++) {
        for (let j = i + 1; j < rects.length; j++) {
          const a = rects[i].r, b = rects[j].r;
          const overlap = !(a.right < b.left || a.left > b.right ||
                           a.bottom < b.top || a.top > b.bottom);
          if (!overlap) continue;
          const aZ = parseInt(getComputedStyle(rects[i].el).zIndex) || 0;
          const bZ = parseInt(getComputedStyle(rects[j].el).zIndex) || 0;
          if (aZ !== bZ) continue;
          const overlapArea = (Math.min(a.right, b.right) - Math.max(a.left, b.left)) *
                             (Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top));
          const minArea = Math.min(a.width * a.height, b.width * b.height);
          if (overlapArea / minArea > 0.5) {
            problems.push({
              type: 'SUSPICIOUS_OVERLAP', severity: 'critical',
              a: getSelector(rects[i].el), b: getSelector(rects[j].el)
            });
          }
        }
      }

      return problems;
    });

    allIssues.push({ viewport: vp, issues });
  }

  await browser.close();
  return allIssues;
}

// 执行
const url = process.argv[2] || 'http://localhost:3000';
validatePrototype(url).then(result => {
  console.log(JSON.stringify(result, null, 2));
  const totalCritical = result.flatMap(r => r.issues)
    .filter(i => i.severity === 'critical').length;
  process.exit(totalCritical > 0 ? 1 : 0); // 有 critical 缺陷则退出码 1
});
```

> **使用方式**：`npm install playwright && npx playwright install chromium && node validate-prototype.js http://localhost:3000`  
> 退出码 `0` = 无 critical 缺陷，`1` = 存在 critical 缺陷，可直接接入 CI/CD 流水线。

#### 4.1.6 DOM 检测边界情况

上述检测脚本需注意以下边界情况，根据项目实际情况补充处理：

| 边界情况 | 问题 | 处理方案 |
|----------|------|----------|
| **Shadow DOM** | `querySelectorAll('*')` 无法穿透 Shadow 边界，Web Components 内部节点不会被检测 | 递归遍历 `el.shadowRoot`，对每个 Shadow Root 执行相同的检测逻辑 |
| **iframe 内容** | `page.evaluate` 只在主 frame 执行，iframe 内部不会被检测 | 使用 `page.frames()` 遍历所有 frame，对每个 frame 执行 `frame.evaluate()` |
| **异步动态内容** | `domcontentloaded` 后仍有 setTimeout / requestAnimationFrame 触发的渲染 | 使用布局稳定检测（连续两帧 scrollHeight 不变），见 4.1.5 脚本 |
| **有意滚动容器** | `scrollHeight > clientHeight` 在可滚动列表上是正常行为，不应报为缺陷 | 检测 `overflowY === 'auto'` 或 `'scroll'` 时跳过（仅 `'hidden'` 才报 CLIPPED） |

**Shadow DOM 递归检测示例**：

```javascript
function collectAllElements(root = document) {
  const elements = [...root.querySelectorAll('*')];
  for (const el of elements) {
    if (el.shadowRoot) {
      elements.push(...collectAllElements(el.shadowRoot)); // 递归穿透 Shadow DOM
    }
  }
  return elements;
}
```

**iframe 遍历检测示例**：

```javascript
for (const frame of page.frames()) {
  const frameIssues = await frame.evaluate(() => {
    // 与主 frame 相同的检测逻辑
  });
  allIssues.push({ frame: frame.url(), issues: frameIssues });
}
```

### 4.2 截图 + 视觉模型审查（补充）

DOM 分析能抓到结构问题，但抓不到"视觉丑陋""层级不清""对齐不齐"这类主观问题。用多模态 LLM 做视觉评审：

```
[截图] → 视觉模型 → 输出：
{
  visual_hierarchy_score: 7,
  alignment_issues: ["标题与正文左边缘未对齐"],
  spacing_inconsistency: ["卡片间距不统一，有16px和24px混用"],
  overlapping_risk: "中等",
  suggestions: ["..."]
}
```

把截图喂给视觉模型，让它用预定义的评审 rubric 打分。这是"LLM-as-judge"在视觉域的应用。

### 4.3 无障碍审计

使用 `axe-core` 自动检测：

- 颜色对比度不足
- 缺少 alt 文本
- 键盘不可访问
- 语义化标签缺失

这一层同时提升了"易用性"维度。

### 4.4 视觉回归

如果有参考竞品的优秀界面截图，可做相似度对比 + 差异分析，确保设计确实"站在竞品肩膀上"而非闭门造车。

---

## 五、设计质量评分体系（让 AI 自证质量）

核心问题"AI 怎么知道它的设计满足要求"的答案是：**把主观要求拆解成可计算的指标。**

### 5.1 评分卡

| 维度 | 权重 | 评分方法 | 自动化程度 |
|------|------|----------|-----------|
| 视觉正确性 | 20% | DOM 分析缺陷数 = 0 | 全自动 |
| 响应式适配 | 15% | 4 个断点均无溢出 | 全自动 |
| 视觉层级 | 10% | 视觉模型评分 ≥ 7/10 | LLM 自动（非确定性） |
| 信息架构 | 10% | Playwright 实测任务路径深度 ≤ N | 全自动（Playwright 实测） |
| 一致性 | 15% | 设计 token 使用率 = 100% | 全自动 |
| 可访问性 | 10% | axe-core 0 critical | 全自动 |
| 竞品超越度 | 20% | LLM 对比特征矩阵 + Playwright 验证 | LLM + 程序混合 |

> **权重调整说明**：确定性检测维度（视觉正确性+响应式+一致性+可访问性+信息架构）总权重从 70% 提升至 70%，LLM 非确定性维度（视觉层级）从 15% 降至 10%。竞品超越度从 15% 提升至 20%，作为核心业务目标给予更高权重。信息架构从 LLM 推断改为 Playwright 实测，提升为全自动确定性维度。
>
> **自动化程度说明**：全自动 = 确定性程序检测；LLM 自动（非确定性）= LLM 评判+多次采样取中位数；LLM+程序混合 = LLM 判断+程序化验证。全维度均无人工参与。
>
> **信息架构 N 值定义**：N 按产品类型动态设置——信息展示型产品 N=3，ToB 企业级产品 N=5。任务路径深度由 Playwright 实际执行点击流测量，而非 LLM 推断。

### 5.2 评分公式

每个维度按 0-100 分打分，再按权重加权求和得到总分：

```
总分 = Σ(维度得分 × 权重)
```

各维度的得分换算规则：

| 维度 | 得分 = 100 的条件 | 得分 < 100 的换算 |
|------|-------------------|-------------------|
| 视觉正确性 | critical 缺陷数 = 0 | `100 - critical数 × 25 - warning数 × 5`，下限 0 |
| 响应式适配 | 4 个断点均无溢出 | `100 - 有溢出的断点数 × 25` |
| 视觉层级 | 视觉模型评分 = 10 | `视觉模型评分 × 10` |
| 信息架构 | 核心任务路径深度 ≤ 3 步 | `100 - max(0, 路径深度 - 3) × 20` |
| 一致性 | token 使用率 = 100% | `token使用率 × 100` |
| 可访问性 | axe-core critical = 0 | `100 - critical数 × 30 - serious数 × 10` |
| 竞品超越度 | 特征矩阵全部达标 | 按类别加权：`MustHave达标率×40 + Differentiator达标率×25 + Innovation达标率×20 + PainPoint改善率×15` |

**示例**：某原型 DOM 检测出 1 个 critical + 2 个 warning，3/4 断点无溢出，视觉模型评分 8，任务路径 4 步，token 使用率 95%，axe-core 0 critical 1 serious。竞品特征矩阵中 Must Have 达标率 100%、Differentiator 达标率 75%、Innovation 达标率 50%、Pain Point 改善率 80%。

```
视觉正确性: 100 - 25 - 10 = 65  → 65 × 0.20 = 13.0
响应式适配: 100 - 25 = 75        → 75 × 0.15 = 11.25
视觉层级:   8 × 10 = 80          → 80 × 0.15 = 12.0
信息架构:   100 - 20 = 80        → 80 × 0.15 = 12.0
一致性:     95 × 100 / 100 = 95  → 95 × 0.10 = 9.5
可访问性:   100 - 10 = 90        → 90 × 0.10 = 9.0
竞品超越度: 100×40+75×25+50×20+80×15 = 4000+1875+1000+1200 = 8075/100 = 80.75
           → 80.75 × 0.15 = 12.11
总分 = 13.0 + 11.25 + 12.0 + 12.0 + 9.5 + 9.0 + 12.11 = 78.86 → 不达标
```

### 5.3 视觉模型评分机制

为确保 LLM 视觉评分的稳定性与一致性，采用以下措施：

1. **固定 Prompt 模板**：每次评审使用相同的 rubric 描述，要求模型输出结构化 JSON（分数 + 具体问题列表）
2. **多次采样取中位数**：对同一截图调用 3 次，取中位数作为最终分数，降低单次波动
3. **温度设为 0**：最大化输出确定性（注意：温度=0 仍有微小随机性，容差区间可兜底）
4. **Few-shot 校准**：在 prompt 中附 2-3 个已标注分数的参考截图，校准评分尺度
5. **置信度惩罚**：3 次采样的标准差 > 1.5 时，取 `中位数 - 标准差` 作为保守得分；标准差 > 3 时标记为"低置信评分"，触发换模型交叉验证
6. **像素级检测分离**：LLM 视觉评审只负责宏观语义判断（"视觉层级是否清晰""信息密度是否合理"），像素级间距/对齐检测完全由 DOM 分析（`getComputedStyle` 读取实际值）完成
7. **评分与设计使用不同模型家族**：评分阶段使用的 LLM 必须与设计 Agent 使用的模型属于不同家族（如设计用 GLM，评分用 Claude），避免"左手检查右手"

### 5.3.1 放行容差区间

总分恰好落在 [83, 87] 区间时，放行/拒绝由 LLM 概率性波动决定，不可靠。处理策略：

- 总分 ∈ [83, 87] → 触发"边界复验"：LLM 维度增加采样至 7 次取中位数
- 复验后总分仍 ∈ [83, 87] → 引入第二个独立模型交叉验证，取两者中较低分（保守策略）
- 复验后总分 ≥ 85 → 放行；< 85 → 继续迭代

### 5.4 竞品超越度 LLM 评判机制

竞品超越度由 LLM 自动评判，无需人工。评判流程：

1. **输入**：原型截图 + 竞品特征矩阵（含每个功能的类别标注：Must Have / Differentiator / Innovation / Pain Point）
2. **LLM 任务**：逐项判断原型是否实现了特征矩阵中的每个功能，输出结构化 JSON：

```json
{
  "items": [
    { "feature": "订单管理", "category": "MustHave", "implemented": true, "evidence": "导航栏有订单入口" },
    { "feature": "实时协作", "category": "Differentiator", "implemented": false, "evidence": "未发现协作功能入口" },
    { "feature": "AI智能推荐", "category": "Innovation", "implemented": true, "evidence": "首页有推荐模块" }
  ]
}
```

3. **得分计算**：按类别加权（Must Have 权重最高，不达标影响最大）：

```
得分 = MustHave达标率×40 + Differentiator达标率×25 + Innovation达标率×20 + PainPoint改善率×15
```

4. **Must Have 一票否决**：如果任意 Must Have 项未实现，竞品超越度直接判 0 分，并标记为 critical 缺陷。一票否决前需二次确认（换模型重新检查该特定功能项 + Playwright 验证功能入口可达），避免因单次幻觉导致全盘否决
5. **evidence 可验证化**：LLM 输出的 evidence 字段必须包含可程序化验证的 DOM 定位信息（CSS selector），由 Playwright 验证该元素是否真实存在。仅截图可见但 DOM 中不存在的"功能"判为未实现

### 5.5 放行规则

- 总分 ≥ 85 **且**无 critical 缺陷 **且**竞品超越度 ≥ 70 → 放行进入自动终审（多 LLM 共识，详见第十一章）
- 总分 < 85 或竞品超越度 < 70 → 自动进入迭代循环
- 总分 ∈ [83, 87] → 触发边界复验（见 5.3.1）
- 迭代超过最大次数（默认 10 次）→ 触发策略回退（回退到评分最高的检查点 + 依次切换设计策略 A→B→C，详见 11.3）
- Must Have 项持续无法实现 → 触发策略回退（可能是设计策略问题而非修复问题）

没有量化标准，就无法判断"超越竞品"是否达成。评分卡是整个方法论的度量基石。

---

## 六、多 Agent 评审架构

不要用单个 AI 既设计又评审（存在自我盲区）。使用**角色分离的多 Agent**：

```
┌─────────────────┐
│   Orchestrator  │  管理循环、聚合结果
└───────┬─────────┘
        │
        ├── 研究 Agent     采集竞品，输出特征矩阵
        ├── 分析 Agent     差距分析，输出设计规格
        ├── 设计 Agent     生成原型代码
        ├── 渲染 Agent     执行 Playwright 校验，输出缺陷列表
        ├── 视觉评审 Agent  截图 + 视觉模型，输出视觉问题
        ├── 无障碍 Agent   axe-core 审计
        ├── 用户视角 Agent  模拟认知走查，检查易用性
        └── 批判 Agent     综合所有反馈，生成修复指令
```

### 关键原则

- **批判 Agent 和设计 Agent 必须是不同的会话/上下文**，否则会有"确认偏差"——自己写的代码自己倾向于认为没问题。
- 每个 Agent 有明确的输入/输出契约，便于工程化编排。
- Orchestrator 负责调度、收敛判定、超时控制。

### 6.1 执行编排：串行与并行

Agent 分为三个阶段，阶段间串行，阶段内并行：

```
阶段一（串行，一次性）：
  研究 Agent → 分析 Agent → 设计 Agent
  （前者的输出是后者的输入，必须串行）

阶段二（并行，每轮迭代）：
  ┌─ 渲染 Agent ──────────┐
  ├─ 视觉评审 Agent ──────┤  同时执行，各自独立输出
  ├─ 无障碍 Agent ────────┤
  └─ 用户视角 Agent ──────┘
           ↓ 汇总
       批判 Agent（串行，聚合所有反馈后生成修复指令）

阶段三：修复指令 → 回到设计 Agent → 重新进入阶段二
```

### 6.2 Agent 数据契约

每个 Agent 有明确的输入/输出 JSON Schema：

| Agent | 输入 | 输出 |
|-------|------|------|
| 研究 Agent | 竞品名称列表 + URL | `FeatureMatrix[]`（功能名、竞品覆盖情况、用户反馈） |
| 分析 Agent | `FeatureMatrix[]` | `DesignSpec`（信息架构、页面清单、组件需求、内容边界） |
| 设计 Agent | `DesignSpec` + `DesignTokens` + 修复指令(可选) | 原型代码文件 |
| 渲染 Agent | 原型 URL | `DefectList[]`（type、severity、selector、detail） |
| 视觉评审 Agent | 截图 PNG | `VisualReport`（score 0-10、alignment_issues[]、suggestions[]） |
| 无障碍 Agent | 原型 URL | `AxeReport`（critical 数、serious 数、详细违规列表） |
| 用户视角 Agent | 原型 URL + 任务列表 | `UsabilityReport`（任务路径深度、痛点列表） |
| 批判 Agent | 上述所有报告 | `FixInstructions[]`（文件路径、修改描述、优先级） |

### 6.3 上下文隔离策略

- **设计 Agent**：只接收 `DesignSpec` + `DesignTokens` + `FixInstructions`，不接触评审报告原文（避免被评分影响自我辩护）
- **批判 Agent**：接收所有评审报告 + 当前代码，但不接收设计 Agent 的"设计意图说明"（避免被辩解说服）
- **实现方式**：每个 Agent 是独立的 LLM 调用会话，通过文件系统或消息队列传递 JSON 数据，不共享对话历史

### 6.4 推荐实现框架

- **轻量方案**：Node.js 脚本 + 直接调用 LLM API，Agent 间通过 JSON 文件传递数据
- **中量方案**：LangChain / LangGraph，利用其 Agent 编排能力
- **重量方案**：自研编排服务，支持 Agent 注册、任务调度、结果聚合、可视化监控

---

## 七、迭代收敛机制

```
generate(spec) → validate() → score() → save_checkpoint()
  → if score >= threshold:
      auto_consensus_review()
        → PASS → finalize（交付）
        → FAIL → 缺陷反馈传入批判 Agent，重置迭代计数器 → loop
  → else if iterations > max (默认 10):
      strategy_rollback()
        → 回退到评分最高的检查点
        → 依次切换策略（A→B→C）
        → 重置迭代计数器 → loop
      if 策略回退次数 > 3:
        回退到分析 Agent 重新生成 DesignSpec
        if DesignSpec 重生成次数 > 2:
          降级交付（需满足底线：Must Have 100% 覆盖 + axe-core 0 critical + 总分 ≥ 60）
          不满足底线 → 拒绝交付，标记为"生成失败" → finalize
  → else:
      collect_all_issues() → prioritize() → refine(spec, issues) → loop
```

> **检查点保存**：每轮迭代完成后自动保存当前版本的代码 + 评分 + 缺陷列表为检查点，供策略回退使用。

### 设计要点

1. **增量修复**：每次迭代只修上次没通过的部分，不推翻重来，避免反复震荡
2. **优先级排序**：critical 缺陷先修，视觉层级问题后修
3. **防死循环**：设最大迭代次数（默认 10 次），超过则触发策略回退（回退到评分最高的检查点 + 依次切换设计策略 A→B→C），最多 3 次回退；仍不达标则重生成 DesignSpec，最多 2 次；最终兜底为降级交付评分最高的版本
4. **可追溯**：每次迭代的缺陷列表、修复动作、评分变化均记录存档

### 7.1 震荡检测与处理

迭代过程中可能出现"震荡"——修复 A 缺陷引入 B 缺陷，修复 B 又引入 A，无限往复。检测与处理策略：

| 检测信号 | 判定条件 | 处理策略 |
|----------|----------|----------|
| 评分不升反降 | 连续 2 轮总分下降 | 回退到上一轮版本，将问题标记为顽固缺陷，触发策略回退 |
| 缺陷反复出现 | 同一缺陷在第 N 轮修复后第 N+2 轮复现 | 标记为"顽固缺陷"，切换至深度分析模式（LLM 重新分析根因后重试） |
| 修复引入新缺陷 | 修复后 critical 数不降反增 | 拒绝本次修复，回退代码，要求批判 Agent 重新生成修复方案 |

### 7.2 各环节失败模式与兜底

| 环节 | 失败模式 | 兜底策略 |
|------|----------|----------|
| Playwright 渲染 | 原型 JS 报错导致页面白屏 | 捕获 `pageerror` 事件，将 JS 错误作为 critical 缺陷反馈给设计 Agent |
| Playwright 超时 | `domcontentloaded` + 布局稳定检测仍超时 | 设置 10s 超时上限，超时不阻塞检测流程（布局未稳定时检测结果标注为"低置信度"） |
| LLM 视觉评审 | 返回非 JSON 或字段缺失 | 重试 1 次；仍失败则启用 JSON mode / function calling 强制结构化输出 |
| LLM 视觉评分不一致 | 3 次采样分差 > 3 分 | 增加采样至 5 次取中位数 + 换用不同模型交叉验证 |
| axe-core 执行失败 | 页面结构异常导致 axe 崩溃 | 可访问性维度判 0 分并产生 1 个 critical 缺陷（无法验证可访问性本身就是高风险），不得跳过 |
| 设计 Agent 生成无效代码 | ESLint/stylelint 全部报错 | 将 lint 错误列表直接回传给设计 Agent，要求重新生成 |
| 研究 Agent 采集失败 | 竞品站点不可访问/反爬 | 降级为仅基于公开文档和搜索引擎结果推断功能 |
| 分析 Agent 分类不确定 | 特征矩阵中某功能难以判定类别 | 标记为"待定"，在后续评分中按 Must Have（最严格）处理 |
| 验收测试用例缺失 | 核心任务路径未定义 | 由分析 Agent 从 DesignSpec 自动提取核心任务列表，生成 Playwright 测试脚本 |

### 7.3 架构状态机与崩溃恢复

Orchestrator 使用显式状态机管理生命周期，确保任何环节崩溃后可恢复：

```
状态枚举：
  INIT → RESEARCH → ANALYSIS → DESIGN → ITERATING → SCORING → CONSENSUS → ACCEPTANCE → DELIVERED
  异常状态：ROLLBACK → RESPEC → DEGRADED_DELIVERY

每轮迭代的中间产物使用带版本号的原子写入：
  1. 先写入临时文件：checkpoint_{iter}_{phase}.tmp
  2. 写入完成后 rename 为正式文件：checkpoint_{iter}_{phase}.json（rename 是原子操作）
  3. Orchestrator 启动时扫描最新正式文件，恢复到对应状态
```

### 7.4 检查点存储与清理策略

| 策略 | 规则 |
|------|------|
| 保留策略 | 仅保留评分 top-3 的检查点 + 最近 3 轮的检查点 |
| 存储格式 | 增量 diff（git 对象格式），非全量拷贝 |
| 截图压缩 | 按断点维度压缩存储，单检查点截图 ≤ 5MB |
| 总存储预算 | ≤ 500MB，超限时自动淘汰低分检查点 |
| 清理时机 | 每轮迭代完成后执行保留策略清理 |

### 7.5 成本预算与调用上限

| 预算项 | 上限 | 超限处理 |
|--------|------|----------|
| LLM API 总调用次数 | ≤ 100 次/原型 | 强制降级交付当前最优版本 |
| LLM API 总 token 消耗 | ≤ 2M tokens | 强制降级交付 |
| 总执行时间 | ≤ 2 小时 | 强制降级交付 |
| 单轮迭代时间 | ≤ 10 分钟 | 跳过当前轮次的 LLM 视觉评审（降为纯 DOM 检测） |

**成本优化策略**：

1. **模型分级**：设计 Agent 使用低成本模型（如 GLM-4-Flash / GPT-4o-mini），仅评分和终审使用高端模型
2. **采样降级**：前 3 轮迭代视觉评审仅 1 次采样（快速筛选），第 4 轮起升级为 3 次采样
3. **缓存复用**：未修改页面的 DOM 检测结果和截图可跨轮复用，跳过重复检测

### 7.6 上下文窗口管理

增量修复过程中，设计 Agent 的输入会随迭代轮次增加而膨胀。管理策略：

1. **滑动窗口**：设计 Agent 只接收"当前代码快照 + 当前待修复缺陷列表"，不传入历史修复指令
2. **代码快照压缩**：当输入 token 接近上下文窗口上限（如 100K tokens）时，自动移除注释、空行、已修复的缺陷历史
3. **震荡关联检测**：当检测到震荡时，首先检查是否因上下文过长导致模型遗忘早期修复（而非直接切换策略）

---

## 八、竞品分析与超越策略

### 8.1 竞品信息采集

AI 自动采集以下维度的信息，无需人工提供数据：

| 维度 | 采集内容 | 自动化采集方式 |
|------|----------|----------------|
| 功能清单 | 核心功能、辅助功能、差异化功能 | LLM 搜索竞品官网/产品页，提取功能列表 |
| 交互流程 | 主任务路径、关键操作步骤数 | Playwright 自动遍历竞品站点（如有公开访问），记录操作路径 |
| 信息架构 | 导航结构、页面层级、功能入口 | 爬取竞品站点 DOM，LLM 分析导航结构与页面层级 |
| 视觉风格 | 配色、字体、间距、组件样式 | 截图 + LLM 视觉分析提取设计特征 |
| 技术实现 | 公开的技术文档、架构信息 | 搜索竞品公开文档/GitHub/技术博客，LLM 提取要点 |
| 用户反馈 | 公开评价、痛点、抱怨 | 爬取应用商店评论/G2/Trustpilot 等公开评价，LLM 聚类提取痛点 |

> **采集约束**：仅采集公开可访问的信息，遵守目标站点的 robots.txt 和服务条款。无法自动访问的竞品（如需登录），由 LLM 基于公开文档和评价推断其功能与交互。

### 8.2 特征矩阵与差距分析

输出一张竞品功能矩阵，标注每个功能。分类规则由 LLM 自动判定：

- **Must Have**：所有竞品都有，必须实现
- **Differentiator**：部分竞品有，可作为差异化点
- **Innovation**：竞品都没有，基于用户痛点创新
- **Pain Point**：竞品做得差，明确超越方向

### 8.3 超越验证

设计完成后，对照特征矩阵逐项验证：

- Must Have 项是否全部覆盖且体验不劣于竞品
- Differentiator 项是否做了增强
- Innovation 项是否真正解决了痛点
- Pain Point 项是否明显改善

这一步是"竞品超越度"评分的依据。

### 8.4 输入质量门禁（垃圾输入检测）

所有下游环节都假设上游输入正确，但 LLM 采集可能出错。在关键传递节点设置质量门禁：

| 门禁点 | 校验内容 | 不通过处理 |
|--------|----------|------------|
| 特征矩阵交叉验证 | 同一功能至少 2 个独立来源确认才采信 | 标记"单源未验证"，评分时按 50% 置信度处理 |
| 特征矩阵完整度 | 每个竞品至少覆盖 N 个功能维度 | 低于阈值触发补充采集 |
| 用户反馈噪声过滤 | 过滤极端值（1星/5星偏置评论），痛点至少被 M 条独立评论提及 | 噪声评论不纳入聚类 |
| DesignSpec 完备性 | DesignSpec 必须覆盖特征矩阵中所有 Must Have 项 | 拒绝进入设计阶段，回退到分析 Agent |
| 特征分类置信度 | 分类不确定时输出置信度 | 低置信度项标记"待确认"，不自动按 Must Have 处理，而是触发二次分析 |

---

## 九、推荐技术栈

| 层 | 工具 | 用途 |
|----|------|------|
| 原型生成 | React + Tailwind CSS | 约束在 token 体系内生成可运行代码 |
| 真实渲染 | Playwright | 无头浏览器渲染原型 |
| DOM 缺陷检测 | Playwright + 自定义 evaluate 脚本 | 程序化扫描缺陷 |
| 截图视觉审查 | 多模态 LLM（GPT-4o / Claude） | 主观视觉质量评审 |
| 无障碍审计 | axe-core | 自动化可访问性检测 |
| 视觉回归 | Playwright snapshot + pixelmatch | 界面变化对比 |
| 设计系统 | Storybook + Style Dictionary | 组件库 + 设计 token 管理 |
| 流水线编排 | Node.js 脚本 | 无需重型框架，保持轻量 |

### 9.1 前置条件与环境要求

在开始实施前，需准备以下环境：

| 类别 | 要求 | 版本/说明 |
|------|------|-----------|
| Node.js | ≥ 18 LTS | Playwright 和 axe-core 的运行基础 |
| 包管理器 | npm / pnpm | 推荐 pnpm（更快、磁盘占用更小） |
| 浏览器引擎 | Chromium | 通过 `npx playwright install chromium` 安装 |
| Playwright | ≥ 1.40 | 无头渲染与截图 |
| axe-core | ≥ 4.8 | 无障碍审计 |
| React | ≥ 18 | 原型生成框架 |
| Tailwind CSS | ≥ 3.4 | 设计 token 约束执行 |
| stylelint | ≥ 15 | 任意值禁止规则 |
| ESLint | ≥ 8 | 布局规则自定义检测 |
| LLM API | 多模态模型 | 视觉评审需要支持图像输入的模型 |
| 本地 HTTP 服务 | vite / http-server | 为 Playwright 提供原型访问 URL |

**环境验证命令**：

```bash
node -v              # 确认 ≥ 18
npx playwright --version  # 确认 Playwright 已安装
npx playwright install chromium  # 安装浏览器引擎
```

**项目结构建议**：

```
project/
├── design-tokens/        # Style Dictionary 管理的设计令牌
│   └── tokens.json
├── components/           # 经过视觉校验的组件库
├── prototypes/           # AI 生成的原型页面
├── scripts/
│   ├── validate-prototype.js   # DOM 缺陷检测脚本
│   ├── visual-review.js        # LLM 视觉评审脚本
│   └── score.js                # 评分计算脚本
├── reports/              # 每轮迭代的缺陷报告与评分记录
└── tailwind.config.js    # 设计 token 约束配置
```

---

## 十、落地实施路径

### 阶段一：地基建设（3-4 周）

1. 定义设计 token 体系（颜色、字体、间距、栅格、圆角）
2. 搭建经过视觉校验的基础组件库（最小范围：8-10 个核心组件——按钮/卡片/表单/表格/导航/弹窗/列表/标签页）
3. 制定布局规则与内容边界规范
4. 配置 Tailwind 约束（`tailwind.config.js` 限制 theme + `eslint-plugin-tailwindcss` 的 `no-custom-classname` 拦截非白名单类名 + 禁用任意值模式 `p-[13px]`）

> 先建约束，再放生成。地基不稳，上层全部白费。组件库质量直接决定整个方法论上限，不可压缩此阶段时间。

### 阶段二：校验能力建设（2-3 周）

1. 搭建 Playwright 渲染 + DOM 检测脚本（含父子元素排除、x 排序剪枝、布局稳定检测）
2. 接入 axe-core 无障碍审计（所有路由页面分别执行）
3. 接入多模态 LLM 视觉评审（含置信度惩罚、像素级检测分离）
4. 实现评分卡计算逻辑（含容差区间、边界复验）

> 先做 DOM 校验（确定性强、成本低），再做视觉模型校验。

### 阶段三：闭环管线集成（2-3 周）

1. 实现生成 → 校验 → 评分 → 迭代的自动化循环
2. 实现多 Agent 编排（含状态机、原子写入、崩溃恢复）
3. 实现迭代收敛与策略回退机制（含检查点存储清理、上下文窗口管理）
4. 实现多 LLM 共识终审（3 个不同模型家族 + 仲裁 Agent + rubric + 循环上限）
5. 实现自动化验收测试套件（含独立测试 Agent、交互状态测试、负面路径测试）
6. 实现成本预算与调用上限监控

### 阶段四：试运行验证（1-2 周）

1. 用 1-2 个真实产品场景验证管线端到端可用性
2. 调整评分阈值和迭代策略
3. 验证成本和时间是否符合预算预期

### 阶段五：竞品对标与调优（持续）

1. 导入竞品特征矩阵
2. 跑通端到端流程
3. 调优评分阈值与迭代策略
4. 评分阈值自动调优（根据历史迭代数据动态调整，**硬性下限 80 分**，每次调整幅度 ≤ 2 分，连续下调超 3 次自动冻结并告警）

---

## 十一、自动化终审机制（零人工参与）

全流程不设任何人工检查点。原先需要人工判断的环节，全部通过以下自动化机制替代：

### 11.1 多 LLM 共识终审

评分达标后，不进入人工终审，而是由 **3 个独立 LLM 实例**各自独立完成终审评审。为最大化独立性，**强制要求使用 3 个不同模型家族**（如 GLM + Claude + GPT-4o），同家族模型即使 prompt 不同也不允许复用：

```
原型截图 + DesignSpec + 特征矩阵 + 评分报告
         ↓
  ┌── LLM-A（模型家族1，角色：产品经理视角）
  ├── LLM-B（模型家族2，角色：设计师视角）     → 各自输出 PASS/FAIL + 理由
  └── LLM-C（模型家族3，角色：用户视角）
         ↓
  3/3 PASS → 自动交付
  2/3 PASS → 触发仲裁 Agent（使用第 4 个不同模型）做决胜评审
  0-1/3 PASS → 缺陷反馈传入批判 Agent，重置迭代计数器重新迭代
  有 LLM 实例失败 → 重试该实例 1 次；仍失败则用剩余实例，需 2/2 PASS 才放行
```

**终审 rubric（各角色评判标准）**：

| 角色 | PASS 条件 | FAIL 条件 |
|------|-----------|-----------|
| 产品经理视角 | DesignSpec 中所有核心功能可识别且有清晰入口 | 核心功能缺失或入口隐蔽不可达 |
| 设计师视角 | 视觉层级清晰、间距一致、无明显对齐问题 | 层级混乱、间距不一致、对齐错误 |
| 用户视角 | 核心任务路径 ≤ 3 步可走通，无认知障碍 | 任务路径断裂或步骤过多 |

> **终审循环上限**：终审不通过最多重试 3 次（每次重置迭代计数器重新迭代）。3 次终审仍不通过 → 触发策略回退（见 11.3）。

| 规则 | 说明 |
|------|------|
| 模型多样性 | 强制 3 个不同模型家族（如 GLM + Claude + GPT-4o），同家族不允许复用 |
| 独立性 | 3 个 LLM 实例不共享上下文，各自独立评审 |
| 共识判定 | 3/3 PASS 直接放行；2/3 PASS 触发仲裁 Agent 决胜；0-1/3 PASS 回炉 |
| 角色差异 | 每个 LLM 持有不同评审视角（产品/设计/用户），避免单一视角盲区 |
| 计数器重置 | 终审不通过回炉时重置迭代计数器，但保留历史缺陷记录供批判 Agent 参考 |
| 可追溯 | 每个 LLM 的 PASS/FAIL 理由均存档记录 |

### 11.2 自动化替代对照表

| 原人工环节 | 自动化替代机制 | 实现方式 |
|------------|----------------|----------|
| 设计规格确认 | **LLM 规格校验** | LLM 检查 DesignSpec 是否覆盖特征矩阵中所有 Must Have 项 |
| 评分达标终审 | **多 LLM 共识** | 见 11.1，3 个不同模型家族独立评审，3/3 PASS 放行或 2/3 触发仲裁 |
| 迭代超限介入 | **策略回退** | 回退到评分最高的检查点，依次切换设计策略 A→B→C，重新生成 |
| 最终交付验收 | **自动化验收测试套件** | Playwright 端到端测试：模拟用户操作走通所有核心任务路径 + 全断点 DOM 无缺陷 + axe-core 0 critical + 全维度评分达标 |

### 11.3 策略回退机制

当迭代超过最大次数仍不达标时，不升级到人工，而是自动执行策略回退：

```
当前策略迭代失败（10轮未达标）
    ↓
回退到迭代过程中评分最高的检查点版本
    ↓
切换设计策略：
  - 方案A：换用不同的布局结构（如从侧边栏切换到顶部导航）
  - 方案B：换用不同的组件组合
  - 方案C：简化信息架构，减少页面元素密度
    ↓
以新策略重新进入迭代循环（重置迭代计数器）
    ↓
最多允许 3 次策略回退（每次 10 轮，共 30 轮迭代）
    ↓
仍不达标 → 标记为"需规格层面调整"，回退到分析 Agent 重新生成 DesignSpec
    ↓
DesignSpec 变更后，重新校验特征矩阵覆盖度（Must Have 项仍须全部覆盖）
```

### 11.4 全自动质量保障链

```
约束拦截（编译期） → DOM检测（渲染期） → LLM视觉评审 → 多维度评分 
→ 多LLM共识终审 → 自动化验收测试 → 交付
```

每一层都有自动化的通过/失败判定，任何一层不通过都不会进入下一层。全链路零人工。

### 11.5 自动化验收测试套件

终审通过后、交付前，执行自动化验收测试套件作为最后一道关：

| 测试类别 | 测试内容 | 实现方式 | 通过条件 |
|----------|----------|----------|----------|
| 功能完整性 | 所有 Must Have 功能入口可达 | Playwright 遍历每个功能入口，验证页面加载无 404/白屏 | 100% 可达 |
| 任务路径 | 核心任务路径可走通 | **独立测试 Agent**（非分析 Agent）从特征矩阵提取 Must Have 项，生成 Playwright 测试脚本 | 全部任务路径走通 |
| 响应式 | 4 个断点无 critical 缺陷 | 复用 4.1.5 的 validate-prototype.js | 0 critical |
| 无障碍 | axe-core 0 critical | axe-core 自动审计（所有路由页面分别执行） | 0 critical |
| 评分复验 | 全维度评分仍达标 | 重新执行评分计算 | 总分 ≥ 85 |
| 交互状态 | 关键组件状态转换正确 | Playwright 验证按钮点击后 loading/成功/失败状态、模态框开关 | 全部 PASS |
| 负面路径 | 非法输入/空数据/超长文本容错 | 自动注入边界内容（超过 maxChars 的文本、空列表），验证 ellipsis/占位提示/校验提示 | 全部 PASS |

**测试用例独立性保障**：

测试用例不由分析 Agent（DesignSpec 生成者）生成，而由**独立测试 Agent**生成。独立测试 Agent 仅接收特征矩阵（竞品数据），不接收 DesignSpec，独立推导应测试的任务路径。两份任务列表做交集校验：

```
独立测试 Agent 从特征矩阵提取 Must Have 功能列表
    ↓
为每个 Must Have 生成 Playwright 测试脚本（基于功能定义，非 DesignSpec）
    ↓
与分析 Agent 的任务列表做交集：
  - 交集部分 → 执行测试
  - 仅分析 Agent 有的任务 → 标记"覆盖争议"（可能分析 Agent 编造了非必要功能）
  - 仅独立测试 Agent 有的任务 → 标记"覆盖争议"（可能分析 Agent 遗漏了 Must Have）
    ↓
执行全部测试脚本 → 全部 PASS → 交付
                 → 任一 FAIL → 缺陷反馈回迭代循环
```

---

## 十二、安全与合规

### 12.1 竞品数据采集合规

| 风险 | 缓解措施 |
|------|----------|
| 著作权侵权（界面设计复刻） | 仅采集功能清单和用户反馈等事实性信息，禁止像素级复刻竞品界面设计元素（配色/字体/布局结构） |
| 服务条款违规（自动化爬取） | 默认方案仅使用公开 API、官方文档、搜索引擎索引页；Playwright 遍历竞品站点为可选项，需法务确认合规性后方可启用 |
| 反爬触发 | 增加 anti-bot 检测（页面标题/内容异常检测），检测到反爬立即中止并切换降级路径 |
| 用户评价含个人信息 | 爬取评价时去除用户名/头像等可识别信息，仅保留评论文本和评分 |

### 12.2 数据安全与脱敏

| 措施 | 说明 |
|------|------|
| 数据分级 | 竞品名称/商标/可识别特征 → 脱敏后发送给 LLM；DesignSpec/原型代码 → 可发送（非机密） |
| LLM 服务商 DPA | 与第三方 LLM 服务商签署数据处理协议，明确禁止将输入数据用于模型训练 |
| API 调用审计 | 记录每次 LLM 调用的输入摘要（哈希）、输出摘要、时间戳、模型版本、调用者 Agent ID |
| 本地降级 | 敏感数据场景下使用本地部署模型替代第三方 API |

### 12.3 审计追溯

全流程审计日志架构：

| 日志类别 | 记录内容 | 保留期限 |
|----------|----------|----------|
| LLM 调用日志 | 时间戳、Agent ID、模型版本、prompt 模板版本、输入/输出哈希 | ≥ 3 年 |
| 竞品采集日志 | URL、访问时间、采集内容摘要、robots.txt 检查结果 | ≥ 3 年 |
| 评分日志 | 每次采样的原始分数、标准差、最终得分 | ≥ 3 年 |
| 策略回退日志 | 触发原因、回退检查点、切换的策略方案 | ≥ 3 年 |
| 交付日志 | 交付版本、评分、降级标记（如有）、决策链路 | ≥ 3 年 |

> 日志写入 append-only 存储，禁止修改。关键决策节点（策略回退、降级交付、终审分歧）的日志应支持导出为独立审计报告。

### 12.4 供应链安全

| 措施 | 说明 |
|------|------|
| Lockfile 强制校验 | CI 中使用 `--frozen-lockfile`，禁止运行时修改依赖版本 |
| 依赖漏洞扫描 | 每次 CI 运行 `npm audit`，高危漏洞阻断流水线 |
| LLM API 安全评估 | 审查服务商 ISO 27001/SOC 2 认证，签署 DPA |
| Playwright 沙箱 | 运行环境使用 Docker 容器 + 网络白名单，禁止原型代码访问内网 |
| AI 代码静态扫描 | 检测生成代码中的 `fetch`/`XMLHttpRequest`/`eval` 等危险调用 |

### 12.5 知识产权声明

- 所有 AI 生成物在交付时标注"AI 辅助生成"及使用的模型版本、生成日期
- 对 AI 生成代码进行原创性检查（与开源代码库做相似度比对），避免输出训练数据中的受保护代码

---

## 十三、总结

把"AI 自由设计原型"变成：

> **AI 在设计系统约束下生成 → 真实渲染做 DOM 级缺陷检测 → 多 Agent 多维度评分 → 不达标自动迭代修复 → 多 LLM 共识自动终审**

的闭环工程管线。

- **错误在约束中预防**：设计 token、组件库、布局规则在上游消除 80% 的问题
- **问题在渲染中暴露**：Playwright 真实渲染 + DOM 分析精确检测溢出/覆盖/错位
- **质量在评分中量化**：7 维评分卡让"超越竞品"从口号变成可计算的指标
- **缺陷在迭代中消除**：闭环收敛机制自动修复，超限触发策略回退，全流程零人工

这套方法论的核心价值：**把不可控的 AI 创意生成，转化为可度量、可收敛、可复现、零人工的工程过程。**

---

## 附录：评审变更记录

本文档经过 10 轮评审迭代，每轮发现问题即修改，变更记录如下：

| 轮次 | 评审重点 | 发现与修复内容 |
|------|----------|----------------|
| 第 1 轮 | 代码技术正确性 | 修复 `problems` 变量未声明、SVG `className` 崩溃、`+zIndex` 语义不清、O(n²) 性能无提示 |
| 第 2 轮 | 可执行性补全 | 新增 4.1.5 完整可运行 Playwright 脚本，含初始化、多断点循环、退出码 |
| 第 3 轮 | 评分体系完善 | 定义 N=3、新增评分公式与部分得分换算表、LLM 视觉评分稳定性机制 |
| 第 4 轮 | 约束执行机制 | 新增 3.5 节，说明 Tailwind/stylelint/ESLint/TypeScript 如何强制执行 token 约束 |
| 第 5 轮 | 多 Agent 实现 | 新增 6.1-6.4：串并行编排、数据契约表、上下文隔离策略、实现框架推荐 |
| 第 6 轮 | 失败模式与兜底 | 新增 7.1 震荡检测、7.2 各环节失败模式与兜底策略表 |
| 第 7 轮 | 一致性校验 | 修复流程图顺序与伪代码矛盾、统一最大迭代次数为 10 次 |
| 第 8 轮 | 前置条件 | 新增 9.1 环境要求表、验证命令、项目结构建议 |
| 第 9 轮 | DOM 检测边界 | 新增 4.1.6：Shadow DOM/iframe/异步内容/有意滚动容器处理方案 |
| 第 10 轮 | 终审打磨 | 版本号升级 v2.0、添加变更记录、全文编号与格式终审 |
| 修订 | 零人工改造 | 移除全部人工检查点，第 11 节重写为自动化终审机制（多 LLM 共识 + 策略回退 + 自动验收测试）；评分卡竞品超越度改为全自动；版本升级 v2.1 |
| R1 | 终审机制逻辑 | 修复 LLM 模型多样性、终审回炉计数器、策略回退硬编码、DesignSpec 变更校验、验收测试实现方式 |
| R2 | 竞品超越度评分 | 消除"半自动"歧义、分类加权公式、新增 5.4 LLM 评判机制（JSON 输出 + Must Have 一票否决） |
| R3 | 策略回退逻辑 | 伪代码条件优先级、检查点保存时机、策略依次切换、DesignSpec 重生成上限、降级交付兜底 |
| R4 | 多 LLM 共识 | 补 DesignSpec 输入、LLM 实例失败处理、终审 rubric、终审循环上限、落地路径补充 |
| R5 | 全链路断点 | 竞品采集自动化方式、特征分类自动化、验收测试用例来源、前端 Agent 失败模式 |
| R6 | 交叉引用 | 共识规则表同步（3/3 + 2/3 分级）、对照表同步 |
| R7 | 评分衔接 | 放行规则策略回退同步、Must Have 持续失败处理、评分示例新公式重算 |
| R8 | 验收测试套件 | 新增 11.5（5 类测试 + 通过条件 + 测试用例自动生成流程） |
| R9 | 术语一致性 | 策略回退描述同步、30 轮计算明确、Agent 命名一致 |
| R10 | 终审打磨 | 版本号 v3.0、变更记录追加、全文终审 |
| D1 | 代码技术（工程架构师对抗） | 重叠检测排除父子元素+x排序剪枝+zIndex缓存、networkidle 替换为布局稳定检测、waitForTimeout 不一致修复 |
| D2 | 架构与成本（工程架构师+AI/ML 对抗） | 新增 7.3-7.6：状态机崩溃恢复、检查点存储清理、成本预算与调用上限（≤100次/2M tokens/2h）、上下文窗口管理 |
| D3 | 评分可信度（AI/ML+QA 对抗） | 权重调整（竞品超越度升至 20%）、容差区间 [83,87] 边界复验、置信度惩罚、终审强制 3 个不同模型家族+仲裁、竞品超越度独立门槛≥70、evidence 可验证化 |
| D4 | 安全合规与自验证循环（安全专家+QA 对抗） | 新增第十二章安全与合规（5 节）、验收测试引入独立测试 Agent+交集校验、新增交互状态/负面路径测试、降级交付硬性底线、axe-core 失败不得跳过、8.4 输入质量门禁 |
| D5 | 产品适配与落地性（产品经理对抗） | 落地时间修正（阶段一 3-4 周/阶段三 2-3 周/新增阶段四试运行）、Tailwind 约束精确化（eslint-plugin-tailwindcss）、阈值漂移防护（下限 80+冻结告警）、Playwright URL 安全校验+跨域拦截 |
| G1-G6 | 可执行代码补全 | 新增 7 个可运行代码文件：orchestrator.js（主编排）、llm-client.js（多模型 API 封装+成本追踪+共识终审）、checkpoint-manager.js（原子写入+崩溃恢复）、axe-audit.js（多路由审计）、scoring.js（7 维评分公式）、agent-prompts.js（8 Agent+终审+仲裁+测试 Prompt 模板）、.eslintrc.js+stylelint.config.js（约束配置）、package.json |

---

*文档结束*
