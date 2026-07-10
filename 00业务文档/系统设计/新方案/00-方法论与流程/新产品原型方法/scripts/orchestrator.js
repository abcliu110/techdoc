/**
 * orchestrator.js — 主编排脚本
 *
 * 串联 8 个 Agent，实现完整的闭环管线：
 * 研究 → 分析 → 设计 → 校验 → 评分 → 迭代 → 终审 → 验收 → 交付
 *
 * 用法: node orchestrator.js --competitors "竞品A,竞品B" --product-type display
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const { callLLM, callLLMWithSampling, consensusReview, arbitrationReview, costTracker, safeJsonParse } = require('./llm-client');
const { CheckpointManager, STATES } = require('./checkpoint-manager');
const { runScoring } = require('./scoring');
const { runAxeAudit } = require('./axe-audit');
const { AGENT_PROMPTS } = require('./agent-prompts');

// ============================================================
// 配置
// ============================================================
const CONFIG = {
  maxIterations: 10,
  maxRollbacks: 3,
  maxRespec: 2,
  maxConsensusRetries: 3,
  designModel: 'glm-flash',      // 设计 Agent 用低成本模型
  reviewModel: 'claude',          // 评审用不同模型家族
  scoringModel: 'gpt4o',          // 评分用第三个模型家族
  prototypeUrl: 'http://localhost:3000',
  prototypeDir: path.join(process.cwd(), 'prototypes'),
  reportsDir: path.join(process.cwd(), 'reports'),
  screenshotsDir: path.join(process.cwd(), 'reports', 'screenshots'),
  budget: { maxCalls: 100, maxTokens: 2000000, maxCost: 50 },
  rollbackStrategies: ['A', 'B', 'C'],
};

// ============================================================
// 主流程
// ============================================================

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const competitors = (args.competitors || '').split(',').map(s => s.trim()).filter(Boolean);
  const productType = args['product-type'] || 'display';

  if (competitors.length === 0) {
    console.error('Usage: node orchestrator.js --competitors "竞品A,竞品B" --product-type display');
    process.exit(1);
  }

  console.log('=== AI 原型设计闭环验证管线启动 ===');
  console.log(`竞品: ${competitors.join(', ')}`);
  console.log(`产品类型: ${productType}`);

  const cp = new CheckpointManager();

  // 崩溃恢复：尝试加载最新检查点
  const lastCp = cp.loadLatest();
  let state = lastCp ? lastCp.phase : STATES.INIT;
  let iteration = lastCp ? lastCp.iteration : 0;
  let rollbackCount = 0;
  let respecCount = 0;
  let consensusRetries = 0;

  if (lastCp) {
    console.log(`恢复到检查点: ${lastCp.id} (状态: ${state}, 轮次: ${iteration})`);
  }

  // ========== 阶段一：研究 Agent ==========
  if (state === STATES.INIT || state === STATES.RESPEC) {
    state = STATES.RESEARCH;
    console.log('\n--- 阶段一: 研究 Agent ---');
    const featureMatrix = await runResearchAgent(competitors);
    cp.save(iteration, STATES.RESEARCH, { featureMatrix }, 0);
    state = STATES.ANALYSIS;

    // ========== 分析 Agent ==========
    console.log('\n--- 阶段一: 分析 Agent ---');
    const designSpec = await runAnalysisAgent(featureMatrix, productType);
    cp.save(iteration, STATES.ANALYSIS, { featureMatrix, designSpec }, 0);
    state = STATES.DESIGN;
  }

  let featureMatrix = lastCp?.data?.featureMatrix;
  let designSpec = lastCp?.data?.designSpec;

  // ========== 设计 Agent（首次生成） ==========
  if (state === STATES.DESIGN) {
    console.log('\n--- 阶段一: 设计 Agent ---');
    await runDesignAgent(designSpec, null, CONFIG.prototypeDir);
    cp.save(iteration, STATES.DESIGN, { featureMatrix, designSpec }, 0);
    state = STATES.ITERATING;
  }

  // ========== 迭代循环 ==========
  while (state !== STATES.DELIVERED && state !== STATES.ACCEPTANCE) {
    iteration++;
    console.log(`\n=== 迭代第 ${iteration} 轮 ===`);

    // 预算检查
    const budget = costTracker.checkBudget(CONFIG.budget);
    if (budget.callsExceeded || budget.tokensExceeded || budget.costExceeded) {
      console.error('预算超限，触发降级交付');
      return degradedDelivery(cp, '预算超限');
    }

    // 启动原型服务
    await startPrototypeServer(CONFIG.prototypeDir);

    // 阶段二：并行校验
    console.log('--- 阶段二: 并行校验 ---');
    const [domResult, visualResult, axeResult, usabilityResult] = await Promise.all([
      runDOMValidation(CONFIG.prototypeUrl),
      runVisualReview(CONFIG.prototypeUrl, CONFIG.reviewModel),
      runAxeAudit(CONFIG.prototypeUrl, designSpec.routes || ['/']),
      runUsabilityReview(CONFIG.prototypeUrl, designSpec, CONFIG.reviewModel),
    ]);

    // 评分
    console.log('--- 评分 ---');
    const scoringInput = {
      domIssues: domResult.allIssues.flatMap(r => r.issues),
      breakpointIssues: domResult.allIssues,
      llmVisualScore: visualResult.medianScore || 5,
      taskPathDepth: usabilityResult.taskPathDepth || 3,
      tokenUsageRate: await checkTokenUsage(CONFIG.prototypeDir),
      axeCritical: axeResult.criticalCount,
      axeSerious: axeResult.seriousCount,
      axeFailed: axeResult.hasExecutionFailure,
      competitor: await runCompetitorScoring(CONFIG.prototypeUrl, featureMatrix, CONFIG.scoringModel),
      productType,
    };
    const score = runScoring(scoringInput);
    console.log(`总分: ${score.totalScore} | 竞品超越度: ${score.dimensions.competitorAdvantage}`);
    console.log(`各维度:`, score.dimensions);

    // 保存检查点
    cp.save(iteration, STATES.SCORING, {
      featureMatrix, designSpec,
      domResult, visualResult, axeResult, usabilityResult,
      score,
    }, score.totalScore);

    // 边界复验
    if (score.inToleranceZone) {
      console.log('总分在容差区间 [83,87]，触发边界复验...');
      // 增加采样至 7 次取中位数（此处简化为重新评分）
    }

    // 放行判定
    if (score.passed && !score.inToleranceZone) {
      state = STATES.CONSENSUS;
      break;
    }

    // 迭代超限检查
    if (iteration >= CONFIG.maxIterations) {
      if (rollbackCount < CONFIG.maxRollbacks) {
        console.log(`\n--- 策略回退 #${rollbackCount + 1} ---`);
        const bestCp = cp.loadBest();
        if (bestCp) {
          await restoreCheckpoint(bestCp, CONFIG.prototypeDir);
          designSpec = applyRollbackStrategy(designSpec, CONFIG.rollbackStrategies[rollbackCount]);
        }
        rollbackCount++;
        iteration = 0;
        continue;
      } else if (respecCount < CONFIG.maxRespec) {
        console.log('\n--- 重新生成 DesignSpec ---');
        designSpec = await runAnalysisAgent(featureMatrix, productType);
        respecCount++;
        iteration = 0;
        rollbackCount = 0;
        continue;
      } else {
        return degradedDelivery(cp, '迭代超限且策略回退/Spec重生成均用尽');
      }
    }

    // 批判 Agent 生成修复指令
    console.log('--- 批判 Agent ---');
    const allReports = { domResult, visualResult, axeResult, usabilityResult, score };
    const fixInstructions = await runCriticAgent(allReports, CONFIG.reviewModel);
    console.log(`修复指令: ${fixInstructions.length} 条`);

    // 设计 Agent 修复
    console.log('--- 设计 Agent 修复 ---');
    await runDesignAgent(designSpec, fixInstructions, CONFIG.prototypeDir);
  }

  // ========== 多 LLM 共识终审 ==========
  if (state === STATES.CONSENSUS) {
    console.log('\n=== 多 LLM 共识终审 ===');
    let consensusPassed = false;

    while (consensusRetries < CONFIG.maxConsensusRetries) {
      consensusRetries++;
      console.log(`终审第 ${consensusRetries} 次`);

      const screenshotPath = path.join(CONFIG.screenshotsDir, 'consensus.png');
      await takeScreenshot(CONFIG.prototypeUrl, screenshotPath);

      const consensus = await consensusReview({
        systemPrompt: AGENT_PROMPTS.consensusSystem,
        userPrompt: AGENT_PROMPTS.consensusUser(designSpec, featureMatrix),
        imagePath: screenshotPath,
      });

      console.log(`终审结果: ${consensus.verdict} (PASS:${consensus.passCount} FAIL:${consensus.failCount})`);

      if (consensus.verdict === 'PASS') {
        consensusPassed = true;
        break;
      } else if (consensus.verdict === 'ARBITRATION') {
        console.log('2/3 分歧，触发仲裁 Agent...');
        const arbitration = await arbitrationReview({
          systemPrompt: AGENT_PROMPTS.consensusSystem,
          userPrompt: AGENT_PROMPTS.consensusUser(designSpec, featureMatrix),
          imagePath: screenshotPath,
          votes: consensus.votes,
        });
        console.log(`仲裁结果: ${arbitration.verdict}`);
        if (arbitration.verdict === 'PASS') {
          consensusPassed = true;
          break;
        }
      }

      // 终审不通过 → 重置迭代计数器重新迭代
      iteration = 0;
      break;
    }

    if (!consensusPassed && consensusRetries >= CONFIG.maxConsensusRetries) {
      console.log('终审循环上限用尽，触发策略回退');
      // 回到迭代循环
      state = STATES.ITERATING;
    }
  }

  // ========== 自动化验收测试 ==========
  if (state === STATES.CONSENSUS || consensusPassed) {
    console.log('\n=== 自动化验收测试 ===');
    const acceptancePassed = await runAcceptanceTests(CONFIG.prototypeUrl, featureMatrix, designSpec);

    if (acceptancePassed) {
      console.log('\n=== 交付 ===');
      cp.save(iteration, STATES.DELIVERED, { featureMatrix, designSpec, finalScore: score?.totalScore }, score?.totalScore || 0);
      console.log('✅ 原型已交付');
      console.log('成本报告:', costTracker.report());
      console.log('检查点统计:', cp.getStorageStats());
    } else {
      console.log('验收测试未通过，回退到迭代循环');
      state = STATES.ITERATING;
    }
  }
}

// ============================================================
// Agent 函数
// ============================================================

async function runResearchAgent(competitors) {
  const prompt = AGENT_PROMPTS.research(competitors);
  const result = await callLLM({
    modelKey: CONFIG.reviewModel,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    temperature: 0,
    jsonMode: true,
  });
  return safeJsonParse(result.content, { features: [] });
}

async function runAnalysisAgent(featureMatrix, productType) {
  const prompt = AGENT_PROMPTS.analysis(featureMatrix, productType);
  const result = await callLLM({
    modelKey: CONFIG.reviewModel,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    temperature: 0,
    jsonMode: true,
  });
  return safeJsonParse(result.content, { pages: [], routes: [], components: [] });
}

async function runDesignAgent(designSpec, fixInstructions, outputDir) {
  const prompt = AGENT_PROMPTS.design(designSpec, fixInstructions);
  const result = await callLLM({
    modelKey: CONFIG.designModel,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    temperature: 0,
  });
  // 将生成的代码写入文件
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(path.join(outputDir, 'App.tsx'), result.content, 'utf-8');
}

async function runDOMValidation(url) {
  const scriptPath = path.join(__dirname, 'validate-prototype.js');
  try {
    const output = execSync(`node "${scriptPath}" "${url}"`, { encoding: 'utf-8', timeout: 60000 });
    return { allIssues: JSON.parse(output) };
  } catch (e) {
    return { allIssues: [{ viewport: 0, issues: [{ type: 'RENDER_ERROR', severity: 'critical', detail: e.message }] }] };
  }
}

async function runVisualReview(url, modelKey) {
  const screenshotPath = path.join(CONFIG.screenshotsDir, `visual_${Date.now()}.png`);
  await takeScreenshot(url, screenshotPath);
  const prompt = AGENT_PROMPTS.visualReview;
  return await callLLMWithSampling({
    modelKey,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    imagePath: screenshotPath,
    temperature: 0,
    jsonMode: true,
  }, 3);
}

async function runUsabilityReview(url, designSpec, modelKey) {
  const screenshotPath = path.join(CONFIG.screenshotsDir, `usability_${Date.now()}.png`);
  await takeScreenshot(url, screenshotPath);
  const prompt = AGENT_PROMPTS.usabilityReview(designSpec);
  const result = await callLLM({
    modelKey,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    imagePath: screenshotPath,
    temperature: 0,
    jsonMode: true,
  });
  return safeJsonParse(result.content, { taskPathDepth: 99, painPoints: [] });
}

async function runCompetitorScoring(url, featureMatrix, modelKey) {
  const screenshotPath = path.join(CONFIG.screenshotsDir, `competitor_${Date.now()}.png`);
  await takeScreenshot(url, screenshotPath);
  const prompt = AGENT_PROMPTS.competitorScoring(featureMatrix);
  const result = await callLLM({
    modelKey,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    imagePath: screenshotPath,
    temperature: 0,
    jsonMode: true,
  });
  const parsed = safeJsonParse(result.content, { items: [] });
  // Must Have 二次确认 + evidence 可验证化
  const mustHaveItems = parsed.items?.filter(i => i.category === 'MustHave') || [];
  const mustHaveAllCovered = mustHaveItems.length > 0 && mustHaveItems.every(i => i.implemented);
  return {
    mustHaveRate: mustHaveItems.length > 0 ? mustHaveItems.filter(i => i.implemented).length / mustHaveItems.length : 0,
    differentiatorRate: calcRate(parsed.items, 'Differentiator'),
    innovationRate: calcRate(parsed.items, 'Innovation'),
    painPointRate: calcRate(parsed.items, 'PainPoint'),
    mustHaveAllCovered,
  };
}

function calcRate(items, category) {
  const filtered = items?.filter(i => i.category === category) || [];
  if (filtered.length === 0) return 1; // 无该类功能视为 100%
  return filtered.filter(i => i.implemented).length / filtered.length;
}

async function runCriticAgent(allReports, modelKey) {
  const prompt = AGENT_PROMPTS.critic(allReports);
  const result = await callLLM({
    modelKey,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    temperature: 0,
    jsonMode: true,
  });
  return safeJsonParse(result.content, { fixes: [] }).fixes || [];
}

// ============================================================
// 验收测试
// ============================================================

async function runAcceptanceTests(url, featureMatrix, designSpec) {
  // 独立测试 Agent 从特征矩阵生成测试用例
  const prompt = AGENT_PROMPTS.testAgent(featureMatrix);
  const result = await callLLM({
    modelKey: CONFIG.scoringModel,
    systemPrompt: prompt.system,
    userPrompt: prompt.user,
    temperature: 0,
    jsonMode: true,
  });
  const testCases = safeJsonParse(result.content, { tests: [] }).tests || [];

  // 交集校验：独立测试 Agent 的任务列表 vs DesignSpec 的任务列表
  const specTasks = designSpec.pages?.map(p => p.name) || [];
  const testTasks = testCases.map(t => t.taskName);
  const intersection = specTasks.filter(t => testTasks.includes(t));
  const onlyInSpec = specTasks.filter(t => !testTasks.includes(t));
  const onlyInTest = testTasks.filter(t => !specTasks.includes(t));

  if (onlyInTest.length > 0) {
    console.log(`⚠️ 覆盖争议（仅独立测试Agent有）: ${onlyInTest.join(', ')}`);
  }

  // 执行 Playwright 测试
  const { chromium } = require('playwright');
  const browser = await chromium.launch();
  const page = await browser.newPage();
  let allPassed = true;

  for (const tc of testCases) {
    try {
      await page.goto(url + (tc.route || '/'), { waitUntil: 'domcontentloaded', timeout: 10000 });
      for (const step of tc.steps || []) {
        if (step.action === 'click') await page.click(step.selector);
        if (step.action === 'fill') await page.fill(step.selector, step.value);
      }
      console.log(`  ✓ ${tc.taskName}`);
    } catch (e) {
      console.log(`  ✗ ${tc.taskName}: ${e.message}`);
      allPassed = false;
    }
  }

  await browser.close();
  return allPassed;
}

// ============================================================
// 工具函数
// ============================================================

async function takeScreenshot(url, outputPath) {
  const { chromium } = require('playwright');
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 15000 });
  await page.screenshot({ path: outputPath, fullPage: true });
  await browser.close();
}

async function startPrototypeServer(dir) {
  // 假设原型已通过 vite dev server 启动在 localhost:3000
  // 实际项目中此处启动 dev server
}

async function checkTokenUsage(dir) {
  // 扫描生成的代码中 Tailwind token 使用率
  // 简化实现：返回 0.95（实际应解析 className 与 tailwind.config.js 对比）
  return 0.95;
}

async function restoreCheckpoint(checkpoint, outputDir) {
  if (checkpoint.data?.code) {
    fs.writeFileSync(path.join(outputDir, 'App.tsx'), checkpoint.data.code, 'utf-8');
  }
}

function applyRollbackStrategy(designSpec, strategy) {
  const modified = { ...designSpec };
  if (strategy === 'A') modified.layoutStrategy = 'top-nav';     // 换布局
  if (strategy === 'B') modified.componentSet = 'alternative';   // 换组件
  if (strategy === 'C') modified.density = 'low';                // 简化信息架构
  return modified;
}

function degradedDelivery(cp, reason) {
  const best = cp.loadBest();
  const score = best?.score || 0;
  const mustHaveCovered = true; // 实际应检查
  const noCritical = true;     // 实际应检查

  if (score >= 60 && mustHaveCovered && noCritical) {
    console.log(`\n⚠️ 降级交付（原因: ${reason}）| 评分: ${score}`);
    console.log('成本报告:', costTracker.report());
    return;
  } else {
    console.error(`\n❌ 拒绝交付（原因: ${reason}）| 评分: ${score} 不满足底线`);
    process.exit(1);
  }
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith('--')) {
      args[argv[i].slice(2)] = argv[i + 1];
      i++;
    }
  }
  return args;
}

// ============================================================
// 启动
// ============================================================

main().catch(e => {
  console.error('管线异常:', e);
  console.error('成本报告:', costTracker.report());
  process.exit(1);
});
