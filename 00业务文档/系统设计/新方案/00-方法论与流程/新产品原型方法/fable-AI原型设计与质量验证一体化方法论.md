# fable-AI 原型设计与质量验证一体化方法论

> 版本：v1.0
> 日期：2026-07-10
> 类型：方法论文档
> 上游规范：《00-总纲-知识库与产品交付双循环研发流程.md》、《01-方法论-多竞品逆向学习与产品设计知识库.md》、《06-规范-AI_UI质量保障流程规范.md》
> 下游规范：《02-流程-知识库驱动新产品创建与迭代.md》阶段 5A 设计决策工作流
> 关系：本方法是 06-规范-AI_UI质量保障流程规范.md 的前置方法论补充，解决"AI 原型设计如何自我验证"的核心问题

---

## 0. 一句话定义

**本方法论解决的核心问题：AI 逆向设计的原型缺乏闭环验证，导致设计合理性、先进性和视觉正确性无法自证。**

解决方案是建立三层验证闭环：规则校验（结构合理性）→ 对比校验（超越竞品）→ 模拟校验（可用性验证），配合视觉缺陷自动检测流水线，形成完整的设计质量保障体系。

---

## 1. 问题定义

### 1.1 AI 逆向设计的核心困境

当要求 AI "设计一款比竞品更强的软件"时，AI 生成原型的过程存在三个致命缺陷：

| 缺陷类型 | 具体表现 | 后果 |
|---|---|---|
| 设计合理性缺陷 | AI 无法知道自己的设计在哪些场景下会失败 | 原型在真实使用中暴露大量交互问题 |
| 先进性无法自证 | AI 声称"超越竞品"但无法量化证明 | 设计评审变成主观判断，缺乏说服力 |
| 视觉缺陷不可见 | 内容溢出、元素重叠、响应式崩溃、状态缺失 | 上线后发现大量 UI Bug |

### 1.2 根本原因

AI 原型设计的输出缺少**质量门禁**（Quality Gate）。设计输出直接进入下一阶段，缺陷累积且无法追溯。

```
当前流程：
竞品分析 → AI 设计原型 → 直接实现 → 上线 → 用户发现问题

缺失的环节：
竞品分析 → AI 设计原型 → 【质量门禁】 → 实现 → 上线
```

### 1.3 为什么需要专门的验证方法

AI 设计与人类设计不同：

```text
人类设计师：基于经验积累，知道"这样做会出问题"
AI 设计器：基于模式学习，可能生成"看似合理但实际有缺陷"的设计
```

因此，AI 设计必须比人类设计更严格的验证机制。人类设计师的错误往往是"已知风险的权衡选择"，而 AI 的错误往往是"未知盲区的系统性偏差"。

---

## 2. 核心方法：三层验证闭环

### 2.0 三层验证体系概述

```
┌─────────────────────────────────────────────────────────────────┐
│                        第一层：规则校验                          │
│  (Rule-based Verification)                                      │
│  设计输出 → Design Rule System → 结构合理性报告                 │
│  回答：设计是否满足基本工程约束？                                │
├─────────────────────────────────────────────────────────────────┤
│                        第二层：对比校验                          │
│  (Competitive Verification)                                     │
│  设计方案 → 多代理对抗评审 → 超越竞品证明                       │
│  回答：设计是否真的优于竞品？是否有证据支撑？                    │
├─────────────────────────────────────────────────────────────────┤
│                        第三层：模拟校验                          │
│  (Simulated User Verification)                                  │
│  原型 → 用户任务流模拟 → 可用性报告                             │
│  回答：用户在实际任务中是否能顺利完成任务？                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    三层全部通过 → 进入实现
                    任一层失败 → 返回上一层修复
```

### 2.1 第一层：规则校验（Design Rule System）

#### 2.1.1 规则类型定义

规则校验解决"设计是否满足基本工程约束"的问题。规则分为四类：

| 规则类型 | 规则内容 | 检测方式 |
|---|---|---|
| 一致性规则 | 所有表单的错误提示必须统一位置 | 静态分析 |
| 可用性规则 | 按钮最小点击区域 ≥ 44x44px | 布局计算 |
| 可扩展性规则 | 列表组件必须支持虚拟滚动（数据量 > 100 条时） | 条件触发检测 |
| 响应式规则 | 卡片在 320px ~ 1920px 屏幕宽度下不能溢出 | 多视口截图 |

#### 2.1.2 规则系统结构

```text
Design-Rule-System/
├── rules/
│   ├── consistency/          # 一致性规则
│   │   ├── error-position.yaml
│   │   ├── button-style.yaml
│   │   └── color-semantic.yaml
│   ├── usability/            # 可用性规则
│   │   ├── touch-target.yaml
│   │   ├── text-contrast.yaml
│   │   └── keyboard-navigation.yaml
│   ├── scalability/          # 可扩展性规则
│   │   ├── virtual-scroll.yaml
│   │   ├── pagination.yaml
│   │   └── lazy-load.yaml
│   └── responsive/           # 响应式规则
│       ├── overflow.yaml
│       ├── viewport-break.yaml
│       └── layout-collapse.yaml
├── rule-engine/
│   └── validator.js          # 规则引擎
└── reports/
    └── rule-check-report.json
```

#### 2.1.3 规则配置文件格式

```yaml
# rules/usability/touch-target.yaml
rule_id: RU-001
name: 触摸目标尺寸规则
description: 所有可点击元素的触摸区域必须满足最小尺寸要求
severity: error  # error | warning | info

conditions:
  - selector: "button, [role='button'], a, input[type='submit']"
    properties:
      min-width: 44px
      min-height: 44px
      padding-inclusive: true  #  padding 是否计入触摸区域

exceptions:
  - selector: ".icon-only-button"
    reason: "图标按钮允许小于 44px，但必须提供 tooltip"
    alternative: 必须有等效键盘操作或明确的视觉指示

detection_method: static-analysis | runtime-detection
```

#### 2.1.4 规则校验执行流程

```text
AI 生成设计输出
    ↓
规则引擎加载所有规则
    ↓
并行执行规则检测
    ↓
┌──────────────────────────────────────┐
│  error → 阻断，立即修复              │
│  warning → 记录，评估是否修复        │
│  info → 记录，供人工参考             │
└──────────────────────────────────────┘
    ↓
输出 Rule-Check-Report
    ↓
通过 → 进入第二层对比校验
失败 → 返回 AI 重新设计
```

### 2.2 第二层：对比校验（多代理对抗评审）

#### 2.2.1 为什么需要对抗评审

规则校验只能检查"基本工程约束"，无法判断"设计是否真正超越竞品"。超越竞品的证明需要对抗性验证：让 AI 设计接受系统性挑战。

#### 2.2.2 多代理对抗评审框架

```
Agent A: Product Designer（设计者）
  └─ 职责：生成设计方案，提供设计 rationale

Agent B: Competitive Expert（竞品专家）
  └─ 职责：扮演竞品立场，逐一反驳设计决策

Agent C: User Advocate（用户代言人）
  └─ 职责：寻找可用性问题，模拟真实用户视角

Agent D: Architecture Expert（架构专家）
  └─ 职责：检查可扩展性、技术债务、安全边界

Agent E: Synthesizer（综合者）
  └─ 职责：汇总所有挑战，输出最终评审结论
```

#### 2.2.3 对抗评审执行流程

**Step 1: 设计师提交设计方案**

```text
设计师必须提供：
- 设计方案完整描述
- 每个设计决策的 rationale
- 与竞品的对比说明
- 预期的用户任务流
```

**Step 2: 竞品专家挑战**

```text
竞品专家必须回答：
1. 竞品 X 在这个功能点上的做法是什么？
2. 我的设计为什么比竞品 X 更好？
3. 如果用户从竞品 X 迁移到我的产品，操作路径是变长还是变短？
4. 竞品 X 有什么设计是我应该借鉴但我没有借鉴的？
```

如果设计师无法给出有说服力的理由，说明设计不够强。

**Step 3: 用户代言人挑战**

```text
用户代言人必须模拟以下场景：
1. 新用户首次使用：是否能在 2 分钟内理解核心概念？
2. 专家用户批量操作：高频操作路径是否高效？
3. 异常情况处理：出错时用户是否知道如何恢复？
4. 边缘用户：视力不好的用户、键盘操作的用户是否能正常使用？
```

**Step 4: 架构专家挑战**

```text
架构专家必须检查：
1. 未来需求扩展时，这个设计改动成本有多高？
2. 数据量增长 100 倍时，现有设计是否需要重构？
3. 是否有安全漏洞或性能瓶颈？
4. 第三方集成是否会导致技术债？
```

**Step 5: 综合者输出结论**

```text
综合者必须输出：
- 设计方案通过/不通过
- 如果不通过，列出所有未解决的挑战
- 每个挑战的严重程度（P0/P1/P2）
- 修复建议

通过标准：
- 所有 P0 挑战必须有可接受的回应
- 不能有"我不知道"或"未来再考虑"
- 竞品对比必须有量化证据支撑
```

#### 2.2.4 竞争力门禁（Competitive Gate）

对于复杂 UI / 设计器 / 低代码构建器，必须建立严格的竞争力门禁：

```text
Competitive-Gate 必须包含：
1. 竞品池：至少 1 个直接业务竞品、2 个专业设计器竞品、3 个商业低代码竞品
2. 对标维度：信息架构、工具栏/组件库、字段/数据入口、结构树、画布、属性面板、交互效率、可测试性
3. 评分：每个 P0 维度按 0-3 分评分
   - 0 = 缺失
   - 1 = 弱于竞品
   - 2 = 达到主流竞品
   - 3 = 明显超过竞品
4. 通过标准：
   - P0 维度不得为 0
   - P0 平均分必须 >= 2.3
   - 至少 5 个 P0 维度达到 3 分
5. 直接竞品约束：对直接竞品不得低于其能力
6. 超越证明：每个"超过竞品"的声明必须包含：
   - 竞品做法
   - 我方做法
   - 为什么更好
   - 代价是什么
```

### 2.3 第三层：模拟校验（用户任务流模拟）

#### 2.3.1 为什么需要模拟校验

前两层验证解决了"设计是否合理"和"设计是否优于竞品"的问题，但无法回答"用户在真实任务中是否能顺利完成任务"。

模拟校验通过 AI 模拟用户执行任务，发现任务流断裂、认知负荷过高、错误恢复路径缺失等问题。

#### 2.3.2 任务流模拟框架

```text
任务定义 → 任务分解 → 步骤模拟 → 瓶颈识别 → 报告输出
```

#### 2.3.3 任务定义标准

每个需要验证的任务必须包含：

```yaml
task:
  task_id: TASK-001
  task_name: 订单批量处理
  description: 用户需要在 5 分钟内处理 50 个待审核订单

  personas:
    - name: 新用户
      experience: < 1 week
      characteristics: 需要引导，对批量操作不熟悉
    - name: 熟练用户
      experience: > 3 months
      characteristics: 高效操作，注重快捷键支持

  success_criteria:
    - 完成率 >= 95%
    - 平均耗时 <= 5 分钟
    - 错误率 <= 2%
    - 用户满意度 >= 4/5

  constraints:
    - 必须支持批量选择
    - 必须支持键盘操作
    - 必须支持撤销操作
```

#### 2.3.4 模拟执行流程

```text
Step 1: 任务分解
  把任务分解为原子步骤
  示例：订单审核 → [打开列表] → [筛选待审核] → [批量选择] → [点击审核] → [确认提交] → [查看结果]

Step 2: 步骤模拟
  AI 模拟用户执行每个步骤
  检查：操作是否可发现？是否有歧义？是否有替代路径？

Step 3: 瓶颈识别
  识别以下瓶颈：
  - 认知瓶颈：用户是否理解当前界面要做什么？
  - 操作瓶颈：用户能否找到并正确执行操作？
  - 恢复瓶颈：操作失败后用户能否恢复？
  - 效率瓶颈：高频操作路径是否最短？

Step 4: 报告输出
  输出 Usability-Report，包含：
  - 任务完成率预测
  - 瓶颈清单及严重程度
  - 改进建议
  - 与竞品的任务效率对比
```

#### 2.3.5 模拟校验通过标准

```text
通过条件：
1. 所有核心任务流完成率 >= 90%
2. 无 P0 认知瓶颈（用户完全无法理解）
3. 无 P0 操作瓶颈（用户无法找到操作入口）
4. 每个关键操作都有明确的错误恢复路径
5. 高频操作路径不超过 3 步

不通过条件（任意一项）：
1. 任何核心任务流完成率 < 70%
2. 存在任何 P0 认知或操作瓶颈
3. 关键操作缺少错误恢复路径
4. 存在用户可能永久丢失数据的风险
```

---

## 3. 视觉缺陷自动化检测

### 3.1 视觉缺陷分类

| 缺陷类型 | 定义 | 检测方案 |
|---|---|---|
| 内容溢出 | 文本/元素超出容器边界 | Playwright 截图 + OCR 检测 |
| 元素重叠 | 不同元素 z-index 冲突导致覆盖 | DOM 层叠分析 |
| 响应式崩溃 | 特定视口下布局错乱 | 多视口自动化截图对比 |
| 状态缺失 | 组件缺少 hover/active/disabled/loading/error 状态 | 状态枚举完整性检查 |
| 交互死区 | 按钮/链接不可点击或点击无效 | 可点击区域检测 |
| 视觉不一致 | 同类元素样式不统一 | 设计 Token 比对 |

### 3.2 视觉检测流水线

```
┌─────────────────────────────────────────────────────────────────┐
│                     AI 生成 UI 代码 / 原型                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Stage 1: 代码静态分析                        │
│  - AST 解析提取组件树                                            │
│  - 检测固定宽度/高度、overflow: hidden、z-index 冲突            │
│  - 提取设计 Token（颜色、间距、字体）                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 2: 渲染与截图                            │
│  - 使用 Playwright/Puppeteer 渲染页面                           │
│  - 截取多视口截图（320px, 768px, 1024px, 1440px, 1920px）       │
│  - 截取多种状态（默认、hover、error、空数据、长文本）           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 3: 视觉缺陷检测                          │
│  - 溢出检测：对比 scrollWidth/clientWidth                       │
│  - 重叠检测：计算 bounding box 碰撞                             │
│  - 一致性检测：同类元素设计 Token 比对                           │
│  - OCR 验证：检测截断文本                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 4: 报告生成                              │
│  - Visual-Defect-Report.json                                    │
│  - 缺陷截图标注                                                  │
│  - 缺陷修复优先级                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 检测工具配置

#### 3.3.1 Playwright 配置

```javascript
// visual-checker.js
const { chromium } = require('playwright');

async function visualCheck(page, config) {
  const viewports = config.viewports || [
    { width: 320, height: 568, name: 'mobile-s' },
    { width: 768, height: 1024, name: 'tablet' },
    { width: 1024, height: 768, name: 'laptop' },
    { width: 1440, height: 900, name: 'desktop' },
    { width: 1920, height: 1080, name: 'large' }
  ];

  const states = config.states || [
    { name: 'default', action: () => {} },
    { name: 'hover-button', action: async () => {
      await page.hover('button');
    }},
    { name: 'error-state', action: async () => {
      await page.fill('input', 'invalid');
      await page.click('button[type="submit"]');
    }},
    { name: 'empty-state', action: async () => {
      // 清空列表数据
    }},
    { name: 'long-text', action: async () => {
      // 填入超长文本
    }}
  ];

  const results = [];

  for (const viewport of viewports) {
    await page.setViewportSize({ width: viewport.width, height: viewport.height });

    for (const state of states) {
      await state.action();
      await page.screenshot({
        path: `screenshots/${viewport.name}-${state.name}.png`
      });

      // 检测溢出
      const overflows = await page.evaluate(() => {
        const elements = document.querySelectorAll('*');
        return Array.from(elements).filter(el => {
          return el.scrollWidth > el.clientWidth || el.scrollHeight > el.clientHeight;
        }).map(el => ({
          tag: el.tagName,
          class: el.className,
          overflowX: el.scrollWidth - el.clientWidth,
          overflowY: el.scrollHeight - el.clientHeight
        }));
      });

      // 检测重叠
      const overlaps = await detectOverlaps(page);

      results.push({
        viewport: viewport.name,
        state: state.name,
        screenshot: `${viewport.name}-${state.name}.png`,
        overflows,
        overlaps
      });
    }
  }

  return results;
}
```

#### 3.3.2 重叠检测算法

```javascript
async function detectOverlaps(page) {
  const elements = await page.evaluate(() => {
    const all = document.querySelectorAll('*');
    return Array.from(all)
      .filter(el => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0;
      })
      .map(el => {
        const rect = el.getBoundingClientRect();
        const style = window.getComputedStyle(el);
        return {
          tag: el.tagName,
          class: el.className,
          id: el.id,
          rect: {
            top: rect.top,
            left: rect.left,
            width: rect.width,
            height: rect.height,
            bottom: rect.bottom,
            right: rect.right
          },
          zIndex: style.zIndex === 'auto' ? 0 : parseInt(style.zIndex)
        };
      });
  });

  const overlaps = [];

  for (let i = 0; i < elements.length; i++) {
    for (let j = i + 1; j < elements.length; j++) {
      const a = elements[i];
      const b = elements[j];

      if (rectsOverlap(a.rect, b.rect) && a.zIndex === b.zIndex) {
        overlaps.push({
          element1: `${a.tag}.${a.class}`,
          element2: `${b.tag}.${b.class}`,
          overlapArea: calculateOverlapArea(a.rect, b.rect)
        });
      }
    }
  }

  return overlaps;
}

function rectsOverlap(a, b) {
  return !(a.right < b.left || a.left > b.right || a.bottom < b.top || a.top > b.bottom);
}
```

### 3.4 状态覆盖完整性检查

```javascript
async function checkStateCompleteness(page, component) {
  const states = ['default', 'hover', 'active', 'focus', 'disabled', 'loading', 'error', 'empty'];

  const results = {};

  for (const state of states) {
    try {
      await activateState(page, component, state);
      const screenshot = await page.screenshot({
        path: `states/${component}-${state}.png`
      });
      results[state] = { captured: true, screenshot };
    } catch (e) {
      results[state] = { captured: false, error: e.message };
    }
  }

  const missingStates = Object.entries(results)
    .filter(([_, r]) => !r.captured)
    .map(([state, _]) => state);

  return {
    component,
    stateCoverage: results,
    coverageRate: (states.length - missingStates.length) / states.length,
    missingStates,
    pass: missingStates.length === 0
  };
}

async function activateState(page, component, state) {
  const selector = `[data-component="${component}"]`;

  switch (state) {
    case 'hover':
      await page.hover(selector);
      break;
    case 'active':
      await page.click(selector);
      break;
    case 'focus':
      await page.focus(selector);
      break;
    case 'disabled':
      await page.evaluate((sel) => {
        document.querySelector(sel).setAttribute('disabled', 'true');
      }, selector);
      break;
    case 'loading':
      await page.evaluate((sel) => {
        document.querySelector(sel).classList.add('loading');
      }, selector);
      break;
    case 'error':
      await page.evaluate((sel) => {
        document.querySelector(sel).classList.add('error');
      }, selector);
      break;
    case 'empty':
      await page.evaluate((sel) => {
        const el = document.querySelector(sel);
        el.innerHTML = '';
      }, selector);
      break;
  }
}
```

---

## 4. 完整工程化流程

### 4.0 流程总览

```
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 0: 准备                              │
│  - 确定设计目标和竞品池                                          │
│  - 建立 Design Rule System                                      │
│  - 准备对抗评审 Agent                                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 1: AI 设计                          │
│  - AI 生成设计方案                                               │
│  - AI 生成 UI 原型代码                                           │
│  - 自动执行规则校验（第一层）                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 2: 对抗评审                          │
│  - 多代理对抗评审（第二层）                                      │
│  - 竞争力门禁检查                                                │
│  - 输出评审报告                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 3: 视觉检测                          │
│  - 渲染流水线                                                    │
│  - 视觉缺陷自动检测                                              │
│  - 状态覆盖完整性检查                                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 4: 模拟校验                          │
│  - 用户任务流定义                                                │
│  - 任务流模拟执行                                                │
│  - 可用性报告生成                                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Phase 5: 人工评审                          │
│  - 关键设计决策人工确认                                          │
│  - 已知风险接受                                                  │
│  - 终审放行                                                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                      进入实现阶段
```

### 4.1 各阶段门禁

| 阶段 | 门禁类型 | 通过条件 | 失败处理 |
|---|---|---|---|
| Phase 1 规则校验 | 自动门禁 | 所有 error 规则通过 | 阻断，返回修复 |
| Phase 2 对抗评审 | 人工+AI门禁 | 所有 P0 挑战有可接受回应 | 阻断，返回修复 |
| Phase 3 视觉检测 | 自动门禁 | 无 P0/P1 视觉缺陷 | 阻断，返回修复 |
| Phase 4 模拟校验 | AI门禁 | 任务完成率 >= 90% | 阻断，返回修复 |
| Phase 5 人工评审 | 人工门禁 | 人工签字确认 | 阻断，升级决策 |

### 4.2 循环控制

```text
允许的循环：
- Phase 1 → Phase 1（修复后重跑规则校验）
- Phase 1 → Phase 2（规则校验通过后进入对抗评审）
- Phase 2 → Phase 1（对抗评审发现设计问题）
- Phase 3 → Phase 1（视觉检测发现设计问题）
- Phase 4 → Phase 1（模拟校验发现设计问题）

不允许的循环：
- Phase 5 → Phase 1/2/3/4（人工评审不通过必须重新评审，不允许简单修复）

循环上限：
- 每个 Phase 最多 3 次循环
- 超过上限必须升级人工决策
```

---

## 5. 强制自我质疑机制

### 5.1 自我质疑清单

AI 在每个设计决策点必须回答以下问题：

```text
Q1: 失败场景识别
   "这个设计决策可能在哪些场景下失败？"
   "竞品在类似场景下是怎么处理的？"

Q2: 用户理解验证
   "如果用户是完全没有相关经验的小白，这个设计会不会让用户困惑？"
   "我用什么方式验证用户理解了我的设计意图？"

Q3: 可扩展性验证
   "未来需求扩展时，这个设计改动成本有多高？"
   "如果数据量增长 100 倍，这个设计是否需要重构？"

Q4: 超越竞品证明
   "我声称'超越竞品'，这个结论有量化证据支撑吗？"
   "竞品的做法有哪些是我应该借鉴但我没有借鉴的？"

Q5: 错误恢复验证
   "用户操作失败后，是否有明确的恢复路径？"
   "是否存在用户可能永久丢失数据的风险？"
```

### 5.2 自我质疑执行规则

```text
执行时机：
- 每个关键设计决策产生时
- 每个 UI 组件设计完成时
- 对抗评审前
- 人工评审前

输出要求：
- 必须有文字回答
- 必须有证据支撑
- 必须识别不确定性并标注
- "我不知道"必须被记录为风险项
```

---

## 6. 与现有规范体系的衔接

### 6.1 与 06-规范-AI_UI质量保障流程规范.md 的关系

本文是 06-规范 的前置方法论补充：

| 06-规范 | 本文 |
|---|---|
| S0-S7 设计门禁流程 | 提供设计门禁执行的方法论基础 |
| U0-U9 视觉审核规范 | 提供视觉检测的具体实现方案 |
| AI 原型生成 SOP | 补充"如何让 AI 自我验证设计"的方法 |

### 6.2 与 02-流程-知识库驱动新产品创建与迭代.md 的关系

本文为阶段 5A（统一设计决策工作流）提供验证方法：

```text
02-流程 阶段 5A 要求：
- 三路候选（知识库证据 + 行业标准 + 自主创新）
- 权衡矩阵
- ADR 决策

本文提供：
- 第一层规则校验：确保设计满足基本工程约束
- 第二层对比校验：确保设计优于竞品
- 第三层模拟校验：确保设计可用
```

### 6.3 产出衔接

```text
本文产出：
- Design-Rule-System/
- Multi-Agent-Critique-Report.md
- Usability-Simulation-Report.md
- Visual-Defect-Report.json

这些产出进入：
- 02-流程 阶段 5A 的设计决策包
- 06-规范 的设计门禁基线
- 后续实现阶段的设计依据
```

---

## 7. 实施建议

### 7.1 渐进式实施路径

```text
第一阶段（1-2周）：
- 建立基础的 Design Rule System（20-30 条核心规则）
- 手动执行对抗评审（人类担任部分角色）
- 使用 Playwright 进行基础的视觉检测

第二阶段（2-4周）：
- 完善规则系统（覆盖 100+ 条规则）
- 引入 AI 担任部分评审角色
- 实现自动化视觉检测流水线

第三阶段（1-2月）：
- 部署多代理对抗评审框架
- 实现用户任务流模拟
- 建立完整的质量门禁体系
```

### 7.2 关键成功因素

```text
1. 规则系统必须与业务场景匹配
   - 不要照搬行业通用规则
   - 要根据实际产品特点定制

2. 对抗评审必须真正独立
   - Designer 不能参与评审
   - 评审结论必须被认真对待

3. 视觉检测必须覆盖真实场景
   - 必须使用真实数据
   - 必须测试真实任务流

4. 人工评审必须有足够授权
   - 人工可以否决 AI 结论
   - 人工决策必须被尊重
```

### 7.3 常见误区

```text
误区 1: 规则越多越好
  事实: 规则过多会导致大量 warning，降低整体效率
  正确做法: 只定义必要的 error 规则，warning 和 info 按需添加

误区 2: AI 评审可以完全替代人工
  事实: AI 评审只能发现可量化的问题，无法判断战略价值
  正确做法: AI 处理量化问题，人工处理战略问题

误区 3: 视觉检测通过 = 设计质量通过
  事实: 视觉正确不等于设计合理
  正确做法: 三层验证必须全部通过

误区 4: 对抗评审只是形式
  事实: 真正独立的对抗评审会发现大量隐藏问题
  正确做法: 评审结论必须有明确的处理要求和跟踪机制
```

---

## 8. 一句话压缩

fable-AI 原型设计与质量验证一体化方法论的核心，是建立三层验证闭环（规则校验 → 对比校验 → 模拟校验）配合视觉缺陷自动检测流水线，让 AI 设计在进入实现前必须通过合理性证明、超越竞品证明和可用性证明，从根本上解决 AI 原型设计无法自我验证的问题。

---

## 9. 多Agent对抗评审机制（3轮迭代）

本文档定义完全自动化的多Agent对抗评审流程。所有评审、质疑、修复、验证均由AI自动完成，无需人工干预。

**执行前提：**
- AI模型需支持多轮对话上下文（建议 > 100K tokens）
- 或使用外部多Agent调度框架（如AutoGen、LangChain Agents）

### 9.0 机制概述

```
┌─────────────────────────────────────────────────────────────────────┐
│                      3轮对抗评审流程                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  第1轮：初始挑战 → 竞品专家 + 用户代言人 主导                      │
│          输出：问题清单 + 修复任务                                  │
│                                                                     │
│  第2轮：修复验证 → 设计师 + 综合者 主导                           │
│          输出：修复确认 + 新问题                                   │
│                                                                     │
│  第3轮：最终裁决 → 综合者 主导                                     │
│          输出：通过/不通过 + 遗留问题                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 9.1 Agent角色定义

#### 设计师Agent (Designer Agent)

**职责：** 维护设计方案，回应质疑，解释设计决策

**Prompt模板：**
```markdown
你是设计师Agent，负责维护设计方案。
当前轮次：第N轮
待评审内容：[设计稿/原型]

你的职责：
1. 维护设计方案，解释设计决策的rationale
2. 回应其他Agent提出的质疑
3. 识别设计中的不确定性并标注风险
4. 当被说服时，优雅地接受并修改设计

当被质疑时，必须回答：
- 设计为什么这样做？
- 有没有考虑过其他方案？为什么拒绝了？
- 如果这个设计失败，最可能的原因是什么？

输出格式：
{
  "agent": "designer",
  "round": N,
  "position": "维护/修改/接受",
  "responses": [...],
  "concessions": [...],
  "uncertainty": [...]
}
```

#### 竞品专家Agent (Competitor Agent)

**职责：** 从竞品视角挑战设计方案，验证超越性声明

**Prompt模板：**
```markdown
你是竞品专家Agent，扮演多个竞品的辩护律师。
当前轮次：第N轮
待评审内容：[设计稿/原型]

你的职责：
1. 从每个竞品的角度挑战设计方案
2. 验证"超越竞品"声明是否有量化证据
3. 指出设计中借鉴竞品但未承认的部分
4. 挑战设计师的设计决策，要求提供证据

必须挑战的维度：
- 信息架构：竞品X如何组织这个功能？
- 交互效率：用户从竞品X迁移到本产品，操作路径变长还是变短？
- 功能覆盖：竞品X有哪些功能是本产品缺失的？
- 体验细节：竞品X在哪些细节上做得更好？

输出格式：
{
  "agent": "competitor",
  "round": N,
  "challenges": [
    {
      "competitor": "竞品名称",
      "dimension": "挑战维度",
      "competitor_approach": "竞品做法",
      "designer_approach": "本产品做法",
      "verdict": "胜/负/平",
      "evidence_required": "需要的证据"
    }
  ],
  "unresolved_claims": [...]
}
```

#### 用户代言人Agent (User Agent)

**职责：** 从用户视角质疑设计方案，关注可用性和边缘场景

**Prompt模板：**
```markdown
你是用户代言人Agent，扮演不同类型的用户。
当前轮次：第N轮
待评审内容：[设计稿/原型]

你的职责：
1. 模拟不同类型用户的操作体验
2. 发现设计师可能忽略的认知负荷问题
3. 识别任务流断裂点
4. 指出边缘用户（视力不好、键盘操作、新手、专家）可能遇到的问题

必须模拟的用户场景：
- 新用户首次使用：2分钟内能理解核心概念吗？
- 专家用户批量操作：高频操作路径是否高效？
- 异常情况处理：出错时用户知道如何恢复吗？
- 边缘用户：特殊需求用户能正常使用吗？

输出格式：
{
  "agent": "user",
  "round": N,
  "user_scenarios": [
    {
      "user_type": "用户类型",
      "scenario": "场景描述",
      "can_complete": true/false,
      "cognitive_load": "高/中/低",
      "blocking_issues": [...],
      "recovery_path_exists": true/false
    }
  ],
  "edge_cases_identified": [...]
}
```

#### 综合者Agent (Synthesizer Agent)

**职责：** 汇总各方观点，输出决策建议，触发修复流程

**Prompt模板：**
```markdown
你是综合者Agent，负责汇总评审结果并输出决策。
当前轮次：第N轮
所有Agent评审结果：[汇总]

你的职责：
1. 汇总所有Agent的评审意见
2. 识别真正的设计缺陷（非边缘争议）
3. 输出明确的通过/不通过决策
4. 如不通过，生成具体的修复任务清单
5. 验证上轮修复是否有效

决策标准：
- P0问题（阻断）：功能不可用、数据丢失风险、安全问题 → 必须修复
- P1问题（严重）：核心流程受阻、高概率操作失败 → 应该修复
- P2问题（中等）：次要功能受限、低概率问题 → 可接受或下轮修复
- Info（低）：优化建议 → 记录但不阻断

输出格式：
{
  "agent": "synthesizer",
  "round": N,
  "verdict": "pass/fail/conditional_pass",
  "issues_found": {
    "p0": [...],
    "p1": [...],
    "p2": [...],
    "info": [...]
  },
  "fix_required": [...],
  "regression_check": {
    "previous_p0_fixed": true/false,
    "previous_p1_fixed": true/false,
    "new_issues_introduced": [...]
  },
  "recommendation": "继续/修复后继续/终止设计"
}
```

### 9.2 三轮评审流程

```yaml
评审流程:
  第1轮:
    名称: 初始挑战
    目标: 发现所有明显的P0/P1问题
    参与者: 竞品专家 + 用户代言人 主导
    设计师响应: 必须回应每个质疑
    焦点: 完整性检查、竞品对比、用户任务流
    输出: 问题清单 + 修复任务

  第2轮:
    名称: 修复验证
    目标: 验证前轮问题的修复效果
    参与者: 设计师 + 综合者 主导
    焦点: 回归测试、修复确认
    输出: 修复确认 + 新问题

  第3轮:
    名称: 最终裁决
    目标: 做出最终通过/不通过决定
    参与者: 综合者 主导
    焦点: 全部P0/P1问题解决情况
    输出: 最终裁决 + 遗留问题处理建议
```

### 9.3 对抗评审执行命令

AI自动执行时，使用以下命令模板：

```markdown
## 多Agent对抗评审执行命令

请执行《fable-AI原型设计与质量验证一体化方法论》第9节多Agent对抗评审：

### 当前状态
- 评审轮次：第N轮（N=1-3）
- 待评审内容：[设计稿/原型位置]
- 上轮遗留问题：[如有]

### 执行步骤

#### 第1轮：初始挑战
1. 竞品专家Agent提出挑战（至少3个维度）
2. 用户代言人Agent模拟用户场景（至少4种用户）
3. 设计师Agent必须回应每个质疑
4. 综合者Agent汇总问题清单，输出verdict

#### 第2轮：修复验证
1. 设计师Agent展示修复内容
2. 综合者Agent验证修复效果
3. 如有新问题，记录并继续修复

#### 第3轮：最终裁决
1. 综合者Agent输出最终裁决
2. 如通过，输出设计确认
3. 如不通过，输出终止原因

### 输出格式
每轮必须输出标准JSON报告：
```json
{
  "round": N,
  "timestamp": "ISO8601时间戳",
  "agents_participated": ["designer", "competitor", "user", "synthesizer"],
  "lead_agent": "主导Agent",
  "verdict": "pass/fail/conditional_pass",
  "issues": {
    "p0": [{"id": "P0-001", "description": "...", "status": "new/ongoing/fixed"}],
    "p1": [{"id": "P1-001", "description": "...", "status": "new/ongoing/fixed"}],
    "p2": [{"id": "P2-001", "description": "...", "status": "new/ongoing/fixed"}]
  },
  "fixes": [{"issue_id": "P0-001", "fix_description": "...", "verified": true/false}],
  "unresolved": ["问题ID列表"],
  "can_proceed": true/false
}
```
```

### 9.4 通过判定标准

```yaml
通过条件（满足全部）：
  条件1: 第3轮无P0问题
  条件2: 所有P0问题已修复或标记为"接受风险"
  条件3: 综合者Agent输出verdict="pass"

不通过条件（任意满足）：
  条件1: 任何轮次发现P0问题且无法修复
  条件2: 第3轮仍有未解决的P0问题
  条件3: 核心功能缺失（任务流断裂、关键状态缺失）

终止设计条件：
  条件1: 发现根本性设计错误，无法通过迭代修复
  条件2: 竞品专家Agent证明设计无法超越竞品
```

### 9.5 执行自律清单

AI在执行对抗评审时必须遵守：

```markdown
## 多Agent对抗评审自律清单

### 质疑原则
- [ ] 竞品专家Agent必须真正从竞品角度挑战
- [ ] 用户代言人Agent必须模拟真实用户视角
- [ ] 综合者Agent必须做出客观裁决

### 回应原则
- [ ] 设计师Agent不能回避质疑，必须正面回应
- [ ] 不能用"这是设计决策"回避技术质疑

### 修复原则
- [ ] 每次修复必须经过验证
- [ ] 修复不能引入新问题
```

### 9.6 完整执行示例

```markdown
## 第1轮：初始挑战 - 完整执行

### 1. 设计师Agent提交设计方案
```json
{
  "agent": "designer",
  "round": 1,
  "position": "维护",
  "design_summary": "订单管理页面采用卡片式布局，支持批量操作",
  "key_decisions": [
    {"decision": "使用卡片式布局", "rationale": "信息密度适中，便于批量操作"},
    {"decision": "批量选择放左侧", "rationale": "符合用户习惯"}
  ]
}
```

### 2. 竞品专家Agent提出挑战
```json
{
  "agent": "competitor",
  "round": 1,
  "challenges": [
    {
      "competitor": "竞品A",
      "dimension": "批量操作效率",
      "competitor_approach": "列表式+快捷键，支持Ctrl+点击多选",
      "designer_approach": "卡片式+复选框",
      "verdict": "负",
      "evidence_required": "卡片式批量操作效率数据"
    }
  ]
}
```

### 3. 用户代言人Agent提出质疑
```json
{
  "agent": "user",
  "round": 1,
  "user_scenarios": [
    {
      "user_type": "新手用户",
      "scenario": "首次找到批量操作入口",
      "can_complete": false,
      "cognitive_load": "高",
      "blocking_issues": ["批量操作入口不明显"],
      "recovery_path_exists": false
    }
  ]
}
```

### 4. 综合者Agent裁决
```json
{
  "agent": "synthesizer",
  "round": 1,
  "verdict": "fail",
  "issues": {
    "p0": [],
    "p1": [
      {"id": "P1-001", "description": "新手用户找不到批量操作入口", "status": "new"}
    ],
    "p2": [
      {"id": "P2-001", "description": "批量操作效率低于竞品A", "status": "new"}
    ]
  },
  "fix_required": [
    {"issue_id": "P1-001", "fix": "添加工具栏引导"}
  ],
  "can_proceed": false
}
```

### 9.7 自律清单（摘要）

核心原则：

1. **质疑必须真实**：竞品专家必须从竞品角度挑战，用户代言人必须模拟真实用户，综合者必须指出真实设计缺陷。
2. **回应必须正面**：设计师Agent不能回避质疑，不能用"这是设计决策"回避技术质疑。
3. **修复必须验证**：每次修复必须经过验证，不能引入新问题。
4. **裁决必须客观**：综合者Agent必须独立裁决，不受设计师立场影响。

---

## 10. 附录
